# HostsEdit

<img align="center" src="https://i.imgur.com/yW6WR9S.png">

HostEdit is a command line utility for editing Windows HOSTS file. it can be used to edit(add/remove) single or multiple entries in hosts file. it also has some additional features as creating hosts backup, restoring it to Windows default, and changing attributes of hosts file. HostEdit is written in Delphi, Compiled using Embarcadero's Delphi 10.3.3.

<b>Features:</b>

```
  1. Add/Remove single entry in HOSTS file.
  2. Add/Remove multiple entries in HOSTS file, reading from text file.
  3. Create backup of HOSTS file.
  4. Restore HOSTS file to windows default.
  5. Change attributes of HOSTS file.
```
<b>Usage :</b>
```
  /a     : Add single entry.
  /r     : Remove single entry.
  /am    : Add multiple entries, reading from text file.
  /rm    : Remove multiple entries, reading from text file.
  /b     : Create backup of HOSTS file.
  /res   : Restore HOSTS file to Windows default.
  /attr  : Set attributes for HOSTS file, ReadOnly(/attr r), Archive(/attr a), Both(/attr ra).
```
<b>Samples :</b>
```
  hostsedit /a 0.0.0.0 wwww.example-domain.com
  hostsedit /r 0.0.0.0 wwww.example-domain.com
  hostsedit /am "D:\HOSTS Entries\example.txt"
  hostsedit /rm "D:\HOSTS Entries\example.txt"
  hostsedit /b "D:\HOSTS.BKP"
  hostsedit /res
  hostsedit /attr r
```
<b>Sample Text file for editing(add/remove) multiple entries :</b>
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




<b>Download[v1.0] :</b> <a href="https://github.com/OnlyDeLtA/HostsEdit/files/4086261/hostsedit.zip">Click Here.</a>



