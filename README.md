[![Build Status](https://travis-ci.org/vorce/rushie.svg?branch=master)](https://travis-ci.org/vorce/rushie)

# Rushie

Rushie is an elixir library to make it easy to interact with the [Rushfiles API](https://rushfiles.com/).

## Usage

```elixir
def deps do
  [
    {:rushie, "~> 0.1"}
  ]
end
```

## Quickstart

Follow the steps below to get familiar with Rushie.

Pre-requisites:

- Account already created at some rushfiles instance. You will need your email/username and password,
and the domain (ex: "rushfiles.one").

### Login

To do anything you have to login. The `login` function needs your rushfiles
credentials (email and password) and will return a `Rushie.Login` struct.

```elixir
domain = "rushfiles.foo"
email = "myuser@email.com"
password = "secret"
{:ok, login} = Rushie.login(domain, email, password)
```

`Rushie.Login` contains `managed_shares` - a list of your managed shares in rushfiles represented as `Rushie.ManagedShare` structs.
You will need the struct for the share you want to interact with.

### Upload a file

Let's upload a test file to our share. We will pick the first available share,
and create a simple text file that we want to upload to it.

```elixir
share = List.first(login.managed_shares)
file_path = "./test_file_for_rushie.txt"
File.write(file_path, "Hello Rushie!")

Rushie.upload_file(login, share, file_path)
```

Hopefully you got back a `{:ok, %Rushie.FileMeta{}}` response. This means the upload
was successful.

### List files

```elixir
{:ok, files} = Rushie.list_files(login, share)
```

`list_files` will return a list of `Rushie.FileMeta` structs. You should see an
entry in the list that corresponds to the file you uploaded in the previous step.

### Download file

The following example downloads the first file in the first share and writes it
to the current directory with an easily identifiable name.

```elixir
file = List.first(files)
Rushie.download_file(login, share, file, "./first_file_in_#{share.name}")
```

Usually you probably want to save the file with its `public_name` - basically the
display name in rushfiles.

## Rushfiles

I don't know too much about this service to be honest.
It seems to be meant for hosting providers (or other partners) to offer their customers file sharing.

It was offered as part of my already existing hosting solution. I needed to backup some stuff so I figured why not use a service meant for this that I'm already paying for.

The API is quite quirky and the official docs aren't super helpful, plus seems out of date.

## Development notes

Rushfiles API documentation:

- http://helpdesk.rushfiles.com/support/solutions/articles/13000004767-file-api
- http://helpdesk.rushfiles.com/support/solutions/articles/13000004768-fileapiclasses
- Some sort of C# reference implementation for a client (super helpful): https://pastebin.com/ab5PbBdE
- There are reference responses returned from the API in `test/data`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rushie` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rushie, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rushie](https://hexdocs.pm/rushie).
