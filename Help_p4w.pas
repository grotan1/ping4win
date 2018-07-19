unit Help_p4w;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, shellapi,
  Vcl.ComCtrls, Vcl.Menus, Vcl.ExtCtrls;

type
  THelpForm = class(TForm)
    sPanel1: TPanel;
    sButton1: TButton;
    sLabel4: TLabel;
    sLabel3: TLabel;
    sRichEdit1: TRichEdit;
    sLabel2: TLabel;
    sLabel1: TLabel;
    procedure sLabel4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;

implementation

{$R *.dfm}
{$R Help.RES}

procedure THelpForm.FormShow(Sender: TObject);
var
  str: TResourceStream;

begin
  str := TResourceStream.Create(hInstance, PChar('appInfo'), RT_RCDATA);
  try
    str.Position := 0;
    sRichEdit1.Lines.LoadFromStream(str);
  finally
    str.Free;
  end;

end;

procedure THelpForm.sLabel4Click(Sender: TObject);
begin
  ShellExecute(Self.Handle, nil, 'http://' + 'klingsundet.no', nil, nil, SW_NORMAL);
end;

end.
