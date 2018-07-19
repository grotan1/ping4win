unit Main_p4w;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask, BMDThread, System.DateUtils, ipwping,
  Vcl.ExtCtrls, System.ioutils,
  Vcl.Buttons, System.Win.Registry, System.Win.TaskbarCore,
  Vcl.Taskbar, System.Actions, Vcl.ActnList, System.IniFiles,
  System.Hash, DCPcrypt2, DCPblockciphers, DCPrijndael, DCPrc4, DCPsha1,
  DCPsha256, DCPrc6, IdMessageClient, IdSMTPBase, IdSMTP, IdMessage,
  IdSASL, IdSASLCollection, IdUserPassProvider, IdSASLUserPass, IdSASLLogin,
  IdSSLOpenSSLHeaders, IdEMailAddress, System.Notification, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdBaseComponent;

type
  TMyObj = class
    procedure ipwPing1Error(Sender: TObject; ErrorCode: Integer; const Description: string);
    procedure ipwPing1Response(Sender: TObject; RequestId: Integer; const ResponseSource, ResponseStatus: string;
      ResponseTime: Integer);
  end;

type
  TMain = class(TForm)
    Thread1: TBMDThread;
    sLabel1: TLabel;
    PingIPEdit: TComboBox;
    sLabel2: TLabel;
    PingIntervalEdit: TEdit;
    sLabel3: TLabel;
    sLabel10: TLabel;
    PingOverEdit: TEdit;
    sLabel11: TLabel;
    sLabel4: TLabel;
    LogFileName: TEdit;
    PingWriteLoggCheck: TCheckBox;
    SendEdmailCheckBox: TCheckBox;
    PingStopBtn: TButton;
    PingBtn: TButton;
    PingListBox: TListBox;
    sLabel5: TLabel;
    StatusListBox: TListBox;
    sPanel2: TPanel;
    sLabel6: TLabel;
    sLabel7: TLabel;
    sLabel8: TLabel;
    sLabel9: TLabel;
    MaxPingLabel: TLabel;
    AveragePingLabel: TLabel;
    TimeOuTLabel: TLabel;
    ErrorsLabel: TLabel;
    OptionButton: TSpeedButton;
    sSpeedButton1: TSpeedButton;
    DelayEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    MailThread: TBMDThread;
    EmailonTimeoutCheck: TCheckBox;
    procedure PingBtnClick(Sender: TObject);
    procedure PingStopBtnClick(Sender: TObject);
    procedure Thread1Execute(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);
    Procedure Delay(MSecs: Cardinal);
    procedure PingListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StatusListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WriteLog(Filename: string; str: string; create: boolean);
    procedure sSpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OptionButtonClick(Sender: TObject);
    function EncryptString(str: string): string;
    function DecryptString(str: string): string;
    procedure SendEmail(Sender: TObject);
    procedure MailThreadExecute(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);
    procedure Thread1Terminate(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);
    procedure PingIPEditKeyPress(Sender: TObject; var Key: Char);
    procedure PingStopBtnKeyPress(Sender: TObject; var Key: Char);
    procedure DelayEditKeyPress(Sender: TObject; var Key: Char);
    procedure PingIntervalEditKeyPress(Sender: TObject; var Key: Char);
    procedure PingOverEditKeyPress(Sender: TObject; var Key: Char);
    procedure LogFileNameKeyPress(Sender: TObject; var Key: Char);
    procedure PingWriteLoggCheckKeyPress(Sender: TObject; var Key: Char);
    procedure SendEdmailCheckBoxKeyPress(Sender: TObject; var Key: Char);

  private
    Count, AvgCount, TimeOuts, Errors: Longint;
    ListBoxCount: Integer;
    Stopp: boolean;
    StatusUpdated: boolean;
    MaxPing: Integer;
    TotMS: Longint;
    IPAdr: string;
    Interval: Integer;
    // LogOver: Integer;
    Delays: Integer;

    { Private declarations }
  public
    ping1: TipwPing;
    bodyFooter: string;
    mailErrorStatus: string;
    sendMailFinished: boolean;
    mailMessage: string;
    mailSubject: string;
    TimeOut: boolean;
    { Public declarations }
  end;

var
  Main: TMain;
  // Roundtrip: Cardinal;
  // Roundtrip2: Cardinal;

implementation

{$R *.dfm}

uses Help_p4w, Options_p4w;

