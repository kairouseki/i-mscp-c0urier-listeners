i-mscp-c0urier-listeners
=========================

Set of i-MSCP listener files for i-MSCP. These listener files are only compatible with i-MSCP >= **1.2.0**.

## Listener files

Below, you can find a list of all listener files which are available in that repository and their respective purpose.

To install a listener file, you must upload it in your **/etc/imscp/listeners.d** directory, and edit the configuration
parameters inside it. Once done, you must rerun the i-MSCP installer.

### Listener::Apache2::DualStack

The **listeners.d/10_apache2_dualstack.pl** listener file provide dual stack support for Apache2.

### Listener::Postfix::Tuning

The **listeners.d/10_postfix_tuning.pl** listener file allow to tune Postfix configuration files ( main.cf and master.cf ).

### Listener::Apache2::System::Hosts

The **listeners.d/10_system_hosts.pl** listener file allow to add host entries in the system hosts file ( eg. /etc/hosts ).

### License

	Copyright (c) 2015 Laurent Declercq <l.declercq@nuxwin.com>
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

 see [lgpl v2.1](http://www.gnu.org/licenses/lgpl-2.1.txt "lgpl v2.1")

## Sponsors

 - [c0urier.net](http://www.c0urier.net/ "c0urier.net")
 - [Kazi Networks](http://www.kazi-networks.com/ "Kazi Networks")

## Author

- Laurent Declercq <l.declercq@nuxwin.com>
