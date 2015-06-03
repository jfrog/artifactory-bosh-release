require 'yaml'

module Voxtur
  class MetadataUpdater
    def update_release_info!(product_dir, release, s3_path)
      release['url'] = File.join("https://s3.amazonaws.com", s3_path, release['file']) if s3_path

      update_node(product_dir, 'releases', [release])
    end

    def update_product_version!(product_dir, product_version)
      update_node(product_dir, 'product_version', product_version)
    end

    private

    def update_node(product_dir, node_name, node_value)
      binaries_file_path = File.join(product_dir, 'metadata_parts/binaries.yml')
      metadata = YAML.load(File.read(binaries_file_path))

      metadata[node_name] = node_value

      File.write(binaries_file_path, metadata.to_yaml)
    end
  end
end
