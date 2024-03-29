//Much of this is taken from the Synedit Bible writen by Tito Hinostroza
// see https://github.com/t-edson/La-Biblia-del-Synedit

{This is a part of GitWizard}

unit gw_highlighter;

{$mode objfpc}{$H+}

interface

uses
Classes, SysUtils, Graphics, LCLProc, Dialogs, SynEditHighlighter,
SynEditHighlighterFoldBase;

type
{Klasse für die Erstellung eines Highlighters}
TRangeState = (rsUnknown);
//ID zur Kategorisierung der Token
TtkTokenKind = (tkNull, tkSpace, tkString, tkUnknown, tkMinus, tkPlus, tkHeader, tkDiff);
TProcTableProc = procedure of object; //Prozedurtyp zur Verarbeitung des Tokens nach dem Anfangszeichen.

TMyBlockType = (cfbt_NONE,cfbt_Diff,cfbt_Header);

{ TgwHighlighter }
TgwHighlighter = class(TSynCustomFoldHighlighter)
protected
 posIni, PosEnd : Integer;
 fStringLen     : Integer; //Aktuelle Tokengröße
 fToIdent       : PChar; //Zeiger auf Bezeichner
 linAct         : PChar;
 fProcTable     : array[#0..#255] of TProcTableProc; //Tabelle der Verfahren
 fTokenID       : TtkTokenKind; //Id des aktuellen Tokens
 fRange         : TRangeState; //definiert die Kategorien von Token
 fHeaderCount   : integer;

 fAtriSpace     : TSynHighlighterAttributes;
 fAtriString    : TSynHighlighterAttributes;

 fAtriMinus     : TSynHighlighterAttributes;
 fAtriPlus      : TSynHighlighterAttributes;
 fAtriHeader    : TSynHighlighterAttributes;
 fAtriDiff      : TSynHighlighterAttributes;
public
 procedure SetLine(const NewValue: String; LineNumber: Integer); override;
 procedure Next; override;
 function GetEol: Boolean; override;
 procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer);override;
 function GetTokenAttribute: TSynHighlighterAttributes; override;
public
 function GetToken: String; override;
 function GetTokenPos: Integer; override;
 function GetTokenKind: integer; override;
 constructor Create(AOwner: TComponent); override;
private
 procedure CreatingMethods;
 function KeyComp(const aKey: String): Boolean;
 //Funktionen zur Verarbeitung von Bezeichnern
 procedure ProcMinus;  //-
 procedure ProcPlus;   //+
 procedure ProcString; //"git  "
 procedure ProcHeader; //@@
 procedure ProcDiff;   //Diff
 procedure ProcNull;
 procedure ProcSpace;
 procedure ProcUnknown;

public
 function GetRange: Pointer; override;
 procedure SetRange(Value: Pointer); override;
 procedure ResetRange; override;
end;

implementation

