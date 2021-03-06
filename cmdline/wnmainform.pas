{ Copyright (C) 2007 Julian Schutsch

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
  
  This Software is GPL, not LGPL as the libary it uses !
  
  Changelog
    10.8.2007 : Added "Buttons" Unit to avoid "TButton" missing error on 0.9.22 (Linux)

}
unit wnmainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Graphics, Dialogs, ExtCtrls, LCLType,
  ucmdbox, StdCtrls, Controls, Buttons, Menus, ComCtrls, claseli, claseinter,
  edo, clGrange, custParse, TAGraph, TASeries, TAChartListbox, storvar, clSEDO,
  clsistem;

type

  { TWMainForm }

  TWMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cbWordWrap: TCheckBox;
    Chart1: TChart;
    ChartListbox1: TChartListbox;
    ColorDialog1: TColorDialog;
    Chart1ConstantLine1: TConstantLine;
    Chart1ConstantLine2: TConstantLine;
    CmdBox: TCmdBox;
    CbSetCaret: TComboBox;
    FontDialog: TFontDialog;
    Label1: TLabel;
    HistoryList: TListBox;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    RightPanel: TPanel;
    sbZoom: TScrollBar;
    Splitter1: TSplitter;
    ReaderTimer: TTimer;
    ProcessTimer: TTimer;
    Splitter2: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure sbZoomChange(Sender: TObject);
    procedure Split(Input: string; const Strings: TStrings);
    procedure SplitArray(Input: string; const Strings: TStrings);
    procedure puntosRaices(listax: TStringList);
    procedure puntosEdo(listax, listay: TStringList);
    function solve(x: real; expre: string): real;
    procedure ChartListbox1SeriesIconDblClick(ASender: TObject; AIndex: integer);
    procedure ChangeSeriesColor(ASeries: TBasicChartSeries);
    procedure NewFunction(area: boolean);
    procedure Graph(Xminimo, Xmaximo: real; expresion: string; esArea: boolean);
    procedure cbWordWrapChange(Sender: TObject);
    procedure CmdBoxInput(ACmdBox: TCmdBox; Input: string);
    procedure CbSetCaretChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcessTimerTimer(Sender: TObject);
    procedure ReaderTimerTimer(Sender: TObject);
  private
    hglobal: real;
    TextPosition: integer;
    DText: TStringList;
    Rdpw: boolean;
    FProcess: integer;
    lineal: clLinea;
    integral: TIntegral;
    //Array de LineSeries
    FunctionList: TList;

    diferen: TEdo;
    grange: TGrange;
    SENL: TSENL;
    SEDO: TSEDO;
    varArray: array of clVar;
  end;

var
  WMainForm: TWMainForm;


implementation

var
  Dir: string;

{ TWMainForm }

procedure TWMainForm.ReaderTimerTimer(Sender: TObject);
var
  i: integer;
  s: string;
