require 'spec_helper'

require 'voxtur/command'

describe Voxtur::Command do
  let(:example_product_dir) { new_example_product_dir! }
  let(:s3_path) { "foo/bar" }
  let(:release_info) do
    {
      'name' => 'cf-example',
      'file' => 'cf-example-344.tgz',
      'version' => '344',
      'md5' => 'd41d8cd98f00b204e9800998ecf8427e',
      'url' => "https://s3.amazonaws.com/#{s3_path}/cf-example-344.tgz"
    }
  end

  describe 'erroneous input handling' do
    context 'when the release tarball does not exist' do
      it 'raises an appropriate error' do
        command = Voxtur::Command.new('no_a_real_file', 'whatever', s3_path)
        expect { command.execute! }.to raise_error('release tarball not found')
      end
    end

    context 'when the product directory does not exist' do
      it 'raises an appropriate error' do
        command = Voxtur::Command.new(example_release_tgz, 'whatever', s3_path)
        expect { command.execute! }.to raise_error('product directory not found')
      end
    end

    context 'when binaries.yaml not found' do

      let(:example_product_dir) { new_example_product_dir! }

      before do
        FileUtils.rm_rf(File.join(example_product_dir, 'metadata_parts/binaries.yml'))
      end

      it 'raises an appropriate error' do
        command = Voxtur::Command.new(example_release_tgz, example_product_dir, s3_path)
        expect { command.execute! }.to raise_error('binaries.yml not found')
      end
    end
  end

  context 'when all is well in the world' do
    it 'does not raise any error' do
      command = Voxtur::Command.new(example_release_tgz, example_product_dir, s3_path)
      expect { command.execute! }.not_to raise_error
    end

    it 'does updates the product release info' do
      command = Voxtur::Command.new(example_release_tgz, example_product_dir, s3_path)

      command.execute!

      binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
      binaries = YAML.load(File.read(binaries_path))
      first_release = binaries['releases'].first
      expect(first_release).to eql(release_info)
    end
  end
end
