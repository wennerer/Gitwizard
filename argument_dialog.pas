{This is a part of GitWizard}
unit argument_dialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, gw_rsstrings;

type

  { TArgument_Form }

  TArgument_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  Argument_Form: TArgument_Form;

implementation

{$R *.lfm}

{ TArgument_Form }


procedure TArgument_Form.Button1Click(Sender: TObject);
begin
 ModalResult := mrOk;
end;

procedure TArgument_Form.FormCreate(Sender: TObject);
begin
 Caption             := rs_na;
 StaticText1.Caption := rs_newarg;
 Button2.Caption     := rs_Cancel;
end;

end.

