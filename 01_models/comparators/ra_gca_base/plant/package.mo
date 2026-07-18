package A8FormalSO3Plant20260711
  extends Modelica.Icons.Package;
  // 公共单机基座连接物理模型、传感器和基础几何控制器。
  partial model PlantBase
    Real referenceVector[11];
    QuadrotorModel.Mechanics.QuadChassis quadChassisTest17_1(lift_cofficient=0.002)
      annotation(Placement(transformation(origin={70,0},extent={{-20,-20},{20,20}})));
    QuadrotorModel.Electricals.Actuator actuator1_1 annotation(Placement(transformation(origin={20,60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_2 annotation(Placement(transformation(origin={20,20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_3 annotation(Placement(transformation(origin={20,-20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_4 annotation(Placement(transformation(origin={20,-60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Sensors.Sensors sensors1_1 annotation(Placement(transformation(origin={80,-55},extent={{15,-12},{-15,12}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4] annotation(Placement(transformation(origin={80,55},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Sources.RealExpression referenceSource[11](y=referenceVector) annotation(Placement(transformation(origin={-55,35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression stateSource[18](y={
      sensors1_1.PosMea[1],sensors1_1.PosMea[2],sensors1_1.PosMea[3],
      quadChassisTest17_1.body.v_0[1],quadChassisTest17_1.body.v_0[2],quadChassisTest17_1.body.v_0[3],
      quadChassisTest17_1.body.frame_b.R.T[1,1],quadChassisTest17_1.body.frame_b.R.T[2,1],quadChassisTest17_1.body.frame_b.R.T[3,1],
      quadChassisTest17_1.body.frame_b.R.T[1,2],quadChassisTest17_1.body.frame_b.R.T[2,2],quadChassisTest17_1.body.frame_b.R.T[3,2],
      quadChassisTest17_1.body.frame_b.R.T[1,3],quadChassisTest17_1.body.frame_b.R.T[2,3],quadChassisTest17_1.body.frame_b.R.T[3,3],
      quadChassisTest17_1.body.frame_b.R.w[1],quadChassisTest17_1.body.frame_b.R.w[2],quadChassisTest17_1.body.frame_b.R.w[3]})
      annotation(Placement(transformation(origin={-55,-35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand[4]
      annotation(Placement(transformation(origin={5,35},extent={{-5,-5},{5,5}})));
  equation
    connect(motorCommand[1],actuator1_1.u) annotation(Line(points={{5,35},{10,35},{10,60}},color={0,0,127}));
    connect(motorCommand[2],actuator1_2.u) annotation(Line(points={{5,35},{8,35},{8,20},{10,20}},color={0,0,127}));
    connect(motorCommand[3],actuator1_3.u) annotation(Line(points={{5,35},{8,35},{8,-20},{10,-20}},color={0,0,127}));
    connect(motorCommand[4],actuator1_4.u) annotation(Line(points={{5,35},{10,35},{10,-60}},color={0,0,127}));
    connect(actuator1_1.flange_a,quadChassisTest17_1.flange_a)
      annotation(Line(points={{30,60},{45,60},{45,12},{50,12}},color={95,95,95}));
    connect(actuator1_2.flange_a,quadChassisTest17_1.flange_a1)
      annotation(Line(points={{30,20},{45,20},{45,4},{50,4}},color={95,95,95}));
    connect(actuator1_3.flange_a,quadChassisTest17_1.flange_a2)
      annotation(Line(points={{30,-20},{45,-20},{45,-4},{50,-4}},color={95,95,95}));
    connect(actuator1_4.flange_a,quadChassisTest17_1.flange_a3)
      annotation(Line(points={{30,-60},{45,-60},{45,-12},{50,-12}},color={95,95,95}));
    connect(quadChassisTest17_1.frame_a,sensors1_1.frame_a)
      annotation(Line(points={{90,0},{95,0},{95,-55}},color={95,95,95},thickness=0.5));
    connect(actuator1_1.flange_a,speedSensor[1].flange)
      annotation(Line(points={{30,60},{55,60},{55,55},{72,55}},color={95,95,95}));
    connect(actuator1_2.flange_a,speedSensor[2].flange)
      annotation(Line(points={{30,20},{58,20},{58,55},{72,55}},color={95,95,95}));
    connect(actuator1_3.flange_a,speedSensor[3].flange)
      annotation(Line(points={{30,-20},{61,-20},{61,55},{72,55}},color={95,95,95}));
    connect(actuator1_4.flange_a,speedSensor[4].flange)
      annotation(Line(points={{30,-60},{64,-60},{64,55},{72,55}},color={95,95,95}));
  end PlantBase;
  // 名义悬停场景用于检查基础控制器稳态表现。
  model Scene04
    extends PlantBase;
    A8FormalPidTwin.HoverPath climbePath;
    A8FormalSO3V1F_20260711 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[12]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
  equation
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={climbePath.position_command[1],climbePath.position_command[2],climbePath.position_command[3],0,0,if time<5 then 0.3 else 0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=30,Tolerance=0.0001,NumberOfIntervals=3000));
  end Scene04;
  // 阶梯爬升场景使用官方参考路径。
  model Scene01
    extends PlantBase;
    QuadrotorModel.PathPlanning.ClimbPath climbePath(gain(k=1));
    A8FormalSO3V1F_20260711 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[12]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
  equation
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={climbePath.position_command[1],climbePath.position_command[2],climbePath.position_command[3],
      if time<20 then 0 else if time<30 then 1 else 0,if time<30 then 0 else if time<40 then 1 else 0,
      if time<5 then 2 else if time<10 then 0 else if time<13 then 5/3 else 0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=50,Tolerance=0.0001,NumberOfIntervals=5000));
  end Scene01;
  // 8字轨迹场景用于评价连续转向跟踪。
  model Scene03
    extends PlantBase;
    QuadrotorModel.PathPlanning.EightPath climbePath;
    A8FormalSO3V1F_20260711 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[12]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
  equation
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={climbePath.position_command[1],climbePath.position_command[2],climbePath.position_command[3],
      if time<=10 then 0 else 10*0.02*Modelica.Constants.pi*cos((0.02*(time-10)+1/360)*Modelica.Constants.pi),
      if time<=10 then 0 else 10*0.04*Modelica.Constants.pi*cos(0.04*(time-10)*Modelica.Constants.pi),
      if time<10 then 1 else 0,
      if time<=10 then 0 else -10*(0.02*Modelica.Constants.pi)^2*sin((0.02*(time-10)+1/360)*Modelica.Constants.pi),
      if time<=10 then 0 else -10*(0.04*Modelica.Constants.pi)^2*sin(0.04*(time-10)*Modelica.Constants.pi),
      0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=120,Tolerance=0.0001,NumberOfIntervals=12000));
  end Scene03;
  // 扰动机体在四个旋翼处施加统一的外力输入。
  model QuadChassisMultiDisturbance
    extends QuadrotorModel.Mechanics.QuadChassis;
    Real perRotorDisturbance = if time>=8 and time<=8.5 then 0.01 else
      if time>=14 and time<=15 then 0.02 else
      if time>=20 and time<=22 then 0.03 else 0;
    Modelica.Mechanics.MultiBody.Forces.WorldForce disturbance1(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,animation=false);
    Modelica.Mechanics.MultiBody.Forces.WorldForce disturbance2(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,animation=false);
    Modelica.Mechanics.MultiBody.Forces.WorldForce disturbance3(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,animation=false);
    Modelica.Mechanics.MultiBody.Forces.WorldForce disturbance4(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,animation=false);
  equation
    disturbance1.force={perRotorDisturbance,0,0};
    disturbance2.force={perRotorDisturbance,0,0};
    disturbance3.force={perRotorDisturbance,0,0};
    disturbance4.force={perRotorDisturbance,0,0};
    connect(disturbance1.frame_b,Dronefixed1.frame_b);
    connect(disturbance2.frame_b,Dronefixed2.frame_b);
    connect(disturbance3.frame_b,Dronefixed3.frame_b);
    connect(disturbance4.frame_b,Dronefixed4.frame_b);
  end QuadChassisMultiDisturbance;
  // 外扰基座在公共单机结构上增加扰动力源。
  partial model DisturbancePlantBase
    Real referenceVector[11];
    QuadChassisMultiDisturbance quadChassisTest17_1(lift_cofficient=0.002)
      annotation(Placement(transformation(origin={70,0},extent={{-20,-20},{20,20}})));
    QuadrotorModel.Electricals.Actuator actuator1_1 annotation(Placement(transformation(origin={20,60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_2 annotation(Placement(transformation(origin={20,20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_3 annotation(Placement(transformation(origin={20,-20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_4 annotation(Placement(transformation(origin={20,-60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Sensors.Sensors sensors1_1 annotation(Placement(transformation(origin={80,-55},extent={{15,-12},{-15,12}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4] annotation(Placement(transformation(origin={80,55},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Sources.RealExpression referenceSource[11](y=referenceVector) annotation(Placement(transformation(origin={-55,35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression stateSource[18](y={
      sensors1_1.PosMea[1],sensors1_1.PosMea[2],sensors1_1.PosMea[3],
      quadChassisTest17_1.body.v_0[1],quadChassisTest17_1.body.v_0[2],quadChassisTest17_1.body.v_0[3],
      quadChassisTest17_1.body.frame_b.R.T[1,1],quadChassisTest17_1.body.frame_b.R.T[2,1],quadChassisTest17_1.body.frame_b.R.T[3,1],
      quadChassisTest17_1.body.frame_b.R.T[1,2],quadChassisTest17_1.body.frame_b.R.T[2,2],quadChassisTest17_1.body.frame_b.R.T[3,2],
      quadChassisTest17_1.body.frame_b.R.T[1,3],quadChassisTest17_1.body.frame_b.R.T[2,3],quadChassisTest17_1.body.frame_b.R.T[3,3],
      quadChassisTest17_1.body.frame_b.R.w[1],quadChassisTest17_1.body.frame_b.R.w[2],quadChassisTest17_1.body.frame_b.R.w[3]})
      annotation(Placement(transformation(origin={-55,-35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand[4]
      annotation(Placement(transformation(origin={5,35},extent={{-5,-5},{5,5}})));
  equation
    connect(motorCommand[1],actuator1_1.u);
    connect(motorCommand[2],actuator1_2.u);
    connect(motorCommand[3],actuator1_3.u);
    connect(motorCommand[4],actuator1_4.u);
    connect(actuator1_1.flange_a,quadChassisTest17_1.flange_a);
    connect(actuator1_2.flange_a,quadChassisTest17_1.flange_a1);
    connect(actuator1_3.flange_a,quadChassisTest17_1.flange_a2);
    connect(actuator1_4.flange_a,quadChassisTest17_1.flange_a3);
    connect(quadChassisTest17_1.frame_a,sensors1_1.frame_a);
    connect(actuator1_1.flange_a,speedSensor[1].flange);
    connect(actuator1_2.flange_a,speedSensor[2].flange);
    connect(actuator1_3.flange_a,speedSensor[3].flange);
    connect(actuator1_4.flange_a,speedSensor[4].flange);
  end DisturbancePlantBase;
  // 三事件外扰场景复用同一控制器和结果接口。
  model Scene06b
    extends DisturbancePlantBase;
    A8FormalPidTwin.HoverPath climbePath;
    A8FormalSO3V1F_20260711 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[12]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
  equation
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    referenceVector={climbePath.position_command[1],climbePath.position_command[2],climbePath.position_command[3],0,0,if time<5 then 0.3 else 0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=30,Tolerance=0.0001,NumberOfIntervals=3000));
  end Scene06b;
end A8FormalSO3Plant20260711;
