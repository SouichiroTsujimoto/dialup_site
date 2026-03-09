FROM elixir:1.19-alpine

WORKDIR /build

RUN apk add --no-cache build-base git

RUN mix local.hex --force && mix local.rebar --force

# path dep の dialup も一緒にコピー
COPY dialup/ /dialup/
COPY dialup_site/ .

ENV MIX_ENV=prod

RUN mix deps.get --only prod
RUN mix compile

WORKDIR /app
RUN cp -r /build/. .

EXPOSE 4001

CMD ["mix", "run", "--no-halt"]
