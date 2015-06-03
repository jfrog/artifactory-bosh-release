require 'spec_helper'

require 'yaml'

require 'voxtur/metadata_updater'

describe Voxtur::MetadataUpdater do
  let(:example_product_dir) { new_example_product_dir! }
  let(:s3_path) { 'foo/bar' }
  let(:release_info) do
    {
      'name' => 'i_be_name',
      'file' => 'i_be_file',
      'version' => '9',
      'md5' => 'superlongunreadablestring'
    }
  end

  let(:release_info_with_url) do
    release_info.merge('url' => "https://s3.amazonaws.com/#{s3_path}/i_be_file")
  end

  context '#update_release_info!' do
    context 'when an s3 path is provided' do
      it 'updates the metadata_parts/binaries.yml file with the correct info' do
        subject.update_release_info!(example_product_dir, release_info, s3_path)

        binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
        binaries = YAML.load(File.read(binaries_path))
        first_release = binaries['releases'].first
        expect(first_release).to eql(release_info_with_url)
      end
    end

    context 'when an s3 path is not provided' do
      it 'updates the metadata_parts/binaries.yml file with the correct info' do
        subject.update_release_info!(example_product_dir, release_info, nil)

        binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
        binaries = YAML.load(File.read(binaries_path))
        first_release = binaries['releases'].first
        expect(first_release).to eql(release_info)
      end
    end

    it 'does not delete other parts of the metadata_parts/binaries.yml file' do
      subject.update_release_info!(example_product_dir, release_info, s3_path)

      binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
      binaries = YAML.load(File.read(binaries_path))
      %w(
        name
        product_version
        metadata_version
        stemcell
        releases
        provides_product_versions
      ).each do |key|
        expect(binaries.keys).to include(key)
      end
    end
  end

  context '#update_version!' do
    it 'updates the metadata_parts/binaries.yml with the correct product_version' do
      version_to_be_updated = '0.1.0-alpha.1'

      subject.update_product_version!(example_product_dir, version_to_be_updated)

      binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
      binaries = YAML.load(File.read(binaries_path))
      expect(binaries['product_version']).to eql(version_to_be_updated)
    end

    it 'does not delete other parts of the metadata_parts/binaries.yml file' do
      subject.update_product_version!(example_product_dir, 'whatever')

      binaries_path = File.join(example_product_dir, 'metadata_parts/binaries.yml')
      binaries = YAML.load(File.read(binaries_path))
      %w(
        name
        product_version
        metadata_version
        stemcell
        releases
        provides_product_versions
      ).each do |key|
        expect(binaries.keys).to include(key)
      end
    end
  end
end
