# i-MSCP Listener::System::Hosts listener file
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

package Listener::System::Hosts;

use iMSCP::Debug;
use iMSCP::EventManager;
use iMSCP::File;

#
## Configuration parameters
#

# Path to system hosts file
my $hostsFilePath = '/etc/hosts';

# Parameter which allow to add one or many entries in the system hosts file
# Please replace the values below by your own values
my @hostsFileEntries = (
	'192.168.1.10	foo.mydomain.org	foo',
	'192.168.1.13	bar.mydomain.org	bar'
);

# Please, don't edit anything below this line

# Listener responsible to add host entries in the system hosts file, once it was built by i-MSCP
sub addEntries
{
	if(-f $hostsFilePath) {
		my $file = iMSCP::File->new( filename => $hostsFilePath );

		my $fileContent = $file->get();
		unless(defined $fileContent) {
			error("Unable to read $hostsFilePath");
			return 1;
		}

		my $rs = $file->set( $fileContent . ( join "\n", @hostsFileEntries ) . "\n" );
		return $rs if $rs;

		$rs = $file->save();
		return $rs if $rs;
	}

	0;
}

# Register event listeners on the event manager
my $eventManager = iMSCP::EventManager->getInstance();
$eventManager->register('afterSetupServerHostname', \&addEntries);

1;
__END__
