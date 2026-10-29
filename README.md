# NardArena

Cross-platform backgammon / nard (Short Nard and Long Nard) with offline AI,
online ranked play, tournaments, clans and cosmetics.

- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Rules: [Short Nard](docs/RULES_SHORT.md) · [Long Nard](docs/RULES_LONG.md)
- Decisions: [docs/DECISIONS.md](docs/DECISIONS.md)
- Changelog: [docs/CHANGELOG.md](docs/CHANGELOG.md)

## Quick start

```bash
dart pub get
cd packages/nard_core && dart test
docker compose -f infra/docker-compose.yml up --build
```
