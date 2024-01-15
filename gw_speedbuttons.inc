{%gw_frame --- this is a part of GitWizzard}


//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX---SpeedButtons---XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.SpeedButton_LastSavedProjectClick(Sender: TObject);
var PathToEnviro : string;
    //sarchstring  : string;
begin
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'environmentoptions.xml';
 PathToGitDirectory := ReadPathToDir(PathToEnviro,'/CONFIG/EnvironmentOptions/AutoSave/@*');
 SetPathToGitDirectory(PathToGitDirectory);
end;

procedure TFrame1.SpeedButton_LastSavedPackageClick(Sender: TObject);
var PathToEnviro : string;
    //sarchstring  : string;
begin
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'environmentoptions.xml';
 PathToGitDirectory := ReadPathToDir(PathToEnviro,'/CONFIG/EnvironmentOptions/AutoSave/LastOpenPackages/@*');
 SetPathToGitDirectory(PathToGitDirectory);
end;

procedure TFrame1.SpeedButton_AnyDirClick(Sender: TObject);
begin
 if GitDirectoryDlg.Execute then
  PathToGitDirectory := GitDirectoryDlg.FileName;
 SetPathToGitDirectory(PathToGitDirectory);
end;

procedure TFrame1.SpeedButton_defgitignoreClick(Sender: TObject);
begin
 if not OpenDocument(PathToGitWizzard+PathDelim+'defaultgitignore'+PathDelim+'.gitignore')
     then showmessage(rs_ignorenofound);
end;

procedure TFrame1.SpeedButton_NewCommandClick(Sender: TObject);
var i        : integer;
    aCommand : string;
begin
 NewcommandDlg := TNewcommandDlg.Create(self);
 try
  NewcommandDlg.ShowModal;

  if NewcommandDlg.Edit_newcaption.Text  = '' then exit;
  if NewcommandDlg.Edit_newfilename.Text = '' then exit;
  if NewcommandDlg.Edit_newcommand.Text  = '' then exit;

  aCommand := NewcommandDlg.Edit_newcommand.Text;
  CommandList.Add(TCommandButton.Create(self));
  TCommandButton(CommandList.Last).Parent     := ScrollBox1;
  TCommandButton(CommandList.Last).Caption    := NewcommandDlg.Edit_newcaption.Text;
  TCommandButton(CommandList.Last).FileName   := NewcommandDlg.Edit_newfilename.Text;
  TCommandButton(CommandList.Last).Hint       := NewcommandDlg.Edit_newhint.Text;
  TCommandButton(CommandList.Last).NeedsInput := NewcommandDlg.NeedsInput.Checked;
 finally
  NewcommandDlg.Free;
 end;

 TCommandButton(CommandList.Last).BorderSpacing.Around:= 2;
 i := CommandList.Count-2;
 if CommandList.Count = 1 then
  TCommandButton(CommandList.Last).AnchorSideTop.Control := gitignore
 else
  TCommandButton(CommandList.Last).AnchorSideTop.Control := TCommandButton(CommandList.Items[i]);
 TCommandButton(CommandList.Last).AnchorSideTop.Side     := asrBottom;
 TCommandButton(CommandList.Last).AnchorSideLeft.Control := ScrollBox1;
 TCommandButton(CommandList.Last).AnchorSideRight.Control:= ScrollBox1;
 TCommandButton(CommandList.Last).AnchorSideRight.Side   := asrBottom;
 TCommandButton(CommandList.Last).Anchors := [akLeft, akRight, akTop];
 TCommandButton(CommandList.Last).Tag                    := CommandList.Count-1;
 TCommandButton(CommandList.Last).ShowHint               := true;
 TCommandButton(CommandList.Last).OnClick                := @CommandButtonClick;
 TCommandButton(CommandList.Last).PopupMenu              := PopupMenu_CommandButtons;
 TCommandButton(CommandList.Last).LastClick              := false;
 TCommandButton(CommandList.Last).Images                 := ImageList1;
 TCommandButton(CommandList.Last).Layout                 := blGlyphRight;
 SaveABashfile(TCommandButton(CommandList.Last).FileName,aCommand);
 WriteValues;
 Checkgitinit;
end;

procedure TFrame1.SpeedButton_opendirClick(Sender: TObject);
begin
 if not OpenDocument(PathToGitDirectory) then showmessage(rs_Directorynotfound);
end;

procedure TFrame1.SpeedButton_optionsClick(Sender: TObject);
begin
  Optionsform := TOptionsform.Create(self);
  try
   Optionsform.Edit_Editor.Text := FEditor;
   Optionsform.ShowModal;

   FEditor := Optionsform.Edit_Editor.Text;
  finally
   Optionsform.Free;
  end;
  WriteValues;
end;

