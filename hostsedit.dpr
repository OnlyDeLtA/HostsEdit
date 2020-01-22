program hostsedit;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, Winapi.Windows;

var
  host: string;
  attrib: Integer;
function GetConsoleWindow: HWND; stdcall; external kernel32;

function CheckStr(str: string; sites: array of string): Boolean;
var
  I: Integer;
begin
  for I := Low(sites) to High(sites) do
    if str = sites[I] then
      Exit(False);
  Exit(True);
end;

procedure Add(site: String);
var
  edit: TextFile;
  hsites: array of string;
  I: Integer;
begin
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Inc(I, 1);
    SetLength(hsites, I);
    readln(edit, hsites[I - 1]);
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Append(edit);
  if CheckStr(site, hsites) then
    Writeln(edit, site);
  CloseFile(edit);
end;

procedure Remove(site: string);
var
  hsites: array of string;
  edit: TextFile;
  I: Integer;
begin
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Inc(I, 1);
    SetLength(hsites, I);
    readln(edit, hsites[I - 1]);
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Rewrite(edit);
  for I := Low(hsites) to High(hsites) do
    if hsites[I] <> site then
      Writeln(edit, hsites[I]);
  CloseFile(edit);
end;

procedure AddFromText(lhost: String);
var
  txtfile: TextFile;
  edit: TextFile;
  sites: array of string;
  hsites: array of String;
  I: Integer;
begin
  I := 0;
  AssignFile(txtfile, lhost);
  Reset(txtfile);
  while not Eof(txtfile) do
  begin
    Inc(I, 1);
    SetLength(sites, I);
    readln(txtfile, sites[I - 1]);
  end;
  CloseFile(txtfile);
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Inc(I, 1);
    SetLength(hsites, I);
    readln(edit, hsites[I - 1]);
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Append(edit);
  for I := Low(sites) to High(sites) do
    if CheckStr(sites[I], hsites) then
      Writeln(edit, sites[I]);
  CloseFile(edit);
end;

procedure RemoveFromText(lhost: String);
var
  sites: array of string;
  hsites: array of string;
  edit: TextFile;
  txtfile: TextFile;
  I: Integer;
begin
  I := 0;
  AssignFile(txtfile, lhost);
  Reset(txtfile);
  while not Eof(txtfile) do
  begin
    Inc(I, 1);
    SetLength(sites, I);
    readln(txtfile, sites[I - 1]);
  end;
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Inc(I, 1);
    SetLength(hsites, I);
    readln(edit, hsites[I - 1]);
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Rewrite(edit);
  for I := Low(hsites) to High(hsites) do
    if CheckStr(hsites[I], sites) then
      Writeln(edit, hsites[I]);
  CloseFile(edit);
end;

procedure Backup(loc: String);
var
  hsites: array of string;
  edit: TextFile;
  I: Integer;
begin
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Inc(I, 1);
    SetLength(hsites, I);
    readln(edit, hsites[I - 1]);
  end;

  CloseFile(edit);
  if not DirectoryExists(ExtractFileDir(loc)) then
    CreateDir(ExtractFileDir(loc));

  AssignFile(edit, loc);
  Rewrite(edit);
  for I := Low(hsites) to High(hsites) do
    Writeln(edit, hsites[I]);
  CloseFile(edit);
end;

procedure Restore(loc: String = '');
var
  edit: TextFile;
  sites: array of string;
  I: Integer;
begin
  if loc = '' then
  begin
    AssignFile(edit, host);
    Rewrite(edit);
    Writeln(edit, '# Copyright (c) 1993-2009 Microsoft Corp.');
    Writeln(edit, '#');
    Writeln(edit,
      '# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.');
    Writeln(edit, '#');
    Writeln(edit,
      '# This file contains the mappings of IP addresses to host names. Each');
    Writeln(edit,
      '# entry should be kept on an individual line. The IP address should');
    Writeln(edit,
      '# be placed in the first column followed by the corresponding host name.');
    Writeln(edit,
      '# The IP address and the host name should be separated by at least one');
    Writeln(edit, '# space.');
    Writeln(edit, '#');
    Writeln(edit,
      '# Additionally, comments (such as these) may be inserted on individual');
    Writeln(edit,
      '# lines or following the machine name denoted by a ''#'' symbol.');
    Writeln(edit, '#');
    Writeln(edit, '# For example:');
    Writeln(edit, '#');
    Writeln(edit,
      '#      102.54.94.97     rhino.acme.com          # source server');
    Writeln(edit,
      '#       38.25.63.10     x.acme.com              # x client host');
    Writeln(edit, '');
    Writeln(edit, '# localhost name resolution is handled within DNS itself.');
    Writeln(edit, '#	127.0.0.1       localhost');
    Writeln(edit, '#	::1             localhost');
    CloseFile(edit);
  end
  else
  begin
    I := 0;
    AssignFile(edit, loc);
    Reset(edit);
    while not Eof(edit) do
    begin
      Inc(I, 1);
      SetLength(sites, I);
      readln(edit, sites[I - 1]);
    end;
    CloseFile(edit);

    AssignFile(edit, host);
    Rewrite(edit);
    for I := Low(sites) to High(sites) do
      Writeln(edit, sites[I]);
    CloseFile(edit);
  end;
