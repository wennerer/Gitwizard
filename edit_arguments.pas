{This is a part of GitWizard}
unit edit_arguments;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DOM, XMLRead, XPath, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, LazIDEIntf,gw_rsstrings;

type

  { TEditArgument_Form }

  TEditArgument_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_newargument: TEdit;
    ImageList1: TImageList;
    ListBox_1: TListBox;
    SpeedButton_delete: TSpeedButton;
    SpeedButton_newargument: TSpeedButton;
    SpeedButton_movedown: TSpeedButton;
    SpeedButton_moveup: TSpeedButton;
    procedure Button2Click(Sender: TObject);
    procedure Edit_newargumentEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton_deleteClick(Sender: TObject);
    procedure SpeedButton_movedownClick(Sender: TObject);
    procedure SpeedButton_moveupClick(Sender: TObject);
    procedure SpeedButton_newargumentClick(Sender: TObject);
  private

  public

  end;

var
  EditArgument_Form: TEditArgument_Form;

implementation
uses gw_frame;
{$R *.lfm}

{ TEditArgument_Form }

procedure TEditArgument_Form.FormCreate(Sender: TObject);
var xml         :  TXMLDocument;
    XPathResult : TXPathVariable;
    APtr        :Pointer;
    sl          : TStringlist;
    lv          : integer;
begin
  SpeedButton_newargument.Caption     := rs_InsertArgument;
  SpeedButton_moveup.Caption          := rs_moveup;
  SpeedButton_movedown.Caption        := rs_movedown;
  SpeedButton_delete.Caption          := rs_delete;
  Button1.Caption                     := rs_Cancel;
  Caption                             := rs_ea;

  if fileexists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml') then
   begin
    ReadXMLFile(Xml,IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath)+ 'gw_options.xml');

    XPathResult := EvaluateXPathExpression('/Options/Arguments/@*', Xml.DocumentElement);
    For APtr in XPathResult.AsNodeSet do
     (Owner as TFrame1).FArguments := string(TDOMNode(APtr).NodeValue);
    XPathResult.Free;

    Xml.Free;
    sl := TStringlist.Create;
    try
     sl.StrictDelimiter:= true;
     sl.Delimiter:=';';
     sl.DelimitedText:= (Owner as TFrame1).FArguments;

     for lv := 0 to pred(sl.Count) do ListBox_1.Items.Add(sl[lv]);
    finally
     sl.Free;
    end;
   end;
end;

procedure TEditArgument_Form.Edit_newargumentEnter(Sender: TObject);
begin
 ListBox_1.ClearSelection;
 ListBox_1.Invalidate;
end;

procedure TEditArgument_Form.Button2Click(Sender: TObject);
begin
 ModalResult := mrOk;
end;

procedure TEditArgument_Form.SpeedButton_deleteClick(Sender: TObject);
begin
 ListBox_1.DeleteSelected;
end;

procedure TEditArgument_Form.SpeedButton_movedownClick(Sender: TObject);
begin
 if (ListBox_1.ItemIndex > -1) and (ListBox_1.ItemIndex < ListBox_1.Items.Count-1) then
  begin
   ListBox_1.Items.Exchange(ListBox_1.ItemIndex, ListBox_1.ItemIndex+1);
   ListBox_1.Selected[ListBox_1.ItemIndex+1]:=true;
  end;
end;

procedure TEditArgument_Form.SpeedButton_moveupClick(Sender: TObject);
begin
 if ListBox_1.ItemIndex > 0 then
  begin
   ListBox_1.Items.Exchange(ListBox_1.ItemIndex, ListBox_1.ItemIndex-1);
   ListBox_1.Selected[ListBox_1.ItemIndex-1]:=true;
  end;
end;

procedure TEditArgument_Form.SpeedButton_newargumentClick(Sender: TObject);
begin
 if Edit_newargument.Text = '' then exit;
 ListBox_1.Items.Add(Edit_newargument.Text);
 Edit_newargument.Text :='';
 ListBox_1.SetFocus;
 ListBox_1.Selected[ListBox_1.Count -1] := true;
 ListBox_1.Invalidate;
end;



end.

