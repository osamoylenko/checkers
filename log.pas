unit log;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, StdCtrls;

type
  p_TMemo = ^TMemo;

  procedure log_output(s : string);
  procedure set_memo(lm : p_TMemo);


implementation
  var
    log_memo:^TMemo;

  procedure log_output(s : string);
  begin
    log_memo^.lines.Add(s);
  end;

  procedure set_memo(lm : p_TMemo);
  begin
     log_memo := lm;
  end;
end.

