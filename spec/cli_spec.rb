require 'spec_helper'

describe CLI do
  describe '::Helper#parse_cli_opts' do
    it 'parses string options into hash options' do 
      string_opts = 'a=1,b=2,c=3'
      test_hash_opts = CLI::Helper.parse_cli_opts(string_opts)

      ref_hash_opts = {a: '1', b: '2', c: '3'}

      expect(test_hash_opts).to eql ref_hash_opts
    end
  end
end
