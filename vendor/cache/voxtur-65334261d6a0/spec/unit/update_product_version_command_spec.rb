require 'spec_helper'

require 'voxtur/update_product_version_command'

describe Voxtur::UpdateProductVersionCommand do
  let(:example_product_dir) { new_example_product_dir! }
  let(:product_version) { '0.0.1-alpha.1' }

  describe 'erroneous input handling' do
    context 'when the product directory does not exist' do
      it 'raises an appropriate error' do
        command = Voxtur::UpdateProductVersionCommand.new('invalid dir', product_version)
        expect { command.execute! }.to raise_error('product directory not found')
      end
    end

    context 'when binaries.yaml not found' do
      let(:example_product_dir) { new_example_product_dir! }

      before do
        FileUtils.rm_rf(File.join(example_product_dir, 'metadata_parts/binaries.yml'))
      end

      it 'raises an appropriate error' do
        command = Voxtur::UpdateProductVersionCommand.new(example_product_dir, product_version)
        expect { command.execute! }.to raise_error('binaries.yml not found')
      end
    end
  end

  context 'when all is well in the world' do
    it 'does not raise any error' do
      command = Voxtur::UpdateProductVersionCommand.new(example_product_dir, product_version)
      expect { command.execute! }.not_to raise_error
    end

    it 'does updates the product version' do
      command = Voxtur::UpdateProductVersionCommand.new(example_product_dir, product_version)

      command.execute!

      binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
      binaries = YAML.load(File.read(binaries_path))
      expect(binaries['product_version']).to eql(product_version)
    end
  end
end
