# == Define dns::record::dname
#
# Wrapper for dns::record to set a CNAME
#
define dns::record::cname (
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
    $alias = "${name},CNAME,${zone}"
    $qualified_data = $data ? {
      '@'     => $data,
      /\.$/   => $data,
      default => "${data}."
    }
    dns::record { $alias:
      zone     => $zone,
      host     => $host,
      ttl      => $ttl,
      record   => 'CNAME',
      data     => $qualified_data,
      data_dir => $data_dir,
    }
  }
}
