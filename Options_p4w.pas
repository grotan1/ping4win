unit Options_p4w;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ipwcore,
  ipwhtmlmailer, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, IdMessage,
  IdSASL, IdSASLCollection, IdUserPassProvider, IdSASLUserPass, IdSASLLogin,
  IdSSLOpenSSLHeaders, IdEMailAddress, System.Notification;

type
  TOptionsForm = class(TForm)
    FromEdit: TLabeledEdit;
    ToEdit: TLabeledEdit;
    SMTPEdit: TLabeledEdit;
    Button1: TButton;
    AuthenticationCheck: TCheckBox;
    UsernameEdit: TLabeledEdit;
    PasswordEdit: TLabeledEdit;
    TLSCheck: TCheckBox;
    TestButton: TButton;
    Memo1: TMemo;
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    PortEdit: TLabeledEdit;
    Label1: TLabel;
    IdMessage1: TIdMessage;
    NotificationCenter1: TNotificationCenter;
    Button2: TButton;
    procedure TestButtonClick(Sender: TObject);
    procedure smtp1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdSMTP1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdSSLIOHandlerSocketOpenSSL1StatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
      const AWhere, Aret: Integer; const AType, AMsg: string);
    procedure IdSSLIOHandlerSocketOpenSSL1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdSSLIOHandlerSocketOpenSSL1StatusInfo(const AMsg: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.dfm}

uses Main_p4w;

procedure TOptionsForm.IdSMTP1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(AStatusText);
end;

procedure TOptionsForm.IdSSLIOHandlerSocketOpenSSL1Status(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  Memo1.Lines.Add(AStatusText);
end;

procedure TOptionsForm.IdSSLIOHandlerSocketOpenSSL1StatusInfo(const AMsg: string);
begin
  Memo1.Lines.Add(AMsg);
end;

procedure TOptionsForm.IdSSLIOHandlerSocketOpenSSL1StatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, Aret: Integer; const AType, AMsg: string);
begin
  // Memo1.Lines.Add(AMsg);
  // Memo1.Lines.Add(AType);
end;

procedure TOptionsForm.smtp1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(AStatusText);
end;

procedure TOptionsForm.TestButtonClick(Sender: TObject);

var
  IdSASLLogin: TIdSASLLogin;
  IdUserPassProvider: TIdUserPassProvider;
  IdEmailAddressItem: TIdEmailAddressItem;

begin
  Memo1.Lines.Clear;
  Memo1.Repaint;
  IdSMTP1.Disconnect;
  try
    if TLSCheck.Checked then
      IdSMTP1.UseTLS := utUseRequireTLS
    else
      IdSMTP1.UseTLS := utNoTLSSupport;

    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1_2;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmUnassigned;
    IdSMTP1.Host := SMTPEdit.text;
    IdSMTP1.Port := StrToInt(PortEdit.text);

    IdSASLLogin := TIdSASLLogin.Create(IdSMTP1);
    IdUserPassProvider := TIdUserPassProvider.Create(IdSASLLogin);

    IdSASLLogin.UserPassProvider := IdUserPassProvider;
    IdUserPassProvider.Username := UsernameEdit.text;
    IdUserPassProvider.Password := PasswordEdit.text;

    if AuthenticationCheck.Checked then
      IdSMTP1.AuthType := satSASL
    else
      IdSMTP1.AuthType := satNone;

    IdSMTP1.SASLMechanisms.Add.SASL := IdSASLLogin;
    IdSMTP1.ConnectTimeout := 5000;
    IdSMTP1.ReadTimeout := 5000;

    try
      IdSMTP1.Connect;
      try
        IdSMTP1.Authenticate;
        if IdSMTP1.Authenticate then
        begin
          try
            IdMessage1.From.Name := 'Ping4win';
            IdMessage1.From.Address := FromEdit.text;
            IdMessage1.Subject := 'Ping4Win: Testmail'; // + main.PingIPEdit.Text;
            // IdMessage1.Body := BodyEdit.Lines;
            IdMessage1.Body.Add(main.bodyFooter);
            IdEmailAddressItem := IdMessage1.Recipients.Add;
            IdEmailAddressItem.Address := ToEdit.text;

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
      ShowMessage('Connection to mailserver OK');
    except
      on E: Exception do
      begin
        // ShowMessage(Format('Failed!'#13'[%s] %s', [E.ClassName, E.Message]));
        raise;
      end;
    end;
  finally
    IdUserPassProvider.Free;
    // idSMTP1.Free;
  end;
end;

end.