procedure TMyObj.ipwPing1Error(Sender: TObject; ErrorCode: Integer; const Description: string);
begin
  Main.StatusListBox.Items.Add('grg: ' + inttostr(ErrorCode) + ' ' + Description);

end;

procedure TMyObj.ipwPing1Response(Sender: TObject; RequestId: Integer; const ResponseSource, ResponseStatus: string;
  ResponseTime: Integer);

begin

  Main.PingListBox.Items.Add(inttostr(Main.Count) + ': Sending ' + inttostr(Main.ping1.PacketSize) + ' bytes to ' +
    Main.PingIPEdit.Text + '... Reply from ' + ResponseSource + ' Time: ' + inttostr(ResponseTime) + ' ms');

  if (Main.EmailonTimeoutCheck.Checked = true) AND (Main.TimeOut = true) AND (Main.MailThread.Runing = false) then
  begin
    Main.mailMessage := '<b>Host ' + Main.PingIPEdit.Text + ' up</b><br>' + DateTimeToStr(now) + ': Sending ' +
      inttostr(Main.ping1.PacketSize) + ' bytes to ' + Main.PingIPEdit.Text + '... Reply from ' + ResponseSource +
      ' Time: ' + inttostr(ResponseTime) + ' ms';
    Main.mailSubject := 'Ping4Win: ' + Main.PingIPEdit.Text + ' Up';

    Main.TimeOut := false;
    Main.MailThread.Start;
  end;

  Main.TotMS := Main.TotMS + ResponseTime;
  // Average := TotMS div Main.Count;
  inc(Main.AvgCount);
  Main.AveragePingLabel.Caption := inttostr(Main.TotMS div Main.AvgCount) + ' ms';

  if Main.MaxPing < ResponseTime then
  begin
    Main.MaxPing := ResponseTime;
    Main.MaxPingLabel.Caption := inttostr(Main.MaxPing) + ' ms';
  end;

  if (ResponseTime > StrToInt(Main.PingOverEdit.Text)) AND (StrToInt(Main.PingOverEdit.Text) > 0) then
    Main.StatusUpdated := true;

  if Main.StatusUpdated = true then
  begin
    Main.StatusListBox.Items.Add(DateTimeToStr(now) + ': Sending ' + inttostr(Main.ping1.PacketSize) + ' bytes to ' +
      Main.IPAdr + '... Reply from ' + ResponseSource + ' Time: ' + inttostr(ResponseTime) + ' ms');

    if Main.PingWriteLoggCheck.Checked then
      Main.WriteLog(Main.LogFileName.Text, DateTimeToStr(now) + ': Sending ' + inttostr(Main.ping1.PacketSize) +
        ' bytes to ' + Main.IPAdr + '... Reply from ' + ResponseSource + ' Time: ' + inttostr(ResponseTime) +
        ' ms', false);

    Main.StatusUpdated := false;
  end;

end;

procedure TMain.Thread1Execute(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);

var
  MyObj: TMyObj;
  LastMessage: String;
  Filename: string;

begin
  TimeOut := false;
  StatusUpdated := true;
  MyObj := TMyObj.create;

  ping1 := TipwPing.create(nil);
  ping1.Config('AbsoluteTimeout=true');
  ping1.Config('TimeoutInMilliseconds=true');
  ping1.TimeOut := 1000;
  ping1.PacketSize := 32;
  ping1.OnResponse := MyObj.ipwPing1Response;
  ping1.OnError := MyObj.ipwPing1Error;
  if LogFileName.Text = '' then
    LogFileName.Text := 'Ping4Win.log';
  Filename := ExtractFileName(LogFileName.Text);
  if not System.ioutils.TPath.HasValidFileNameChars(Filename, false) then
    LogFileName.Text := 'Ping4Win.log';
  if Main.PingWriteLoggCheck.Checked then
    WriteLog(LogFileName.Text, '', true);

  while not Stopp do
  begin
    try
      ping1.PingHost(IPAdr);
    except
      on e: Exception do
      begin

        if AnsiContainsText(e.Message, '301') then
        begin
          inc(TimeOuts);
          TimeOuTLabel.Caption := inttostr(TimeOuts);
        end
        else
          inc(Errors);

        if (Main.EmailonTimeoutCheck.Checked = true) AND (TimeOut = false) AND (Main.MailThread.Runing = false) then
        begin
          TimeOut := true;
          Main.mailMessage := '<b>Host ' + Main.PingIPEdit.Text + ' down</b><br>' + DateTimeToStr(now) + ': ' +
            e.Message;
          Main.mailSubject := 'Ping4Win: ' + Main.PingIPEdit.Text + ' Down';
          Main.MailThread.Start;
        end;

        Main.ErrorsLabel.Caption := inttostr(Errors);
        PingListBox.Items.Add(inttostr(Count) + ': ' + e.Message);

        if (StatusUpdated = false) or (e.Message <> LastMessage) then
        begin
          StatusListBox.Items.Add(DateTimeToStr(now) + ': ' + e.Message);

          if Main.PingWriteLoggCheck.Checked then
            WriteLog(LogFileName.Text, DateTimeToStr(now) + ': ' + e.Message, false);
          StatusUpdated := true;
        end;
        LastMessage := e.Message;

      end;
    end;

    Sleep(Delays);
    inc(ListBoxCount);

    if ListBoxCount = 10 then
    begin
      PingListBox.Items.Clear;
      ListBoxCount := 0;
    end;

    if (Count = Interval) AND (Interval > 0) then
      Stopp := true;

    inc(Count);
  end;

  MyObj.Free;
  ping1.Free;
