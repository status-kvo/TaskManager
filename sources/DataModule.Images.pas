unit DataModule.Images;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls,
  cxImageList, cxGraphics;

type
  TImagesDataModule = class(TDataModule)
    ImageList32x32: TcxImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImagesDataModule: TImagesDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
