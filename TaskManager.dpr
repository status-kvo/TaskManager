program TaskManager;

uses
  Winapi.Windows,
  System.UITypes,
  System.SysUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  form.main in 'sources\form.main.pas' {MainForm},
  Information in 'sources\Information.pas',
  WinFileInfo in 'sources\WinFileInfo.pas',
  AuxTypes in 'sources\AuxTypes.pas',
  StrRect in 'sources\StrRect.pas';

{$R *.res}

function IsElevated: Boolean;
 const
  CTokenElevation = TTokenInformationClass(20);
 var
  LTokenHandle: THandle;
  LLen: Cardinal;
  LTokenElevation: TOKEN_ELEVATION;
  LGotToken: Boolean;
begin
  Result := False;
  if CheckWin32Version(6, 0) then
  begin
    LTokenHandle := 0;

    LGotToken := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, LTokenHandle);
    if not LGotToken then
      if (GetLastError = ERROR_NO_TOKEN) then
        LGotToken := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, LTokenHandle);

    if LGotToken then
      try
        LLen := 0;
        if GetTokenInformation(LTokenHandle, CTokenElevation, @LTokenElevation, SizeOf(LTokenElevation), LLen) then
          Result := LTokenElevation.TokenIsElevated <> 0
      finally
        CloseHandle(LTokenHandle);
      end
  end
  else
    Result := True
end;

resourcestring
  rsRequiresElevationToAdministratorToWork = 'Для работы требуется повышения прав до администратора';

begin
  if not IsElevated then
  begin
    MessageDlg(rsRequiresElevationToAdministratorToWork, mtError, [mbClose], 0);
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
