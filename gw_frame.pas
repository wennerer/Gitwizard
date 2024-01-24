{This is a part of GitWizard}

unit gw_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, Dialogs, StdCtrls,
  ExtCtrls, FileCtrl, LCLIntf, Menus, LazIDEIntf, FileUtil, DOM, XMLRead,
  XMLWrite, XPath, process, Contnrs, gettext, StrUtils, newcommand, input_form,
  options_form, Translations, LCLTranslator, DefaultTranslator, LMessages,
  LCLType, gw_rsstrings, move_button, info_form, output_form, newtab;



type
 { TCommandButton }

  TCommandButton = class(TSpeedButton)

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
    ImageList1                  : TImageList;
    deletecommand               : TMenuItem;
    movebutton                  : TMenuItem;
    openfile                    : TMenuItem;
    PageControl1                : TPageControl;
    Path_Panel                  : TPanel;
    Input                       : TEdit;
    GitDirectoryDlg             : TSelectDirectoryDialog;
    PopupMenu_CommandButtons    : TPopupMenu;
    ScrollBox1                  : TScrollBox;
    Separator_Shape1            : TShape;
    gitignore                   : TSpeedButton;
    SpeedButton_newtab          : TSpeedButton;
    SpeedButton_info            : TSpeedButton;
    SpeedButton_restorebackup   : TSpeedButton;
    SpeedButton_createbackup    : TSpeedButton;
    SpeedButton_opendir         : TSpeedButton;
    SpeedButton_options         : TSpeedButton;
    SpeedButton_NewCommand      : TSpeedButton;
    SpeedButton_defgitignore    : TSpeedButton;
    SpeedButton_SingleInput     : TSpeedButton;
    SpeedButton_LastSavedPackage: TSpeedButton;
    SpeedButton_AnyDir          : TSpeedButton;
    SpeedButton_LastSavedProject: TSpeedButton;
    TabSheet_favorites          : TTabSheet;
    ToolBar1                    : TToolBar;
    procedure Checkgitignore;
    procedure Checkgitinit;
    procedure FrameResize(Sender: TObject);
    procedure gitignoreClick(Sender: TObject);
    procedure InputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure movebuttonClick(Sender: TObject);
    procedure ReadValues;
    procedure SpeedButton_createbackupClick(Sender: TObject);
    procedure SpeedButton_infoClick(Sender: TObject);
    procedure SpeedButton_newtabClick(Sender: TObject);
    procedure SpeedButton_opendirClick(Sender: TObject);
    procedure SpeedButton_optionsClick(Sender: TObject);
    procedure SpeedButton_restorebackupClick(Sender: TObject);
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
    PathToGitWizard        : string; //The path to the directory where the gitwizard package is located
    Lang                   : string;
    FFirst                 : boolean;
    TabSheets              : array of TTabSheet;
    FTabCaptions           : string;
    procedure CommandButtonClick(Sender: TObject);
    procedure ExecuteCommand(aCommandBash: String;Com: array of TProcessString; Options: TProcessOptions=[];
                             swOptions: TShowWindowOptions=swoNone);
    procedure SaveABashfile(aFileName, aCommand: string);
    procedure SetPathToGitDirectory(aPath: string);
    procedure AdjustTheButtons;
    procedure CreateTabs;
  protected

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

procedure DeleteAFolder(aFolder: string);
var sl : TStringList;
    lv : integer;
begin
 sl := TStringlist.Create;
 try
  FindAllFiles(sl,aFolder,'*',false);
  for lv :=0 to pred(sl.Count) do
   DeleteFile(sl[lv]);
 finally
  sl.Free;
 end;
end;

procedure CopyAFolder(aSourceFolder,aDestFolder: string);
var sl : TStringList;
    lv : integer;
    s  : string;
begin
 sl := TStringlist.Create;
 try
  FindAllFiles(sl,aSourceFolder,'*',false);
  for lv :=0 to pred(sl.Count) do
   begin
    copyfile(sl[lv],aDestFolder+ExtractFileName(sl[lv]));
    {$IFDEF Linux}
     if not RunCommandInDir(aDestFolder,'chmod a+x '+aDestFolder+ExtractFileName(sl[lv]),s)
      then showmessage(s);
    {$ENDIF}
   end;
 finally
  sl.Free;
 end;
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
    localedir,s      : string;
