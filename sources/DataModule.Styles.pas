unit DataModule.Styles;

interface

uses
  System.SysUtils, System.Classes;

type
  TStylesDataModule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StylesDataModule: TStylesDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
