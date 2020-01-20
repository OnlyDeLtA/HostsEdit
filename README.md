# HostsEdit

<img align="center" src="https://i.imgur.com/yW6WR9S.png">

HostEdit is a command line utility for editing Windows HOSTS file. it can edit(add/remove) single entry in host file. HostEdit also supports
adding/removing mutiple hosts file entries reading from text file. HostEdit is written in Delphi, Compiled using Embarcadero's Delphi 10.3.

Features:

```
  1. Add/Remove single entry in HOSTS file.
  2. Add/Remove multiple entries in HOSTS file, reading from text file.
  3. Create backup of HOSTS file.
  4. Restore HOSTS file to windows default.
  5. Change attributes of HOSTS file.
```
Usage :
```
  /a     : Add single entry.
  /r     : Remove single entry.
  /am    : Add multiple entries, reading from text file.
  /rm    : Remove multiple entries, reading from text file.
  /b     : Create backup of HOSTS file.
  /res   : Restore HOSTS file to Windows default.
  /attr  : Set attributes for HOSTS file, ReadOnly(/attr r), Archive(/attr a), Both(/attr ra).
```
Samples :
```
  hostsedit /a 0.0.0.0 wwww.example-domain.com
  hostsedit /r 0.0.0.0 wwww.example-domain.com
  hostsedit /am "D:\HOSTS Entries\example.txt"
  hostsedit /rm "D:\HOSTS Entries\example.txt"
  hostsedit /b "D:\HOSTS.BKP"
  hostsedit /res
  hostsedit /attr r
```
Sample Text file for editing(add/remove) multiple entries :
```
0.0.0.0 c3.zedo.com
0.0.0.0 c4.zedo.com
0.0.0.0 c5.zedo.com
0.0.0.0 c6.zedo.com
0.0.0.0 c7.zedo.com
0.0.0.0 c8.zedo.com
0.0.0.0 d2.zedo.com
0.0.0.0 d3.zedo.com
0.0.0.0 d7.zedo.com
0.0.0.0 d8.zedo.com
0.0.0.0 g.zedo.com
0.0.0.0 gw.zedo.com
```

<img align="center" src="https://i.imgur.com/341Kqaw.png">




Download[v1.0] : <a href="https://github.com/OnlyDeLtA/HostsEdit/files/4086261/hostsedit.zip">Click Here.</a>



