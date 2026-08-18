package A8RAGCACGHTEPhaseValidationPlant20260715
  extends Modelica.Icons.Package;

  // 鲁棒物理层集中注入升力、质量、惯量和风扰变化，不改正式控制器参数。
  model RobustQuadChassis
    parameter Real liftScale=1;
    parameter Real massScale=1;
    parameter Real inertiaScale=1;
    parameter Boolean windEnabled=false;
    parameter Real referenceArea=0.02;
    parameter Real pressureCenterOffset=0.02;
    parameter Real phaseOffset=0;
    extends QuadrotorModel.Mechanics.QuadChassis(
      lift_cofficient=0.002*liftScale,
      body(m=0.159504*massScale,I_11=0.00010556*inertiaScale,
        I_22=0.00010556*inertiaScale,I_33=0.00010556*inertiaScale),
      propellers1(m=0.000913171*massScale,I_11=1.59662e-7*inertiaScale,
        I_22=1.59594e-7*inertiaScale,I_33=3.16359e-7*inertiaScale),
      propellers2(m=0.000913171*massScale,I_11=1.59662e-7*inertiaScale,
        I_22=1.59594e-7*inertiaScale,I_33=3.16359e-7*inertiaScale),
      propellers3(m=0.000913171*massScale,I_11=1.59662e-7*inertiaScale,
        I_22=1.59594e-7*inertiaScale,I_33=3.16359e-7*inertiaScale),
      propellers4(m=0.000913171*massScale,I_11=1.59662e-7*inertiaScale,
        I_22=1.59594e-7*inertiaScale,I_33=3.16359e-7*inertiaScale));
    Real windVelocity[3];
    Real relativeAirVelocity[3];
    Real aerodynamicForce[3];
    Real aerodynamicTorque[3];
    Real relativeAirSpeed;
    Modelica.Mechanics.MultiBody.Forces.WorldForce windForce(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.world,
      animation=false)
      annotation(Placement(transformation(origin={110,55},extent={{-10,-10},{10,10}})));
    Modelica.Mechanics.MultiBody.Forces.WorldTorque windTorque(
      resolveInFrame=Modelica.Mechanics.MultiBody.Types.ResolveInFrameB.world,
      animation=false)
      annotation(Placement(transformation(origin={110,25},extent={{-10,-10},{10,10}})));
  equation
    // 风场按预注册时段分段施加，气动力和力矩由相对气流统一计算。
    windVelocity={
      if windEnabled and time>=8 then 1.5 else 0,
      if windEnabled and time>=15 and time<=18 then
        1.5*sin(Modelica.Constants.pi*(time-15)/3+phaseOffset) else 0,
      if windEnabled and time>=24 and time<=27 then
        0.8*sin(Modelica.Constants.pi*(time-24)/3+phaseOffset) else 0};
    relativeAirVelocity=windVelocity-body.v_0;
    relativeAirSpeed=sqrt(relativeAirVelocity*relativeAirVelocity+1e-12);
    aerodynamicForce=0.5*1.225*1.0*referenceArea*relativeAirSpeed*relativeAirVelocity;
    aerodynamicTorque={-pressureCenterOffset*aerodynamicForce[2],
      pressureCenterOffset*aerodynamicForce[1],0};
    windForce.force=aerodynamicForce;
    windTorque.torque=aerodynamicTorque;
    connect(windForce.frame_b,body.frame_b)
      annotation(Line(points={{120,55},{135,55},{135,10}},color={95,95,95}));
    connect(windTorque.frame_b,body.frame_b)
      annotation(Line(points={{120,25},{135,25},{135,10}},color={95,95,95}));
  end RobustQuadChassis;

  // 五相位包装统一传感器退化、执行器边界和场景诊断接口。
  partial model PlantBase
    parameter Real liftScale=1;
    parameter Real massScale=1;
    parameter Real inertiaScale=1;
    parameter Boolean windEnabled=false;
    parameter Boolean sensorDegraded=false;
    parameter Real measurementDelay=0.02;
    parameter Real sensorNoiseScale=1;
    parameter Real phaseOffset=0;
    parameter Real qLimit=3600;
    Real referenceVector[11];
    Real measuredPosition[3];
    Real measuredVelocity[3];
    Real delayedRotation[3,3];
    Real noiseRotation[3,3];
    Real measuredRotation[3,3];
    Real measuredBodyRate[3];
    Real positionNoise[3];
    Real attitudeNoise[3];
    Real sensorActivation;
    Modelica.Blocks.Interfaces.RealOutput motorApplied[4];
    Real headroomActive;
    RobustQuadChassis quadChassisTest17_1(liftScale=liftScale,massScale=massScale,
      inertiaScale=inertiaScale,windEnabled=windEnabled,phaseOffset=phaseOffset)
      annotation(Placement(transformation(origin={70,0},extent={{-20,-20},{20,20}})));
    QuadrotorModel.Electricals.Actuator actuator1_1
      annotation(Placement(transformation(origin={20,60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_2
      annotation(Placement(transformation(origin={20,20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_3
      annotation(Placement(transformation(origin={20,-20},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Electricals.Actuator actuator1_4
      annotation(Placement(transformation(origin={20,-60},extent={{-10,-10},{10,10}})));
    QuadrotorModel.Sensors.Sensors sensors1_1
      annotation(Placement(transformation(origin={80,-55},extent={{15,-12},{-15,12}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor[4]
      annotation(Placement(transformation(origin={80,55},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Sources.RealExpression referenceSource[11](y=referenceVector)
      annotation(Placement(transformation(origin={-55,35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression stateSource[18](y={
      measuredPosition[1],measuredPosition[2],measuredPosition[3],
      measuredVelocity[1],measuredVelocity[2],measuredVelocity[3],
      measuredRotation[1,1],measuredRotation[2,1],measuredRotation[3,1],
      measuredRotation[1,2],measuredRotation[2,2],measuredRotation[3,2],
      measuredRotation[1,3],measuredRotation[2,3],measuredRotation[3,3],
      measuredBodyRate[1],measuredBodyRate[2],measuredBodyRate[3]})
      annotation(Placement(transformation(origin={-55,-35},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression allocatorLimit[2](y={0,qLimit})
      annotation(Placement(transformation(origin={-55,-65},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand[4]
      annotation(Placement(transformation(origin={5,35},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[16]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Interfaces.RealOutput scenarioDiagnostics[16]
      annotation(Placement(transformation(origin={100,-35},extent={{-5,-5},{5,5}})));
  equation
    sensorActivation=if sensorDegraded then
      (if time<8 then 0 else if time<9 then time-8 else 1) else 0;
    positionNoise={sensorActivation*sensorNoiseScale*sqrt(2)*0.005*sin(2*Modelica.Constants.pi*0.73*time+phaseOffset),
      sensorActivation*sensorNoiseScale*sqrt(2)*0.005*sin(2*Modelica.Constants.pi*0.91*time+0.7+phaseOffset),
      sensorActivation*sensorNoiseScale*sqrt(2)*0.005*sin(2*Modelica.Constants.pi*1.13*time+1.4+phaseOffset)};
    attitudeNoise={sensorActivation*sensorNoiseScale*sqrt(2)*0.5*Modelica.Constants.pi/180*sin(2*Modelica.Constants.pi*0.61*time+phaseOffset),
      sensorActivation*sensorNoiseScale*sqrt(2)*0.5*Modelica.Constants.pi/180*sin(2*Modelica.Constants.pi*0.83*time+0.9+phaseOffset),
      sensorActivation*sensorNoiseScale*sqrt(2)*0.5*Modelica.Constants.pi/180*sin(2*Modelica.Constants.pi*1.07*time+1.8+phaseOffset)};
    for i in 1:3 loop
      measuredPosition[i]=if sensorDegraded then
        (1-sensorActivation)*sensors1_1.PosMea[i]+
        sensorActivation*delay(sensors1_1.PosMea[i],measurementDelay)+positionNoise[i]
        else sensors1_1.PosMea[i];
      measuredVelocity[i]=if sensorDegraded then
        (1-sensorActivation)*quadChassisTest17_1.body.v_0[i]+
        sensorActivation*delay(quadChassisTest17_1.body.v_0[i],measurementDelay)
        else quadChassisTest17_1.body.v_0[i];
      measuredBodyRate[i]=if sensorDegraded then
        (1-sensorActivation)*quadChassisTest17_1.body.frame_b.R.w[i]+
        sensorActivation*delay(quadChassisTest17_1.body.frame_b.R.w[i],measurementDelay)
        else quadChassisTest17_1.body.frame_b.R.w[i];
      for j in 1:3 loop
        delayedRotation[i,j]=if sensorDegraded then
          (1-sensorActivation)*quadChassisTest17_1.body.frame_b.R.T[i,j]+
          sensorActivation*delay(quadChassisTest17_1.body.frame_b.R.T[i,j],measurementDelay)
          else quadChassisTest17_1.body.frame_b.R.T[i,j];
      end for;
    end for;
    noiseRotation={{cos(attitudeNoise[2])*cos(attitudeNoise[3]),
      sin(attitudeNoise[1])*sin(attitudeNoise[2])*cos(attitudeNoise[3])-cos(attitudeNoise[1])*sin(attitudeNoise[3]),
      cos(attitudeNoise[1])*sin(attitudeNoise[2])*cos(attitudeNoise[3])+sin(attitudeNoise[1])*sin(attitudeNoise[3])},
      {cos(attitudeNoise[2])*sin(attitudeNoise[3]),
      sin(attitudeNoise[1])*sin(attitudeNoise[2])*sin(attitudeNoise[3])+cos(attitudeNoise[1])*cos(attitudeNoise[3]),
      cos(attitudeNoise[1])*sin(attitudeNoise[2])*sin(attitudeNoise[3])-sin(attitudeNoise[1])*cos(attitudeNoise[3])},
      {-sin(attitudeNoise[2]),sin(attitudeNoise[1])*cos(attitudeNoise[2]),
      cos(attitudeNoise[1])*cos(attitudeNoise[2])}};
    for i in 1:3 loop
      for j in 1:3 loop
        measuredRotation[i,j]=if sensorDegraded then
          sum(noiseRotation[i,k]*delayedRotation[k,j] for k in 1:3)
          else delayedRotation[i,j];
      end for;
    end for;
    for i in 1:4 loop
      motorApplied[i]=if motorCommand[i]^2<=qLimit then motorCommand[i]
        else if motorCommand[i]>=0 then sqrt(qLimit) else -sqrt(qLimit);
    end for;
    headroomActive=if max(max(motorCommand[1]^2,motorCommand[2]^2),
      max(motorCommand[3]^2,motorCommand[4]^2))>qLimit then 1 else 0;
    scenarioDiagnostics={quadChassisTest17_1.windVelocity[1],
      quadChassisTest17_1.windVelocity[2],quadChassisTest17_1.windVelocity[3],
      quadChassisTest17_1.aerodynamicForce[1],quadChassisTest17_1.aerodynamicForce[2],
      quadChassisTest17_1.aerodynamicForce[3],quadChassisTest17_1.aerodynamicTorque[1],
      quadChassisTest17_1.aerodynamicTorque[2],quadChassisTest17_1.aerodynamicTorque[3],
      qLimit,headroomActive,positionNoise[1],positionNoise[2],positionNoise[3],
      sqrt(attitudeNoise*attitudeNoise),measurementDelay};
    connect(motorApplied[1],actuator1_1.u);
    connect(motorApplied[2],actuator1_2.u);
    connect(motorApplied[3],actuator1_3.u);
    connect(motorApplied[4],actuator1_4.u);
    connect(actuator1_1.flange_a,quadChassisTest17_1.flange_a);
    connect(actuator1_2.flange_a,quadChassisTest17_1.flange_a1);
    connect(actuator1_3.flange_a,quadChassisTest17_1.flange_a2);
    connect(actuator1_4.flange_a,quadChassisTest17_1.flange_a3);
    connect(quadChassisTest17_1.frame_a,sensors1_1.frame_a);
    connect(actuator1_1.flange_a,speedSensor[1].flange);
    connect(actuator1_2.flange_a,speedSensor[2].flange);
    connect(actuator1_3.flange_a,speedSensor[3].flange);
    connect(actuator1_4.flange_a,speedSensor[4].flange);
  end PlantBase;

  partial model Scene08PhaseBase
    extends PlantBase(windEnabled=true);
    A8FormalPidTwin.HoverPath hoverPath;
  equation
    referenceVector={hoverPath.position_command[1],hoverPath.position_command[2],
      hoverPath.position_command[3],0,0,if time<5 then 0.3 else 0,0,0,0,0,0};
  end Scene08PhaseBase;

  partial model Scene10PhaseBase
    extends PlantBase(sensorDegraded=true);
    A8FormalPidTwin.HoverPath hoverPath;
  equation
    referenceVector={hoverPath.position_command[1],hoverPath.position_command[2],
      hoverPath.position_command[3],0,0,if time<5 then 0.3 else 0,0,0,0,0,0};
  end Scene10PhaseBase;

  model Scene08_P0
    extends Scene08PhaseBase(phaseOffset=0);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene08_P0;
  model Scene08_P1
    extends Scene08PhaseBase(phaseOffset=1.2566370614359172);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene08_P1;
  model Scene08_P2
    extends Scene08PhaseBase(phaseOffset=2.5132741228718345);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene08_P2;
  model Scene08_P3
    extends Scene08PhaseBase(phaseOffset=3.7699111843077517);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene08_P3;
  model Scene08_P4
    extends Scene08PhaseBase(phaseOffset=5.026548245743669);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene08_P4;

  model Scene10_P0
    extends Scene10PhaseBase(phaseOffset=0);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene10_P0;
  model Scene10_P1
    extends Scene10PhaseBase(phaseOffset=1.2566370614359172);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene10_P1;
  model Scene10_P2
    extends Scene10PhaseBase(phaseOffset=2.5132741228718345);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene10_P2;
  model Scene10_P3
    extends Scene10PhaseBase(phaseOffset=3.7699111843077517);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene10_P3;
  model Scene10_P4
    extends Scene10PhaseBase(phaseOffset=5.026548245743669);
    A8FormalRAGCACGHTE_20260715 controller annotation(__MWORKS(SECInstance=true));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference);
    connect(stateSource.y,controller.state);
    connect(allocatorLimit.y,controller.allocator_limit);
    connect(controller.motor_cmd,motorCommand);
    connect(controller.diagnostics,controllerDiagnostics);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene10_P4;
end A8RAGCACGHTEPhaseValidationPlant20260715;
