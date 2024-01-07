unit options_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TOptionsform }

  TOptionsform = class(TForm)
    Button1: TButton;
    Edit_Editor: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Optionsform: TOptionsform;

implementation

{$R *.lfm}

{ TOptionsform }

procedure TOptionsform.Button1Click(Sender: TObject);
begin
  close;
end;

end.