begin
 inherited Create(AOwner);
 CommandList := TObjectList.Create(True);
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'packagefiles.xml';
 PathToGitWizard := ReadPathToDir(PathToEnviro,'/CONFIG/UserPkgLinks//*[Name[@Value="laz_gitwizard"]]/Filename/@*');

 FFirst := true;

 GetLanguageIDs(s{%H-},lang{%H-});
 SetDefaultlang(lang);

 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'gw_rsstrings.%s.po';
 Translations.TranslateUnitResourceStrings('gw_rsstrings', Format(localedir, [lang]));
 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'gw_frame.%s.po';
 Translations.TranslateUnitResourceStrings('gw_frame', Format(localedir, [lang]));
 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'newcommand.%s.po';
 Translations.TranslateUnitResourceStrings('newcommand', Format(localedir, [lang]));
 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'input_form.%s.po';
 Translations.TranslateUnitResourceStrings('input_form', Format(localedir, [lang]));
 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'options_form.%s.po';
 Translations.TranslateUnitResourceStrings('options_form', Format(localedir, [lang]));
 localedir := PathToGitWizard+Pathdelim+'locale'+PathDelim+'move_button.%s.po';
 Translations.TranslateUnitResourceStrings('move_button', Format(localedir, [lang]));

 Input.Hint                                  := rs_forcommans;
 SpeedButton_SingleInput.Hint                := rs_excecute;
 SpeedButton_AnyDir.Hint                     := rs_AnyDirHint;
 SpeedButton_LastSavedProject.Hint           := rs_LastSavedProject;
 SpeedButton_LastSavedPackage.Hint           := rs_LastSavePackage;
 SpeedButton_defgitignore.Hint               := rs_defgitignore;
 SpeedButton_NewCommand.Hint                 := rs_newCommand;
 SpeedButton_opendir.Hint                    := rs_opendir;
 SpeedButton_options.Hint                    := rs_options;
 SpeedButton_createbackup.Hint               := rs_createbackup;
 SpeedButton_restorebackup.Hint              := rs_restorebackup;
 SpeedButton_info.Hint                       := rs_Info;
 SpeedButton_newtab.Hint                     := rs_newtab;

 openfile.Caption                            := rs_openfile;
 deletecommand.Caption                       := rs_deletecommand;
 movebutton.Caption                          := rs_movebutton;
 TabSheet_favorites.Caption                  := rs_favorites;
 FTabCaptions                                := 'no';
end;


destructor TFrame1.Destroy;
begin
 FreeAndNil(CommandList);
 if assigned(outputform) then outputform.Free;
 inherited Destroy;
end;

procedure TFrame1.WriteValues;
var Doc               : TXMLDocument;
    RootNode, ButtonNode,CaptionNode,HintNode,FilenameNode,NeedsInputNode,OptionsNode,
    LastNode,TabNode,aText: TDOMNode;
    lv : integer;
    s  : string;
