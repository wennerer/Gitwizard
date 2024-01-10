unit input_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,gw_rsstrings;

type

  { TInputForm }

  TInputForm = class(TForm)
    Button1: TButton;
    Edit_Complete: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TInputForm.FormCreate(Sender: TObject);
begin
 Caption := rs_InputForm;
 StaticText1.Caption:= rs_CopleteCommand;
end;

end.

