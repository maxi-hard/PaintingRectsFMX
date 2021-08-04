unit UObjects;

interface

uses
  System.Generics.Collections, System.Classes, FMX.Objects;

type
  TRect = class(TRectangle)
  public
    constructor Create(AOwner: TComponent; AX, AY: Integer);
  end;

  TRectangleList = class(TObjectList<TRect>);

implementation

{ TRectangle }

constructor TRect.Create(AOwner: TComponent; AX, AY: Integer);
begin
  inherited Create(AOwner);
  Position.X := AX;
  Position.Y := AY;
end;

end.
