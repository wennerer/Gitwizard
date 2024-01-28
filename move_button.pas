{This is a part of GitWizard}
unit move_button;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls,gw_rsstrings;

type

  { TMoveButtonForm }

  TMoveButtonForm = class(TForm)
    SpinEdit1: TSpinEdit;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  MoveButtonForm: TMoveButtonForm;

implementation

{$R *.lfm}

{ TMoveButtonForm }

procedure TMoveButtonForm.FormCreate(Sender: TObject);
begin
 Caption := rs_EnterNewPos;
 StaticText1.Caption := rs_NewPos;
end;

end.

