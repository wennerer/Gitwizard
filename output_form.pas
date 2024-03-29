{This is a part of GitWizard}
unit output_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, Spin, SynEdit, SynEditKeyCmds, SynEditTypes, gw_rsstrings;

type

  { TOutPutForm }

  TOutPutForm = class(TForm)
    Button1: TButton;
    Edit_Search: TEdit;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    SpeedButton_searchdown: TSpeedButton;
    SpeedButton_searchup: TSpeedButton;
    SpeedButton_ClearAllBookmarks: TSpeedButton;
    SpeedButton_ClearBookmark: TSpeedButton;
    SpeedButton_UnFoltAll: TSpeedButton;
    SpeedButton_SetBookmarks: TSpeedButton;
    SpeedButton_GotoBookmark: TSpeedButton;
    SpeedButton_FoltAll: TSpeedButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton_ClearAllBookmarksClick(Sender: TObject);
    procedure SpeedButton_ClearBookmarkClick(Sender: TObject);
    procedure SpeedButton_searchdownClick(Sender: TObject);
    procedure SpeedButton_searchupClick(Sender: TObject);
    procedure SpeedButton_UnFoltAllClick(Sender: TObject);
    procedure SpeedButton_FoltAllClick(Sender: TObject);
    procedure SpeedButton_GotoBookmarkClick(Sender: TObject);
    procedure SpeedButton_SetBookmarksClick(Sender: TObject);
  private
    BM                     : array [0..9] of boolean;
    function GetABookmark: integer;

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

procedure TOutPutForm.FormCreate(Sender: TObject);
var lv : integer;
begin
 for lv := 0 to 9 do BM[lv] := true;
 caption                                 := rs_output;
 Button1.Caption                         := rs_close;
 Label1.Caption                          := rs_bookmarks;
 SpeedButton_SetBookmarks.Caption        := rs_setbokmark;
 SpeedButton_ClearAllBookmarks.Caption   := rs_clearallbokmark;
 SpeedButton_GotoBookmark.Caption        := rs_gotobokmark;
 SpeedButton_ClearBookmark.Caption       := rs_clearbokmark;
 SpeedButton_FoltAll.Caption             := rs_FoltAll;
 SpeedButton_UnFoltAll.Caption           := rs_UnFoltAll;
 Label2.Caption                          := rs_Folting;
 Label3.Caption                          := rs_searching;
 SpeedButton_searchdown.Hint             := rs_downwards;
 SpeedButton_searchup.Hint               := rs_backwards;
end;

procedure TOutPutForm.SpeedButton_ClearAllBookmarksClick(Sender: TObject);
var lv : integer;
begin
 for lv:=0 to 9 do
  begin
   SynEdit1.ClearBookMark(lv);
   BM[lv] := true;
  end;
end;

function TOutPutForm.GetABookmark: integer;
var lv : integer;
begin
 Result := -1;
 for lv := 0 to 9 do
  if BM[lv] then
  begin
   BM[lv] := false;
   Result := lv;
   break;
  end;
end;

procedure TOutPutForm.SpeedButton_SetBookmarksClick(Sender: TObject);
begin
 SynEdit1.BookMarkOptions.BookmarkImages := ImageList2;
 SynEdit1.SetBookMark (GetABookmark,1,SynEdit1.CaretY);
end;


procedure TOutPutForm.SpeedButton_GotoBookmarkClick(Sender: TObject);
begin
 SynEdit1.GotoBookMark(SpinEdit1.Value);
end;

procedure TOutPutForm.SpeedButton_ClearBookmarkClick(Sender: TObject);
begin
 SynEdit1.ClearBookMark(SpinEdit2.Value);
 BM[SpinEdit2.Value] := true;
end;

procedure TOutPutForm.SpeedButton_UnFoltAllClick(Sender: TObject);
begin
 SynEdit1.CommandProcessor(TSynEditorCommand(EcFoldLevel0), ' ', nil);
end;

procedure TOutPutForm.SpeedButton_FoltAllClick(Sender: TObject);
begin
 SynEdit1.CommandProcessor(TSynEditorCommand(EcFoldLevel1), ' ', nil);
end;


procedure TOutPutForm.SpeedButton_searchdownClick(Sender: TObject);
begin
 SynEdit1.SearchReplace(Edit_Search.Text, '' ,[]);
end;

procedure TOutPutForm.SpeedButton_searchupClick(Sender: TObject);
begin
 SynEdit1.SearchReplace(Edit_Search.Text, '' ,[ssoBackwards]);
end;

end.

