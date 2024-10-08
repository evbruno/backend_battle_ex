FROM elixir:1.17.3-alpine AS build

WORKDIR /app

RUN apk update \
    && apk --no-cache --update add build-base 

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY . .

RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

# Stage 2: Create the release image
FROM alpine:3.20 AS app

RUN apk add --no-cache openssl ncurses-libs libstdc++ bash

WORKDIR /app
COPY --from=build /app/_build/prod/rel/backend_battle_ex .

ENV MIX_ENV=prod \
    LANG=en_US.UTF-8 \
    REPLACE_OS_VARS=true

ENV PORT=4000
EXPOSE 4000

CMD ["./bin/backend_battle_ex", "start"]