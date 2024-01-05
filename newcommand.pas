unit newcommand;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

resourcestring
  rs_nocaption   = 'No caption entered';
  rs_nofilename  = 'No filename entered';
  rs_nocommand   = 'No command entered';

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
    procedure CancelClick(Sender: TObject);
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
 close;
end;

procedure TNewcommandDlg.CancelClick(Sender: TObject);
begin
 close;
end;

end.

