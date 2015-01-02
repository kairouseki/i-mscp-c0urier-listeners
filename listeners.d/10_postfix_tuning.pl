# i-MSCP Listener::Postfix::Tuning listener file
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

package Listener::Postfix::Tuning;

use iMSCP::Debug;
use iMSCP::ProgramFinder;
use iMSCP::EventManager;
use iMSCP::Execute;

#
## Configuration parameters
#

# Path to Postfix configuration directory
my $postfixConfigDir = '/etc/postfix';

## Postfix main.cf parameters
# Hash where each pair of key/value correspond to a specific postfix parameter
# Please replace the values below by your own values
my %mainCfParameters = (
	'inet_protocols' => 'ipv4,ipv6',
	'inet_interfaces' => '127.0.0.1, 192.168.2.5, [2001:db8:0:85a3::ac1f:8001]',
	'smtp_bind_address' => '192.168.2.5',
	'smtp_bind_address6' => '',
	'relayhost' => '192.168.1.5:125'
);

## Postfix master.cf parameters
# Array where each line correspond to a postfix master.cf entry. Entries are added at bottom.
# Please replace the values blow by your own values
my @masterCfParameters = (
	'125       inet  n       -       -       -       -       smtpd'
);

# Please, don't edit anything below this line

# Listener responsible to tune Postfix main.cf file, once it was built by i-MSCP
sub setupMainCf
{
	if(%mainCfParameters && iMSCP::ProgramFinder::find('postconf')) {
		my @cmd = (
			'postconf',
			'-e', # Needed for Postfix < 2.8
			'-c', escapeShell($postfixConfigDir)
		);

		push @cmd, ($_ . '=' . escapeShell($mainCfParameters{$_})) for keys %mainCfParameters;

		my ($stdout, $stderr);
		my $rs = execute("@cmd", \$stdout, \$stderr);
		debug($stdout) if $stdout;
		error($stderr) if $stderr && $rs;
		return $rs if $rs;
	}

	0;
}

# Listener responsible to add entries at bottom of Postfix master.cf file, once it was built by i-MSCP
sub setupMasterCf
{
	my $cfgTpl = $_[0];

	if(@masterCfParameters) {
		$$cfgTpl .= join("\n", @masterCfParameters) . "\n";
	}

	0;
}

# Register event listeners on the event manager
my $eventManager = iMSCP::EventManager->getInstance();
$eventManager->register('afterMtaBuildConf', \&setupMainCf);
$eventManager->register('afterMtaBuildMasterCfFile', \&setupMasterCf);

1;
__END__
