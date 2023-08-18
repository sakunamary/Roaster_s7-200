PROGRAM get_temp
  VAR
    I2C_AHT200 : I2C_AHT20;
    sck : INT := 5;
    sda : INT := 4;
    temp : REAL;
    RH0 : REAL;
  END_VAR

  I2C_AHT200(EN := TRUE, SCK_PIN := sck, SDA_PIN := sda);
  IF I2C_AHT200.ENO THEN
      temp := I2C_AHT200.TEMP;
  END_IF;
  IF I2C_AHT200.ENO THEN
      RH0 := I2C_AHT200.RH;
  END_IF;
END_PROGRAM

PROGRAM main
  VAR
    in AT %IX0.2 : BOOL;
    out AT %QX0.2 : BOOL;
  END_VAR

  out := in;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    TASK task1(INTERVAL := T#1000ms,PRIORITY := 1);
    PROGRAM instance0 WITH task0 : main;
    PROGRAM instance1 WITH task1 : get_temp;
  END_RESOURCE
END_CONFIGURATION
