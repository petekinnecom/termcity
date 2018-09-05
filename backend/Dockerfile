FROM alpine:3.7

# for elixir
RUN apk add --no-cache \
  build-base \
  erlang-crypto \
  elixir \
  erlang-parsetools \
  erlang-eunit \
  erlang-syntax-tools \
  erlang erlang-sasl erlang-dev erlang-parsetools \
  erlang-runtime-tools \
  erlang-dev \
  git
RUN mix local.hex --force && mix local.rebar --force
COPY script/wait-for-it /bin/wait-for-it

ENV MIX_ENV=test
EXPOSE 3000
WORKDIR /app
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock
RUN mix do deps.get, deps.compile
COPY lib /app/lib
COPY test /app/test
COPY priv /app/priv
COPY config /app/config
