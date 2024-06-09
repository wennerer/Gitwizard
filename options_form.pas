{This is a part of GitWizard}
unit options_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  EditBtn, gw_rsstrings, edit_arguments;

type

  { TOptionsform }

  TOptionsform = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button_Argument: TButton;
    DirectoryEdit1: TDirectoryEdit;
    Edit_Editor: TEdit;
    Image1: TImage;
    RadioGroup1: TRadioGroup;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure Button_ArgumentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Optionsform: TOptionsform;

implementation
uses gw_frame;
{$R *.lfm}

{ TOptionsform }



procedure TOptionsform.FormCreate(Sender: TObject);
begin
 Caption                 := rs_Optionsform;
 StaticText1.Caption     := rs_selectEditor;
 Button2.Caption         := rs_Cancel;
 StaticText2.Caption     := rs_ownfolder;
 Button_Argument.Caption := rs_AddArgument;
 RadioGroup1.Caption     := rs_PathTransfer;
 RadioGroup1.Items.Strings[0] := rs_Always;
 RadioGroup1.Items.Strings[1] := rs_Auto;
 RadioGroup1.Items.Strings[2] := rs_Never;


end;

procedure TOptionsform.Button_ArgumentClick(Sender: TObject);
var lv : integer;
begin
 EditArgument_Form := TEditArgument_Form.Create(self.Owner);
 try
  if  EditArgument_Form.ShowModal = mrCancel then exit;

  (Owner as TFrame1).FArguments:='';
  (Owner as TFrame1).FArguments:= EditArgument_Form.ListBox_1.Items[0];
  if EditArgument_Form.ListBox_1.Count > 1 then
   for lv := 1 to pred(EditArgument_Form.ListBox_1.Count) do
    (Owner as TFrame1).FArguments:= (Owner as TFrame1).FArguments+';'+EditArgument_Form.ListBox_1.Items[lv];

  (Owner as TFrame1).WriteValues;
 finally
  EditArgument_Form.Free;
 end;
end;


end.

