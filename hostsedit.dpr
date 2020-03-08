program hostsedit;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, Winapi.Windows, System.Types, System.Classes,
  System.RegularExpressions;

var
  host: string;
  attrib: Integer;
  RegularExpression: TRegEx;
  Match: TMatch;
  regex1: string =
    '(^\s*(\w{0,4}:\w{0,4})+\s+[^#\s]+)|(^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+[^#\s]+)';
  regex2: string = '(?<=.)\s+(?<=.)';

procedure FlushDNS();
begin
  WinExec('ipconfig /flushdns', SW_HIDE);
  Sleep(500);
end;

function CheckStr(str: string; sites: array of string): Boolean;
var
  I: Integer;
begin
  for I := Low(sites) to High(sites) do
    if CompareText(sites[I], str) = 0 then
      Exit(False);
  Exit(True);
end;

procedure Restore(loc: String = '');
var
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  sites: array of string;
  I: Integer;
begin
  if loc = '' then
  begin
    wstrm := TStreamWriter.Create(host);
    wstrm.writeline('# Copyright (c) 1993-2009 Microsoft Corp.');
    wstrm.writeline('#');
    wstrm.writeline
      ('# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.');
    wstrm.writeline('#');
    wstrm.writeline
      ('# This file contains the mappings of IP addresses to host names. Each');
    wstrm.writeline
      ('# entry should be kept on an individual line. The IP address should');
    wstrm.writeline
      ('# be placed in the first column followed by the corresponding host name.');
    wstrm.writeline
      ('# The IP address and the host name should be separated by at least one');
    wstrm.writeline('# space.');
    wstrm.writeline('#');
    wstrm.writeline
      ('# Additionally, comments (such as these) may be inserted on individual');
    wstrm.writeline
      ('# lines or following the machine name denoted by a ''#'' symbol.');
    wstrm.writeline('#');
    wstrm.writeline('# For example:');
    wstrm.writeline('#');
    wstrm.writeline
      ('#      102.54.94.97     rhino.acme.com          # source server');
    wstrm.writeline
      ('#       38.25.63.10     x.acme.com              # x client host');
    wstrm.writeline('');
    wstrm.writeline
      ('# localhost name resolution is handled within DNS itself.');
    wstrm.writeline('#	127.0.0.1       localhost');
    wstrm.writeline('#	::1             localhost');
    wstrm.free;
  end
  else
  begin
    I := 0;
    rstrm := TStreamReader.Create(loc);
    while not(rstrm.endofstream) do
    begin
      inc(I, 1);
      SetLength(sites, I);
      sites[I - 1] := rstrm.ReadLine;
    end;
    rstrm.free;

    wstrm := TStreamWriter.Create(host);
    for I := Low(sites) to High(sites) do
      wstrm.writeline(sites[I]);
    wstrm.free;
  end;
end;

procedure Add(ip: String; domain: String);
var
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  hip, hdomain, osites: array of string;
  I: Integer;
  splt: TStringDynArray;
  str: string;
  exists: Boolean;
begin
  if not FileExists(host) then
    Restore;
  exists := False;
  RegularExpression.Create(regex1);
  I := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    inc(I, 1);
    SetLength(hip, I);
    SetLength(hdomain, I);
    SetLength(osites, I);
    str := rstrm.ReadLine;
    osites[I - 1] := str;
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      str := Match.Value;
      str := Trim(str);
      splt := TRegEx.Split(str, regex2);
      hip[I - 1] := splt[0];
      hdomain[I - 1] := splt[1];
      if (CompareText(hdomain[I - 1], domain) = 0) and (exists = False) then
      begin
        exists := True;
        osites[I - 1] := ip + ' ' + domain;

      end
      else if (CompareText(hdomain[I - 1], domain) = 0) and (exists = True) then
      begin
        hip[I - 1] := 'removed';
      end;
      Continue;
    end;
    hip[I - 1] := '';
    hdomain[I - 1] := '';
  end;
  rstrm.free;
  wstrm := TStreamWriter.Create(host);

  for I := Low(hip) to High(hip) do
    if (hip[I] <> 'removed') then
      wstrm.writeline(osites[I]);

  if not exists then
    wstrm.writeline(ip + ' ' + domain);

  wstrm.free;
end;

procedure Remove(site: string);
var
  hsites, osites: array of string;
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  I: Integer;
  str: string;
begin
  RegularExpression.Create(regex1);
  I := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    str := rstrm.ReadLine;
    Match := RegularExpression.Match(str);
    inc(I, 1);
    SetLength(hsites, I);
    SetLength(osites, I);
    osites[I - 1] := str;
    if Match.Success then
    begin
      str := Match.Value;
      str := TRegEx.Replace(str,
        '(^\s*(\w{0,4}:\w{0,4})+\s+)|(^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+)',
        '');
      hsites[I - 1] := str;
      Continue;
    end;
    hsites[I - 1] := str;
  end;
  rstrm.free;
  wstrm := TStreamWriter.Create(host);
  for I := Low(hsites) to High(hsites) do
    if CompareText(hsites[I], site) <> 0 then
      wstrm.writeline(osites[I]);
  wstrm.free;
