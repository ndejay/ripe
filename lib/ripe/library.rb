module Ripe

  ##
  # This class represents a library containing all the components accessible
  # to ripe (tasks and workflows) based on what is contained in the +RIPELIB+
  # environment variable.

  class Library

    attr_reader :paths

    ##
    # Creates a new library spanning all paths in the +RIPELIB+ environment
    # variable.

    def initialize
      # Prepends the working directory to the list of paths so that the
      # working directory is always looked in first.

      @paths = "#{Dir.pwd}/#{Repo::REPOSITORY_PATH}:#{ENV['RIPELIB']}".split(/:/)
    end

    ##
    # Search throughout the library for a task component by the name of
    # +handle+.  When there is more than one match, give precendence to the
    # component whose path is declared first.
    #
    # Return the full path of the component if found, and +nil+ otherwise.

    def find_task(handle)
      search = @paths.map do |path|
        filename = "#{path}/tasks/#{handle}.sh"
        (File.exists? filename) ? filename : nil
      end

      search.compact.first
    end

    ##
    # Search throughout the library for a workflow component by the name of
    # +handle+.  When there is more than one match, give precendence to
    # component whose path is declared first.
    #
    # Return the full path of the component if found, and +nil+ otherwise.

    def find_workflow(handle)
      search = @paths.map do |path|
        filename = "#{path}/workflows/#{handle}.rb"
        (File.exists? filename) ? filename : nil
      end

      search.compact.first
    end

  end

end
