
set errors 0

if { $argc == 0 } {
	set computer [string toupper [info hostname]]
} elseif { [regexp {[;:/\?\*]} [lindex $argv 0]] }  {
	set errors 1
} elseif { $argc == 1 } {
	set computer [string toupper [lindex $argv 0]]
} else {
	set errors 1
}

if { $errors != 1 } {
	package require twapi_wmi
	namespace path twapi

	# Some basic error handling
	if { [catch {[set wbem_services [comobj_object winmgmts://$computer/root/cimv2]]} errmsg] } {
		# Work-around: when using catch, the "set wbem_services" command complains about
		# wrong arguments; if catch isn't used, however, that same "set wbem_services"
		# command continues without complaining (provided a valid computer is specified)
		if { $errorCode != "TCL WRONGARGS" } {
			puts "\nError: $errmsg"
			set errors 1
		}
	}

	if { $errors != 1 } {
		set colitems [$wbem_services ExecQuery "SELECT * FROM Win32_Printer"]

		if { [$colitems Count] == 0 } {
			puts "\nNo printers found on $computer"
			exit -1
		} elseif { [$colitems Count] == 1 } {
			puts "\n1 printer found on $computer:\n"
		} else {
			puts "\n[$colitems Count] printers found on $computer:\n"
		}

		set printers {}

		if { [$colitems Count] != 0 } {
			$colitems -iterate item {
				if { [$item Default] } {
					puts "\t[$item DeviceID]"
				} else {
					lappend printers [$item DeviceID]
				}
				$item -destroy
			}

			foreach item [lsort -dictionary $printers] {
				puts "\t$item"
			}

			$colitems -destroy
			$wbem_services -destroy

			exit 0
		}
	}
}

if { $errors == 1 } {
	puts "\nListPrinters.tcl,  Version 1.02"
	puts "List all printers available on the specified computer\n"
	puts "Usage:  tclsh.exe    ListPrinters.tcl   \[ computer \]\n"
	puts "Where:  \"computer\"   is the optional host name or IP address of a"
	puts "                     remote computer (default: local computer)\n"
	puts "Notes:  The default printer is listed first, followed by a sorted list"
	puts "        of the other printers."
	puts "        Return code is -1 in case of (command line) errors, otherwise 0.\n"
	puts "Written by Rob van der Woude"
	puts "http://www.robvanderwoude.com"
	exit -1
}