# frozen_string_literals: true

#
# saybot -- emit speech from macOS' TTS system in IRC
#
# This software is in the public domain.
#

require 'cinch'
require 'tempfile'
require 'json'

require 'http'
require 'dotenv/load'

CMD_REGEX = Regexp.new(/^\.say (-v (\S+) )?(.*)$/).freeze

def make_speech_sample(text, voice='whisper')
  outfile = Tempfile.new(['saybot', '.aiff'])

  IO.popen(['say', '-f-', "-o#{outfile.path}", "-v#{voice}"], 'w') do |p|
    p.puts text
    p.close
  end

  return outfile
end

def convert_to_ogg(infile)
  outfile = Tempfile.new(['saybot', '.ogg'])

  IO.popen(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', infile.path, outfile.path]) do |p|
    p.read
  end

  return outfile
end

def pomf(infile)
  response = HTTP.post(ENV['SAYBOT_POMF_UPLOAD_URL'], form: {
    'files[]' => [HTTP::FormData::File.new(infile)]
  })
  response = response.to_s
  response = JSON.parse(response.to_s)

  raise response unless response['success']

  return response['files'][0]['url']
end

def ensure_env_file_permissions!
  unless (File.stat('.env').mode & 0o077) == 0
    $stderr.write <<~err

      Your .env file is unprotected! Please adjust its permissions, e.g.:
      $ chmod 600 .env

      Refusing to run until this is resolved.

    err
    exit 1
  end
end

def main
  ensure_env_file_permissions!

  bot = Cinch::Bot.new do
    configure do |c|
      c.nick = ENV['SAYBOT_NICK']
      c.user = ENV['SAYBOT_USER']
      c.realname = ENV['SAYBOT_REALNAME']

      c.server = ENV['SAYBOT_HOST']
      c.port = ENV['SAYBOT_PORT']
      c.password = ENV['SAYBOT_PASSWORD'] if ENV.include?('SAYBOT_PASSWORD')
      c.channels = ENV['SAYBOT_CHANNELS'].split(' ')
      c.ssl.use = ENV['SAYBOT_SSL'].downcase == 'true'

      if ENV.include?('SAYBOT_SASL_USERNAME') and ENV.include?('SAYBOT_SASL_PASSWORD')
        c.sasl.username = ENV['SAYBOT_SASL_USERNAME']
        c.sasl.password = ENV['SAYBOT_SASL_PASSWORD']
      end
    end

    on :message, '.bots' do |m|
      m.target.notice("I let you .say things using macOS' text-to-speech system; run by Flisk")
    end

    on :message, '.source' do |m|
      m.target.notice("https://github.com/Flisk/saybot")
    end
  
    on :message, /^.say / do |m|
      if match = CMD_REGEX.match(m.message)
        voice = match[2] || 'whisper'
        text = match[3]

        aiff = make_speech_sample(text, voice)
        ogg = convert_to_ogg(aiff)
        aiff.close
        aiff.unlink

        url = pomf(ogg)
        ogg.close
        ogg.unlink

        m.target.notice("#{m.user.nick}: #{url}")
      end
    end
  end

  bot.loggers.level = :info
  bot.start
end

main

