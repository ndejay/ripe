require 'spec_helper'

describe CLI::Helper do
  describe '::Helper#parse_cli_opts' do
    it 'parses string options into hash options' do 
      string_opts = 'a=1,b=2,c=3'
      test_hash_opts = CLI::Helper.parse_cli_opts(string_opts)

      ref_hash_opts = {a: '1', b: '2', c: '3'}

      expect(test_hash_opts).to eql ref_hash_opts
    end
  end

  describe '::Helper#parse_config' do
    it 'parses json file info symbolized hash' do
      file = Tempfile.new("json")
      begin
        file.write("{\"a\": 1, \"b\": 2, \"c\": \"bob\"}")
        file.rewind
        test_hash_config = CLI::Helper.parse_config(file.path)
        ref_hash_config = {:a=>1, :b=>2, :c=>"bob"}
        expect(test_hash_config).to eql ref_hash_config
      ensure
        file.close
      end

    end
  end
end
