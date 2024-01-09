unit input_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TInputForm }

  TInputForm = class(TForm)
    Button1: TButton;
    Edit_Complete: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  InputForm: TInputForm;

implementation

{$R *.lfm}

{ TInputForm }

procedure TInputForm.Button1Click(Sender: TObject);
begin
 close;
end;

end.