begin
  for i := 0 to 0 do
  begin
    s := '';
    s := DText[TextPosition];{+#13#10;}
    Inc(TextPosition);
    CmdBox.TextColors(clAqua, clNavy);
    CmdBox.Writeln(s);
    if (TextPosition >= DText.Count) then
    begin
      CmdBox.ClearLine;
      CmdBox.TextColor(clYellow);
      CmdBox.Writeln(#27#10#196);
      TextPosition := 0;
      ReaderTimer.Enabled := False;
    end;
  end;
end;


procedure TWMainForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  setLength(varArray, 2);
  varArray[0] := clVar.Create;
  varArray[0].passValue('h', '0.001');
  varArray[1] := clVar.Create;
  varArray[1].passValue('decimales', '0.0000');
  DText := TStringList.Create;
  FunctionList := TList.Create;
  ;
  if FileExists(Dir + '/demotext.txt') then
    DText.LoadFromFile(Dir + '/demotext.txt');
  CmdBox.StartRead(clSilver, clNavy, ':~$', clYellow, clNavy);
  CmdBox.TextColors(clWhite, clNavy);
  CmdBox.Writeln(#27#218#27#10#191);
  CmdBox.Writeln(#27#179'Type "help" to see a short list of available commands.'#27#10#179);
  CmdBox.Writeln(#27#217#27#10#217);
end;

//*******

function TWMainForm.solve(x: real; expre: string): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    FParser.AddVariable('x', x);
    FParser.AddExpression(expre);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;


procedure TWMainForm.ChartListbox1SeriesIconDblClick(ASender: TObject; AIndex: integer);
begin
  ChangeSeriesColor(ChartListbox1.Series[AIndex]);
end;


procedure TWMainForm.ChangeSeriesColor(ASeries: TBasicChartSeries);
var
  lineseries: TLineSeries;
  areaseries: TAreaSeries;
begin
  if ASeries is TLineSeries then
  begin
    lineseries := ASeries as TLineSeries;
    ColorDialog1.Color := lineseries.SeriesColor;
    ColorDialog1.Color := lineseries.Pointer.Brush.Color;
    if ColorDialog1.Execute then
    begin
      lineseries.SeriesColor := ColorDialog1.Color;
      lineseries.Pointer.Brush.Color := ColorDialog1.Color;
    end;
  end
  else
  if ASeries is TAreaSeries then
  begin
    areaseries := ASeries as TAreaSeries;
    ColorDialog1.Color := areaSeries.AreaBrush.Color;
    if ColorDialog1.Execute then
      areaSeries.AreaBrush.Color := ColorDialog1.Color;
  end;
end;


procedure TWMainForm.NewFunction(area: boolean);
const
  FunctionSeriesName = 'Function';
  FunctionAreasName = 'Function';
begin
  if (area) then
  begin
    FunctionList.Add(TAreaSeries.Create(Chart1));
    with TAreaSeries(FunctionList[FunctionList.Count - 1]) do
    begin
      Name := FunctionAreasName + IntToStr(FunctionList.Count);
      UseZeroLevel := True;
      Title := 'Area ' + IntToStr(FunctionList.Count);
    end;
  end
  else
  begin
    FunctionList.Add(TLineSeries.Create(Chart1));
    with TLineSeries(FunctionList[FunctionList.Count - 1]) do
    begin
      Name := FunctionSeriesName + IntToStr(FunctionList.Count);
      Title := 'Funcion ' + IntToStr(FunctionList.Count);
    end;
  end;
  Chart1.AddSeries(TLineSeries(FunctionList[FunctionList.Count - 1]));
end;

//raiz("2*power(x,3)+2",-1.5,-0.25)
procedure TWMainForm.Graph(Xminimo, Xmaximo: real; expresion: string; esArea: boolean);
const
  N = 4000;
  MIN = -50;
  MAX = 50;
var
  j, xn: real;
begin
  //graph function
  if (Xminimo = 0) and (Xmaximo = 0) then
  begin
    Xminimo := MIN;
    Xmaximo := MAX;
  end;

  j := -3;
  with TLineSeries(FunctionList[FunctionList.Count - 1]) do
    while (j < N - 1) do
    begin
      xn := Xminimo + (Xmaximo - Xminimo) * j / (N - 1);
      AddXY(xn, solve(xn, expresion));
      j += 1;
    end;

  if (esArea) then
  begin
    j := -3;
    with TAreaSeries(FunctionList[FunctionList.Count - 2]) do
      while (j < N - 1) do
      begin
        xn := Xminimo + (Xmaximo - Xminimo) * j / (N - 1);
        AddXY(xn, solve(xn, expresion));
        j += 1;
      end;
  end;

end;

procedure TWMainForm.puntosEdo(listax, listay: TStringList);
var
  i: integer;
begin
  //GraphPuntos.clear;
  with TLineSeries(FunctionList[FunctionList.Count - 1]) do
  begin
    LineType := ltNone;
    ShowPoints := True;
    Pointer.Brush.Color := clRed;

    for i := 0 to listax.Count - 1 do
      AddXY(StrToFloat(listax[i]), StrToFloat(listay[i]));
  end;
end;

procedure TWMainForm.puntosRaices(listax: TStringList);
var
  i: integer;
begin
  with TLineSeries(FunctionList[FunctionList.Count - 1]) do
  begin
    LineType := ltNone;
    ShowPoints := True;
    Pointer.Brush.Color := clRed;

    for i := 0 to listax.Count - 1 do
      AddXY(StrToFloat(listax[i]), 0);
  end;
end;

procedure TWMainForm.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  Strings.StrictDelimiter := True;
  Strings.Delimiter := ',';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;

procedure TWMainForm.SplitArray(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  //Strings.StrictDelimiter := True;
  //Strings.Delimiter := ' ';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;


procedure TWMainForm.CmdBoxInput(ACmdBox: TCmdBox; Input: string);
var
  i, j, k, p, m, indexOverride, storeMetodIndex: integer;
  paramFloat: array of real;
  metodo, funvar, res, varVal, storeInput, valParseTEMPO: string;
  valParse, temporal, storeMetodos: TStringList;
  flgArea, pascom, execMetod, toStore: boolean;

begin
  if rdpw then
  begin
    CmdBox.TextColors(clLime, clBlue);
    CmdBox.Writeln('Your Secret Password : ' + Input);
    CmdBox.TextColors(clSilver, clNavy);
    rdpw := False;
  end
  else
  begin
    rdpw := False;
    valParse := TStringList.Create;
    temporal := TStringList.Create;

    storeMetodos := TStringList.Create;
    storeMetodos.AddStrings(['integral', 'area', 'edo', 'lagrange']);
    storeMetodos.sorted := True;
    lineal := clLinea.Create;
    integral := TIntegral.Create;
    diferen := TEdo.Create;
    grange := TGrange.Create;
    SENL := TSENL.Create;
    SEDO := TSEDO.Create;
    flgArea := False;
    pascom := True;
    execMetod := True;
    toStore := False;
    metodo := '';
    varVal := '';
    Input := trim(LowerCase(Input));
    if Input = 'help' then
    begin
      CmdBox.TextColors(clLime, clNavy);
      CmdBox.Writeln(#27#218#27#197#128#0#27#194#27#10#191);
      CmdBox.Writeln(#27#179' Command'#27#33#128#0#27#179' Explanation'#27#10#179);
      CmdBox.Writeln(#27#195#27#197#128#0#27#198#27#10#180);
      CmdBox.Writeln(#27#179' help'#27#33#128#0#27#179' Gives this list of Commands'#27#10#179);
      CmdBox.Writeln(#27#179' clear'#27#33#128#0#27#179' Clears the Content of CmdBox'#27#10#179);
      CmdBox.Writeln(#27#179' start'#27#33#128#0#27#179' Outputs the Content of Demotext.txt from the beginning'#27#10#179);
      CmdBox.Writeln(#27#179' stop'#27#33#128#0#27#179' Stops output and resets to Start'#27#10#179);
      CmdBox.Writeln(#27#179' pause'#27#33#128#0#27#179' Interrupts output'#27#10#179);
      CmdBox.Writeln(#27#179' resume'#27#33#128#0#27#179' Resumes output from the last position'#27#10#179);
      CmdBox.Writeln(#27#179' clearhistory'#27#33#128#0#27#179' Clears all history entries'#27#10#179);
      CmdBox.Writeln(#27#179' readpwd'#27#33#128#0#27#179' Read a Password (just as a test)'#27#10#179);
      CmdBox.Writeln(#27#179' exit'#27#33#128#0#27#179' Exit program'#27#10#179);
      CmdBox.Writeln(#27#217#27#197#128#0#27#193#27#10#217);
      CmdBox.TextColor(clSilver);
    end
    else
    if Input = 'readpwd' then
    begin
      rdpw := True;
    end
    else
    if Input = 'clearhistory' then
    begin
      CmdBox.TextColor(clYellow);
      CmdBox.Writeln('Clear History...');
      CmdBox.TextColor(clSilver);
      CmdBox.ClearHistory;
    end
    else
    if Input = 'start' then
    begin
      TextPosition := 0;
      ReaderTimer.Enabled := True;
      CmdBox.TextColors(clLime, clBlue);
      CmdBox.Writeln('Start...');
    end
    else if Input = 'stop' then
    begin
      TextPosition := 0;
      ReaderTimer.Enabled := False;
      CmdBox.TextColors(clRed, clBlue);
      CmdBox.Writeln('Stop...');
    end
    else if Input = 'pause' then
    begin
      ReaderTimer.Enabled := False;
      CmdBox.TextColors(clPurple, clBlue);
      CmdBox.Writeln('Pause...');
    end
    else if Input = 'resume' then
    begin
      ReaderTimer.Enabled := True;
      CmdBox.TextColors(clGreen, clBlue);
      CmdBox.Writeln('Continue...');
    end
    else if Input = 'clear' then
    begin
      CmdBox.Clear;
    end
    else if Input = 'clearplot' then
    begin
      FunctionList.Clear;
      Chart1.Series.Clear;
      Chart1.AddSeries(TConstantLine.Create(Chart1));
      Chart1.AddSeries(TConstantLine.Create(Chart1));
      Chart1.Series[0].Name := 'AxisX';
      Chart1.Series[1].Name := 'AxisY';
      TConstantLine(Chart1.Series[0]).LineStyle := lsVertical;
      TConstantLine(Chart1.Series[0]).Title := 'AxisY';
      TConstantLine(Chart1.Series[1]).Title := 'AxisX';
    end
    else if Input = 'showplot' then
    begin
      Chart1.Visible := True;
    end
    else if Input = 'hideplot' then
    begin
      Chart1.Visible := False;
    end
    else if Input = 'exit' then
      Close
    else
    begin
      try
        //Parse metodo
        i := 1;

        while (i <> length(Input) + 1) and (Input[i] <> '(') and (Input[i] <> '=') do
        begin
          metodo += Input[i];
          i += 1;
        end;
        //si se quiere mostrar la variable (ejm >> x) -> muestra el valor de x
        if (i = length(Input) + 1) then
        begin
          for j := 0 to Length(varArray) - 1 do
            if (metodo = varArray[j].varname) then
              res := metodo + '= ' + varArray[j].varstr;
          execMetod := False;
        end
        else if (Input[i] = '=') then
        begin
          execMetod := False;

          //si el nombre ya esta en el array then save index
          indexOverride := -1;
          for j := 0 to Length(varArray) - 1 do
            if (metodo = varArray[j].varname) then
              indexOverride := j;

          varVal := copy(Input, i + 1, length(Input) - i);
          varVal := trim(varVal);
          //Se reemplaza
          if (indexOverride <> -1) then
          begin
            if (varArray[indexOverride].passValue(metodo, varVal)) then
              if (varArray[indexOverride].esArray) then
              begin
                varArray[indexOverride].varstr := '[';
                for j := 0 to varArray[indexOverride].arrayValores.Count - 1 do
                  varArray[indexOverride].varstr +=
                    varArray[indexOverride].arrayValores[j] + ' ';
                varArray[indexOverride].varstr[
                  length(varArray[indexOverride].varstr)] := ']';
              end;

          end
          else//else es un valor nuevo a guardar
          begin
            setLength(varArray, Length(varArray) + 1);
            varArray[Length(varArray) - 1] := clVar.Create;
            //se pasa el input y se valida

            //si el argumento es un metodo
            m := 1;
            storeInput := '';

            while (m <> length(varVal) + 1) and (varVal[m] <> '(') do
            begin
              storeInput += varVal[m];
              m += 1;
            end;

            //comprueba si es un metodo
            if (storeMetodos.find(storeInput, storeMetodIndex)) then
            begin
              execMetod := True;
              Input := varVal;
              i := m;
              varArray[Length(varArray) - 1].varname := metodo;
              metodo := storeMetodos[storeMetodIndex];
              toStore := True;
            end //Pass valor y valida
            else if not (varArray[Length(varArray) - 1].passValue(metodo, varVal)) then
            begin
              //si no valido se elimina el elemento
              setLength(varArray, Length(varArray) - 1);
            end
            //si es valido y es un array
            else if (varArray[Length(varArray) - 1].esArray) then
            begin

              //comparacion arraylist(elementos matriz ingresada)
              //con los nombres lista variables

              //si son lo mismo entonces reeplace elemento arraylist con valores variab

              //valores arraylist
              for j := 0 to varArray[Length(varArray) - 1].arrayValores.Count - 1 do
                //variables almacenadas
                for k := 0 to length(varArray) - 1 do
                  if (varArray[Length(varArray) - 1].arrayValores[j] =
                    varArray[k].varname) then
                    varArray[Length(varArray) - 1].arrayValores[j] := varArray[k].varstr;

              //arraylist to varstr
              varArray[Length(varArray) - 1].varstr := '[';
              for j := 0 to varArray[Length(varArray) - 1].arrayValores.Count - 1 do
                varArray[Length(varArray) - 1].varstr +=
                  varArray[Length(varArray) - 1].arrayValores[j] + ' ';
              varArray[Length(varArray) - 1].varstr[
                length(varArray[Length(varArray) - 1].varstr)] := ']';

            end;
          end;

        end;
        if (execMetod) then
          //**********************************************************
        begin
          Split(copy(Input, i + 1, length(Input) - i - 1), valParse);

          setLength(paramFloat, valParse.Count - 1);

          //if parameters are inside vararray
          //parametros pasados
          for p := 0 to valParse.Count - 1 do
          begin
            //If its an array
            if (valParse[p][1] = '[') or (valParse[p][length(valParse[p])] = ']') then
            begin
              //transform to TStringList
              valParseTEMPO := valParse[p];
              Delete(valParseTEMPO, 1, 1);
              setlength(valParseTEMPO, length(valParseTEMPO) - 1);
              SplitArray(valParseTEMPO, temporal);

              //valores parametro array
              for j := 0 to temporal.Count - 1 do
                //variables almacenadas
                for k := 0 to length(varArray) - 1 do
                  if (temporal[j] = varArray[k].varname) then
                    temporal[j] := varArray[k].varstr;

              //              //arraylist to varstr
              valParse[p] := '[';
              for j := 0 to temporal.Count - 1 do
              begin
                valParse[p] := valParse[p] + temporal[j] + ' ';
              end;
              valParse[p] := valParse[p] + ']';
            end
            else //its a float or string
            begin
              //CmdBox.Writeln('valParse es un Float o Str');
              //CmdBox.Writeln('valParse[p]= '+valParse[p]);

              for i := 0 to length(varArray) - 1 do
              begin
                //CmdBox.Writeln('varArray[i].varname= '+varArray[i].varname);
                if (varArray[i].varname = valParse[p]) then
                begin
                  //CAMBIAR LA TRANSFORM DE TIPOS
                  //DEBUG****************
                  //x=lagrange([5 2 3 4 ],[3 7 5 6 ])
                  //integral(x,3,4)

                  //**********
                  //CmdBox.Writeln('valparse antes '+valParse[p]);
                  valParse[p] := varArray[i].varstr;
                  //CmdBox.Writeln('valparse despues '+ valParse[p]);
                end;
              end;
            end;

          end;

          //CmdBox.Writeln('entra metodos');


          //f=x*y
          //xo=1
          //yo=2
          //xf=2
          //metodo=0
          //edo(f,xo,yo,xf)    gvk
          //edo(f,xo,yo,xf,metodo)

          //CmdBox.Writeln('# de elementos: '+IntToStr(length(varArray)));
          //argumentos metodo
          //end;



          //Metodos validos
          if (metodo = 'plot2d') then//********
          begin
            NewFunction(False);
            Graph(0, 0, valParse[0], False);
          end
          else if (metodo = 'raiz') then
          begin
            //raiz("2*power(x,3)+2",-1.5,-0.25)
            //raiz("2*power(x,3)-5*x",-3,2)
            //raiz(expre,a,b,metod)
            if (valParse.Count = 4) then
              lineal.setMetod(valParse[3]);

            lineal.seth(StrToFloat(varArray[0].varstr));
            lineal.getInterv(StrToFloat(valParse[1]), StrToFloat(valParse[2]));
            lineal.getFunc(valParse[0]);

            if (lineal.Execute) then
            begin
              NewFunction(False);
              Graph(0, 0, valParse[0], False);

              res := 'Raices: ';
              for i := 0 to lineal.ResLi.Count - 1 do
                res := res + lineal.Resli[i] + ' ';
              NewFunction(False);
              puntosRaices(lineal.Resli);
            end
            else
            begin
              CmdBox.Writeln('No hay raices en el intervalo');
            end;

          end
          else if (metodo = 'interseccion') then
          begin
            //interseccion("2*power(x,3)+2","x+2",-1.5,-0.25)
            //interseccion("power(x,3)-1","power(x,2)-1",-3,5)
            //interseccion(f1,f2,a,b)

            lineal.seth(StrToFloat(varArray[0].varstr));
            lineal.setMetod('1');
            lineal.getInterv(StrToFloat(valParse[2]), StrToFloat(valParse[3]));
            lineal.getFunc('(' + valParse[0] + ')-(' + valParse[1] + ')');
            lineal.getFuncInter(valParse[0]);

            if (lineal.Execute) then
            begin
              //graficar(0, 0, valParse[0], False, True);
              //graficar(0, 0, valParse[1], False, False);
              NewFunction(False);
              Graph(0, 0, valParse[0], False);

              NewFunction(False);
              Graph(0, 0, valParse[1], False);

              res := 'Raices: ';
              for i := 0 to lineal.ResLi.Count - 1 do
                res := res + lineal.Resli[i] + ' ';

              NewFunction(False);
              puntosEdo(lineal.Resli, lineal.Resliy);
            end;
          end
          else if (metodo = 'sedo') then//********
          begin
            //a=sin(x)+cos(y)+sin(z)
            //b=cos(x)+sin(z)
            //sedo([a b ],[x=0 y=-1 z=1],20)



            SEDO.seth(StrToFloat(varArray[0].varstr));
            if (SEDO.getValues(valParse[0], valParse[1])) and
              (SEDO.getFinal(valParse[2])) then
            begin
              res := SEDO.Execute();
              NewFunction(false);
              puntosEdo(SEDO.resx,SEDO.resy);
              NewFunction(false);
              puntosEdo(SEDO.resx,SEDO.resz);
            end;
          end
          else if (metodo = 'senl') then//********
          begin
            //a=cos(x)+exp(y)-x
            //b=sen(5*x)+x*y-y
            //x=0.5
            //y=1

            //senl([a b],[x=0.5 y=1])

            //a=power(x,2)+power(y,2)-5
            //b=power(x,2)-power(y,2)-1

            //x=2
            //y=1

            //senl([a b],[x=2 y=1])


            SENL.seth(StrToFloat(varArray[0].varstr));
            if (SENL.getValues(valParse[0], valParse[1])) then
            begin
              //CmdBox.Writeln('valido');

              res := SENL.Execute();
            end;
            //CmdBox.Writeln('el valor DEBUG ' + SENL.DEBUG);
            //CmdBox.Writeln('valParse[0] ' + valParse[0]);
            //CmdBox.Writeln('valParse[1] ' + valParse[1]);

          end
          else if (metodo = 'integral') then
          begin
            //integral(expre,a,b,metod)
            //integral("2*power(x+1,3)-1",-1,0)

            if (valParse.Count = 4) then
              integral.setMetod(StrToInt(valParse[3]));

            integral.seth(StrToFloat(varArray[0].varstr));
            integral.getInterv(StrToFloat(valParse[1]),
              StrToFloat(valParse[2]));
            integral.getFunc(valParse[0]);

            NewFunction(True);
            NewFunction(False);
            Graph(StrToFloat(valParse[1]), StrToFloat(valParse[2]), valParse[0], True);

            res := FormatFloat(varArray[1].varstr, integral.Execute());
          end
          else if (metodo = 'area') then
          begin
            //area(expre,a,b,metod)
            //area("2*power(x+1,3)-1",-1,0)

            if (valParse.Count = 4) then
              integral.setMetod(StrToInt(valParse[3]));

            integral.seth(StrToFloat(varArray[0].varstr));
            integral.getInterv(StrToFloat(valParse[1]),
              StrToFloat(valParse[2]));
            integral.getFunc(valParse[0]);
            integral.esArea();

            NewFunction(True);
            NewFunction(False);
            Graph(StrToFloat(valParse[1]), StrToFloat(valParse[2]), valParse[0], True);

            res := FormatFloat(varArray[1].varstr, integral.Execute());
          end
          else if (metodo = 'edo') then
          begin
            //edo("x*y",1,2,2)
            //edo(expre,xo,yo,xf,metodo)
            if (valParse.Count = 5) then
              diferen.setMetod(StrToInt(valParse[4]));

            diferen.seth(StrToFloat(varArray[0].varstr));
            diferen.setxf(StrToFloat(valParse[3]));
            diferen.getFunc(valParse[0]);
            diferen.getFront(StrToFloat(valParse[1]),
              StrToFloat(valParse[2]));
            res := FormatFloat(varArray[1].varstr, diferen.Execute());

            if (toStore) then
              varArray[length(varArray) - 1].varstr := res;

            NewFunction(False);
            puntosEdo(diferen.resx, diferen.resy);
          end
          else if (metodo = 'lagrange') then
          begin
            //lagrange([5 2 3 4],[1 2 4 5])
            //a=lagrange([1 8 2 3 5],[7 3 4 6 7])

            if (grange.getValues(valParse[0], valParse[1])) then
            begin
              res := grange.Execute();

              if (toStore) then
                varArray[length(varArray) - 1].varstr := res;


              NewFunction(False);
              puntosedo(grange.tempxTList, grange.tempyTList);

              //Busca el menor y maximo de los Xs
              with grange do
              begin
                tempxTList.Sort;
                tempxTList.sort;
                NewFunction(False);
                Graph(StrToFloat(tempxTList[0]),
                  StrToFloat(tempxTList[tempxTList.Count - 1]), res, False);
              end;

            end;
          end
          else
          begin
            CmdBox.TextColors(clYellow, ClRed);
            CmdBox.Writeln('Invalid Command!');
            res := '';
          end;
        end;

        CmdBox.TextColors(clLime, clNavy);
        if (res <> '') then
        begin
          //CmdBox.Writeln(FormatFloat(res,4));
          CmdBox.Writeln(res);
        end;
      except
        CmdBox.TextColors(clYellow, ClRed);
        CmdBox.Writeln('Invalid Command!');
      end;
    end;
  end;

  valParse.Free;
  temporal.Free;
  lineal.Destroy;
  integral.Destroy;
  diferen.Destroy;
  SENL.Destroy;
  SEDO.Destroy;


  if rdpw then
    CmdBox.StartReadPassWord(clYellow, clNavy, 'Pwd:', clLime, clNavy)
  else
    CmdBox.StartRead(clSilver, clNavy, ':~$', clYellow, clNavy);
  HistoryList.Clear;
  for i := 0 to CmdBox.HistoryCount - 1 do
    HistoryList.Items.Add(CmdBox.History[i]);
end;

procedure TWMainForm.CbSetCaretChange(Sender: TObject);
begin
  case cbSetCaret.ItemIndex of
    0: CmdBox.CaretType := cartLine;
    1: CmdBox.CaretType := cartSubBar;
    2: CmdBox.CaretType := cartBigBar;
  end;
  CmdBox.SetFocus;
end;

procedure TWMainForm.Button2Click(Sender: TObject);
begin
  CmdBox.ClearHistory;
  HistoryList.Clear;
end;

procedure TWMainForm.Button3Click(Sender: TObject);
begin
  FProcess := 0;
  ProcessTimer.Enabled := True;
end;

procedure TWMainForm.Button4Click(Sender: TObject);
begin
  FontDialog.Font := CmdBox.Font;
  if FontDialog.Execute then
  begin
    CmdBox.Font := FontDialog.Font;
  end;
end;

procedure TWMainForm.sbZoomChange(Sender: TObject);
var
  pos: integer;
begin
  pos := sbZoom.Position;
  Chart1.Extent.XMin := -pos;
  Chart1.Extent.XMax := pos;
  Chart1.Extent.YMin := -pos;
  Chart1.Extent.YMax := pos;
end;

procedure TWMainForm.cbWordWrapChange(Sender: TObject);
begin
  if CmdBox.WrapMode = wwmWord then
    CmdBox.WrapMode := wwmChar
  else
    CmdBox.WrapMode := wwmWord;
end;

procedure TWMainForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TWMainForm.FormDestroy(Sender: TObject);
begin
  FunctionList.Free;
  setLength(varArray, 0);
  DText.Free;
end;

procedure TWMainForm.ProcessTimerTimer(Sender: TObject);
begin
  if FProcess = 100 then
  begin
    CmdBox.ClearLine;
    ProcessTimer.Enabled := False;
  end
  else
  begin
    CmdBox.TextColors(clRed, clBlue);
    CmdBox.Write('Processing [' + IntToStr(FProcess) + '%]'#13);
  end;
  Inc(FProcess);
end;

initialization
  {$I wnmainform.lrs}
  Dir := ExtractFileDir(ParamStr(0));
end.
