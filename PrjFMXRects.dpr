program PrjFMXRects;

uses
  FMX.Forms,
  UMain in 'UMain.pas' {FrmRectangles},
  UObjects in 'UObjects.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmRectangles, FrmRectangles);
  Application.Run;
end.
