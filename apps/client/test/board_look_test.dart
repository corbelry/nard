import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/board/board_layout.dart';
import 'package:nard_client/board/board_painter.dart';
import 'package:nard_client/cosmetics/board_look.dart';
import 'package:nard_client/cosmetics/catalog.dart';
import 'package:nard_client/cosmetics/set_preview.dart';
import 'package:nard_client/theme/board_theme.dart';
import 'package:nard_core/nard_core.dart';

import 'store_fakes.dart';

void main() {
  group('BoardLook', () {
    test('built-in walnut equals the pre-Phase-4 painter constants', () {
      const w = BoardLook.walnut;
      expect(w.frame, const [
        Color(0xFF6E4224),
        Color(0xFF4B2B16),
        Color(0xFF5D3720),
      ]);
      expect(w.field, const [Color(0xFFC49159), Color(0xFFA87745)]);
      // Odd points were `_darkPoint`, even points `_lightPoint`.
      expect(w.pointA, const [Color(0xFF2E1C10), Color(0xFF1A0E07)]);
      expect(w.pointB, const [Color(0xFFF2E7CF), Color(0xFFD5C29D)]);
      expect(w.tray, const [Color(0xFF2A170C), Color(0xFF1C0F07)]);
      expect(w.numbers, BoardTheme.walnut.numberColor);
      expect(w.grain, isTrue);
      expect(w.light.stops, const [
        Color(0xFFFFFBF2),
        Color(0xFFEFE4CF),
        Color(0xFFD4C3A2),
        Color(0xFFB3A07C),
      ]);
      expect(w.light.groove, const Color(0x2B6E5532));
      expect(w.dark.stops, const [
        Color(0xFF5D564F),
        Color(0xFF2B2724),
        Color(0xFF151312),
        Color(0xFF0A0909),
      ]);
      expect(w.dark.groove, const Color(0x0EFFFFFF));
      expect(w.light.rim, isNull);
      expect(w.light.flat, isFalse);
      // Was Color.fromRGBO(255, 250, 240) → (228, 214, 184) with pips
      // (58, 42, 30) → (13, 8, 6).
      expect(w.dice.face, const [
        Color.fromRGBO(255, 250, 240, 1),
        Color.fromRGBO(228, 214, 184, 1),
      ]);
      expect(w.dice.pip, const [
        Color.fromRGBO(58, 42, 30, 1),
        Color.fromRGBO(13, 8, 6, 1),
      ]);
    });

    test("the catalog's board.walnut parses to the built-in walnut", () {
      final item = CatalogItem.tryParse(walnutJson)!;
      expect(item.look, BoardLook.walnut);
      expect(item.isDefault, isTrue);
      expect(item.obtain, Obtain.defaultItem);
      expect(item.nameFor('az'), 'Klassik Qoz');
      // ru/tr fall back to English (ADR-034).
      expect(item.nameFor('ru'), 'Classic Walnut');
    });

    test('parses rims, flat materials, inlay and 3-stop crystal dice', () {
      final catalog = Catalog.fromJson(catalogJson);
      final marble = catalog.item('board.marble_royale')!.look!;
      expect(marble.id, 'marble_royale');
      expect(marble.inlay, const [Color(0xFFE9CF82), Color(0xFFA8822F)]);
      expect(marble.light.rim, const Color(0xFFC9A24A));
      expect(marble.dice.face, hasLength(3));
      expect(marble.dice.face.first, const Color(0xF2EBF5FF));
      expect(marble.grain, isFalse);
      final minimal = catalog.item('board.minimal_pro')!.look!;
      expect(minimal.light.flat, isTrue);
      expect(minimal.dark.rim, const Color(0xFF4A4D53));
      expect(minimal.dice.flat, isTrue);
      final baku = catalog.item('board.baku_night')!.look!;
      expect(baku.glow, const Color(0x2EE8783C));
    });

    test('missing or malformed parts fall back to walnut', () {
      const json = {
        'frame': ['#FF000000', 'nope'],
        'field': ['#123456'],
        'numbers': 42,
        'light': {'stops': <String>[]},
      };
      final look = BoardLook.fromJson(json, id: 'x');
      expect(look.id, 'x');
      expect(look.frame, BoardLook.walnut.frame);
      // A single #RRGGBB colour becomes an opaque flat gradient.
      expect(look.field, const [Color(0xFF123456), Color(0xFF123456)]);
      expect(look.numbers, BoardLook.walnut.numbers);
      expect(look.light, BoardLook.walnut.light);
      expect(BoardLook.fromJson(null), BoardLook.walnut);
      expect(parseColor('#80FFFFFF'), const Color(0x80FFFFFF));
      expect(parseColor('#FFF'), isNull);
    });

    test('catalog skips broken entries; loadout slots pick the set', () {
      final catalog = Catalog.fromJson({
        'items': [
          ...catalogJson['items']! as List,
          {'id': 1},
          'junk',
        ],
      });
      expect(catalog.items, hasLength((catalogJson['items']! as List).length));
      expect(catalog.lookFor(const {}), BoardLook.walnut);
      expect(
        catalog.lookFor(const {'board': 'board.carpet_heritage'}).id,
        'carpet_heritage',
      );
      expect(catalog.categories.first, ItemCategory.board);
      expect(Catalog.builtin.lookFor(const {}), BoardLook.walnut);
    });

    test('every seeded set paints without errors', () {
      final catalog = Catalog.fromJson(catalogJson);
      for (final item in catalog.inCategory(ItemCategory.board)) {
        final scene = previewScene(
          item.look!,
        ).withLook(item.look!, sideLooks: {Side.black: BoardLook.walnut});
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final layout = BoardLayout(
          rules: scene.rules,
          viewer: scene.viewer,
          height: BoardGeometry.heightPortrait,
        );
        BoardPainter.paintBoard(canvas, layout, scene);
        for (final side in Side.values) {
          BoardPainter.paintChecker(
            canvas,
            const Offset(50, 50),
            19,
            side,
            material: scene.material(side),
          );
        }
        BoardPainter.paintDie(
          canvas,
          const Offset(80, 80),
          5,
          dice: scene.diceLook,
        );
        recorder.endRecording().dispose();
      }
    });
  });
}
