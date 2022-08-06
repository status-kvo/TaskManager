unit Information;

interface

uses
  Winapi.Windows, {$IFDEF FPC} jwaTlHelp32{$ELSE} Winapi.TlHelp32{$ENDIF}, //Winapi.ShellAPI,
  System.SysUtils, System.StrUtils, System.Classes,
  Vcl.Graphics,
  WinFileInfo;


//   WinFileInfo, APK_System, StrRect;

type
  TProcessBits = (pbUnknown, pb32bit, pb64bit);

  RecProcessEntry = record
    ProcessID:      UInt32;
    ParentID :      UInt32;
    ProcessBits:    TProcessBits;
    ProcessName:    String;
    ProcessPath:    String;
    Description:    String;
    CompanyName:    String;
    Icon:           TBitmap;
    LimitedAccess:  Boolean;
    Hash:           NativeInt;
   public
    function BitsToString: String;
    procedure HashCalc;
  end;

//type
//  IProcessList = interface
//    ['{2E59A551-4A0E-4936-9BC0-558E8B6D0D39}']
//
//    function GetProcessCount: NativeInt;
//    function GetProcess(Index: NativeInt): RecProcessEntry;
//
//    function IndexOfByName(const ProcessName: String): NativeInt; overload;
//    function IndexOfByPID(const ProcessID: UInt32): NativeInt; overload;
//
//    property Processes[Index: NativeInt]: RecProcessEntry read GetProcess; default;
//    property ProcessCount: NativeInt read GetProcessCount;
//  end;

type
  ArrProcessList = array of RecProcessEntry;
  ArrProcessListPtr = array of ^RecProcessEntry;

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
  TProcessList = class(TObject)
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
    function GetProcessByParentPID(AProcessID: UInt32): ArrProcessListPtr;

    function IndexOfByName(const AProcessName: String): NativeInt; overload; virtual;
    function IndexOfByPID(const AProcessID: UInt32): NativeInt; overload; virtual;

    property Processes[Index: NativeInt]: RecProcessEntry read GetProcess; default;
    property ProcessCount: NativeInt read GetProcessCount;
   public
    constructor Create(const AIconBackground: TColor);
    procedure AfterConstruction; override;
    destructor Destroy; override;
   public
    class constructor Create;
    class destructor Destroy;
  end;

implementation

function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall; external 'PSAPI.dll' name 'GetProcessImageFileNameW';

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

procedure TProcessList.AfterConstruction;
begin
  InnerEnumerate;
end;

constructor TProcessList.Create(const AIconBackground: TColor);
begin
  inherited Create;

  FIconBackground := AIconBackground;
  SetLength(FProcesses,0);
  SetLength(FDevices,0);
end;

class constructor TProcessList.Create;
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

class destructor TProcessList.Destroy;
begin
  FWoW64RedirectValue := nil;
  FDisableWoW64RedirectProc := nil;
  FRevertWoW64RedirectProc := nil;
end;

function TProcessList.DisableWoW64Redirection: Boolean;
begin
  Result := False;
  if (@FDisableWoW64RedirectProc <> nil) then
    if (@FRevertWoW64RedirectProc <> nil) then
      Result := FDisableWoW64RedirectProc(@FWoW64RedirectValue)
end;

function TProcessList.EnableWoW64Redirection: Boolean;
begin
  Result := False;
  if (@FDisableWoW64RedirectProc <> nil) then
    if (@FRevertWoW64RedirectProc <> nil) then
      Result := FRevertWoW64RedirectProc(FWoW64RedirectValue)
end;

destructor TProcessList.Destroy;
begin
  InnerClear;
  inherited;
end;

function TProcessList.GetProcessCount: NativeInt;
begin
  Result := Length(FProcesses)
end;

function TProcessList.GetProcess(AIndex: NativeInt): RecProcessEntry;
begin
  if (AIndex >= Low(FProcesses)) and (AIndex <= High(FProcesses)) then
    Result := FProcesses[AIndex]
  else
    raise Exception.CreateFmt('TProcessList.GetProcess: Index (%d) out of bounds.', [AIndex]);
end;

function TProcessList.GetProcessByParentPID(AProcessID: UInt32): ArrProcessListPtr;
 var
  LIndex:  NativeInt;
