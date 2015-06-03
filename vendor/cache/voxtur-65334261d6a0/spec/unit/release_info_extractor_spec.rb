require 'spec_helper'

require 'voxtur/release_info_extractor'

describe Voxtur::ReleaseInfoExtractor do
  let(:expected_info) do
    {
      'name' => 'cf-example',
      'file' => 'cf-example-344.tgz',
      'version' => '344',
      'md5' => 'd41d8cd98f00b204e9800998ecf8427e'
    }
  end

  it 'extracts the correct info' do
    info = Voxtur::ReleaseInfoExtractor.new.extract_info(example_release_tgz)
    expect(info).to eql(expected_info)
  end

  it 'extracts the correct info when version contains periods' do
    example_release_with_periods = File.expand_path('spec/support/cf-example-1.2.3.4.tgz')
    expected_info_with_periods = expected_info.merge(
      {
        'file' => 'cf-example-1.2.3.4.tgz',
        'version' => '1.2.3.4'
      }
    )
    info = Voxtur::ReleaseInfoExtractor.new.extract_info(example_release_with_periods)
    expect(info).to eql(expected_info_with_periods)
  end
end
