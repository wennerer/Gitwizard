unit gw_frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, Dialogs, StdCtrls,
  ExtCtrls, FileCtrl, LazIDEIntf, DOM, XMLRead, XPath, process, StrUtils;

resourcestring
  rs_comnotfound = 'Command-File not found';
  rs_comerror    = 'The command is incorrect';
type

  { TFrame1 }

  TFrame1 = class(TFrame)
    Git_init: TButton;
    ImageList1             : TImageList;
    Path_Panel             : TPanel;
    Input : TEdit;
    GitDirectoryDlg        : TSelectDirectoryDialog;
    Separator_Shape1: TShape;
    SpeedButton_SingleInput: TSpeedButton;
    SpeedButton_LastSavedPackage: TSpeedButton;
    SpeedButton_Open       : TSpeedButton;
    SpeedButton_LastSavedProject: TSpeedButton;
    ToolBar1               : TToolBar;
    procedure Git_initClick(Sender: TObject);
    procedure SpeedButton_LastSavedPackageClick(Sender: TObject);
    procedure SpeedButton_OpenClick(Sender: TObject);
    procedure SpeedButton_LastSavedProjectClick(Sender: TObject);
    procedure SpeedButton_SingleInputClick(Sender: TObject);
  private
    PathToGitDirectory     : string; //The path to the directory that is to be versioned using git
    PathToGitWizzard       : string; //The path to the directory where the gitwizzard package is located
    procedure ExecuteCommand(aCommandBash: String;
      Com: array of TProcessString; Options: TProcessOptions=[];
      swOptions: TShowWindowOptions=swoNone);
    procedure SetPathToGitDirectory(aPath: string);
  public
    constructor Create(AOwner: TComponent); override;
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
begin
  inherited Create(AOwner);
end;

procedure TFrame1.SetPathToGitDirectory(aPath : string);
var PathToEnviro     : string;
begin
 Path_Panel.Caption := AdjustText(aPath,Path_Panel);
 Path_Panel.Hint:= aPath;

 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'packagefiles.xml';
 PathToGitWizzard := ReadPathToDir(PathToEnviro,'/CONFIG/UserPkgLinks//*[Name[@Value="laz_gitwizzard"]]/Filename/@*');

 //Checks whether git has already been initialised
 if DirectoryExists(aPath+PathDelim+'.git') then Git_init.Enabled:= false
  else Git_init.Enabled:=true;
end;

procedure TFrame1.SpeedButton_OpenClick(Sender: TObject);
begin
 if GitDirectoryDlg.Execute then
  PathToGitDirectory := GitDirectoryDlg.FileName;
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

procedure TFrame1.SpeedButton_LastSavedProjectClick(Sender: TObject);
var PathToEnviro : string;
    //sarchstring  : string;
begin
 PathToEnviro := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+'environmentoptions.xml';
 PathToGitDirectory := ReadPathToDir(PathToEnviro,'/CONFIG/EnvironmentOptions/AutoSave/@*');
 SetPathToGitDirectory(PathToGitDirectory);
end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----Commands----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

procedure TFrame1.ExecuteCommand(aCommandBash:String;Com:array of TProcessString;
                                   Options:TProcessOptions=[];swOptions:TShowWindowOptions=swoNone);
var pathtobash,s : string;
begin
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
  strList.Add('cd '+PathToGitWizzard+'/linuxCommands');
  strList.Add(Input.Text);
  strList.SaveToFile(PathToGitWizzard+'/linuxCommands/singlecommand.sh');
 finally
  strList.Free;
 end;
 ExecuteCommand('singlecommand',[],[],swoNone);
end;

procedure TFrame1.Git_initClick(Sender: TObject);
begin
 ExecuteCommand('git_init',[],[],swoNone);
 //Checks whether git has already been initialised
 if DirectoryExists(PathToGitDirectory+PathDelim+'.git') then Git_init.Enabled:= false
  else Git_init.Enabled:=true;
end;



end.

