unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Forms, FMX.Dialogs, FMX.Objects, FMX.Ani, FMX.Controls, FMX.Types,
  FMX.Controls.Presentation, FMX.Effects, FMX.StdCtrls, FMX.Graphics,
  System.Generics.Collections, System.SyncObjs, DateUtils,
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.UI, FireDAC.Stan.ExprFuncs,
  UObjects;

type
  TFrmRectangles = class(TForm)
    btnAdd: TButton;
    pnlButtons: TPanel;
    pnlMain: TPanel;
    tmrMoving: TTimer;
    PaintBox: TPaintBox;
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure tmrMovingTimer(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FMouseIsDown: Boolean;
    FRectPositionX: Single;
    FRectPositionY: Single;
    FGapInsideRectX: Single;
    FGapInsideRectY: Single;
    FRectList: TRectangleList;
    FMoveRectIndex: Integer;
    procedure SetSizes;
  end;

const
  cstTimerInterval = 30;
  cstRectWidth = 160;
  cstRectHeight = 180;
  cstRoundingCoeff = 5;

var
  FrmRectangles: TFrmRectangles;

implementation

{$R *.fmx}


procedure TFrmRectangles.FormCreate(Sender: TObject);
begin
  //RegisterFmxClasses([TPanel]);
  Randomize;

  {$IFDEF ANDROID}
    Width := Screen.Size.Width;
    Height := Screen.Size.Height;
  {$ENDIF}

  SetSizes;
  FRectList := TRectangleList.Create;
  tmrMoving.Interval := cstTimerInterval;
  tmrMoving.Enabled := True;
end;

procedure TFrmRectangles.FormDestroy(Sender: TObject);
begin
  FRectList.Free;
end;

procedure TFrmRectangles.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  i: Integer;
begin
  FMouseIsDown := True;
  FMoveRectIndex := -1;

  for i := 0 to FRectList.Count - 1 do
    if (X > FRectList[i].Position.X) and (X < FRectList[i].Position.X + cstRectWidth)
       and (Y > FRectList[i].Position.Y) and (Y < FRectList[i].Position.Y + cstRectHeight)
    then
    begin
      FMoveRectIndex := i;

      FRectPositionX := X;
      FRectPositionY := Y;
      FGapInsideRectX := X - FRectList[i].Position.X;
      FGapInsideRectY := Y - FRectList[i].Position.Y;

      Break;
    end;
end;

procedure TFrmRectangles.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FMouseIsDown := False;
end;

procedure TFrmRectangles.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
var
  i: Integer;
begin
  if FMouseIsDown then
  begin
    FRectPositionX := X;
    FRectPositionY := Y;
    Exit;
  end;

  for i := 0 to FRectList.Count - 1 do
    if (X > FRectList[i].Position.X) and (X < FRectList[i].Position.X + cstRectWidth)
       and (Y > FRectList[i].Position.Y) and (Y < FRectList[i].Position.Y + cstRectHeight)
    then
    begin
      PaintBox.Cursor := crHandpoint;
      Break;
    end
    else
    begin
      PaintBox.Cursor := crDefault;
    end;
end;

procedure TFrmRectangles.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
var
  i: Integer;
  LSolidRectF, LGradientRectF: TRectF;
  LCorners: TCorners;
  LStrokeBrush: TStrokeBrush;
  LGradientBrush: TBrush;

  LSolidX1, LSolidY1, LSolidX2, LSolidY2, LShadowX1, LShadowY1, LShadowX2, LShadowY2: Single;
begin
  Canvas.ClearRect(TRectF.Create( TPointF.Create(0, 0), TPointF.Create(PaintBox.Width, PaintBox.Height) ), $FFFFFFFF);

  BeginUpdate;
  try
    for i := 0 to FRectList.Count - 1 do
    begin
      if FMouseIsDown and (i = FMoveRectIndex) then
      begin
        FRectList[i].Position.X := FRectPositionX - FGapInsideRectX;
        FRectList[i].Position.Y := FRectPositionY - FGapInsideRectY;
      end;

      LShadowX1 := FRectList[i].Position.X;
      LShadowY1 := FRectList[i].Position.Y;
      LShadowX2 := FRectList[i].Position.X + cstRectWidth;
      LShadowY2 := FRectList[i].Position.Y + cstRectHeight;

      LSolidX1 := LShadowX1 - (cstRectWidth / 5);
      LSolidY1 := LShadowY1 - (cstRectHeight / 5);
      LSolidX2 := LShadowX2 + (cstRectWidth / 5);
      LSolidY2 := LShadowY2 + (cstRectHeight / 5);

      LGradientRectF := TRectF.Create( TPointF.Create(LSolidX1, LSolidY1), TPointF.Create(LSolidX2, LSolidY2) );
      LGradientBrush := TBrush.Create(TBrushKind.Gradient, TAlphaColors.Black);
      LGradientBrush.Gradient.Color := $00000000;
      LGradientBrush.Gradient.Color1 := $77000000;
      LGradientBrush.Gradient.Style := TGradientStyle.Radial;
      LGradientBrush.Gradient.RadialTransform.Position.X := LSolidX1;
      LGradientBrush.Gradient.RadialTransform.Position.Y := LSolidY1;

      Canvas.FillRect( LGradientRectF, 1, LGradientBrush );

      LCorners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight];

      LSolidRectF := TRectF.Create( TPointF.Create(LShadowX1, LShadowY1), TPointF.Create(LShadowX2, LShadowY2) );
      LStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, $FF7BAE0F);
      Canvas.FillRect(
        LSolidRectF, cstRectWidth / cstRoundingCoeff, cstRectHeight / cstRoundingCoeff, LCorners, 1, LStrokeBrush, TCornerType.Round
      );

      LSolidRectF := TRectF.Create( TPointF.Create(LShadowX1, LShadowY1), TPointF.Create(LShadowX2, LShadowY2) );
      LStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, $FF149DE7);
      Canvas.DrawRect(
        LSolidRectF, cstRectWidth / cstRoundingCoeff, cstRectHeight / cstRoundingCoeff, LCorners, 1, LStrokeBrush, TCornerType.Round
      );

      {
      LSolidRectF := TRectF.Create( TPointF.Create(LSolidX1, LSolidY1), TPointF.Create(LSolidX2, LSolidY2) );
      LStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Red);
      Canvas.DrawRect(
        LSolidRectF, cstRectWidth / cstRoundingCoeff, cstRectHeight / cstRoundingCoeff, LCorners, 1, LStrokeBrush, TCornerType.Round
      );
      }
    end;
  finally
    EndUpdate;
  end;
end;

procedure TFrmRectangles.btnAddClick(Sender: TObject);
var
  LRect: TRect;
begin
  LRect := TRect.Create(nil {pnlMain}, 30, 30);

  with LRect do
  begin
    Parent := TFmxObject(Owner);

    Opacity := 0.8;
    Fill.Color := TAlphaColors.Gray;
    Fill.Kind := TBrushKind.Solid;
    Stroke.Thickness := 0;

    Width := cstRectWidth;
    Height := cstRectHeight;
    BringToFront;
  end;

  FRectList.Add(LRect);

  PaintBox.Repaint;
end;

procedure TFrmRectangles.btnExitClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmRectangles.SetSizes;
begin
  // FMX bug: иногда выставляет некорректный размер панели кнопок
  pnlButtons.Width := Width;
  pnlMain.Width := Width;
end;

procedure TFrmRectangles.tmrMovingTimer(Sender: TObject);
begin
  if FMouseIsDown then
    PaintBox.Repaint;
end;

end.