end;

procedure TMain.Thread1Terminate(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);
begin
  StatusListBox.Items.Add(DateTimeToStr(now) + ' Ping ended...');
  if SendEdmailCheckBox.Checked then
    SendEmail(self);

end;

procedure TMain.WriteLog(Filename: string; str: string; create: boolean);

var
  LogFile: TextFile;

begin
  try
    begin
      AssignFile(LogFile, LogFileName.Text);
      if create = true then
        rewrite(LogFile)
      else
      begin
        Append(LogFile);
        writeln(LogFile, str);
      end;
    end;
  finally
    CloseFile(LogFile);
  end;

end;

Procedure TMain.Delay(MSecs: Cardinal);
var
  FirstTick, CurrentTick: Cardinal;
  Done: boolean;

begin
  Done := false;
  FirstTick := GetTickCount;
  While Not Done do
  begin
    Application.ProcessMessages;
    Done := Stopp;

    CurrentTick := GetTickCount;
    If Int64(CurrentTick) - Int64(FirstTick) < 0 Then
    begin
      If CurrentTick >= (Int64(FirstTick) - High(Cardinal) + MSecs) Then
        Done := true;
    End
    Else If CurrentTick - FirstTick >= MSecs Then
      Done := true;
  end;
end;

procedure TMain.DelayEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PingIntervalEdit.SetFocus;
    Key := #0;
  end;

end;

function TMain.EncryptString(str: string): string;

var
  Cipher: TDCP_rijndael;
  KeyStr: string;

begin
  KeyStr := '[ÃSV‹ò‹Ø‹Ö‹Ãè½ÿÿÿ';
  Cipher := TDCP_rijndael.create(self);

  Cipher.InitStr(KeyStr, TDCP_sha1);
  // initialize the cipher with a hash of the passphrase
  KeyStr := '';
  result := Cipher.EncryptString(str);
  Cipher.Burn;
  Cipher.Free;
end;

function TMain.DecryptString(str: string): string;

var
  Cipher: TDCP_rijndael;
  KeyStr: string;

begin
  KeyStr := '[ÃSV‹ò‹Ø‹Ö‹Ãè½ÿÿÿ';
  Cipher := TDCP_rijndael.create(self);
  Cipher.InitStr(KeyStr, TDCP_sha1);
  // initialize the cipher with a hash of the passphrase
  KeyStr := '';
  result := Cipher.DecryptString(str);
  Cipher.Burn;
  Cipher.Free;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);

var
  appINI: TIniFile;
  section: string;

begin
  Stopp := true;
  Thread1.Stop;

  appINI := TIniFile.create(ChangeFileExt(Application.ExeName, '.ini'));
  section := 'General_Options';
  try
    appINI.WriteString(section, 'Delay', DelayEdit.Text);
    appINI.WriteString(section, 'Interval', PingIntervalEdit.Text);
    appINI.WriteString(section, 'LogAllOver', PingOverEdit.Text);
    appINI.WriteString(section, 'LogFileName', LogFileName.Text);
    appINI.WriteBool(section, 'WriteToLogfile', PingWriteLoggCheck.Checked);
    appINI.WriteBool(section, 'SendEmail', SendEdmailCheckBox.Checked);
    appINI.WriteBool(section, 'WriteLog', PingWriteLoggCheck.Checked);
    appINI.WriteBool(section, 'SendUpDown', EmailonTimeoutCheck.Checked);;
  finally
    appINI.Free;
  end;

