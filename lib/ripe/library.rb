require_relative 'repo'

module Ripe

  ##
  # This singleton class represents a library containing all the components
  # accessible to ripe (tasks and workflows) based on what is contained in the
  # +RIPELIB+ environment variable.

  module Library

    class << self

      ##
      # Provide a list of search paths
      #
      # @return [List] Return the list of search paths

      def paths
        # Prepend the working directory to the list of paths so that the
        # working directory is always looked in first.
        "#{Dir.pwd}/#{Repo::REPOSITORY_PATH}:#{ENV['RIPELIB']}".split(/:/)
      end

      ##
      # Search throughout the library for a task component by the name of
      # +handle+.  When there is more than one match, give precendence to the
      # component whose path is declared first.
      #
      # @param handle [String] Task to search for
      # @return [String, nil] Return the full path of the component if found,
      #   and +nil+ otherwise.

      def find_task(handle)
        search = paths.map do |path|
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
      # @param handle [String] Workflow to search for
      # @return [String, nil] Return the full path of the component if found,
      #   and +nil+ otherwise.

      def find_workflow(handle)
        search = paths.map do |path|
          filename = "#{path}/workflows/#{handle}.rb"
          (File.exists? filename) ? filename : nil
        end

        search.compact.first
      end

    end

  end

end
