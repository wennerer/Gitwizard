unit move_button;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls;

type

  { TMoveButtonForm }

  TMoveButtonForm = class(TForm)
    SpinEdit1: TSpinEdit;
    StaticText1: TStaticText;
  private

  public

  end;

var
  MoveButtonForm: TMoveButtonForm;

implementation

{$R *.lfm}

end.

