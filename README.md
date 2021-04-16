# saybot

A jury-rigged pipe between macOS's `say` command and IRC.

There's lots of hardcoded stuff going on in `main.rb`. If you want to run this,
you'd better know Ruby and get your hands dirty, and just to be perfectly
clear, this requires macOS (or a compatible implementation of `say`, which to
my knowledge doesn't exist).

You will have to copy `.env.sample` to `.env` and edit it appropriately.

I run it using [Nix](https://nixos.org/) like so:

```sh
$ nix-shell -p ruby ffmpeg --command "bundle install && bundle exec ruby main.rb"
```

## Usage

`.say Your text here.`

`.say -v bells Ding dong, ding dong.`

## Voices

Here's a short (non-exhaustive) reference of available voices:

* albert
* bahh
* bells
* boing
* bubbles
* cellos
* deranged
* hysterical
* trinoids
* whisper
* zarvox

These are basically almost all the novelty voices available. Others may also
work.

## Copyright

This software is in the public domain.

That's right, do whatever.

Let's all love Lain.

