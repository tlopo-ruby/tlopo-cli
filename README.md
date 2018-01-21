# tlopo-cli
[![Gem Version](https://badge.fury.io/rb/tlopo-cli.svg)](http://badge.fury.io/rb/tlopo-cli)
[![Build Status](https://travis-ci.org/tlopo-ruby/tlopo-cli.svg?branch=master)](https://travis-ci.org/tlopo-ruby/tlopo-cli)
[![Code Climate](https://codeclimate.com/github/tlopo-ruby/tlopo-cli/badges/gpa.svg)](https://codeclimate.com/github/tlopo-ruby/tlopo-cli)
[![Dependency Status](https://gemnasium.com/tlopo-ruby/tlopo-cli.svg)](https://gemnasium.com/tlopo-ruby/tlopo-cli)
[![Coverage Status](https://coveralls.io/repos/github/tlopo-ruby/tlopo-cli/badge.svg?branch=master)](https://coveralls.io/github/tlopo-ruby/tlopo-cli?branch=master)

A Library to speed up CLI apps development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tlopo-cli'
```

And then execute:

```Bash
bundle
```

Or install it yourself as:

```Bash
gem install tlopo-cli
```

## Usage

Simple usage: 
```ruby
require 'tlopo/cli'

class Command
  def self.run(opts)
    puts opts
  end
end

cfg = {
  'name' =>  'command',
  'banner' => "My ClI\n    Run my-cli with ARGS\nOPTIONS:\n",
  'class' => 'Command',
  'switches' => [{
    'name' => 'filename',
    'short' => '-f',
    'long' => '--filename <Filename>',
    'desc' => 'Sets filename'
  }]
}

Tlopo::Cli.new(config: cfg).run 
```
In action: 
```bash
$ ruby /tmp/my-cli.rb --help
My ClI
    Run my-cli with ARGS
OPTIONS:
    -f, --filename <Filename>        Sets filename
$ ruby /tmp/my-cli.rb  -f /etc/hosts
{"filename"=>"/etc/hosts"}
```

You can have as many subcommands as you want, options will be parsed.
```ruby
require 'tlopo/cli'

class Command
  def self.run(opts)
    puts opts
  end
end

class SubCommand1
  def self.run(opts)
    puts opts
  end
end

class SubCommand2
  def self.run(opts)
    puts opts
  end
end

cfg = {
  :globals => true, # This will include the options for each 'parent' command
  :usage => true, # This will add _usage in opts commands/subcommands can print it  if needed
  'name' =>  'command',
  'banner' => "command\nOPTIONS:\n",
  'class' => 'Command',
  'switches' => [{ 'name' => 'arg1', 'short' => '-a', 'long' => '--arg1 <arg1>', 'desc' => 'Sets arg1'}],
  'subcommands' => [
    { 
      'name' =>  'subcommand1',
      'banner' => "Subcommand1\nOPTIONS:\n",
      'class' => 'SubCommand1',
      'switches' => [{ 'name' => 'arg1', 'short' => '-a', 'long' => '--arg1 <arg1>', 'desc' => 'Sets subcommand1 arg1'} ],
      'subcommands' => [
        { 
          'name' =>  'subcommand2',
          'banner' => "Subcommand2\nOPTIONS:\n",
          'class' => 'SubCommand2',
          'switches' => [{ 'name' => 'arg1', 'short' => '-a', 'long' => '--arg1 <arg1>', 'desc' => 'Sets subcommand2 arg1'}]
        }
      ]
    }
  ]
}

Tlopo::Cli.new(config: cfg).run 
```
In action: 
```bash
$ ruby /tmp/my-cli.rb -a 1  subcommand1 -a 2  subcommand2 -a 3
{"arg1"=>"3", "_globals"=>{"command"=>{"class"=>"Command", "arg1"=>"1"}, "command::subcommand1"=>{"class"=>"SubCommand1", "arg1"=>"2"}}}
```




The configuration can also be a yaml or json file: 

```ruby
Tlopo::Cli.new(config_file: './cli-config.yml')
```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/kubeclient/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test your changes with `rake test rubocop`, add new tests if needed.
4. If you added a new functionality, add it to README
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

## Tests

This library is tested with Minitest.
Please run all tests before submitting a Pull Request, and add new tests for new functionality.

Running tests:
```ruby
rake test
```
