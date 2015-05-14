require 'spec_helper'

describe Ripe::Library do
  context 'when RIPELIB env is empty' do
    before(:each) do
      ENV['RIPELIB'] = ''
      @library = Ripe::Library.new
    end

    it 'looks in the working directory' do
      expect(@library.paths).to eql ["#{Dir.pwd}/#{Ripe::Repo::REPOSITORY_PATH}"]
    end

    it 'cannot resolve components of the test library' do
      expect(@library.find_task('foo')).to eql nil
      expect(@library.find_task('bar')).to eql nil
      expect(@library.find_workflow('foobar')).to eql nil
    end
  end

  context 'when RIPELIB contains the test library' do
    before(:each) do
      @test = Ripe::TestPack.new
      ENV['RIPELIB'] = @test.path
      @library = Ripe::Library.new
    end

    it 'looks in two directories' do
      expect(@library.paths.length).to eql 2
    end

    it 'looks in the working directory first' do
      # It looks in the working directory, and then in the directory
      # specified in RIPELIB.
      expect(@library.paths[0]).to eql "#{Dir.pwd}/#{Ripe::Repo::REPOSITORY_PATH}"
      expect(@library.paths[1]).to eql @test.path
    end

    it 'resolves task components of the test library' do
      expect(@library.find_task('foo')).to eql @test.tasks['foo']
      expect(@library.find_task('bar')).to eql @test.tasks['bar']
    end

    it 'resolves workflows components of the test library' do
      expect(@library.find_workflow('foobar')).to eql @test.workflows['foobar']
    end

    it 'cannot resolve non-existing componenets' do
      expect(@library.find_task('other')).to eql nil
      expect(@library.find_workflow('other')).to eql nil
    end
  end
end
