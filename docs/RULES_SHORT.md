# Short Nard (international backgammon) — rule catalogue

Each rule has an ID. Tests in `packages/nard_core/test/` are named after the
ID they prove, so `grep -r "SN-10" packages/nard_core/test` finds them.
Points are numbered from the mover's own perspective: it moves from 24
towards 1, its home board is 1–6, the bar is 25 and borne off is 0.

| ID | Rule | Tests |
|---|---|---|
| SN-01 | Start: 2 checkers on 24, 5 on 13, 3 on 8, 5 on 6 for each side. A side's point *p* is the opponent's point 25−*p*. | `short_nard_test` |
| SN-02 | Opening roll: each side throws one die, ties are re-thrown, the higher die starts and plays **both opening dice** as its first roll. | `game_state_test` |
| SN-03 | A checker moves exactly the number on a die towards its point 1. | `short_nard_test` |
| SN-04 | A double is played four times. | `short_nard_test` |
| SN-05 | A point held by two or more opposing checkers is closed. | `short_nard_test` |
| SN-06 | Landing on a single opposing checker (blot) hits it; the hit checker goes to the bar. | `short_nard_test` |
| SN-07 | While a side has checkers on the bar it must enter them (on point 25−die) before any other move. | `short_nard_test` |
| SN-08 | A die that cannot be used is forfeited; if nothing can be played the turn passes (an empty turn). | `short_nard_test`, `game_state_test` |
| SN-09 | Both dice (all four for doubles) must be used whenever any sequence allows it, including a particular order of the dice. | `short_nard_test`, `property_test` |
| SN-10 | If either die but not both can be played, the larger die must be played; if only the smaller can be played, it is played. | `short_nard_test`, `property_test` |
| SN-11 | With doubles, as many of the four moves as possible must be played. | `short_nard_test` |
| SN-12 | Bearing off is allowed only when all 15 checkers are in the home board (or already off). | `short_nard_test` |
| SN-13 | Bear off with the exact die; a higher die bears off from the highest occupied point only if no checker is on a higher point; otherwise the die must be played inside the home board. Bearing off is never forced over a legal alternative unless the max-dice rules require it. | `short_nard_test` |
| SN-14 | A checker hit during bear-off must re-enter and come home before bearing off resumes. | `short_nard_test` |
| SN-15 | Gammon (×2): the loser has borne off no checker. | `short_nard_test` |
| SN-16 | Backgammon (×3): gammon **and** a loser checker on the bar or in the winner's home board (loser's points 19–24). | `short_nard_test` |
| SN-17 | Doubling cube: only before rolling, by the side to move, if the cube is centred or owned by that side. Take → value ×2, owned by the taker. Drop → the doubler wins the current (pre-double) value. Default cap 64 (configurable). | `game_state_test` |
| SN-18 | Jacoby rule (money play, optional): gammons/backgammons count single while the cube is centred at 1. | `short_nard_test`, `game_state_test` |
| SN-19 | Crawford rule in matches — see MT-03. | `match_and_record_test` |
| SN-20 | Resignation is offered at a level (single/gammon/backgammon); the opponent accepts (game ends at level × cube) or rejects (play continues). | `game_state_test` |

## Match rules

| ID | Rule |
|---|---|
| MT-01 | Formats: single game, match to N points (3/5/7/11/15/21) or unlimited money session (length 0). |
| MT-02 | A match ends as soon as a side reaches N or more points. |
| MT-03 | Crawford: the first time a side reaches N−1 points, the next game is played without the cube. All later games (post-Crawford) use the cube again. A 1-point match never has a Crawford game (the cube is meaningless there). |

## Not implemented (by decision, see DECISIONS.md)

Beavers/raccoons, automatic doubles, Murphy rule, Holland rule.
