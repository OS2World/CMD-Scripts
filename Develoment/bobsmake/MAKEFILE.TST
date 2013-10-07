SETDIR = j:\rascode
"@echo ' Starting this makefile '"
SETLIST SourceFiles = (rassupt.* rasls16.inc ls16supt.* parmarea.inc)

IFCOND exedll\rasls16.dll < SourceFiles then DOCOND
    SAY 'Target file = ' TargetFile ' TargetDrive = ' TargetDrive ' Target Path = ' TargetPath ' TargetFullName = ' TargetFullName 'TargetName = ' TargetName 'TargetSuffix = ' TargetSuffix
    'PLI ' targetName
    'link386 @'||TargetName||'.rsp'
    ENDCOND
