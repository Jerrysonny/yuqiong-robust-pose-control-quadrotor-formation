package A8ARDGRGPCFinalScenarios20260815
  extends Modelica.Icons.Package;

  partial model PlantAdapterBase
    extends A8RAGCACGHTEPlant20260715.PlantBase(
      qLimit=3600,
      quadChassisTest17_1(
        lift_cofficient=0.002,
        body(m=0.159504,I_11=0.00010556,I_22=0.00010556,I_33=0.00010556),
        propellers1(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07),
        propellers2(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07),
        propellers3(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07),
        propellers4(m=0.000913171,I_11=1.59662e-07,I_22=1.59594e-07,I_33=3.16359e-07)));
    A8FormalPidTwin.HoverPath hoverPath 
      annotation(Placement(transformation(origin={-75,65},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput controllerReference[11] 
      annotation(Placement(transformation(origin={100,70},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput controllerState[18] 
      annotation(Placement(transformation(origin={100,45},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput controllerAllocatorLimit[2] 
      annotation(Placement(transformation(origin={100,20},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput controllerRotorSpeed[4] 
      annotation(Placement(transformation(origin={100,-5},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput referencePosition[3] 
      annotation(Placement(transformation(origin={100,-30},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput eventCode 
      annotation(Placement(transformation(origin={100,-55},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput externalForceWorld[3] 
      annotation(Placement(transformation(origin={100,-75},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput externalTorqueBody[3] 
      annotation(Placement(transformation(origin={100,-95},extent={{-5,-5},{5,5}})));
  equation
    referenceVector={hoverPath.position_command[1],hoverPath.position_command[2],hoverPath.position_command[3],
      0,0,if time<5 then 0.3 else 0,0,0,0,0,0};
    referencePosition={referenceVector[1],referenceVector[2],referenceVector[3]};
    connect(referenceSource.y,controllerReference) 
      annotation(Line(points={{-45,35},{85,35},{85,70},{100,70}},color={0,0,127}));
    connect(stateSource.y,controllerState) 
      annotation(Line(points={{-45,-35},{82,-35},{82,45},{100,45}},color={0,0,127}));
    connect(allocatorLimit.y,controllerAllocatorLimit) 
      annotation(Line(points={{-45,-65},{78,-65},{78,20},{100,20}},color={0,0,127}));
    controllerRotorSpeed={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w};
    annotation(Diagram(coordinateSystem(extent={{-100,-110},{100,100}},grid={2,2})));
  end PlantAdapterBase;

  model BodyRollPlantAdapter
    extends PlantAdapterBase;
    Modelica.Mechanics.MultiBody.Forces.WorldTorque bodyTorque(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,
      animation=false) 
      annotation(Placement(transformation(origin={95,10},extent={{-8,-8},{8,8}})));
  equation
    eventCode=if time>=8 and time<8.25 then 1 else 0;
    externalForceWorld={0,0,0};
    externalTorqueBody={if time>=8 and time<8.25 then 0.0006 else 0,0,0};
    bodyTorque.torque=externalTorqueBody;
    connect(quadChassisTest17_1.body.frame_b,bodyTorque.frame_b) 
      annotation(Line(points={{90,0},{95,0},{95,2}},color={95,95,95},thickness=0.5));
  end BodyRollPlantAdapter;

  model BodyPitchPlantAdapter
    extends PlantAdapterBase;
    Modelica.Mechanics.MultiBody.Forces.WorldTorque bodyTorque(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.frame_b,
      animation=false) 
      annotation(Placement(transformation(origin={95,10},extent={{-8,-8},{8,8}})));
  equation
    eventCode=if time>=8 and time<8.25 then 1 else 0;
    externalForceWorld={0,0,0};
    externalTorqueBody={0,if time>=8 and time<8.25 then -0.0006 else 0,0};
    bodyTorque.torque=externalTorqueBody;
    connect(quadChassisTest17_1.body.frame_b,bodyTorque.frame_b) 
      annotation(Line(points={{90,0},{95,0},{95,2}},color={95,95,95},thickness=0.5));
  end BodyPitchPlantAdapter;

  partial model QualificationTop
    parameter Real ardgEnable=1;
    Modelica.Blocks.Sources.RealExpression enableARDG1[1](y={ardgEnable}) 
      annotation(Placement(transformation(origin={-65,-80},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression continuousTime[1](y={time}) 
      annotation(Placement(transformation(origin={-65,-110},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[16] 
      annotation(Placement(transformation(origin={10,-35},extent={{-5,-5},{5,5}})));
    annotation(
      experiment(Algorithm=Dassl,StartTime=0,StopTime=50,Tolerance=0.0001,NumberOfIntervals=5000),
      Diagram(coordinateSystem(extent={{-100,-130},{100,100}},grid={2,2})));
  end QualificationTop;

  model BodyRollPos
    extends QualificationTop;
    BodyRollPlantAdapter plant 
      annotation(Placement(transformation(origin={45,0},extent={{-25,-25},{25,25}})));
    A8FormalRAGCACGHTE_20260715 controller 
      annotation (Placement(transformation(origin = {-15, 0}, extent = {{-15, -15}, {15, 15}})),__MWORKS(SECInstance=true));
  equation
    connect(plant.controllerReference, controller.reference) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerState, controller.state) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerAllocatorLimit, controller.allocator_limit) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(controller.motor_cmd, plant.motorCommand) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(controller.diagnostics, controllerDiagnostics) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerRotorSpeed, controller.ardg1_rotor_speed) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(enableARDG1.y, controller.ardg1_enable) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(continuousTime.y, controller.ardg1_time) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=50,Tolerance=0.0001,NumberOfIntervals=5000));
  end BodyRollPos;

  model BodyPitchNeg
    extends QualificationTop;
    BodyPitchPlantAdapter plant 
      annotation(Placement(transformation(origin={45,0},extent={{-25,-25},{25,25}})));
    A8FormalRAGCACGHTE_20260715 controller 
      annotation (Placement(transformation(origin = {-15, 0}, extent = {{-15, -15}, {15, 15}})),__MWORKS(SECInstance=true));
  equation
    connect(plant.controllerReference, controller.reference) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerState, controller.state) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerAllocatorLimit, controller.allocator_limit) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(controller.motor_cmd, plant.motorCommand) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(controller.diagnostics, controllerDiagnostics) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(plant.controllerRotorSpeed, controller.ardg1_rotor_speed) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(enableARDG1.y, controller.ardg1_enable) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    connect(continuousTime.y, controller.ardg1_time) 
      annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=50,Tolerance=0.0001,NumberOfIntervals=5000));
  end BodyPitchNeg;
end A8ARDGRGPCFinalScenarios20260815;
