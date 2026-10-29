# Build context: repository root (the Dart workspace).
FROM dart:3.7.2 AS build
WORKDIR /src
COPY pubspec.yaml pubspec.lock analysis_options.yaml ./
COPY packages/ packages/
COPY apps/game_server/ apps/game_server/
# The Flutter client is a workspace member but needs the Flutter SDK; drop
# it from the workspace for this pure-Dart build.
RUN sed -i '/apps\/client/d' pubspec.yaml && dart pub get
RUN dart compile exe apps/game_server/bin/server.dart -o /server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /app/server
EXPOSE 8080
CMD ["/app/server"]
