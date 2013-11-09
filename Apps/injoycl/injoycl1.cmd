/*                                                                           */
/* utility to calculate time used online with in-joy internet dialer       */
/* Written for personal use and free distribution by idiot@mindless.com */
/* If you find this useful please email me and let me know              */
/*                          						      */
/* Installation.  Place this file in your injoy directory                    */
/* and run it from the command line. simple huh :)                       */
/*                                                                           */
/* feel free to hack the rexx if you can make it better.  send me a copy*/
/*                                                                           */

call RxFuncAdd 'SysLoadFuncs','rexxutil','sysloadfuncs'
call sysloadfuncs

say ""
say "In-joy online time calculator"
say ""

rc = SysFileTree('*.log', 'found', 'O')
do counter=rc to found.0
	say counter found.counter
end

say choose the log to analyse
parse pull number

say "what month ? jan=01 feb=02...dec=12"
parse pull input_month

total_time_online = 0

call SysFileSearch 'date', found.number, 'stem.'
do i=1 to stem.0
	PARSE VAR stem.i 'DATE' day.i'.'month.i'.'year.i',' shit.i ',' 'DURATION' minutes.i 'min,' seconds.i 'sec'
/*	say i "day =" day.i "month ="month.i "year ="year.i "time online = "minutes.i */
	if month.i = input_month
		then total_time_online = total_time_online + minutes.i
end
say "total time online for month" input_month "=" total_time_online "minutes for this ISP"
say ""
say "total time online for month" input_month "=" total_time_online/60 "hours for this ISP"
say ""
say "Written by idiot@mindless.com and distributed as freeware. "
say "Email me and tell me what you think."


