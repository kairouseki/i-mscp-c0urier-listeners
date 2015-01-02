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

package Listener::Postfix::Relayhost;

use iMSCP::Debug;
use iMSCP::ProgramFinder;
use iMSCP::EventManager;
use iMSCP::Execute;

#
## Configuration parameters
#

# Parameter which allow to set relayhost parameter
# Please replace the value below by your own value
my $relayhost = '192.168.1.5:125';

# Please, don't edit anything below this line

# Listener responsible to setup relayhost parameter in postfix main.cf file after i-MSCP processing
sub setupRelayhost
{
	if(iMSCP::ProgramFinder::find('postconf')) {
		my @cmd = ('postconf', ('relayhost=' . escapeShell($relayhost)));

		my ($stdout, $stderr);
		my $rs = iMSCP::Execute("@cmd", \$stdout, \$stdout);
		debug($stdout) if $stdout;
		error($stderr) if $stderr && $rs;
		return $rs if $rs;
	}

	0;
}

# Register event listeners on the event manager
my $eventManager = iMSCP::EventManager->getInstance();
$eventManager->register('afterMtaBuildMainCfFile', \&setupRelayhost);

1;
__END__
