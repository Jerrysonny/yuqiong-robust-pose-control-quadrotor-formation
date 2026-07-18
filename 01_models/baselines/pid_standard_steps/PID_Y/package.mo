package A8FormalPidTwin "PID topology twins for the frozen official plant"
  extends Modelica.Icons.Package;

  // Y轴标准阶跃路径，其他轴保持初始参考值。
  model StandardStepPathV7
    parameter Integer axis(min=1, max=3) = 2;
    Modelica.Blocks.Interfaces.RealOutput position_command[3];
  equation
    position_command[1]=if axis==1 and time>=10 then 1 else 0;
    position_command[2]=if axis==2 and time>=10 then 1 else 0;
    position_command[3]=if axis==3 then
      (if time<5 then time/5 else if time<10 then 1 else 2)
      else if time<5 then 1.5*time/5 else 1.5;
  end StandardStepPathV7;

  // 悬停路径用于复用同一官方PID拓扑完成基准检查。
  model HoverPath "Exact scene_04 reference used by the frozen baseline"
    parameter Real x0 = 0;
    parameter Real y0 = 0;
    parameter Real z0 = 1.5;
    parameter Real climbDuration = 5;
    Modelica.Blocks.Interfaces.RealOutput position_command[3];
  equation
    position_command[1] = x0;
    position_command[2] = y0;
    position_command[3] = if time < climbDuration then
      z0 * time / climbDuration else z0;
  end HoverPath;

  // 悬停场景连接官方机体、传感器、控制器和电机模型。
  model PidTopologyTwinScene04 "scene_04_hover official PID topology twin"
    HoverPath climbePath;
    QuadrotorModel.Mechanics.QuadChassis quadChassisTest17_1(
      lift_cofficient = 0.002);
    QuadrotorModel.Electricals.Actuator actuator1_1;
    QuadrotorModel.Electricals.Actuator actuator1_2;
    QuadrotorModel.Electricals.Actuator actuator1_3;
    QuadrotorModel.Electricals.Actuator actuator1_4;
    QuadrotorModel.Sensors.Sensors sensors1_1;
    QuadrotorModel.Blocks.Controller.Controller controller3_2;
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4];
  equation
    connect(actuator1_1.flange_a, quadChassisTest17_1.flange_a);
    connect(actuator1_2.flange_a, quadChassisTest17_1.flange_a1);
    connect(actuator1_3.flange_a, quadChassisTest17_1.flange_a2);
    connect(actuator1_4.flange_a, quadChassisTest17_1.flange_a3);
    connect(quadChassisTest17_1.frame_a, sensors1_1.frame_a);
    connect(actuator1_1.u, controller3_2.y);
    connect(actuator1_2.u, controller3_2.y1);
    connect(actuator1_3.u, controller3_2.y2);
    connect(actuator1_4.u, controller3_2.y3);
    connect(sensors1_1.AngleMea, controller3_2.angle);
    connect(sensors1_1.PosMea, controller3_2.position);
    connect(climbePath.position_command, controller3_2.position_command);
    connect(actuator1_1.flange_a, speedSensor[1].flange);
    connect(actuator1_2.flange_a, speedSensor[2].flange);
    connect(actuator1_3.flange_a, speedSensor[3].flange);
    connect(actuator1_4.flange_a, speedSensor[4].flange);
    annotation(experiment(
      Algorithm = Dassl,
      StartTime = 0,
      StopTime = 30,
      Tolerance = 0.0001,
      Interval = 0.01));
  end PidTopologyTwinScene04;

  // 阶跃场景仅替换参考路径，其余物理和控制连接保持一致。
  model PidTopologyTwinScene01 "scene_01_step_climb official PID topology twin"
    StandardStepPathV7 climbePath;
    Real referenceVector[11];
    Real motorCommand[4];
    Real motorApplied[4];
    QuadrotorModel.Mechanics.QuadChassis quadChassisTest17_1(
      lift_cofficient = 0.002);
    QuadrotorModel.Electricals.Actuator actuator1_1;
    QuadrotorModel.Electricals.Actuator actuator1_2;
    QuadrotorModel.Electricals.Actuator actuator1_3;
    QuadrotorModel.Electricals.Actuator actuator1_4;
    QuadrotorModel.Sensors.Sensors sensors1_1;
    QuadrotorModel.Blocks.Controller.Controller controller3_2;
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4];
  equation
    connect(actuator1_1.flange_a, quadChassisTest17_1.flange_a);
    connect(actuator1_2.flange_a, quadChassisTest17_1.flange_a1);
    connect(actuator1_3.flange_a, quadChassisTest17_1.flange_a2);
    connect(actuator1_4.flange_a, quadChassisTest17_1.flange_a3);
    connect(quadChassisTest17_1.frame_a, sensors1_1.frame_a);
    connect(actuator1_1.u, controller3_2.y);
    connect(actuator1_2.u, controller3_2.y1);
    connect(actuator1_3.u, controller3_2.y2);
    connect(actuator1_4.u, controller3_2.y3);
    connect(sensors1_1.AngleMea, controller3_2.angle);
    connect(sensors1_1.PosMea, controller3_2.position);
    connect(climbePath.position_command, controller3_2.position_command);
    connect(actuator1_1.flange_a, speedSensor[1].flange);
    connect(actuator1_2.flange_a, speedSensor[2].flange);
    connect(actuator1_3.flange_a, speedSensor[3].flange);
    connect(actuator1_4.flange_a, speedSensor[4].flange);
    referenceVector={climbePath.position_command[1],climbePath.position_command[2],climbePath.position_command[3],0,0,0,0,0,0,0,0};
    motorCommand={controller3_2.y,controller3_2.y1,controller3_2.y2,controller3_2.y3};
    motorApplied={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w};
    annotation(experiment(
      Algorithm = Dassl,
      StartTime = 0,
      StopTime = 30,
      Tolerance = 0.0001,
      Interval = 0.01));
  end PidTopologyTwinScene01;
end A8FormalPidTwin;
