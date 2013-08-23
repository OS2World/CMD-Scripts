What is INI2Rexx?
-----------------
INI2Rexx is a tool tahat eases the freezing, editing and mainteinance of INI
files that you want to behave exactly as you like.

It works by generating a rexx script capable or regerating again the original
INI file when executed. What are then the advantages?
-You can edit the rexx script with any ASCII text editor.
-The INI file generation is created automatically once finished the script
editing, which can be very useful for automatic tasks.

In the intent to ease the editing, the rexx scripts contains as much text as
possible. Binary keys are also dumped in hexadecimal form with a comment
containing an ASCII transliteration, and keys with a mixed value are dumped
in mixed form (no hexa->ASCII transliteration is performed in this case).

Requeriments:
-------------
FastINI.DLL, included in the package. It is copyright of Dennis Bareis.
http://www.ozemail.com.au/~dbareis

Known bugs / limitations.
-------------------------
A user informed that he had to run the rexx program twice to recreate an INI
file with the same name as the system INI file.

History:
---------
Version 0.1, revision 2:
~~~~~~~~~~~~~~~~~~~~~~~~
-Now RxFuncQuery is used to see if it is necessary to call SysLoadFuncs and
the other external functions. It is also used in the generated rexx scripts.
-Removed the nuissance of unvoluntarily closed comments in hex dumps.
-Someone told me to include some corrections in the English text, but I lost
the message and his email. Sorry, it will be for v0.1.3!

Version 0.1, revision 1:
~~~~~~~~~~~~~~~~~~~~~~~~
First public release.

I hope this is of some use for some one....

Feedback will be VERY welcome.

Alfredo Fern ndez D¡az, alfredo at netropolis-si dot com
