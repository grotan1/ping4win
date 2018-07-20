unit grg;

interface
  uses System.Inifiles, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask, BMDThread, System.DateUtils, ipwping,
  Vcl.ExtCtrls, System.ioutils,
  Vcl.Buttons, System.Win.Registry, System.Win.TaskbarCore,
  Vcl.Taskbar, System.Actions, Vcl.ActnList;

  function WriteINIstr(Filename,Section,key,Value:string):boolean;

implementation

function WriteINIstr(Filename,Section,Key,Value:string):boolean;

var
  IniFile: TIniFile;

begin
  Inifile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  try
    Inifile.WriteString(Section,Key,Value);
  except
    showmessage('Error writing to inifile');
  end;
end;

end.
