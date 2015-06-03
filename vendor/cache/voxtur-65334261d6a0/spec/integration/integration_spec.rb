require 'spec_helper'

require 'yaml'

require 'voxtur/command'

describe 'voxtur' do

  let(:example_product_dir) { new_example_product_dir! }
  let(:binaries_path) { File.join(example_product_dir, 'metadata_parts/binaries.yml') }
  let(:s3_path) { 'some-bucket-name/some-dir' }

  it 'updates the release info' do
    expected_binaries = modify_binaries_as_expected(load_yaml(binaries_path))

    `bin/voxtur #{example_release_tgz} #{example_product_dir} #{s3_path}`

    resulting_binaries = load_yaml(binaries_path)

    expect(resulting_binaries).to eq(expected_binaries)
  end

  it 'updates the product version' do
    product_version = '0.1.0-alpha.1'

    `bin/voxtur_utgafa #{example_product_dir} #{product_version}`

    metadata = load_yaml(binaries_path)

    expect(metadata['product_version']).to eq(product_version)
  end

  def load_yaml(path)
    YAML.load(File.read(path))
  end

  def modify_binaries_as_expected(binaries)
    binaries['releases'].first['name'] = 'cf-example'
    binaries['releases'].first['file'] = 'cf-example-344.tgz'
    binaries['releases'].first['version'] = '344'
    binaries['releases'].first['md5'] = 'd41d8cd98f00b204e9800998ecf8427e'
    binaries['releases'].first['url'] = "https://s3.amazonaws.com/#{s3_path}/cf-example-344.tgz"
    binaries
  end
end
