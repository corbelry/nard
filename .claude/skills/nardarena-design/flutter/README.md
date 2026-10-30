# Flutter tema paketi

`lib/theme/` qovluğunu layihənin `lib/` qovluğuna kopyala.

```dart
MaterialApp(
  theme: NardTheme.build(NardColors.defaultTheme),   // = sebeke (1c)
  // NardColors.ceviz (1a), NardColors.komur (1b), NardColors.light
);
// istifadə: context.nard.accent, NardType.clock, NardSpace.s4, NardMotion.checker
```

## Şriftlər (pubspec.yaml)
Google Fonts-dan endir və `assets/fonts/`-a qoy (OFL):
```yaml
flutter:
  fonts:
    - family: NotoSerifDisplay
      fonts: [{asset: assets/fonts/NotoSerifDisplay-SemiBold.ttf, weight: 600}, {asset: assets/fonts/NotoSerifDisplay-MediumItalic.ttf, weight: 500, style: italic}]
    - family: IBMPlexSans
      fonts: [{asset: assets/fonts/IBMPlexSans-Regular.ttf}, {asset: assets/fonts/IBMPlexSans-Medium.ttf, weight: 500}, {asset: assets/fonts/IBMPlexSans-SemiBold.ttf, weight: 600}]
    - family: IBMPlexSansCondensed
      fonts: [{asset: assets/fonts/IBMPlexSansCondensed-SemiBold.ttf, weight: 600}]
    - family: IBMPlexMono
      fonts: [{asset: assets/fonts/IBMPlexMono-Regular.ttf}]
```

## Taxta (Flame)
- `BoardGeometry` — bütün ölçülər 640 × H məntiqi məkanda; komponenti `scale = boardWidthPx / 640` ilə böyüt.
- `BoardTheme.all` — 6 kosmetik tema; teksturalar `assets/themes/{id}/`.
- Vurğular, xəyal daşlar, seçim halqası və xana nömrələri kodla çəkilir (`BoardOverlay`).

## Adlandırma
CSS token → Dart: `--brass-500` → `NardPalette.brass500`, `--text-dim` → `context.nard.textDim`, `--dur-checker` → `NardMotion.checker`.
