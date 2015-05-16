require 'spec_helper'

include Ripe::DSL # required by dirty hack +WorkerController#prepare+

require 'digest'
require 'fileutils'

def signature(file)
  Digest::MD5.hexdigest(File.read(file))
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
      @controller = @repo.controller

      @test.samples.each do |sample|
        source = "#{@test.path}/#{sample}/#{@test.steps.first}"
        dest = "#{sample}/#{@test.steps.first}"
        FileUtils.mkdir_p(sample)
        FileUtils.cp(source, dest)
      end
    end

    after :all do
      FileUtils.rm_r("#{@tmpdir}")
      Dir.chdir(@oldwd)
    end

    describe '#prepare' do
      it 'prepares workers' do
        @controller.prepare 'foobar', @test.samples, pwd: @test.path
        expect(DB::Worker.all.length).to eql 3
      end

      it 'prepares workers with accurate task scripts' do
        DB::Task.all.each do |task|
          test_hash = signature(task.sh)
          ref_hash = signature("#{@test.path}/#{task.sh}")
          expect(test_hash).to eql ref_hash
        end
      end

      it 'properly prepares workers in force mode' do
        @controller.prepare 'foobar', [@test.samples[0]], pwd: @test.path, mode: :force

        ref_tasks = DB::Worker.find(1).tasks
        test_tasks = DB::Worker.find(4).tasks

        ref_tasks.zip(test_tasks).map do |ref, test|
          ref_hash = signature(ref.sh)
          test_hash = signature(test.sh)
          expect(test_hash).to eql ref_hash
        end
      end
    end

    describe '#local' do
      it 'runs worker jobs locally' do
        worker = DB::Worker.find(1)
        @controller.local worker
        @test.steps.map do |step|
          test_hash = signature("#{@test.samples[0]}/#{step}")
          ref_hash = signature("#{@test.path}/#{@test.samples[0]}/#{step}")
          expect(test_hash).to eql ref_hash
        end
      end
    end
  end
end
