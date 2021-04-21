.PHONY: all run

all:
	@echo "This is a convenience Makefile to run the bot; try \`make run\`."

run:
	nix-shell -p ruby ffmpeg --command "bundle install && exec bundle exec ruby main.rb"
