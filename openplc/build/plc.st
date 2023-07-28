TYPE
  LOGLEVEL : (CRITICAL, WARNING, INFO, DEBUG) := INFO;
END_TYPE

FUNCTION_BLOCK LOGGER
  VAR_INPUT
    TRIG : BOOL;
    MSG : STRING;
    LEVEL : LOGLEVEL := INFO;
  END_VAR
  VAR
    TRIG0 : BOOL;
  END_VAR

  IF TRIG AND NOT TRIG0 THEN
  {{
   LogMessage(GetFbVar(LEVEL),(char*)GetFbVar(MSG, .body),GetFbVar(MSG, .len));
  }}
  END_IF;
  TRIG0:=TRIG;
END_FUNCTION_BLOCK



FUNCTION_BLOCK python_eval
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(0, data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_poll
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(1,(PYTHON_EVAL*)(void*)data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_gear
  VAR_INPUT
    N : UINT;
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    py_eval : python_eval;
    COUNTER : UINT;
    _TMP_ADD10_OUT : UINT;
    _TMP_EQ13_OUT : BOOL;
    _TMP_SEL15_OUT : UINT;
    _TMP_AND7_OUT : BOOL;
  END_VAR

  _TMP_ADD10_OUT := ADD(COUNTER, 1);
  _TMP_EQ13_OUT := EQ(N, _TMP_ADD10_OUT);
  _TMP_SEL15_OUT := SEL(_TMP_EQ13_OUT, _TMP_ADD10_OUT, 0);
  COUNTER := _TMP_SEL15_OUT;
  _TMP_AND7_OUT := AND(_TMP_EQ13_OUT, TRIG);
  py_eval(TRIG := _TMP_AND7_OUT, CODE := CODE);
  ACK := py_eval.ACK;
  RESULT := py_eval.RESULT;
END_FUNCTION_BLOCK


PROGRAM program0
  VAR
    RUN_BUTTON : BOOL;
    STOP_BUTTON : BOOL;
    heat_BUTTON : BOOL;
    cooling_BUTTON : BOOL;
    system_out : BOOL;
    heat_out : BOOL;
    cooling_out : BOOL;
    ET_IN : INT;
    BT_IN : INT;
    AT_IN : INT;
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
