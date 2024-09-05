{ <Gitwizard>

  Copyright (C) <05.09.2024> <Bernd Hübner (wennerer)>

  This source is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
  License as published by the Free Software Foundation; either version 2 of the License, or any later
  version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web at
  <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing to the Free Software Foundation, Inc., 51
  Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}




unit gitwizard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IDEWindowIntf, MenuIntf, IDECommands, Forms,
  LCLType, Dialogs, Graphics, gw_frame;

resourcestring
  mnuShowGitwizard = 'Gitwizard';

type

  { TGW_MainForm }

  TGW_MainForm = class (TCustomForm)
  private
   MainFrame : TFrame1;
  public
   constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
   destructor  Destroy; override;
  end;
procedure Register;


var GW_MainForm        : TGW_MainForm = nil;
    Cmd                : TIDEMenuCommand  = nil;
    CmdMessageComposer : TIDECommand;

implementation

procedure CreateGW_MainForm({%H-}Sender: TObject; aFormName: string; var AForm: TCustomForm; DoDisableAutoSizing: boolean);
begin
 if CompareText(aFormName,'GW_MainForm')<>0 then exit;

 IDEWindowCreators.CreateForm(GW_MainForm,TGW_MainForm,DoDisableAutosizing,Application);

 AForm:=GW_MainForm;
end;

procedure OnCmdClick({%H-}Sender: TObject);
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

  IDEWindowCreators.Add('GW_MainForm',@CreateGW_MainForm,nil,'50','15%','+330','+80%');

  //Erzeugt den Menüeintrag mit Shortcut:
  Key := IDEShortCut(VK_M,[ssCtrl],VK_UNKNOWN,[]);
  Cat := IDECommandList.FindIDECommand(ecFind).Category;
  CmdMyTool := RegisterIDECommand(Cat,mnuShowGitwizard,mnuShowGitwizard, Key, nil,@OnCmdClick);
  Cmd := RegisterIDEMenuCommand(itmCustomTools,mnuShowGitwizard,mnuShowGitwizard, nil, nil, CmdMyTool,'magicwand_16');

  //Ohne Shortcut
  //RegisterIDEMenuCommand(itmCustomTools, mnuShowGitwizard,mnuShowGitwizard,nil,@OnCmdClick,nil);

end;

{ TGW_MainForm }
constructor TGW_MainForm.CreateNew(AOwner: TComponent; Num: Integer);
begin
  inherited CreateNew(AOwner, Num);
  Name := 'GW_MainForm';
  Caption := 'Gitwizard';
  Color := clForm;

  MainFrame := TFrame1.Create(self);
  MainFrame.Parent := self;



end;

destructor TGW_MainForm.Destroy;
begin

  inherited Destroy;
end;

end.

