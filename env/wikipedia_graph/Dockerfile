FROM elixir:1.17

WORKDIR /app

COPY mix.lock ./
COPY mix.exs ./
COPY config ./config
COPY lib ./lib

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile

CMD ["mix", "run", "--no-halt"]
