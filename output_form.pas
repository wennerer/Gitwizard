unit output_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SynEdit;

type

  { TOutPutForm }

  TOutPutForm = class(TForm)
    Button1: TButton;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  OutPutForm: TOutPutForm;

implementation

{$R *.lfm}

{ TOutPutForm }

procedure TOutPutForm.Button1Click(Sender: TObject);
begin
  close;
end;

end.

