require 'spec_helper'

include Ripe::DSL # required by dirty hack +WorkerController#prepare+

require 'digest'
require 'fileutils'
require 'tempfile'

def signature(file)
  Digest::MD5.hexdigest(File.read(file).gsub(/LOG=.*\n/, '').gsub(/exec 1>".*\n/, '') )
end

describe WorkerController do
  context 'when RIPELIB contains the test library' do
    before :all do
      @test = TestPack.new

      @oldwd  = Dir.pwd
      @tmpdir = Dir.mktmpdir 'ripe'
      Dir.chdir(@tmpdir)

      ENV['RIPELIB'] = @test.lib_path
      @repo = Repo.new
      @repo.attach_or_create
      @library = Library
      @test.samples.each do |sample|
        FileUtils.mkdir_p(sample)
        @test.steps.each do |step|
          source = "#{@test.path}/#{sample}/#{step}"
          dest = "#{sample}/#{step}"
          FileUtils.cp(source, dest)
        end
      end
    end

    after :all do
      FileUtils.rm_r("#{@tmpdir}")
      Dir.chdir(@oldwd)
    end

    describe '#prepare' do
      it 'prepares workers' do
        workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers
        # Prepares workers 1-2-3
        expect(workers.length).to eql 3
      end

      it 'prepares workers with accurate task scripts' do
        workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers

        workers.map { |a| a.tasks }.inject(&:+).each do |task|
          test_hash = signature(task.sh)
          ref_hash = signature("#{@test.path}/#{task.sh}")
          expect(test_hash).to eql ref_hash
        end
      end

      it 'properly prepares workers in force mode' do
        workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers
        workers += WorkerController.new('foobar', [@test.samples[0]], '.ripe/workers', pwd: @test.path, mode: :force).workers

        ref_tasks = workers[0].tasks
        test_tasks = workers[3].tasks

        expect(ref_tasks.length).to eql 3
        expect(test_tasks.length).to eql 3

        ref_tasks.zip(test_tasks).map do |ref, test|
          ref_hash = signature(ref.sh)
          test_hash = signature(test.sh)
          expect(test_hash).to eql ref_hash
        end
      end

      it 'properly prepares workers in patch mode' do
        sample = @test.samples[0]
        step = @test.steps[1]

        workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers

        # Delete the first output
        FileUtils.rm_r("#{sample}/#{step}")

        workers += WorkerController.new('foobar', [sample], '.ripe/workers', pwd: @test.path, mode: :patch).workers

        ref_tasks = workers[0].tasks
        test_tasks = workers[3].tasks

        expect(ref_tasks.length).to eql 3
        expect(test_tasks.length).to eql 1

        ref_hash = signature(ref_tasks.first.sh)
        test_hash = signature(test_tasks.first.sh)

        expect(test_hash).to eql ref_hash
      end

      it 'properly prepares workers in depend mode' do
        sample = @test.samples[1]
        step = @test.steps[1]

        workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers

        # Delete the first output
        FileUtils.rm_r("#{sample}/#{step}")

        workers += WorkerController.new('foobar', [sample], '.ripe/workers', pwd: @test.path, mode: :depend).workers

        ref_tasks = workers[1].tasks
        test_tasks = workers[3].tasks

        expect(ref_tasks.length).to eql 3
        expect(test_tasks.length).to eql 3

        ref_tasks.zip(test_tasks).map do |ref, test|
          ref_hash = signature(ref.sh)
          test_hash = signature(test.sh)
          expect(test_hash).to eql ref_hash
        end
      end

      describe '#local' do
        it 'runs worker jobs locally' do
          workers = WorkerController.new('foobar', @test.samples, '.ripe/workers', pwd: @test.path, mode: :force).workers
          worker = workers[0]
          `bash #{worker.sh}`
          @test.steps.map do |step|
            test_hash = signature("#{@test.samples[0]}/#{step}")
            ref_hash = signature("#{@test.path}/#{@test.samples[0]}/#{step}")
            expect(test_hash).to eql ref_hash
          end
        end
      end

    end
  end
end
