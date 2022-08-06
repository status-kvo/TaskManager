unit form.main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.IniFiles, System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Information,
  DataModule.Images,
  dxForms, dxBarBuiltInMenu, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxPC, dxBar, cxClasses, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges,
  dxScrollbarAnnotations, Data.DB, cxDBData, cxGridLevel, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxImage, cxTL,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData, cxDBTL, cxMaskEdit,
  cxCheckBox;

const
  WM_UPDATE_PROCESS_LIST = WM_USER + 100;

type
  TMainForm = class(TdxForm)
    pgcMain: TcxPageControl;
    tbsProcess: TcxTabSheet;
    BarManager: TdxBarManager;
    bMenu: TdxBar;
    lbtnProcessViewTree: TdxBarLargeButton;
    lbtnProcessProcessList: TdxBarLargeButton;
    GridProcess: TcxGrid;
    GridProcessLevel: TcxGridLevel;
    GridProcessTableViewTree: TcxGridDBTableView;
    GridProcessTableViewList: TcxGridDBTableView;
    tblProcess: TFDMemTable;
    tblProcessProcessID: TIntegerField;
    tblProcessProcessBits: TSmallintField;
    tblProcessProcessBitsName: TStringField;
    tblProcessProcessName: TStringField;
    tblProcessProcessPath: TStringField;
    tblProcessDescription: TStringField;
    tblProcessCompanyName: TStringField;
    tblProcessIcon: TGraphicField;
    tblProcessLimitedAccess: TBooleanField;
    dsProcess: TDataSource;
    tblProcessParentId: TIntegerField;
    GridProcessTableViewTreeProcessID: TcxGridDBColumn;
    GridProcessTableViewTreeProcessBits: TcxGridDBColumn;
    GridProcessTableViewTreeProcessBitsName: TcxGridDBColumn;
    GridProcessTableViewTreeProcessName: TcxGridDBColumn;
    GridProcessTableViewTreeProcessPath: TcxGridDBColumn;
    GridProcessTableViewTreeDescription: TcxGridDBColumn;
    GridProcessTableViewTreeCompanyName: TcxGridDBColumn;
    GridProcessTableViewTreeIcon: TcxGridDBColumn;
    GridProcessTableViewTreeLimitedAccess: TcxGridDBColumn;
    GridProcessTableViewTreeParentId: TcxGridDBColumn;
    GridProcessTableViewListProcessID: TcxGridDBColumn;
    GridProcessTableViewListProcessBits: TcxGridDBColumn;
    GridProcessTableViewListProcessBitsName: TcxGridDBColumn;
    GridProcessTableViewListProcessName: TcxGridDBColumn;
    GridProcessTableViewListProcessPath: TcxGridDBColumn;
    GridProcessTableViewListDescription: TcxGridDBColumn;
    GridProcessTableViewListCompanyName: TcxGridDBColumn;
    GridProcessTableViewListIcon: TcxGridDBColumn;
    GridProcessTableViewListLimitedAccess: TcxGridDBColumn;
    GridProcessTableViewListParentId: TcxGridDBColumn;
    tblProcessHash: TIntegerField;
    tbsProcessTree: TcxTabSheet;
    TreeList: TcxDBTreeList;
    TreeListProcessID: TcxDBTreeListColumn;
    TreeListProcessBits: TcxDBTreeListColumn;
    TreeListProcessBitsName: TcxDBTreeListColumn;
    TreeListProcessName: TcxDBTreeListColumn;
    TreeListProcessPath: TcxDBTreeListColumn;
    TreeListDescription: TcxDBTreeListColumn;
    TreeListCompanyName: TcxDBTreeListColumn;
    TreeListIcon: TcxDBTreeListColumn;
    TreeListLimitedAccess: TcxDBTreeListColumn;
    TreeListParentId: TcxDBTreeListColumn;
    TreeListHash: TcxDBTreeListColumn;
    procedure FormCreate(ASender: TObject);
    procedure FormDestroy(ASender: TObject);
    procedure lbtnProcessViewTreeClick(Sender: TObject);
    procedure lbtnProcessProcessListClick(Sender: TObject);
  private
    FTimerUI: TTimer;
    FProcessList: TProcessList;
    FCS: TCriticalSection;
    FSettings: TIniFile;
    FIsUpdate: Boolean;
    FRunThread: TSimpleEvent;
    procedure InnerUpdateInformation(ASender: TObject);
    function InnerProcessListGet: TProcessList;
    procedure InnerProcessListSet(AValue: TProcessList);
    procedure WmUpdateProcessList(var AMsg: TMessage); message WM_UPDATE_PROCESS_LIST;
    procedure InnerUpdateProcessList(AProcessList: TProcessList);
//  public
//    property ProcessList: IProcessList read InnerProcessListGet write InnerProcessListSet;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  CSettings = 'Settings';
  CUpdateInformation = 'UpdateInformation';
  CProcessId = 'ProcessId';

