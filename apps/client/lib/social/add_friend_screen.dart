import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/online_text.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/fields.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'social_gate.dart';
import 'social_models.dart';
import 'social_providers.dart';

/// Friend codes: 8 characters without look-alikes (`[A-HJKMNP-Z2-9]`).
final friendCodePattern = RegExp(r'^[A-HJKMNP-Z2-9]{8}$');

/// 6.2 Add friend: name search, my friend code (copy), add by code. The
/// QR card is replaced by the code (no camera / QR dependency yet).
class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _query = TextEditingController();
  final _code = TextEditingController();
  Timer? _debounce;
  List<PublicUser>? _results;
  bool _searching = false;
  String? _searchError;
  bool _sendingCode = false;
  String? _codeError;

  /// userId → result of my request (Göndərildi / Dostsunuz).
  final _sent = <String, FriendRequestStatus>{};
  final _busy = <String>{};

  static const searchDelay = Duration(milliseconds: 300);

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _code.dispose();
    super.dispose();
  }

  void _changed(String q) {
    _debounce?.cancel();
    final text = q.trim();
    if (text.length < 3) {
      setState(() {
        _results = null;
        _searching = false;
        _searchError = null;
      });
      return;
    }
    _debounce = Timer(searchDelay, () => _search(text));
  }

  Future<void> _search(String q) async {
    setState(() => _searching = true);
    try {
      final users = await ref.read(apiClientProvider).searchUsers(q);
      if (!mounted || _query.text.trim() != q) return;
      setState(() {
        _results = users;
        _searching = false;
        _searchError = null;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = friendErrorText(AppLocalizations.of(context), e);
      });
    }
  }

  Future<void> _add(PublicUser u) async {
    setState(() => _busy.add(u.id));
    try {
      final status = await ref.read(friendsProvider.notifier).add(userId: u.id);
      if (mounted) setState(() => _sent[u.id] = status);
    } on Object catch (e) {
      if (mounted) {
        showNote(context, friendErrorText(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(u.id));
    }
  }

  Future<void> _addByCode() async {
    final l = AppLocalizations.of(context);
    final code = _code.text.trim().toUpperCase();
    if (!friendCodePattern.hasMatch(code)) {
      setState(() => _codeError = l.friendErrNotFound);
      return;
    }
    setState(() {
      _sendingCode = true;
      _codeError = null;
    });
    try {
      final status = await ref.read(friendsProvider.notifier).add(code: code);
      if (!mounted) return;
      _code.clear();
      showNote(
        context,
        status == FriendRequestStatus.accepted
            ? l.friendAccepted
            : l.friendRequested,
      );
    } on Object catch (e) {
      if (mounted) setState(() => _codeError = friendErrorText(l, e));
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.addFriendTitle, bare: true),
            Expanded(
              child: SocialGate(
                builder: (context, account) {
                  final code =
                      ref.watch(friendsProvider).value?.friendCode ??
                      account.friendCode ??
                      '';
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      NardSearchField(
                        controller: _query,
                        hint: l.addFriendSearchHint,
                        onChanged: _changed,
                        maxLength: 20,
                      ),
                      ..._resultRows(l),
                      const SizedBox(height: 22),
                      OrDivider(l.addFriendOr),
                      const SizedBox(height: 22),
                      _codeCard(context, l, code),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Overline(
                          l.addFriendEnterCode,
                          color: c.text.withValues(alpha: .6),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: NardTextField(
                              controller: _code,
                              height: 48,
                              error: _codeError != null,
                              maxLength: 8,
                              textCapitalization: TextCapitalization.characters,
                              style: NardType.mono.copyWith(
                                fontSize: 16,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w600,
                              ),
                              onSubmitted: (_) => _addByCode(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SmallActionButton(
                            label: l.send,
                            height: 48,
                            busy: _sendingCode,
                            onTap: _addByCode,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                        child: Text(
                          _codeError ?? l.addFriendCodeHint,
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color:
                                _codeError != null
                                    ? c.dangerText
                                    : c.text.withValues(alpha: .5),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _resultRows(AppLocalizations l) {
    final c = context.nard;
    final q = _query.text.trim();
    Widget note(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
      child: Text(
        text,
        style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .6)),
      ),
    );
    if (q.isNotEmpty && q.length < 3) return [note(l.addFriendSearchShort)];
    if (_searching) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
          ),
        ),
      ];
    }
    if (_searchError != null) return [note(_searchError!)];
    final results = _results;
    if (results == null) return const [];
    if (results.isEmpty) return [note(l.friendErrNotFound)];
    final friends = ref.watch(friendsProvider).value;
    return [
      const SizedBox(height: 8),
      for (final u in results)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Avatar(name: u.name, size: 42, tone: AvatarTone.opponent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.labelM.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _meta(l, u),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.text.withValues(alpha: .6),
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _addButton(l, u, friends),
            ],
          ),
        ),
    ];
  }

  Widget _addButton(AppLocalizations l, PublicUser u, FriendsOverview? f) {
    final status =
        _sent[u.id] ??
        (f?.isFriend(u.id) ?? false
            ? FriendRequestStatus.accepted
            : f?.isRequested(u.id) ?? false
            ? FriendRequestStatus.requested
            : null);
    if (status != null) {
      return SmallActionButton(
        label:
            status == FriendRequestStatus.accepted
                ? l.friendAccepted
                : l.friendRequested,
        style: SmallButtonStyle.outline,
        onTap: null,
      );
    }
    return SmallActionButton(
      label: l.addFriendAction,
      busy: _busy.contains(u.id),
      onTap: () => _add(u),
    );
  }

  String _meta(AppLocalizations l, PublicUser u) {
    final rating = u.bestRating;
    final base = rating == null ? l.levelShort(u.level) : l.rankMeta(rating);
    final clan = u.clan;
    return clan == null ? base : l.metaWithClan(base, l.clanTag(clan.tag));
  }

  Widget _codeCard(BuildContext context, AppLocalizations l, String code) {
    final c = context.nard;
    void copy() {
      if (code.isEmpty) return;
      unawaited(Clipboard.setData(ClipboardData(text: code)));
      showNote(context, l.copied);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          Overline(l.addFriendCodeLabel, color: c.text.withValues(alpha: .6)),
          const SizedBox(height: 14),
          Pressable(
            onTap: copy,
            semanticLabel: l.addFriendCopyCode,
            child: Text(
              code.isEmpty ? l.valueNone : code,
              style: NardType.mono.copyWith(
                fontSize: 26,
                height: 1.2,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.6,
                color: c.accentHi,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.addFriendCodeCaption,
            textAlign: TextAlign.center,
            style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .7)),
          ),
          const SizedBox(height: 14),
          SmallActionButton(
            label: l.addFriendCopyCode,
            style: SmallButtonStyle.strong,
            height: 44,
            onTap: code.isEmpty ? null : copy,
          ),
        ],
      ),
    );
  }
}
