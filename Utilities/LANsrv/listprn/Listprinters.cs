// The initial C# code for the WMI query was generated by WMI Code Generator, Version 5.00, http://www.robvanderwoude.com/wmigen.php

using System;
using System.Management;
using System.Collections;


namespace RobvanderWoude
{
	public class ListPrinters
	{
		public static int Main( string[] args )
		{
			try
			{
				string computer = string.Empty;

				#region Command line parsing

				// Only 1 optional argument allowed: a remote computer name
				if ( args.Length > 1 )
				{
					throw new Exception( "Invalid command line arguments" );
				}
				if ( args.Length == 1 )
				{
					// We'll display a 'friendly' message if help was requested
					if ( args[0].StartsWith( "/" ) || args[0].StartsWith( "-" ) )
					{
						switch ( args[0].ToUpper( ) )
						{
							case "/?":
							case "-?":
							case "/H":
							case "-H":
							case "--H":
							case "/HELP":
							case "-HELP":
							case "--HELP":
								return WriteError( string.Empty );
							default:
								return WriteError( "Invalid command line argument" );
						}
					}
					else
					{
						computer = "\\\\" + args[0] + "\\";
					}
				}

				#endregion

				string wmins = computer + "root\\CIMV2";

				ManagementObjectSearcher searcher = new ManagementObjectSearcher( wmins, "SELECT * FROM Win32_Printer" );

				ArrayList printers = new ArrayList( );

				foreach ( ManagementObject queryObj in searcher.Get( ) )
				{
					printers.Add( queryObj["DeviceID"] );
				}

				printers.Sort( );

				foreach ( string printer in printers )
				{
					Console.WriteLine( printer );
				}

				return 0;
			}
			catch ( Exception e )
			{
				return WriteError( e );
			}
		}

		public static int WriteError( Exception e )
		{
			return WriteError( e == null ? null : e.Message );
		}

		public static int WriteError( string errorMessage )
		{
			/*
			ListPrinters,  Version 1.10
			List all local printers on the specified computer

			Usage:  LISTPRINTERS  [ computername ]

			Where:  'computername'  is the (optional) name of a remote computer
									(default if not specified: local computer)

			Written by Rob van der Woude
			http://www.robvanderwoude.com
			*/

			string fullpath = Environment.GetCommandLineArgs( ).GetValue( 0 ).ToString( );
			string[] program = fullpath.Split( '\\' );
			string exename = program[program.GetUpperBound( 0 )];
			exename = exename.Substring( 0, exename.IndexOf( '.' ) );

			if ( string.IsNullOrEmpty( errorMessage ) == false )
			{
				Console.Error.WriteLine( );
				Console.ForegroundColor = ConsoleColor.Red;
				Console.Error.Write( "ERROR:  " );
				Console.ForegroundColor = ConsoleColor.White;
				Console.Error.WriteLine( errorMessage );
				Console.ResetColor( );
			}
			Console.Error.WriteLine( );
			Console.Error.WriteLine( exename + ",  Version 1.10" );
			Console.Error.WriteLine( "List all local printers on the specified computer" );
			Console.Error.WriteLine( );
			Console.Error.Write( "Usage:  " );
			Console.ForegroundColor = ConsoleColor.White;
			Console.Error.Write( exename.ToUpper( ) );
			Console.Error.WriteLine( "  [ computername ]" );
			Console.ResetColor( );
			Console.Error.WriteLine( );
			Console.Error.WriteLine( "Where:  'computername'  is the (optional) name of a remote computer" );
			Console.Error.WriteLine( "                        (default if not specified: local computer)" );
			Console.Error.WriteLine( );
			Console.Error.WriteLine( "Written by Rob van der Woude" );
			Console.Error.WriteLine( "http://www.robvanderwoude.com" );
			return 1;
		}
	}
}
