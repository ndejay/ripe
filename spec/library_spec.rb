require 'spec_helper'

describe Library do
  context 'when RIPELIB env is empty' do
    before :each do
      ENV['RIPELIB'] = ''
      @library = Library
    end

    it 'looks in the working directory' do
      expect(@library.paths).to eql ["#{Dir.pwd}/#{Repo::REPOSITORY_PATH}"]
    end

    it 'cannot resolve components of the test library' do
      expect(@library.find(:task, 'foo.sh')).to eql nil
      expect(@library.find(:task, 'bar.sh')).to eql nil
      expect(@library.find(:workflow, 'foobar.rb')).to eql nil
    end
  end

  context 'when RIPELIB contains the test library' do
    before :each do
      @test = TestPack.new
      ENV['RIPELIB'] = @test.lib_path
      @library = Library
    end

    it 'looks in two directories' do
      expect(@library.paths.length).to eql 2
    end

    it 'looks in the working directory first' do
      # It looks in the working directory, and then in the directory
      # specified in RIPELIB.
      expect(@library.paths[0]).to eql "#{Dir.pwd}/#{Repo::REPOSITORY_PATH}"
      expect(@library.paths[1]).to eql @test.lib_path
    end

    it 'resolves task components of the test library' do
      expect(@library.find(:task, 'foo.sh')).to eql @test.tasks['foo']
      expect(@library.find(:task, 'bar.sh')).to eql @test.tasks['bar']
    end

    it 'resolves workflows components of the test library' do
      expect(@library.find(:workflow, 'foobar.rb')).to eql @test.workflows['foobar']
    end

    it 'cannot resolve non-existing components' do
      expect(@library.find(:task, 'other.sh')).to eql nil
      expect(@library.find(:workflow, 'other.rb')).to eql nil
    end
  end
end
