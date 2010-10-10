%w{ rails }.each do |rails_gem|
  gem_package rails_gem do
    if node[:rails_version]
      action :install
      version node[:rails_version]
    else
      action :install
    end
  end
end
