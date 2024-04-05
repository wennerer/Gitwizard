{This is a part of GitWizard}
unit input_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, DOM, XPath, XMLRead, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, LCLType, LazIDEIntf, gw_rsstrings,
  argument_dialog;

type

  { TInputForm }

  TInputForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit_Complete: TEdit;
    Image1: TImage;
    StaticText1: TStaticText;
    Timer1: TTimer;
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1DblClick(Sender: TObject);
    procedure Edit_CompleteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    mr           : boolean;
    secondchoice : boolean;
    lastchoice   : string;
    StartPos     : integer;
  public

  end;

var
  InputForm: TInputForm;

implementation
uses gw_frame;
{$R *.lfm}

{ TInputForm }


procedure TInputForm.FormCreate(Sender: TObject);
var xml         :  TXMLDocument;
    XPathResult : TXPathVariable;
    APtr        :Pointer;
    sl          : TStringlist;
    lv          : integer;
begin
 Caption             := rs_InputForm;
 StaticText1.Caption := rs_CopleteCommand;
 Button2.Caption     := rs_Cancel;
 ComboBox1.Text      := rs_prearguments;
 ComboBox1.Hint      := rs_insertnewargument;
 mr := false;
 secondchoice := false;

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

     for lv := 0 to pred(sl.Count) do ComboBox1.Items.Add(sl[lv]);
    finally
     sl.Free;
    end;

  end;
end;



procedure TInputForm.FormActivate(Sender: TObject);
begin
 Timer1.Enabled:=true;
end;

procedure TInputForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if mr then ModalResult := mrOk;
end;

procedure TInputForm.Edit_CompleteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_RETURN then
  begin
   mr := true;
   Close;
  end;
end;

procedure TInputForm.ComboBox1Change(Sender: TObject);
var s : String;
    EndPos : integer;
begin
 s := Edit_Complete.Text;
 if not secondchoice then
  begin
   StartPos := pos('<',s);
   if StartPos = 0 then exit;
   EndPos := PosEx('>',s,StartPos+1);
   if EndPos = 0 then exit;
   Delete(s, StartPos, (EndPos-StartPos)+1);
   Insert(ComboBox1.Text, s, StartPos);
   Edit_Complete.Text := s;
   lastchoice := ComboBox1.Text;
   secondchoice := true;
  end
 else
  begin
   Delete(s, StartPos, (length(lastchoice)));
   Insert(ComboBox1.Text, s, StartPos);
   Edit_Complete.Text := s;
   lastchoice := ComboBox1.Text;
  end;
end;

procedure TInputForm.ComboBox1DblClick(Sender: TObject);
var s           : string;

begin
 Argument_Form:= TArgument_Form.Create(self);
 try

  if  Argument_Form.ShowModal = mrCancel then exit;
  ComboBox1.Items.Add(Argument_Form.Edit1.Text);
  s := Argument_Form.Edit1.Text;
 finally
  Argument_Form.Free;
 end;
 if (Owner as TFrame1).FArguments = '' then
  (Owner as TFrame1).FArguments:= s
 else
  (Owner as TFrame1).FArguments:= (Owner as TFrame1).FArguments+';'+s;

 (Owner as TFrame1).WriteValues;

end;



procedure TInputForm.Timer1Timer(Sender: TObject);
var s : string;
    i1,i2 : integer;
begin
 Timer1.Enabled:=false;

 //selected Command
 Edit_Complete.SetFocus;
 s := Edit_Complete.Text;
 i1 := pos('<',s)-1;
 if i1 = 0 then exit;
 i2 := PosEx('>',s,i1+2);
 if i2 = 0 then exit;
 Edit_Complete.SelStart := i1;
 Edit_Complete.SelLength := i2-i1;
end;

end.

