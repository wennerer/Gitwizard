unit gitwizzard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IDEWindowIntf, MenuIntf, IDECommands, Forms, LCLType,
  Dialogs, Graphics;

resourcestring
  mnuShowGitWizzard = 'GitWizzard';

type

  { TGW_MainForm }

  TGW_MainForm = class (TCustomForm)
  public
   constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
   destructor  Destroy; override;
  end;
procedure Register;


var GW_MainForm           : TGW_MainForm = nil;
    Cmd                : TIDEMenuCommand  = nil;
    CmdMessageComposer : TIDECommand;

implementation

procedure CreateGW_MainForm(Sender: TObject; aFormName: string; var AForm: TCustomForm; DoDisableAutoSizing: boolean);
begin
 if CompareText(aFormName,'GW_MainForm')<>0 then exit;

 IDEWindowCreators.CreateForm(GW_MainForm,TGW_MainForm,DoDisableAutosizing,Application);

 AForm:=GW_MainForm;
end;

procedure OnCmdClick(Sender: TObject);
begin
 IDEWindowCreators.ShowForm(GW_MainForm.Name,true);
end;

procedure Register;
var Key      : TIDEShortCut;
    Cat      : TIDECommandCategory;
    CmdMyTool: TIDECommand;
begin
  {$R image.res}
  GW_MainForm := TGW_MainForm.CreateNew(Application,0);

  IDEWindowCreators.Add('GW_MainForm',@CreateGW_MainForm,nil,'100','20%','+330','+80%');

  //Erzeugt den Menüeintrag mit Shortcut:
  Key := IDEShortCut(VK_M,[ssCtrl],VK_UNKNOWN,[]);
  Cat := IDECommandList.FindIDECommand(ecFind).Category;
  CmdMyTool := RegisterIDECommand(Cat,mnuShowGitWizzard,mnuShowGitWizzard, Key, nil,@OnCmdClick);
  Cmd := RegisterIDEMenuCommand(itmCustomTools,mnuShowGitWizzard,mnuShowGitWizzard, nil, nil, CmdMyTool,'magicwand_16');

  //Ohne Shortcut
  //RegisterIDEMenuCommand(itmCustomTools, mnuShowGitWizzard,mnuShowGitWizzard,nil,@OnCmdClick,nil);

end;

{ TGW_MainForm }
constructor TGW_MainForm.CreateNew(AOwner: TComponent; Num: Integer);
begin
  inherited CreateNew(AOwner, Num);
  Name := 'GW_MainForm';
  Caption := 'GitWizzard';
  //SetBounds(100,100,500,800);
  Color := clWindow;
end;

destructor TGW_MainForm.Destroy;
begin

  inherited Destroy;
end;

end.

