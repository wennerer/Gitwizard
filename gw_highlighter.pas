unit gw_highlighter;

{$mode objfpc}{$H+}

interface

uses
Classes, SysUtils, Graphics, SynEditHighlighter, SynEditHighlighterFoldBase;

type
{Klasse für die Erstellung eines Highlighters}
TRangeState = (rsUnknown, rsComment);
//ID zur Kategorisierung der Token
TtkTokenKind = (tkComment, tkKey, tkNull, tkSpace, tkString, tkUnknown,tkMinus);
TProcTableProc = procedure of object; //Prozedurtyp zur Verarbeitung des Tokens nach dem Anfangszeichen.

{ TgwHighlighter }
TgwHighlighter = class(TSynCustomFoldHighlighter)
protected
 posIni, posFin : Integer;
 fStringLen     : Integer; //Aktuelle Tokengröße
 fToIdent       : PChar; //Zeiger auf Bezeichner
 linAct         : PChar;
 fProcTable     : array[#0..#255] of TProcTableProc; //Tabelle der Verfahren
 fTokenID       : TtkTokenKind; //Id des aktuellen Tokens
 fRange         : TRangeState; //definiert die Kategorien von Token

 fAtriComent    : TSynHighlighterAttributes;
 fAtriClave     : TSynHighlighterAttributes;
 fAtriEspac     : TSynHighlighterAttributes;
 fAtriCadena    : TSynHighlighterAttributes;

 fAtriMinus     : TSynHighlighterAttributes;
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
 procedure CommentProc;
 procedure CreaTablaDeMetodos;
 function KeyComp(const aKey: String): Boolean;
 //Funktionen zur Verarbeitung von Bezeichnern
 procedure ProcMinus;  //-

 procedure ProcNull;
 procedure ProcSlash;
 procedure ProcSpace;
 procedure ProcString;
 procedure ProcUnknown;
 procedure ProcB;
 procedure ProcC;
 procedure ProcD;
 procedure ProcE;
 procedure ProcL;
public
 function GetRange: Pointer; override;
 procedure SetRange(Value: Pointer); override;
 procedure ResetRange; override;
end;

implementation

var
Identifiers: array[#0..#255] of ByteBool;
mHashTable: array[#0..#255] of Integer;

procedure CreaTablaIdentif;
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


 (*
//Kommentar-Attribut
 fAtriComent := TSynHighlighterAttributes.Create('Comment');
 fAtriComent.Style := [fsItalic]; //kursiv geschrieben
 fAtriComent.Foreground :=  clGray; //graue Schriftfarbe
 AddAttribute(fAtriComent); *)

//Schlüsselwort-Attribut
 fAtriClave := TSynHighlighterAttributes.Create('Key');
 fAtriClave.Style := [fsBold]; //fettgedruckt
 fAtriClave.Foreground:=clGreen; //grüne Schriftfarbe
 AddAttribute(fAtriClave);

//Leerzeichen Attribute. Keine Attribute
 fAtriEspac := TSynHighlighterAttributes.Create('space');
 AddAttribute(fAtriEspac);

//String-Attribut
 fAtriCadena := TSynHighlighterAttributes.Create('String');
 fAtriCadena.Foreground := clBlue;

//blaue Schriftfarbe
 AddAttribute(fAtriCadena);
 CreaTablaDeMetodos;
end;

//Tabelle zur Erstellung von Methoden
procedure TgwHighlighter.CreaTablaDeMetodos;
var I: Char;
begin
 for I := #0 to #255 do
  case I of
   '-'    : fProcTable[I] := @ProcMinus;

   '"'    : fProcTable[I] := @ProcString;
   '/'    : fProcTable[I] := @ProcSlash;
   'B','b': fProcTable[I] := @ProcB;
   'C','c': fProcTable[I] := @ProcC;
   'D','d': fProcTable[I] := @ProcD;
   'E','e': fProcTable[I] := @ProcE;
   'L','l': fProcTable[I] := @ProcL;
   #0     : fProcTable[I] := @ProcNull;
//Das Zeichen zur Markierung des Zeichenkettenendes wird gelesen.
   #1..#9, #11, #12, #14..#32 : fProcTable[I] := @ProcSpace;
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
 case LinAct[PosFin + 1] of
 //siehe nächstes Zeichen
  '-':
//Rot bis zum Zeilenenede
       begin
        fTokenID := tkMinus;
        inc(PosFin, 2);
//zum nächsten Token springen
        while not (linAct[PosFin] in [#0, #10, #13]) do Inc(PosFin);
       end;

  else //muss der "Minus"-Operator sein.
   begin
    if (Pos('@',linAct) =  1) then

     while not (linAct[PosFin] in [#0, #10, #13,'+']) do
      begin
       Inc(PosFin);
       fTokenID := tkMinus;

      end
    else
     if Pos('-',linAct) =  1 then
     while not (linAct[PosFin] in [#0, #10, #13]) do
      begin
       Inc(PosFin);
       fTokenID := tkMinus;
      end

    else
     begin
      Inc(PosFin);
      fTokenID := tkUnknown;
     end;


   end;
 end;

end;

procedure TgwHighlighter.ProcString;
//Verarbeitet das Anführungszeichen.
begin
 fTokenID := tkString;
//Token als String
 Inc(PosFin);
 while (not (linAct[PosFin] in [#0, #10, #13])) do
 begin
  if linAct[PosFin] = '"' then begin //sucht das Ende des Strings
  Inc(PosFin);
  if (linAct[PosFin] <> '"') then break; //wenn nicht doppelte Anführungszeichen
 end;
 Inc(PosFin);
 end;
end;

procedure TgwHighlighter.ProcSlash;
//Verarbeitet das '/'-Symbol
begin
 case linAct[PosFin + 1] of
  '*':
//mehrzeiliger Kommentar
       begin
        fRange := rsComment;
//Tokenstatus
        fTokenID := tkComment;
        inc(PosFin, 2);
        while linAct[PosFin] <> #0 do
         case linAct[PosFin] of
          '*': if linAct[PosFin + 1] = '/' then
                begin
                 inc(PosFin, 2);
                 fRange := rsUnknown;
                 break;
                end else inc(PosFin);
          #10: break;
          #13: break;
         else inc(PosFin);
        end;
       end;
       else
//muss der "zwischen"-Operator sein.
       begin
        inc(PosFin);
        fTokenID := tkUnknown;
       end;
 end
end;

procedure TgwHighlighter.ProcB;
begin
 while Identifiers[linAct[posFin]] do inc(posFin);
 fStringLen := posFin - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 if KeyComp('EGIN') then
  begin
   fTokenID := tkKey; StartCodeFoldBlock(nil);
  end else
  if KeyComp('Y')
  then fTokenID :=  tkKey else
  fTokenID := tkUnknown; //gemeinsamer Bezeichner
end;

procedure TgwHighlighter.ProcC;
begin
 while Identifiers[linAct[posFin]] do inc(posFin);
 fStringLen := posFin - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 fTokenID := tkUnknown; //gemeinsamer Bezeichner
end;

procedure TgwHighlighter.ProcD;
begin
 while Identifiers[linAct[posFin]] do inc(posFin);
 fStringLen := posFin - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 if KeyComp('E') then fTokenID := tkKey else
 fTokenID := tkUnknown; //gemeinsamer Bezeichner
end;

procedure TgwHighlighter.ProcE;
begin
 while Identifiers[linAct[posFin]] do inc(posFin);
 fStringLen := posFin - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 if KeyComp('N')
 then fTokenID := tkKey else
 if KeyComp('ND')
 then
  begin
   fTokenID := tkKey;
   EndCodeFoldBlock();
  end else
  fTokenID := tkUnknown; //gemeinsamer Bezeichner
end;

procedure TgwHighlighter.ProcL;
begin
 while Identifiers[linAct[posFin]] do inc(posFin);
 fStringLen := posFin - posIni - 1; //Größe berechnen - 1
 fToIdent := linAct + posIni + 1; //Zeiger auf Bezeichner + 1
 if KeyComp('A')
 then fTokenID := tkKey else
 if KeyComp('OS')
 then fTokenID := tkKey else
 fTokenID := tkUnknown; //ohne Attribute
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
  Inc(posFin);
 until (linAct[posFin] > #32) or (linAct[posFin] in [#0, #10, #13]);
end;

procedure TgwHighlighter.ProcUnknown;
begin
 inc(posFin);
 while (linAct[posFin] in [#128..#191]) OR // fortgesetzter utf8-Subcode
  ((linAct[posFin]<>#0)
 and (fProcTable[linAct[posFin]] = @ProcUnknown)) do
 inc(posFin);
 fTokenID := tkUnknown;
end;

procedure TgwHighlighter.SetLine(const NewValue: String; LineNumber: Integer);
begin
 inherited;
 linAct := PChar(NewValue); //Kopieren der aktuellen Zeile
 posFin := 0; //zeigt auf das erste Zeichen
 Next;
end;

procedure TgwHighlighter.Next;
begin
 posIni := PosFin; //verweist auf das erste Element
 if fRange = rsComment then
  CommentProc
 else
 begin
  fRange := rsUnknown;
  fProcTable[linAct[PosFin]]; //Die entsprechende Funktion wird ausgeführt.
 end;
end;

function TgwHighlighter.GetEol: Boolean;
{Zeigt an, wenn das Ende der Zeile erreicht ist.}
begin
 Result := fTokenId = tkNull;
end;

procedure TgwHighlighter.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
{Gibt Informationen über den aktuellen Token zurück}
begin
 TokenLength := posFin - posIni;
 TokenStart := linAct + posIni;
end;

function TgwHighlighter.GetTokenAttribute: TSynHighlighterAttributes;
//Gibt Informationen über den aktuellen Token zurück
begin
 case fTokenID of
  tkMinus   : Result := fAtriMinus;

  tkComment : Result := fAtriComent;
  tkKey     : Result := fAtriClave;
  tkSpace   : Result := fAtriEspac;
  tkString  : Result := fAtriCadena;
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

procedure TgwHighlighter.CommentProc;
begin
 fTokenID := tkComment;
 case linAct[PosFin] of
  #0:
     begin
      ProcNull;
      exit;
     end;
 end;
 while linAct[PosFin] <> #0 do
 case linAct[PosFin] of
  '*': if linAct[PosFin + 1] = '/' then
        begin
         inc(PosFin, 2);
         fRange := rsUnknown;
         break;
        end
       else inc(PosFin);
  #10: break;
  #13: break;
  else inc(PosFin);
 end;
end;

///////// Implementierung der Bereichsfunktionalitäten //////////
procedure TgwHighlighter.ReSetRange;
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
CreaTablaIdentif; //Erstellen der Tabelle für die Schnellsuche

end.

