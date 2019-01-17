require 'thor'

include Ripe
include Ripe::DSL

module Ripe

  ##
  # This class represents the CLI interface to ripe.

  class CLI < Thor

    desc 'prepare SAMPLES', 'Prepare jobs from template workflow'
    # Mandatory parameters
    option :workflow, :aliases => '-w', :type => :string, :required => true,
      :desc => 'Workflow to be applied'
    option :output_prefix, :aliases => '-x', :type => :string, :required => true,
      :desc => 'Output prefix', :default => '.ripe/'
   # Optional parameters
    option :config, :aliases => '-c', :type => :string, :required => false,
      :desc => 'Config file for workflows'
    option :options, :aliases => '-o', :type => :string, :required => false,
      :desc => 'Available options in the format opt1=value1,opt2=value2', :default => ''
    option :list_options, :aliases => '-l', :type => :boolean, :required => false,
      :desc => 'List workflow available options', :default => false
    ##
    # Prepare samples.
    #
    # @see Ripe::WorkerController
    def prepare(*samples)

      if options[:list_options]
        Helper.print_options(options[:workflow])
        return
      end
      
      abort 'No samples specified.' if samples.length == 0

      config = options[:config] ? Helper.parse_config(options[:config]) : {}
      workflow_options = config[options[:workflow].to_sym] ||= {}
      workflow_options.merge!(Helper.parse_cli_opts(options[:options]))

      WorkerController.new(options[:workflow], samples, options[:output_prefix], workflow_options)
    end

    ##
    # Retrieve ripe version.

    desc 'version', 'Retrieve ripe version'
    def version
      puts "ripe version #{Ripe::VERSION}"
    end

    ##
    # List available workflows
    desc 'list', 'List available workflows'
    def list
      puts Library.list_workflows
    end

  end

end

require_relative 'cli/helper.rb'
