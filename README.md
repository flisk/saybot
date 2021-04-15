# saybot

A jury-rigged pipe between macOS's `say` command and IRC.

There's lots of hardcoded stuff going on in `main.rb`. If you want to run this,
you'd better know Ruby and get your hands dirty, and just to be perfectly
clear, this requires macOS (or a compatible implementation of `say`, which to
my knowledge doesn't exist).

I run it using [Nix](https://nixos.org/) like so:

```sh
$ nix-shell -p ruby --command "bundle install && bundle exec ruby main.rb"
```

Let's all love lain.

