unit Information;

interface

uses
  Winapi.Windows, {$IFDEF FPC} jwaTlHelp32{$ELSE} Winapi.TlHelp32{$ENDIF}, Winapi.ShellAPI,
  System.SysUtils, System.StrUtils, System.Classes,
  Vcl.Graphics,
  WinFileInfo;


//   WinFileInfo, APK_System, StrRect;

type
  TProcessBits = (pbUnknown, pb32bit, pb64bit);

  RecProcessEntry = record
    ProcessID:      UInt32;
    ProcessBits:    TProcessBits;
    ProcessName:    String;
    ProcessPath:    String;
    Description:    String;
    CompanyName:    String;
    Icon:           TBitmap;
    LimitedAccess:  Boolean;
   public
     function BitsToString: String;
  end;

type
  IProcessList = interface

    function GetProcessCount: NativeInt;
    function GetProcess(Index: NativeInt): RecProcessEntry;

    function IndexOfByName(const ProcessName: String): NativeInt; overload;
    function IndexOfByPID(const ProcessID: UInt32): NativeInt; overload;

    property Processes[Index: NativeInt]: RecProcessEntry read GetProcess; default;
    property ProcessCount: NativeInt read GetProcessCount;
  end;

function GetProcessList(const AIconBackground: TColor = clWhite): IProcessList;

implementation

function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall; external 'PSAPI.dll' name 'GetProcessImageFileNameW';

type
  ArrProcessList = array of RecProcessEntry;

type
  TDeviceEntry = record
    DrivePath:  String;
    DevicePath: String;
  end;

type
  ArrDevicesList = array of TDeviceEntry;

type
  TWow64DisableWow64FsRedirection = function(AOldValue: PPointer): BOOL; stdcall;
  TWow64RevertWow64FsRedirection = function(AOldValue: Pointer): BOOL; stdcall;

type
  TInnerProcessList = class(TInterfacedObject, IProcessList)
   private
    class var FRunningInWin64: Boolean;
   private
    class var FDisableWoW64RedirectProc: TWow64DisableWow64FsRedirection;
   private
    class var FRevertWoW64RedirectProc: TWow64RevertWow64FsRedirection;
   private
    class var FWoW64RedirectValue: Pointer;
   private
    FProcesses: ArrProcessList;
    FDevices: ArrDevicesList;
    FIconBackground: TColor;
    procedure InnerClear;
    procedure InnerEnumerate;
    procedure InnerEnumerateDevices;
    procedure InnerEnumerateProcess;
    procedure InnerGetProcessImageInfo(var AProcessEntry: RecProcessEntry);
   private
    function InnerExtractIcon(const AFileName: String): TBitmap;
    Function InnerGetProcessBits(AProcessHandle: THandle): TProcessBits;
    Function InnerGetProcessPath(AProcessHandle: THandle): String;
   private
     function DisableWoW64Redirection: Boolean;
     function EnableWoW64Redirection: Boolean;
   public
    // IProcessList
    function GetProcessCount: NativeInt;
    function GetProcess(AIndex: NativeInt): RecProcessEntry;
    function IndexOfByName(const AProcessName: String): NativeInt; overload; virtual;
    function IndexOfByPID(const AProcessID: UInt32): NativeInt; overload; virtual;
   public
    constructor Create(const AIconBackground: TColor);
    procedure AfterConstruction; override;
    destructor Destroy; override;
   public
    class constructor Create;
    class destructor Destroy;
  end;

function GetProcessList(const AIconBackground: TColor): IProcessList;
begin
  Result := TInnerProcessList.Create(AIconBackground)
end;

{ RecProcessEntry }

function RecProcessEntry.BitsToString: String;
begin
  case ProcessBits of
    pb32bit:
      Result := '32 bit';
    pb64bit:
      Result := '64 bit';
   else
    Result := 'unknown';
  end;
end;

const
  PROCESS_QUERY_LIMITED_INFORMATION = $00001000;


{ TInnerProcessList }

procedure TInnerProcessList.AfterConstruction;
begin
  InnerEnumerate;
end;

constructor TInnerProcessList.Create(const AIconBackground: TColor);
begin
  inherited Create;

  FIconBackground := AIconBackground;
  SetLength(FProcesses,0);
  SetLength(FDevices,0);
end;

class constructor TInnerProcessList.Create;
 var
  LModuleHandle: THandle;
begin
  {$IFDEF Win64}
    FRunningInWin64 := True;
  {$ELSE}
    IsWow64Process(GetCurrentProcess, FRunningInWin64);
  {$ENDIF}

  FWoW64RedirectValue := nil;

  LModuleHandle := GetModuleHandle(kernel32);
  if LModuleHandle <> 0 then
  begin
    FDisableWoW64RedirectProc := GetProcAddress(LModuleHandle,'Wow64DisableWow64FsRedirection');
    FRevertWoW64RedirectProc := GetProcAddress(LModuleHandle,'Wow64RevertWow64FsRedirection');
  end
  else
    raise Exception.CreateFmt('TInnerProcessList.Create: Unable to load kernell32.dll library (0x.8x).', [GetLastError]);

  if (@FDisableWoW64RedirectProc = nil) or (@FRevertWoW64RedirectProc = nil) then
  begin
    FDisableWoW64RedirectProc := nil;
    FRevertWoW64RedirectProc := nil;
  end;
