unit form.main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.IniFiles, System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Information;

const
  WM_UPDATE_PROCESS_LIST = WM_USER + 100;

type
  TMainForm = class(TForm)
    procedure FormCreate(ASender: TObject);
    procedure FormDestroy(ASender: TObject);
  private
    FTimerUI: TTimer;
    FProcessList: IProcessList;
    FCS: TCriticalSection;
    FSettings: TIniFile;
    FIsUpdate: Boolean;
    FRunThread: TSimpleEvent;
    procedure InnerUpdateInformation(ASender: TObject);
    function InnerProcessListGet: IProcessList;
    procedure InnerProcessListSet(AValue: IProcessList);
    procedure WmUpdateProcessList(var AMsg: TMessage); message WM_UPDATE_PROCESS_LIST;
    procedure InnerUpdateProcessList(AProcessList: IProcessList);
  public
    property ProcessList: IProcessList read InnerProcessListGet write InnerProcessListSet;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  CSettings = 'Settings';
  CUpdateInformation = 'UpdateInformation';

procedure TMainForm.FormCreate(ASender: TObject);
begin
  FCS := TCriticalSection.Create;
  FRunThread := TSimpleEvent.Create;

  FIsUpdate := False;
  FSettings := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));

  FTimerUI := TTimer.Create(Self);
  FTimerUI.Enabled := False;
  FTimerUI.OnTimer := InnerUpdateInformation;
  FTimerUI.Interval := Cardinal(FSettings.ReadInteger(CSettings, CUpdateInformation, 1000));
  FTimerUI.OnTimer(Self);
end;

procedure TMainForm.FormDestroy(ASender: TObject);
begin
  FTimerUI.Enabled := False;
  FRunThread.WaitFor();
  FSettings.Free;
  FCS.Free;
end;

function TMainForm.InnerProcessListGet: IProcessList;
begin
  FCS.Enter;
  try
    Result := FProcessList
  finally
    FCS.Leave
  end;
end;

procedure TMainForm.InnerProcessListSet(AValue: IProcessList);
begin
  FCS.Enter;
  try
    FProcessList := AValue;
    FIsUpdate := True;
  finally
    FCS.Leave
  end;
  PostMessage(Handle, WM_UPDATE_PROCESS_LIST, 0, 0);
end;

procedure TMainForm.InnerUpdateInformation(ASender: TObject);
 var
  LProcessList: IProcessList;
begin
  FTimerUI.Enabled := False;
  FRunThread.ResetEvent;

  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LProcessList := GetProcessList;
        if LProcessList = nil then
          Exit;
        Self.ProcessList := LProcessList
      finally
        FRunThread.SetEvent;
      end;
    end
  ).Start;
  FTimerUI.Enabled := True;
end;

procedure TMainForm.InnerUpdateProcessList(AProcessList: IProcessList);
 var
  LIndex : NativeInt;
begin
  Writeln;
  Writeln(' ========= Новый список');
  for LIndex := 0 to Pred(AProcessList.ProcessCount) do
    Writeln(AProcessList[LIndex].ProcessName, '     ', AProcessList[LIndex].ProcessPath);
end;

procedure TMainForm.WmUpdateProcessList(var AMsg: TMessage);
begin
  InnerUpdateProcessList(Self.ProcessList)
end;

end.
