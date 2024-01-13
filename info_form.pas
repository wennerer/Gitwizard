unit info_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLIntf;

type

  { TInfoForm }

  TInfoForm = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    procedure StaticText2Click(Sender: TObject);
    procedure StaticText3Click(Sender: TObject);
  private

  public

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

procedure TInfoForm.StaticText3Click(Sender: TObject);
begin
 OpenUrl('https://www.lazarusforum.de/viewtopic.php?f=1&t=14263&p=128092&hilit=hahn#p128092');
end;

end.

