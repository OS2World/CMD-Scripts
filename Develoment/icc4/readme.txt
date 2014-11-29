ICC4 1.08

ICC4 is a front end to use VisualAge C++ 4.0's vacbld command like icc of old icc.
This is only for C++ source files.
The options must start with -, not /.

Usage example:
icc4 foo.cpp (generate foo.exe)
icc4 -C -Foobj\foo.obj foo.cpp (generate obj\foo.obj)
icc4 -Fc foo.cpp (sytax check only)
icc4 -Febin\foo.exe foo.obj bar.lib (link and generate bin\foo.exe)

History
2001-03-11 1.08: Fix: NOCODESTORE/CODESTORE/CLEANCODESTORE/SHOWPROGRESS options are not working.

2001-03-01 1.07: Fix: -Tx options did not work.
                 Add -STACK option.

2001-01-31 1.06: Fix: some options (ex PMTYPE) does not work.
                 Fix: cannot process .HXX files.

2000-09-28 1.05: Return error code when VACBLD returns with error code.

2000-09-13 1.04: You can specify lib files in lower cases.
                 H/HXX/HPP is now tread as C++ source files.

2000-09-08 1.03: Use code store. This improves the performance.
                 Add -CODESTORE/NOCODESTORE option.
                 Add -CLEANCODESTORE option.

2000-09-05 1.02: You need not specify the path of the lib files.

2000-09-04 1.01: Fix -Gx option problem. (Trap may occur)
                 Add -PROGRESS option.

2000-09-01 1.00: initial release
