.PHONY: clean code-analysis code-analysis-strict test

all: build ;

clean:
	rm -rf _build deps mix.lock

code-analysis: deps
	mix credo

code-analysis-strict: deps
	mix credo --strict

deps: mix.exs
	mix deps.get
	touch deps

dev: deps
	iex -S mix

outdated-dependencies: deps
	mix hex.outdated

test: deps
	MIX_ENV=test mix coveralls
