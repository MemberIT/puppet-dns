# == Define dns::record::prt
#
# Wrapper for dns::record to set PTRs
#
define dns::record::ptr (
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
    $alias = "${name},PTR,${zone}"
    dns::record { $alias:
      zone     => $zone,
      host     => $host,
      ttl      => $ttl,
      record   => 'PTR',
      data     => "${data}.",
      data_dir => $data_dir,
    }
  }
}
