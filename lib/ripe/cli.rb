require 'ripl' # REPL
require 'hirb' # Pretty output for +ActiveRecord+ objects
require 'thor'

require_relative '../ripe'

include Ripe
include Ripe::DB
include Ripe::DSL

module Ripe

  ##
  # This class represents the CLI interface to ripe.  The methods defined in
  # this class are wrappers for the methods defined in +Ripe::Repo+ and
  # +Ripe::WorkerController+.
  #
  # @see Ripe::Repo
  # @see Ripe::WorkerController

  class CLI < Thor

    desc 'init', 'Initialize ripe repository'

    ##
    # Initialize ripe repository.
    #
    # @see Ripe::Repo#attach_or_create

    def init
      puts "Initialized ripe repository in #{Dir.pwd}"
      repo = Repo.new
      repo.attach_or_create
    end





    desc 'console', 'Launch ripe console'

    ##
    # Launch ripe console.  It is a REPL bound to the context of a
    # +Ripe::WorkerController+ initialized in the working directory.

    def console
      repo = Repo.new
      repo.attach

      unless repo.has_repository?
        abort "Cannot launch console: ripe repo not initialized"
      end

      # Do not send arguments to the REPL
      ARGV.clear

      Ripl.config[:prompt] = proc do
        # This is the only place I could think of placing +Hirb#enable+.
        Hirb.enable unless Hirb::View.enabled?
        'ripe> '
      end

      # Launch the REPL session in the context of +WorkerController+.
      # Ripl.start :binding => repo.controller.instance_eval { binding }
    end





    desc 'prepare SAMPLES', 'Prepare jobs from template workflow'
    option :workflow, :aliases => '-w', :type => :string, :required => true,
      :desc => 'Workflow to be applied'
    option :config, :aliases => '-c', :type => :string, :required => false,
      :desc => 'Config file for workflows.'
    option :options, :aliases => '-o', :type => :string, :required => false,
      :desc => 'Options', :default => ''
    option :prefix, :aliases => '-p', :type => :string, :required => true,
      :desc => 'Output prefix', :default => 'out_'

    ##
    # Prepare samples.
    #
    # @see Ripe::Repo#controller
    # @see Ripe::WorkerController#prepare

    def prepare(*samples)
      repo = Repo.new
      repo.attach

      unless repo.has_repository?
        abort 'Cannot prepare samples: ripe repo not initialized'
      end

      abort 'No samples specified.' if samples.length == 0

      config = options[:config] ? Helper.parse_config(options[:config]) : {}
      workflow_options = config[options[:workflow].to_sym] ||= {}
      workflow_options.merge!(Helper.parse_cli_opts(options[:options]))

      workers = WorkerController.new(options[:workflow], samples, workflow_options).workers
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
