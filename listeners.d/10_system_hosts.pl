package Listener::System::Hosts;

use iMSCP::Debug;
use iMSCP::EventsManager;
use iMSCP::File;

#
## Configuration parameters
#

# Path to hosts file
my $hostsFilePath = '/etc/hosts';

# Parameter which allow to add one or many entries in the system hosts file
# Please replace the values below by your own values
my @entries = (
	'192.168.1.10	foo.mydomain.org	foo',
	'192.168.1.13	bar.mydomain.org	bar'
);

# Please, don't edit anything below this line

# Listener responsible to add entries in hosts file after i-MSCP hosts file generation
sub addEntries
{
	if(-f $hostsFilePath) {
		my $file = iMSCP::File->new( filename => $hostsFilePath );

		my $fileContent = $file->get();
		unless(defined $fileContent) {
			error("Unable to read $hostsFilePath");
			return 1;
		}

		my $rs = $file->set( join "\n", @entries );
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
