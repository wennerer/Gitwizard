{This is a part of GitWizard}

unit move_toatab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, gw_rsstrings;

type

  { TMoveToATabForm }

  TMoveToATabForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  MoveToATabForm: TMoveToATabForm;

implementation

{$R *.lfm}

{ TMoveToATabForm }

procedure TMoveToATabForm.FormCreate(Sender: TObject);
begin
 Caption := rs_movetoatab;
 StaticText1.Caption := rs_selectanewtab;
 Button2.Caption := rs_Cancel;
end;

end.

