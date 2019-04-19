# 7z_Archiver
---
A Windows based commandlet wrapper for 7z commandline.

Primarily tested with Windows 10.
(Might work with Windows 7 x64)


## **DESCRIPTION**
---
SCRIPT STYLE: Intelligent Wrapper (for 7-Zip Archiver)

The purpose of this script/commandlet is to intelligently process
a folder directory to be archived compressed using 7-Zip.
Process a single archive or multiple archives.
Minimally developed for console output. Primarily developed for log output.

## Features
---
- Perfect as a scheduled task
- Perfect for running in the windows commandshell

## Latest Version
---
- 3.0.0

## How To Configure
---
Fill out the configuration file

1. `ARCHIVE_NAME` Used for single archive to give a name and location for the archive.
2. `ARCHIVE_SOURCE_FOLDER` What Single folder to archive.
3. `ARCHIVE_BULK_FOLDER` What bulk folder to archive; will process all the sub-directories in the given folder.
4. `ARCHIVE_BULK_HASH` Calculate [SHA256] hash (or not).
5. `ARCHIVE_BULK_SHIPPING` If bulk archive is configured, should the archive files be shipped somewhere --Yes or No.
6. `ARCHIVE_BULK_DESTINATION` If bulk shipping, where to send.
7. `ARCHIVE_ACTION` Corresponds to the <command> of 7z, i.e. what to do. Default is **a** *for add files to archive*
8. `ARCHIVE_SWITCH_STRING` Corresponds to <switches> for 7z.
9. `LOG_LOCATION` Location for log file.
10. `LOG_FILE` leave blank to accept default or use a custom name.
11. `LOG_SHIPPING_LOCATION` the log file can be shipped to a specified location.
12. `ARCHIVE_CLEAN_UP` If the archiver should delete the folder(s) after archive is complete.
13. `ARCHIVE_FILE_EXCLUDE` Can add to list if needed.
14. `LOG_LEVEL_*` Control the log output.
15. `DEBUGGER_PC` configure hostname of a machine running the archiver if debugging is needed. Mostly used for development.
16. `VAR_CLEANUP` Cleanup var folder? Yes <1> or No <0>


- Don't change `ARCHIVER_CONFIG_SCHEMA_VERSION`

### Author
---
David Geeraerts

Location:	Olympia, Washington USA

dgeeraerts.evergreen@gmail.com


### License
---
Copyleft License(s)
GNU GPL (General Public License)
https://www.gnu.org/licenses/gpl-3.0.en.html