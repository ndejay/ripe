require 'thor'

require_relative '../ripe'

include Ripe

module Ripe

  ##
  # This class represents the CLI interface to ripe.

  class CLI < Thor

    desc 'prepare SAMPLES', 'Prepare jobs from template workflow'
    option :workflow, :aliases => '-w', :type => :string, :required => true,
      :desc => 'Workflow to be applied'
    option :config, :aliases => '-c', :type => :string, :required => false,
      :desc => 'Config file for workflows'
    option :options, :aliases => '-o', :type => :string, :required => false,
      :desc => 'Options', :default => ''
    option :output_prefix, :aliases => '-p', :type => :string, :required => true,
      :desc => 'Output prefix', :default => '.ripe/workers'

    ##
    # Prepare samples.
    #
    # @see Ripe::WorkerController

    def prepare(*samples)
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

  end

end

require_relative 'cli/helper.rb'
