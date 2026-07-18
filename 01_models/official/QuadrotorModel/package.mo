package QuadrotorModel "四旋翼无人机模型"
  extends Modelica.Icons.Package;
  annotation(uses(Modelica(version = "4.0.0.TY.1")));
  package Examples "示例模型库"
    extends Modelica.Icons.Example;
    extends Modelica.Icons.ExamplesPackage;
    model Example1 "阶梯爬升运动"

      PathPlanning.ClimbPath climbePath(gain(k = 1)) 
        annotation (Placement(transformation(origin = {-150.0, 24.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      annotation (Diagram(coordinateSystem(extent = {{-200.0, -100.0}, {200.0, 100.0}},
        grid = {2.0, 2.0})),
        Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          preserveAspectRatio = false,
          grid = {2.0, 2.0})),
        experiment(Algorithm = Dassl, StartTime = 0, StopTime = 50, Tolerance = 0.0001, Interval = 0.01));
      Mechanics.QuadChassis quadChassisTest17_1(lift_cofficient=0.002) annotation (Placement(transformation(origin = {86.00000000000001, 8.499999999999986},
        extent = {{-34.0, -33.99999999999999}, {34.0, 34.00000000000001}})));
      Electricals.Actuator actuator1_1 
        annotation (Placement(transformation(origin = {2.0, 46.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_2 
        annotation (Placement(transformation(origin = {2.0, 22.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_3 
        annotation (Placement(transformation(origin = {2.0, -3.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_4 
        annotation (Placement(transformation(origin = {2.0, -29.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));


      extends Modelica.Icons.Example;
      Sensors.Sensors sensors1_1 
        annotation (Placement(transformation(origin = {2.0000000000000018, -64.5},
          extent = {{21.0, -19.0}, {-21.0, 19.0}})));
      Blocks.Controller.Controller controller3_2 
        annotation (Placement(transformation(origin = {-70.99999999999999, 9.0},
          extent = {{-25.000000000000014, -25.0}, {25.0, 25.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4] annotation (Placement(transformation(origin = {80.0, 66.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}})));
    equation
      connect(actuator1_1.flange_a, quadChassisTest17_1.flange_a) 
        annotation (Line(origin = {27.0, 30.5},
          points = {{-15.0, 16.0}, {3.0, 16.0}, {3.0, -2.0}, {25.0, -2.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_2.flange_a, quadChassisTest17_1.flange_a1) 
        annotation (Line(origin = {27.0, 14.5},
          points = {{-15.0, 8.0}, {3.0, 8.0}, {3.0, 2.0}, {25.0, 2.0}, {25.0, 1.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_3.flange_a, quadChassisTest17_1.flange_a2) 
        annotation (Line(origin = {27.0, 0.5},
          points = {{-15.0, -4.0}, {3.0, -4.0}, {3.0, 1.0}, {25.0, 1.0}},
          color = {0, 0, 0},
          thickness = 1.0));
      connect(actuator1_4.flange_a, quadChassisTest17_1.flange_a3) 
        annotation (Line(origin = {27.0, -13.5},
          points = {{-15.0, -16.0}, {3.0, -16.0}, {3.0, 2.0}, {25.0, 2.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(quadChassisTest17_1.frame_a, sensors1_1.frame_a) 
        annotation (Line(origin = {16.0, -30.5},
          points = {{104.0, 39.0}, {122.0, 39.0}, {122.0, -34.0}, {7.0, -34.0}},
          color = {95, 95, 95},
          thickness = 0.8));
      connect(actuator1_1.u, controller3_2.y) 
        annotation (Line(origin = {-21.0, 27.5},
          points = {{11.0, 19.0}, {-15.0, 19.0}, {-15.0, -4.0}, {-22.0, -4.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_2.u, controller3_2.y1) 
        annotation (Line(origin = {-21.0, 15.5},
          points = {{11.0, 7.0}, {-8.0, 7.0}, {-8.0, -1.0}, {-22.0, -1.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_3.u, controller3_2.y2) 
        annotation (Line(origin = {-21.0, 2.5},
          points = {{11.0, -6.0}, {-8.0, -6.0}, {-8.0, 2.0}, {-22.0, 2.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_4.u, controller3_2.y3) 
        annotation (Line(origin = {-21.0, -10.5},
          points = {{11.0, -19.0}, {-16.0, -19.0}, {-16.0, 5.0}, {-22.0, 5.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(sensors1_1.AngleMea, controller3_2.angle) 
        annotation (Line(origin = {-58.0, -39.0},
          points = {{37.0, -18.0}, {-55.0, -18.0}, {-55.0, 33.0}, {-41.0, 33.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(sensors1_1.PosMea, controller3_2.position) 
        annotation (Line(origin = {-76.0, -34.0},
          points = {{55.0, -38.0}, {-50.0, -38.0}, {-50.0, 44.0}, {-23.0, 44.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(climbePath.position_command, controller3_2.position_command) 
        annotation (Line(origin = {-115.0, 24.0},
          points = {{-17.0, 0.0}, {17.0, 0.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_1.flange_a, speedSensor[1].flange) 
        annotation (Line(origin = {44.0, 57.0},
          points = {{-32.0, -10.0}, {-14.0, -10.0}, {-14.0, 9.0}, {26.0, 9.0}},
          color = {0, 0, 0}));
      connect(actuator1_2.flange_a, speedSensor[2].flange) 
        annotation (Line(origin = {44.0, 45.0},
          points = {{-32.0, -22.0}, {-14.0, -22.0}, {-14.0, 21.0}, {26.0, 21.0}},
          color = {0, 0, 0}));
      connect(actuator1_3.flange_a, speedSensor[3].flange) 
        annotation (Line(origin = {44.0, 32.0},
          points = {{-32.0, -35.0}, {-14.0, -35.0}, {-14.0, 34.0}, {26.0, 34.0}},
          color = {0, 0, 0}));
      connect(actuator1_4.flange_a, speedSensor[4].flange) 
        annotation (Line(origin = {44.0, 19.0},
          points = {{-32.0, -48.0}, {-14.0, -48.0}, {-14.0, 47.0}, {26.0, 47.0}},
          color = {0, 0, 0},
          thickness = 0.8));
    end Example1;
    model Example2 "螺旋爬升运动"

      PathPlanning.CirclePath climbePath(ramp(height=20), sine(f=0.05), cosine(f=0.05, startTime=10, phase=0)) 
        annotation (Placement(transformation(origin = {-159.00000000000003, 31.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));

      Mechanics.QuadChassis quadChassisTest17_1 annotation (Placement(transformation(origin = {95.0, 17.5},
        extent = {{-34.0, -33.99999999999999}, {34.0, 34.00000000000001}})));
      Electricals.Actuator actuator1_1 
        annotation (Placement(transformation(origin = {1.0, 53.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_2 
        annotation (Placement(transformation(origin = {1.0, 29.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_3 
        annotation (Placement(transformation(origin = {1.0, 3.500000000000007},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_4 
        annotation (Placement(transformation(origin = {1.0, -22.499999999999993},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));


      annotation (Diagram(coordinateSystem(extent = {{-200.0, -100.0}, {200.0, 100.0}},
        grid = {2.0, 2.0})),
        Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          preserveAspectRatio = false,
          grid = {2.0, 2.0})),
        experiment(Algorithm = Dassl, StartTime = 0, StopTime = 50, Tolerance = 0.0001, Interval = 0.01));
      extends Modelica.Icons.Example;
      Blocks.Controller.Controller controller3_2 
        annotation (Placement(transformation(origin = {-76.00000000000001, 16.0},
          extent = {{-25.000000000000014, -25.0}, {25.0, 25.0}})));
      Sensors.Sensors sensors1_1 
        annotation (Placement(transformation(origin = {0.9999999999999996, -64.5},
          extent = {{19.342105263157897, -17.5}, {-19.342105263157897, 17.5}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4] annotation (Placement(transformation(origin = {80.0, 66.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}})));
    equation
      connect(actuator1_1.flange_a, quadChassisTest17_1.flange_a) 
        annotation (Line(origin = {26.0, 37.5},
          points = {{-15.0, 16.0}, {4.0, 16.0}, {4.0, 0.0}, {35.0, 0.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_2.flange_a, quadChassisTest17_1.flange_a1) 
        annotation (Line(origin = {26.0, 21.5},
          points = {{-15.0, 8.0}, {4.0, 8.0}, {4.0, 3.0}, {35.0, 3.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_3.flange_a, quadChassisTest17_1.flange_a2) 
        annotation (Line(origin = {26.0, 7.500000000000007},
          points = {{-15.0, -4.0}, {4.0, -4.0}, {4.0, 3.0}, {35.0, 3.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_4.flange_a, quadChassisTest17_1.flange_a3) 
        annotation (Line(origin = {26.0, -6.499999999999993},
          points = {{-15.0, -16.0}, {4.0, -16.0}, {4.0, 4.0}, {35.0, 4.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(quadChassisTest17_1.frame_a, sensors1_1.frame_a) 
        annotation (Line(origin = {25.0, -21.499999999999993},
          points = {{104.0, 39.0}, {122.0, 39.0}, {122.0, -43.0}, {-5.0, -43.0}},
          color = {95, 95, 95},
          thickness = 0.8));
      connect(actuator1_1.u, controller3_2.y) 
        annotation (Line(origin = {-30.0, 34.5},
          points = {{19.0, 19.0}, {-11.0, 19.0}, {-11.0, -4.0}, {-19.0, -4.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_2.u, controller3_2.y1) 
        annotation (Line(origin = {-30.0, 22.5},
          points = {{19.0, 7.0}, {-5.0, 7.0}, {-5.0, -1.0}, {-19.0, -1.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_3.u, controller3_2.y2) 
        annotation (Line(origin = {-30.0, 9.500000000000007},
          points = {{19.0, -6.0}, {-5.0, -6.0}, {-5.0, 2.0}, {-19.0, 2.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_4.u, controller3_2.y3) 
        annotation (Line(origin = {-30.0, -3.499999999999993},
          points = {{19.0, -19.0}, {-9.0, -19.0}, {-9.0, 5.0}, {-19.0, 5.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(climbePath.position_command, controller3_2.position_command) 
        annotation (Line(origin = {-143.0, -11.0},
          points = {{2.0, 42.0}, {39.0, 42.0}},
          color = {0, 0, 127},
          thickness = 1.0));
      connect(sensors1_1.AngleMea, controller3_2.angle) 
        annotation (Line(origin = {-66.0, -31.0},
          points = {{46.0, -27.0}, {-50.0, -27.0}, {-50.0, 32.0}, {-38.0, 32.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(sensors1_1.PosMea, controller3_2.position) 
        annotation (Line(origin = {-92.0, -29.0},
          points = {{72.0, -42.0}, {-34.0, -42.0}, {-34.0, 46.0}, {-12.0, 46.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_1.flange_a, speedSensor[1].flange) 
        annotation (Line(origin = {44.0, 57.0},
          points = {{-32.0, -10.0}, {-14.0, -10.0}, {-14.0, 9.0}, {26.0, 9.0}},
          color = {0, 0, 0}));
      connect(actuator1_2.flange_a, speedSensor[2].flange) 
        annotation (Line(origin = {44.0, 45.0},
          points = {{-32.0, -22.0}, {-14.0, -22.0}, {-14.0, 21.0}, {26.0, 21.0}},
          color = {0, 0, 0}));
      connect(actuator1_3.flange_a, speedSensor[3].flange) 
        annotation (Line(origin = {44.0, 32.0},
          points = {{-32.0, -35.0}, {-14.0, -35.0}, {-14.0, 34.0}, {26.0, 34.0}},
          color = {0, 0, 0}));
      connect(actuator1_4.flange_a, speedSensor[4].flange) 
        annotation (Line(origin = {44.0, 19.0},
          points = {{-32.0, -48.0}, {-14.0, -48.0}, {-14.0, 47.0}, {26.0, 47.0}},
          color = {0, 0, 0},
          thickness = 0.8));
    end Example2;



    model Example3 "8字形运动"

      PathPlanning.EightPath climbePath annotation (Placement(transformation(origin = {-173.0, 27.0},
        extent = {{-16.0, -16.0}, {16.0, 16.0}})));

      Mechanics.QuadChassis quadChassisTest17_1 annotation (Placement(transformation(origin = {96.99999999999997, 15.500000000000007},
        extent = {{-34.0, -33.99999999999999}, {34.0, 34.00000000000001}})));
      Electricals.Actuator actuator1_1 
        annotation (Placement(transformation(origin = {3.0, 51.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_2 
        annotation (Placement(transformation(origin = {3.0, 27.5},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_3 
        annotation (Placement(transformation(origin = {3.0, 1.500000000000007},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Electricals.Actuator actuator1_4 
        annotation (Placement(transformation(origin = {3.0, -24.499999999999993},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));


      annotation (Diagram(coordinateSystem(extent = {{-200.0, -100.0}, {200.0, 100.0}},
        grid = {2.0, 2.0})),
        Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          preserveAspectRatio = false,
          grid = {2.0, 2.0})),
        experiment(Algorithm = Dassl, StartTime = 0, StopTime = 120, Tolerance = 0.0001, Interval = 0.01));
      extends Modelica.Icons.Example;
      Blocks.Controller.Controller controller3_2 
        annotation (Placement(transformation(origin = {-84.00000000000003, 12.0},
          extent = {{-25.000000000000014, -25.0}, {25.0, 25.0}})));
      Sensors.Sensors sensors1_1 
        annotation (Placement(transformation(origin = {2.999999999999999, -58.0},
          extent = {{19.342105263157897, -17.5}, {-19.342105263157897, 17.5}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4] annotation (Placement(transformation(origin = {80.0, 66.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}})));
    equation
      connect(actuator1_1.flange_a, quadChassisTest17_1.flange_a) 
        annotation (Line(origin = {28.0, 35.5},
          points = {{-15.0, 16.0}, {2.0, 16.0}, {2.0, 0.0}, {35.0, 0.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_2.flange_a, quadChassisTest17_1.flange_a1) 
        annotation (Line(origin = {28.0, 19.5},
          points = {{-15.0, 8.0}, {2.0, 8.0}, {2.0, 3.0}, {35.0, 3.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_3.flange_a, quadChassisTest17_1.flange_a2) 
        annotation (Line(origin = {28.0, 5.500000000000007},
          points = {{-15.0, -4.0}, {2.0, -4.0}, {2.0, 3.0}, {35.0, 3.0}},
          color = {0, 0, 0},
          thickness = 0.8));
      connect(actuator1_4.flange_a, quadChassisTest17_1.flange_a3) 
        annotation (Line(origin = {28.0, -8.499999999999993},
          points = {{-15.0, -16.0}, {2.0, -16.0}, {2.0, 4.0}, {35.0, 4.0}},
          color = {0, 0, 0},
          thickness = 0.8));


      connect(actuator1_1.u, controller3_2.y) 
        annotation (Line(origin = {-26.0, 16.5},
          points = {{17.0, 35.0}, {-16.0, 35.0}, {-16.0, 10.0}, {-31.0, 10.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_2.u, controller3_2.y1) 
        annotation (Line(origin = {-28.0, 20.5},
          points = {{19.0, 7.0}, {1.0, 7.0}, {1.0, -3.0}, {-29.0, -3.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_3.u, controller3_2.y2) 
        annotation (Line(origin = {-28.0, 7.500000000000007},
          points = {{19.0, -6.0}, {1.0, -6.0}, {1.0, 0.0}, {-29.0, 0.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_4.u, controller3_2.y3) 
        annotation (Line(origin = {-28.0, -5.499999999999993},
          points = {{19.0, -19.0}, {-9.0, -19.0}, {-9.0, 3.0}, {-29.0, 3.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(climbePath.position_command, controller3_2.position_command) 
        annotation (Line(origin = {-133.0, 57.0},
          points = {{-22.0, -30.0}, {21.0, -30.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(sensors1_1.frame_a, quadChassisTest17_1.frame_a) 
        annotation (Line(origin = {88.0, -28.0},
          points = {{-66.0, -30.0}, {64.0, -30.0}, {64.0, 43.0}, {43.0, 43.0}},
          color = {95, 95, 95},
          thickness = 0.8));
      connect(sensors1_1.AngleMea, controller3_2.angle) 
        annotation (Line(origin = {-68.0, -34.0},
          points = {{50.0, -17.0}, {-58.0, -17.0}, {-58.0, 31.0}, {-44.0, 31.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(sensors1_1.PosMea, controller3_2.position) 
        annotation (Line(origin = {-85.0, -32.0},
          points = {{67.0, -33.0}, {-55.0, -33.0}, {-55.0, 45.0}, {-27.0, 45.0}},
          color = {0, 0, 127},
          thickness = 0.8));
      connect(actuator1_1.flange_a, speedSensor[1].flange) 
        annotation (Line(origin = {44.0, 57.0},
          points = {{-32.0, -10.0}, {-14.0, -10.0}, {-14.0, 9.0}, {26.0, 9.0}},
          color = {0, 0, 0}));
      connect(actuator1_2.flange_a, speedSensor[2].flange) 
        annotation (Line(origin = {44.0, 45.0},
          points = {{-32.0, -22.0}, {-14.0, -22.0}, {-14.0, 21.0}, {26.0, 21.0}},
          color = {0, 0, 0}));
      connect(actuator1_3.flange_a, speedSensor[3].flange) 
        annotation (Line(origin = {44.0, 32.0},
          points = {{-32.0, -35.0}, {-14.0, -35.0}, {-14.0, 34.0}, {26.0, 34.0}},
          color = {0, 0, 0}));
      connect(actuator1_4.flange_a, speedSensor[4].flange) 
        annotation (Line(origin = {44.0, 19.0},
          points = {{-32.0, -48.0}, {-14.0, -48.0}, {-14.0, 47.0}, {26.0, 47.0}},
          color = {0, 0, 0},
          thickness = 0.8));
    end Example3;
  end Examples;
  package PathPlanning "路径模型"
    extends Modelica.Icons.Package;
    model CirclePath "螺旋爬升模型"
      Modelica.Blocks.Sources.Ramp ramp(startTime = 0, duration = 150,
        height = 10) 
        annotation (Placement(transformation(origin = {-2.0, -50.209416252197016},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Interfaces.RealOutput position_command[3] "指令信号--x,y,z" annotation (Placement(transformation(origin = {111.0, 0.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {110.0, 0.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Gain gain(k = 1) 
        annotation (Placement(transformation(origin = {55.94162521970009, -50.121461426274266},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Gain gain1(k = 1) 
        annotation (Placement(transformation(origin = {55.94162521970009, 41.790583747803},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.Sine sine(f=0.03, amplitude=3, startTime=10) 
        annotation (Placement(transformation(origin = {-2.0, -0.209416252197002},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.Cosine cosine(f=0.03, amplitude=3, startTime=10) 
        annotation (Placement(transformation(origin = {-2.0, 41.790583747803},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));



      Modelica.Blocks.Math.Gain gain2(k = 1) 
        annotation (Placement(transformation(origin = {56.779290228488094, 0.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0}), graphics = {Rectangle(origin = {-0.2695547533092224, 0.5391095066185301},
        lineColor = {200, 200, 200},
        fillColor = {248, 248, 248},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-100.0, -100.0}, {100.0, 100.0}},
        radius = 25.0), Ellipse(origin = {2.0, 1.0},
        lineColor = {118, 118, 118},
        fillColor = {255, 255, 255},
        lineThickness = 0.5,
        extent = {{60.0, 39.0}, {-60.0, -39.0}}), Line(origin = {2.0, 31.0},
        points = {{0.0, -33.0}, {0.0, 33.0}},
        color = {132, 132, 132},
        pattern = LinePattern.Dash,
        arrow = {Arrow.None, Arrow.Filled},
        arrowSize = 4.0,
        __MWorks_Manhattanize = true)}));
    equation
      connect(gain1.y, position_command[1]) 
        annotation (Line(origin = {89.0, 21.0},
          points = {{-22.0, 21.0}, {-9.0, 21.0}, {-9.0, -21.0}, {22.0, -21.0}},
          color = {0, 0, 127}));
      connect(gain2.y, position_command[2]) 
        annotation (Line(origin = {90.0, 0.0},
          points = {{-22.0, 0.0}, {21.0, 0.0}},
          color = {0, 0, 127}));
      connect(gain.y, position_command[3]) 
        annotation (Line(origin = {90.0, -25.0},
          points = {{-23.0, -25.0}, {-10.0, -25.0}, {-10.0, 25.0}, {21.0, 25.0}},
          color = {0, 0, 127}));
      connect(cosine.y, gain1.u) 
        annotation (Line(origin = {7.0, 42.0},
          points = {{2.0, 0.0}, {37.0, 0.0}},
          color = {0, 0, 127}));
      connect(sine.y, gain2.u) 
        annotation (Line(origin = {7.0, 0.0},
          points = {{2.0, 0.0}, {38.0, 0.0}},
          color = {0, 0, 127}));
      connect(ramp.y, gain.u) 
        annotation (Line(origin = {7.0, -50.0},
          points = {{2.0, 0.0}, {37.0, 0.0}},
          color = {0, 0, 127}));
    end CirclePath;


    model ClimbPath "阶梯爬升模型"
      Modelica.Blocks.Sources.Ramp ramp(startTime = 10, duration = 3,
        height = 5) 
        annotation (Placement(transformation(origin = {-52.0, -28.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Interfaces.RealOutput position_command[3] "指令信号--x,y,z" annotation (Placement(transformation(origin = {110.0, 0.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {110.0, 0.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.Ramp ramp1(offset = 0, startTime = 0, height = 10, duration = 5) 
        annotation (Placement(transformation(origin = {-52.0, -72.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));



      Modelica.Blocks.Math.Add add 
        annotation (Placement(transformation(origin = {6.0, -50.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Gain gain(k = 1) 
        annotation (Placement(transformation(origin = {46.0, -50.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      annotation (experiment(Algorithm = Dassl, Interval = 0.001, StartTime = 0, StopTime = 20, Tolerance = 0.0001),
        Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.11311672683513052, 0.808664259927788},
          lineColor = {200, 200, 200},
          fillColor = {248, 248, 248},
          fillPattern = FillPattern.HorizontalCylinder,
          extent = {{-100.0, -100.0}, {100.0, 100.0}},
          radius = 25.0), Line(origin = {3.0, -3.0},
          points = {{-83.0, -37.0}, {-5.0, -37.0}, {15.0, 37.0}, {83.0, 37.0}},
          color = {136, 136, 136},
          thickness = 0.5,
          arrow = {Arrow.None, Arrow.Filled}), Line(origin = {-63.0, -26.0},
          points = {{-17.0, 0.0}, {17.0, 0.0}},
          color = {134, 134, 134},
          pattern = LinePattern.Dash,
          arrow = {Arrow.None, Arrow.Filled},
          arrowSize = 4.0,
          __MWorks_Manhattanize = true)}));
      Modelica.Blocks.Sources.Ramp ramp3(startTime = 30, duration = 10,
        height = 10) 
        annotation (Placement(transformation(origin = {6.0, 0.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.Ramp ramp5(startTime = 20, duration = 10,
        height = 10) 
        annotation (Placement(transformation(origin = {6.0, 44.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
    equation
      connect(ramp.y, add.u1) 
        annotation (Line(origin = {-21.999999999999996, -35.0},
          points = {{-19.0, 7.0}, {4.0, 7.0}, {4.0, -9.0}, {16.0, -9.0}},
          color = {0, 0, 127}));
      connect(ramp1.y, add.u2) 
        annotation (Line(origin = {-21.999999999999996, -63.0},
          points = {{-19.0, -9.0}, {4.0, -9.0}, {4.0, 7.0}, {16.0, 7.0}},
          color = {0, 0, 127}));
      connect(add.y, gain.u) 
        annotation (Line(origin = {13.0, -50.0},
          points = {{4.0, 0.0}, {21.0, 0.0}},
          color = {0, 0, 127}));
      connect(gain.y, position_command[3]) 
        annotation (Line(origin = {84.0, -25.0},
          points = {{-27.0, -25.0}, {-22.0, -25.0}, {-22.0, 25.0}, {26.0, 25.0}},
          color = {0, 0, 127}));
      connect(ramp3.y, position_command[2]) 
        annotation (Line(origin = {64.0, 0.0},
          points = {{-47.0, 0.0}, {46.0, 0.0}},
          color = {0, 0, 127}));
      connect(ramp5.y, position_command[1]) 
        annotation (Line(origin = {64.0, 22.0},
          points = {{-47.0, 22.0}, {-2.0, 22.0}, {-2.0, -22.0}, {46.0, -22.0}},
          color = {0, 0, 127}));
    end ClimbPath;

    model EightPath "横8字型模型"
      Modelica.Blocks.Sources.RealExpression realExpression(y = x) 
        annotation (Placement(transformation(origin = {1.1591052234775123, 47.17773039939571},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.RealExpression realExpression1(y = y) 
        annotation (Placement(transformation(origin = {-0.1359852938817938, -0.17597254192228462},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Sources.Ramp ramp(duration = 10, height = 10) 
        annotation (Placement(transformation(origin = {-0.9087221095334688, -41.28301853656825},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Interfaces.RealOutput position_command[3] "指令信号--x,y,z" annotation (Placement(transformation(origin = {110.30852974245975, 0.03180971102869656},
        extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      import pi = Modelica.Constants.pi;
      Real x "x方向输出";
      Real y "y方向输出";
      parameter Real XAMP = 10 "x方向输出幅值";
      parameter Real XOmega = 0.02 "X方向频率";
      parameter Real YAMP = 10 "Y方向输出幅值";
      parameter Real YOmega = 0.04 "Y方向频率";
      Modelica.Blocks.Nonlinear.FixedDelay fixedDelay(delayTime=10) 
        annotation (Placement(transformation(origin={52,47.1777},
    extent={{-10,-10},{10,10}})));
      Modelica.Blocks.Nonlinear.FixedDelay fixedDelay1(delayTime=10) 
        annotation (Placement(transformation(origin={52,-0.175973},
    extent={{-10,-10},{10,10}})));
      annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0}), graphics = {Rectangle(origin = {5.684341886080802e-14, -0.6522262334536704},
        lineColor = {200, 200, 200},
        fillColor = {248, 248, 248},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-100.0, -100.0}, {100.0, 100.0}},
        radius = 25.0), Ellipse(origin = {-40.0, -1.0},
        lineColor = {135, 135, 135},
        fillColor = {255, 255, 255},
        extent = {{40.0, 23.0}, {-40.0, -23.0}}), Ellipse(origin = {39.0, -2.0},
        lineColor = {135, 135, 135},
        fillColor = {255, 255, 255},
        extent = {{39.0, 24.0}, {-39.0, -24.0}}), Line(origin = {-76.0, -1.0},
        points = {{10.0, 23.0}, {2.7886769820447683, 18.49292311377798}, {-6.0, 13.0}, {-10.0, 1.0}, {-6.0, -15.0}, {8.0, -23.0}},
        color = {135, 135, 135},
        pattern = LinePattern.Dash,
        arrow = {Arrow.None, Arrow.Filled},
        smooth = Smooth.Bezier)}),Diagram(coordinateSystem(extent={{-100,-100},{100,100}},
    grid={2,2})));
      equation
      if time<=0 then
      x=0;
      y=0;
      else
      x = XAMP * sin((XOmega * time + 1 / 360) * pi);
      y = YAMP * sin(YOmega * time * pi);
      end if;
      connect(ramp.y, position_command[3]) 
        annotation (Line(origin = {60.0, -11.0},
          points = {{-50.0, -30.0}, {20.0, -30.0}, {20.0, 11.0}, {50.0, 11.0}},
          color = {0, 0, 127}));
      connect(realExpression.y, fixedDelay.u) 
      annotation(Line(origin={61,24},
    points={{-48.8409,23.1777},{-21,23.1777}},
    color={0,0,127}));
      connect(realExpression1.y, fixedDelay1.u) 
      annotation(Line(origin={61,0},
    points={{-50.136,-0.175973},{-21,-0.175973}},
    color={0,0,127}));
      connect(fixedDelay.y, position_command[1]) 
      annotation(Line(origin={87,24},
    points={{-24,23.1777},{-7,23.1777},{-7,-23.9682},{23.3085,-23.9682}},
    color={0,0,127}));
      connect(fixedDelay1.y, position_command[2]) 
      annotation(Line(origin={122,20},
    points={{-59,-20.176},{-11.6915,-20.176},{-11.6915,-19.9682}},
    color={0,0,127}));
    end EightPath;


    annotation (Diagram(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
      grid = {2.0, 2.0})),
      Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        preserveAspectRatio = false,
        grid = {2.0, 2.0}), graphics = {Line(origin = {4.0, 16.25},
        points = {{-70.0, -34.25}, {-30.0, 34.25}, {37.0, 34.25}, {70.0, -34.25}},
        color = {158, 158, 158},
        thickness = 0.5), Line(origin = {-66.0, -6.0},
        points = {{0.0, 80.0}, {0.0, -80.0}},
        color = {153, 153, 153},
        arrow = {Arrow.Filled, Arrow.None},
        arrowSize = 5.0), Line(origin = {10.0, -18.0},
        points = {{-76.0, 0.0}, {76.0, 0.0}},
        color = {158, 158, 158},
        arrow = {Arrow.None, Arrow.Filled},
        arrowSize = 5.0), Text(origin = {8.0, 28.0},
        lineColor = {192, 192, 192},
        extent = {{-35.5, 21.5}, {35.5, -21.5}},
        textString = "w",
        textColor = {192, 192, 192}), Polygon(origin = {-66.0, 72.0},
        lineColor = {192, 192, 192},
        fillColor = {192, 192, 192},
        fillPattern = FillPattern.Solid,
        points = {{0.0, 11.0}, {-8.0, -11.0}, {8.0, -11.0}, {0.0, 11.0}}), Polygon(origin = {88.0, -18.0},
        rotation = -90.0,
        lineColor = {192, 192, 192},
        fillColor = {192, 192, 192},
        fillPattern = FillPattern.Solid,
        points = {{0.0, 11.0}, {8.0, -11.0}, {-8.0, -11.0}, {0.0, 11.0}})}));
  end PathPlanning;
  package Mechanics "机械多体库"
    annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
      grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.0, 0.0},
      lineColor = {200, 200, 200},
      fillColor = {248, 248, 248},
      fillPattern = FillPattern.HorizontalCylinder,
      extent = {{-100.0, -100.0}, {100.0, 100.0}},
      radius = 25.0), Rectangle(origin = {0.0, 0.0},
      lineColor = {128, 128, 128},
      extent = {{-100.0, -100.0}, {100.0, 100.0}},
      radius = 25.0), Rectangle(origin = {8.6, 63.3333},
      lineColor = {64, 64, 64},
      fillColor = {192, 192, 192},
      fillPattern = FillPattern.HorizontalCylinder,
      extent = {{-4.6, -93.3333}, {41.4, -53.3333}}), Ellipse(origin = {9.0, 46.0},
      extent = {{-90.0, -60.0}, {-80.0, -50.0}}), Line(origin = {9.0, 46.0},
      points = {{-85.0, -55.0}, {-60.0, -21.0}},
      thickness = 0.5), Ellipse(origin = {9.0, 46.0},
      extent = {{-65.0, -26.0}, {-55.0, -16.0}}), Line(origin = {9.0, 46.0},
      points = {{-60.0, -21.0}, {9.0, -55.0}},
      thickness = 0.5), Ellipse(origin = {9.0, 46.0},
      fillPattern = FillPattern.Solid,
      extent = {{4.0, -60.0}, {14.0, -50.0}}), Line(origin = {9.0, 46.0},
      points = {{-10.0, -26.0}, {72.0, -26.0}, {72.0, -86.0}, {-10.0, -86.0}})}));
    model QuadrotorBody "四旋翼机身"
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a 
        annotation (Placement(transformation(origin = {-100.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b 
        annotation (Placement(transformation(origin = {100.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Parts.BodyShape body(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        r_CM = {0, 0, 0.0230935},
        m = 0.159504,
        I_11 = 0.00010556,
        I_22 = 0.00010556,
        I_33 = 0.00010556,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "QuadBody.hsf",
        r_shape = {0, 0, 0},
        lengthDirection = {-1, 0, 0},
        widthDirection = {0, 1, 0},
        length = 1,
        width = 1,
        height = 1,
        extra = 1,
        color = {255, 255, 255},
        specularCoefficient = 1,
        r_0(fixed = false),
        enforceStates = true) annotation (Placement(transformation(extent = {{10.0, -10.0}, {-10.0, 10.0}})));
    equation
      connect(frame_a, body.frame_b) 
        annotation (Line(origin = {-55.0, 0.0},
          points = {{-45.0, 0.0}, {45.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(body.frame_a, frame_b) 
        annotation (Line(origin = {55.0, 0.0},
          points = {{-45.0, 0.0}, {45.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
    end QuadrotorBody;
    model Rotor "旋翼模型"
      Modelica.Mechanics.MultiBody.Parts.BodyShape propellers1(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        m = 0.000913171,
        I_11 = 1.59662e-7,
        I_22 = 1.59594e-7,
        I_33 = 3.16359e-7,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "QuadPropeller.hsf",
        r_shape = {0, 0, 0},
        lengthDirection = {0.923728, 0.383049, 0},
        widthDirection = {-0.383049, 0.923728, 0},
        length = 1,
        width = 1,
        height = 1,
        extra = 1,
        color = {255, 255, 255},
        specularCoefficient = 1,
        r_0(fixed = false)) 
        annotation (Placement(transformation(origin = {-25.00000000000003, -0.5000000000000284},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Joints.Revolute revolute1(
        animation = false,
        n = {0, 0, 1},
        useAxisFlange = true) 
        annotation (Placement(transformation(origin = {16.99999999999997, -0.5000000000000284},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_a annotation (Placement(transformation(origin = {-100.0, 18.000000000000014},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {-100.40059043098442, 1.7339167500375368},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b 
        annotation (Placement(transformation(origin = {101.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
    equation
      connect(propellers1.frame_a, revolute1.frame_b) 
        annotation (Line(origin = {-4.0, -0.5},
          points = {{-11.0, 0.0}, {11.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));



      connect(revolute1.axis, flange_a) 
        annotation (Line(origin = {19.0, 14.5},
          points = {{-2.0, -5.0}, {-2.0, 4.0}, {-118.0, 4.0}},
          color = {0, 0, 0}));
      connect(revolute1.frame_a, frame_b) 
        annotation (Line(origin = {64.0, 1.0},
          points = {{-37.0, -2.0}, {37.0, -2.0}, {37.0, -1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
    end Rotor;
    model Arm "机臂"
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed1(
        animation = false,
        r = {0.04243, -0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {2.4999999999999716, 75.50000000000004},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed2(
        animation = false,
        r = {0.04243, 0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {4.499999999999972, 24.83333333333337},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed3(
        animation = false,
        r = {-0.04243, 0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {2.4999999999999716, -25.8333333333333},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed4(
        animation = false,
        r = {-0.04243, -0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {2.4999999999999716, -76.49999999999997},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b 
        annotation (Placement(transformation(origin = {101.0, 76.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b1 
        annotation (Placement(transformation(origin = {101.0, 26.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b2 
        annotation (Placement(transformation(origin = {101.0, -24.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b3 
        annotation (Placement(transformation(origin = {101.0, -76.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a 
        annotation (Placement(transformation(origin = {-100.0, 76.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a1 
        annotation (Placement(transformation(origin = {-100.0, 24.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a2 
        annotation (Placement(transformation(origin = {-100.0, -26.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a3 
        annotation (Placement(transformation(origin = {-100.0, -76.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}})));
    equation
      connect(Dronefixed1.frame_a, frame_b) 
        annotation (Line(origin = {64.0, 77.0},
          points = {{-52.0, -1.0}, {37.0, -1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed2.frame_a, frame_b1) 
        annotation (Line(origin = {58.0, 25.0},
          points = {{-44.0, 0.0}, {-44.0, 1.0}, {43.0, 1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed3.frame_a, frame_b2) 
        annotation (Line(origin = {57.0, -25.0},
          points = {{-45.0, -1.0}, {44.0, -1.0}, {44.0, 1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed4.frame_a, frame_b3) 
        annotation (Line(origin = {58.0, -74.0},
          points = {{-46.0, -2.0}, {43.0, -2.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed1.frame_b, frame_a) 
        annotation (Line(origin = {-54.0, 76.0},
          points = {{46.0, 0.0}, {-46.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed2.frame_b, frame_a1) 
        annotation (Line(origin = {-53.0, 25.0},
          points = {{47.0, 0.0}, {45.0, 0.0}, {45.0, -1.0}, {-47.0, -1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(frame_a3, Dronefixed4.frame_b) 
        annotation (Line(origin = {-54.0, -76.0},
          points = {{-46.0, 0.0}, {46.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(frame_a2, Dronefixed3.frame_b) 
        annotation (Line(origin = {-54.0, -25.0},
          points = {{-46.0, -1.0}, {46.0, -1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
    end Arm;
    model QuadChassis "四旋翼本体+地面"
      annotation (Icon(coordinateSystem(extent = {{-200.0, -200.0}, {200.0, 200.0}},
        grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.0, 0.0},
        lineColor = {200, 200, 200},
        fillColor = {248, 248, 248},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-200.0, -200.0}, {200.0, 200.0}},
        radius = 25.0), Bitmap(origin = {-5.999999999999947, 7.628925581943946},
        extent = {{-137.50000000000006, -135.62892558194395}, {137.49999999999994, 135.62892558194395}},
        fileName = "modelica://QuadrotorModel/Resources/Images/Quadpic 5.png"), Line(origin = {0.0, 35.0},
        rotation = 270.0,
        points = {{31.0, 0.0}, {-31.0, 0.0}},
        color = {255, 0, 0},
        thickness = 1.0,
        arrow = {Arrow.None, Arrow.Filled},
        arrowSize = 5.0), Line(origin = {35.99999999999998, 1.9999999999999982},
        rotation = 270.0,
        points = {{1.7763568394002505e-15, -35.99999999999999}, {-1.7763568394002505e-15, 36.00000000000002}},
        color = {0, 128, 0},
        thickness = 1.0,
        arrow = {Arrow.None, Arrow.Filled},
        arrowSize = 5.0), Text(origin = {-122.0, 141.0},
        lineColor = {0, 0, 0},
        extent = {{-4.0, 5.0}, {4.0, -5.0}},
        textString = "1",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {120.0, 141.0},
        lineColor = {0, 0, 0},
        extent = {{-6.0, 5.0}, {6.0, -5.0}},
        textString = "2",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {121.0, -119.0},
        lineColor = {0, 0, 0},
        extent = {{-5.0, 5.0}, {5.0, -5.0}},
        textString = "3",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {-117.0, -119.0},
        lineColor = {0, 0, 0},
        extent = {{-7.0, 5.0}, {7.0, -5.0}},
        textString = "4",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {-177.0, 116.0},
        lineColor = {0, 0, 0},
        extent = {{-3.0, 4.0}, {3.0, -4.0}},
        textString = "1",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {-176.0, 40.0},
        lineColor = {0, 0, 0},
        extent = {{-4.0, 4.0}, {4.0, -4.0}},
        textString = "2",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {-175.0, -42.0},
        lineColor = {0, 0, 0},
        extent = {{-5.0, 4.0}, {5.0, -4.0}},
        textString = "3",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {-175.0, -124.0},
        lineColor = {0, 0, 0},
        extent = {{-5.0, 4.0}, {5.0, -4.0}},
        textString = "4",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {10.0, 60.0},
        lineColor = {0, 0, 0},
        extent = {{-4.0, 4.0}, {4.0, -4.0}},
        textString = "X",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {68.0, 18.0},
        lineColor = {0, 0, 0},
        extent = {{-4.0, 16.0}, {4.0, -16.0}},
        textString = "Y",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 0},
        horizontalAlignment = LinePattern.None), Text(origin = {0.0, 169.0},
        lineColor = {136, 136, 136},
        extent = {{-102.0, 97.0}, {102.0, -97.0}},
        textString = "QuadrotorBody",
        textStyle = {TextStyle.Bold},
        textColor = {136, 136, 136})}),
        Diagram(coordinateSystem(extent = {{-200.0, -200.0}, {200.0, 200.0}},
          grid = {2.0, 2.0})),
        experiment(Algorithm = Dassl, Interval = 0.001, StartTime = 0, StopTime = 30, Tolerance = 1e-10));
      inner Modelica.Mechanics.MultiBody.World world(
        animateWorld = false,
        animateGravity = false,
        n = {0, 0, -1},
        gravityType = Modelica.Mechanics.MultiBody.Types.GravityTypes.UniformGravity,
        g = 9.81) 

        annotation (Placement(transformation(origin = {124.60787940430421, 90.30849111731482},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      parameter Real lift_cofficient = 0.002 "旋翼的升力系数，这里简化处理";
      Modelica.Mechanics.MultiBody.Parts.BodyShape body(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        r_CM = {0, 0, 0.0230935},
        m = 0.159504,
        I_11 = 0.00010556,
        I_22 = 0.00010556,
        I_33 = 0.00010556,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "jijia.stl",
        r_shape = {-0.0005, -0.0018, 0.0485},
        lengthDirection = {0, 1, 0},
        widthDirection = {0, 0, 1},
        length = 0.000253,
        width = 0.0002,
        height = 0.00028,
        extra = 1,
        color = {255, 141, 11},
        specularCoefficient = 1,
        r_0(fixed = false),
        enforceStates = true) annotation (Placement(transformation(origin = {145.7168984524965, -2.964434436258074},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.BodyShape propellers1(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        m = 0.000913171,
        I_11 = 1.59662e-7,
        I_22 = 1.59594e-7,
        I_33 = 3.16359e-7,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "DroneBlade.stl",
        r_shape = {0, 0, 0},
        widthDirection = {0, 0, 1},
        length = 0.45,
        width = 0.45,
        height = 0.45,
        extra = 1,
        color = {192, 192, 192},
        r_0(fixed = false),
        specularCoefficient = 1) annotation (Placement(transformation(origin = {-8.223051505802104, 99.50262144364181},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Joints.Revolute revolute1(
        animation = false,
        n = {0, 0, 1},
        useAxisFlange = true) 
        annotation (Placement(transformation(origin = {33.77694849419791, 99.50262144364181},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed1(
        animation = false,
        r = {0.04243, -0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {73.77694849419791, 99.5026214436419},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Joints.Revolute revolute2(
        animation = false,
        n = {0, 0, 1},
        useAxisFlange = true) 
        annotation (Placement(transformation(origin = {33.77694849419791, 37.50262144364184},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed2(
        animation = false,
        r = {0.04243, 0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {73.77694849419791, 39.502621443641885},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Joints.Revolute revolute3(
        animation = false,
        n = {0, 0, 1},
        useAxisFlange = true) 
        annotation (Placement(transformation(origin = {33.77694849419791, -40.49737855635814},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed3(
        animation = false,
        r = {-0.04243, 0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {73.77694849419791, -40.497378556358086},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Joints.Revolute revolute4(
        animation = false,
        n = {0, 0, 1},
        useAxisFlange = true) 
        annotation (Placement(transformation(origin = {33.77694849419791, -100.49737855635817},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedTranslation Dronefixed4(
        animation = false,
        r = {-0.04243, -0.04243, 0.05460}) 
        annotation (Placement(transformation(origin = {73.7769484941979, -100.49737855635811},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Forces.WorldForce force1(resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b, animation=false) annotation (Placement(transformation(origin = {-43.68550815051444, 80.71820959281155},
          extent = {{10.0, -10.0}, {-10.0, 10.0}},
          rotation = -180.0)));
      Modelica.Mechanics.MultiBody.Forces.WorldForce force2(resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b, animation=false) annotation (Placement(transformation(origin = {-43.68550815051444, 20.437682636071557},
          extent = {{10.0, -10.0}, {-10.0, 10.0}},
          rotation = -180.0)));
      Modelica.Mechanics.MultiBody.Forces.WorldForce force3(resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b, animation=false) annotation (Placement(transformation(origin = {-43.68550815051444, -61.29549361916214},
          extent = {{10.0, -10.0}, {-10.0, 10.0}},
          rotation = -180.0)));
      Modelica.Mechanics.MultiBody.Forces.WorldForce force4(resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b, animation=false) annotation (Placement(transformation(origin = {-43.68550815051444, -121.52273778588403},
          extent = {{10.0, -10.0}, {-10.0, 10.0}},
          rotation = -180.0)));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a 
        annotation (Placement(transformation(origin = {198.73389546164995, -2.6981293698647804},
          extent = {{-16.0, -16.0}, {16.0, 16.0}}),
          iconTransformation(origin = {201.16363719723324, -0.25785116388788687},
            extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Mechanics.MultiBody.Parts.FixedRotation fixedRotation(r = {0, 0, -0.05},
        animation = false) annotation (Placement(transformation(origin = {158.25275041021322, 90.48433844745136},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Visualizers.FixedShape2 fixedShape2_1(shapeType = "Jichang1.stl",
        extra = 1, length = 4, width = 4, height = 4, color = {155, 155, 155}, animation = false) annotation (Placement(transformation(origin = {191.55742017263336, 92.28481521933296},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(transformation(origin = {-167.0062898849564, 81.17560498021649},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
      Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_a annotation (Placement(transformation(origin = {-202.121, 118.705},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {-200.40059043098444, 117.73391675003751},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

      Modelica.Blocks.Math.Gain gain2(k = lift_cofficient) 
        annotation (Placement(transformation(origin = {-86.81308142887323, 80.23120583227565},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Product PF3 
        annotation (Placement(transformation(origin = {-118.58572547423151, 80.06209401758375},
          extent = {{-11.0, -11.0}, {11.0, 11.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor1 annotation (
        Placement(transformation(origin = {-164.99920358087837, 21.03024798179142},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
      Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_a1 annotation (Placement(transformation(origin = {-203.656, 58.8397},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {-200.40059043098444, 38.95688026849126},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

      Modelica.Blocks.Math.Gain gain3(k = lift_cofficient) 
        annotation (Placement(transformation(origin = {-84.80599512479517, 20.085848833850648},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Product PF4 
        annotation (Placement(transformation(origin = {-116.57863917015342, 19.91673701915868},
          extent = {{-11.0, -11.0}, {11.0, 11.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor2 annotation (
        Placement(transformation(origin = {-161.75066788483727, -60.34082342126454},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
      Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_a2 annotation (Placement(transformation(origin = {-202.548, -22.2587},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {-200.40059043098444, -39.820156213054986},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

      Modelica.Blocks.Math.Gain gain4(k = lift_cofficient) 
        annotation (Placement(transformation(origin = {-81.55745942875407, -61.28522256920533},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Product PF5 
        annotation (Placement(transformation(origin = {-113.33010347411226, -61.45433438389731},
          extent = {{-11.0, -11.0}, {11.0, 11.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor3 annotation (
        Placement(transformation(origin = {-161.3686131501953, -120.82889806644587},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
      Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_a3 annotation (Placement(transformation(origin = {-203.305, -81.059},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {-200.40059043098444, -118.59719269460122},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

      Modelica.Blocks.Math.Gain gain5(k = lift_cofficient) 
        annotation (Placement(transformation(origin = {-81.17540469411205, -121.77329721438676},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Product PF6 
        annotation (Placement(transformation(origin = {-112.9480487394703, -121.9424090290787},
          extent = {{-11.0, -11.0}, {11.0, 11.0}})));
      GroundModel.TouchModel touchModel(V_s = 0, Cst = 0, Vtr = 0, Cdy = 0,
        Fs(animation
           = false)) 
        annotation (Placement(transformation(origin = {144.0, 48.0},
          extent = {{-10.0, 10.0}, {10.0, -10.0}},
          rotation = -90.0)));
      Modelica.Mechanics.MultiBody.Parts.BodyShape propellers2(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        m = 0.000913171,
        I_11 = 1.59662e-7,
        I_22 = 1.59594e-7,
        I_33 = 3.16359e-7,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "DroneBlade.stl",
        r_shape = {0, 0, 0},
        widthDirection = {0, 0, 1},
        length = 0.45,
        width = 0.45,
        height = 0.45,
        extra = 1,
        color = {192, 192, 192},
        specularCoefficient = 1,
        r_0(fixed = false)) 
        annotation (Placement(transformation(origin = {-8.223051505802104, 37.50262144364186},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.BodyShape propellers3(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        m = 0.000913171,
        I_11 = 1.59662e-7,
        I_22 = 1.59594e-7,
        I_33 = 3.16359e-7,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "DroneBlade.stl",
        r_shape = {0, 0, 0},
        widthDirection = {0, 0, 1},
        length = 0.45,
        width = 0.45,
        height = 0.45,
        extra = 1,
        color = {192, 192, 192},
        specularCoefficient = 1,
        r_0(fixed = false)) 
        annotation (Placement(transformation(origin = {-8.223051505802102, -40.49737855635814},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
      Modelica.Mechanics.MultiBody.Parts.BodyShape propellers4(
        animation = true,
        animateSphere = false,
        r = {0, 0, 0},
        m = 0.000913171,
        I_11 = 1.59662e-7,
        I_22 = 1.59594e-7,
        I_33 = 3.16359e-7,
        I_21 = 0,
        I_31 = 0,
        I_32 = 0,
        shapeType = "DroneBlade.stl",
        r_shape = {0, 0, 0},
        widthDirection = {0, 0, 1},
        length = 0.45,
        width = 0.45,
        height = 0.45,
        extra = 1,
        color = {192, 192, 192},
        specularCoefficient = 1,
        r_0(fixed = false)) 
        annotation (Placement(transformation(origin = {-8.223051505802102, -100.4973785563582},
          extent = {{10.0, -10.0}, {-10.0, 10.0}})));
    equation
      force1.force[1] = 0;
      force1.force[2] = 0;
      force2.force[1] = 0;
      force2.force[2] = 0;
      force3.force[1] = 0;
      force3.force[2] = 0;
      force4.force[1] = 0;
      force4.force[2] = 0;
      connect(propellers1.frame_a, revolute1.frame_b) 
        annotation (Line(origin = {12.776948494197939, 99.50262144364183},
          points = {{-11.0, 0.0}, {11.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute1.frame_a, Dronefixed1.frame_b) 
        annotation (Line(origin = {53.77694849419794, 99.50262144364183},
          points = {{-10.0, 0.0}, {10.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed1.frame_a, body.frame_b) 
        annotation (Line(origin = {104.77694849419794, 49.50262144364184},
          points = {{-21.0, 50.0}, {-1.0, 50.0}, {-1.0, -52.0}, {31.0, -52.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute2.frame_a, Dronefixed2.frame_b) 
        annotation (Line(origin = {53.77694849419794, 39.50262144364184},
          points = {{-10.0, -2.0}, {12.0, -2.0}, {12.0, 0.0}, {10.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute3.frame_a, Dronefixed3.frame_b) 
        annotation (Line(origin = {53.77694849419794, -40.49737855635815},
          points = {{-10.0, 0.0}, {10.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute4.frame_a, Dronefixed4.frame_b) 
        annotation (Line(origin = {53.77694849419794, -100.49737855635817},
          points = {{-10.0, 0.0}, {10.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed2.frame_a, body.frame_b) 
        annotation (Line(origin = {104.77694849419794, 19.502621443641846},
          points = {{-21.0, 20.0}, {-1.0, 20.0}, {-1.0, -22.0}, {31.0, -22.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed3.frame_a, body.frame_b) 
        annotation (Line(origin = {104.77694849419794, -20.497378556358157},
          points = {{-21.0, -20.0}, {-1.0, -20.0}, {-1.0, 18.0}, {31.0, 18.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Dronefixed4.frame_a, body.frame_b) 
        annotation (Line(origin = {104.77694849419794, -50.49737855635815},
          points = {{-21.0, -50.0}, {-1.0, -50.0}, {-1.0, 48.0}, {31.0, 48.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(force1.frame_b, Dronefixed1.frame_b) 
        annotation (Line(origin = {-27.22305150580206, 99.50262144364183},
          points = {{-6.0, -19.0}, {90.0, -19.0}, {90.0, 0.0}, {91.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(force2.frame_b, Dronefixed2.frame_b) 
        annotation (Line(origin = {-27.22305150580206, 39.50262144364184},
          points = {{-6.0, -19.0}, {90.0, -19.0}, {90.0, 0.0}, {91.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(force3.frame_b, Dronefixed3.frame_b) 
        annotation (Line(origin = {-27.22305150580206, -40.49737855635815},
          points = {{-6.0, -21.0}, {90.0, -21.0}, {90.0, 0.0}, {91.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(force4.frame_b, Dronefixed4.frame_b) 
        annotation (Line(origin = {-27.22305150580206, -100.49737855635817},
          points = {{-6.0, -21.0}, {96.0, -21.0}, {96.0, 0.0}, {91.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(world.frame_b, fixedRotation.frame_a) 
        annotation (Line(origin = {141.19763229997702, 89.57095262067975},
          points = {{-7.0, 1.0}, {7.0, 1.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(fixedRotation.frame_b, fixedShape2_1.frame_a) 
        annotation (Line(origin = {176.88393527497624, 90.4095726524103},
          points = {{-9.0, 0.0}, {5.0, 0.0}, {5.0, 2.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(flange_a, speedSensor.flange) 
        annotation (Line(origin = {-152.40323470449508, 109.45508643941054},
          points = {{-50.0, 9.0}, {-31.0, 9.0}, {-31.0, -28.0}, {-25.0, -28.0}},
          color = {0, 0, 0}));
      connect(PF3.y, gain2.u) 
        annotation (Line(origin = {-116.0632797293461, 80.06209401758369},
          points = {{10.0, 0.0}, {17.0, 0.0}},
          color = {0, 0, 127}));
      connect(speedSensor.w, PF3.u1) 
        annotation (Line(origin = {-143.70360332410846, 83.94180069248642},
          points = {{-12.0, -3.0}, {-4.0, -3.0}, {-4.0, 3.0}, {12.0, 3.0}},
          color = {0, 0, 127}));
      connect(PF3.u2, speedSensor.w) 
        annotation (Line(origin = {-143.70360332410846, 77.94180069248642},
          points = {{12.0, -4.0}, {-4.0, -4.0}, {-4.0, 3.0}, {-12.0, 3.0}},
          color = {0, 0, 127}));
      connect(gain2.y, force1.force[3]) 
        annotation (Line(origin = {-68.5072156121318, 80.71820959281146},
          points = {{-7.0, 0.0}, {13.0, 0.0}},
          color = {0, 0, 127}));
      connect(revolute1.axis, flange_a) 
        annotation (Line(origin = {-84.22305150580206, 114.50262144364183},
          points = {{118.0, -5.0}, {118.0, 4.0}, {-118.0, 4.0}},
          color = {0, 0, 0}));
      connect(flange_a1, speedSensor1.flange) 
        annotation (Line(origin = {-154.68031250674682, 30.52531759015514},
          points = {{-49.0, 28.0}, {-29.0, 28.0}, {-29.0, -9.0}, {-20.0, -9.0}},
          color = {0, 0, 0}));
      connect(PF4.y, gain3.u) 
        annotation (Line(origin = {-114.05619342526796, 19.916737019158653},
          points = {{10.0, 0.0}, {17.0, 0.0}},
          color = {0, 0, 127}));
      connect(speedSensor1.w, PF4.u1) 
        annotation (Line(origin = {-141.69651702003043, 23.796443694061388},
          points = {{-12.0, -3.0}, {-13.0, -3.0}, {-13.0, 3.0}, {12.0, 3.0}},
          color = {0, 0, 127}));
      connect(PF4.u2, speedSensor1.w) 
        annotation (Line(origin = {-141.69651702003043, 17.796443694061374},
          points = {{12.0, -4.0}, {-13.0, -4.0}, {-13.0, 3.0}, {-12.0, 3.0}},
          color = {0, 0, 127}));
      connect(revolute2.axis, flange_a1) 
        annotation (Line(origin = {-84.22305150580206, 54.50262144364184},
          points = {{118.0, -7.0}, {118.0, 4.0}, {-119.0, 4.0}},
          color = {0, 0, 0}));
      connect(gain3.y, force2.force[3]) 
        annotation (Line(origin = {-65.96584132947362, 20.437682636071507},
          points = {{-8.0, 0.0}, {10.0, 0.0}},
          color = {0, 0, 127}));
      connect(flange_a2, speedSensor2.flange) 
        annotation (Line(origin = {-153.16495306593922, -30.04763875009685},
          points = {{-49.0, 8.0}, {-29.0, 8.0}, {-29.0, -30.0}, {-19.0, -30.0}},
          color = {0, 0, 0}));
      connect(PF5.y, gain4.u) 
        annotation (Line(origin = {-110.80765772922683, -61.45433438389731},
          points = {{10.0, 0.0}, {17.0, 0.0}},
          color = {0, 0, 127}));
      connect(speedSensor2.w, PF5.u1) 
        annotation (Line(origin = {-138.44798132398932, -57.574627708994576},
          points = {{-12.0, -3.0}, {-12.0, 3.0}, {12.0, 3.0}},
          color = {0, 0, 127}));
      connect(PF5.u2, speedSensor2.w) 
        annotation (Line(origin = {-138.44798132398932, -63.574627708994605},
          points = {{12.0, -4.0}, {-12.0, -4.0}, {-12.0, 3.0}},
          color = {0, 0, 127}));
      connect(gain4.y, force3.force[3]) 
        annotation (Line(origin = {-63.48987525056839, -60.29549361916214},
          points = {{-7.0, -1.0}, {8.0, -1.0}},
          color = {0, 0, 127}));
      connect(revolute3.axis, flange_a2) 
        annotation (Line(origin = {-84.22305150580206, -25.497378556358157},
          points = {{118.0, -5.0}, {118.0, 3.0}, {-118.0, 3.0}},
          color = {0, 0, 0}));
      connect(flange_a3, speedSensor3.flange) 
        annotation (Line(origin = {-151.0497220760636, -111.33382845808222},
          points = {{-52.0, 30.0}, {-29.0, 30.0}, {-29.0, -9.0}, {-20.0, -9.0}},
          color = {0, 0, 0}));
      connect(PF6.y, gain5.u) 
        annotation (Line(origin = {-110.42560299458489, -121.9424090290787},
          points = {{10.0, 0.0}, {17.0, 0.0}},
          color = {0, 0, 127}));
      connect(speedSensor3.w, PF6.u1) 
        annotation (Line(origin = {-138.06592658934738, -118.06270235417597},
          points = {{-12.0, -3.0}, {-12.0, 3.0}, {12.0, 3.0}},
          color = {0, 0, 127}));
      connect(PF6.u2, speedSensor3.w) 
        annotation (Line(origin = {-138.06592658934738, -124.062702354176},
          points = {{12.0, -4.0}, {-12.0, -4.0}, {-12.0, 3.0}},
          color = {0, 0, 127}));
      connect(revolute4.axis, flange_a3) 
        annotation (Line(origin = {-84.22305150580206, -85.49737855635817},
          points = {{118.0, -5.0}, {118.0, 4.0}, {-119.0, 4.0}},
          color = {0, 0, 0}));
      connect(gain5.y, force4.force[3]) 
        annotation (Line(origin = {-62.685508150514465, -121.52273778588409},
          points = {{-7.0, 0.0}, {7.0, 0.0}},
          color = {0, 0, 127}));
      connect(touchModel.frame_a, world.frame_b) 
        annotation (Line(origin = {143.0, 75.0},
          points = {{1.0, -17.0}, {1.0, 15.0}, {-8.0, 15.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(touchModel.frame_b, body.frame_a) 
        annotation (Line(origin = {150.0, 18.0},
          points = {{-6.0, 20.0}, {-6.0, -6.0}, {6.0, -6.0}, {6.0, -21.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(body.frame_b, frame_a) 
        annotation (Line(origin = {167.0, -7.0},
          points = {{-31.0, 4.0}, {-33.0, 4.0}, {-33.0, -9.0}, {8.0, -9.0}, {8.0, 4.0}, {32.0, 4.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute2.frame_b, propellers2.frame_a) 
        annotation (Line(origin = {13.0, 38.0},
          points = {{10.77694849419791, -0.4973785563581572}, {-11.223051505802104, -0.497378556358143}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute3.frame_b, propellers3.frame_a) 
        annotation (Line(origin = {13.0, -40.0},
          points = {{11.0, 0.0}, {-11.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(revolute4.frame_b, propellers4.frame_a) 
        annotation (Line(origin = {13.0, -100.0},
          points = {{10.77694849419791, -0.4973785563581714}, {-11.223051505802102, -0.49737855635819983}},
          color = {95, 95, 95},
          thickness = 0.5));
    end QuadChassis;
  end Mechanics;
  package Blocks "控制系统"
    extends Modelica.Icons.Package;
    annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
      preserveAspectRatio = false,
      grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.0, 0.0},
      lineColor = {128, 128, 128},
      extent = {{-100.0, -100.0}, {100.0, 100.0}},
      radius = 25.0), Rectangle(origin = {0.0, 35.1488},
      fillColor = {255, 255, 255},
      extent = {{-30.0, -20.1488}, {30.0, 20.1488}}), Rectangle(origin = {0.0, -34.8512},
      fillColor = {255, 255, 255},
      extent = {{-30.0, -20.1488}, {30.0, 20.1488}}), Line(origin = {-51.25, 0.0},
      points = {{21.25, -35.0}, {-13.75, -35.0}, {-13.75, 35.0}, {6.25, 35.0}}), Polygon(origin = {-40.0, 35.0},
      pattern = LinePattern.None,
      fillPattern = FillPattern.Solid,
      points = {{10.0, 0.0}, {-5.0, 5.0}, {-5.0, -5.0}}), Line(origin = {51.25, 0.0},
      points = {{-21.25, 35.0}, {13.75, 35.0}, {13.75, -35.0}, {-6.25, -35.0}}), Polygon(origin = {40.0, -35.0},
      pattern = LinePattern.None,
      fillPattern = FillPattern.Solid,
      points = {{-10.0, 0.0}, {5.0, 5.0}, {5.0, -5.0}})}));



    package ControlMethod "控制算法"
      extends Modelica.Icons.Package;
      model PID "连续PID控制器"

        parameter Real KP = 1;
        parameter Real KI = 1;
        parameter Real KD = 1;
        Modelica.Blocks.Math.Gain gain(k = KP) 
          annotation (Placement(transformation(origin = {-30.0, 60.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add3 add3_1 
          annotation (Placement(transformation(origin = {38.0, 0.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Continuous.Integrator integrator 
          annotation (Placement(transformation(origin = {-50.0, 0.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Continuous.Derivative der1 annotation (Placement(transformation(origin = {-50.0, -60.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Gain gain1(k = KI) 
          annotation (Placement(transformation(origin = {-10.0, 0.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain2(k = KD) 
          annotation (Placement(transformation(origin = {-10.0, -60.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.9443507588532611, -1.0556492411467104},
          lineColor = {200, 200, 200},
          fillColor = {248, 248, 248},
          fillPattern = FillPattern.HorizontalCylinder,
          extent = {{-100.0, -100.0}, {100.0, 100.0}},
          radius = 25.0), Text(origin = {-0.24957841483981724, 0.527824620573357},
          lineColor = {120, 120, 120},
          extent = {{-92.0, 73.0}, {92.0, -73.0}},
          textString = "PID",
          fontName = "Times New Roman",
          textStyle = {TextStyle.None},
          textColor = {120, 120, 120})}));
        extends Modelica.Blocks.Interfaces.SISO;
        Modelica.Blocks.Math.Gain gain3 
          annotation (Placement(transformation(origin = {73.99999999999999, 0.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      equation
        connect(u, integrator.u) 
          annotation (Line(origin = {-91.0, 0.0},
            points = {{-29.0, 0.0}, {29.0, 0.0}},
            color = {0, 0, 127}));
        connect(u, gain.u) 
          annotation (Line(origin = {-81.0, 30.0},
            points = {{-39.0, -30.0}, {1.0, -30.0}, {1.0, 30.0}, {39.0, 30.0}},
            color = {0, 0, 127}));
        connect(u, der1.u) 
          annotation (Line(origin = {-91.0, -30.0},
            points = {{-29.0, 30.0}, {11.0, 30.0}, {11.0, -30.0}, {29.0, -30.0}},
            color = {0, 0, 127}));
        connect(integrator.y, gain1.u) 
          annotation (Line(origin = {-30.0, 0.0},
            points = {{-9.0, 0.0}, {8.0, 0.0}},
            color = {0, 0, 127}));
        connect(der1.y, gain2.u) 
          annotation (Line(origin = {-30.0, -60.0},
            points = {{-9.0, 0.0}, {8.0, 0.0}},
            color = {0, 0, 127}));
        connect(gain.y, add3_1.u1) 
          annotation (Line(origin = {20.0, 34.0},
            points = {{-39.0, 26.0}, {-6.0, 26.0}, {-6.0, -26.0}, {6.0, -26.0}},
            color = {0, 0, 127}));
        connect(gain1.y, add3_1.u2) 
          annotation (Line(origin = {30.0, 0.0},
            points = {{-29.0, 0.0}, {-4.0, 0.0}},
            color = {0, 0, 127}));
        connect(gain2.y, add3_1.u3) 
          annotation (Line(origin = {30.0, -34.0},
            points = {{-29.0, -26.0}, {-16.0, -26.0}, {-16.0, 26.0}, {-4.0, 26.0}},
            color = {0, 0, 127}));
        connect(add3_1.y, gain3.u) 
          annotation (Line(origin = {55.0, 0.0},
            points = {{-6.0, 0.0}, {6.999999999999986, 0.0}},
            color = {0, 0, 127}));
        connect(gain3.y, y) 
          annotation (Line(origin = {98.0, 0.0},
            points = {{-13.000000000000014, 0.0}, {12.0, 0.0}},
            color = {0, 0, 127}));
      end PID;
    end ControlMethod;

    package Controller "控制器"
      extends Modelica.Icons.Package;
      model Controller "6Dof控制器-"
        Modelica.Blocks.Math.Gain gain2(k = 1) 
          annotation (Placement(transformation(origin = {-212.69990699270426, -179.0123120728828},
            extent = {{9.663753636058601, -9.663753636058573}, {-9.663753636058544, 9.663753636058573}},
            rotation = -180.0)));
        Modelica.Blocks.Math.Add add 
          annotation (Placement(transformation(origin = {195.38603678043503, 136.2455786404107},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add add1 
          annotation (Placement(transformation(origin = {194.07688458582734, 43.30416328490037},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add add2 
          annotation (Placement(transformation(origin = {194.07688458582734, -49.63725207061002},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add add3 
          annotation (Placement(transformation(origin = {193.41777678011923, -143.77619343602075},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add3 add3_1(k3 = +1, k2 = -1,
          k1 = -1) 
          annotation (Placement(transformation(origin = {132.88406102774712, 142.6102498040092},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add3 add3_2(k3 = -1, k2 = -1,
          k1 = +1) 
          annotation (Placement(transformation(origin = {132.88406102774712, 49.929746327695895},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add3 add3_3(k3 = -1, k2 = +1,
          k1 = -1) 
          annotation (Placement(transformation(origin = {132.88406102774712, -34.903964680479746},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Add3 add3_4(k3 = +1, k2 = +1,
          k1 = +1) 
          annotation (Placement(transformation(origin = {132.88406102774712, -120.6610719227242},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain(k = 0.707) 
          annotation (Placement(transformation(origin = {50.0, 51.929746327695895},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain1(k = 0.707) 
          annotation (Placement(transformation(origin = {50.31127897946099, -41.478087343389646},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Feedback feedback 
          annotation (Placement(transformation(origin = {-40.0, 136.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        ControlMethod.PID PID1(KP = 5, KI = 0, KD = 0) annotation (Placement(transformation(origin = {-10.000000000000004, 136.24557864041074},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Feedback feedback1 
          annotation (Placement(transformation(origin = {-40.0, 51.9297463276959},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        ControlMethod.PID PID5(KP = 14.142, KI = 0, KD = 1.414) annotation (Placement(transformation(origin = {-9.999999999999998, 51.929746327695895},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Feedback feedback2 
          annotation (Placement(transformation(origin = {-39.99999999999999, -41.737719741257976},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        ControlMethod.PID PID6(KP = 14.142, KI = 0, KD = 1.414) annotation (Placement(transformation(origin = {-10.0, -41.737719741257976},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Feedback feedback3 
          annotation (Placement(transformation(origin = {-177.0338684599124, -144.95408039247764},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        ControlMethod.PID PID7(KP = 8, KI = 6, KD = 4) annotation (Placement(transformation(origin = {-147.6231252910071, -145.3480005256226},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Gain gain3(k = 1) 
          annotation (Placement(transformation(origin = {-112.51509596744064, -144.65059206492597},
            extent = {{7.892020399656985, -7.892020399656985}, {-7.892020399656985, 7.892020399656985}},
            rotation = -180.0)));
        ControlMethod.PID PID3(KP = 1.5, KI = 0, KD = 1) annotation (Placement(transformation(origin = {-147.89106799143525, 54.13037202945324},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        ControlMethod.PID PID4(KP = 1.5, KI = 0, KD = 1) annotation (Placement(transformation(origin = {-147.6231252910071, -42.78744987823214},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));

        Modelica.Blocks.Math.Feedback feedback4 
          annotation (Placement(transformation(origin = {-174.06836126495082, 55.01839156918994},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Feedback feedback5 
          annotation (Placement(transformation(origin = {-175.50457262869273, -43.28839032256941},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain4(k = 1) 
          annotation (Placement(transformation(origin = {-212.36366062876286, -74.70691878418587},
            extent = {{10.0, -10.0}, {-10.0, 10.0}},
            rotation = -180.0)));
        Modelica.Blocks.Nonlinear.Limiter limiter1(uMax = 15 / 57.3) 
          annotation (Placement(transformation(origin = {-70.0, 52.63497015576597},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Nonlinear.Limiter limiter2(uMax = 15 / 57.3) 
          annotation (Placement(transformation(origin = {-68.9630855717734, -42.78744987823214},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain5(k = 0.1) 
          annotation (Placement(transformation(origin = {-110.40711636709761, -44.40672684784512},
            extent = {{10.0, -10.0}, {-10.0, 10.0}},
            rotation = -180.0)));
        Modelica.Blocks.Math.Gain gain6(k = 0.1) 
          annotation (Placement(transformation(origin = {-110.40711636709761, 53.95747780349969},
            extent = {{10.0, -10.0}, {-10.0, 10.0}},
            rotation = -180.0)));
        annotation (Diagram(coordinateSystem(extent = {{-270.0, -200.0}, {270.0, 200.0}},
          grid = {2.0, 2.0}), graphics = {Rectangle(origin = {161.99999999999994, 6.039613253960852e-14},
          fillColor = {250, 250, 187},
          pattern = LinePattern.Dash,
          fillPattern = FillPattern.Solid,
          extent = {{-87.99999999999994, 199.99999999999994}, {88.00000000000006, -200.00000000000006}}), Rectangle(origin = {-8.999999999999993, -5.684341886080802e-14},
          fillColor = {170, 255, 127},
          pattern = LinePattern.Dash,
          fillPattern = FillPattern.Solid,
          extent = {{-75.00000000000001, 200.00000000000006}, {74.99999999999997, -199.99999999999994}}), Rectangle(origin = {-178.0, -2.1316282072803006e-14},
          fillColor = {170, 255, 255},
          pattern = LinePattern.Dash,
          fillPattern = FillPattern.Solid,
          extent = {{-84.0, 200.00000000000003}, {84.0, -199.99999999999997}}), Text(origin = {-172.0, 187.0},
          extent = {{-40.0, 15.0}, {40.0, -15.0}},
          textString = "位置控制",
          fontName = "等线",
          textStyle = {TextStyle.None}), Text(origin = {-5.0, 188.0},
          extent = {{-39.0, 20.0}, {39.0, -20.0}},
          textString = "姿态控制",
          fontName = "等线",
          textStyle = {TextStyle.None}), Text(origin = {151.0, 188.0},
          extent = {{-39.0, 12.0}, {39.0, -12.0}},
          textString = "控制分配",
          fontName = "等线",
          textStyle = {TextStyle.None})}),
          Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
            grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.22951688694824135, 0.45903377389647915},
            lineColor = {200, 200, 200},
            fillColor = {248, 248, 248},
            fillPattern = FillPattern.HorizontalCylinder,
            extent = {{-100.0, -100.0}, {100.0, 100.0}},
            radius = 25.0), Text(origin = {2.0, 3.0},
            lineColor = {136, 136, 136},
            extent = {{-78.0, 81.0}, {78.0, -81.0}},
            textString = "PIDController",
            fontName = "Times New Roman",
            textStyle = {TextStyle.None},
            textColor = {136, 136, 136})}));
        Modelica.Blocks.Math.Gain gain7(k = 1) 
          annotation (Placement(transformation(origin = {-212.36366062876286, 22.765560154234876},
            extent = {{10.0, -10.0}, {-10.0, 10.0}},
            rotation = -180.0)));
        Modelica.Blocks.Math.Gain gain8(k = 1) 
          annotation (Placement(transformation(origin = {230.0, 136.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain9(k = -1) 
          annotation (Placement(transformation(origin = {230.0, 44.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain10(k = 1) 
          annotation (Placement(transformation(origin = {230.0, -50.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain11(k = -1) 
          annotation (Placement(transformation(origin = {230.0, -144.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain12(k = 0.707) 
          annotation (Placement(transformation(origin = {50.0, 136.2455786404107},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Math.Gain gain13(k = -1) 
          annotation (Placement(transformation(origin = {-112.51509596744066, -95.58264925655706},
            extent = {{10.0, -10.0}, {-10.0, 10.0}},
            rotation = -180.0)));
        Modelica.Blocks.Nonlinear.Limiter limiter3(uMax = 7) 
          annotation (Placement(transformation(origin = {20.0, 51.929746327695895},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Nonlinear.Limiter limiter4(uMax = 7) 
          annotation (Placement(transformation(origin = {20.155639489730493, -41.47808734338966},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Nonlinear.Limiter limiter5(uMax = 7) 
          annotation (Placement(transformation(origin = {19.999999999999996, 136.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealInput position_command[3] "指令信号 --- x，y，z" annotation (Placement(transformation(origin = {-286.0, 94.0},
          extent = {{-20.0, -20.0}, {20.0, 20.0}}),
          iconTransformation(origin = {-110.0, 60.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealInput position[3] "位置信息---x,y,z" annotation (Placement(transformation(origin = {-290.0, -8.0},
          extent = {{-20.0, -20.0}, {20.0, 20.0}}),
          iconTransformation(origin = {-110.0, 2.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealInput angle[3] "姿态信息--roll,pitch,yaw" annotation (Placement(transformation(origin = {-290.0, -118.0},
          extent = {{-20.0, -20.0}, {20.0, 20.0}}),
          iconTransformation(origin = {-110.0, -62.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealOutput y
          "一号电机转速控制信号" annotation (Placement(transformation(origin = {280.0, 136.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}}),
            iconTransformation(origin = {110.0, 59.999999999999986},
              extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealOutput y1
          "二号电机转速控制信号" annotation (Placement(transformation(origin = {280.0, 44.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}}),
            iconTransformation(origin = {110.0, 20.666666666666657},
              extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealOutput y2
          "三号电机转速控制信号" annotation (Placement(transformation(origin = {280.0, -50.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}}),
            iconTransformation(origin = {110.0, -18.66666666666667},
              extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Interfaces.RealOutput y3
          "四号电机转速控制信号" annotation (Placement(transformation(origin = {280.0, -144.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}}),
            iconTransformation(origin = {110.0, -58.0},
              extent = {{-10.0, -10.0}, {10.0, 10.0}})));
        Modelica.Blocks.Sources.Constant const(k = 0) 
          annotation (Placement(transformation(origin = {-68.96308557177342, 136.0},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      equation
        connect(gain2.y, feedback3.u2) 
          annotation (Line(origin = {53.610508919861104, -149.8919319107595},
            points = {{-256.0, -29.0}, {-231.0, -29.0}, {-231.0, -3.0}},
            color = {0, 0, 127}));
        connect(add3_1.y, add.u1) 
          annotation (Line(origin = {146.95118178983827, 32.2855521816803},
            points = {{-3.0, 110.0}, {36.0, 110.0}},
            color = {0, 0, 127}));
        connect(add3_2.y, add1.u1) 
          annotation (Line(origin = {146.95118178983827, -5.714447818319712},
            points = {{-3.0, 56.0}, {35.0, 56.0}, {35.0, 55.0}},
            color = {0, 0, 127}));
        connect(add3_3.y, add2.u1) 
          annotation (Line(origin = {146.95118178983827, -42.71444781831971},
            points = {{-3.0, 8.0}, {12.0, 8.0}, {12.0, -1.0}, {35.0, -1.0}},
            color = {0, 0, 127}));
        connect(add3_4.y, add3.u1) 
          annotation (Line(origin = {146.95118178983827, -81.71444781831971},
            points = {{-3.0, -39.0}, {12.0, -39.0}, {12.0, -56.0}, {34.0, -56.0}},
            color = {0, 0, 127}));
        connect(feedback.y, PID1.u) 
          annotation (Line(origin = {-9.047589837435265, 139.7139393638377},
            points = {{-22.0, -4.0}, {-13.0, -4.0}, {-13.0, -3.0}},
            color = {0, 0, 127}));
        connect(feedback1.y, PID5.u) 
          annotation (Line(origin = {-1.8744491963850756, 53.89544133659771},
            points = {{-29.0, -2.0}, {-20.0, -2.0}},
            color = {0, 0, 127}));
        connect(feedback2.y, PID6.u) 
          annotation (Line(origin = {5.864782786952201, -42.06148659675134},
            points = {{-37.0, 0.0}, {-28.0, 0.0}},
            color = {0, 0, 127}));


        connect(feedback3.y, PID7.u) 
          annotation (Line(origin = {-161.74937830820016, -145.67176738111604},
            points = {{-6.0, 1.0}, {2.0, 1.0}, {2.0, 0.0}},
            color = {0, 0, 127}));
        connect(PID7.y, gain3.u) 
          annotation (Line(origin = {-135.56294479613206, -145.14130128012883},
            points = {{-1.0, 0.0}, {14.0, 0.0}},
            color = {0, 0, 127}));
        connect(gain3.y, add3.u2) 
          annotation (Line(origin = {57.977999938512994, -148.58583127373336},
            points = {{-162.0, 4.0}, {101.0, 4.0}, {101.0, -1.0}, {123.0, -1.0}},
            color = {0, 0, 127}));
        connect(gain3.y, add2.u2) 
          annotation (Line(origin = {204.07901205363325, -160.393356432471},
            points = {{-308.0, 16.0}, {-45.0, 16.0}, {-45.0, 105.0}, {-22.0, 105.0}},
            color = {0, 0, 127}));
        connect(gain3.y, add1.u2) 
          annotation (Line(origin = {204.07901205363325, -146.393356432471},
            points = {{-308.0, 2.0}, {-45.0, 2.0}, {-45.0, 184.0}, {-22.0, 184.0}},
            color = {0, 0, 127}));
        connect(gain3.y, add.u2) 
          annotation (Line(origin = {204.07901205363325, -131.393356432471},
            points = {{-308.0, -13.0}, {-45.0, -13.0}, {-45.0, 262.0}, {-21.0, 262.0}},
            color = {0, 0, 127}));
        connect(feedback5.y, PID4.u) 
          annotation (Line(origin = {-135.32525239618457, -30.028667121554385},
            points = {{-31.0, -13.0}, {-24.0, -13.0}},
            color = {0, 0, 127}));
        connect(feedback4.y, PID3.u) 
          annotation (Line(origin = {-151.46206049556133, 51.98219706603876},
            points = {{-14.0, 3.0}, {-8.0, 3.0}, {-8.0, 2.0}},
            color = {0, 0, 127}));
        connect(gain4.y, feedback5.u2) 
          annotation (Line(origin = {-175.42140257154261, -75.53967302362271},
            points = {{-26.0, 1.0}, {0.0, 1.0}, {0.0, 24.0}},
            color = {0, 0, 127}));
        connect(PID4.y, gain5.u) 
          annotation (Line(origin = {-135.73433357702584, -44.19664220500482},
            points = {{-1.0, 1.0}, {13.0, 1.0}, {13.0, 0.0}},
            color = {0, 0, 127}));
        connect(gain5.y, limiter2.u) 
          annotation (Line(origin = {-110.02331656999085, -44.19664220500482},
            points = {{11.0, 0.0}, {29.0, 0.0}, {29.0, 1.0}},
            color = {0, 0, 127}));
        connect(limiter2.y, feedback2.u1) 
          annotation (Line(origin = {41.53983579048576, -78.62459613738737},
            points = {{-100.0, 36.0}, {-90.0, 36.0}, {-90.0, 37.0}},
            color = {0, 0, 127}));
        connect(limiter1.y, feedback1.u1) 
          annotation (Line(origin = {11.888478860152016, 25.15658168995462},
            points = {{-71.0, 27.0}, {-60.0, 27.0}},
            color = {0, 0, 127}));
        connect(PID3.y, gain6.u) 
          annotation (Line(origin = {-169.1959584533509, 51.52860783033083},
            points = {{32.0, 3.0}, {47.0, 3.0}, {47.0, 2.0}},
            color = {0, 0, 127}));
        connect(gain6.y, limiter1.u) 
          annotation (Line(origin = {-125.48494144631586, 51.52860783033083},
            points = {{26.0, 2.0}, {43.0, 2.0}, {43.0, 1.0}},
            color = {0, 0, 127}));
        connect(gain7.y, feedback4.u2) 
          annotation (Line(origin = {-179.56687759540455, 32.5558016868566},
            points = {{-22.0, -10.0}, {5.0, -10.0}, {5.0, 14.0}},
            color = {0, 0, 127}));
        connect(gain12.y, add3_1.u1) 
          annotation (Line(origin = {95.08607863974495, 145.47608926673752},
            points = {{-34.0, -9.0}, {-16.0, -9.0}, {-16.0, 5.0}, {26.0, 5.0}},
            color = {0, 0, 127}));
        connect(add3_3.u1, gain12.y) 
          annotation (Line(origin = {95.08607863974495, 56.47608926673752},
            points = {{26.0, -83.0}, {-16.0, -83.0}, {-16.0, 80.0}, {-34.0, 80.0}},
            color = {0, 0, 127}));
        connect(add3_4.u1, gain12.y) 
          annotation (Line(origin = {95.08607863974495, 13.476089266737517},
            points = {{26.0, -126.0}, {-16.0, -126.0}, {-16.0, 123.0}, {-34.0, 123.0}},
            color = {0, 0, 127}));
        connect(gain.y, add3_1.u2) 
          annotation (Line(origin = {71.0, 98.0},
            points = {{-10.0, -46.0}, {8.0, -46.0}, {8.0, 45.0}, {50.0, 45.0}},
            color = {0, 0, 127}));
        connect(add3_2.u2, gain.y) 
          annotation (Line(origin = {71.0, 52.0},
            points = {{50.0, -2.0}, {-10.0, -2.0}, {-10.0, 0.0}},
            color = {0, 0, 127}));
        connect(add3_3.u2, gain.y) 
          annotation (Line(origin = {71.0, 9.0},
            points = {{50.0, -44.0}, {8.0, -44.0}, {8.0, 43.0}, {-10.0, 43.0}},
            color = {0, 0, 127}));
        connect(add3_4.u2, gain.y) 
          annotation (Line(origin = {71.0, -34.0},
            points = {{50.0, -87.0}, {8.0, -87.0}, {8.0, 86.0}, {-10.0, 86.0}},
            color = {0, 0, 127}));
        connect(gain1.y, add3_1.u3) 
          annotation (Line(origin = {71.0, 47.0},
            points = {{-10.0, -88.0}, {8.0, -88.0}, {8.0, 88.0}, {50.0, 88.0}},
            color = {0, 0, 127}));
        connect(add3_2.u3, gain1.y) 
          annotation (Line(origin = {71.0, 0.0},
            points = {{50.0, 42.0}, {50.0, 41.0}, {8.0, 41.0}, {8.0, -41.0}, {-10.0, -41.0}},
            color = {0, 0, 127}));
        connect(add3_3.u3, gain1.y) 
          annotation (Line(origin = {70.0, -42.0},
            points = {{51.0, -1.0}, {9.0, -1.0}, {9.0, 1.0}, {-9.0, 1.0}},
            color = {0, 0, 127}));
        connect(add3_4.u3, gain1.y) 
          annotation (Line(origin = {71.0, -87.0},
            points = {{50.0, -42.0}, {8.0, -42.0}, {8.0, 46.0}, {-10.0, 46.0}},
            color = {0, 0, 127}));
        connect(add3_2.u1, gain12.y) 
          annotation (Line(origin = {95.08607863974495, 99.47608926673752},
            points = {{26.0, -42.0}, {-16.0, -42.0}, {-16.0, 37.0}, {-34.0, 37.0}},
            color = {0, 0, 127}));
        connect(gain7.u, position[1]) 
          annotation (Line(origin = {-247.0, -29.0},
            points = {{23.0, 52.0}, {7.0, 52.0}, {7.0, 21.0}, {-43.0, 21.0}},
            color = {0, 0, 127}));
        connect(gain4.u, position[2]) 
          annotation (Line(origin = {-247.0, -78.0},
            points = {{23.0, 3.0}, {7.0, 3.0}, {7.0, 70.0}, {-43.0, 70.0}},
            color = {0, 0, 127}));
        connect(gain2.u, position[3]) 
          annotation (Line(origin = {-247.0, -130.0},
            points = {{23.0, -49.0}, {7.0, -49.0}, {7.0, 122.0}, {-43.0, 122.0}},
            color = {0, 0, 127}));
        connect(feedback.u2, angle[3]) 
          annotation (Line(origin = {-145.0, 25.0},
            points = {{105.0, 103.0}, {105.0, 85.0}, {-95.0, 85.0}, {-95.0, -143.0}, {-145.0, -143.0}},
            color = {0, 0, 127}));
        connect(feedback1.u2, angle[2]) 
          annotation (Line(origin = {-149.0, -18.0},
            points = {{109.0, 62.0}, {110.0, 62.0}, {110.0, 12.0}, {-91.0, 12.0}, {-91.0, -100.0}, {-141.0, -100.0}},
            color = {0, 0, 127}));
        connect(gain13.u, angle[1]) 
          annotation (Line(origin = {-149.0, -73.0},
            points = {{24.0, -23.0}, {-91.0, -23.0}, {-91.0, -45.0}, {-141.0, -45.0}},
            color = {0, 0, 127}));
        connect(add3.y, gain11.u) 
          annotation (Line(origin = {211.0, -144.0},
            points = {{-7.0, 0.0}, {7.0, 0.0}},
            color = {0, 0, 127}));
        connect(add2.y, gain10.u) 
          annotation (Line(origin = {212.0, -50.0},
            points = {{-7.0, 0.0}, {6.0, 0.0}},
            color = {0, 0, 127}));
        connect(add1.y, gain9.u) 
          annotation (Line(origin = {214.0, 43.0},
            points = {{-9.0, 0.0}, {-8.0, 0.0}, {-8.0, 1.0}, {4.0, 1.0}},
            color = {0, 0, 127}));
        connect(add.y, gain8.u) 
          annotation (Line(origin = {213.0, 136.0},
            points = {{-7.0, 0.0}, {5.0, 0.0}},
            color = {0, 0, 127}));
        connect(gain8.y, y) 
          annotation (Line(origin = {256.0, 67.0},
            points = {{-15.0, 69.0}, {24.0, 69.0}},
            color = {0, 0, 127}));
        connect(gain9.y, y1) 
          annotation (Line(origin = {256.0, 21.0},
            points = {{-15.0, 23.0}, {24.0, 23.0}},
            color = {0, 0, 127}));
        connect(gain10.y, y2) 
          annotation (Line(origin = {256.0, -26.0},
            points = {{-15.0, -24.0}, {24.0, -24.0}},
            color = {0, 0, 127}));
        connect(gain11.y, y3) 
          annotation (Line(origin = {256.0, -73.0},
            points = {{-15.0, -71.0}, {24.0, -71.0}},
            color = {0, 0, 127}));

        connect(gain13.y, feedback2.u2) 
          annotation (Line(origin = {-63.0, -73.0},
            points = {{-39.0, -23.0}, {23.0, -23.0}, {23.0, 23.0}},
            color = {0, 0, 127}));
        connect(PID5.y, limiter3.u) 
          annotation (Line(origin = {3.0, 50.0},
            points = {{-2.0, 2.0}, {5.0, 2.0}},
            color = {0, 0, 127}));
        connect(limiter3.y, gain.u) 
          annotation (Line(origin = {29.0, 50.0},
            points = {{2.0, 2.0}, {9.0, 2.0}},
            color = {0, 0, 127}));
        connect(PID6.y, limiter4.u) 
          annotation (Line(origin = {5.0, -42.0},
            points = {{-4.0, 0.0}, {3.0, 0.0}, {3.0, 1.0}},
            color = {0, 0, 127}));
        connect(limiter4.y, gain1.u) 
          annotation (Line(origin = {35.0, -42.0},
            points = {{-4.0, 1.0}, {-4.0, 0.0}, {3.0, 0.0}, {3.0, 1.0}},
            color = {0, 0, 127}));
        connect(PID1.y, limiter5.u) 
          annotation (Line(origin = {4.0, 136.0},
            points = {{-3.0, 0.0}, {4.0, 0.0}},
            color = {0, 0, 127}));
        connect(limiter5.y, gain12.u) 
          annotation (Line(origin = {35.0, 136.0},
            points = {{-4.0, 0.0}, {3.0, 0.0}},
            color = {0, 0, 127}));
        connect(feedback.u1, const.y) 
          annotation (Line(origin = {-53.0, 136.0},
            points = {{5.0, 0.0}, {-4.963085571773419, 0.0}},
            color = {0, 0, 127}));
        connect(position_command[1], feedback4.u1) 
          annotation (Line(origin = {-234.0, 75.0},
            points = {{-52.0, 19.0}, {-6.0, 19.0}, {-6.0, -20.0}, {52.0, -20.0}},
            color = {0, 0, 127}));
        connect(position_command[2], feedback5.u1) 
          annotation (Line(origin = {-235.0, 26.0},
            points = {{-51.0, 68.0}, {-5.0, 68.0}, {-5.0, -69.0}, {51.0, -69.0}},
            color = {0, 0, 127}));
        connect(position_command[3], feedback3.u1) 
          annotation (Line(origin = {-235.0, -27.0},
            points = {{-51.0, 121.0}, {-5.0, 121.0}, {-5.0, -118.0}, {50.0, -118.0}},
            color = {0, 0, 127}));
      end Controller;
    end Controller;
  end Blocks;
  package Electricals "电气系统"
    extends Modelica.Icons.Package;
    annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
      preserveAspectRatio = false,
      grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.0, 0.0},
      lineColor = {128, 128, 128},
      extent = {{-100.0, -100.0}, {100.0, 100.0}},
      radius = 25.0), Rectangle(origin = {20.3125, 82.8571},
      extent = {{-45.3125, -57.8571}, {4.6875, -27.8571}}), Line(origin = {8.0, 48.0},
      points = {{32.0, -58.0}, {72.0, -58.0}}), Line(origin = {9.0, 54.0},
      points = {{31.0, -49.0}, {71.0, -49.0}}), Line(origin = {-2.0, 55.0},
      points = {{-83.0, -50.0}, {-33.0, -50.0}}), Line(origin = {-3.0, 45.0},
      points = {{-72.0, -55.0}, {-42.0, -55.0}}), Line(origin = {1.0, 50.0},
      points = {{-61.0, -45.0}, {-61.0, -10.0}, {-26.0, -10.0}}), Line(origin = {7.0, 50.0},
      points = {{18.0, -10.0}, {53.0, -10.0}, {53.0, -45.0}}), Line(origin = {6.2593, 48.0},
      points = {{53.7407, -58.0}, {53.7407, -93.0}, {-66.2593, -93.0}, {-66.2593, -58.0}})}));
    model Actuator "电机模型"
      replaceable parameter Modelica.Electrical.Machines.Examples.ControlledDCDrives.Utilities.DriveDataDCPM driveData constrainedby ControlledDCDrives.Utilities.DriveDataDCPM 
        annotation (Placement(transformation(origin = {-78.0, 38.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(transformation(origin = {82.00000000000003, -53.99999999999999},
          extent = {{-10.0, -10.0}, {10.0, 10.0}},
          rotation = 270.0)));
      Modelica.Electrical.Machines.BasicMachines.DCMachines.DC_PermanentMagnet dcpm(
        TaOperational = driveData.motorData.TaNominal,
        VaNominal = driveData.motorData.VaNominal,
        IaNominal = driveData.motorData.IaNominal,
        wNominal = driveData.motorData.wNominal,
        TaNominal = driveData.motorData.TaNominal,
        Ra = driveData.motorData.Ra,
        TaRef = driveData.motorData.TaRef,
        La = driveData.motorData.La,
        Jr = driveData.motorData.Jr,
        frictionParameters = driveData.motorData.frictionParameters,
        phiMechanical(fixed = true),
        wMechanical(fixed = true),
        coreParameters = driveData.motorData.coreParameters,
        strayLoadParameters = driveData.motorData.strayLoadParameters,
        brushParameters = driveData.motorData.brushParameters,
        ia(fixed = true),
        Js = driveData.motorData.Js,
        alpha20a = driveData.motorData.alpha20a) 
        annotation (Placement(transformation(origin = {62.0, -24.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Electrical.Machines.Examples.ControlledDCDrives.Utilities.DcdcInverter armatureInverter(
        fS = driveData.fS,
        Td = driveData.Td,
        Tmf = driveData.Tmf,
        VMax = driveData.VaMax) 
        annotation (Placement(transformation(origin = {62.0, 6.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Electrical.Machines.Examples.ControlledDCDrives.Utilities.Battery source(
        INominal = driveData.motorData.IaNominal, V0 = driveData.VBat) 
        annotation (Placement(transformation(origin = {62.0, 48.0},
          extent = {{10.0, -10.0}, {-10.0, 10.0}},
          rotation = 180.0)));
      Modelica.Electrical.Machines.Examples.ControlledDCDrives.Utilities.LimitedPI currentController(
        constantLimits = false,
        k = driveData.kpI,
        Ti = driveData.TiI,
        KFF = driveData.kPhi,
        initType = Modelica.Blocks.Types.Init.InitialOutput,
        useFF = true) 
        annotation (Placement(transformation(origin = {-8.0, 6.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Math.Gain tau2i(k = 1 / driveData.kPhi) annotation (Placement(transformation(origin = {-38.0, 6.0},
        extent = {{10.0, -10.0}, {-10.0, 10.0}},
        rotation = 180.0)));
      Modelica.Electrical.Machines.Examples.ControlledDCDrives.Utilities.LimitedPI speedController(
        initType = Modelica.Blocks.Types.Init.InitialOutput,
        k = driveData.kpw,
        Ti = driveData.Tiw,
        constantLimits = true,
        yMax = driveData.tauMax) 
        annotation (Placement(transformation(origin = {-78.0, 6.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a 
        annotation (Placement(transformation(origin = {120.0, -24.0},
          extent = {{-2.0, -2.0}, {2.0, 2.0}}),
          iconTransformation(origin = {99.30272050638656, 2.0655011867162516},
            extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0}), graphics = {Rectangle(origin = {-0.21868787276341806, 0.44532803180914016},
        lineColor = {200, 200, 200},
        fillColor = {248, 248, 248},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-100.0, -100.0}, {100.0, 100.0}},
        radius = 25.0), Rectangle(origin = {-24.71292246520875, 1.959443339960238},
        lineColor = {82, 0, 2},
        fillColor = {252, 37, 57},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-65.0, -50.0}, {65.0, 50.0}},
        radius = 10.0), Polygon(origin = {-24.71292246520875, -58.04055666003976},
        fillColor = {64, 64, 64},
        fillPattern = FillPattern.Solid,
        points = {{-65.0, -30.0}, {-55.0, -30.0}, {-25.0, 40.0}, {25.0, 40.0}, {55.0, -30.0}, {65.0, -30.0}, {65.0, -40.0}, {-65.0, -40.0}, {-65.0, -30.0}}), Rectangle(origin = {70.28707753479125, 1.959443339960238},
        lineColor = {64, 64, 64},
        fillColor = {255, 255, 255},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-30.0, -10.0}, {30.0, 10.0}})}),
        Diagram(coordinateSystem(extent = {{-120.0, -100.0}, {120.0, 100.0}},
          grid = {2.0, 2.0})));
      Modelica.Blocks.Interfaces.RealInput u 
        annotation (Placement(transformation(origin = {-119.688, 5.68798},
          extent = {{-4.31202, -4.31202}, {4.31202, 4.31202}}),
          iconTransformation(origin = {-118.37598000000001, 3.0000000000000036},
            extent = {{-16.999999999999986, -17.000000000000004}, {17.000000000000014, 16.999999999999996}})));
    equation
      connect(speedSensor.flange, dcpm.flange) 
        annotation (Line(origin = {77.0, -34.0},
          points = {{5.0, -10.0}, {5.0, 10.0}, {-5.0, 10.0}}));
      connect(armatureInverter.pin_nMot, dcpm.pin_an) 
        annotation (Line(origin = {56.0, -9.0},
          points = {{0.0, 5.0}, {0.0, -5.0}},
          color = {0, 0, 255}));
      connect(armatureInverter.pin_pMot, dcpm.pin_ap) 
        annotation (Line(origin = {68.0, -9.0},
          points = {{0.0, 5.0}, {0.0, -5.0}},
          color = {0, 0, 255}));
      connect(armatureInverter.vDC, currentController.yMaxVar) 
        annotation (Line(origin = {27.5, 12.0},
          points = {{24.0, 0.0}, {-24.0, 0.0}},
          color = {0, 0, 127}));
      connect(armatureInverter.vRef, currentController.y) 
        annotation (Line(origin = {26.5, 6.0},
          points = {{24.0, 0.0}, {-24.0, 0.0}},
          color = {0, 0, 127}));
      connect(armatureInverter.iMot, currentController.u_m) 
        annotation (Line(origin = {18.5, -7.0},
          points = {{33.0, 7.0}, {3.0, 7.0}, {3.0, -25.0}, {-33.0, -25.0}, {-33.0, 1.0}},
          color = {0, 0, 127}));
      connect(speedSensor.w, currentController.feedForward) 
        annotation (Line(origin = {37.0, -40.0},
          points = {{45.0, -25.0}, {45.0, -34.0}, {-45.0, -34.0}, {-45.0, 34.0}},
          color = {0, 0, 127}));
      connect(tau2i.y, currentController.u) 
        annotation (Line(origin = {-23.5, 6.0},
          points = {{-4.0, 0.0}, {4.0, 0.0}},
          color = {0, 0, 127}));
      connect(source.pin_n, armatureInverter.pin_nBat) 
        annotation (Line(origin = {56.0, 51.0},
          points = {{0.0, -13.0}, {0.0, -35.0}},
          color = {0, 0, 255}));
      connect(source.pin_p, armatureInverter.pin_pBat) 
        annotation (Line(origin = {68.0, 51.0},
          points = {{0.0, -13.0}, {0.0, -35.0}},
          color = {0, 0, 255}));
      connect(speedSensor.w, speedController.u_m) 
        annotation (Line(origin = {-1.0, -40.0},
          points = {{83.0, -25.0}, {83.0, -34.0}, {-83.0, -34.0}, {-83.0, 34.0}},
          color = {0, 0, 127}));
      connect(speedController.y, tau2i.u) 
        annotation (Line(origin = {-58.5, 6.0},
          points = {{-9.0, 0.0}, {9.0, 0.0}},
          color = {0, 0, 127}));

      connect(dcpm.flange, flange_a) 
        annotation (Line(origin = {82.0, -39.0},
          points = {{-10.0, 15.0}, {38.0, 15.0}},
          color = {0, 0, 0}));
      connect(u, speedController.u) 
        annotation (Line(origin = {-109.0, 5.0},
          points = {{-11.0, 1.0}, {19.0, 1.0}},
          color = {0, 0, 127}));
    end Actuator;
  end Electricals;
  package GroundModel "地面模型"

    model TouchModel "接触模型"
      //接触参数设定
      import SI = Modelica.SIunits;
      parameter Real n(unit = "1") = 1.5 "非线性指数" 
        annotation (Dialog(group = "接触参数设置", enable = ForceType == 2));
      parameter Modelica.Units.SI.Distance delta(displayUnit = "mm") = 0.0001 "穿透深度阈值" 
        annotation (Dialog(group = "接触参数设置", enable = ForceType == 2));
      parameter Modelica.Units.SI.TranslationalDampingConstant C = 10000 "接触阻尼" 
        annotation (Dialog(group = "接触参数设置", enable = ForceType == 2));
      parameter Modelica.Units.SI.TranslationalSpringConstant K = 1e5 "接触刚度" 
        annotation (Dialog(group = "接触参数设置", enable = ForceType == 2));
      parameter Modelica.Units.SI.Radius R1 = 0.001 "接触半径" 
        annotation (Dialog(group = "接触参数设置", enable = ForceType == 2));
      //摩擦力参数设定
      parameter Modelica.Units.SI.Velocity V_s = 0 "最大静摩擦对应的相对滑移速度" 
        annotation (Dialog(group = "摩擦力参数", enable = ForceType == 2));
      parameter Modelica.Units.SI.CoefficientOfFriction Cst = 0 "静摩擦系数" 
        annotation (Dialog(group = "摩擦力参数", enable = ForceType == 2));
      parameter Modelica.Units.SI.Velocity Vtr = 0 "动摩擦对应的相对滑移速度" 
        annotation (Dialog(group = "摩擦力参数", enable = ForceType == 2));
      parameter Modelica.Units.SI.CoefficientOfFriction Cdy = 0 "动摩擦系数" 
        annotation (Dialog(group = "摩擦力参数", enable = ForceType == 2));
      //状态变量定义
      Modelica.Units.SI.Position P[3] "两物体质心相对位置矢量";
      Modelica.Units.SI.Force F[3] "接触弹力矢量值";
      Modelica.Units.SI.Force f[3] "接触摩擦力矢量值";
      Modelica.Units.SI.Force F_C "接触阻尼系数";
      Modelica.Units.SI.Velocity V[3] "接触点速度矢量";
      Modelica.Units.SI.Distance x "穿透深度";
      //模型实例化
      Modelica.Mechanics.MultiBody.Forces.WorldForce Fs(resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_resolve) "合外力（除重力）" annotation (Placement(transformation(origin = {2.0, 0.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}},
          rotation = 360.0)));
      annotation (Diagram(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0})),
        Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
          grid = {2.0, 2.0}), graphics = {Rectangle(origin = {0.0, 0.0},
          lineColor = {0, 0, 255},
          fillColor = {255, 255, 255},
          fillPattern = FillPattern.Solid,
          extent = {{-100.0, 100.0}, {100.0, -100.0}}), Rectangle(origin = {0.0, -60.0},
          lineColor = {85, 85, 255},
          fillColor = {255, 255, 255},
          fillPattern = FillPattern.HorizontalCylinder,
          extent = {{-100.0, 40.0}, {100.0, -40.0}}), Rectangle(origin = {0.0, -80.0},
          fillColor = {255, 255, 255},
          pattern = LinePattern.None,
          fillPattern = FillPattern.Solid,
          extent = {{-100.0, 20.0}, {100.0, -20.0}}), Ellipse(origin = {1.0, 46.0},
          rotation = 90.0,
          lineColor = {0, 85, 255},
          fillColor = {0, 0, 0},
          fillPattern = FillPattern.Sphere,
          extent = {{-38.0, 39.0}, {38.0, -39.0}}), Text(origin = {0.0, 129.0},
          rotation = 360.0,
          lineColor = {0, 0, 0},
          extent = {{100.0, -35.0}, {-100.0, 35.0}},
          textString = "%name",
          textColor = {0, 0, 0}), Text(origin = {2.0, -123.0},
          rotation = 360.0,
          lineColor = {0, 0, 0},
          extent = {{100.0, -35.0}, {-100.0, 35.0}},
          textString = "点面接触模型",
          textStyle = {TextStyle.None},
          textColor = {0, 0, 0})}));
      Modelica.Mechanics.MultiBody.Sensors.RelativePosition R_p(resolveInFrame = Modelica.Mechanics.MultiBody.Types.ResolveInFrameAB.frame_a)
        "相对位置矢量" annotation (Placement(transformation(origin = {0.0, 40.0},
          extent = {{-10.0, 10.0}, {10.0, -10.0}})));

      Modelica.Mechanics.MultiBody.Sensors.RelativeVelocity R_v(resolveInFrame = Modelica.Mechanics.MultiBody.Types.ResolveInFrameAB.frame_a)
        "相对速度矢量" annotation (Placement(transformation(origin = {4.440892098500626e-16, -40.0},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a 
        annotation (Placement(transformation(origin = {-100.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}},
          rotation = 180.0)));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_b frame_b 
        annotation (Placement(transformation(origin = {100.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}},
          rotation = 180.0)));
      //方程
    equation
      //接触判定条件方程
      x = max((R1 - P[3]), 0);
      //接触阻尼方程
      F_C = QuadrotorModel.Utilities.Functions.Step(x, 0, 0, delta, C);
      //接触弹力方程
      F[1] = 0;
      F[2] = 0;
      F[3] = if x > 0 then max((K * x ^ n - F_C * V[3]), 0) else 0;
      //接触摩擦力方程
      f[1] = if abs(V[1]) > 0 then QuadrotorModel.Utilities.Functions.Friction(F[3], V[1], V_s, Cst, Vtr, Cdy) else 0;
      f[2] = if abs(V[2]) > 0 then QuadrotorModel.Utilities.Functions.Friction(F[3], V[3], V_s, Cst, Vtr, Cdy) else 0;
      f[3] = 0 * V[3];
      //参数传递方程
      V = R_v.v_rel;
      P = R_p.r_rel;
      F - f = Fs.force;
      //连接方程
      connect(Fs.frame_b, frame_b) 
        annotation (Line(origin = {56.0, 0.0},
          points = {{-44.0, 0.0}, {44.0, 0.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(R_p.frame_b, frame_b) 
        annotation (Line(origin = {57.0, 13.0},
          points = {{-47.0, 27.0}, {3.0, 27.0}, {3.0, -13.0}, {43.0, -13.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(R_v.frame_b, frame_b) 
        annotation (Line(origin = {55.0, -24.0},
          points = {{-45.0, -16.0}, {5.0, -16.0}, {5.0, 24.0}, {45.0, 24.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(R_v.frame_a, frame_a) 
        annotation (Line(origin = {-55.0, -20.0},
          points = {{45.0, -20.0}, {-5.0, -20.0}, {-5.0, 20.0}, {-45.0, 20.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(R_p.frame_a, frame_a) 
        annotation (Line(origin = {-55.0, 20.0},
          points = {{45.0, 20.0}, {-5.0, 20.0}, {-5.0, -20.0}, {-45.0, -20.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(Fs.frame_resolve, frame_a) 
        annotation (Line(origin = {-49.0, -10.0},
          points = {{51.0, 0.0}, {51.0, -10.0}, {-11.0, -10.0}, {-11.0, 10.0}, {-51.0, 10.0}},
          color = {95, 95, 95},
          pattern = LinePattern.Dot));
    end TouchModel;
    annotation (Diagram(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
      grid = {2.0, 2.0})),
      Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        preserveAspectRatio = false,
        grid = {2.0, 2.0}), graphics = {Line(origin = {2.0, 0.0},
        points = {{-62.0, 0.0}, {62.0, 0.0}}), Line(origin = {0.0, -20.0},
        points = {{-40.0, 0.0}, {40.0, 0.0}}), Line(origin = {0.0, -40.0},
        points = {{-20.0, 0.0}, {20.0, 0.0}}), Ellipse(origin = {1.0, 21.0},
        fillColor = {255, 255, 255},
        extent = {{-21.0, 21.0}, {21.0, -21.0}})}));
    extends Modelica.Icons.Package;
  end GroundModel;

  package Sensors "传感器系统"
    extends Modelica.Icons.SensorsPackage;
    model Sensors
      AbsoluteAngles absoluteAngles 
        annotation (Placement(transformation(origin = {0.0, 20.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));



      Modelica.Mechanics.MultiBody.Interfaces.Frame_a frame_a 
        annotation (Placement(transformation(origin = {-100.0, 0.0},
          extent = {{-16.0, -16.0}, {16.0, 16.0}}),
          iconTransformation(origin = {-100.0, 0.0},
            extent = {{-16.0, -16.0}, {16.0, 16.0}})));
      Modelica.Blocks.Interfaces.RealOutput AngleMea[3] "角度测量信号" annotation (Placement(transformation(origin = {110.0, 20.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {110.0, 40.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      Modelica.Blocks.Interfaces.RealOutput PosMea[3] "位置测量信号" annotation (Placement(transformation(origin = {110.0, -24.0},
        extent = {{-10.0, -10.0}, {10.0, 10.0}}),
        iconTransformation(origin = {110.0, -38.0},
          extent = {{-10.0, -10.0}, {10.0, 10.0}})));
      annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0}), graphics = {Rectangle(origin = {-7.105427357601002e-15, 0.0},
        lineColor = {200, 200, 200},
        fillColor = {248, 248, 248},
        fillPattern = FillPattern.HorizontalCylinder,
        extent = {{-100.0, -100.0}, {100.0, 100.0}},
        radius = 25.0), Text(origin = {6.0, 0.0},
        lineColor = {136, 136, 136},
        extent = {{-68.0, 60.0}, {68.0, -60.0}},
        textString = "Sensors",
        textStyle = {TextStyle.None},
        textColor = {136, 136, 136})}));
      AbsolutePosition absolutePosition1(
        resolveInFrame = Modelica.Mechanics.MultiBody.Types.ResolveInFrameA.world) annotation (Placement(transformation(origin = {0.0, -23.974440894568694},
          extent = {{10.0, 10.0}, {-10.0, -10.0}},
          rotation = 180.0)));
    equation
      connect(frame_a, absoluteAngles.frame_a) 
        annotation (Line(origin = {-55.0, 10.0},
          points = {{-45.0, -10.0}, {-5.0, -10.0}, {-5.0, 10.0}, {45.0, 10.0}},
          color = {95, 95, 95},
          thickness = 0.5));

      connect(absoluteAngles.angles, AngleMea) 
        annotation (Line(origin = {61.0, 19.0},
          points = {{-50.0, 1.0}, {49.0, 1.0}},
          color = {0, 0, 127}));
      connect(absolutePosition1.frame_a, frame_a) 
        annotation (Line(origin = {-55.0, -12.0},
          points = {{45.0, -12.0}, {-5.0, -12.0}, {-5.0, 12.0}, {-45.0, 12.0}},
          color = {95, 95, 95},
          thickness = 0.5));
      connect(absolutePosition1.r, PosMea) 
        annotation (Line(origin = {61.0, -23.0},
          points = {{-50.0, -1.0}, {49.0, -1.0}},
          color = {0, 0, 127}));
    end Sensors;
    model AbsoluteAngles
      "Measure absolute angles between frame connector and the world frame"
      extends Modelica.Mechanics.MultiBody.Sensors.Internal.PartialAbsoluteSensor;
      import SI = Modelica.SIunits;
      Modelica.Blocks.Interfaces.RealOutput angles[3](
        each final quantity = "Angle",
        each final unit = "rad",
        each displayUnit = "deg")
        "Angles to rotate world frame into frame_a via 'sequence'" 
        annotation (Placement(transformation(
          origin = {110, 0},
          extent = {{-10, -10}, {10, 10}})));
      parameter Modelica.Mechanics.MultiBody.Types.RotationSequence sequence(
        min = {1, 1, 1},
        max = {3, 3, 3}) = {1, 2, 3}
        "Angles are returned to rotate world frame around axes sequence[1], sequence[2] and finally sequence[3] into frame_a" 
        annotation (Evaluate = true);
      parameter Modelica.Units.SI.Angle guessAngle1 = 0
        "Select angles[1] such that abs(angles[1] - guessAngle1) is a minimum";
    equation
      frame_a.f = zeros(3);
      frame_a.t = zeros(3);
      angles = Modelica.Mechanics.MultiBody.Frames.axesRotationsAngles(
        frame_a.R,
        sequence,
        guessAngle1);
      annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
        grid = {2.0, 2.0}), graphics = {Text(origin = {4.5, 122.0},
        lineColor = {0, 0, 255},
        extent = {{-130.5, -24.0}, {130.5, 24.0}},
        textString = "%name",
        textStyle = {TextStyle.None},
        textColor = {0, 0, 255}), Line(origin = {85.0, 0.0},
        points = {{-15.0, 0.0}, {15.0, 0.0}},
        color = {0, 0, 127}), Text(origin = {117.0, -33.0},
        extent = {{-55.0, 11.0}, {55.0, -11.0}},
        textString = "angles")}),
        Documentation(info = "<html>
<p>
This model determines the 3 angles to rotate the world frame
into frame_a along the axes defined by parameter <strong>sequence</strong>.
For example, if sequence = {3,1,2} then the world frame is
rotated around angles[1] along the z-axis, afterwards it is rotated
around angles[2] along the x-axis, and finally it is rotated around
angles[3] along the y-axis and is then identical to frame_a.
The 3 angles are returned in the range
</p>
<pre>
    -<font face=\"Symbol\">p</font> &lt;= angles[i] &lt;= <font face=\"Symbol\">p</font>
</pre>
<p>
There are <strong>two solutions</strong> for \"angles[1]\" in this range.
Via parameter <strong>guessAngle1</strong> (default = 0) the
returned solution is selected such that |angles[1] - guessAngle1| is
minimal. The transformation matrix between the world frame and
frame_a may be in a singular configuration with respect to \"sequence\", i.e.,
there is an infinite number of angle values leading to the same relative
transformation matrix. In this case, the returned solution is
selected by setting angles[1] = guessAngle1. Then angles[2]
and angles[3] can be uniquely determined in the above range.
</p>
<p>
The parameter <strong>sequence</strong> has the restriction that
only values 1,2,3 can be used and that sequence[1] &ne; sequence[2]
and sequence[2] &ne; sequence[3]. Often used values are:
</p>
<pre>
  sequence = <strong>{1,2,3}</strong>  // Cardan or Tait-Bryan angle sequence
           = <strong>{3,1,3}</strong>  // Euler angle sequence
           = <strong>{3,2,1}</strong>
</pre>
</html>"));
    end AbsoluteAngles;
    model AbsolutePosition
      "Measure absolute position vector of the origin of a frame connector"
      extends Modelica.Mechanics.MultiBody.Sensors.Internal.PartialAbsoluteSensor;

      Modelica.Blocks.Interfaces.RealOutput r[3](
        each final quantity = "Length",
        each final unit = "m")
        "Absolute position vector resolved in frame defined by resolveInFrame" 
        annotation (Placement(transformation(
          extent = {{-10, -10}, {10, 10}},
          origin = {110, 0})));
      Modelica.Mechanics.MultiBody.Interfaces.Frame_resolve frame_resolve if 
        resolveInFrame == Modelica.Mechanics.MultiBody.Types.ResolveInFrameA.frame_resolve
        "Coordinate system in which output vector r is optionally resolved" 
        annotation (Placement(transformation(extent = {{-16, -16}, {16, 16}},
          rotation = -90,
          origin = {0, -100})));

      parameter Modelica.Mechanics.MultiBody.Types.ResolveInFrameA resolveInFrame =
        Modelica.Mechanics.MultiBody.Types.ResolveInFrameA.frame_a
        "Frame in which output vector r shall be resolved (world, frame_a, or frame_resolve)";
    protected
      Modelica.Mechanics.MultiBody.Sensors.Internal.BasicAbsolutePosition position(resolveInFrame = resolveInFrame) 
        annotation (Placement(transformation(extent = {{-10, -10}, {10, 10}})));

      Modelica.Mechanics.MultiBody.Interfaces.ZeroPosition zeroPosition if 
        not (resolveInFrame == Modelica.Mechanics.MultiBody.Types.ResolveInFrameA.frame_resolve) 
        annotation (Placement(transformation(extent = {{20, -40}, {40, -20}})));
    equation
      connect(position.frame_resolve, frame_resolve) annotation (Line(
        points = {{0, -10}, {0, -100}},
        color = {95, 95, 95},
        pattern = LinePattern.Dot));
      connect(zeroPosition.frame_resolve, position.frame_resolve) 
        annotation (Line(
          points = {{20, -30}, {0, -30}, {0, -10}},
          color = {95, 95, 95},
          pattern = LinePattern.Dot));
      connect(position.r, r) annotation (Line(
        points = {{11, 0}, {110, 0}}, color = {0, 0, 127}));
      connect(position.frame_a, frame_a) annotation (Line(
        points = {{-10, 0}, {-100, 0}},
        color = {95, 95, 95},
        thickness = 0.5));
      annotation (Icon(coordinateSystem(
        preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {
        Line(
        points = {{70, 0}, {100, 0}},
        color = {0, 0, 127}),
        Text(
        extent = {{-127, 95}, {134, 143}},
        textString = "%name",
        lineColor = {0, 0, 255}),
        Text(
        extent = {{62, 46}, {146, 16}},
        textString = "r"),
        Text(
        extent = {{15, -67}, {146, -92}},
        lineColor = {95, 95, 95},
        textString = "resolve"),
        Line(
        points = {{0, -96}, {0, -96}, {0, -70}, {0, -70}},
        pattern = LinePattern.Dot)}),
        Documentation(info = "<html>
<p>
The absolute position vector of the origin of frame_a is
determined and provided at the output signal connector <strong>r</strong>.
</p>

<p>
Via parameter <strong>resolveInFrame</strong> it is defined, in which frame
the position vector is resolved:
</p>

<table border=1 cellspacing=0 cellpadding=2>
<tr><th><strong>resolveInFrame =<br>Types.ResolveInFrameA.</strong></th><th><strong>Meaning</strong></th></tr>
<tr><td>world</td>
    <td>Resolve vector in world frame</td></tr>

<tr><td>frame_a</td>
    <td>Resolve vector in frame_a</td></tr>

<tr><td>frame_resolve</td>
    <td>Resolve vector in frame_resolve</td></tr>
</table>

<p>
If resolveInFrame = Types.ResolveInFrameA.frame_resolve, the conditional connector
\"frame_resolve\" is enabled and r is resolved in the frame, to
which frame_resolve is connected. Note, if this connector is enabled, it must
be connected.
</p>

<h4>Example</h4>
<p>
If resolveInFrame = Types.ResolveInFrameA.frame_a, the output vector is
computed as:
</p>

<blockquote><pre>
r = MultiBody.Frames.resolve2(frame_a.R, frame_b.r_0);
</pre></blockquote>
</html>"));
    end AbsolutePosition;
    model SpeedSensor
      "Ideal sensor to measure the absolute flange angular velocity"

      extends Modelica.Mechanics.Rotational.Interfaces.PartialAbsoluteSensor;
      Modelica.Blocks.Interfaces.RealOutput w(unit = "rad/s")
        "Absolute angular velocity of flange as output signal" annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}})));
    equation
      w = der(flange.phi);
      annotation (
        Documentation(info = "<html>
<p>
Measures the <strong>absolute angular velocity w</strong> of a flange in an ideal
way and provides the result as output signal <strong>w</strong>
(to be further processed with blocks of the Modelica.Blocks library).
</p>
</html>"), Icon(coordinateSystem(
          preserveAspectRatio = true,
          extent = {{-100, -100}, {100, 100}}), graphics = {Text(
          extent = {{70, -30}, {120, -70}},
          textString = "w")}));
    end SpeedSensor;
  end Sensors;
  annotation (Icon(coordinateSystem(extent = {{-100.0, -100.0}, {100.0, 100.0}},
    preserveAspectRatio = false,
    grid = {2.0, 2.0}), graphics = {Bitmap(origin = {4.0, -10.0},
    extent = {{-110.0, -110.0}, {110.0, 110.0}},
    fileName = "modelica://QuadrotorModel/Resources/Images/图片1.png")}));
  package Utilities "附件"
    extends Modelica.Icons.UtilitiesPackage;



    package Functions "函数库"
      extends Modelica.Icons.Package;
      extends Modelica.Icons.FunctionsPackage;
      function Step "三次阶跃函数"
        extends Modelica.Icons.Function;
        input Real x "自变量，可以是时间或时间的任一函数";
        input Real x_0 "自变量的STEP函数开始值，可以是常数或函数表达式或设计变量";
        input Real h_0 "STEP函数的初始值，可以是常数或函数表达式或设计变量";
        input Real x_1 "自变量的STEP函数结束值，可以是常数或函数表达式或设计变量";
        input Real h_1 "STEP函数的最终值，可以是常数或函数表达式或设计变量";
        output Real y "函数输出值";
      algorithm
        y := if x <= x_0 then h_0 else if x > x_0 and x < x_1 then h_0 + ((h_1 - h_0) * ((x - x_0) / (x_1 - x_0)) ^ 2) * (3 - 2 * ((x - x_0) / (x_1 - x_0))) else h_1;
      end Step;
      function Friction "摩擦力"
        extends Modelica.Icons.Function;
        import SI = Modelica.SIunits;
        //输入参数
        input Modelica.Units.SI.Force N "法向载荷";
        input Modelica.Units.SI.Velocity V "相对滑移速度";
        input Modelica.Units.SI.Velocity V_s "最大静摩擦对应的相对滑移速度";
        input Modelica.Units.SI.CoefficientOfFriction Cst "静摩擦系数";
        input Modelica.Units.SI.Velocity Vtr "动摩擦对应的相对滑移速度";
        input Modelica.Units.SI.CoefficientOfFriction Cdy "动摩擦系数";
        output Modelica.Units.SI.Force F_f "摩擦力";
        //中间变量
      algorithm
        F_f := N * QuadrotorModel.Utilities.Functions.Step(V, -V_s, -1, V_s, 1) * QuadrotorModel.Utilities.Functions.Step(abs(V), V_s, Cst, Vtr, Cdy);
      end Friction;
    end Functions;
  end Utilities;
end QuadrotorModel;