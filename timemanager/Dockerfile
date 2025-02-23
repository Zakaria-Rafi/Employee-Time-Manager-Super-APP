FROM elixir:alpine

WORKDIR /usr/share/app

RUN apk add --no-cache bash git inotify-tools curl make cmake g++ build-base

COPY mix.exs mix.lock .

RUN mix local.hex --force
RUN mix deps.get
#RUN mix archive.install hex phx_new --force
RUN mix local.rebar --force

COPY . .

RUN mix deps.compile

EXPOSE 4000

CMD ["mix", "phx.server"]