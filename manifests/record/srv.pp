# == Define dns::server:srv
#
# Wrapper for dns::zone to set SRV records
#
define dns::record::srv (
  $zone,
  $service,
  $pri,
  $weight,
  $port,
  $target,
  $proto = 'tcp',
  $ttl = '',
  $data_dir = $::dns::server::config::data_dir,
) {

  if is_string($zone) {
    $convert_zone = [ $zone ]
  } else {
    if is_array($zone) {
      $convert_zone = unique($zone)
    } else {
      fail("'zone' must be string or array!")
    }
  }

  $convert_zone.each |String $zone| {
    $alias = "${service}:${proto}@${target}:${port},${pri},${weight},SRV,${zone}"
    $host = "_${service}._${proto}.${zone}."
    dns::record { $alias:
      zone     => $zone,
      host     => $host,
      ttl      => $ttl,
      record   => 'SRV',
      data     => "${pri}\t${weight}\t${port}\t${target}",
      data_dir => $data_dir,
    }
  }
}
