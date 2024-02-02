{This is a part of GitWizard}
unit options_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,gw_rsstrings;

type

  { TOptionsform }

  TOptionsform = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_Editor: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Optionsform: TOptionsform;

implementation

{$R *.lfm}

{ TOptionsform }



procedure TOptionsform.FormCreate(Sender: TObject);
begin
 Caption := rs_Optionsform;
 StaticText1.Caption := rs_selectEditor;
end;

end.

