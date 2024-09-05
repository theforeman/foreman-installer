# forwarders was always an array, but previously it was documented as
# --foreman-proxy-dns-forwarders "192.0.2.1; 192.0.2.2"
fp_mod = answers['foreman_proxy']
if fp_mod.is_a?(Hash) && fp_mod['dns_forwarders']
  fp_mod['dns_forwarders'] = fp_mod['dns_forwarders'].flat_map do |forwarder|
    forwarder.split(';').map(&:strip)
  end
end
