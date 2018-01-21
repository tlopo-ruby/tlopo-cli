require 'tlopo/cli/version'
require 'yaml'
require 'optparse'

module Tlopo
  # A library to speedup CLI apps development
  class Cli
    def initialize(opts = {})
      msg = 'Either config or config_file must be specified'
      raise msg unless opts[:config_file] || opts[:config]
      raise msg if opts[:config_file] && opts[:config]
      @cfg = YAML.safe_load(File.read(opts[:config_file])) if opts[:config_file]
      @cfg = opts[:config] if opts[:config]
      @globals = @cfg[:globals]
      @cfg.delete(:globals)
    end

    def run
      validate_recursive
      parse_recursive(@cfg, {})
    end

    private

    def validate_recursive(obj = @cfg)
      validate_command(obj)
      obj['switches'].each { |sw| validate_switch(sw) } if obj['switches']
      obj['subcommands'].each { |sub| validate_recursive(sub) } if obj['subcommands']
    end

    def parse_options(obj, result, key)
      return nil if obj.nil?
      result[key] = {} unless result[key]
      result[key]['class'] = obj['class']
      OptionParser.new do |opts|
        opts.banner = obj['banner']
        if obj['switches']
          obj['switches'].each do |sw|
            short = sw['short']
            long = sw['long']
            desc = sw['desc']
            opts.on(short, long, desc) { |v| result[key][sw['name']] = v }
          end
        end
      end
    end

    def parse_recursive(obj, result, stack = [])
      stack << obj['name']
      key = stack.join('::')
      _p = parse_options(obj, result, key)
      _p.order! unless _p.nil?
      subcommand = ARGV.shift
      return invoke_class_run(result, key) if subcommand.nil?
      command = obj['subcommands'].find { |e| e['name'] == subcommand } if obj['subcommands']
      raise "Unknown subcommand '#{subcommand}' for [ #{stack.join(' -> ')} ]" unless command
      parse_recursive(command, result, stack)
    end

    def invoke_class_run(result, key)
      _class = result[key]['class']
      opts = result[key]
      opts.delete('class')
      result.delete(key)
      opts['_globals'] = result if @globals
      Object.const_get(_class).run(opts)
    end

    def validate_command(command)
      required = %w[name banner class]
      optional = %w[switches subcommands]
      required.each do |e|
        raise "Field '#{e}' is required. received: [#{command.inspect}]" unless command[e]
      end
      known = required + optional
      command.each_key do |k|
        raise "Unknown field '#{k}', known values #{known.inspect}" unless known.include?(k)
      end
      begin
        Object.const_get(command['class'])
      rescue NameError
        raise "Can't find class #{command['class']}, make sure it's loaded."
      end
    end

    def validate_switch(switch)
      required = %w[name long desc]
      optional = ['short']
      required.each do |e|
        raise "Field '#{e}' is required. received: [#{switch.inspect}]" unless switch[e]
      end
      known = required + optional
      switch.each_key do |k|
        raise "Unknown field '#{k}', known values #{known.inspect}" unless known.include?(k)
      end
    end
  end
end
