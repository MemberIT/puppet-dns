# == Define: dns::record::mx
#
# Wrapper for dns::record to set an MX record.
#
define dns::record::mx (
  $zone,
  $data,
  $ttl        = '',
  $preference = 10,
  $host       = '@',
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
      fail("Define[dns::record::mx]: MX zone ${zone} must be a valid domain name.")
    }
    # Highest label (top-level domain) must be alphabetic
    if $zone =~ /\./ and $zone !~ /(\.|@)[A-Za-z]+$/ {
      fail("Define[dns::record::mx]: MX zone ${zone} must be a valid domain name.")
    }
    # RR data must be a valid hostname, not entirely numeric values
    if !is_domain_name($data) or $data =~ /^[0-9\.]+$/ {
      fail("Define[dns::record::mx]: MX data ${data} must be a valid hostname.")
    }
    if !is_integer($preference) or $preference < 0 or $preference > 65536 {
      fail("Define[dns::record::mx]: preference ${preference} must be an integer within 0-65536.")
    }
    if !is_domain_name($host) and $host != '@' {
      # Blank labels are permitted in BIND zone files, but they are not handled
      # by this puppet module because it does not render concat fragments in an
      # explicit order. Since BIND will substitute the last valid label, the
      # resulting blank substitution would be unpredictable.
      # Use @ to substitute the zone origin.
      fail("Define[dns::record::mx]: MX host label ${host} must be a valid hostname or '@' to signify \$ORIGIN.")
    }
    $alias = "${name},${zone},MX,${preference},${data}"
    dns::record { $alias:
      zone       => $zone,
      host       => $host,
      ttl        => $ttl,
      record     => 'MX',
      preference => $preference,
      data       => "${data}.",
      order      => 2,
      data_dir   => $data_dir,
    }
  }
}
