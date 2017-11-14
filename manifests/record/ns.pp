# == Define: dns::record::ns
#
# Wrapper of dns::record to set NS records
#
define dns::record::ns (
  $zone,
  $data,
  $ttl  = '',
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
  validate_string($data)
  validate_string($host)

  $convert_zone.each |String $zone| {
    if (!is_domain_name($zone) and $zone !~ /(\.|@)[A-Za-z]+$/) or $zone =~ /^[0-9\.]+$/ {
      fail("Define[dns::record::ns]: NS zone ${zone} must be a valid domain name.")
    }
    # Highest label (top-level domain) must be alphabetic
    if $zone =~ /\./ and $zone !~ /(\.|@)[A-Za-z]+$/ {
      fail("Define[dns::record::ns]: NS zone ${zone} must be a valid domain name.")
    }
    # RR data must be a valid hostname, not entirely numeric values
    if !is_domain_name($data) or $data =~ /^[0-9\.]+$/ {
      fail("Define[dns::record::ns]: NS data ${data} must be a valid hostname.")
    }
    $alias = "${host},${zone},NS,${data}"
    dns::record { $alias:
      zone     => $zone,
      host     => $host,
      ttl      => $ttl,
      record   => 'NS',
      data     => $data,
      data_dir => $data_dir,
    }
  }
}
