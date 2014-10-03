/* quick and dirty script to generate gcc flags */
"gcc -h >g  2>nul"

do i = 1 to  8
   "gcc -h"i ">>g  2>nul"
end

do i = 1 to 16
   "gcc -h1."i ">>g  2>nul"
end

"gcc -h1.15.14 >>g  2>nul"