end;

procedure TMain.FormShow(Sender: TObject);

var
  ip: string;

  appINI: TIniFile;
  section: string;
  MemoStream: TMemoryStream;

begin
  bodyFooter := '<br><br><br><br><br><br><br><p>Ping4Win &copy 2015 Geir Rune Grøtan<br>http://www.klingsundet.no</p>';
  sendMailFinished := true;
  // Read INI
  appINI := TIniFile.create(ChangeFileExt(Application.ExeName, '.ini'));
  section := 'Email_Options';
  try
    OptionsForm.FromEdit.Text := appINI.ReadString(section, 'FromAddress', '');
    OptionsForm.ToEdit.Text := appINI.ReadString(section, 'RecipientAddress', '');
    OptionsForm.SMTPEdit.Text := appINI.ReadString(section, 'SMTPServer', '');
    OptionsForm.PortEdit.Text := appINI.ReadString(section, 'Port', '587');
    OptionsForm.TLSCheck.Checked := appINI.ReadBool(section, 'UseTLS', true);
    OptionsForm.AuthenticationCheck.Checked := appINI.ReadBool(section, 'UseAuth', true);
    OptionsForm.UsernameEdit.Text := appINI.ReadString(section, 'Username', '');
    OptionsForm.PasswordEdit.Text := DecryptString(appINI.ReadString(section, 'Password', ''));

    section := 'General_Options';
    SendEdmailCheckBox.Checked := appINI.ReadBool(section, 'SendEmail', false);
    PingWriteLoggCheck.Checked := appINI.ReadBool(section, 'WriteLog', false);
    EmailonTimeoutCheck.Checked := appINI.ReadBool(section, 'SendUpDown', false);
    MemoStream := TMemoryStream.create;
    try
      appINI.ReadBinaryStream(section, 'IP_Items', MemoStream);
      MemoStream.Position := 0;
      PingIPEdit.Items.LoadFromStream(MemoStream);
      PingIPEdit.ItemIndex := 0;
    finally
      MemoStream.Free;
    end;

  finally
    appINI.Free;
  end;
  if FindCmdLineSwitch('ip', ip, true, [clstValueAppended, clstValueNextParam]) then
  begin
    if PingIPEdit.Items.IndexOf(ip) < 0 then
    begin
      PingIPEdit.Items.Add(ip);
      PingIPEdit.ItemIndex := PingIPEdit.Items.IndexOf(ip);
    end
    else
      PingIPEdit.ItemIndex := PingIPEdit.Items.IndexOf(ip)
  end;

  if FindCmdLineSwitch('log', ip, true, [clstValueAppended, clstValueNextParam]) then
  begin
    LogFileName.Text := ip;
    PingWriteLoggCheck.Checked := true;
  end;

  if FindCmdLineSwitch('autostart', ['/'], true) then
  begin
    PostMessage(PingBtn.Handle, WM_LBUTTONDOWN, 0, 0);
    PostMessage(PingBtn.Handle, WM_LBUTTONUP, 0, 0);
  end;
end;

procedure TMain.LogFileNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PingWriteLoggCheck.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.MailThreadExecute(Sender: TObject; Thread: TBMDExecuteThread; var Data: Pointer);
var
  IdSASLLogin: TIdSASLLogin;
  IdUserPassProvider: TIdUserPassProvider;
  IdEmailAddressItem: TIdEmailAddressItem;
  X: Integer;

