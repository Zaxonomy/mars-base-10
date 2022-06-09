# frozen_string_literal: true

require "thor"
require "pastel"
require "tty-font"

module MarsBase10
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    class_option :"no-color", type: :boolean, default: false, desc: "Disable colorization in output"

    # Error raised by this runner
    Error = Class.new(StandardError)

    def self.exit_on_failure?
      true
    end

    desc "help, --help, -h", "Describe available commands or one specific command"
    map %w[-h --help] => :help
    def help(*args)
      font = TTY::Font.new(:standard)
      pastel = Pastel.new(enabled: !options["no-color"])
      puts pastel.yellow(font.write("Mars Base 10"))
      super
    end

    desc "launch  [SHIP_CONFIG]", "Start Mars Base 10 connected to the Urbit ship defined in SHIP_CONFIG. (Required)"
    long_desc <<-DESC
      The SHIP_CONFIG uses the yaml format defined in the ruby urbit-api gem.
      see https://github.com/Zaxonomy/urbit-ruby
    DESC
    method_option :help, aliases: %w[-h --help], type: :boolean, desc: "Display usage information"
    def launch(config)
      if options[:help]
        invoke :help, ["launch"]
      else
        if (config)
          require_relative "mission_control"
          begin
            cc = MarsBase10::MissionControl.new config_filename: config
            cc.activate
          ensure
            cc.shutdown
          end
        else
         raise Error, "A SHIP_CONFIG is required to launch."
        end
      end
    end


    desc "version, --version, -v", "print the version number, then exit"
    map %w[-v --version] => :version
    def version
      require_relative "version"
      puts "v#{MarsBase10::VERSION}"
    end
  end
end