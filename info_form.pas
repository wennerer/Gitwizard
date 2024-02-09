{This is a part of GitWizard}
unit info_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLIntf, gw_rsstrings;

type

  { TInfoForm }

  TInfoForm = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Memo1: TMemo;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StaticText2Click(Sender: TObject);
    procedure StaticText3Click(Sender: TObject);
  private

  public
    openfile : boolean;
  end;

var
  InfoForm: TInfoForm;

implementation

{$R *.lfm}

{ TInfoForm }

procedure TInfoForm.StaticText2Click(Sender: TObject);
begin
  OpenUrl('http://www.gnu.org/copyleft/gpl.html');
end;

procedure TInfoForm.FormCreate(Sender: TObject);
begin
 Memo1.Lines.Add(rs_InfoLine1);
 Memo1.Lines.Add(rs_InfoLine2);
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(rs_InfoLine3);
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(' ');
 Memo1.Lines.Add(rs_InfoLine4);
 Button1.Caption:= rs_openhelpfile;

 openfile := false;
end;

procedure TInfoForm.Button1Click(Sender: TObject);
begin
 openfile := true;
 close;
end;

procedure TInfoForm.StaticText3Click(Sender: TObject);
begin
 OpenUrl('https://www.lazarusforum.de/viewtopic.php?f=1&t=14263&p=128092&hilit=hahn#p128092');
end;

end.