procedure TFrame1.SpeedButton_restorebackupClick(Sender: TObject);
var dest,source,pathtobashes: string;
    TaskDialog1: TTaskDialog;
    Button: TTaskDialogBaseButtonItem;
 begin
  TaskDialog1   := TTaskDialog.Create(nil);
  try
   TaskDialog1.Caption      := 'GitWizzard';
   TaskDialog1.Title        := rs_restorebackup;
   TaskDialog1.Text         := rs_restorebackuptext;
   TaskDialog1.MainIcon     := tdiWarning;
   //TaskDialog1.FooterText   := 'https://github.com/wennerer/Multis.git';
   //TaskDialog1.FooterIcon   := tdiInformation;

   TaskDialog1.CommonButtons:=[];
   Button := TaskDialog1.Buttons.Add;
   Button.Caption := rs_Yes;
   Button.ModalResult := mrYes;
   Button := TaskDialog1.Buttons.Add;
   Button.Caption := rs_No;
   Button.ModalResult := mrNo;

   //From here it is executed when a button is pressed
    if TaskDialog1.Execute then
     if TaskDialog1.ModalResult = mrNo then exit;

  finally
   Button.Free;
   TaskDialog1.Free;
  end;


 {$IFDEF WINDOWS}
  source := PathToGitWizzard+PathDelim+'winCommands'+PathDelim+'backup'+PathDelim+'gw_commands.xml';
 {$ENDIF}
 {$IFDEF Linux}
  source := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim+'backup'+PathDelim+'gw_commands.xml';
 {$ENDIF}
 {$IFDEF WINDOWS}
  dest := PathToGitWizzard+PathDelim+'winCommands'+PathDelim;
  pathtobashes := PathToGitWizzard+PathDelim+'winCommands'+PathDelim+'backup'+PathDelim;
 {$ENDIF}
 {$IFDEF Linux}
  dest := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim;
  pathtobashes := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim+'backup'+PathDelim;
 {$ENDIF}
 //delete commandbashfolder
   DeleteAFolder(dest);

 //copy gw_commands.xml into backup folder
   if not copyfile(source,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_commands.xml')
    then showmessage(rs_gw_commands);

  //copy all commandfiles into backup folder
   CopyAFolder(pathtobashes,dest);
   sleep(200);
   readvalues;
end;


procedure TFrame1.SpeedButton_createbackupClick(Sender: TObject);
var dest1,dest,pathtobashes : string;
    TaskDialog1: TTaskDialog;
    Button: TTaskDialogBaseButtonItem;
begin
 TaskDialog1   := TTaskDialog.Create(nil);
 try
  TaskDialog1.Caption      := 'GitWizzard';
  TaskDialog1.Title        := rs_createbackup;
  TaskDialog1.Text         := rs_createnewbackup;
  TaskDialog1.MainIcon     := tdiWarning;
  //TaskDialog1.FooterText   := 'https://github.com/wennerer/Multis.git';
  //TaskDialog1.FooterIcon   := tdiInformation;

  TaskDialog1.CommonButtons:=[];
  Button := TaskDialog1.Buttons.Add;
  Button.Caption := rs_Yes;
  Button.ModalResult := mrYes;
  Button := TaskDialog1.Buttons.Add;
  Button.Caption := rs_No;
  Button.ModalResult := mrNo;

  //From here it is executed when a button is pressed
   if TaskDialog1.Execute then
    if TaskDialog1.ModalResult = mrNo then exit;

 finally
  Button.Free;
  TaskDialog1.Free;
 end;


 if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_commands.xml') then
  begin
   {$IFDEF WINDOWS}
    pathtobashes := PathToGitWizzard+PathDelim+'winCommands'+PathDelim;
    dest := PathToGitWizzard+PathDelim+'winCommands'+PathDelim+'backup'+PathDelim;
   {$ENDIF}
   {$IFDEF Linux}
    pathtobashes := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim;
    dest := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim+'backup'+PathDelim;
   {$ENDIF}
  //delete old backup
   DeleteAFolder(dest);

  sleep(200);
   {$IFDEF WINDOWS}
    dest1 := PathToGitWizzard+PathDelim+'winCommands'+PathDelim+'backup'+PathDelim+'gw_commands.xml';
   {$ENDIF}
   {$IFDEF Linux}
    dest1 := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim+'backup'+PathDelim+'gw_commands.xml';
   {$ENDIF}
  //copy gw_commands.xml into backup folder
   if not copyfile(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_commands.xml',dest1)
    then showmessage(rs_gw_commands);

  //copy all commandfiles into backup folder
   CopyAFolder(pathtobashes,dest);
  end;
 end;

procedure TFrame1.SpeedButton_infoClick(Sender: TObject);
begin
 InfoForm := TInfoform.Create(self);
  try
   InfoForm.Memo1.Lines.Add(rs_InfoLine1);
   InfoForm.Memo1.Lines.Add(rs_InfoLine2);
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(rs_InfoLine3);
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(' ');
   InfoForm.Memo1.Lines.Add(rs_InfoLine4);


   InfoForm.ShowModal;
  finally
   Optionsform.Free;
  end;
end;


