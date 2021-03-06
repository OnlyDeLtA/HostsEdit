
  
# HostsEdit

<img align="center" src="https://i.imgur.com/yW6WR9S.png">

HostsEdit is a command-line utility for editing Windows HOSTS file. it can be used to edit(add/remove) single or multiple entries in hosts file. it also has some additional features as creating hosts file backup, restoring hosts file to Windows default or to a previous backup, changing attributes of hosts file, replacing IPs in hosts file and flushing Windows DNS cache. HostsEdit is written in Delphi, Compiled using [Embarcadero's Delphi 10.3.3 CE](https://www.embarcadero.com/products/delphi/starter/free-download).

## Features

 - Add/Remove single entry in HOSTS file.
 - Add/Remove multiple entries in HOSTS file, reading from text file.
 - Create a backup of HOSTS file.
 - Restore HOSTS file to windows default, or to a previous backup.
 - Change attributes of HOSTS file.
 - Replace IPs in HOSTS file.
 - Supports both IPv4 & IPv6 Entries.
 - Flush Windows DNS cache.
 - Supports third party HOSTS files like [MVPS](http://winhelp2002.mvps.org/hosts.htm).

## Usage
```
  /a     : Add single entry.
  /r     : Remove single entry.
  /am    : Add multiple entries, reading from text file.
  /rm    : Remove multiple entries, reading from text file.
  /b     : Create backup of HOSTS file.
  /fdns  : Flush Windows DNS Cache.
  /rip   : Replace IPs in HOSTS file.
  /res   : Restore HOSTS file to Windows default, or to a previous backup.
  /attr  : Set attributes for HOSTS file, ReadOnly(/attr r), Archive(/attr a), Both(/attr ra).
```
## Samples
```
  hostsedit /a 0.0.0.0 www.example-domain.com
  hostsedit /r www.example-domain.com
  hostsedit /am "D:\HOSTS Entries\example.txt"
  hostsedit /rm "D:\HOSTS Entries\example.txt"
  hostsedit /b "D:\HOSTS.BKP"
  hostsedit /fdns
  hostsedit /rip 0.0.0.0 127.0.0.1
  hostsedit /res
  hostsedit /res "D:\HOSTS.BKP"
  hostsedit /attr r
```
### Sample Text file for editing(adding/removing) multiple entries
```
#entries suitable for both adding/removing.
0.0.0.0 c3.zedo.com
0.0.0.0 c4.zedo.com
0.0.0.0 c5.zedo.com
0.0.0.0 c6.zedo.com
#entries suitable for removing alone.
c7.zedo.com
c8.zedo.com
```
### Using HostsEdit with Command Prompt
```
Run CMD as Administrator(Important to receive execution results from hostsedit back to CMD),
using 'cd' command change working directory to where hostsedit.exe is placed,
now write commands as Shown in the Samples.
```
```
Microsoft Windows [Version 10.0.14393]
(c) 2016 Microsoft Corporation. All rights reserved.

C:\Windows\system32>hostsedit /a 0.0.0.0 www.example-domain.com
Adding entry to HOSTS file...
Done.

C:\Windows\system32>hostsedit /r www.example-domain.com
Removing entry from HOSTS file...
Done.

```
### Using HostsEdit with Inno Setup
```
//Edit Single Entry:

[Run]
Filename: "{app}\hostsedit.exe"; Parameters: "/a 0.0.0.0 www.google.com"; Flags: runhidden;
[UninstallRun]
Filename: "{app}\hostsedit.exe"; Parameters: "/r www.google.com"; Flags: runhidden;

//Edit Multiple Entries:

[Run]
Filename: "{app}\hostsedit.exe"; Parameters: "/am ""{app}\test.txt"""; Flags: runhidden;
[UninstallRun]
Filename: "{app}\hostsedit.exe"; Parameters: "/rm ""{app}\test.txt"""; Flags: runhidden;
```
<p align="center">
<img src="https://i.imgur.com/I4106HR.png">
</p>

## Download 
 * [Download Latest Version](https://github.com/OnlyDeLtA/HostsEdit/releases/tag/2.2)
 * [Download Older Versions](https://github.com/OnlyDeLtA/HostsEdit/releases)
 
  *For Windows XP, Vista, 7, 8, 8.1, 10 (32\64-bit)*