# == Define: dns::record::aaaa
#
# Wrapper of dns::record to set AAAA records
#
define dns::record::aaaa (
  $zone,
  $data,
  $ttl = '',
  $host = $name,
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
    $alias = "${name},AAAA,${zone}"
    dns::record { $alias:
      zone     => $zone,
      host     => $host,
      ttl      => $ttl,
      record   => 'AAAA',
      data     => $data,
      data_dir => $data_dir,
    }
  }
}
