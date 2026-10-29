# Long Nard (Uzun nərd) — rule catalogue

Each rule has an ID that the tests in `packages/nard_core/test/` cite.
Points are numbered from the mover's own perspective: it moves from its head
(own point 24) towards 1, its home board is 1–6, borne off is 0. There is no
bar.

| ID | Rule | Tests |
|---|---|---|
| LN-01 | Start: all 15 checkers on the head (own point 24). | `long_nard_test` |
| LN-02 | Both sides move in the same rotational direction (counter-clockwise) from heads on opposite sides; a side's point *p* is the opponent's point *p*±12. The opponent's head is own point 12. | `long_nard_test` |
| LN-03 | No hitting: a checker may not land on a point holding **any** opposing checker. | `long_nard_test` |
| LN-04 | Only one checker may leave the head per turn. | `long_nard_test` |
| LN-05 | Exception: on a side's **first** turn, 6-6, 4-4 or 3-3 allow two checkers to leave the head (the opponent's head would otherwise block the full roll). Applies to both players. | `long_nard_test` |
| LN-06 | Six-block rule: a side may not hold six consecutive points (consecutive along the **opponent's** path) unless at least one opposing checker is already past the block. Borne-off opposing checkers count as past. Checked after every single move. | `long_nard_test`, `property_test` |
| LN-07 | Dice usage as in Short Nard: use both dice if possible; if only one can be used, the larger. | `long_nard_test`, `property_test` |
| LN-08 | A double is played four times (as many as possible). | `long_nard_test` |
| LN-09 | Bearing off as in Short Nard (SN-12, SN-13). | `long_nard_test` |
| LN-10 | Oyn (×1): the loser has borne off at least one checker. | `long_nard_test` |
| LN-11 | Mars (×2): the loser has borne off no checker. | `long_nard_test` |
| LN-12 | Koks (×3): mars **and** at least one loser checker has not passed the winner's home board (still on loser's own points 13–24). Can be disabled (`LongNardRules(koks: false)`). | `long_nard_test` |
| LN-13 | Opening: each side throws one die, ties re-thrown; the higher die moves first and then **rolls both dice** (the opening dice are not played). | `game_state_test` |
| LN-14 | No doubling cube. | `long_nard_test` |

## Open questions for the product owner

* LN-12 koks definition — regional rule sets differ (see DECISIONS ADR-009).
* Some rule sets give the second player a final roll to draw the game when
  the first player finishes; not implemented.
