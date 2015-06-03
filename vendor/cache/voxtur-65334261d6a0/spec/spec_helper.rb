require 'tmpdir'

def example_release_tgz
  File.expand_path('spec/support/cf-example-344.tgz')
end

def new_example_product_dir!
  tmpdir = Dir.mktmpdir
  prototype_product_dir = File.expand_path('spec/support/p-example')
  FileUtils.cp_r(prototype_product_dir, tmpdir)
  File.join(tmpdir, 'p-example')
end