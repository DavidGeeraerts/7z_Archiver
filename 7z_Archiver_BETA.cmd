::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts																::
:: Location:	Olympia, Washington USA														::
:: E-Mail:		dgeeraerts.evergreen@gmail.com												::
::																							::
::	Copyright License																		::
:: 	Creative Commons: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)	::
:: 	http://creativecommons.org/licenses/by-nc-sa/3.0/										::
::																							::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::
:: Helpful information can be found here:		::
::	http://thedeveloperblog.com/7-zip-examples	::
::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::

@Echo Off
@SETLOCAL enableextensions

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $SCRIPT_NAME=7z_Archiver_BETA
SET $SCRIPT_VERSION=2.0.0
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
Prompt 7z$G
color 8A
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: DO NOT SURROND THE PATH WITH DOUBLE QUOTES

:: SET $ARCHIVE_NAME=%USERPROFILE%\Documents\Sample_Archive
:: SET $ARCHIVE_SOURCE_FOLDER=%USERPROFILE%\Documents

:: One Off Archive
::	$ARCHIVE_NAME: What to make the archive
::	i.e. D:\Mounts\Archives\research\research
::		...the name will automatically be appended with the compression method: <ARCHIVE_NAME>.7z
SET $ARCHIVE_NAME=
::	ARCHIVE_SOURCE_FOLDER: What to archive (folder)
SET $ARCHIVE_SOURCE_FOLDER=
:: Bulk folder archive
::	Will automatically create the compressed archive files in the same folder
SET $ARCHIVE_BULK_FOLDER=

:: ACTIONS
::	{a: Add files to archive}
::	{b: Benchmark}
::	{d: Delete files from an archive}
::	{e: Extract}
::	{h: Hash}
::	{l: List}
::	{m: Rename}
::	{t: Test}
::	{u: Update}
::	{x: Extract with full paths}
SET $ARCHIVE_SEVENZ_ACTION=a

:: SWTICHES
::	(most common)
:: --	(stop switch parsing) i.e r -t7z -mx5 -ms=on --
:: -r	(Recurse subdirectories)
:: -t	(Archive type) {tzip, t7z, tiso, tudf}
:: -m	(Compression methods)
::		{mx= <0 (copy mode) | 1 (Fastest) | 3 (Fast) | 5 (Normal) | 7 (Maximum) | 9 (Ultra) }	--sets level of compression
::			Compression Method Parameters for 7z <t7z>
::				{mt= on | off}	sets multithreading mode
::				{mtc= on | off}	Stores NTFS timestamps for files: Modification time, Creation time, Last access time.
::				{mtm= on | off} Stores last Modified timestamps for files.
::				{mtc= on | off} Stores Creation timestamps for files.
::				{mta= on | off} Stores last Access timestamps for files.
::				{mtr= on | off} Stores file attributes.
::				{ms= on | off} Sets solid mode. Only used with 7z compression method <-t7z> Cannot update solid archives!

:: used when degugging
SET "ARCHIVE_SEVENZ_SWTICH_STRING=-r -t7z -mx1 -mtm=on -mtc=on -mta=on -mtr=on -ms=on"

:: SET ARCHIVE_SEVENZ_SWTICH_STRING=-r -t7z -mx5 -mtm=on -mtc=on -mta=on -mtr=on -ms=on


:: Logging
::	DEFAULT
:: ARCHIVE_LOG_LOCATION=%USERPROFILE%\Documents
:: ARCHIVE_LOG_FILE=%$SCRIPT_NAME%_%SCRIPT_VERSION%_%COMPUTERNAME%.log
SET ARCHIVE_LOG_LOCATION=%USERPROFILE%\Documents
SET ARCHIVE_LOG_FILE=%$SCRIPT_NAME%_%SCRIPT_VERSION%_%COMPUTERNAME%.log


::###########################################################################::
::            *******************
::            Advanced Settings 
::            *******************
::###########################################################################::

:: Clean up folders after archiving is done
::	{1 (on) | 0 (off)}
SET ARCHIVE_CLEAN_UP=0

:: Files to exclude (Universal)
SET "ARCHIVE_FILE_EXCLUDE=-xr!*.tmp -xr!.DS_STORE -xr!._.DS_STORE -xr!._*"

