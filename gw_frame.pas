unit gw_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, Dialogs, StdCtrls,
  ExtCtrls, FileCtrl, LCLIntf, Menus, LazIDEIntf, FileUtil, DOM, XMLRead, XMLWrite, XPath,
  process, Contnrs, StrUtils, newcommand, input_form,options_form;

resourcestring
  rs_comnotfound = 'Command-File not found!';
  rs_comerror    = 'The command is incorrect!';
  rs_ignorenofound = 'Default gitignore not found!';
  rs_nodirectoryselected = 'No directory selected!';
  rs_Filealreadyexists = 'File already exists';
  rs_filenotfound = 'File not found';
  rs_Directorynotfound = 'Directory not found';
  rs_checkoptionsdialog = 'Please check optionsdialog';
  rs_gw_commands = 'File nor found: gw_commands.xml';

type

  { CommandButton }

  { TCommandButton }

  TCommandButton = class(TButton)

  private
    FFileName  : string;
    FLastClick: boolean;
    FNeedsInput: boolean;
  public
   property FileName   : string  read FFileName   write FFileName;
   property NeedsInput : boolean read FNeedsInput write FNeedsInput;
   property LastClick : boolean read FLastClick write FLastClick;
   procedure MouseDown({%H-}Button: TMouseButton;{%H-}Shift: TShiftState; X, Y: Integer);override;
  end;


type

  { TFrame1 }

  TFrame1 = class(TFrame)
    gitignore                   : TButton;
    ImageList1                  : TImageList;
    deletecommand               : TMenuItem;
    openfile                    : TMenuItem;
    Path_Panel                  : TPanel;
    Input                       : TEdit;
    GitDirectoryDlg             : TSelectDirectoryDialog;
    PopupMenu_CommandButtons    : TPopupMenu;
    Separator_Shape1            : TShape;
    SpeedButton_opendir         : TSpeedButton;
    SpeedButton_options         : TSpeedButton;
    SpeedButton_NewCommand      : TSpeedButton;
    SpeedButton_defgitignore    : TSpeedButton;
    SpeedButton_SingleInput     : TSpeedButton;
    SpeedButton_LastSavedPackage: TSpeedButton;
    SpeedButton_AnyDir          : TSpeedButton;
    SpeedButton_LastSavedProject: TSpeedButton;
    ToolBar1                      : TToolBar;
    procedure gitignoreClick(Sender: TObject);
    procedure ReadValues;
    procedure SpeedButton_opendirClick(Sender: TObject);
    procedure SpeedButton_optionsClick(Sender: TObject);
    procedure WriteValues;
    procedure deletecommandClick(Sender: TObject);
    procedure openfileClick(Sender: TObject);
    procedure SpeedButton_defgitignoreClick(Sender: TObject);
    procedure SpeedButton_LastSavedPackageClick(Sender: TObject);
    procedure SpeedButton_AnyDirClick(Sender: TObject);
    procedure SpeedButton_LastSavedProjectClick(Sender: TObject);
    procedure SpeedButton_NewCommandClick(Sender: TObject);
    procedure SpeedButton_SingleInputClick(Sender: TObject);
  private
    CommandList            : TObjectList;
    FSender                : TObject;
    FEditor                : string;
    PathToGitDirectory     : string; //The path to the directory that is to be versioned using git
    PathToGitWizzard       : string; //The path to the directory where the gitwizzard package is located
    procedure CommandButtonClick(Sender: TObject);
    procedure ExecuteCommand(aCommandBash: String;Com: array of TProcessString; Options: TProcessOptions=[];
                             swOptions: TShowWindowOptions=swoNone);
    procedure SaveABashfile(aFileName, aCommand: string);
    procedure SetPathToGitDirectory(aPath: string);
    procedure AdjustTheButtons;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

implementation

{$R *.lfm}
function AdjustText(aText: String;aControl : TControl) : string;
var cnv : TControlCanvas;
    w   : Integer;
begin
  cnv := TControlCanvas.Create;
  try
    cnv.Control := aControl;
    w := aControl.ClientWidth;
    Result := MinimizeName(aText, cnv, w-4);
  finally
    cnv.Free;
  end;
end;

