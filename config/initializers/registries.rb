registries = {
  wallets: Peatio::Wallet.registry,
  blockchains: Peatio::Blockchain.registry,
  upstreams: Peatio::Upstream.registry
}

%w(config/registries.local.yml config/registries.yml).each do |config_file|
  next unless File.exists? config_file
  YAML.load_file(config_file).each_pair do |registry_name, items|
    registry = registries[registry_name.to_sym] || raise("Unknown registry (#{registry_name}) defined in #{config_file}")
    items.each do |item_name, item_class|
      registry[item_name.to_sym] = item_name.classify
    end
  end
  break
end