:: Location for 7z Archiver Configuration File(s)
SET "$7z_ARCHIVER_CONFIG_LOCATION=D:\David_Geeraerts\Projects\Script Code\7z_Archiver"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Configuration File Settings
::   and dependency check for configuration file!
::###########################################################################::
REM This has to be first to check that a configuration file actually exists
:://///////////////////////////////////////////////////////////////////////////
SET $CONFIG_FILE_NAME=%$SCRIPT_NAME%.config
SET $7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN=1.0.0
IF DEFINED $7z_ARCHIVER_CONFIG_LOCATION IF NOT EXIST "%$7z_ARCHIVER_CONFIG_LOCATION%\%$CONFIG_FILE_NAME%" GoTo errCONF ELSE (
	IF NOT EXIST %~dp0\%$CONFIG_FILE_NAME% GoTo errCONF)
:://///////////////////////////////////////////////////////////////////////////

::###########################################################################::
:: CONFIGURATION FILE OVERRIDE
::###########################################################################::

:: START CONFIGURATION FILE LOAD
::	change the directory to where the condiguration file is
IF DEFINED $7z_ARCHIVER_CONFIG_LOCATION CD /D "%$7z_ARCHIVER_CONFIG_LOCATION%"

REM Any configuration variable being pulled from the configuration file that is using another variable
REM  needs to be reset so as not to take the string from the configuration file literally.
REM  This solves the problem when build in variables are used such as %PROGRAMDATA%
REM EXAMPLE: FOR /F %%R IN ('ECHO %VARIABLE%') DO SET VARIABLE=%%R
::  FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"variable" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "variable=%%V"