begin
 try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('Options');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    OptionsNode := Doc.CreateElement('Editor');
    TDOMElement(OptionsNode).SetAttribute('Editor',unicodestring(FEditor));
    RootNode.Appendchild(OptionsNode);

    LastNode := Doc.CreateElement('Last');
    TDOMElement(LastNode).SetAttribute('Last',unicodestring(PathToGitDirectory));
    RootNode.Appendchild(LastNode);

    TabNode := Doc.CreateElement('Tabsheet');
    TDOMElement(TabNode).SetAttribute('TabCaptions',unicodestring(FTabCaptions));
    RootNode.Appendchild(TabNode);

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
         if Node.NodeName = 'Commandbutton'+unicodestring(inttostr(k)) then
          begin
           CommandList.Add(TCommandButton.Create(self));
           TCommandButton(CommandList.Last).Parent     := TabSheet_favorites;
           TCommandButton(CommandList.Last).BorderSpacing.Around:= 2;
           i := CommandList.Count-2;
           if CommandList.Count = 1 then
            TCommandButton(CommandList.Last).AnchorSideTop.Control := gitignore
           else
            TCommandButton(CommandList.Last).AnchorSideTop.Control := TCommandButton(CommandList.Items[i]);
           TCommandButton(CommandList.Last).AnchorSideTop.Side     := asrBottom;
           TCommandButton(CommandList.Last).AnchorSideLeft.Control := TabSheet_favorites;
           TCommandButton(CommandList.Last).AnchorSideRight.Control:= TabSheet_favorites;
           TCommandButton(CommandList.Last).AnchorSideRight.Side   := asrBottom;
           TCommandButton(CommandList.Last).Anchors := [akLeft, akRight, akTop];
           TCommandButton(CommandList.Last).Tag                    := CommandList.Count-1;
           TCommandButton(CommandList.Last).ShowHint               := true;
           TCommandButton(CommandList.Last).OnClick                := @CommandButtonClick;
           TCommandButton(CommandList.Last).PopupMenu              := PopupMenu_CommandButtons;
           TCommandButton(CommandList.Last).LastClick              := false;
           TCommandButton(CommandList.Last).Images                 := ImageList1;
           TCommandButton(CommandList.Last).Layout                 := blGlyphRight;
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
     FEditor := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;

    XPathResult := EvaluateXPathExpression('/Options/Last/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     PathToGitDirectory := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;

     XPathResult := EvaluateXPathExpression('/Options/Tabsheet/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     FTabCaptions := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;

    Xml.Free;
  end;
end;

procedure TFrame1.SetPathToGitDirectory(aPath : string);
var Doc               : TXMLDocument;
    RootNode,OptionsNode,LastNode,TabNode: TDOMNode;
begin
 if PathToGitDirectory = '' then exit;
 Path_Panel.Caption := AdjustText(aPath,Path_Panel);
 Path_Panel.Hint:= aPath;
 Checkgitinit;
 Checkgitignore;
 try
    Doc := TXMLDocument.Create;

    RootNode := Doc.CreateElement('Options');
    Doc.Appendchild(RootNode);
    RootNode:= Doc.DocumentElement;

    OptionsNode := Doc.CreateElement('Editor');
    TDOMElement(OptionsNode).SetAttribute('Editor',unicodestring(FEditor));
    RootNode.Appendchild(OptionsNode);

    LastNode := Doc.CreateElement('Last');
    TDOMElement(LastNode).SetAttribute('Last',unicodestring(PathToGitDirectory));
    RootNode.Appendchild(LastNode);

    TabNode := Doc.CreateElement('Tabsheet');
    TDOMElement(TabNode).SetAttribute('TabCaptions',unicodestring(FTabCaptions));
    RootNode.Appendchild(TabNode);

    writeXMLFile(Doc,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_options.xml');
  finally
    Doc.Free;
  end;
end;

procedure TFrame1.AdjustTheButtons;
var lv : integer;
begin
 for lv:=0 to pred(CommandList.Count) do
  begin
   TCommandButton(CommandList.Items[lv]).Anchors:=[];
   if lv = 0 then
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Control := gitignore
   else
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Control := TCommandButton(CommandList.Items[lv-1]);
    TCommandButton(CommandList.Items[lv]).AnchorSideTop.Side     := asrBottom;
    TCommandButton(CommandList.Items[lv]).AnchorSideLeft.Control := ScrollBox1;
    TCommandButton(CommandList.Items[lv]).AnchorSideRight.Control:= ScrollBox1;
    TCommandButton(CommandList.Items[lv]).AnchorSideRight.Side   := asrBottom;
    TCommandButton(CommandList.Items[lv]).Anchors := [akLeft, akRight, akTop];
  end;
end;

procedure TFrame1.CreateTabs;
var sl : TStringlist;
    lv : integer;
begin
 if FTabCaptions = 'no' then exit;

 sl := TStringlist.Create;
 try
  sl.Delimiter:=';';
  sl.DelimitedText:= FTabCaptions;
  for lv := 0 to pred(sl.Count) do
   begin
    setlength(TabSheets,sl.Count);
    TabSheets[lv]              := TTabSheet.Create(self);
    TabSheets[lv].Parent       := PageControl1;
    TabSheets[lv].Caption      := sl[lv];
   end;
 finally
  sl.Free;
 end;


end;

procedure TFrame1.SaveABashfile(aFileName,aCommand:string);
var strList          : TStringList;
begin
 strList  := TStringlist.Create;
 try
  {$IFDEF WINDOWS}
   strList.Add(aCommand);
   strList.SaveToFile(PathToGitWizard+'\winCommands\'+aFileName+'.bat');
  {$ENDIF}
  {$IFDEF Linux}
   strList.Add('#!/bin/bash');
   strList.Add(aCommand);
   strList.SaveToFile(PathToGitWizard+'/linuxCommands/'+aFileName+'.sh');
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
  strList.Add('chmod a+x '+PathToGitWizard+'/linuxCommands/'+aFileName+'.sh');
  strList.SaveToFile(PathToGitWizard+'/linuxCommands/makeexecutable.sh');
 finally
  strList.Free;
 end;
 ExecuteCommand('makeexecutable',[],[],swoNone);
end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----Execute Commands----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.ExecuteCommand(aCommandBash:String;Com:array of TProcessString;
                                   Options:TProcessOptions=[];swOptions:TShowWindowOptions=swoNone);
var pathtobash : string;
    s : ansistring;
    sl           : TStringList;
    lv           : integer;

begin
  if PathToGitDirectory = '' then
  begin
   showmessage(rs_nodirectoryselected);
   exit;
  end;

 {$IFDEF WINDOWS}
    pathtobash := PathToGitWizard+PathDelim+'winCommands'+PathDelim+ aCommandBash+'.bat';
 {$ENDIF}
 {$IFDEF Linux}
    pathtobash := PathToGitWizard+PathDelim+'linuxCommands'+PathDelim+ aCommandBash+'.sh';
 {$ENDIF}
 if not fileexists(pathtobash) then
  begin
   showmessage(rs_comnotfound);
   exit;
  end;
 s:= '';

 //if RunCommandInDir(PathToGitDirectory,pathtobash,Com,s,[poStderrToOutput],swOptions) then showmessage(s)
  //else showmessage(rs_comerror);
 if RunCommandInDir(PathToGitDirectory,pathtobash,Com,s,[poStderrToOutput],swOptions) then
  begin
   outputform   := TOutPutForm.Create(self);
   sl := TStringList.Create;
   try
    //if pos('\',s) <> 0 then showmessage('Escape Sequenz da');
    sl.Text:=s;
    if sl.Count <> 0 then
     begin
      for lv:= 0 to sl.Count-1 do
      outputform.SynEdit1.Lines.Add(sl[lv]);
      outputform.Show;
     end else showmessage('Okay');
   finally
    sl.Free;
   end;
  end //run
 else showmessage(rs_comerror);
end;

procedure TFrame1.SpeedButton_SingleInputClick(Sender: TObject);
var strList          : TStringList;
begin
 strList  := TStringlist.Create;
 try
 {$IFDEF WINDOWS}
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizard+'\winCommands\singlecommand.bat');
 {$ENDIF}
 {$IFDEF Linux}
  strList.Add('#!/bin/bash');
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizard+'/linuxCommands/singlecommand.sh');
  {$ENDIF}
 finally
  strList.Free;
 end;
 ExecuteCommand('singlecommand',[],[],swoNone);
end;

procedure TFrame1.Checkgitignore;
begin
 if FileExists(PathToGitDirectory+PathDelim+'.gitignore') then
 gitignore.ImageIndex:= 14 else gitignore.ImageIndex:= -1;
end;

procedure TFrame1.Checkgitinit;
var lv,i : integer;
    s    : string;
begin
 //Checks whether git has already been initialised
 if DirectoryExists(PathToGitDirectory+PathDelim+'.git') then
  begin
   for lv:=0 to pred(CommandList.Count) do
    begin
     s := TCommandButton(CommandList.Items[lv]).Caption;
     i := Pos('init',s);
     if i <> 0 then TCommandButton(CommandList.Items[lv]).ImageIndex:=14;
    end;//count
  end //exists
 else
  begin
   for lv:=0 to pred(CommandList.Count) do
    begin
     s := TCommandButton(CommandList.Items[lv]).Caption;
     i := Pos('init',s);
     if i <> 0 then TCommandButton(CommandList.Items[lv]).ImageIndex:=-1;
    end;
  end;
end;

procedure TFrame1.FrameResize(Sender: TObject);
begin
 if not FFirst then exit;
 FFirst := false;
 if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml') then ReadValues;
 if PathToGitDirectory = '' then exit;
 Path_Panel.Caption := AdjustText(PathToGitDirectory,Path_Panel);
 Path_Panel.Hint:= PathToGitDirectory;
 Checkgitignore;
 Checkgitinit;
 CreateTabs;
 BringToFront;
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
 if CopyFile(PathToGitWizard+PathDelim+'defaultgitignore'+PathDelim+'.gitignore',
             PathToGitDirectory+PathDelim+'.gitignore')
 then showmessage('Ok') else showmessage('Error');
 Checkgitignore;
end;

procedure TFrame1.InputKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_RETURN then SpeedButton_SingleInputClick(Sender);
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
      strList.LoadFromFile(PathToGitWizard+'\winCommands\'+(Sender as TCommandButton).FileName+'.bat');
      InputForm.Edit_Complete.Text := strList[0];
    {$ENDIF}
    {$IFDEF Linux}
     strList.LoadFromFile(PathToGitWizard+'/linuxCommands/'+(Sender as TCommandButton).FileName+'.sh');
     InputForm.Edit_Complete.Text := strList[1];
    {$ENDIF}


    InputForm.ShowModal;

    SaveABashfile('NeedsInput',InputForm.Edit_Complete.Text);
    ExecuteCommand('NeedsInput',[],[],swoNone);
   finally
    InputForm.Free;
    strList.Free;
   end;

  exit;
  end;

 ExecuteCommand((Sender as TCommandButton).FileName,[],[],swoNone);
 Checkgitinit;
end;

{$Include gw_speedbuttons.inc}
{$Include gw_popups.inc}

end.