procedure TMainForm.FormCreate(ASender: TObject);
begin
  pgcMain.Properties.HideTabs := True;
  tblProcess.Active := False;
  tblProcess.Active := True;
  lbtnProcessViewTreeClick(Self);

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
  InnerProcessListSet(nil);
  FSettings.Free;
  FCS.Free;
  FRunThread.Free;
end;

function TMainForm.InnerProcessListGet: TProcessList;
begin
  FCS.Enter;
  try
    Result := FProcessList;
//    FProcessList := nil;
    FIsUpdate := False;
  finally
    FCS.Leave
  end;
end;

procedure TMainForm.InnerProcessListSet(AValue: TProcessList);
begin
  FCS.Enter;
  try
    FProcessList.DisposeOf;
    FProcessList := AValue;
    FIsUpdate := True;
  finally
    FCS.Leave
  end;
  PostMessage(Handle, WM_UPDATE_PROCESS_LIST, 0, 0);
end;

procedure TMainForm.InnerUpdateInformation(ASender: TObject);
begin
  FTimerUI.Enabled := False;
  FRunThread.ResetEvent;

  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        InnerProcessListSet(TProcessList.Create(clWhite));
      finally
        FRunThread.SetEvent;
        if not (csDestroying in ComponentState) then
          FTimerUI.Enabled := True;
      end;
    end
  ).Start;
end;

procedure TMainForm.InnerUpdateProcessList(AProcessList: TProcessList);
 var
  LIndex, LPidOld, LPidCheck: NativeInt;
  LProcessEntry: RecProcessEntry;
  LStream: TBytesStream;
begin
  LPidOld := -1;

  tblProcess.DisableControls;
  try
    if (tblProcess.RecordCount > 0) then
      LPidOld := tblProcess.FieldByName(CProcessId).AsInteger;

    tblProcess.First;
    while not tblProcess.Eof do
    begin
      LPidCheck := tblProcess.FieldByName(CProcessId).AsInteger;
      if AProcessList.IndexOfByPID(LPidCheck) = -1 then
        tblProcess.Delete
      else
        tblProcess.Next
    end;

    for LIndex := 0 to Pred(AProcessList.ProcessCount) do
    begin
      LProcessEntry := AProcessList.Processes[LIndex];

      if LProcessEntry.LimitedAccess then
        Continue;

      tblProcess.First;
      try
        if tblProcess.Locate(CProcessId, LProcessEntry.ProcessID, []) then
        begin
          if tblProcess.FieldByName('Hash').AsInteger = Integer(LProcessEntry.Hash) then
            continue;
          tblProcess.Edit
        end
        else
        begin
          tblProcess.Append;
          tblProcess.FieldByName(CProcessId).AsInteger := LProcessEntry.ProcessID;
        end;

        tblProcess.FieldByName('ProcessBits').AsInteger := Integer(LProcessEntry.ProcessBits);
        tblProcess.FieldByName('ProcessBitsName').AsString := LProcessEntry.BitsToString;
        tblProcess.FieldByName('ProcessName').AsString := Format('%s (%s)', [LProcessEntry.ProcessName, LProcessEntry.BitsToString]);
        tblProcess.FieldByName('ProcessPath').AsString := LProcessEntry.ProcessPath;
        tblProcess.FieldByName('Description').AsString := LProcessEntry.Description;
        tblProcess.FieldByName('CompanyName').AsString := LProcessEntry.CompanyName;
        tblProcess.FieldByName('LimitedAccess').AsBoolean := LProcessEntry.LimitedAccess;
        tblProcess.FieldByName('ParentID').AsInteger := Integer(LProcessEntry.ParentID);

        if LProcessEntry.Icon <> nil then
        begin
          LStream := nil;
          try
            LStream := TBytesStream.Create;
            LProcessEntry.Icon.SaveToStream(LStream);
            tblProcess.FieldByName('Icon').AsBytes := LStream.Bytes
          finally
            LStream.Free;
          end;
        end;

        tblProcess.Post;
      except
        tblProcess.Cancel
      end;
    end;
  finally
    tblProcess.First;
    if (LPidOld > -1) then
      if (tblProcess.RecordCount > 0) then
        tblProcess.Locate(CProcessId, LPidOld, []);
    tblProcess.EnableControls;
  end;
end;

procedure TMainForm.lbtnProcessProcessListClick(Sender: TObject);
begin
  pgcMain.ActivePage := tbsProcess;
  GridProcessLevel.GridView := GridProcessTableViewList
end;

procedure TMainForm.lbtnProcessViewTreeClick(Sender: TObject);
begin
//  pgcMain.ActivePage := tbsProcess;
//  GridProcessLevel.GridView := GridProcessTableViewTree
  pgcMain.ActivePage := tbsProcessTree;
end;

procedure TMainForm.WmUpdateProcessList(var AMsg: TMessage);
 var
  LProcessList: TProcessList;
begin
  LProcessList := InnerProcessListGet;
  if LProcessList <> nil then
  begin
    InnerUpdateProcessList(LProcessList);
    InnerProcessListSet(nil)
  end;
end;

initialization
  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := true
  {$ENDIF}

end.
