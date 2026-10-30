import 'dart:io';

/// Label set of one sample, e.g. `{'mode': 'casual'}`.
typedef Labels = Map<String, String>;

/// A minimal Prometheus registry (text exposition format 0.0.4): counters,
/// histograms and gauges read at scrape time. No dependencies; the game
/// server's metric set is small and fixed (docs/LOAD_TEST.md, ADR-043).
class Metrics {
  final _families = <String, _Family>{};

  /// A monotonically increasing counter (name should end in `_total`).
  Counter counter(String name, String help) =>
      _register(name, () => Counter._(name, help)) as Counter;

  /// A histogram with cumulative [buckets] (upper bounds, ascending).
  Histogram histogram(String name, String help, List<double> buckets) =>
      _register(name, () => Histogram._(name, help, buckets)) as Histogram;

  /// A gauge whose value is read when `/metrics` is scraped.
  void gauge(String name, String help, num Function() read) =>
      gauges(name, help, () => {const <String, String>{}: read()});

  /// A labelled gauge family read at scrape time (one sample per label set).
  void gauges(String name, String help, Map<Labels, num> Function() read) =>
      _register(name, () => _GaugeFamily(name, help, read));

  _Family _register(String name, _Family Function() create) {
    final existing = _families[name];
    if (existing != null) return existing;
    return _families[name] = create();
  }

  /// Process gauges: resident memory, peak memory, start time.
  void addProcessMetrics({int? startedAtMs}) {
    final start = (startedAtMs ?? DateTime.now().millisecondsSinceEpoch) / 1000;
    gauge(
      'process_resident_memory_bytes',
      'Resident memory size in bytes.',
      () => ProcessInfo.currentRss,
    );
    gauge(
      'process_max_resident_memory_bytes',
      'Peak resident memory size in bytes.',
      () => ProcessInfo.maxRss,
    );
    gauge(
      'process_start_time_seconds',
      'Start time of the process since unix epoch in seconds.',
      () => start,
    );
  }

  /// The registry in Prometheus text format.
  String render() {
    final out = StringBuffer();
    for (final f in _families.values) {
      out
        ..writeln('# HELP ${f.name} ${_escapeHelp(f.help)}')
        ..writeln('# TYPE ${f.name} ${f.type}');
      f.write(out);
    }
    return out.toString();
  }

  static const contentType = 'text/plain; version=0.0.4; charset=utf-8';
}

sealed class _Family {
  _Family(this.name, this.help);

  final String name;
  final String help;
  String get type;
  void write(StringBuffer out);
}

class Counter extends _Family {
  Counter._(super.name, super.help);

  final _values = <String, num>{};

  @override
  String get type => 'counter';

  void inc([Labels labels = const {}, num by = 1]) {
    final key = _labelText(labels);
    _values[key] = (_values[key] ?? 0) + by;
  }

  num value([Labels labels = const {}]) => _values[_labelText(labels)] ?? 0;

  @override
  void write(StringBuffer out) {
    if (_values.isEmpty) out.writeln('$name 0');
    _values.forEach((labels, v) => out.writeln('$name$labels ${_num(v)}'));
  }
}

class Histogram extends _Family {
  Histogram._(super.name, super.help, this.buckets);

  final List<double> buckets;
  final _series = <String, _HistogramSeries>{};

  @override
  String get type => 'histogram';

  void observe(double value, [Labels labels = const {}]) {
    final s = _series.putIfAbsent(
      _labelText(labels),
      () => _HistogramSeries(labels, buckets.length),
    );
    for (var i = 0; i < buckets.length; i++) {
      if (value <= buckets[i]) s.counts[i]++;
    }
    s.count++;
    s.sum += value;
  }

  int count([Labels labels = const {}]) =>
      _series[_labelText(labels)]?.count ?? 0;

  @override
  void write(StringBuffer out) {
    final series =
        _series.isEmpty
            ? [_HistogramSeries(const {}, buckets.length)]
            : _series.values;
    for (final s in series) {
      for (var i = 0; i < buckets.length; i++) {
        final l = _labelText({...s.labels, 'le': _num(buckets[i])});
        out.writeln('${name}_bucket$l ${s.counts[i]}');
      }
      out
        ..writeln(
          '${name}_bucket${_labelText({...s.labels, 'le': '+Inf'})} '
          '${s.count}',
        )
        ..writeln('${name}_sum${_labelText(s.labels)} ${_num(s.sum)}')
        ..writeln('${name}_count${_labelText(s.labels)} ${s.count}');
    }
  }
}

class _HistogramSeries {
  _HistogramSeries(this.labels, int buckets) : counts = List.filled(buckets, 0);

  final Labels labels;
  final List<int> counts;
  int count = 0;
  double sum = 0;
}

class _GaugeFamily extends _Family {
  _GaugeFamily(super.name, super.help, this.read);

  final Map<Labels, num> Function() read;

  @override
  String get type => 'gauge';

  @override
  void write(StringBuffer out) {
    read().forEach(
      (labels, v) => out.writeln('$name${_labelText(labels)} ${_num(v)}'),
    );
  }
}

String _labelText(Labels labels) {
  if (labels.isEmpty) return '';
  final keys = labels.keys.toList()..sort();
  final parts = [for (final k in keys) '$k="${_escapeValue(labels[k]!)}"'];
  return '{${parts.join(',')}}';
}

String _escapeValue(String v) =>
    v.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n');

String _escapeHelp(String v) =>
    v.replaceAll(r'\', r'\\').replaceAll('\n', r'\n');

String _num(num v) {
  if (v is int) return '$v';
  if (v.isNaN) return 'NaN';
  if (v.isInfinite) return v > 0 ? '+Inf' : '-Inf';
  if (v == v.roundToDouble() && v.abs() < 1e15) return '${v.toInt()}';
  return '$v';
}
