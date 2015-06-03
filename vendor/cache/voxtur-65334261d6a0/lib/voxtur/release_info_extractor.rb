require 'digest/md5'

module Voxtur
  class ReleaseInfoExtractor
    def extract_info(release_tarball_path)
      release_file_name = File.basename(release_tarball_path)
      {
        'name' => release_name(release_file_name),
        'file' => release_file_name,
        'version' => release_version(release_file_name),
        'md5' => md5(release_tarball_path)
      }
    end

    private

    def release_name(release_file_name)
      release_parser_regex.match(release_file_name)[1]
    end

    def release_version(release_file_name)
      release_parser_regex.match(release_file_name)[2]
    end

    def release_parser_regex
      /(.*)-([\d.]+)\.tgz/
    end

    def md5(release_tarball_path)
      # Do it in chunks to avoid using lots of RAMs
      digest = Digest::MD5.new
      File.open(release_tarball_path, 'rb') do |io|
        while (buf = io.read(4096))
          digest.update(buf)
        end
      end
      digest.hexdigest
    end
  end
end
