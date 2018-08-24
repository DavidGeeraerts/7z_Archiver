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
SET SCRIPT_NAME=7z_Archiver
SET SCRIPT_VERSION=1.5.0
Title %SCRIPT_NAME% Version: %SCRIPT_VERSION%
Prompt 7z$G
color 8A
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: DO NOT SURROND THE PATH WITH DOUBLE QUOTES

:: SET ARCHIVE_NAME=%USERPROFILE%\Documents\Sample_Archive
:: SET ARCHIVE_SOURCE_FOLDER=%USERPROFILE%\Documents

:: One Off Archive
::	ARCHIVE_NAME: What to nake the archive
::	i.e. D:\Mounts\Archives\research\research
::		...the name will automatically be appended with the compression method: <ARCHIVE_NAME>.7z
SET ARCHIVE_NAME=
::	ARCHIVE_SOURCE_FOLDER: What to archive (folder)
SET ARCHIVE_SOURCE_FOLDER=
:: Bulk folder archive
::	Will automatically create the compressed archive files in the same folder
SET ARCHIVE_BULK_FOLDER=

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
SET ARCHIVE_SEVENZ_ACTION=a

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
:: SET "ARCHIVE_SEVENZ_SWTICH_STRING=-r -t7z -mx1 -mtm=on -mtc=on -mta=on -mtr=on -ms=on"

SET ARCHIVE_SEVENZ_SWTICH_STRING=-r -t7z -mx5 -mtm=on -mtc=on -mta=on -mtr=on -ms=on


:: Logging
::	DEFAULT
:: ARCHIVE_LOG_LOCATION=%USERPROFILE%\Documents
:: ARCHIVE_LOG_FILE=%SCRIPT_NAME%_%SCRIPT_VERSION%_%COMPUTERNAME%.log

SET ARCHIVE_LOG_LOCATION=%USERPROFILE%\Documents
SET ARCHIVE_LOG_FILE=%SCRIPT_NAME%_%SCRIPT_VERSION%_%COMPUTERNAME%.log



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


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ECHO START %DATE% %TIME% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
HOSTNAME >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
WHOAMI >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
:: Make sure the command shell is pathed to the executable
PATH | FIND /I "7-Zip" || PATH=%PATH%;"C:\Program Files\7-Zip"

::	##### SINGLE ARCHIVER ##### 
IF NOT DEFINED ARCHIVE_SOURCE_FOLDER GoTo skipSA

ECHO Processing Single Archive operation on [%ARCHIVE_SOURCE_FOLDER%]... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

:: Variable names should not contain numeric character nor any special characters except for "_".
IF DEFINED ARCHIVE_SOURCE_FOLDER 7z %SEVENZ_ACTION% %SEVENZ_SWTICH_STRING% %ARCHIVE_FILE_EXCLUDE% "%ARCHIVE_NAME%" "%ARCHIVE_SOURCE_FOLDER%"

SET ARCHIVE_SEVENZ_ERRORLEVEL=%ERRORLEVEL%
ECHO SEVENZ_ERRORLEVEL: %ARCHIVE_SEVENZ_ERRORLEVEL% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 0 ECHO 7z reported no errors! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 1 ECHO 7z Warning Non fatal errors. For example, one or more files were locked by some other application, so they were not compressed. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 2 ECHO 7z Fatal error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 7 ECHO 7z Command line error! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 8 ECHO 7z Not enough memory for operation! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
IF %ARCHIVE_SEVENZ_ERRORLEVEL% EQU 255 ECHO 7z reported that User stopped the process! >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

IF %ARCHIVE_CLEAN_UP% EQU 1 IF EXIST %ARCHIVE_SOURCE_FOLDER% RD /S /Q "%ARCHIVE_SOURCE_FOLDER%"

:: Create SHA256 hash
IF EXIST %ARCHIVE_NAME% 7z h -scrcsha256 "%ARCHIVE_NAME%" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
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
IF NOT DEFINED ARCHIVE_BULK_FOLDER GoTo skipBA
ECHO Processing Bulk Archive operation on [%ARCHIVE_BULK_FOLDER%]... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

IF DEFINED ARCHIVE_BULK_FOLDER GoTo BA ELSE (GoTo skipBA)
:BA
:: NOTES
::	When trying to catch the %ERRORLEVEL% from 7z and set the error level for 7z as ARCHIVE_BULK_CODE, it wouldn't set if 7z was configured output to file i.e. ">>"
::	...this is a workaround to the problem 

FOR /F %%Z IN ('DIR /B /A:D "%ARCHIVE_BULK_FOLDER%"') DO (7z %ARCHIVE_SEVENZ_ACTION% %ARCHIVE_SEVENZ_SWTICH_STRING% %ARCHIVE_FILE_EXCLUDE% "%ARCHIVE_BULK_FOLDER%\%%Z" "%ARCHIVE_BULK_FOLDER%\%%Z" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%) & ((ECHO %ERRORLEVEL%)> %ARCHIVE_LOG_LOCATION%\var_ARCHIVER_BULK_CODE_%%Z.txt) & (IF EXIST "%ARCHIVE_BULK_FOLDER%\%%Z" 7z h -scrcsha256 "%ARCHIVE_BULK_FOLDER%\%%Z" >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%)

ECHO Checking to see if source folders should be deleted up... >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO ARCHIVE_CLEAN_UP is set to: %ARCHIVE_CLEAN_UP% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%

FOR /F %%K IN ('DIR /B /A:D "%ARCHIVE_BULK_FOLDER%"') Do (TYPE %ARCHIVE_LOG_LOCATION%\var_ARCHIVER_BULK_CODE_%%K.txt | FIND "0") && (IF %ARCHIVE_CLEAN_UP% EQU 1 IF EXIST "%ARCHIVE_BULK_FOLDER%\%%K" RD /S /Q "%ARCHIVE_BULK_FOLDER%\%%K") & (ECHO %%K ARCHIVER_BULK_CODE is 0 >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%)
:: Cleanup the var_ files
DEL /Q %ARCHIVE_LOG_LOCATION%\var_*.txt

:skipBA

:EOF
ECHO END %DATE% %TIME% >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
ECHO. >> %ARCHIVE_LOG_LOCATION%\%ARCHIVE_LOG_FILE%
Exit