#! perl

# Store help text in variable
$syntax = "\nDefPRN2K.pl,  Version 1.00 for Windows 2000\n";
$syntax = $syntax."Display default printer\n\n";
$syntax = $syntax."Usage:  DEFPRN2K.PL\n\n";
$syntax = $syntax."Written by Rob van der Woude\n";
$syntax = $syntax."http://www.robvanderwoude.com\n";

# Check Windows version (Windows 2000 = NT 5.0 or later required)
if ( $^O ne "MSWin32" ) {
	die $syntax;
} else {
        @os_version_info = Win32::GetOSVersion();
	if ( @os_version_info[1] < 5 ) {
		die $syntax;
	}
}

# Check number of command line arguments (none required)
if ( @ARGV[0] ) {
	die $syntax;
}

# Initialize the required module
use Win32API::Registry 0.21 qw( :ALL );

# Read the value from the registry
RegOpenKeyEx( HKEY_CURRENT_USER, "Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows", 0, KEY_READ, $handle ) || die "Can't open registry section: ".regLastError()."\n";
RegQueryValueEx( $handle, "Device", [], $type, $regval, [] ) || die "Can't read registry section: ".regLastError()."\n";
RegCloseKey( $handle ) ||  die "Can't close registry section: ".regLastError()."\n";

# Parse the string found
$regval =~ m/^([^\,]+),[^\,]+,([^:]+):?$/;
$prn    = $1;
$port   = $2;

# Display the result
print "\nDefault printer is $prn on $port\n";
