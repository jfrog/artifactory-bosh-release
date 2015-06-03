require 'voxtur/metadata_updater'

module Voxtur
  class UpdateProductVersionCommand
    def initialize(product_dir, product_version)
      @product_dir = product_dir
      @product_version = product_version
    end

    def execute!
      fail 'product directory not found' unless File.exist?(product_dir)
      fail 'binaries.yml not found' unless File.exist?(File.join(product_dir, 'metadata_parts/binaries.yml'))

      MetadataUpdater.new.update_product_version!(product_dir, product_version)
    end

    private

    attr_reader :product_dir, :product_version
  end
end
