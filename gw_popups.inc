{%gw_frame --- this is a part of GitWizard}


//The Popup
procedure TFrame1.openfileClick(Sender: TObject);
var aPath,s : string;
    sa      : array of string;
    lv,i    : integer;
begin
 FSender := nil;

 for i := 0 to pred(length(TabSheets)) do
  for lv := 0 to pred(CommandList[i].Count) do
   begin
    if TCommandButton(CommandList[i].Items[lv]).LastClick then FSender := TCommandButton(CommandList[i].Items[lv]);
    TCommandButton(CommandList[i].Items[lv]).LastClick:= false;
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
var aPath        : string;
    lv,i,aTag,j  : integer;
begin
 FSender := nil;
 for i := 0 to pred(length(TabSheets)) do
  for lv := 0 to pred(CommandList[i].Count) do
   begin
    if TCommandButton(CommandList[i].Items[lv]).LastClick then
     begin
      FSender := TCommandButton(CommandList[i].Items[lv]);
      aTag    := TCommandButton(CommandList[i].Items[lv]).Tag;
      j       := i;
     end;
    TCommandButton(CommandList[i].Items[lv]).LastClick:= false;
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
   CommandList[j].Delete(aTag);
   AdjustTheButtons;
   for lv := 0 to pred(CommandList[j].Count) do TCommandButton(CommandList[j].Items[lv]).Tag:=lv;
   WriteValues;
  end;
 Checkgitinit;
end;

procedure TFrame1.movebuttonClick(Sender: TObject);
var lv,i,aTag,j,k : integer;
begin
  FSender := nil;
 for i := 0 to pred(length(TabSheets)) do
  for lv := 0 to pred(CommandList[i].Count) do
   begin
    if TCommandButton(CommandList[i].Items[lv]).LastClick then
     begin
      FSender := TCommandButton(CommandList[i].Items[lv]);
      aTag    := TCommandButton(CommandList[i].Items[lv]).Tag;
      j       := i;
     end;
    TCommandButton(CommandList[i].Items[lv]).LastClick:= false;
   end;
 if FSender = nil then exit;

 MoveButtonForm  := TMoveButtonForm.Create(self);
 try
  MoveButtonForm.SpinEdit1.MaxValue := pred(CommandList[j].Count);
  if j=0 then MoveButtonForm.SpinEdit1.MinValue:= 1
  else MoveButtonForm.SpinEdit1.MinValue:= 0;
  MoveButtonForm.SpinEdit1.Value    := aTag;

  MoveButtonForm.ShowModal;

  k := MoveButtonForm.SpinEdit1.Value;
 finally
  MoveButtonForm.Free;
 end;

 CommandList[j].Move(aTag,k);
 AdjustTheButtons;
 for lv := 0 to pred(CommandList[j].Count) do TCommandButton(CommandList[j].Items[lv]).Tag:=lv;
 writeValues;
end;

procedure TFrame1.movetotabClick(Sender: TObject);
var lv,i,aTag,j,k : integer;
begin
 FSender := nil;
 for i := 0 to pred(length(TabSheets)) do
  for lv := 0 to pred(CommandList[i].Count) do
   begin
    if TCommandButton(CommandList[i].Items[lv]).LastClick then
     begin
      FSender := TCommandButton(CommandList[i].Items[lv]);
      aTag    := TCommandButton(CommandList[i].Items[lv]).Tag;
      j       := i;
     end;
    TCommandButton(CommandList[i].Items[lv]).LastClick:= false;
   end;

 if FSender = nil then exit;

 MoveToATabForm  := TMoveToATabForm.Create(self);
 try
  for lv:= 0 to pred(length(TabSheets)) do
   MoveToATabForm.ComboBox1.Items.Add(TabSheets[lv].Caption);
  MoveToATabForm.ComboBox1.Text:= TabSheets[j].Caption;
  if MoveToATabForm.ShowModal = mrCancel then exit;

  k := MoveToATabForm.ComboBox1.ItemIndex;
  if j = k then exit; //No change
  i := pred(CommandList[k].Count); //Save index of the last element
  CommandList[k].Add(TCommandButton.Create(self));
  TCommandButton(CommandList[k].Last).Parent     := TabSheets[k];
  TCommandButton(CommandList[k].Last).Caption    := TCommandButton(CommandList[j].Items[aTag]).Caption;
  TCommandButton(CommandList[k].Last).FileName   := TCommandButton(CommandList[j].Items[aTag]).FileName;
  TCommandButton(CommandList[k].Last).Hint       := TCommandButton(CommandList[j].Items[aTag]).Hint;
  TCommandButton(CommandList[k].Last).NeedsInput := TCommandButton(CommandList[j].Items[aTag]).NeedsInput;
  //TCommandButton(CommandList[k].Last).BorderSpacing.Around:= 2;
  //TCommandButton(CommandList[k].Last).AnchorSideTop.Control := TCommandButton(CommandList[k].Items[i]);
  //TCommandButton(CommandList[k].Last).AnchorSideTop.Side     := asrBottom;
  //TCommandButton(CommandList[k].Last).AnchorSideLeft.Control := TabSheets[k];
  //TCommandButton(CommandList[k].Last).AnchorSideRight.Control:= TabSheets[k];
  //TCommandButton(CommandList[k].Last).AnchorSideRight.Side   := asrBottom;
  //TCommandButton(CommandList[k].Last).Anchors := [akLeft, akRight, akTop];
  TCommandButton(CommandList[k].Last).Tag                    := CommandList[k].Count-1;
  TCommandButton(CommandList[k].Last).ShowHint               := true;
  TCommandButton(CommandList[k].Last).OnClick                := @CommandButtonClick;
  TCommandButton(CommandList[k].Last).PopupMenu              := PopupMenu_CommandButtons;
  TCommandButton(CommandList[k].Last).LastClick              := false;
  TCommandButton(CommandList[k].Last).Images                 := ImageList1;
  TCommandButton(CommandList[k].Last).Layout                 := blGlyphRight;

  CommandList[j].Delete(aTag);

  AdjustTheButtons;
  for lv := 0 to pred(CommandList[j].Count) do TCommandButton(CommandList[j].Items[lv]).Tag:=lv;
  writeValues;
  PageControl1.ActivePage:=PageControl1.Pages[k];
 finally
  MoveToATabForm.Free;
 end;
end;