end;

class destructor TInnerProcessList.Destroy;
begin
  FWoW64RedirectValue := nil;
  FDisableWoW64RedirectProc := nil;
  FRevertWoW64RedirectProc := nil;
end;

function TInnerProcessList.DisableWoW64Redirection: Boolean;
begin
  Result := False;
  if (@FDisableWoW64RedirectProc <> nil) then
    if (@FRevertWoW64RedirectProc <> nil) then
      Result := FDisableWoW64RedirectProc(@FWoW64RedirectValue)
end;

function TInnerProcessList.EnableWoW64Redirection: Boolean;
begin
  Result := False;
  if (@FDisableWoW64RedirectProc <> nil) then
    if (@FRevertWoW64RedirectProc <> nil) then
      Result := FRevertWoW64RedirectProc(FWoW64RedirectValue)
end;

destructor TInnerProcessList.Destroy;
begin
  InnerClear;
  inherited;
end;

function TInnerProcessList.GetProcessCount: NativeInt;
begin
  Result := Length(FProcesses)
end;

function TInnerProcessList.GetProcess(AIndex: NativeInt): RecProcessEntry;
begin
  if (AIndex >= Low(FProcesses)) and (AIndex <= High(FProcesses)) then
    Result := FProcesses[AIndex]
  else
    raise Exception.CreateFmt('TProcessList.GetProcess: Index (%d) out of bounds.', [AIndex]);
end;

function TInnerProcessList.IndexOfByName(const AProcessName: String): NativeInt;
 var
  LIndex:  NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    if AnsiSameText(AProcessName, FProcesses[LIndex].ProcessName) then
      Exit(LIndex);
  Result := -1;
end;

function TInnerProcessList.IndexOfByPID(const AProcessID: UInt32): NativeInt;
 var
  LIndex:  NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    if FProcesses[LIndex].ProcessID = AProcessID then
      Exit(LIndex);
  Result := -1;
end;

procedure TInnerProcessList.InnerClear;
 var
  LIndex: NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    FreeAndNil(FProcesses[LIndex].Icon);
  SetLength(FProcesses,0);
  SetLength(FDevices,0);
end;

procedure TInnerProcessList.InnerEnumerate;
begin
  DisableWoW64Redirection;
  try
    InnerEnumerateDevices;
    InnerEnumerateProcess;
   finally
    EnableWoW64Redirection;
  end;
end;

procedure TInnerProcessList.InnerEnumerateDevices;
 type
  ArrString = array of String;
 var
  LTempStr: String;
  LDrivePaths, LDevicePaths: ArrString;
  LIndex, LIndexPred: NativeInt;
  LResLen: UInt32;

  procedure ParseStrings(AStr: String; out APaths: ArrString);
   var
    LSubStrLen:  NativeInt;
  begin
    SetLength(APaths,0);
    repeat
      LSubStrLen := StrLen(PChar(AStr));
      if LSubStrLen > 0 then
      begin
        SetLength(APaths, Length(APaths) + 1);
        APaths[High(APaths)] := Copy(AStr,1,LSubStrLen);
        Delete(AStr,1,LSubStrLen + 1);
      end;
    until LSubStrLen <= 0;
  end;

begin
  SetLength(LTempStr, GetLogicalDriveStrings(0,nil));
  SetLength(LTempStr, GetLogicalDriveStrings(Length(LTempStr), PChar(LTempStr)));

  ParseStrings(LTempStr, LDrivePaths);
  SetLength(fDevices, Length(LDrivePaths));

  for LIndex := Low(LDrivePaths) to High(LDrivePaths) do
  begin
    fDevices[LIndex].DrivePath := ExcludeTrailingPathDelimiter(LDrivePaths[LIndex]);
    SetLength(LTempStr,0);
    repeat
      SetLength(LTempStr, Length(LTempStr) + 1024);
      LResLen := QueryDosDevice(PChar(fDevices[LIndex].DrivePath), PChar(LTempStr), Length(LTempStr));
    until GetLastError <> ERROR_INSUFFICIENT_BUFFER;

    SetLength(LTempStr, LResLen);
    ParseStrings(LTempStr, LDevicePaths);
    if Length(LDevicePaths) > 0 then
      fDevices[LIndex].DevicePath := LDevicePaths[Low(LDevicePaths)]
    else
      fDevices[LIndex].DevicePath := '';
  end;

  for LIndex := High(fDevices) downto Low(fDevices) do
    if (fDevices[LIndex].DrivePath = '') or (fDevices[LIndex].DevicePath = '') then
      begin
        for LIndexPred := LIndex to Pred(High(fDevices)) do
          fDevices[LIndexPred] := fDevices[LIndexPred + 1];
        SetLength(fDevices, Length(fDevices) - 1);
      end;
