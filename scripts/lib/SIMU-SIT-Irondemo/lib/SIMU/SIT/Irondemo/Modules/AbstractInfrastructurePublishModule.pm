package SIMU::SIT::Irondemo::Modules::AbstractInfrastructurePublishModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';

sub specific_mac_address {
  my $address=$_[1];
  my $r = <<"END";
  <mac-address value="$address"/>
END
  return $r;
}

sub specific_ipv4_address {
  my $address=$_[1];
  my $r = <<"END";
<ip-address type="IPv4" value="$address"/>
END
  return $r;
}

sub specific_ipv6_address {
  my $address=$_[1];
  my $r = <<"END";
<ip-address type="IPv6" value="$address"/>
END
  return $r;
}

sub generic_mac_address {
  my $address=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;address xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;2&amp;quot; type=&amp;quot;MAC&amp;quot; value=&amp;quot;$address&amp;quot;&amp;gt;&amp;lt;/address&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub generic_ipv4_address {
  my $address=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;address xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;3&amp;quot; type=&amp;quot;IPv4&amp;quot; value=&amp;quot;$address&amp;quot;&amp;gt;&amp;lt;/address&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r
}

sub generic_ipv6_address {
  my $address=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;address xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;3&amp;quot; type=&amp;quot;IPv6&amp;quot; value=&amp;quot;$address&amp;quot;&amp;gt;&amp;lt;/address&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}


sub specific_vlan {
  my $vlan=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;vlan xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; id=&amp;quot;$vlan&amp;quot;&amp;gt;&amp;lt;/vlan&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub specific_ipv4_network {
  my $network=$_[1];
  my $prefix=$_[2];
  my $r = <<"END";
<identity name="&amp;lt;ipnetwork xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; prefix=&amp;quot;$prefix&amp;quot; type=&amp;quot;IPv4&amp;quot; value=&amp;quot;$network&amp;quot;&amp;gt;&amp;lt;/ipnetwork&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub specific_ipv6_network {
  my $network=$_[1];
  my $prefix=$_[2];
  my $r = <<"END";
<identity name="&amp;lt;ipnetwork xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; prefix=&amp;quot;$prefix&amp;quot; type=&amp;quot;IPv6&amp;quot; value=&amp;quot;$network&amp;quot;&amp;gt;&amp;lt;/ipnetwork&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub generic_vlan {
  my $network=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;network xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;2&amp;quot; type=&amp;quot;Ethernet&amp;quot; value=&amp;quot;$network&amp;quot;&amp;gt;&amp;lt;/network&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub generic_ipv4_network {
  my $network=$_[1];
  my $prefix=$_[2];
  my $r = <<"END";
<identity name="&amp;lt;network xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;3&amp;quot; scope=&amp;quot;$prefix&amp;quot; type=&amp;quot;IPv4&amp;quot; value=&amp;quot;$network&amp;quot;&amp;gt;&amp;lt;/network&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub generic_ipv6_network {
  my $network=$_[1];
  my $prefix=$_[2];
  my $r = <<"END";
<identity name="&amp;lt;network xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;3&amp;quot; scope=&amp;quot;$prefix&amp;quot; type=&amp;quot;IPv6&amp;quot; value=&amp;quot;$network&amp;quot;&amp;gt;&amp;lt;/network&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

sub interface {
  my $name=$_[1];
  my $r = <<"END";
<identity name="&amp;lt;interface xmlns=&amp;quot;http://sit.fraunhofer.de/2014/INFRASTRUCTURE-IDENTIFIER/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; layer=&amp;quot;combined_2_3&amp;quot; name=&amp;quot;$name&amp;quot; type=&amp;quot;physical&amp;quot;&amp;gt;&amp;lt;/interface&amp;gt;" type="other" other-type-definition="extended"/>
END
  return $r;
}

1;
