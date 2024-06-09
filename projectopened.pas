unit ProjectOpened;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,gw_rsstrings;

type

  { TForm_ProjectOpened }

  TForm_ProjectOpened = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Shape1: TShape;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form_ProjectOpened: TForm_ProjectOpened;

implementation

{$R *.lfm}

{ TForm_ProjectOpened }

procedure TForm_ProjectOpened.FormCreate(Sender: TObject);
begin
 Caption                 := rs_NPO;
 StaticText1.Caption     := rs_NewProjectOpened;
 StaticText2.Caption     := rs_Settings;
 Button1.Caption         := rs_Accept;
 Button2.Caption         := rs_Cancel;
 RadioButton1.Caption    := rs_Always;
 RadioButton2.Caption    := rs_Auto;
 RadioButton3.Caption    := rs_Never;
end;

end.

