require 'json'

module Ripe

  class CLI

    ##
    # This class defines helper methods for +Ripe::CLI+.
    #
    # @see Ripe::CLI

    class Helper

      ##
      # Parses a string representing a hash in the format of +a=1,b=2,c=3+ into a
      # hash in the format of +{a: 1, b: 2, c: 3}+.
      #
      # @param options [String] a hash in the format of +a=1,b=2,c=3+
      # @return [Hash] a hash in the format of +{a: 1, b: 2, c: 3}+

      def self.parse_cli_opts(options)
        params = options.split(/,/).map do |pair|
          key, value = pair.split(/=/)
          { key.to_sym => value }
        end
        params.inject(&:merge) || {}
      end

      ##
      # Read and parse a json configuration file into a symbolized hash with
      # the content of that file.
      #
      # @param filename [String] name of a configuration file in json format
      # @return [Hash] a symbolized hash of the content of the json file, or
      # nothing if the file was not found or ill defined.

      def self.parse_config(filename)
        begin
          file = File.read(filename)
          begin
            JSON.parse(file, :symbolize_names => true)
          rescue
            abort "Configuration file found but ill defined: #{filename}"
          end
        rescue
          abort "Configuration file specified but not found: #{filename}"
        end
      end


      ##
      # Print available options for workflow files 
      # @param workflow [String] name of a the workflow
      # @return nothing only prints to standard output
    def self.print_options(workflow)
        puts ""
        puts "Available options for workflow : " + workflow
        puts "-------------------------------------"
        w = WorkerController.new(workflow, [], '')
        s = ""
        w.params.each{|key, value|
          if !['wd', 'group_num', 'handle'].include?("#{key}")
            s += "#{key}, "
          end
          }
        puts s.chop.chop
        puts ""
      end

    end

  end

end
