module Ripe

  class WorkerController

    ##
    # This class controls worker preparation from a given workflow, list of
    # samples and parameters.  It applies the workflow to each of the specified
    # samples.
    #
    # @attr workers [Array<Worker>] workers prepared in current batch
    #
    # @see Ripe::DSL::WorkflowDSL#describe
    # @see Ripe::WorkerController#prepare

    class Preparer

      attr_accessor :workers

      ##
      # Prepare workers by applying the workflow callback and its parameters to
      # each sample.
      #
      # @param workflow [String] the name of a workflow to apply on the sample
      #   list
      # @param samples [Array<String>] list of samples to apply the callback to
      # @param params [Hash<Symbol, String>] a list of worker-wide parameters

      def initialize(workflow, samples, params = {})
        # Extract callback and params from input
        callback, params = load_workflow(workflow, params)

        if ![:patch, :force, :depend].include?(params[:mode].to_sym)
          abort "Invalid mode #{params[:mode]}."
        end

        # Apply the workflow to each sample
        sample_blocks = prepare_sample_blocks(samples, callback, params)

        if sample_blocks
          # Split samples into groups of +:group_num+ samples and produce a
          # worker from each of these groups.
          @workers = sample_blocks.each_slice(params[:group_num].to_i).map do |worker_blocks|
            prepare_worker(worker_blocks, params)
          end
        else
          []
        end
      end

      ##
      # Load a workflow and return its +callback+ and +params+ components.
      #
      # @param workflow [String] the name of a workflow
      # @param params [Hash<Symbol, String>] a list of worker-wide parameters
      # @return [Proc, Hash<Symbol, String>] a list containing the workflow callback
      #   and default params

      def load_workflow(workflow, params)
        filename = Library.find(:workflow, "#{workflow}.rb")
        abort "Could not find workflow #{workflow}." if filename == nil
        require_relative filename

        # Imports +$workflow+ from the workflow component.  This is a dirty
        # hack to help make the +DSL::WorkflowDSL+ more convenient for the
        # end user.

        params = {
          wd:        Dir.pwd,
          mode:      :patch,
          group_num: 1,
        }.merge($workflow.params.merge(params))

        [$workflow.callback, params]
      end

      ##
      # Apply the workflow (callback) to each sample, producing a single root
      # block per sample.
      #
      # @param samples [Array<String>] a list of samples
      # @param callback [Proc] workflow callback to be applied to each sample
      # @param params [Hash] a list of worker-wide parameters
      # @return [Hash] a +{sample => block}+ hash

      def prepare_sample_blocks(samples, callback, params)
        sample_blocks = samples.map do |sample|
          block = callback.call(sample, params)

          if block
            # No need to prune if callback returns nil
            block = block.prune(params[:mode].to_sym == :force,
                              params[:mode].to_sym == :depend)
          end

          if block != nil
            puts "Preparing sample #{sample}"
            {sample => block}
          else
            puts "Nothing to do for sample #{sample}"
            nil
          end
        end

        # Produce a {sample => block} hash
        sample_blocks.compact.inject(&:merge)
      end

      ##
      # Prepare a worker from a group of sample blocks.
      #
      # @param worker_sample_blocks [Hash] a list containing as many elements
      #   as there are samples in the group, with each element containing
      #   +[String, Blocks::Block]+
      # @param params [Hash] worker-level parameter list
      # @return [DB::Worker] worker

      def prepare_worker(worker_sample_blocks, params)
        worker = DB::Worker.create(handle: params[:handle])
        worker_blocks = prepare_worker_blocks(worker_sample_blocks, worker)

        # Combine all grouped sample blocks into a single worker block

        params = params.merge({
          name:    worker.id,
          stdout:  worker.stdout,
          stderr:  worker.stderr,
          command: Blocks::SerialBlock.new(*worker_blocks).command,
        })

        worker_block = Blocks::LiquidBlock.new("#{PATH}/share/moab.sh", params)
        File.open(worker.sh, 'w') { |f| f.write(worker_block.command) }

        worker.update({
          status:       :prepared,
          ppn:          params[:ppn],
          queue:        params[:queue],
          walltime:     params[:walltime],
          user:         `whoami`.chomp,
          project_name: params[:project_name],
        })

        worker
      end

      ##
      # Organize worker blocks into tasks and prepare them.
      #
      # @param worker_sample_blocks [Array<Hash<String, Blocks::Block>>] a list
      # containing as many elements as there are samples in the group
      # @param worker [DB::Worker] worker
      # @return [Array<Blocks::Block>] a list of all the prepared blocks for a
      #   worker

      def prepare_worker_blocks(worker_sample_blocks, worker)
        worker_sample_blocks.map do |sample, block|
          # Preorder traversal of blocks -- assign incremental numbers starting from
          # 1 to each node as it is being traversed, as well as producing the job
          # file for each task.
          post_var_assign = lambda do |subblock|
            if subblock.blocks.length == 0
              # This section is only called when the subblock is actually a working
              # block (a leaf in the block arborescence).
              task = worker.tasks.create({
                sample: sample,
                block:  subblock.id,
              })

              subblock.vars.merge!(log: task.log)
              File.open(task.sh, 'w') { |f| f.write(subblock.command) }
              subblock.vars
            else
              subblock.blocks.each(&post_var_assign)
            end
          end

          post_var_assign.call(block)
          block
        end
      end

    end

  end

end