end;

procedure SetAttrib(attrib: String);
begin
  if attrib = 'r' then
    FileSetAttr(host, faReadOnly);
  if (attrib = 'ra') or (attrib = 'ar') then
    FileSetAttr(host, faReadOnly or faArchive);
  if attrib = 'a' then
    FileSetAttr(host, faArchive);
end;

begin
  try
    SetConsoleTitle('hostsedit 1.2');
    host := GetEnvironmentVariable('WINDIR') + '\System32\drivers\etc\hosts';
    if ParamStr(1) = '/a' then
    begin
      ShowWindow(GetConsoleWindow, SW_HIDE);
      attrib := FileGetAttr(host);
      FileSetAttr(host, faArchive);
      Add(ParamStr(2) + ' ' + ParamStr(3));
      FileSetAttr(host, attrib);
      Exit;
    end;
    if ParamStr(1) = '/r' then
    begin
      attrib := FileGetAttr(host);
      FileSetAttr(host, faArchive);
      ShowWindow(GetConsoleWindow, SW_HIDE);
      Remove(ParamStr(2) + ' ' + ParamStr(3));
      FileSetAttr(host, attrib);
      Exit;
    end;
    if ParamStr(1) = '/am' then
    begin
      attrib := FileGetAttr(host);
      FileSetAttr(host, faArchive);
      ShowWindow(GetConsoleWindow, SW_HIDE);
      AddFromText(ParamStr(2));
      FileSetAttr(host, attrib);
      Exit;
    end;
    if ParamStr(1) = '/rm' then
    begin
      attrib := FileGetAttr(host);
      FileSetAttr(host, faArchive);
      ShowWindow(GetConsoleWindow, SW_HIDE);
      RemoveFromText(ParamStr(2));
      FileSetAttr(host, attrib);
      Exit;
    end;
    if ParamStr(1) = '/b' then
    begin
      ShowWindow(GetConsoleWindow, SW_HIDE);
      Backup(ParamStr(2));
      Exit;
    end;
    if ParamStr(1) = '/res' then
    begin
      FileSetAttr(host, faArchive);
      ShowWindow(GetConsoleWindow, SW_HIDE);
      if ParamCount > 1 then
        Restore(ParamStr(2))
      else
        Restore;
      Exit;
    end;
    if ParamStr(1) = '/attr' then
    begin
      SetAttrib(ParamStr(2));
      Exit;
    end;

    Writeln('Command line utility for editing HOSTS file.');
    Writeln('Freeware');
    Writeln('');
    Writeln('Usage :');
    Writeln('');
    Writeln('  /a     : Add single entry.');
    Writeln('  /r     : Remove single entry.');
    Writeln('  /am    : Add multiple entries, reading from text file.');
    Writeln('  /rm    : Remove multiple entries, reading from text file.');
    Writeln('  /b     : Create backup of HOSTS file.');
    Writeln('  /res   : Restore HOSTS file to Windows default, or to a previous backup.');
    Writeln('  /attr  : Set attributes for HOSTS file, ReadOnly(/attr r), Archive(/attr a), Both(/attr ra).');
    Writeln('');
    Writeln('Samples :');
    Writeln('');
    Writeln('  hostsedit /a 0.0.0.0 wwww.example-domain.com');
    Writeln('  hostsedit /r 0.0.0.0 wwww.example-domain.com ');
    Writeln('  hostsedit /am "D:\HOSTS Entries\example.txt"');
    Writeln('  hostsedit /rm "D:\HOSTS Entries\example.txt"');
    Writeln('  hostsedit /b "D:\HOSTS.BKP"');
    Writeln('  hostsedit /res');
    Writeln('  hostsedit /res "D:\HOSTS.BKP"');
    Writeln('  hostsedit /attr r');
    Writeln('');
    Writeln('');
    Writeln('Press any key to continue . . .');
    readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
