require 'spec_helper'

include Ripe::DSL

require 'digest'
require 'fileutils'

def signature(file)
  Digest::MD5.hexdigest(File.read(file))
end

describe WorkerController do
  context 'when RIPELIB contains the test library' do
    before :all do
      @test = TestPack.new

      @tmpdir = Dir.mktmpdir 'ripe'
      Dir.chdir(@tmpdir)

      ENV['RIPELIB'] = @test.lib_path
      @repo = Repo.new
      @repo.attach_or_create
      @library = Library
      @controller = @repo.controller

      @test.samples.each do |sample|
        FileUtils.mkdir_p(sample)
        FileUtils.cp("#{@test.path}/#{sample}/#{@test.steps.first}",
          "#{sample}/#{@test.steps.first}")
      end
    end

    after :all do
      FileUtils.rm_r("#{@tmpdir}")
    end

    describe '#prepare' do
      it 'prepares workers' do
        @controller.prepare 'foobar', @test.samples, pwd: @test.path
        expect(Worker.all.length).to eql 3
      end

      it 'prepares workers with accurate task scripts' do
        Task.all.each do |task|
          expect(signature(task.sh)).to eql signature("#{@test.path}/#{task.sh}")
        end
      end
    end
  end
end