function ReadPathToDir(aFilename,aSearchString :string): string;
var
  Xml         : TXMLDocument;
  XPathResult : TXPathVariable;
  APtr        : Pointer;
  Path,s      : string;
  i           : integer;
begin
  Path:= '';
  ReadXMLFile(Xml, aFilename);
  XPathResult := EvaluateXPathExpression(Unicodestring(aSearchString), Xml.DocumentElement);
  For APtr in XPathResult.AsNodeSet do
    Path := Path + string(TDOMNode(APtr).NodeValue);
  XPathResult.Free;
  Xml.Free;


 {$IFDEF WINDOWS}
   s:='\';
 {$ENDIF}
 {$IFDEF Linux}
   s:='/';
 {$ENDIF}
  Path:=ReverseString(Path);
  i:=Pos(s,Path);
  Delete(Path, 1, i);
  Path:=ReverseString(Path);

  Result := Path;
end;

{ TCommandButton }

procedure TCommandButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
 inherited MouseDown(Button, Shift, X, Y);
 LastClick:=true;
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---FRAME---XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

{ TFrame1 }

constructor TFrame1.Create(AOwner: TComponent);
var PathToEnviro     : string;
begin
 inherited Create(AOwner);
 CommandList := TObjectList.Create(True);
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'packagefiles.xml';
 PathToGitWizzard := ReadPathToDir(PathToEnviro,'/CONFIG/UserPkgLinks//*[Name[@Value="laz_gitwizzard"]]/Filename/@*');
 //PathToGitDirectory := '';
 //SetPathToGitDirectory(PathToGitDirectory);

 if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml') then ReadValues
 else showmessage(rs_gw_commands);

end;

destructor TFrame1.Destroy;
begin
 FreeAndNil(CommandList);
 inherited Destroy;
end;

procedure TFrame1.WriteValues;
var Doc               : TXMLDocument;
    RootNode, ButtonNode,CaptionNode,HintNode,FilenameNode,NeedsInputNode,OptionsNode,aText: TDOMNode;
    lv : integer;
    s  : string;
