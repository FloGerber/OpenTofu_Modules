Terraspace.configure do |config|
  config.logger.level = :info
  config.test_framework = "rspec"
  config.allow.envs = ["development", "staging", "production"]
  config.build.cache_dir = ":CACHE_ROOT/:ENV/:BUILD_DIR"
end
