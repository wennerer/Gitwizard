{%gw_frame --- this is a part of GitWizard}


//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX---SpeedButtons---XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.SpeedButton_LastSavedProjectClick(Sender: TObject);
var PathToEnviro : string;
begin
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'environmentoptions.xml';
 PathToGitDirectory := ReadPathToDir(PathToEnviro,'/CONFIG/EnvironmentOptions/AutoSave/@LastSavedProjectFile');
 SetPathToGitDirectory(PathToGitDirectory);
end;

procedure TFrame1.SpeedButton_LastSavedPackageClick(Sender: TObject);
var PathToEnviro,s : string;
begin
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'environmentoptions.xml';
 s := ReadPathToDir(PathToEnviro,'/CONFIG/EnvironmentOptions/AutoSave/LastOpenPackages/@*');
 if pos('lpk',s) <> 0 then
  begin
   showmessage(rs_moreopen);
   exit;
  end;
 PathToGitDirectory := s;
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
 if not OpenDocument(PathToGitWizard+PathDelim+'defaultgitignore'+PathDelim+'.gitignore')
     then showmessage(rs_ignorenofound);
end;

procedure TFrame1.SpeedButton_NewCommandClick(Sender: TObject);
var i        : integer;
    aCommand : string;
begin
 NewcommandDlg := TNewcommandDlg.Create(self);
 try
  NewcommandDlg.ShowModal;

  if NewcommandDlg.ModalResult = mrCancel then exit;

  if NewcommandDlg.Edit_newcaption.Text  = '' then exit;
  if NewcommandDlg.Edit_newfilename.Text = '' then exit;
  if NewcommandDlg.Edit_newcommand.Text  = '' then exit;

  aCommand := NewcommandDlg.Edit_newcommand.Text;
  CommandList[FActiveTab].Add(TCommandButton.Create(self));
  TCommandButton(CommandList[FActiveTab].Last).Parent     := TabSheets[FActiveTab];
  TCommandButton(CommandList[FActiveTab].Last).Caption    := NewcommandDlg.Edit_newcaption.Text;
  TCommandButton(CommandList[FActiveTab].Last).FileName   := NewcommandDlg.Edit_newfilename.Text;
  TCommandButton(CommandList[FActiveTab].Last).Hint       := NewcommandDlg.Edit_newhint.Text;
  TCommandButton(CommandList[FActiveTab].Last).NeedsInput := NewcommandDlg.NeedsInput.Checked;
 finally
  NewcommandDlg.Free;
 end;

 TCommandButton(CommandList[FActiveTab].Last).BorderSpacing.Around:= 2;
 i := CommandList[FActiveTab].Count-2;
 if CommandList[FActiveTab].Count = 1 then
  begin
   if FActiveTab = 0 then
    TCommandButton(CommandList[FActiveTab].Last).AnchorSideTop.Control := gitignore
   else
    TCommandButton(CommandList[FActiveTab].Last).Align:= alTop;
  end
 else
  TCommandButton(CommandList[FActiveTab].Last).AnchorSideTop.Control := TCommandButton(CommandList[FActiveTab].Items[i]);

 TCommandButton(CommandList[FActiveTab].Last).AnchorSideTop.Side     := asrBottom;
 TCommandButton(CommandList[FActiveTab].Last).AnchorSideLeft.Control := TabSheets[FActiveTab];
 TCommandButton(CommandList[FActiveTab].Last).AnchorSideRight.Control:= TabSheets[FActiveTab];
 TCommandButton(CommandList[FActiveTab].Last).AnchorSideRight.Side   := asrBottom;
 TCommandButton(CommandList[FActiveTab].Last).Anchors := [akLeft, akRight, akTop];
 TCommandButton(CommandList[FActiveTab].Last).Tag                    := CommandList[FActiveTab].Count-1;
 TCommandButton(CommandList[FActiveTab].Last).ShowHint               := true;
 TCommandButton(CommandList[FActiveTab].Last).OnClick                := @CommandButtonClick;
 TCommandButton(CommandList[FActiveTab].Last).PopupMenu              := PopupMenu_CommandButtons;
 TCommandButton(CommandList[FActiveTab].Last).LastClick              := false;
 TCommandButton(CommandList[FActiveTab].Last).Images                 := ImageList1;
 TCommandButton(CommandList[FActiveTab].Last).Layout                 := blGlyphRight;
 TCommandButton(CommandList[FActiveTab].Last).OnMouseEnter           := @CommandButtons_MouseEnter;
 SaveABashfile(TCommandButton(CommandList[FActiveTab].Last).FileName,aCommand);
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
   Optionsform.Edit_Editor.Text         := FEditor;
   Optionsform.DirectoryEdit1.Directory := FOwnBackupFile;
   Optionsform.RadioGroup1.ItemIndex    := FAutoPath;

   if Optionsform.ShowModal = mrCancel then exit;

   FEditor        := Optionsform.Edit_Editor.Text;
   FOwnBackupFile := Optionsform.DirectoryEdit1.Directory;
   FAutoPath      := Optionsform.RadioGroup1.ItemIndex;

  finally
   Optionsform.Free;
  end;
  WriteValues;
end;

