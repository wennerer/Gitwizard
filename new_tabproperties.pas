unit new_tabproperties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, gw_rsstrings;

type

  { TNewTabPropertiesForm }

  TNewTabPropertiesForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  NewTabPropertiesForm: TNewTabPropertiesForm;

implementation

{$R *.lfm}

{ TNewTabPropertiesForm }

procedure TNewTabPropertiesForm.FormCreate(Sender: TObject);
begin
 Caption := rs_newTabproperties;
 StaticText1.Caption:= rs_newCaptionTab;
 Button2.Caption:= rs_Cancel;
end;

end.