end;

procedure AddFromText(lhost: String);
var
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  splt: TStringDynArray;
  ip, domain, hip, hdomain, osites, aip, adomain: array of string;
  str: string;
  I, J, K: Integer;
  exists: Boolean;
begin
  if not FileExists(host) then
    Restore;
  RegularExpression.Create(regex1);
  I := 0;
  K := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    inc(I, 1);
    SetLength(hip, I);
    SetLength(hdomain, I);
    SetLength(osites, I);
    str := rstrm.ReadLine;
    osites[I - 1] := str;
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      str := Match.Value;
      str := Trim(str);
      splt := TRegEx.Split(str, regex2);
      hip[I - 1] := splt[0];
      hdomain[I - 1] := splt[1];
      Continue;
    end;
    hip[I - 1] := '';
    hdomain[I - 1] := '';
  end;
  rstrm.free;
  I := 0;
  rstrm := TStreamReader.Create(lhost);
  while not(rstrm.endofstream) do
  begin
    str := rstrm.ReadLine;
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      SetLength(ip, I);
      SetLength(domain, I);
      str := Match.Value;
      str := Trim(str);
      splt := TRegEx.Split(str, regex2);
      ip[I - 1] := splt[0];
      domain[I - 1] := splt[1];
    end;
  end;
  rstrm.free;
  for I := Low(domain) to High(domain) do
  begin
    exists := False;
    for J := Low(hdomain) to High(hdomain) do
    begin
      if (CompareText(hdomain[J], domain[I]) = 0) and (exists = False) then
      begin
        exists := True;
        osites[J] := ip[I] + ' ' + domain[I];

      end
      else if (CompareText(hdomain[J], domain[I]) = 0) and (exists = True) then
      begin
        hip[J] := 'removed';
      end;

    end;

    if not exists then
    begin
      inc(K, 1);
      SetLength(aip, K);
      SetLength(adomain, K);
      aip[K - 1] := ip[I];
      adomain[K - 1] := domain[I];
    end;
  end;

  wstrm := TStreamWriter.Create(host);
  for I := Low(hip) to High(hip) do
    if (hip[I] <> 'removed') then
      wstrm.writeline(osites[I]);
  for I := Low(adomain) to High(adomain) do
    wstrm.writeline(aip[I] + ' ' + adomain[I]);
  wstrm.free;
end;

procedure RemoveFromText(lhost: String);
var
  sites, hsites, osites: array of string;
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  AltRegularExpression: TRegEx;
  AltMatch: TMatch;
  str: string;
  I: Integer;
begin
  RegularExpression.Create(regex1);
  AltRegularExpression.Create('^\s*[^#\s]+');
  I := 0;
  rstrm := TStreamReader.Create(lhost);
  while not(rstrm.endofstream) do
  begin
    str := rstrm.ReadLine;
    Match := RegularExpression.Match(str);
    AltMatch := AltRegularExpression.Match(str);
    if Match.Success then
    begin
      inc(I, 1);
      SetLength(sites, I);
      str := Match.Value;
      str := TRegEx.Replace(str,
        '(^\s*(\w{0,4}:\w{0,4})+\s+)|(^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+)',
        '');
      sites[I - 1] := str;
    end
    else if AltMatch.Success then
    begin
      inc(I, 1);
      SetLength(sites, I);
      str := AltMatch.Value;
      str := Trim(str);
      sites[I - 1] := str;
    end;
  end;
  rstrm.free;
  I := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    str := rstrm.ReadLine;
    Match := RegularExpression.Match(str);
    inc(I, 1);
    SetLength(hsites, I);
    SetLength(osites, I);
    osites[I - 1] := str;
    if Match.Success then
    begin
      str := Match.Value;
      str := TRegEx.Replace(str,
        '(^\s*(\w{0,4}:\w{0,4})+\s+)|(^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+)',
        '');
      hsites[I - 1] := str;
      Continue;
    end;
    hsites[I - 1] := str;
  end;
  rstrm.free;
  wstrm := TStreamWriter.Create(host);
  for I := Low(hsites) to High(hsites) do
    if CheckStr(hsites[I], sites) then
      wstrm.writeline(osites[I]);
  wstrm.free;
end;

procedure Backup(loc: String);
var
  hsites: array of string;
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  I: Integer;
begin
  I := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    inc(I, 1);
    SetLength(hsites, I);
    hsites[I - 1] := rstrm.ReadLine;
  end;

  rstrm.free;
  if (not DirectoryExists(ExtractFileDir(loc))) and
    (not ExtractFileDir(loc).IsEmpty) then
    ForceDirectories(ExtractFileDir(loc));

  wstrm := TStreamWriter.Create(loc);
  for I := Low(hsites) to High(hsites) do
    wstrm.writeline(hsites[I]);
  wstrm.free;
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

