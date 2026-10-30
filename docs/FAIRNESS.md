# Provably fair dice

Online games use dice that neither the server nor a player can choose, and
that anyone can recompute after the game (spec §7.1). Implementation:
`packages/nard_core/lib/src/fair_dice.dart` (`FairDice`), shared by the game
server and the client's verification screen (10.3).

| ID | Rule |
|---|---|
| FD-01 | Before the game the server picks a random 256-bit `serverSeed` (64 lowercase hex chars) and publishes `commitment = sha256(utf8(serverSeed))` (lowercase hex). |
| FD-02 | Each player sends a `clientSeed` (any string, ≤ 64 chars) before the opening roll. Roll *N* (0, 1, 2, … for the whole game, opening included) is `HMAC-SHA256(key = utf8(serverSeed), message = utf8("clientSeedA|clientSeedB|N"))`, where A is White's seed and B is Black's. |
| FD-03 | MAC bytes are read in order: a byte *b* < 252 gives a die `b % 6 + 1`; bytes ≥ 252 are skipped (252 = 6 × 42, so every face has probability exactly 1/6). The first two usable bytes are die 1 and die 2. If a MAC has fewer than two usable bytes, the message gets the suffix `|k` (k = 1, 2, …) and reading continues with the next MAC. |
| FD-04 | The opening roll consumes one roll: die 1 is White's die, die 2 Black's. A tie consumes the roll and the next roll is thrown. |
| FD-05 | After the game the server reveals `serverSeed`; the client checks `sha256(serverSeed) == commitment` and recomputes every roll of the game record. |

## Verify by hand

```python
import hmac, hashlib
def roll(server_seed, a, b, n):
    dice, k = [], 0
    while len(dice) < 2:
        msg = f"{a}|{b}|{n}" + (f"|{k}" if k else "")
        mac = hmac.new(server_seed.encode(), msg.encode(), hashlib.sha256).digest()
        for byte in mac:
            if byte < 252:
                dice.append(byte % 6 + 1)
                if len(dice) == 2:
                    break
        k += 1
    return tuple(dice)
```

Test vectors (from this script) are in
`packages/nard_core/test/fair_dice_test.dart`.

## Threat model (short)

- The server cannot pick favourable dice after seeing the client seeds:
  the seed is committed before they are known.
- A player cannot steer the dice: the other player's seed and the hidden
  server seed both enter every roll.
- The server could still collude with one player by leaking the seed
  during the game; mitigations are operational (seeds never leave the game
  server process, Phase 7 audit logging).
