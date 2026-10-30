import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import 'clan_models.dart';

/// Localized clan copy shared by the 5.x / 19.x screens.
extension ClanText on AppLocalizations {
  String roleName(ClanRole role) => switch (role) {
    ClanRole.leader => roleLeader,
    ClanRole.coLeader => roleCoLeader,
    ClanRole.elder => roleElder,
    ClanRole.member => roleMember,
  };

  String policyName(JoinPolicy p) => switch (p) {
    JoinPolicy.open => policyOpen,
    JoinPolicy.request => policyRequest,
    JoinPolicy.invite => policyInvite,
  };

  String policySub(JoinPolicy p) => switch (p) {
    JoinPolicy.open => policyOpenSub,
    JoinPolicy.request => policyRequestSub,
    JoinPolicy.invite => policyInviteSub,
  };

  String languageName(String code) => switch (code) {
    'az' => languageNameAz,
    'tr' => languageNameTr,
    'ru' => languageNameRu,
    _ => languageNameEn,
  };

  /// "Səv. 14 · 42/50 · 2140" (rating "—" when the clan has none).
  String clanMeta(ClanSummary c) => clanListMeta(
    c.level,
    c.memberCount,
    c.maxMembers,
    c.rating == null ? valueNone : '${c.rating}',
  );

  String shapeName(String id) => switch (id) {
    'shield' => emblemShapeShield,
    'hexagon' => emblemShapeHexagon,
    'octagon' => emblemShapeOctagon,
    'circle' => emblemShapeCircle,
    'diamond' => emblemShapeDiamond,
    'banner' => emblemShapeBanner,
    'star' => emblemShapeStar,
    'arch' => emblemShapeArch,
    _ => id,
  };

  String symbolName(String id) => switch (id) {
    'diamond' => emblemSymbolDiamond,
    'diamond_dot' => emblemSymbolDiamondDot,
    'circle' => emblemSymbolCircle,
    'square' => emblemSymbolSquare,
    'initials' => emblemSymbolInitials,
    _ => id,
  };

  String colorName(String id) => switch (id) {
    'garnet' => emblemColorGarnet,
    'indigo' => emblemColorIndigo,
    'emerald' => emblemColorEmerald,
    'brass' => emblemColorBrass,
    'purple' => emblemColorPurple,
    'slate' => emblemColorSlate,
    'ivory' => emblemColorIvory,
    'blue' => emblemColorBlue,
    'walnut' => emblemColorWalnut,
    _ => id,
  };

  String patternName(String id) =>
      id == 'lattice' ? emblemPatternLattice : emblemPatternNone;

  /// A system chat line (`event` + `data`), or null for unknown events.
  String? systemText(ClanMessage m) {
    final d = m.data;
    final name = '${d['name'] ?? ''}';
    String n(Object? v) => v is num ? formatAmount(v.toInt()) : '${v ?? 0}';
    return switch (m.event) {
      'created' => clanSysCreated(name),
      'joined' => clanSysJoined(name),
      'left' => clanSysLeft(name),
      'kicked' => clanSysKicked(name),
      'promoted' ||
      'demoted' => clanSysRole(name, roleName(ClanRole.parse(d['role']))),
      'leader' => clanSysLeader(name),
      'renamed' => clanSysRenamed(name, '${d['tag'] ?? ''}'),
      'donated' => clanSysDonated(name, n(d['amount'])),
      'chest_full' => clanSysChestFull,
      'war_started' => clanSysWarStarted(name, '${d['tag'] ?? ''}'),
      'war_win' => clanSysWarWin(name, n(d['points'])),
      'war_ended' => clanSysWarEnded(n(d['mine']), n(d['theirs'])),
      _ => null,
    };
  }
}