begin
  // Memo1.Lines.Clear;
  IdSMTP1.Disconnect;
  try
    if OptionsForm.TLSCheck.Checked then
      IdSMTP1.UseTLS := utUseRequireTLS
    else
      IdSMTP1.UseTLS := utNoTLSSupport;

    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvSSLv3;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmUnassigned;
    IdSMTP1.Host := OptionsForm.SMTPEdit.Text;
    IdSMTP1.Port := StrToInt(OptionsForm.PortEdit.Text);

    IdSASLLogin := TIdSASLLogin.create(IdSMTP1);
    IdUserPassProvider := TIdUserPassProvider.create(IdSASLLogin);

    IdSASLLogin.UserPassProvider := IdUserPassProvider;
    IdUserPassProvider.Username := OptionsForm.UsernameEdit.Text;
    IdUserPassProvider.Password := OptionsForm.PasswordEdit.Text;

    if OptionsForm.AuthenticationCheck.Checked then
      IdSMTP1.AuthType := satSASL
    else
      IdSMTP1.AuthType := satNone;

    IdSMTP1.SASLMechanisms.Add.SASL := IdSASLLogin;

    try
      IdSMTP1.Connect;
      try
        IdSMTP1.Authenticate;
        if IdSMTP1.Authenticate then
        begin
          try
            IdMessage1.From.Name := 'Ping4win';
            IdMessage1.From.Address := OptionsForm.FromEdit.Text;
            IdMessage1.Subject := Main.mailSubject;
            IdMessage1.Body.Add(mailMessage);
            IdMessage1.Body.Add(bodyFooter);
            IdEmailAddressItem := IdMessage1.Recipients.Add;
            IdEmailAddressItem.Address := OptionsForm.ToEdit.Text;
            IdMessage1.ContentType := 'Text/HTML';
            IdMessage1.CharSet := 'UTF-8';
            IdSMTP1.Send(IdMessage1);
          finally
            IdMessage1.Clear;
          end;
        end;
      finally
        IdSMTP1.Disconnect;
      end;
      // ShowMessage('Connection to mailserver OK');
    except
      on e: Exception do
      begin
        // ShowMessage(Format('Failed!'#13'[%s] %s', [E.ClassName, E.Message]));
        // raise;
      end;
    end;
  finally
    IdUserPassProvider.Free;
    // idSMTP1.Free;
  end;

end;

procedure TMain.PingBtnClick(Sender: TObject);

var
  str: Tstrings;
  currentIP: string;
  appINI: TIniFile;
  section: string;
  MemoStream: TStream;

begin

  try
    begin
      str := TStringlist.create;
      str.Text := PingIPEdit.Items.Text;
      currentIP := PingIPEdit.Text;
      if str.IndexOf(currentIP) < 0 then
      begin
        str.Insert(0, currentIP);
        if str.Count > 8 then
          str.Delete(8);
      end;
    end
  finally
    PingIPEdit.Items := str;
    str.Free;
  end;

  appINI := TIniFile.create(ChangeFileExt(Application.ExeName, '.ini'));
  section := 'General_Options';
  try
    MemoStream := TMemoryStream.create;
    try
      PingIPEdit.Items.SaveToStream(MemoStream);
      MemoStream.Position := 0;
      appINI.WriteBinaryStream(section, 'IP_Items', MemoStream);
    finally
      MemoStream.Free;
    end;
  finally
    appINI.Free;
  end;

  Errors := 0;
  TotMS := 0;
  AvgCount := 1;
  Count := 1;
  TimeOuts := 0;
  MaxPing := 0;
  ListBoxCount := 0;
  PingListBox.Items.Clear;
  StatusListBox.Items.Clear;
  Stopp := false;
  TimeOuTLabel.Caption := '0';
  Main.ErrorsLabel.Caption := '0';
  MaxPingLabel.Caption := '0 ms';
  if StrToInt(DelayEdit.Text) < 1000 then
    DelayEdit.Text := '1000';
  Delays := StrToInt(DelayEdit.Text);

  IPAdr := PingIPEdit.Text;
  Interval := StrToInt(PingIntervalEdit.Text);
  Thread1.Start;
  PingStopBtn.SetFocus;

end;

procedure TMain.PingIntervalEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PingOverEdit.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.PingIPEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    DelayEdit.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.PingListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PingListBox.Selected[PingListBox.ItemIndex] := false;
end;

procedure TMain.PingOverEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    LogFileName.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.PingStopBtnClick(Sender: TObject);
begin
  Stopp := true;
  Thread1.Stop;
  PingIPEdit.SetFocus;
end;

procedure TMain.PingStopBtnKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
  end;
end;

procedure TMain.PingWriteLoggCheckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    SendEdmailCheckBox.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.SendEdmailCheckBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PingBtn.SetFocus;
    Key := #0;
  end;

end;

procedure TMain.SendEmail(Sender: TObject);
var
  IdSASLLogin: TIdSASLLogin;
  IdUserPassProvider: TIdUserPassProvider;
  IdEmailAddressItem: TIdEmailAddressItem;
  X: Integer;

