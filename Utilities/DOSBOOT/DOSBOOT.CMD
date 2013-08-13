cd\os2\system
copy config.dos config.nml
copy autoexec.dos autoexec.nml
copy config.%1 config.dos
copy autoexec.%1 autoexec.dos
\os2\boot /dos
