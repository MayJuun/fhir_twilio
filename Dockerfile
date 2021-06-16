################
FROM google/dart:2.13.0

WORKDIR /app
COPY pubspec.yaml /app/pubspec.yaml
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

########################
FROM subfuzion/dart:slim
COPY --from=0 /app/bin/server /app/bin/server
COPY --from=0 /app/lib/ /app/lib/
ENTRYPOINT ["/app/bin/server"]
