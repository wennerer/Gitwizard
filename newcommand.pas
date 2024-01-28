{This is a part of GitWizard}
unit newcommand;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,gw_rsstrings;

type

  { TNewcommandDlg }

  TNewcommandDlg = class(TForm)
    NeedsInput: TCheckBox;
    Edit_newhint: TEdit;
    Edit_newcommand: TEdit;
    Okay: TButton;
    Cancel: TButton;
    Edit_newcaption: TEdit;
    Edit_newfilename: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure OkayClick(Sender: TObject);
  private

  public

  end;

var
  NewcommandDlg: TNewcommandDlg;

implementation

{$R *.lfm}

{ TNewcommandDlg }

procedure TNewcommandDlg.FormCreate(Sender: TObject);
begin
 Caption := rs_newcommandform;
 StaticText1.Caption := rs_EnterACaption;
 StaticText2.Caption := rs_EnterAFilename;
 StaticText3.Caption := rs_EnterACommand;
 StaticText4.Caption := rs_EnterAHint;
 Cancel.Caption      := rs_Cancel;
 NeedsInput.Caption  := rs_NeedInput;
end;

procedure TNewcommandDlg.OkayClick(Sender: TObject);
begin
 if Edit_newcaption.Text = '' then
  begin
   showmessage(rs_nocaption);
   exit;
  end;
 if Edit_newfilename.Text = '' then
  begin
   showmessage(rs_nofilename);
   exit;
  end;
 if Edit_newcommand.Text = '' then
  begin
   showmessage(rs_nocommand);
   exit;
  end;
 ModalResult := mrOk;
end;


end.

