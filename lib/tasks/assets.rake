namespace :assets do
  namespace :yarn do
    task :install do
      sh 'yarn install --modules-folder vendor/assets/components/'
    end
  end
end
