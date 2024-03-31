unit argument_dialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TArgument_Form }

  TArgument_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);

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

end.

