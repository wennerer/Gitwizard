unit new_properties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, gw_rsstrings;

type

  { TNewPropertiesForm }

  TNewPropertiesForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_newhint: TEdit;
    Edit_newcaption: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  NewPropertiesForm: TNewPropertiesForm;

implementation

{$R *.lfm}

{ TNewPropertiesForm }

procedure TNewPropertiesForm.FormCreate(Sender: TObject);
begin
 Caption              := rs_newproperties;
 StaticText1.Caption  := rs_newcaption;
 StaticText2.Caption  := rs_newhint;
 Button2.Caption      := rs_Cancel;
end;

end.