var
Identifiers: array[#0..#255] of ByteBool;
mHashTable: array[#0..#255] of Integer;

procedure CreaTableIdentif;
var i, j: Char;
begin
 for i := #0 to #255 do
 begin
  Case i of
   '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[i] := True;
  else Identifiers[i] := False;
  end;
  j := UpCase(i);
  Case i in ['_', 'A'..'Z', 'a'..'z'] of
   True: mHashTable[i] := Ord(j) - 64
  else
   mHashTable[i] := 0;
  end;
 end;
end;

constructor TgwHighlighter.Create(AOwner: TComponent);
//Konstruktor der Klasse. Hier müssen die zu verwendenden Attribute angelegt werden.
begin
 inherited Create(AOwner);

 //Minus-Attribut
 fAtriMinus := TSynHighlighterAttributes.Create('Minus');
 fAtriMinus.Foreground :=  clRed; //rote Schriftfarbe
 AddAttribute(fAtriMinus);

 //Plus-Attribut
 fAtriPlus := TSynHighlighterAttributes.Create('Plus');
 fAtriPlus.Foreground :=  clGreen; //grüne Schriftfarbe
 AddAttribute(fAtriPlus);

 //String-Attribut git
 fAtriString := TSynHighlighterAttributes.Create('String');
 fAtriString.Foreground := clBlue; //blaue Schriftfarbe
 AddAttribute(fAtriString);

 //Header-Attribut
 fAtriHeader := TSynHighlighterAttributes.Create('Header');
 fAtriHeader.Style:= [fsBold];
 fAtriHeader.Foreground := clFuchsia;
 AddAttribute(fAtriHeader);

 //String-Attribut diff
 fAtriDiff := TSynHighlighterAttributes.Create('Diff');
 fAtriDiff.Foreground := clFuchsia;
 AddAttribute(fAtriDiff);

//Leerzeichen Attribute. Keine Attribute
 fAtriSpace := TSynHighlighterAttributes.Create('space');
 AddAttribute(fAtriSpace);


 fHeaderCount := 0;
 CreatingMethods;
end;

//Tabelle zur Erstellung von Methoden
procedure TgwHighlighter.CreatingMethods;
var I: Char;
begin
 for I := #0 to #255 do
  case I of
   '-'    : fProcTable[I] := @ProcMinus;
   '+'    : fProcTable[I] := @ProcPlus;
   '"'    : fProcTable[I] := @ProcString;
   #64    : fProcTable[I] := @ProcHeader;  //@
   'D','d': fProcTable[I] := @ProcDiff;

  // '/'    : fProcTable[I] := @ProcSlash;

   #0     : fProcTable[I] := @ProcNull; //Das Zeichen zur Markierung des Zeichenkettenendes wird gelesen.
  // #1..#9, #11, #12, #14..#32 : fProcTable[I] := @ProcSpace;
   #32    : fProcTable[I] := @ProcSpace;
  else fProcTable[I] := @ProcUnknown;
end;
end;

function TgwHighlighter.KeyComp(const aKey: String): Boolean;
var I   : Integer;
    Temp: PChar;
begin
 Temp := fToIdent;
 if Length(aKey) = fStringLen then
 begin
  Result := True;
  for i := 1 to fStringLen do
   begin
    if mHashTable[Temp^] <> mHashTable[aKey[i]] then
     begin
      Result := False;
      break;
     end;
    inc(Temp);
   end;
 end else Result := False;
end;

procedure TgwHighlighter.ProcMinus;
//Verarbeitet das Symbol '-'.
begin
 case LinAct[PosEnd + 1] of
 //siehe nächstes Zeichen
  '-':
//Rot bis zum Zeilenenede
       begin
        fTokenID := tkMinus;
        inc(PosEnd, 2);
//zum nächsten Token springen
        while not (linAct[PosEnd] in [#0, #10, #13]) do Inc(PosEnd);
       end;

  else //Minus oder Bindestrich
   begin
    if (Pos('@',linAct) =  1) then
     while not (linAct[PosEnd] in [#0, #10, #13,'+']) do
      begin
       Inc(PosEnd);
       fTokenID := tkMinus;
      end
    else
     if Pos('-',linAct) =  1 then
     while not (linAct[PosEnd] in [#0, #10, #13]) do
      begin
       Inc(PosEnd);
       fTokenID := tkMinus;
      end
     else
      begin
       Inc(PosEnd);
       fTokenID := tkUnknown;
      end;
   end;
 end;
end;

procedure TgwHighlighter.ProcPlus;
//Verarbeitet das Symbol '+'.
begin
 case LinAct[PosEnd + 1] of
 //siehe nächstes Zeichen
  '+':
//Grün bis zum Zeilenenede
       begin
        fTokenID := tkPlus;
        inc(PosEnd, 2);
//zum nächsten Token springen
        while not (linAct[PosEnd] in [#0, #10, #13]) do Inc(PosEnd);
       end;

  else
  begin
    if (Pos('@',linAct) =  1) then
     while not (linAct[PosEnd] in [#0, #10, #13,'@']) do
      begin
       Inc(PosEnd);
       fTokenID := tkPlus;
      end
    else
    if Pos('+',linAct) =  1 then
     while not (linAct[PosEnd] in [#0, #10, #13]) do
      begin
       Inc(PosEnd);
       fTokenID := tkPlus;
      end
     else
      begin
       Inc(PosEnd);
       fTokenID := tkUnknown;
      end;
   end;
end;
end;

procedure TgwHighlighter.ProcString;
//Verarbeitet das Anführungszeichen. "
begin
 if Pos('git',linAct) <>  0 then fTokenID := tkString
 else fTokenID := tkUnknown;
//Token als String
 Inc(PosEnd);
 while (not (linAct[PosEnd] in [#0, #10, #13])) do
 begin
  if linAct[PosEnd] = '"' then begin //sucht das Ende des Strings
  Inc(PosEnd);
  if (linAct[PosEnd] <> '"') then break; //wenn nicht doppelte Anführungszeichen
 end;
 Inc(PosEnd);
 end;
end;

procedure TgwHighlighter.ProcHeader;
begin
 if LinAct[PosEnd + 1] = '@' then
  begin
   if not Odd(FHeaderCount) then FTokenID := tkHeader else FTokenID := tkUnknown;
   inc(FHeaderCount);
  end
 else FTokenID := tkUnknown;
 if FTokenID = tkHeader then Inc(PosEnd,2) else inc(PosEnd);

 //if fTokenID = tkHeader then inc(Durchlauf);
 //if fTokenID = tkHeader then debugln(inttostr(Durchlauf));
 if TopCodeFoldBlockType = Pointer(PtrInt(cfbt_Header)) then
  if fTokenID = tkHeader then EndCodeFoldBlock();

 if fTokenID = tkHeader then StartCodeFoldBlock(Pointer(PtrInt(cfbt_Header)));
end;

procedure TgwHighlighter.ProcDiff;
begin
 while Identifiers[linAct[PosEnd]] do inc(PosEnd);
 fStringLen := PosEnd - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 if KeyComp('iff') then
  begin
   fTokenID := tkDiff;
   inc(PosEnd, 3);
   while not (linAct[PosEnd] in [#0, #10, #13]) do Inc(PosEnd);

   if TopCodeFoldBlockType = Pointer(PtrInt(cfbt_Header)) then
    EndCodeFoldBlock();
   if TopCodeFoldBlockType = Pointer(PtrInt(cfbt_Diff)) then
    EndCodeFoldBlock();
   StartCodeFoldBlock(Pointer(PtrInt(cfbt_Diff)));
  end
 else
  begin
   FTokenID := tkUnknown;
   inc(PosEnd);
  end;
end;

procedure TgwHighlighter.ProcNull;
//Verarbeitet das Auftreten von Zeichen #0
begin
 fTokenID := tkNull;
//Sie braucht dies nur, um anzuzeigen, dass das Ende der Zeile erreicht ist.
end;

procedure TgwHighlighter.ProcSpace;
//Verarbeitet Zeichen, die den Beginn eines Leerzeichens darstellen
begin
 fTokenID := tkSpace;
 repeat
  Inc(PosEnd);
 until (linAct[PosEnd] > #32) or (linAct[PosEnd] in [#0, #10, #13]);
end;

procedure TgwHighlighter.ProcUnknown;
begin
 inc(PosEnd);
 while (linAct[PosEnd] in [#128..#191]) OR // fortgesetzter utf8-Subcode
  ((linAct[PosEnd]<>#0)
 and (fProcTable[linAct[PosEnd]] = @ProcUnknown)) do
 inc(PosEnd);
 fTokenID := tkUnknown;
end;

procedure TgwHighlighter.SetLine(const NewValue: String; LineNumber: Integer);
begin
 inherited;
 linAct := PChar(NewValue); //Kopieren der aktuellen Zeile
 PosEnd := 0; //zeigt auf das erste Zeichen
 Next;
end;

procedure TgwHighlighter.Next;
begin
 posIni := PosEnd; //verweist auf das erste Element
 fRange := rsUnknown;
 fProcTable[linAct[PosEnd]]; //Die entsprechende Funktion wird ausgeführt.
end;

function TgwHighlighter.GetEol: Boolean;
{Zeigt an, wenn das Ende der Zeile erreicht ist.}
begin
 Result := fTokenId = tkNull;
end;

procedure TgwHighlighter.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
{Gibt Informationen über den aktuellen Token zurück}
begin
 TokenLength := PosEnd - posIni;
 TokenStart := linAct + posIni;
end;

function TgwHighlighter.GetTokenAttribute: TSynHighlighterAttributes;
//Gibt Informationen über den aktuellen Token zurück
begin
 case fTokenID of
  tkMinus   : Result := fAtriMinus;
  tkPlus    : Result := fAtriPlus;
  tkHeader  : Result := fAtriHeader;
  tkString  : Result := fAtriString;
  tkDiff    : Result := fAtriDiff;
  tkSpace   : Result := fAtriSpace;

 else Result := nil; //tkUnknown, tkNull
 end;
end;

{Die folgenden Funktionen werden von SynEdit verwendet, um Klammern, geschweifte Klammern und
Anführungszeichen und Hochkommata zu behandeln.
Sie sind nicht entscheidend für Token von Token, aber sie sollten gut reagieren.}

function TgwHighlighter.GetToken: String;
begin
 Result := '';
end;

function TgwHighlighter.GetTokenPos: Integer;
begin
 Result := posIni - 1;
end;

function TgwHighlighter.GetTokenKind: integer;
begin
 Result := 0;
end;

///////// Implementierung der Bereichsfunktionalitäten //////////
procedure TgwHighlighter.ResetRange;
begin
 inherited;
 fRange := rsUnknown;
end;

function TgwHighlighter.GetRange: Pointer;
begin
 CodeFoldRange.RangeType := Pointer(PtrInt(fRange));
 Result := inherited;
end;

procedure TgwHighlighter.SetRange(Value: Pointer);
begin
 inherited;
 fRange := TRangeState(PtrUInt(CodeFoldRange.RangeType));
end;

initialization
CreaTableIdentif; //Erstellen der Tabelle für die Schnellsuche

end.