procedure ReplaceIP(ip1: string; ip2:string);
var
  rstrm: TStreamReader;
  wstrm: TStreamWriter;
  splt: TStringDynArray;
  hip, hdomain, osites: array of string;
  str: string;
  I: Integer;
begin
  RegularExpression.Create(regex1);
  I := 0;
  rstrm := TStreamReader.Create(host);
  while not(rstrm.endofstream) do
  begin
    inc(I, 1);
    SetLength(hip, I);
    SetLength(hdomain, I);
    SetLength(osites, I);
    str := rstrm.ReadLine;
    osites[I - 1] := str;
    Match := RegularExpression.Match(str);
    if Match.Success then
    begin
      str := Match.Value;
      str := Trim(str);
      splt := TRegEx.Split(str, regex2);
      hip[I - 1] := splt[0];
      hdomain[I - 1] := splt[1];
      Continue;
    end;
    hip[I - 1] := '';
    hdomain[I - 1] := '';
  end;
  rstrm.free;
  wstrm := TStreamWriter.Create(host);
  for I := Low(hip) to High(hip) do
    if (hip[I] = ip1) then
      wstrm.writeline(ip2+' '+hdomain[I])
    else
      wstrm.WriteLine(osites[I]);
  wstrm.free;
end;

begin
  try
    host := GetEnvironmentVariable('WINDIR') + '\System32\drivers\etc\hosts';
    if ParamCount <> 0 then
    begin
      if (ParamStr(1) = '/a') and (ParamCount = 3) and
        RegularExpression.IsMatch(ParamStr(2),
        '(^(\w{0,4}:\w{0,4})+$)|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$)') then
      begin
        Writeln('Adding entry to HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        Add(ParamStr(2), ParamStr(3));
        if attrib <> -1 then
          FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/r') and (ParamCount = 2) then
      begin
        Writeln('Removing entry from HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        Remove(ParamStr(2));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/am') and (ParamCount = 2) then
      begin
        Writeln('Adding entries to HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        AddFromText(ParamStr(2));
        if attrib <> -1 then
          FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/rm') and (ParamCount = 2) then
      begin
        Writeln('Removing entries from HOSTS file...');
        attrib := FileGetAttr(host);
        FileSetAttr(host, faArchive);
        RemoveFromText(ParamStr(2));
        FileSetAttr(host, attrib);
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/b') and (ParamCount = 2) then
      begin
        Writeln('Creating HOSTS file backup...');
        Backup(ParamStr(2));
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/res') and (ParamCount = 2) then
      begin
        Writeln('Restoring HOSTS file...');
        FileSetAttr(host, faArchive);
        Restore(ParamStr(2));
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/res') and (ParamCount = 1) then
      begin
        Writeln('Restoring HOSTS file...');
        FileSetAttr(host, faArchive);
        Restore;
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/attr') and (ParamCount = 2) then
      begin
        Writeln('Changing Attributes for HOSTS file...');
        SetAttrib(ParamStr(2));
        Writeln('Done.');
      end;
      if (ParamStr(1) = '/fdns') and (ParamCount = 1) then
      begin
        FlushDNS;
      end;
      if (ParamStr(1) = '/rip') and (ParamCount = 3) and
        RegularExpression.IsMatch(ParamStr(2),
        '(^(\w{0,4}:\w{0,4})+$)|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$)') and
        RegularExpression.IsMatch(ParamStr(3),
        '(^(\w{0,4}:\w{0,4})+$)|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$)')then
      begin
        Writeln('Replacing IP '+ParamStr(2) +' with '+ ParamStr(3)+' ...');
        ReplaceIP(ParamStr(2),ParamStr(3));
        Writeln('Done.');
      end;
    end
    else
    begin
      SetConsoleTitle('hostsedit 2.0');
      Writeln('Command line utility for editing Windows HOSTS file.');
      Writeln('');
      Writeln('Usage :');
      Writeln('');
      Writeln('  /a     : Add single entry.');
      Writeln('  /r     : Remove single entry.');
      Writeln('  /am    : Add multiple entries, reading from text file.');
      Writeln('  /rm    : Remove multiple entries, reading from text file.');
      Writeln('  /b     : Create backup of HOSTS file.');
      Writeln('  /fdns  : Flush Windows DNS Cache.');
      Writeln('  /rip   : Replace IPs in HOSTS file.');
      Writeln('  /res   : Restore HOSTS file to Windows default, or to a previous backup.');
      Writeln('  /attr  : Set attributes for HOSTS file, ReadOnly(/attr r), Archive(/attr a), Both(/attr ra).');
      Writeln('');
      Writeln('Samples :');
      Writeln('');
      Writeln('  hostsedit /a 0.0.0.0 www.example-domain.com');
      Writeln('  hostsedit /r www.example-domain.com');
      Writeln('  hostsedit /am "D:\HOSTS Entries\example.txt"');
      Writeln('  hostsedit /rm "D:\HOSTS Entries\example.txt"');
      Writeln('  hostsedit /b "D:\HOSTS.BKP"');
      Writeln('  hostsedit /fdns');
      Writeln('  hostsedit /rip 0.0.0.0 127.0.0.1');
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
