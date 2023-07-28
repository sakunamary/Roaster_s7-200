PROGRAM program0
  VAR
    RUN_BUTTON AT %IX0.1 : BOOL;
    STOP_BUTTON AT %IX0.2 : BOOL;
    heat_BUTTON AT %IX0.3 : BOOL;
    cooling_BUTTON AT %IX0.4 : BOOL;
    system_out AT %QX0.3 : BOOL;
    heat_out AT %QX0.4 : BOOL;
    cooling_out AT %QX0.7 : BOOL;
    ET_IN AT %IW0 : INT;
    BT_IN AT %IW1 : INT;
    AT_IN AT %IW2 : INT;
  END_VAR
  VAR
    TON0 : TON;
    artisan_bt : INT;
    artisan_et : INT;
    artisan_at : INT;
    sys_run : BOOL;
    stop_status : BOOL;
    cool_run : BOOL;
    heat_run : BOOL;
    RUN_STATUS : BOOL;
    R_TRIG1 : R_TRIG;
    R_TRIG2 : R_TRIG;
    F_TRIG1 : F_TRIG;
    R_TRIG3 : R_TRIG;
    R_TRIG4 : R_TRIG;
    F_TRIG2 : F_TRIG;
    R_TRIG5 : R_TRIG;
    R_TRIG6 : R_TRIG;
    F_TRIG3 : F_TRIG;
  END_VAR

  stop_status := STOP_BUTTON;
  R_TRIG1(CLK := RUN_BUTTON);
  sys_run := NOT(stop_status) AND RUN_STATUS AND R_TRIG1.Q;
  R_TRIG2(CLK := RUN_BUTTON);
  RUN_STATUS := NOT(sys_run) AND (NOT(stop_status) AND RUN_STATUS OR NOT(stop_status) AND R_TRIG2.Q);
  F_TRIG1(CLK := RUN_BUTTON);
  IF F_TRIG1.Q THEN
    sys_run := FALSE; (*reset*)
  END_IF;
  TON0(IN := RUN_STATUS, PT := t#2000ms);
  system_out := TON0.Q;
  R_TRIG3(CLK := cooling_BUTTON);
  cool_run := cooling_out AND R_TRIG3.Q AND NOT(stop_status) AND RUN_STATUS;
  R_TRIG4(CLK := cooling_BUTTON);
  cooling_out := NOT(cool_run) AND (NOT(stop_status) AND cooling_out AND NOT(stop_status) AND RUN_STATUS OR NOT(stop_status) AND R_TRIG4.Q AND NOT(stop_status) AND RUN_STATUS);
  F_TRIG2(CLK := cooling_BUTTON);
  IF F_TRIG2.Q AND NOT(stop_status) AND RUN_STATUS THEN
    cool_run := FALSE; (*reset*)
  END_IF;
  R_TRIG5(CLK := heat_BUTTON);
  heat_run := heat_out AND R_TRIG5.Q AND NOT(stop_status) AND RUN_STATUS;
  R_TRIG6(CLK := heat_BUTTON);
  heat_out := NOT(heat_run) AND (NOT(stop_status) AND heat_out AND NOT(stop_status) AND RUN_STATUS OR NOT(stop_status) AND R_TRIG6.Q AND NOT(stop_status) AND RUN_STATUS);
  F_TRIG3(CLK := heat_BUTTON);
  IF F_TRIG3.Q AND NOT(stop_status) AND RUN_STATUS THEN
    heat_run := FALSE; (*reset*)
  END_IF;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : program0;
  END_RESOURCE
END_CONFIGURATION
