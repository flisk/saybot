.PHONY: all run

all:
	@echo This is a convenience Makefile to run the bot; try `make run`.

run:
	nix-shell -p ruby ffmpeg --command "bundle install && bundle exec ruby main.rb"
