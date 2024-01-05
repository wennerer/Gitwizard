unit gw_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, Dialogs, StdCtrls,
  ExtCtrls, FileCtrl, LCLIntf, Menus, LazIDEIntf, FileUtil, DOM, XMLRead, XPath,
  process, Contnrs, StrUtils, newcommand;

resourcestring
  rs_comnotfound = 'Command-File not found!';
  rs_comerror    = 'The command is incorrect!';
  rs_ignorenofound = 'Default gitignore not found!';
  rs_nodirectoryselected = 'No directory selected!';
  rs_Filealreadyexists = 'File already exists';

type

  { CommandButton }

  { TCommandButton }

  TCommandButton = class(TButton)

  private
    FFileName  : string;
    FNeedsInput: boolean;
  public
   property FileName   : string  read FFileName   write FFileName;
   property NeedsInput : boolean read FNeedsInput write FNeedsInput;
  end;




type

  { TFrame1 }

  TFrame1 = class(TFrame)
    Git_init               : TButton;
    gitignore              : TButton;
    ImageList1             : TImageList;
    deletebash: TMenuItem;
    openbash: TMenuItem;
    Path_Panel             : TPanel;
    Input                  : TEdit;
    GitDirectoryDlg        : TSelectDirectoryDialog;
    PopupMenu_CommandButtons             : TPopupMenu;
    Separator_Shape1       : TShape;


    SpeedButton_NewCommand: TSpeedButton;
    SpeedButton_defgitignore: TSpeedButton;
    SpeedButton_SingleInput: TSpeedButton;
    SpeedButton_LastSavedPackage: TSpeedButton;
    SpeedButton_AnyDir       : TSpeedButton;
    SpeedButton_LastSavedProject: TSpeedButton;
    ToolBar1               : TToolBar;
    procedure deletebashClick(Sender: TObject);
    procedure gitignoreMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Git_initClick(Sender: TObject);
    procedure openbashClick(Sender: TObject);
    procedure SpeedButton_defgitignoreClick(Sender: TObject);
    procedure SpeedButton_LastSavedPackageClick(Sender: TObject);
    procedure SpeedButton_AnyDirClick(Sender: TObject);
    procedure SpeedButton_LastSavedProjectClick(Sender: TObject);
    procedure SpeedButton_NewCommandClick(Sender: TObject);
    procedure SpeedButton_SingleInputClick(Sender: TObject);
  private
    CommandList            : TObjectList;
    PathToGitDirectory     : string; //The path to the directory that is to be versioned using git
    PathToGitWizzard       : string; //The path to the directory where the gitwizzard package is located
    procedure CommandButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExecuteCommand(aCommandBash: String;
      Com: array of TProcessString; Options: TProcessOptions=[];
      swOptions: TShowWindowOptions=swoNone);
    procedure SaveABashfile(aFileName, aCommand: string);
    procedure SetPathToGitDirectory(aPath: string);
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
  Path        : string;
  i           : integer;
begin
  Path:= '';
  ReadXMLFile(Xml, aFilename);
  XPathResult := EvaluateXPathExpression(aSearchString, Xml.DocumentElement);
  For APtr in XPathResult.AsNodeSet do
    Path := Path + string(TDOMNode(APtr).NodeValue);
  XPathResult.Free;
  Xml.Free;

  Path:=ReverseString(Path);
  i:=Pos('/',Path);
  Delete(Path, 1, i);
  Path:=ReverseString(Path);

  Result := Path;
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
end;

destructor TFrame1.Destroy;
begin
 FreeAndNil(CommandList);
 inherited Destroy;
end;

procedure TFrame1.SetPathToGitDirectory(aPath : string);
begin
 if PathToGitDirectory = '' then exit;
 Path_Panel.Caption := AdjustText(aPath,Path_Panel);
 Path_Panel.Hint:= aPath;

 //Checks whether git has already been initialised
 if DirectoryExists(aPath+PathDelim+'.git') then Git_init.Enabled:= false
  else Git_init.Enabled:=true;
end;

procedure TFrame1.SaveABashfile(aFileName,aCommand:string);
var strList          : TStringList;
begin
 strList  := TStringlist.Create;
 try
  strList.Add('#!/bin/bash');
  strList.Add(aCommand);
  strList.SaveToFile(PathToGitWizzard+'/linuxCommands/'+aFileName+'.sh');
 finally
  strList.Free;
 end;

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
 TCommandButton(CommandList.Last).OnMouseDown            := @CommandButtonMouseDown;
 SaveABashfile(TCommandButton(CommandList.Last).FileName,aCommand);
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
    pathtobash := comdir + aBash+'.bat';
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
  strList.Add('#!/bin/bash');
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizzard+'/linuxCommands/singlecommand.sh');
 finally
  strList.Free;
 end;
 ExecuteCommand('singlecommand',[],[],swoNone);
end;

procedure TFrame1.CommandButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ExecuteCommand((Sender as TCommandButton).FileName,[],[],swoNone);
end;




//The Popup
procedure TFrame1.openbashClick(Sender: TObject);
begin
 if not OpenDocument(PathToGitDirectory+PathDelim+'.gitignore')
     then showmessage(rs_ignorenofound);
end;

procedure TFrame1.deletebashClick(Sender: TObject);
begin
 showmessage('Delete Bash');
end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----Commands----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.Git_initClick(Sender: TObject);
begin
 ExecuteCommand('git_init',[],[],swoNone);
 //Checks whether git has already been initialised
 if DirectoryExists(PathToGitDirectory+PathDelim+'.git') then Git_init.Enabled:= false
  else Git_init.Enabled:=true;
end;

procedure TFrame1.gitignoreMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if PathToGitDirectory = '' then
  begin
   showmessage(rs_nodirectoryselected);
   exit;
  end;
 if Button = mbRight then PopupMenu_CommandButtons.PopUp
 else
  begin
   if FileExists(PathToGitDirectory+PathDelim+'.gitignore') then
    begin
     showmessage(rs_Filealreadyexists);
     exit;
    end;
   CopyFile(PathToGitWizzard+PathDelim+'defaultgitignore'+PathDelim+'.gitignore',
            PathToGitDirectory+PathDelim+'.gitignore');
  end;
end;






end.