begin
  Result := [];
  for LIndex := Low(FProcesses) to High(FProcesses) do
    if FProcesses[LIndex].ParentID = AProcessID then
      Result := Result + [@FProcesses[LIndex]]
end;

function TProcessList.IndexOfByName(const AProcessName: String): NativeInt;
 var
  LIndex:  NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    if AnsiSameText(AProcessName, FProcesses[LIndex].ProcessName) then
      Exit(LIndex);
  Result := -1;
end;

function TProcessList.IndexOfByPID(const AProcessID: UInt32): NativeInt;
 var
  LIndex:  NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    if FProcesses[LIndex].ProcessID = AProcessID then
      Exit(LIndex);
  Result := -1;
end;

procedure TProcessList.InnerClear;
 var
  LIndex: NativeInt;
begin
  for LIndex := Low(FProcesses) to High(FProcesses) do
    FreeAndNil(FProcesses[LIndex].Icon);
  SetLength(FProcesses,0);
  SetLength(FDevices,0);
end;

procedure TProcessList.InnerEnumerate;
begin
  DisableWoW64Redirection;
  try
    InnerEnumerateDevices;
    InnerEnumerateProcess;
   finally
    EnableWoW64Redirection;
  end;
end;

procedure TProcessList.InnerEnumerateDevices;
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

procedure TProcessList.InnerEnumerateProcess;
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
          FProcesses[High(FProcesses)].ParentID := LProcessEntry32.th32ParentProcessID;
          InnerGetProcessImageInfo(FProcesses[High(FProcesses)]);
        until not Process32Next(LSnapshotHandle,LProcessEntry32);
    finally
      CloseHandle(LSnapshotHandle);
    end;
end;

type
  ThIconArray = array[0..0] of hIcon;
type
  PhIconArray = ^ThIconArray;

function ExtractIconEx(lpszFile: PWideChar; nIconIndex: Integer;
  phiconLarge: PhIconArray; phiconSmall: PhIconArray; nIcons: UINT): UINT; stdcall; external 'shell32.dll' name 'ExtractIconExW';

function TProcessList.InnerExtractIcon(const AFileName: String): TBitmap;
 var
  LSmall: phIconArray;
  LNumIcons: UINT;
  TheIcon: TIcon;
begin
  Result := nil;

  if AFileName = '' then
    Exit;

  LNumIcons := ExtractIconEx(PChar(AFileName), -1, nil, nil, 0);
  if LNumIcons > 0 then
  begin
    LNumIcons := 1;
    //GetMem(LLarge, LNumIcons * sizeof(hIcon));
    GetMem(LSmall, LNumIcons * sizeof(hIcon));
    try
      //FillChar(LLarge^, LNumIcons * sizeof(hIcon), #0);
      FillChar(LSmall^, LNumIcons * sizeof(hIcon), #0);
      ExtractIconEx(PChar(AFileName), 0, nil, LSmall, LNumIcons);
      //for i := 0 to (LNumIcons - 1) do
      //begin
        TheIcon := TIcon.Create;
        try
          TheIcon.Handle := LSmall^[0];
          Result := TBitmap.Create(TheIcon.Width, TheIcon.Height);
          Result.Canvas.Draw(0, 0, TheIcon);
        finally
          TheIcon.Free;
        end;
      //end;
    finally
      //FreeMem(LLarge, LNumIcons * sizeof(hIcon));
      FreeMem(LSmall, LNumIcons * sizeof(hIcon));
    end;
  end;
end;

function TProcessList.InnerGetProcessBits(AProcessHandle: THandle): TProcessBits;
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

procedure TProcessList.InnerGetProcessImageInfo(var AProcessEntry: RecProcessEntry);
var
  LHandle: THandle;
  LIndex, LInfoIndex: NativeInt;
begin

  if (Win32MajorVersion >= 6) then
    LHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessEntry.ProcessID)
  else
    LHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, AProcessEntry.ProcessID);

  if LHandle <> 0 then
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
  AProcessEntry.HashCalc
end;

function TProcessList.InnerGetProcessPath(AProcessHandle: THandle): String;
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

procedure RecProcessEntry.HashCalc;
 var
   LStr: String;
begin
  LStr := ProcessID.ToString + NativeInt(ProcessBits).ToString + ProcessName + ProcessPath + NativeInt(LimitedAccess).ToString;
  Hash := LStr.GetHashCode
end;

end.