begin
 try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('Options');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    OptionsNode := Doc.CreateElement('Editor');
    TDOMElement(OptionsNode).SetAttribute('Editor', FEditor);
    RootNode.Appendchild(OptionsNode);

    (*LangugaeNode := Doc.CreateElement('Language');
    TDOMElement(LangugaeNode).SetAttribute('Language', 'de');
    RootNode.Appendchild(LangugaeNode); *)

    writeXMLFile(Doc,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_options.xml');
  finally
    Doc.Free;
  end;



 if CommandList.Count = 0 then exit;
  try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('Commandbuttons');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    for lv:= 0 to pred(CommandList.Count) do
     begin
     ButtonNode   := Doc.CreateElement('Commandbutton'+unicodestring(inttostr(lv)));
     RootNode.AppendChild(ButtonNode);

      CaptionNode   := Doc.CreateElement('Caption');
       aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList.Items[lv]).Caption));
       CaptionNode.AppendChild(aText);
      ButtonNode.AppendChild(CaptionNode);

      FilenameNode   := Doc.CreateElement('Filename');
       aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList.Items[lv]).FileName));
       FilenameNode.AppendChild(aText);
      ButtonNode.AppendChild(FilenameNode);

      HintNode   := Doc.CreateElement('Hint');
       aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList.Items[lv]).Hint));
       HintNode.AppendChild(aText);
      ButtonNode.AppendChild(HintNode);

      if TCommandButton(CommandList.Items[lv]).NeedsInput then s:='true' else s:='false';
      NeedsInputNode   := Doc.CreateElement('NeedsInput');
       aText   := Doc.CreateTextNode(Unicodestring(s));
       NeedsInputNode.AppendChild(aText);
      ButtonNode.AppendChild(NeedsInputNode);
     end;
    writeXMLFile(Doc,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml');
  finally
    Doc.Free;
  end;
end;

procedure TFrame1.ReadValues;
var xml     :  TXMLDocument;
    k,i,j   : integer;
    bol     : string;
    XPathResult: TXPathVariable;
    APtr:Pointer;
  procedure ParseXML(Node : TDomNode);
  begin
   while (Assigned(Node)) do
    begin
      if (Node.NodeName <> '')  then
       begin
         if Node.NodeName = 'Commandbutton'+inttostr(k) then
          begin
           CommandList.Add(TCommandButton.Create(self));
           TCommandButton(CommandList.Last).Parent     := self;
           TCommandButton(CommandList.Last).BorderSpacing.Around:= 2;
           i := CommandList.Count-2;
           if CommandList.Count = 1 then
            TCommandButton(CommandList.Last).AnchorSideTop.Control := gitignore
           else
            TCommandButton(CommandList.Last).AnchorSideTop.Control := TCommandButton(CommandList.Items[i]);
           TCommandButton(CommandList.Last).AnchorSideTop.Side     := asrBottom;
           TCommandButton(CommandList.Last).AnchorSideLeft.Control := self;
           TCommandButton(CommandList.Last).AnchorSideRight.Control:= self;
           TCommandButton(CommandList.Last).AnchorSideRight.Side   := asrBottom;
           TCommandButton(CommandList.Last).Anchors := [akLeft, akRight, akTop];
           TCommandButton(CommandList.Last).Tag                    := CommandList.Count-1;
           TCommandButton(CommandList.Last).ShowHint               := true;
           TCommandButton(CommandList.Last).OnClick                := @CommandButtonClick;
           TCommandButton(CommandList.Last).PopupMenu              := PopupMenu_CommandButtons;
           TCommandButton(CommandList.Last).LastClick              := false;
           inc(k);
          end;
         if Node.NodeName = '#text' then
          begin
           if j = 0 then TCommandButton(CommandList.Last).Caption := string(Node.NodeValue);
           if j = 1 then TCommandButton(CommandList.Last).FileName := string(Node.NodeValue);
           if j = 2 then TCommandButton(CommandList.Last).Hint := string(Node.NodeValue);
           if j = 3 then
            begin
             bol := string(Node.NodeValue);
             if bol = 'true' then TCommandButton(CommandList.Last).NeedsInput := true
             else TCommandButton(CommandList.Last).NeedsInput := false;
            end;//bol
           inc(j);
           if j=4 then j:=0;
          end;//#text
       ParseXML(Node.FirstChild);
       Node := Node.NextSibling;
      end;//' '
   end;//while
  end;
begin
  ReadXMLFile(xml,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml');
  k:=0;J:=0;
  ParseXML( xml.FirstChild);
  xml.Free;

  if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
   begin
    ReadXMLFile(Xml,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml');
    XPathResult := EvaluateXPathExpression('/Options/Editor/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     FEDitor := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;
    (*XPathResult := EvaluateXPathExpression('/Options/Language/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
    Memo1.Lines.Add(string(TDOMNode(APtr).NodeValue));
    XPathResult.Free; *)
    Xml.Free;
  end;
end;

procedure TFrame1.SetPathToGitDirectory(aPath : string);
begin
 if PathToGitDirectory = '' then exit;
 Path_Panel.Caption := AdjustText(aPath,Path_Panel);
 Path_Panel.Hint:= aPath;

 //Checks whether git has already been initialised
// if DirectoryExists(aPath+PathDelim+'.git') then Git_init.Enabled:= false
  //else Git_init.Enabled:=true;
end;

procedure TFrame1.AdjustTheButtons;
var lv,i : integer;
begin
 for lv:=0 to pred(CommandList.Count) do
  begin
   TCommandButton(CommandList.Items[lv]).Anchors:=[];
   if lv = 0 then
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Control := gitignore
   else
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Control := TCommandButton(CommandList.Items[lv-1]);
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Side     := asrBottom;
    TCommandButton(CommandList.Items[lv]).AnchorSideLeft.Control := self;
    TCommandButton(CommandList.Items[lv]).AnchorSideRight.Control:= self;
    TCommandButton(CommandList.Items[lv]).AnchorSideRight.Side   := asrBottom;
    TCommandButton(CommandList.Items[lv]).Anchors := [akLeft, akRight, akTop];
  end;
end;

procedure TFrame1.SaveABashfile(aFileName,aCommand:string);
var strList          : TStringList;
begin
 strList  := TStringlist.Create;
 try
  {$IFDEF WINDOWS}
   strList.Add(aCommand);
   strList.SaveToFile(PathToGitWizzard+'\winCommands\'+aFileName+'.bat');
  {$ENDIF}
  {$IFDEF Linux}
   strList.Add('#!/bin/bash');
   strList.Add(aCommand);
   strList.SaveToFile(PathToGitWizzard+'/linuxCommands/'+aFileName+'.sh');
  {$ENDIF}
 finally
  strList.Free;
 end;
 {$IFDEF WINDOWS}
  exit;
 {$ENDIF}
 strList  := TStringlist.Create;
 try
  strList.Add('#!/bin/bash');
  strList.Add('chmod a+x '+PathToGitWizzard+'/linuxCommands/'+aFileName+'.sh');
  strList.SaveToFile(PathToGitWizzard+'/linuxCommands/makeexecutable.sh');
 finally
  strList.Free;
 end;
 ExecuteCommand('makeexecutable',[],[],swoNone);
end;

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
  TCommandButton(CommandList.Last).Parent     := self;
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
 TCommandButton(CommandList.Last).AnchorSideLeft.Control := self;
 TCommandButton(CommandList.Last).AnchorSideRight.Control:= self;
 TCommandButton(CommandList.Last).AnchorSideRight.Side   := asrBottom;
 TCommandButton(CommandList.Last).Anchors := [akLeft, akRight, akTop];
 TCommandButton(CommandList.Last).Tag                    := CommandList.Count-1;
 TCommandButton(CommandList.Last).ShowHint               := true;
 TCommandButton(CommandList.Last).OnClick                := @CommandButtonClick;
 TCommandButton(CommandList.Last).PopupMenu              := PopupMenu_CommandButtons;
 TCommandButton(CommandList.Last).LastClick              := false;
 SaveABashfile(TCommandButton(CommandList.Last).FileName,aCommand);
 WriteValues;
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



//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----Execute Commands----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.ExecuteCommand(aCommandBash:String;Com:array of TProcessString;
                                   Options:TProcessOptions=[];swOptions:TShowWindowOptions=swoNone);
var pathtobash,s : string;
begin
  if PathToGitDirectory = '' then
  begin
   showmessage(rs_nodirectoryselected);
   exit;
  end;

 {$IFDEF WINDOWS}
    pathtobash := PathToGitWizzard+PathDelim+'winCommands'+PathDelim+ aCommandBash+'.bat';
 {$ENDIF}
 {$IFDEF Linux}
    pathtobash := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim+ aCommandBash+'.sh';
 {$ENDIF}
 if not fileexists(pathtobash) then
  begin
   showmessage(rs_comnotfound);
   exit;
  end;
 s:= '';
 if RunCommandInDir(PathToGitDirectory,pathtobash,Com,s,Options,swOptions) then showmessage(s)
 else showmessage(rs_comerror);
end;

procedure TFrame1.SpeedButton_SingleInputClick(Sender: TObject);
var strList          : TStringList;
begin
 strList  := TStringlist.Create;
 try
 {$IFDEF WINDOWS}
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizzard+'\winCommands\singlecommand.bat');
 {$ENDIF}
 {$IFDEF Linux}
  strList.Add('#!/bin/bash');
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizzard+'/linuxCommands/singlecommand.sh');
  {$ENDIF}
 finally
  strList.Free;
 end;
 ExecuteCommand('singlecommand',[],[],swoNone);
end;


procedure TFrame1.gitignoreClick(Sender: TObject);
begin
 if PathToGitDirectory = '' then
  begin
   showmessage(rs_nodirectoryselected);
   exit;
  end;
 if FileExists(PathToGitDirectory+PathDelim+'.gitignore') then
  begin
   showmessage(rs_Filealreadyexists);
   exit;
  end;
 if CopyFile(PathToGitWizzard+PathDelim+'defaultgitignore'+PathDelim+'.gitignore',
             PathToGitDirectory+PathDelim+'.gitignore')
 then showmessage('Ok') else showmessage('Error');
end;



//here execute CommandButtons
procedure TFrame1.CommandButtonClick(Sender: TObject);
var strList : TStringlist;
begin
 if (Sender as TCommandButton).NeedsInput then
  begin
   InputForm  := TInputForm.Create(self);
   strList    := TStringlist.Create;
   try
    {$IFDEF WINDOWS}
      strList.LoadFromFile(PathToGitWizzard+'\winCommands\'+(Sender as TCommandButton).FileName+'.bat');

    {$ENDIF}
    {$IFDEF Linux}
     strList.LoadFromFile(PathToGitWizzard+'/linuxCommands/'+(Sender as TCommandButton).FileName+'.sh');
    {$ENDIF}

    InputForm.Edit_Complete.Text := strList[1];
    InputForm.ShowModal;

    SaveABashfile('NeedsInput',InputForm.Edit_Complete.Text);
    ExecuteCommand('NeedsInput',[],[],swoNone);
   finally
    InputForm.Free;
    strList.Free;
   end;

  exit;
  end;
 //showmessage(PathToGitWizzard+'\winCommands\'+(Sender as TCommandButton).FileName+'.bat');
 ExecuteCommand((Sender as TCommandButton).FileName,[],[],swoNone);
end;




//The Popup
procedure TFrame1.OpenFileClick(Sender: TObject);
var aPath,s : string;
    sa      : array of string;
    lv      : integer;
begin
 FSender := nil;
 for lv := 0 to pred(CommandList.Count) do
  begin
   if TCommandButton(CommandList.Items[lv]).LastClick then FSender := TCommandButton(CommandList.Items[lv]);
   TCommandButton(CommandList.Items[lv]).LastClick:= false;
  end;
 if FSender = nil then FSender := gitignore;

 if not fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
  begin
   showmessage(rs_checkoptionsdialog);
   exit;
  end;

 {$IFDEF WINDOWS}
  aPath := PathToGitWizzard+PathDelim+'winCommands'+PathDelim;
  if FSender is TCommandButton then
   begin
    setlength(sa,1);
    sa[0] := aPath+(FSender as TCommandButton).FileName+'.bat';
    showmessage(FEditor);
    RunCommand(FEditor,sa,s,[],swoNone);   //if abfrage für showmessage
    showmessage(s);
   end;
  //if FSender is TCommandButton then
   //if not OpenDocument(aPath+(FSender as TCommandButton).FileName+'.bat') then showmessage(rs_filenotfound);
 {$ENDIF}
 {$IFDEF Linux}
 aPath := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim;
  if FSender is TCommandButton then
   begin
    setlength(sa,1);
    sa[0] := aPath+(FSender as TCommandButton).FileName+'.sh';
    RunCommand(FEditor,sa,s,[],swoNone);
    //if s <> 'ok' then showmessage(s);
   end;
 //if FSender is TCommandButton then
   //if not OpenDocument(aPath+(FSender as TCommandButton).FileName+'.sh') then showmessage(rs_filenotfound);
 {$ENDIF}
 if FSender = gitignore then
   if not OpenDocument(PathToGitDirectory+PathDelim+'.gitignore') then showmessage(rs_ignorenofound);
end;


procedure TFrame1.DeleteCommandClick(Sender: TObject);
var aPath : string;
    lv    : integer;
begin
 FSender := nil;
 for lv := 0 to pred(CommandList.Count) do
  begin
   if TCommandButton(CommandList.Items[lv]).LastClick then FSender := TCommandButton(CommandList.Items[lv]);
   TCommandButton(CommandList.Items[lv]).LastClick:= false;
  end;
 if FSender = nil then FSender := gitignore;

 {$IFDEF WINDOWS}
  aPath := PathToGitWizzard+PathDelim+'winCommands'+PathDelim;
  if FSender is TCommandButton then
   if deletefile(aPath+(FSender as TCommandButton).FileName+'.bat') then showmessage('Okay')
   else showmessage(rs_filenotfound);
 {$ENDIF}
 {$IFDEF Linux}
  aPath := PathToGitWizzard+PathDelim+'linuxCommands'+PathDelim;
  if FSender is TCommandButton then
   if deletefile(aPath+(FSender as TCommandButton).FileName+'.sh') then showmessage('Okay')
   else showmessage(rs_filenotfound);
 {$ENDIF}

 if FSender = gitignore then
  if deletefile(PathToGitDirectory+PathDelim+'.gitignore') then showmessage('Okay')
  else showmessage(rs_filenotfound);

 if FSender <> gitignore then
  begin
   CommandList.Delete((FSender as TCommandButton).Tag);
   AdjustTheButtons;
   WriteValues;
  end;
end;






end.