begin
  // Memo1.Lines.Clear;
  IdSMTP1.Disconnect;
  try
    if OptionsForm.TLSCheck.Checked then
      IdSMTP1.UseTLS := utUseRequireTLS
    else
      IdSMTP1.UseTLS := utNoTLSSupport;

    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvSSLv3;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmUnassigned;
    IdSMTP1.Host := OptionsForm.SMTPEdit.Text;
    IdSMTP1.Port := StrToInt(OptionsForm.PortEdit.Text);

    IdSASLLogin := TIdSASLLogin.create(IdSMTP1);
    IdUserPassProvider := TIdUserPassProvider.create(IdSASLLogin);

    IdSASLLogin.UserPassProvider := IdUserPassProvider;
    IdUserPassProvider.Username := OptionsForm.UsernameEdit.Text;
    IdUserPassProvider.Password := OptionsForm.PasswordEdit.Text;

    if OptionsForm.AuthenticationCheck.Checked then
      IdSMTP1.AuthType := satSASL
    else
      IdSMTP1.AuthType := satNone;

    IdSMTP1.SASLMechanisms.Add.SASL := IdSASLLogin;

    try
      IdSMTP1.Connect;
      try
        IdSMTP1.Authenticate;
        if IdSMTP1.Authenticate then
        begin
          try
            IdMessage1.From.Name := 'Ping4win';
            IdMessage1.From.Address := OptionsForm.FromEdit.Text;
            IdMessage1.Subject := 'Ping4Win: ' + Main.PingIPEdit.Text;

            for X := 0 to StatusListBox.Count - 1 do
            begin
              IdMessage1.Body.Add(StatusListBox.Items.Strings[X] + '</br>');
            end;

            IdMessage1.Body.Add('-----------------------------------------');
            IdMessage1.Body.Add('<br>Max Ping: ' + MaxPingLabel.Caption);
            IdMessage1.Body.Add('<br>Average Ping: ' + AveragePingLabel.Caption);
            IdMessage1.Body.Add('<br>Timeouts: ' + TimeOuTLabel.Caption);
            IdMessage1.Body.Add('<br>Errors: ' + ErrorsLabel.Caption);

            IdMessage1.Body.Add(bodyFooter);
            IdEmailAddressItem := IdMessage1.Recipients.Add;
            IdEmailAddressItem.Address := OptionsForm.ToEdit.Text;
            IdMessage1.ContentType := 'Text/HTML';
            IdMessage1.CharSet := 'UTF-8';
            IdSMTP1.Send(IdMessage1);
          finally
            IdMessage1.Clear;
          end;
        end;
      finally
        IdSMTP1.Disconnect;
      end;
      // ShowMessage('Connection to mailserver OK');
    except
      on e: Exception do
      begin
        // ShowMessage(Format('Failed!'#13'[%s] %s', [E.ClassName, E.Message]));
        // raise;
      end;
    end;
  finally
    IdUserPassProvider.Free;
    // idSMTP1.Free;
  end;

end;

procedure TMain.OptionButtonClick(Sender: TObject);

var
  appINI: TIniFile;
  section: string;
  // MemoStream: TMemoryStream;

begin

  if OptionsForm.ShowModal = mrOK then
  begin
    appINI := TIniFile.create(ChangeFileExt(Application.ExeName, '.ini'));
    section := 'Email_Options';
    try
      appINI.WriteString(section, 'FromAddress', OptionsForm.FromEdit.Text);
      appINI.WriteString(section, 'RecipientAddress', OptionsForm.ToEdit.Text);
      appINI.WriteString(section, 'SMTPServer', OptionsForm.SMTPEdit.Text);
      appINI.WriteString(section, 'Port', OptionsForm.PortEdit.Text);
      appINI.WriteBool(section, 'UseTLS', OptionsForm.TLSCheck.Checked);
      appINI.WriteBool(section, 'UseAuth', OptionsForm.AuthenticationCheck.Checked);
      appINI.WriteString(section, 'Username', OptionsForm.UsernameEdit.Text);
      appINI.WriteString(section, 'Password', EncryptString(OptionsForm.PasswordEdit.Text));
      { appINI.WriteString(Section, 'Subject', OptionsForm.SubjectEdit.Text);

        MemoStream := TMemoryStream.Create;
        try
        OptionsForm.BodyEdit.Lines.SaveToStream(MemoStream);
        MemoStream.Position := 0;
        appINI.WriteBinaryStream(Section, 'Body', MemoStream);
        finally
        MemoStream.Free;
        end; }

    finally
      appINI.Free;
    end;
  end;
end;

procedure TMain.sSpeedButton1Click(Sender: TObject);
begin
  HelpForm.ShowModal;
end;

procedure TMain.StatusListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StatusListBox.Selected[StatusListBox.ItemIndex] := false;
end;

end.