:: $7z_ARCHIVER_CONFIG_SCHEMA_VERSION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$7z_ARCHIVER_CONFIG_SCHEMA_VERSION" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "$7z_ARCHIVER_CONFIG_SCHEMA_VERSION=%%V"
:: CHECK the Config file Schema version meets the minimum requirement
SET ARCHIVER_CONFIG_FILE_SCHEMA_CHECK=0
::  Parse schema version from configuration file
FOR /F "tokens=1 delims=." %%V IN ("%$7z_ARCHIVER_CONFIG_SCHEMA_VERSION%") DO SET $7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%$7z_ARCHIVER_CONFIG_SCHEMA_VERSION%") DO SET $7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MINOR=%%V
::  Parse schema version from minimum
FOR /F "tokens=1 delims=." %%V IN ("%$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN%") DO SET $7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN%") DO SET $7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN_MINOR=%%V
::  actual check
IF %$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MAJOR% GEQ %$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN_MAJOR% (SET ARCHIVER_CONFIG_FILE_SCHEMA_CHECK=1) ELSE (GoTo err03)
IF %ARCHIVER_CONFIG_FILE_SCHEMA_CHECK% EQU 1 GoTo skipSC
IF %$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MINOR% GEQ %$7z_ARCHIVER_CONFIG_SCHEMA_VERSION_MIN_MINOR% (SET ARCHIVER_CONFIG_FILE_SCHEMA_CHECK=1) ELSE (
     ECHO The configuration file [%$CONFIG_FILE_NAME%] is using an older schema, and doesn't meet the minimum requirement!)
IF %ARCHIVER_CONFIG_FILE_SCHEMA_CHECK% EQU 0 ECHO Minimum MINOR schema version not met. Will proceed anyway!
:skipSC

::	ARCHIVE_NAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ARCHIVE_NAME" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "ARCHIVE_NAME=%%V"
::	ARCHIVE_SOURCE_FOLDER
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ARCHIVE_SOURCE_FOLDER" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "ARCHIVE_SOURCE_FOLDER=%%V"
::	ARCHIVE_BULK_FOLDER
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ARCHIVE_BULK_FOLDER" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "ARCHIVE_BULK_FOLDER=%%V"
::	ARCHIVE_SEVENZ_ACTION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ARCHIVE_SEVENZ_ACTION" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "ARCHIVE_SEVENZ_ACTION=%%V"
::	ARCHIVE_SEVENZ_SWTICH_STRING
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ARCHIVE_SEVENZ_SWTICH_STRING" "%~dp0\%$CONFIG_FILE_NAME%"') DO SET "ARCHIVE_SEVENZ_SWTICH_STRING=%%V"


:: Calculate lapse time by capturing start time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET S_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET S_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET S_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET S_ms=%%h


:: Make sure log path exists, if not create, and use as a test
IF NOT EXIST %ARCHIVE_LOG_LOCATION% MD %ARCHIVE_LOG_LOCATION%
:: Change the working directory just to be safe
CD /D %ARCHIVE_LOG_LOCATION%
:START
ECHO START %DATE% %TIME% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
systeminfo | FIND /I "Time Zone" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
HOSTNAME >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
WHOAMI >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO [DEBUG]	Working directory is now: [%CD%] >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%


:: Make sure the command shell is pathed to the executable
PATH | FIND /I "7-Zip" || PATH=%PATH%;"C:\Program Files\7-Zip"

:SA
::	##### SINGLE ARCHIVER ##### 
IF NOT DEFINED $ARCHIVE_SOURCE_FOLDER GoTo skipSA
:: Change the working directory just to be safe
CD /D %$ARCHIVE_SOURCE_FOLDER%
ECHO Processing Single Archive operation on [%$ARCHIVE_SOURCE_FOLDER%]... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

:: Variable names should not contain numeric character nor any special characters except for "_".
IF DEFINED $ARCHIVE_SOURCE_FOLDER 7z %$ARCHIVE_SEVENZ_ACTION% %ARCHIVE_SEVENZ_SWTICH_STRING% %ARCHIVE_FILE_EXCLUDE% "%$ARCHIVE_NAME%" "%$ARCHIVE_SOURCE_FOLDER%"
SET ARCHIVE_SEVENZ_ERRORLEVEL=%ERRORLEVEL%
ECHO SEVENZ_ERRORLEVEL: %ARCHIVE_SEVENZ_ERRORLEVEL% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 0 ECHO 7z reported no errors! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 1 ECHO 7z Warning Non fatal errors. For example, one or more files were locked by some other application, so they were not compressed. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 2 ECHO 7z Fatal error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 7 ECHO 7z Command line error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 8 ECHO 7z Not enough memory for operation! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 255 ECHO 7z reported that User stopped the process! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

IF %ARCHIVE_CLEAN_UP% EQU 1 IF EXIST %$ARCHIVE_SOURCE_FOLDER% RD /S /Q "%$ARCHIVE_SOURCE_FOLDER%"

:: Create SHA256 hash
IF EXIST %$ARCHIVE_NAME% 7z h -scrcsha256 "%$ARCHIVE_NAME%" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
SET ARCHIVE_SEVENZ_SHA_ERRORLEVEL=%ERRORLEVEL%
ECHO ARCHIVE_SEVENZ_SHA_ERRORLEVEL: %ARCHIVE_SEVENZ_SHA_ERRORLEVEL% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 0 ECHO 7z reported no errors! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 1 ECHO 7z Warning Non fatal errors. For example, one or more files were locked by some other application, so they were not compressed. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 2 ECHO 7z Fatal error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 7 ECHO 7z Command line error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 8 ECHO 7z Not enough memory for operation! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 255 ECHO 7z reported that User stopped the process! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

:skipSA


::	##### BULK ARCHIVE PROCESS ##### 
IF NOT DEFINED $ARCHIVE_BULK_FOLDER GoTo skipBA
:: Change the working directory just to be safe
CD /D %$ARCHIVE_BULK_FOLDER%
ECHO Processing Bulk Archive operation on [%$ARCHIVE_BULK_FOLDER%]... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

IF DEFINED $ARCHIVE_BULK_FOLDER GoTo BA ELSE (GoTo skipBA)
:BA
:: NOTES
::	When trying to catch the %ERRORLEVEL% from 7z and set the error level for 7z as ARCHIVE_BULK_CODE, it wouldn't set if 7z was configured output to file i.e. ">>"
::	...this is a workaround to the problem 

FOR /F %%Z IN ('DIR /B /A:D "%$ARCHIVE_BULK_FOLDER%"') DO (7z %$ARCHIVE_SEVENZ_ACTION% %ARCHIVE_SEVENZ_SWTICH_STRING% %ARCHIVE_FILE_EXCLUDE% "%$ARCHIVE_BULK_FOLDER%\%%Z" "%$ARCHIVE_BULK_FOLDER%\%%Z" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%) & ((ECHO %ERRORLEVEL%)> %ARCHIVE_LOG_LOCATION%\var_ARCHIVER_BULK_CODE_%%Z.txt) & (IF EXIST "%$ARCHIVE_BULK_FOLDER%\%%Z" 7z h -scrcsha256 "%$ARCHIVE_BULK_FOLDER%\%%Z" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%)
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO Checking to see if source folders should be deleted up... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO ARCHIVE_CLEAN_UP is set to: %ARCHIVE_CLEAN_UP% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
FOR /F %%K IN ('DIR /B /A:D "%$ARCHIVE_BULK_FOLDER%"') Do (TYPE %ARCHIVE_LOG_LOCATION%\var_ARCHIVER_BULK_CODE_%%K.txt | FIND "0") && (IF %ARCHIVE_CLEAN_UP% EQU 1 IF EXIST "%$ARCHIVE_BULK_FOLDER%\%%K" RD /S /Q "%$ARCHIVE_BULK_FOLDER%\%%K") & (ECHO %%K ARCHIVER_BULK_CODE is 0 >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%)
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
DIR /B /A:D %$ARCHIVE_BULK_FOLDER% | FINDSTR /I /R [A-Z,0-9] || ECHO [DEBUG]	All the source folders have been deleted! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
DIR /B /A:D %$ARCHIVE_BULK_FOLDER% | FINDSTR /I /R [A-Z,0-9] && ECHO [DEBUG]	Not all the source folders are deleted! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

:: Cleanup the var_ files
DEL /Q %ARCHIVE_LOG_LOCATION%\var_*.txt
DIR /B %ARCHIVE_LOG_LOCATION% | FIND /I "var_" || ECHO [DEBUG]	All the "var_" files have been deleted! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
DIR /B %ARCHIVE_LOG_LOCATION% | FIND /I "var_" && ECHO [DEBUG]	NOT all "var_" files have been deleted! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

:skipBA

GoTo Time
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                    START ERROR SECTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 00's (DEPENDENCY ERROR)

:errCONF
:: ERROR CONF is a FATAL ERROR for NO configuration file
Color 4E
ECHO %TIME% [FATAL]	FATAL ERROR! NO CONFIGURATION FILE [.\%CONFIG_FILE_NAME%] FOUND! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO FATAL ERROR! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO NO CONFIGURATION FILE WAS FOUND! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
TIMEOUT 60
EXIT 

:err03
:: ERROR 03 (Configuration file schema doesn't meet minimum version)
CLS
Color 4E
ECHO %TIME% [FATAL]	FATAL ERROR! CONFIGURATION FILE [.\%$CONFIG_FILE_NAME%] SCHEMA DOESN'T MEET MINIMUM VERSION! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO FATAL ERROR! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO CONFIGURATION FILE SCHEMA DOESN'T MEET MINIMUM VERSION! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
TIMEOUT 60
EXIT 







:://///////////////////////////////////////////////////////////////////////////



:Time
:: Calculate lapse time by capturing end time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET E_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET E_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET E_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET E_ms=%%h

:: Calculate the actual lapse time
IF %E_hh% GEQ %S_hh% (SET /A "L_hh=%E_hh%-%S_hh%") ELSE (SET /A "L_hh=%S_hh%-%E_hh%")
IF %E_mm% GEQ %S_mm% (SET /A "L_mm=%E_mm%-%S_mm%") ELSE (SET /A "L_mm=%S_mm%-%E_mm%")
IF %E_ss% GEQ %S_ss% (SET /A "L_ss=%E_ss%-%S_ss%") ELSE (SET /A "L_ss=%S_ss%-%E_ss%")
IF %E_ms% GEQ %S_ms% (SET /A "L_ms=%E_ms%-%S_ms%") ELSE (SET /A "L_ms=%S_ms%-%E_ms%")
:: turn hours into minutes and add to total minutes
IF %L_hh% GTR 0 SET /A "L_hhh=%L_hh%*60"
IF %L_hh% EQU 0 SET L_hhh=0
IF %L_hhh% GTR 0 SET /A "L_tm=%L_hhh%+%L_mm%"
IF %L_hhh% EQU 0 SET L_tm=%L_mm%
:: Lapse Time
ECHO Time Lapsed (mm:ss.ms): %L_tm%:%L_ss%.%L_ms% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%


:EOF
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO END %DATE% %TIME% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
Exit
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::