


Very simple - run this manually on the server every 5-10 minutes and see
what systems always appear in the list
(See attached file: ListSuspects.cmd)


We run this from timexec every 5 minutes to see if new 3101s have appeared
in the net error log
- it will log the sessions, delete suspected problem users, etc
- it also pages us or sends email ( calls the sendmail.exe )

(See attached file: Check.cmd)

Similar to above - doesn't remove any sessions
(See attached file: Check_NoDelete.cmd)

On some systems, we run this from timexec every hour to see cleanup to
deleted suspects
17,18,19,20,21,22,23,0,1,2,3,4,5,6 22 * * * * * start /c d:
\net3101\killsess.cmd >> d:\net3101\killsess.log
(See attached file: KillSess.cmd)

Can be run on demand to delete the suspect users - i.e. w/ Under 10 minutes
idle time, no open files (may check for no username)
(See attached file: DeleteSuspects.cmd)

Uses the REXX utils to do a revised NET SESS with more information
(See attached file: netsess.cmd)

Sample output  - the system in Blue might be a possible problem
24 Oct 2001 09:46:39
Sessions with idle time under 10
Number of computers having a session to server:  110

                                 CON OPEN   IDLE USR  ACT    OS
CAMARIO          camario          1   0     9.25  1    10.30 OS/2 LS 3.0
DGH4                              0   0     5.22  1  1265.65 OS/2 LS 3.0
LULF                              4   0     0.13  1   146.67 OS/2 LS 3.0
LUST             LUST             2   1     1.28  1   187.08 OS/2 LS 3.0
MARIER                            3   0     6.75  1   119.67 OS/2 LS 3.0
MCOOK            XZW0997          1   0     0.98  1   232.97 OS/2 LS 3.0
MHEILING         mheiling         1   0     7.40  1     8.13 OS/2 LS 3.0
MPA              mpa              1   0     4.83  1    17.00 OS/2 LS 3.0
PETEJ            pjj              3   0     0.80  1    52.47 OS/2 LS 3.0
RCH2QNET         QTCPB1           1   0     1.33  1    43.53 OS/2 LS 5.0
RCH4QNET         ADMINSRV         1   0     0.18  1  1182.78 OS/2 LS 3.0
RCHS1TSK         ADMINSRV         1   0     0.00  1  2924.97 OS/2 LS 5.0
RJBROWN                           1   0     5.32  1    12.52 OS/2 LS 3.0
ROEMER           ROEMER           1   1     6.38  1     6.65  DOS LS 3.0
V2FDJEP                           1   0     7.58  1   145.80 OS/2 LS 3.0
V2FDOLR          v2fdolr          1   0     5.72  1   128.45 OS/2 LS 3.0


Here's another too that I use from OS/2 to see what a system is doing - it
will also log for future checking.

(See attached file: sessmon.cmd)
Sample:
20011016 10:06:54 \\rchs16gd LOUVRE     1 0    0.0 min
20011016 10:11:54 \\rchs16gd LOUVRE     1 0    0.0 min
20011016 10:16:54 \\rchs16gd LOUVRE     1 0    0.0 min
20011016 10:51:53 \\rchs16gd LOUVRE   No connection     probably rebooted
her box
20011016 10:51:53 \\rchs16gd LOUVRE     0 0    4.8 min  almost 5 minutes
20011016 10:52:05 \\rchs16gd LOUVRE     1 0    0.2 min  session restarted
20011016 10:56:55 \\rchs16gd LOUVRE     0 0    4.8 min  almost 5 minutes
20011016 10:57:06 \\rchs16gd LOUVRE     1 0    0.2 min  session restarted


Sample - I started to watch the system in Blue above - but since its idle
time is now above 10 minutes, probably not my problem - ALTHOUGH I can't
rule out that some systems may run on a time interval different than 5
minutes!

20011024 09:46:03 \\rchs04hd DGH4       0 0    6.1 min
20011024 09:46:33 \\rchs04hd DGH4       0 0    6.6 min
20011024 09:47:03 \\rchs04hd DGH4       0 0    7.1 min
20011024 09:47:33 \\rchs04hd DGH4       0 0    7.6 min
20011024 09:48:03 \\rchs04hd DGH4       0 0    8.1 min
20011024 09:48:33 \\rchs04hd DGH4       0 0    8.6 min
20011024 09:49:03 \\rchs04hd DGH4       0 0    9.1 min
20011024 09:49:33 \\rchs04hd DGH4       0 0    9.6 min
20011024 09:50:03 \\rchs04hd DGH4       0 0   10.1 min
:


