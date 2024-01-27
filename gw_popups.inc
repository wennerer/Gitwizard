{%gw_frame --- this is a part of GitWizard}


//The Popup
procedure TFrame1.openfileClick(Sender: TObject);
var aPath,s : string;
    sa      : array of string;
    lv,i    : integer;
begin
 FSender := nil;

 //for i := 0 to
 for lv := 0 to pred(CommandList[0].Count) do
  begin
   if TCommandButton(CommandList[0].Items[lv]).LastClick then FSender := TCommandButton(CommandList[0].Items[lv]);
   TCommandButton(CommandList[0].Items[lv]).LastClick:= false;
  end;


 if FSender = nil then FSender := gitignore;

 if not fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
  begin
   showmessage(rs_checkoptionsdialog);
   exit;
  end;

 {$IFDEF WINDOWS}
  aPath := PathToGitWizard+PathDelim+'winCommands'+PathDelim;
  if FSender is TCommandButton then
   begin
    setlength(sa,1);
    sa[0] := aPath+(FSender as TCommandButton).FileName+'.bat';
    if not RunCommand(FEditor,sa,s,[],swoNone) then showmessage(s);
   end;

 {$ENDIF}
 {$IFDEF Linux}
 aPath := PathToGitWizard+PathDelim+'linuxCommands'+PathDelim;
  if FSender is TCommandButton then
   begin
    setlength(sa,1);
    sa[0] := aPath+(FSender as TCommandButton).FileName+'.sh';
    if not RunCommand(FEditor,sa,s,[],swoNone) then showmessage(s);
   end;

 {$ENDIF}
 if FSender = gitignore then
   if not OpenDocument(PathToGitDirectory+PathDelim+'.gitignore') then showmessage(rs_ignorenofound);
end;


procedure TFrame1.deletecommandClick(Sender: TObject);
var aPath : string;
    lv    : integer;
begin
 FSender := nil;
 for lv := 0 to pred(CommandList[0].Count) do
  begin
   if TCommandButton(CommandList[0].Items[lv]).LastClick then FSender := TCommandButton(CommandList[0].Items[lv]);
   TCommandButton(CommandList[0].Items[lv]).LastClick:= false;
  end;
 if FSender = nil then FSender := gitignore;

 {$IFDEF WINDOWS}
  aPath := PathToGitWizard+PathDelim+'winCommands'+PathDelim;
  if FSender is TCommandButton then
   if deletefile(aPath+(FSender as TCommandButton).FileName+'.bat') then showmessage('Okay')
   else showmessage(rs_filenotfound);
 {$ENDIF}
 {$IFDEF Linux}
  aPath := PathToGitWizard+PathDelim+'linuxCommands'+PathDelim;
  if FSender is TCommandButton then
   if deletefile(aPath+(FSender as TCommandButton).FileName+'.sh') then showmessage('Okay')
   else showmessage(rs_filenotfound);
 {$ENDIF}

 if FSender = gitignore then
  if deletefile(PathToGitDirectory+PathDelim+'.gitignore') then showmessage('Okay')
  else showmessage(rs_filenotfound);
 Checkgitignore;

 if FSender <> gitignore then
  begin
   CommandList[0].Delete((FSender as TCommandButton).Tag);
   AdjustTheButtons;
   for lv := 0 to pred(CommandList[0].Count) do TCommandButton(CommandList[0].Items[lv]).Tag:=lv;
   WriteValues;
  end;
 Checkgitinit;
end;

procedure TFrame1.movebuttonClick(Sender: TObject);
var lv,i : integer;
begin
  FSender := nil;
 for lv := 0 to pred(CommandList[0].Count) do
  begin
   if TCommandButton(CommandList[0].Items[lv]).LastClick then FSender := TCommandButton(CommandList[0].Items[lv]);
   TCommandButton(CommandList[0].Items[lv]).LastClick:= false;
  end;
 if FSender = nil then exit;

 MoveButtonForm  := TMoveButtonForm.Create(self);
 try
  MoveButtonForm.SpinEdit1.MaxValue := pred(CommandList[0].Count);
  MoveButtonForm.SpinEdit1.Value    := (FSender as TCommandButton).Tag;

  MoveButtonForm.ShowModal;

  i := MoveButtonForm.SpinEdit1.Value;
 finally
  MoveButtonForm.Free;
 end;

 CommandList[0].Move((FSender as TCommandButton).Tag,i);
 AdjustTheButtons;
 for lv := 0 to pred(CommandList[0].Count) do TCommandButton(CommandList[0].Items[lv]).Tag:=lv;
 writeValues;
end;

procedure TFrame1.movetotabClick(Sender: TObject);
var lv : integer;
begin
 FSender := nil;
 for lv := 0 to pred(CommandList[0].Count) do
  begin
   if TCommandButton(CommandList[0].Items[lv]).LastClick then FSender := TCommandButton(CommandList[0].Items[lv]);
   TCommandButton(CommandList[0].Items[lv]).LastClick:= false;
  end;
 if FSender = nil then exit;
 //showmessage((FSender as TCommandButton).FileName);
 (FSender as TCommandButton).Parent := TabSheets[0];
 //AdjustTheButtons;
end;


