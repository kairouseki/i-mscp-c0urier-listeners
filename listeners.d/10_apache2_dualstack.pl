# i-MSCP Listener::Apache2::DualStack listener file
# Copyright (C) 2015 Laurent Declercq <l.declercq@nuxwin.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA

package Listener::Apache2::DualStack;

use iMSCP::EventManager;
use List::MoreUtils qw(uniq);

my $httpPort = 80;
my $httpsPort = 443;

# Parameter allowing to add one or many IPs to the Apache2 vhost file of a specific domain
# IPv6 addresses must be surrounded by square-brackets ( eg. [2001:db8:0:85a3:0:0:ac1f:8001] )
# Please replace the values below by your own values
my %perDomainAdditionalIPs = (
	'<domain1.tld>' => ['<IP1>', '<IP2>'],
	'<domain1.tld>' => ['<IP1>', '<IP2>']
);

# Parameter which allow to add one or many IPs to all apache2 vhosts files
# IPv6 addresses must be surrounded by square-brackets ( eg. [2001:db8:0:85a3:0:0:ac1f:8001] )
# Please replace the values below by your own values
my @additionalIps = ( '<IP1>', '<IP2>' );

#
## Please, don't edit anything below this line
#

# Listener responsible to make the Httpd server implementation aware of additional IPs
sub addIPList
{
	my $data = $_[1];

	my @ipsList = ();

	for my $domain(keys %perDomainAdditionalIPs) {
		@ipsList = ( @ipsList, @{$perDomainAdditionalIPs{$domain}} );
	}

	@ipsList = s/\[|\]//g for @ipsList, @additionalIps;

	#@{$data->{'SSL_IPS'}} = uniq(@{$data->{'SSL_IPS'}}, @ipsList);
	@{$data->{'IPS'}} = uniq( @{$data->{'IPS'}}, @ipsList );

	0;
}

# Listener responsible to add additional IPs in Apache2 vhost files
sub addIPs
{
	my ($cfgTpl, $tplName, $data) = @_;

	if(exists $data->{'DOMAIN_NAME'} && $tplName =~ /^domain(?:_(?:disabled|redirect))?(_ssl)?\.tpl$/) {
		my $port = (defined $1) ? $httpsPort : $httpPort;
		my $ipList = ();

		# All vhost IPs
		if(@additionalIps) {
			@ipList = split ' ', (join ":$port ", @additionalIps) . ":$port";
		}

		# Per domain IPs
		if(exists $perDomainAdditionalIPs{$data->{'DOMAIN_NAME'}}) {
			@ipList = uniq(@ipList, split ' ', (join ":$port ", @{$perDomainAdditionalIPs{$data->{'DOMAIN_NAME'}}}) . ":$port");
		}

		if(@ipList) {
			$$cfgTpl =~ s/(<VirtualHost.*?)>/$1 @ipList>/;
		}
	}

	0;
}

# Register event listeners on the event manager
my $eventManager = iMSCP::EventManager->getInstance();
$eventManager->register('beforeHttpdAddIps', \&addIPList);
$eventManager->register('afterHttpdBuildConfFile', \&addIPs);

1;
__END__
