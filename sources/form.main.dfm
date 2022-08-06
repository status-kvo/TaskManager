object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1044#1080#1089#1087#1077#1090#1095#1077#1088' '#1079#1072#1076#1072#1095
  ClientHeight = 515
  ClientWidth = 955
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pgcMain: TcxPageControl
    Left = 46
    Top = 0
    Width = 909
    Height = 515
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tbsProcessTree
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 511
    ClientRectLeft = 4
    ClientRectRight = 905
    ClientRectTop = 26
    object tbsProcess: TcxTabSheet
      Caption = 'Process'
      ImageIndex = 0
      object GridProcess: TcxGrid
        Left = 0
        Top = 0
        Width = 901
        Height = 485
        Align = alClient
        TabOrder = 0
        object GridProcessTableViewTree: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = False
          Navigator.Buttons.PriorPage.Visible = False
          Navigator.Buttons.Prior.Visible = False
          Navigator.Buttons.Next.Visible = False
          Navigator.Buttons.NextPage.Visible = False
          Navigator.Buttons.Last.Visible = False
          Navigator.Buttons.Insert.Visible = False
          Navigator.Buttons.Append.Enabled = False
          Navigator.Buttons.Delete.Visible = False
          Navigator.Buttons.Edit.Visible = False
          Navigator.Buttons.Post.Visible = False
          Navigator.Buttons.Cancel.Visible = False
          Navigator.Buttons.Refresh.Visible = False
          Navigator.Buttons.SaveBookmark.Visible = False
          Navigator.Buttons.GotoBookmark.Visible = False
          Navigator.Buttons.Filter.Visible = False
          Navigator.InfoPanel.DisplayMask = '[RecordIndex] '#1080#1079' [RecordCount]'
          Navigator.InfoPanel.Visible = True
          Navigator.Visible = True
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dsProcess
          DataController.KeyFieldNames = 'ProcessID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.ScrollBars = ssNone
          object GridProcessTableViewTreeIcon: TcxGridDBColumn
            DataBinding.FieldName = 'Icon'
            PropertiesClassName = 'TcxImageProperties'
            Width = 29
          end
          object GridProcessTableViewTreeProcessID: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessID'
            Width = 82
          end
          object GridProcessTableViewTreeProcessBits: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessBits'
            Visible = False
          end
          object GridProcessTableViewTreeProcessBitsName: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessBitsName'
            Visible = False
            Width = 75
          end
          object GridProcessTableViewTreeProcessName: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessName'
            SortIndex = 0
            SortOrder = soAscending
            Width = 302
          end
          object GridProcessTableViewTreeProcessPath: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessPath'
            Width = 348
          end
          object GridProcessTableViewTreeDescription: TcxGridDBColumn
            DataBinding.FieldName = 'Description'
            Visible = False
          end
          object GridProcessTableViewTreeCompanyName: TcxGridDBColumn
            DataBinding.FieldName = 'CompanyName'
            Visible = False
            Width = 12054
          end
          object GridProcessTableViewTreeLimitedAccess: TcxGridDBColumn
            DataBinding.FieldName = 'LimitedAccess'
            Visible = False
            Width = 130
          end
          object GridProcessTableViewTreeParentId: TcxGridDBColumn
            DataBinding.FieldName = 'ParentId'
            Visible = False
            GroupIndex = 0
          end
        end
        object GridProcessTableViewList: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = False
          Navigator.Buttons.PriorPage.Visible = False
          Navigator.Buttons.Prior.Visible = False
          Navigator.Buttons.Next.Visible = False
          Navigator.Buttons.NextPage.Visible = False
          Navigator.Buttons.Last.Visible = False
          Navigator.Buttons.Insert.Visible = False
          Navigator.Buttons.Append.Enabled = False
          Navigator.Buttons.Delete.Visible = False
          Navigator.Buttons.Edit.Visible = False
          Navigator.Buttons.Post.Visible = False
          Navigator.Buttons.Cancel.Visible = False
          Navigator.Buttons.Refresh.Visible = False
          Navigator.Buttons.SaveBookmark.Visible = False
          Navigator.Buttons.GotoBookmark.Visible = False
          Navigator.Buttons.Filter.Visible = False
          Navigator.InfoPanel.DisplayMask = '[RecordIndex] '#1080#1079' [RecordCount]'
          Navigator.InfoPanel.Visible = True
          Navigator.Visible = True
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dsProcess
          DataController.KeyFieldNames = 'ProcessID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.ScrollBars = ssNone
          OptionsView.GroupByBox = False
          object GridProcessTableViewListIcon: TcxGridDBColumn
            DataBinding.FieldName = 'Icon'
            PropertiesClassName = 'TcxImageProperties'
          end
          object GridProcessTableViewListProcessID: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessID'
            Width = 81
          end
          object GridProcessTableViewListProcessBits: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessBits'
            Visible = False
          end
          object GridProcessTableViewListProcessBitsName: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessBitsName'
            Visible = False
            Width = 95
          end
          object GridProcessTableViewListProcessName: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessName'
            Width = 320
          end
          object GridProcessTableViewListProcessPath: TcxGridDBColumn
            DataBinding.FieldName = 'ProcessPath'
            Width = 200
          end
          object GridProcessTableViewListDescription: TcxGridDBColumn
            DataBinding.FieldName = 'Description'
            Visible = False
          end
          object GridProcessTableViewListCompanyName: TcxGridDBColumn
            DataBinding.FieldName = 'CompanyName'
            Visible = False
          end
          object GridProcessTableViewListLimitedAccess: TcxGridDBColumn
            DataBinding.FieldName = 'LimitedAccess'
            Visible = False
            Width = 130
          end
          object GridProcessTableViewListParentId: TcxGridDBColumn
            DataBinding.FieldName = 'ParentId'
            Visible = False
          end
        end
        object GridProcessLevel: TcxGridLevel
          GridView = GridProcessTableViewTree
        end
      end
    end
    object tbsProcessTree: TcxTabSheet
      Caption = 'tbsProcessTree'
      ImageIndex = 1
      object TreeList: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 901
        Height = 485
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = dsProcess
        DataController.ParentField = 'ParentId'
        DataController.KeyField = 'ProcessID'
        Navigator.Buttons.CustomButtons = <>
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsData.SmartRefresh = True
        OptionsView.Indicator = True
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 0
        object TreeListIcon: TcxDBTreeListColumn
          DataBinding.FieldName = 'Icon'
          Width = 100
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListProcessID: TcxDBTreeListColumn
          DataBinding.FieldName = 'ProcessID'
          Width = 100
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          SortOrder = soAscending
          SortIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListProcessBits: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ProcessBits'
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListProcessBitsName: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ProcessBitsName'
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListProcessName: TcxDBTreeListColumn
          DataBinding.FieldName = 'ProcessName'
          Width = 166
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListProcessPath: TcxDBTreeListColumn
          DataBinding.FieldName = 'ProcessPath'
          Width = 361
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListDescription: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'Description'
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListCompanyName: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'CompanyName'
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListLimitedAccess: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'LimitedAccess'
          Position.ColIndex = 8
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListParentId: TcxDBTreeListColumn
          DataBinding.FieldName = 'ParentId'
          Position.ColIndex = 9
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListHash: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'Hash'
          Position.ColIndex = 10
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
  end
  object BarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.LargeImages = ImagesDataModule.ImageList32x32
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 160
    Top = 144
    PixelsPerInch = 96
    DockControlHeights = (
      46
      0
      0
      0)
    object bMenu: TdxBar
      Caption = 'Custom 1'
      CaptionButtons = <>
      DockedDockingStyle = dsLeft
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsLeft
      FloatLeft = 515
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'lbtnProcessViewTree'
        end
        item
          Visible = True
          ItemName = 'lbtnProcessProcessList'
        end>
      OneOnRow = True
      Row = 0
      ShowMark = False
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object lbtnProcessViewTree: TdxBarLargeButton
      Caption = 'ProcessViewTree'
      Category = 0
      Hint = 'ProcessViewTree'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      Down = True
      OnClick = lbtnProcessViewTreeClick
      LargeImageIndex = 0
      ShowCaption = False
    end
    object lbtnProcessProcessList: TdxBarLargeButton
      Caption = 'ProcessProcessList'
      Category = 0
      Hint = 'ProcessProcessList'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      OnClick = lbtnProcessProcessListClick
      LargeImageIndex = 1
      ShowCaption = False
    end
  end
  object tblProcess: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 112
    Top = 80
    object tblProcessProcessID: TIntegerField
      DisplayLabel = #1048#1044' '#1087#1088#1086#1094#1077#1089#1089#1072
      FieldName = 'ProcessID'
    end
    object tblProcessProcessBits: TSmallintField
      DisplayLabel = #1056#1072#1079#1088#1072#1076#1085#1086#1089#1090#1100' '#1095#1080#1089#1083#1086#1074#1086#1077
      FieldName = 'ProcessBits'
      Visible = False
    end
    object tblProcessProcessBitsName: TStringField
      DisplayLabel = #1056#1072#1079#1088#1072#1076#1085#1086#1089#1090#1100
      FieldName = 'ProcessBitsName'
    end
    object tblProcessProcessName: TStringField
      DisplayLabel = #1048#1084#1103' '#1087#1088#1086#1094#1077#1089#1089#1072
      FieldName = 'ProcessName'
      Size = 255
    end
    object tblProcessProcessPath: TStringField
      DisplayLabel = #1050#1086#1084#1072#1085#1076#1085#1072#1103' '#1089#1090#1088#1086#1082#1072
      FieldName = 'ProcessPath'
      FixedChar = True
      Size = 2048
    end
    object tblProcessDescription: TStringField
      DisplayLabel = #1054#1087#1080#1089#1072#1085#1080#1077
      FieldName = 'Description'
      Size = 2048
    end
    object tblProcessCompanyName: TStringField
      DisplayLabel = #1050#1086#1084#1087#1072#1085#1080#1080
      FieldName = 'CompanyName'
      Size = 2048
    end
    object tblProcessIcon: TGraphicField
      FieldName = 'Icon'
      BlobType = ftGraphic
    end
    object tblProcessLimitedAccess: TBooleanField
      DisplayLabel = #1054#1075#1088#1072#1085#1080#1095#1077#1085#1085#1099#1081' '#1076#1086#1089#1090#1091#1087
      FieldName = 'LimitedAccess'
    end
    object tblProcessParentId: TIntegerField
      DisplayLabel = #1056#1086#1076#1080#1090#1077#1083#1100
      FieldName = 'ParentId'
    end
    object tblProcessHash: TIntegerField
      FieldName = 'Hash'
    end
  end
  object dsProcess: TDataSource
    DataSet = tblProcess
    Left = 192
    Top = 80
  end
end