procedure TFrame1.SpeedButton_restorebackupClick(Sender: TObject);
var dest,source,source1 : string;
    TaskDialog1         : TTaskDialog;
    Button              : TTaskDialogBaseButtonItem;
    xml                 :  TXMLDocument;
    XPathResult         : TXPathVariable;
    APtr                :Pointer;
    DirectoryDialog     : TSelectDirectoryDialog;
 begin
  TaskDialog1   := TTaskDialog.Create(nil);
  try
   TaskDialog1.Caption      := 'GitWizard';
   TaskDialog1.Title        := rs_restorebackup;
   TaskDialog1.Text         := rs_restorebackuptext;
   TaskDialog1.MainIcon     := tdiWarning;
   TaskDialog1.FooterText   := 'https://github.com/wennerer/Gitwizard.git';
   TaskDialog1.FooterIcon   := tdiInformation;

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
   Dest := PathToGitWizard+PathDelim+'winCommands'+PathDelim;
   Source1 := PathToGitWizard+PathDelim+'providedCommands'+PathDelim+'winCommands'+PathDelim;
  {$ENDIF}

  {$IFDEF Linux}
   Dest := PathToGitWizard+PathDelim+'linuxCommands'+PathDelim;
   Source1 := PathToGitWizard+PathDelim+'providedCommands'+PathDelim+'linuxCommands'+PathDelim;
  {$ENDIF}

  if pos(PathDelim,FOwnBackupFile) <> 0 then Source1 := FOwnBackupFile;

   DirectoryDialog         := TSelectDirectoryDialog.Create(self);
    try
     DirectoryDialog.Title      := rs_selectabackupfoldersource;
     DirectoryDialog.InitialDir := Source1;
     if DirectoryDialog.Execute then Source := DirectoryDialog.FileName+PathDelim else exit;

    finally
     DirectoryDialog.Free;
    end;

  //delete gw_commands.xml
   deletefile(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_commands.xml');
   deletefile(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml');
  //delete commandbashfolder
   DeleteAFolder(Dest);
   sleep(200);


  //copy gw_commands.xml into config folder
   if not copyfile(source+'gw_commands.xml',IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml')
    then showmessage(rs_gw_commands);
   if not copyfile(source+'gw_options.xml',IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_options.xml')
    then showmessage('gw_options not found');

  //copy all commandfiles into commands folder
   CopyAFolder(Source,Dest);
   CommandList[0].Clear;
   sleep(200);
   if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
   begin
    ReadXMLFile(Xml,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml');
    XPathResult := EvaluateXPathExpression('/Options/Tabsheet/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     FTabCaptions := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;
    Xml.Free;
  end;
  createtabs;
  readvalues;
end;

procedure TFrame1.SpeedButton_createbackupClick(Sender: TObject);
var dest1,dest,pathtobashes : string;
    TaskDialog1             : TTaskDialog;
    Button                  : TTaskDialogBaseButtonItem;
    DirectoryDialog         : TSelectDirectoryDialog;
begin
 TaskDialog1   := TTaskDialog.Create(nil);
 try
  TaskDialog1.Caption      := 'GitWizard';
  TaskDialog1.Title        := rs_createbackup;
  TaskDialog1.Text         := rs_createnewbackup;
  TaskDialog1.MainIcon     := tdiWarning;
  TaskDialog1.FooterText   := 'https://github.com/wennerer/Gitwizard.git';
  TaskDialog1.FooterIcon   := tdiInformation;

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
    pathtobashes := PathToGitWizard+PathDelim+'winCommands'+PathDelim;
    dest1 := PathToGitWizard+PathDelim+'providedCommands'+PathDelim+'winCommands'+PathDelim;
   {$ENDIF}
   {$IFDEF Linux}
    pathtobashes := PathToGitWizard+PathDelim+'linuxCommands'+PathDelim;
    dest1 := PathToGitWizard+PathDelim+'providedCommands'+PathDelim+'linuxCommands'+PathDelim;
   {$ENDIF}

   if pos(PathDelim,FOwnBackupFile) <> 0 then Dest1 := FOwnBackupFile;

   DirectoryDialog         := TSelectDirectoryDialog.Create(self);
   try
    DirectoryDialog.Title      := rs_selectabackupfolderDest;
    DirectoryDialog.InitialDir := dest1;
    if DirectoryDialog.Execute then Dest := DirectoryDialog.FileName+PathDelim else exit;

   finally
    DirectoryDialog.Free;
   end;

   //delete old backup
    DeleteAFolder(dest);
    sleep(200);

   //copy gw_commands.xml into backup folder
    if not copyfile(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_commands.xml',Dest+PathDelim+'gw_commands.xml')
     then showmessage(rs_gw_commands);
    if not copyfile(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml',Dest+PathDelim+'gw_options.xml')
     then showmessage('gw_options not found');

    //copy all commandfiles into backup folder
    CopyAFolder(pathtobashes,Dest);
    end
   else showmessage(rs_gw_commands);
 end;

procedure TFrame1.SpeedButton_infoClick(Sender: TObject);
begin
 InfoForm := TInfoform.Create(self);
  try
   InfoForm.ShowModal;
   if InfoForm.openfile then OpenDocument(PathtoGitWizard+PathDelim+'help'+PathDelim+'helpfile_'+rs_lang +'.pdf');
  finally
   Optionsform.Free;
  end;
end;

procedure TFrame1.SpeedButton_newtabClick(Sender: TObject);
begin
 NewTabForm := TNewTabForm.Create(self);
 try

  if NewTabForm.ShowModal = mrCancel then exit;
  FActiveTab          := length(TabSheets);
  setlength(TabSheets,length(TabSheets)+1);
  TabSheets[FActiveTab]              := TTabSheet.Create(self);
  TabSheets[FActiveTab].Parent       := PageControl1;
  TabSheets[FActiveTab].Caption      := NewTabForm.Edit1.Caption;
  //for options.xml
  FTabCaptions   := FTabCaptions+';'+NewTabForm.Edit1.Caption;
  setlength(CommandList,1);
  CommandList[length(TabSheets)-1]      := TObjectList.Create(True);
 finally
  NewTabForm.Free;
 end;
 WriteValues;
end;


