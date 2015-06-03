require 'voxtur/release_info_extractor'
require 'voxtur/metadata_updater'

module Voxtur
  class Command
    def initialize(release_tarball, product_directory, s3_path)
      @release_tarball = release_tarball
      @product_directory = product_directory
      @s3_path = s3_path
    end

    def execute!
      fail 'release tarball not found' unless File.exist?(release_tarball)
      fail 'product directory not found' unless File.exist?(product_directory)
      fail 'binaries.yml not found' unless File.exist?(File.join(product_directory, 'metadata_parts/binaries.yml'))

      release_info = ReleaseInfoExtractor.new.extract_info(release_tarball)
      MetadataUpdater.new.update_release_info!(product_directory, release_info, s3_path)
    end

    private

    attr_reader :release_tarball, :product_directory, :s3_path
  end
end
