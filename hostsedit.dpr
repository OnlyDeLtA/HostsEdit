program hostsedit;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, Winapi.Windows, System.StrUtils, System.RegularExpressions;

var
  host: string;
  attrib: Integer;
  RegularExpression: TRegEx;
  Match: TMatch;
  regex1: string = '^\h*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+[^#\s]*';
  regex2: string = '^\h+';
  regex3: string = '(?<=.) +(?<=.)';

function CheckStr(str: string; sites: array of string): Boolean;
var
  I: Integer;
begin
  for I := Low(sites) to High(sites) do
    if CompareText(sites[I], str) = 0 then
      Exit(False);
  Exit(True);
end;

function NewLines: Integer;
var
  txt: TextFile;
  chr: Char;
  n: Integer;
begin
  n := 0;
  AssignFile(txt, host);
  Reset(txt);
  while not Eof(txt) do
  begin
    read(txt, chr);
    if chr = #13 then
      inc(n, 1);
  end;
  CloseFile(txt);
  Result := n;
end;

procedure Add(site: String);
var
  edit: TextFile;
  hsites: array of string;
  I, L, n: Integer;
  str: string;
begin
  RegularExpression.Create(regex1);
  I := 0;
  L := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    inc(L, 1);
    Readln(edit, str);
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      str := Match.Value;
      SetLength(hsites, I);
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      hsites[I - 1] := str;
    end;
  end;
  CloseFile(edit);
  n := NewLines;
  AssignFile(edit, host);
  Append(edit);
  if n <> L then
    Writeln(edit);
  if CheckStr(site, hsites) then
    Writeln(edit, site);
  CloseFile(edit);
end;

procedure Remove(site: string);
var
  hsites, osites: array of string;
  edit: TextFile;
  I: Integer;
  str: string;
begin
  RegularExpression.Create(regex1);
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Readln(edit, str);
    Match := RegularExpression.Match(str);
    inc(I, 1);
    SetLength(hsites, I);
    SetLength(osites, I);
    osites[I - 1] := str;
    if Match.Success then
    begin
      str := Match.Value;
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      hsites[I - 1] := str;
      Continue;
    end;
    hsites[I - 1] := str;
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Rewrite(edit);
  for I := Low(hsites) to High(hsites) do
    if CompareText(hsites[I], site) <> 0 then
      Writeln(edit, osites[I]);
  CloseFile(edit);
end;

procedure AddFromText(lhost: String);
var
  txtfile, edit: TextFile;
  sites, hsites: array of string;
  str: string;
  I, L, n: Integer;
begin
  RegularExpression.Create(regex1);
  I := 0;
  L := 0;
  AssignFile(txtfile, lhost);
  Reset(txtfile);
  while not Eof(txtfile) do
  begin
    Readln(txtfile, str);
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      SetLength(sites, I);
      str := Match.Value;
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      sites[I - 1] := str;
    end;
  end;
  CloseFile(txtfile);
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    inc(L, 1);
    Readln(edit, str);
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      SetLength(hsites, I);
      str := Match.Value;
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      hsites[I - 1] := str;
    end;
  end;
  CloseFile(edit);
  n := NewLines;
  AssignFile(edit, host);
  Append(edit);
  if n <> L then
    Writeln(edit);
  for I := Low(sites) to High(sites) do
    if CheckStr(sites[I], hsites) then
      Writeln(edit, sites[I]);
  CloseFile(edit);
end;

procedure RemoveFromText(lhost: String);
var
  sites, hsites, osites: array of string;
  txtfile, edit: TextFile;
  str: string;
  I: Integer;
begin
  RegularExpression.Create(regex1);
  I := 0;
  AssignFile(txtfile, lhost);
  Reset(txtfile);
  while not Eof(txtfile) do
  begin
    Readln(txtfile, str);
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      SetLength(sites, I);
      str := Match.Value;
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      sites[I - 1] := str;
    end;
  end;
  I := 0;
  AssignFile(edit, host);
  Reset(edit);
  while not Eof(edit) do
  begin
    Readln(edit, str);
    Match := RegularExpression.Match(str);
    inc(I, 1);
    SetLength(hsites, I);
    SetLength(osites, I);
    osites[I - 1] := str;
    if Match.Success then
    begin
      str := Match.Value;
      str := TRegEx.Replace(str, regex2, '');
      str := TRegEx.Replace(str, regex3, ' ');
      hsites[I - 1] := str;
      Continue;
    end;
    hsites[I - 1] := str;
  end;
  CloseFile(edit);
  AssignFile(edit, host);
  Rewrite(edit);
  for I := Low(hsites) to High(hsites) do
    if CheckStr(hsites[I], sites) then
      Writeln(edit, osites[I]);
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
    inc(I, 1);
    SetLength(hsites, I);
    Readln(edit, hsites[I - 1]);
  end;

  CloseFile(edit);
  if not DirectoryExists(ExtractFileDir(loc)) then
    ForceDirectories(ExtractFileDir(loc));

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
      inc(I, 1);
      SetLength(sites, I);
      Readln(edit, sites[I - 1]);
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
    host := GetEnvironmentVariable('WINDIR') + '\System32\drivers\etc\hosts';
    if ParamCount <> 0 then
    begin
      if ParamStr(1) = '/a' then
      begin
        Writeln('Adding entry to HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        Add(ParamStr(2) + ' ' + ParamStr(3));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if ParamStr(1) = '/r' then
      begin
        Writeln('Removing entry from HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        Remove(ParamStr(2) + ' ' + ParamStr(3));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if ParamStr(1) = '/am' then
      begin
        Writeln('Adding entries to HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        AddFromText(ParamStr(2));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if ParamStr(1) = '/rm' then
      begin
        Writeln('Removing entries from HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        RemoveFromText(ParamStr(2));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if ParamStr(1) = '/b' then
      begin
        Writeln('Creating HOSTS file backup...');
        Backup(ParamStr(2));
        Writeln('Done.');
      end;
      if ParamStr(1) = '/res' then
      begin
        Writeln('Restoring HOSTS file...');
        FileSetAttr(host, faArchive);
        if ParamCount > 1 then
          Restore(ParamStr(2))
        else
          Restore;
        Writeln('Done.');
      end;
      if ParamStr(1) = '/attr' then
      begin
        Writeln('Changing Attributes for HOSTS file...');
        SetAttrib(ParamStr(2));
        Writeln('Done.');
      end;
    end
    else
    begin
      SetConsoleTitle('hostsedit 1.4');
      Writeln('Command line utility for editing Windows HOSTS file.');
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
      Writeln('  hostsedit /a 0.0.0.0 www.example-domain.com');
      Writeln('  hostsedit /r 0.0.0.0 www.example-domain.com ');
      Writeln('  hostsedit /am "D:\HOSTS Entries\example.txt"');
      Writeln('  hostsedit /rm "D:\HOSTS Entries\example.txt"');
      Writeln('  hostsedit /b "D:\HOSTS.BKP"');
      Writeln('  hostsedit /res');
      Writeln('  hostsedit /res "D:\HOSTS.BKP"');
      Writeln('  hostsedit /attr r');
      Writeln('');
      Writeln('');
      Writeln('Press any key to continue . . .');
      Readln;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