end;

procedure TInnerProcessList.InnerEnumerateProcess;
 var
  LSnapshotHandle: THandle;
  LProcessEntry32: TProcessEntry32;
begin
  LSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if LSnapshotHandle <> INVALID_HANDLE_VALUE then
    try
      LProcessEntry32.dwSize := SizeOf(TProcessEntry32);
      if Process32First(LSnapshotHandle,LProcessEntry32) then
        repeat
          SetLength(FProcesses,Length(FProcesses) + 1);
          FProcesses[High(FProcesses)].ProcessName := StrPas(LProcessEntry32.szExeFile);
          FProcesses[High(FProcesses)].ProcessID := LProcessEntry32.th32ProcessID;
          InnerGetProcessImageInfo(FProcesses[High(FProcesses)]);
        until not Process32Next(LSnapshotHandle,LProcessEntry32);
    finally
      CloseHandle(LSnapshotHandle);
    end;
end;

function TInnerProcessList.InnerExtractIcon(const AFileName: String): TBitmap;
 var
  LIcon: HICON;
  LLarge: HICON;
begin
  Result := nil;

  if (ExtractIconExW(PChar(AFileName), 0, LLarge, LIcon, 1) <> 1) then
    Exit;

  if (LIcon = 0) then
    Exit;

  try
    Result := TBitmap.Create;
    Result.Canvas.Lock;
    try
      Result.Width := GetSystemMetrics(SM_CXSMICON);
      Result.Height := GetSystemMetrics(SM_CYSMICON);
      Result.Canvas.Brush.Color := FIconBackground;
      Result.Canvas.Brush.Style := bsSolid;
      Result.Canvas.FillRect(Rect(0,0,Result.Width,Result.Height));
      if not DrawIconEx(Result.Canvas.Handle, 0, 0, LIcon, Result.Width, Result.Height, 0, 0, DI_NORMAL) then
        FreeAndNil(Result);
    finally
      Result.Canvas.Unlock;
    end;
  except
    FreeAndNil(Result);
  end;
end;

function TInnerProcessList.InnerGetProcessBits(AProcessHandle: THandle): TProcessBits;
 var
  LResultValue: BOOL;
begin
  if IsWow64Process(AProcessHandle, LResultValue) then
  begin
    if (not LResultValue) and (FRunningInWin64) then
      Result := pb64bit
    else
      Result := pb32bit;
  end
  else
    Result := pbUnknown;
end;

procedure TInnerProcessList.InnerGetProcessImageInfo(var AProcessEntry: RecProcessEntry);
var
  LHandle: THandle;
  LIndex, LInfoIndex: NativeInt;
begin

  if (Win32MajorVersion >= 6) then
    LHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessEntry.ProcessID)
  else
    LHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, AProcessEntry.ProcessID);

  If LHandle <> 0 then
    try
      AProcessEntry.ProcessBits := InnerGetProcessBits(LHandle);
      AProcessEntry.ProcessPath := InnerGetProcessPath(LHandle);
      if (AProcessEntry.ProcessPath > '') then
        with TWinFileInfo.Create(AProcessEntry.ProcessPath, WFI_LS_VersionInfo) do
          try
            for LIndex := Pred(VersionInfoStringTableCount) downto 0 do
            begin
              LInfoIndex := IndexOfVersionInfoString(LIndex,'FileDescription');
              if (LInfoIndex >= 0) then
                AProcessEntry.Description :=  VersionInfoString[LIndex,LInfoIndex].Value;

              LInfoIndex := IndexOfVersionInfoString(LIndex,'CompanyName');
              if (LInfoIndex >= 0) then
                AProcessEntry.CompanyName :=  VersionInfoString[LIndex,LInfoIndex].Value;
            end
          finally
             Free;
          end;
      AProcessEntry.Icon := InnerExtractIcon(AProcessEntry.ProcessPath);
      AProcessEntry.LimitedAccess := False;
    finally
      CloseHandle(LHandle);
    end
  else
    AProcessEntry.LimitedAccess := True;
end;

function TInnerProcessList.InnerGetProcessPath(AProcessHandle: THandle): String;
 var
  LIndex: NativeInt;
begin
  SetLength(Result,MAX_PATH + 1);
  SetLength(Result, GetProcessImageFileName(AProcessHandle, PChar(Result), Length(Result)));

  // number of chars copied into buffer can be larger than is actual length of the string...
  if Length(Result) > 0 then
    SetLength(Result, StrLen(PChar(Result)));
//  Result := WinToStr(Result);

  if Length(Result) > 0 then
    for LIndex := Low(FDevices) to High(FDevices) do
      if AnsiStartsText(FDevices[LIndex].DevicePath,Result) then
        Exit(FDevices[LIndex].DrivePath + Copy(Result,Length(FDevices[LIndex].DevicePath) + 1,Length(Result)))
end;

end.
