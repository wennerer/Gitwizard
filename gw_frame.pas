{This is a part of GitWizard}

unit gw_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, Dialogs, StdCtrls,
  ExtCtrls, FileCtrl, LCLIntf, Menus, LazIDEIntf, FileUtil, DOM, XMLRead,
  XMLWrite, XPath, process, Contnrs, gettext, StrUtils, newcommand, input_form,
  options_form, Translations, LCLTranslator, DefaultTranslator, LMessages,
  LCLType, Graphics, gw_rsstrings, move_button, info_form, output_form, newtab,
  move_toatab, new_properties, Types, new_tabproperties;

type
 {TGWSeperator}
 TGWSeperator = class(TShape)
 public
 constructor Create(AOwner: TComponent); override;
 end;

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
   property LastClick  : boolean read FLastClick write FLastClick;
   procedure MouseDown({%H-}Button: TMouseButton;{%H-}Shift: TShiftState; X, Y: Integer);override;
  end;


type

  { TFrame1 }

  TFrame1 = class(TFrame)
    ImageList1                  : TImageList;
    deletecommand               : TMenuItem;
    addseperator: TMenuItem;
    rename: TMenuItem;
    PopupMenu_Tabsheet: TPopupMenu;
    properties: TMenuItem;
    movetotab                   : TMenuItem;
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
    ToolBar1                    : TToolBar;
    procedure addseperatorClick({%H-}Sender: TObject);
    procedure Checkgitignore;
    procedure Checkgitinit;
    procedure FrameResize({%H-}Sender: TObject);
    procedure gitignoreClick({%H-}Sender: TObject);
    procedure InputKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure movebuttonClick({%H-}Sender: TObject);
    procedure movetotabClick({%H-}Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1MouseDown({%H-}Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure propertiesClick({%H-}Sender: TObject);
    procedure ReadValues;
    procedure renameClick({%H-}Sender: TObject);
    procedure SpeedButton_createbackupClick({%H-}Sender: TObject);
    procedure SpeedButton_infoClick({%H-}Sender: TObject);
    procedure SpeedButton_newtabClick({%H-}Sender: TObject);
    procedure SpeedButton_opendirClick({%H-}Sender: TObject);
    procedure SpeedButton_optionsClick({%H-}Sender: TObject);
    procedure SpeedButton_restorebackupClick({%H-}Sender: TObject);
    procedure WriteValues;
    procedure deletecommandClick({%H-}Sender: TObject);
    procedure openfileClick({%H-}Sender: TObject);
    procedure SpeedButton_defgitignoreClick({%H-}Sender: TObject);
    procedure SpeedButton_LastSavedPackageClick({%H-}Sender: TObject);
    procedure SpeedButton_AnyDirClick({%H-}Sender: TObject);
    procedure SpeedButton_LastSavedProjectClick({%H-}Sender: TObject);
    procedure SpeedButton_NewCommandClick({%H-}Sender: TObject);
    procedure SpeedButton_SingleInputClick({%H-}Sender: TObject);
  private
    CommandList            : array of TObjectList;
    FSender                : TObject;
    FEditor                : string;
    PathToGitDirectory     : string; //The path to the directory that is to be versioned using git
    PathToGitWizard        : string; //The path to the directory where the gitwizard package is located
    Lang                   : string;
    FFirst                 : boolean;
    TabSheets              : array of TTabSheet;
    FTabCaptions           : string;
    FActiveTab             : integer;
    FLastTabClick          : integer;
    procedure CommandButtonClick(Sender: TObject);
    procedure ExecuteCommand(aCommandBash: String;Com: array of TProcessString; {%H-}Options: TProcessOptions=[];
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

{ TGWSeperator }

constructor TGWSeperator.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 Height         := 4;
 Pen.Style      := psClear;
 Brush.Color    := $00D4AA00 ;
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
 setlength(CommandList,1);
 CommandList[0]           := TObjectList.Create(True);
 setlength(TabSheets,1);
 TabSheets[0]             := TTabSheet.Create(self);
 TabSheets[0].Parent      := PageControl1;
 FActiveTab               := 0;
 gitignore.Parent         := TabSheets[0];
 gitignore.Align          := alTop;
 PathToEnviro    := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'packagefiles.xml';
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
 movetotab.Caption                           := rs_movetotab;
 properties.Caption                          := rs_newproperties;
 addseperator.Caption                        := rs_addseperator;
 rename.Caption                              := rs_rename;
 TabSheets[0].Caption                        := rs_favorites;
 FTabCaptions                                := rs_favorites;
end;


destructor TFrame1.Destroy;
var lv : integer;
begin
 for lv :=0 to length(CommandList) do
  FreeAndNil(CommandList[lv]);
 for lv :=0 to length(TabSheets) do
  FreeAndNil(TabSheets[lv]);
 if assigned(outputform) then outputform.Free;
 inherited Destroy;
end;

procedure TFrame1.WriteValues;
var Doc               : TXMLDocument;
    RootNode, ButtonNode,CaptionNode,HintNode,FilenameNode,NeedsInputNode,OptionsNode,
    LastNode,TabNode,SepNode,aText: TDOMNode;
    lv,i : integer;
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

  if CommandList[0].Count = 0 then exit;

  Doc := TXMLDocument.Create;

  RootNode := Doc.CreateElement('CommandButtons');
  Doc.Appendchild(RootNode);
  RootNode:= Doc.DocumentElement;

  try
   for i := 0 to pred(length(TabSheets)) do
    begin
     for lv:= 0 to pred(CommandList[i].Count) do
      begin
       ButtonNode   := Doc.CreateElement('Tabsheet_'+unicodestring(inttostr(i))+'_Commandbutton'+unicodestring(inttostr(lv)));
       RootNode.AppendChild(ButtonNode);
       if CommandList[i].Items[lv] is TCommandButton then
        begin
         CaptionNode   := Doc.CreateElement('Caption');
         aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList[i].Items[lv]).Caption));
         CaptionNode.AppendChild(aText);
         ButtonNode.AppendChild(CaptionNode);

         FilenameNode   := Doc.CreateElement('Filename');
         aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList[i].Items[lv]).FileName));
         FilenameNode.AppendChild(aText);
         ButtonNode.AppendChild(FilenameNode);

         HintNode   := Doc.CreateElement('Hint');
         aText   := Doc.CreateTextNode(Unicodestring(TCommandButton(CommandList[i].Items[lv]).Hint));
         HintNode.AppendChild(aText);
         ButtonNode.AppendChild(HintNode);

         if TCommandButton(CommandList[i].Items[lv]).NeedsInput then s:='true' else s:='false';
         NeedsInputNode   := Doc.CreateElement('NeedsInput');
         aText   := Doc.CreateTextNode(Unicodestring(s));
         NeedsInputNode.AppendChild(aText);
         ButtonNode.AppendChild(NeedsInputNode);
        end
       else
        begin
         SepNode   := Doc.CreateElement('Seperator');
         aText   := Doc.CreateTextNode(Unicodestring('Seperator'+inttostr(lv)));
         SepNode.AppendChild(aText);
         ButtonNode.AppendChild(SepNode);
        end;
     end;
    end;//length(Tabsheet)
    writeXMLFile(Doc,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml');
  finally
    Doc.Free;
  end;

end;

procedure TFrame1.ReadValues;
var xml                 :  TXMLDocument;
    k,i,i1,i2,j,cl      : integer;
    bol,s               : string;
    XPathResult         : TXPathVariable;
    APtr                :Pointer;

  procedure ParseXML(Node : TDomNode);
  begin
   while (Assigned(Node)) do
    begin
      if (Node.NodeName <> '')  then
       begin
        if Pos('Tabsheet_',Node.NodeName) <> 0 then
         begin
         s := string(Node.NodeName);
         i1 := pos('_',s)+1;
         i2 := PosEx('_',s,i1);
         i2 := i2-i1;
         s:= copy(s,i1,i2);
         Try
          cl := strtoint(s);
         except
          On E : EConvertError do showmessage('Error by ReadValues');
         end;

           CommandList[cl].Add(TCommandButton.Create(self));
           TCommandButton(CommandList[cl].Last).Parent     := TabSheets[cl];
           TCommandButton(CommandList[cl].Last).BorderSpacing.Around:= 2;
           i := CommandList[cl].Count-2;
           if CommandList[cl].Count = 1 then
            TCommandButton(CommandList[cl].Last).AnchorSideTop.Control := gitignore
           else
            TCommandButton(CommandList[cl].Last).AnchorSideTop.Control := TCommandButton(CommandList[cl].Items[i]);
           TCommandButton(CommandList[cl].Last).AnchorSideTop.Side     := asrBottom;
           TCommandButton(CommandList[cl].Last).AnchorSideLeft.Control := TabSheets[cl];
           TCommandButton(CommandList[cl].Last).AnchorSideRight.Control:= TabSheets[cl];
           TCommandButton(CommandList[cl].Last).AnchorSideRight.Side   := asrBottom;
           TCommandButton(CommandList[cl].Last).Anchors := [akLeft, akRight, akTop];
           TCommandButton(CommandList[cl].Last).Tag                    := CommandList[cl].Count-1;
           TCommandButton(CommandList[cl].Last).ShowHint               := true;
           TCommandButton(CommandList[cl].Last).OnClick                := @CommandButtonClick;
           TCommandButton(CommandList[cl].Last).PopupMenu              := PopupMenu_CommandButtons;
           TCommandButton(CommandList[cl].Last).LastClick              := false;
           TCommandButton(CommandList[cl].Last).Images                 := ImageList1;
           TCommandButton(CommandList[cl].Last).Layout                 := blGlyphRight;
           inc(k);
          end;
         if Node.NodeName = '#text' then
          begin
           if Pos('Seperator',string(Node.NodeValue)) <> 0 then
            begin
             CommandList[cl].Delete(CommandList[cl].Count-1);
             CommandList[cl].Add(TGWSeperator.Create(self));
             TGWSeperator(CommandList[cl].Last).Parent     := TabSheets[cl];
             TGWSeperator(CommandList[cl].Last).BorderSpacing.Around:= 2;
             TGWSeperator(CommandList[cl].Last).AnchorSideTop.Control := TGWSeperator(CommandList[cl].Items[i]);
             TGWSeperator(CommandList[cl].Last).AnchorSideTop.Side     := asrBottom;
             TGWSeperator(CommandList[cl].Last).AnchorSideLeft.Control := TabSheets[cl];
             TGWSeperator(CommandList[cl].Last).AnchorSideRight.Control:= TabSheets[cl];
             TGWSeperator(CommandList[cl].Last).AnchorSideRight.Side   := asrBottom;
             TGWSeperator(CommandList[cl].Last).Anchors := [akLeft, akRight, akTop];
             TGWSeperator(CommandList[cl].Last).Tag                    := CommandList[cl].Count-1;
            end
           else
           begin
           if j = 0 then TCommandButton(CommandList[cl].Last).Caption := string(Node.NodeValue);
           if j = 1 then TCommandButton(CommandList[cl].Last).FileName := string(Node.NodeValue);
           if j = 2 then TCommandButton(CommandList[cl].Last).Hint := string(Node.NodeValue);
           if j = 3 then
            begin
             bol := string(Node.NodeValue);
             if bol = 'true' then TCommandButton(CommandList[cl].Last).NeedsInput := true
             else TCommandButton(CommandList[cl].Last).NeedsInput := false;
            end;//bol
           inc(j);
           if j=4 then j:=0;
           end;
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
var lv,i : integer;
begin
 for i := 0 to pred(length(TabSheets)) do
 for lv:=0 to pred(CommandList[i].Count) do
  begin
   if CommandList[i].Items[lv] is TCommandButton then
    TCommandButton(CommandList[i].Items[lv]).Anchors:=[]
   else
    TGWSeperator(CommandList[i].Items[lv]).Anchors:=[];
   if lv = 0 then
    begin
     if i = 0  then
      begin
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Control := gitignore;
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Side     := asrBottom;
      end;
     if i <> 0 then
      begin
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Control := TabSheets[i];
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Side     := asrTop;
      end;
     TCommandButton(CommandList[i].Items[lv]).AnchorSideLeft.Control := TabSheets[i];
     TCommandButton(CommandList[i].Items[lv]).AnchorSideRight.Control:= TabSheets[i];
     TCommandButton(CommandList[i].Items[lv]).AnchorSideRight.Side   := asrBottom;
     TCommandButton(CommandList[i].Items[lv]).Anchors := [akLeft, akRight, akTop];
    end
   else
    begin
     if CommandList[i].Items[lv] is TCommandButton then
      begin
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Control := TCommandButton(CommandList[i].Items[lv-1]);
       TCommandButton(CommandList[i].Items[lv]).AnchorSideTop.Side     := asrBottom;
       TCommandButton(CommandList[i].Items[lv]).AnchorSideLeft.Control := TabSheets[i];
       TCommandButton(CommandList[i].Items[lv]).AnchorSideRight.Control:= TabSheets[i];
       TCommandButton(CommandList[i].Items[lv]).AnchorSideRight.Side   := asrBottom;
       TCommandButton(CommandList[i].Items[lv]).Anchors := [akLeft, akRight, akTop];
      end
     else
      begin
       TGWSeperator(CommandList[i].Items[lv]).AnchorSideTop.Control := TCommandButton(CommandList[i].Items[lv-1]);
       TGWSeperator(CommandList[i].Items[lv]).AnchorSideTop.Side     := asrBottom;
       TGWSeperator(CommandList[i].Items[lv]).AnchorSideLeft.Control := TabSheets[i];
       TGWSeperator(CommandList[i].Items[lv]).AnchorSideRight.Control:= TabSheets[i];
       TGWSeperator(CommandList[i].Items[lv]).AnchorSideRight.Side   := asrBottom;
       TGWSeperator(CommandList[i].Items[lv]).Anchors := [akLeft, akRight, akTop];
      end;
    end;
  end;//pred(CommandList[0].Count)

end;

procedure TFrame1.CreateTabs;
var sl : TStringlist;
    lv : integer;
begin
 sl := TStringlist.Create;
 try
  sl.Delimiter:=';';
  sl.DelimitedText:= FTabCaptions;

  for lv := 1 to pred(sl.Count) do
   begin
    setlength(TabSheets,sl.Count);
    TabSheets[lv]              := TTabSheet.Create(self);
    TabSheets[lv].Parent       := PageControl1;
    TabSheets[lv].Caption      := sl[lv];
    setlength(CommandList,sl.Count);
    CommandList[lv]      := TObjectList.Create(True);
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
  if aCommandBash <> 'makeexecutable' then
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

 if RunCommandInDir(PathToGitDirectory,pathtobash,Com,s,[poStderrToOutput],swOptions) then
  begin
   outputform   := TOutPutForm.Create(self);
   sl := TStringList.Create;
   try
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
   for lv:=0 to pred(CommandList[0].Count) do
    begin
     s := TCommandButton(CommandList[0].Items[lv]).Caption;
     i := Pos('init',s);
     if i <> 0 then TCommandButton(CommandList[0].Items[lv]).ImageIndex:=14;
    end;//count
  end //exists
 else
  begin
   for lv:=0 to pred(CommandList[0].Count) do
    begin
     s := TCommandButton(CommandList[0].Items[lv]).Caption;
     i := Pos('init',s);
     if i <> 0 then TCommandButton(CommandList[0].Items[lv]).ImageIndex:=-1;
    end;
  end;
end;

procedure TFrame1.FrameResize(Sender: TObject);
var xml     :  TXMLDocument;
    XPathResult: TXPathVariable;
    APtr:Pointer;
begin
 if not FFirst then exit;
 FFirst := false;
//CreateTabs needs FTabCaptions
 if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
   begin
    ReadXMLFile(Xml,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml');
    XPathResult := EvaluateXPathExpression('/Options/Tabsheet/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     FTabCaptions := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;
    Xml.Free;
  end;
 CreateTabs;
 if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'gw_commands.xml') then ReadValues;
 if PathToGitDirectory = '' then exit;
 Path_Panel.Caption := AdjustText(PathToGitDirectory,Path_Panel);
 Path_Panel.Hint:= PathToGitDirectory;
 Checkgitignore;
 Checkgitinit;
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


    if InputForm.ShowModal = mrCancel then exit;
    showmessage('da');
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


procedure TFrame1.PageControl1Change(Sender: TObject);
begin
 if sender is TPagecontrol then FActiveTab := PageControl1.TabIndex;
end;

procedure TFrame1.PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button = mbRight then
  FLastTabClick := PageControl1.IndexOfPageAt(Point(X, Y));
end;

{$Include gw_speedbuttons.inc}
{$Include gw_popups.inc}

end.

