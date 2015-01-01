=head1 NAME

 Listener::Apache2::DualStack

=cut


package Listener::Apache2::DualStack;

use iMSCP::EventsManager;
use List::MoreUtils qw(uniq);

=head1 DESCRIPTION

 Listener file which allow to add additional IPs (DualStack) in Apache2 vhost files managed by i-MSCP

=head1 CONFIGURATION PARAMETERS

=over 4

my $httpPort = 80;
my $httpsPort = 443:

# Parameter allowing to add one or many IPs to the Apache2 vhost file of a specific domain
# IPv6 addresses must be surrounded by square-brackets (eg )[2001:db8:0:85a3:0:0:ac1f:8001]
# Please replace the values below by true values
my %perDomainAdditionalIPs = (
	'<domain1.tld>' => [ '<ip1>', '<ip2>' ],
	'<domain2.tld>' => [ '<ip1>', '<ip2>' ]
);

# Parameter which allow to add one or many IPs to all apache2 vhosts files
# IPv6 addresses must be surrounded by square-brackets (eg )[2001:db8:0:85a3:0:0:ac1f:8001]
# Please replace the values below by true values
my @additionalIps = ('<ip1>', '<ip2>' );

# Please, don't edit anything below this line

=back

=head1 EVENT LISTENERS

=over 4

=item addNameVirtualHost

 Listener responsible to add NameVirtualHost directives

=cut

sub addNameVirtualHost
{
	my ($cfgTpl, $data) = @_;

	my @ipsList = ();

	# Build list of named Directives
	for my $domain(keys %perDomainAdditionalIPs) {
		@ipsList = (@ipsList, @{$perDomainAdditionalIPs{$domain}} );
	}

	@ipsList = (@ipsList, @additionalIps);

	#@{$data->{'SSL_IPS'}} = uniq(@{$data->{'SSL_IPS'}}, @ipsList);
	@{$data->{'IPS'}} = uniq(@{$data->{'IPS'}}, @ipsList);

	0;
}

=item addIps(\$cfgTpl, $tplName, \%data)

 Listener responsible to add additional IPs in Apache2 vhost files

 Param string \$cfgTpl Apache2 vhost template
 Param string $tplName Apache vhost template name (domain.tpl, domain_ssl.tpl domain_redirect.tpl ...)
 Param hash \%data Data as provided by Httpd server implementation
 Return int 0

=cut

sub addIps
{
	my ($cfgTpl, $tplName, $data) = @_;

	if(exists $data->{'DOMAIN_NAME'}) {
		if($tplName ~= /^domain_(disabled|redirect)?(_ssl)?\.tpl/) {
			my $port = ($tplName ~= /ssl/) ? $httpsPort : $httpPort;

			# All vhost IPs
			if(@additionalIps) {
				my $ipsListStr = join ":$port ", @additionalIps;
				$$cfgTpl ~= s/<VirtualHost(.*)>/<VirtualHost $1 $ipsListStr>/;
			}

			# Per domain IPs
			if(%perDomainAdditionalIPs && exists $perDomainAdditionalIPs{$data->{'DOMAIN_NAME'}}) {
				my $ipsListStr = join ":$port ", @{$perDomainAdditionalIPs{$data->{'DOMAIN_NAME'}}};
				$$cfgTpl ~= s/<VirtualHost(.*)>/<VirtualHost $1 $ipsListStr>/;
			}
		}
	}

	0;
}

=back

=head1 MAIN

=over 4

# Register event listeners on the events manager
my $eventsManager = iMSCP::EventsManager->getInstance();
$eventsManager->register('beforeHttpdAddIps', \&addNameVirtualHost);
$eventsManager->register('afterHttpdBuildConfFile', \&addIps);

=back

=head1 AUTHOR

 Laurent Declercq <l.declercq@nuxwin.com>

=cut

1;
__END__
