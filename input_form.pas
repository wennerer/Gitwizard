{This is a part of GitWizard}
unit input_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LCLType, gw_rsstrings;

type

  { TInputForm }

  TInputForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_Complete: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    Timer1: TTimer;
    procedure Edit_CompleteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    mr : boolean;
  public

  end;

var
  InputForm: TInputForm;

implementation

{$R *.lfm}

{ TInputForm }


procedure TInputForm.FormCreate(Sender: TObject);
begin
 Caption := rs_InputForm;
 StaticText1.Caption:= rs_CopleteCommand;
 Button2.Caption:= rs_Cancel;
 mr := false;
end;



procedure TInputForm.FormActivate(Sender: TObject);
begin
 Timer1.Enabled:=true;
end;

procedure TInputForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if mr then ModalResult := mrOk;
end;

procedure TInputForm.Edit_CompleteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_RETURN then
  begin
   mr := true;
   Close;
  end;
end;

procedure TInputForm.Timer1Timer(Sender: TObject);
var s : string;
    i1,i2 : integer;
begin
 Timer1.Enabled:=false;
  //selected Command
 Edit_Complete.SetFocus;
 s := Edit_Complete.Text;
 i1 := pos('<',s)-1;
 if i1 = 0 then exit;
 i2 := PosEx('>',s,i1+2);
 if i2 = 0 then exit;
 Edit_Complete.SelStart := i1;
 Edit_Complete.SelLength := i2-i1;
end;

end.

