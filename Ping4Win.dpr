program Ping4Win;

uses
  Vcl.Forms,
  Main_p4w in 'Main_p4w.pas' {Main} ,
  Help_p4w in 'Help_p4w.pas' {HelpForm} ,
  Vcl.Themes,
  Vcl.Styles,
  Options_p4w in 'Options_p4w.pas' {OptionsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.Run;

end.
