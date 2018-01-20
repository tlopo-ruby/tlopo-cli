require 'test_helper'

# It must load config from file
# It must load config from object
# It must bomb validating all fields of command
# It must bomb validating all fields of switches
# It must create _globals
# It must create at least 5 subcommands

module Tlopo
  class CliTest < Minitest::Test
    @@command_cfg = {
        'name' => 'command',
        'class' => 'Tlopo::Command',
        'banner' => 'Banner goes here',
        'switches' => [
          {
            'name' => 'filename',
            'short' => '-F',
            'long' => '--filename <filename>',
            'desc' => 'Sets filename'
          }
        ]
    }

    def test_that_it_has_a_version_number
      refute_nil(::Tlopo::Cli::VERSION)
    end

    def test_that_it_loads_config_from_file
      assert false
    end

    def test_that_it_loads_config_from_object
      filename = '/etc/hosts'
      Tlopo::Command.opt 'filename'
      out, err = capture_io do 
        ARGV.replace ['-F', filename ]
        Tlopo::Cli.new( config: @@command_cfg ).run
      end
      assert_equal(filename, out.strip)
    end
  end

  class Command
    def self.opt (value=nil)
      @@value = value unless value.nil?
      return @@value
    end 

    def self.run(opts)
      puts opts[@@value]
    end
  end
end
