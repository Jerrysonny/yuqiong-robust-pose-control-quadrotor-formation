package A8FormationScene07COnRobustV3Plant20260712
  extends Modelica.Icons.Package;

  partial model TriplePlantBase
    QuadrotorModel.Mechanics.QuadChassis quad1(
      lift_cofficient=0.002,body(r_0(start={0,0,0},fixed=true)))
      annotation(Placement(transformation(origin={70,70},extent={{-18,-18},{18,18}})));
    QuadrotorModel.Mechanics.QuadChassis quad2(
      lift_cofficient=0.002,body(r_0(start={-0.8,-1,0},fixed=true)))
      annotation(Placement(transformation(origin={70,0},extent={{-18,-18},{18,18}})));
    QuadrotorModel.Mechanics.QuadChassis quad3(
      lift_cofficient=0.002,body(r_0(start={0.8,-1,0},fixed=true)))
      annotation(Placement(transformation(origin={70,-70},extent={{-18,-18},{18,18}})));
    QuadrotorModel.Electricals.Actuator actuator1[4]
      annotation(Placement(transformation(origin={25,70},extent={{-8,-8},{8,8}})));
    QuadrotorModel.Electricals.Actuator actuator2[4]
      annotation(Placement(transformation(origin={25,0},extent={{-8,-8},{8,8}})));
    QuadrotorModel.Electricals.Actuator actuator3[4]
      annotation(Placement(transformation(origin={25,-70},extent={{-8,-8},{8,8}})));
    QuadrotorModel.Sensors.Sensors sensors1
      annotation(Placement(transformation(origin={105,70},extent={{12,-10},{-12,10}})));
    QuadrotorModel.Sensors.Sensors sensors2
      annotation(Placement(transformation(origin={105,0},extent={{12,-10},{-12,10}})));
    QuadrotorModel.Sensors.Sensors sensors3
      annotation(Placement(transformation(origin={105,-70},extent={{12,-10},{-12,10}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor1[4]
      annotation(Placement(transformation(origin={48,50},extent={{-6,-6},{6,6}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor2[4]
      annotation(Placement(transformation(origin={48,-20},extent={{-6,-6},{6,6}})));
    Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor3[4]
      annotation(Placement(transformation(origin={48,-90},extent={{-6,-6},{6,6}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand1[4]
      annotation(Placement(transformation(origin={-10,70},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand2[4]
      annotation(Placement(transformation(origin={-10,0},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealInput motorCommand3[4]
      annotation(Placement(transformation(origin={-10,-70},extent={{-10,-10},{10,10}})));
    Real stateVector1[18]={sensors1.PosMea[1],sensors1.PosMea[2],sensors1.PosMea[3],
      quad1.body.v_0[1],quad1.body.v_0[2],quad1.body.v_0[3],
      quad1.body.frame_b.R.T[1,1],quad1.body.frame_b.R.T[2,1],quad1.body.frame_b.R.T[3,1],
      quad1.body.frame_b.R.T[1,2],quad1.body.frame_b.R.T[2,2],quad1.body.frame_b.R.T[3,2],
      quad1.body.frame_b.R.T[1,3],quad1.body.frame_b.R.T[2,3],quad1.body.frame_b.R.T[3,3],
      quad1.body.frame_b.R.w[1],quad1.body.frame_b.R.w[2],quad1.body.frame_b.R.w[3]};
    Real stateVector2[18]={sensors2.PosMea[1],sensors2.PosMea[2],sensors2.PosMea[3],
      quad2.body.v_0[1],quad2.body.v_0[2],quad2.body.v_0[3],
      quad2.body.frame_b.R.T[1,1],quad2.body.frame_b.R.T[2,1],quad2.body.frame_b.R.T[3,1],
      quad2.body.frame_b.R.T[1,2],quad2.body.frame_b.R.T[2,2],quad2.body.frame_b.R.T[3,2],
      quad2.body.frame_b.R.T[1,3],quad2.body.frame_b.R.T[2,3],quad2.body.frame_b.R.T[3,3],
      quad2.body.frame_b.R.w[1],quad2.body.frame_b.R.w[2],quad2.body.frame_b.R.w[3]};
    Real stateVector3[18]={sensors3.PosMea[1],sensors3.PosMea[2],sensors3.PosMea[3],
      quad3.body.v_0[1],quad3.body.v_0[2],quad3.body.v_0[3],
      quad3.body.frame_b.R.T[1,1],quad3.body.frame_b.R.T[2,1],quad3.body.frame_b.R.T[3,1],
      quad3.body.frame_b.R.T[1,2],quad3.body.frame_b.R.T[2,2],quad3.body.frame_b.R.T[3,2],
      quad3.body.frame_b.R.T[1,3],quad3.body.frame_b.R.T[2,3],quad3.body.frame_b.R.T[3,3],
      quad3.body.frame_b.R.w[1],quad3.body.frame_b.R.w[2],quad3.body.frame_b.R.w[3]};
  equation
    connect(motorCommand1,actuator1.u) annotation(Line(points={{0,70},{17,70}}));
    connect(motorCommand2,actuator2.u) annotation(Line(points={{0,0},{17,0}}));
    connect(motorCommand3,actuator3.u) annotation(Line(points={{0,-70},{17,-70}}));
    connect(actuator1[1].flange_a,quad1.flange_a) annotation(Line(points={{33,70},{52,70}}));
    connect(actuator1[2].flange_a,quad1.flange_a1) annotation(Line(points={{33,72},{48,72},{48,76},{52,76}}));
    connect(actuator1[3].flange_a,quad1.flange_a2) annotation(Line(points={{33,68},{48,68},{48,64},{52,64}}));
    connect(actuator1[4].flange_a,quad1.flange_a3) annotation(Line(points={{33,74},{45,74},{45,82},{52,82}}));
    connect(actuator2[1].flange_a,quad2.flange_a) annotation(Line(points={{33,0},{52,0}}));
    connect(actuator2[2].flange_a,quad2.flange_a1) annotation(Line(points={{33,2},{48,2},{48,6},{52,6}}));
    connect(actuator2[3].flange_a,quad2.flange_a2) annotation(Line(points={{33,-2},{48,-2},{48,-6},{52,-6}}));
    connect(actuator2[4].flange_a,quad2.flange_a3) annotation(Line(points={{33,4},{45,4},{45,12},{52,12}}));
    connect(actuator3[1].flange_a,quad3.flange_a) annotation(Line(points={{33,-70},{52,-70}}));
    connect(actuator3[2].flange_a,quad3.flange_a1) annotation(Line(points={{33,-68},{48,-68},{48,-64},{52,-64}}));
    connect(actuator3[3].flange_a,quad3.flange_a2) annotation(Line(points={{33,-72},{48,-72},{48,-76},{52,-76}}));
    connect(actuator3[4].flange_a,quad3.flange_a3) annotation(Line(points={{33,-66},{45,-66},{45,-58},{52,-58}}));
    connect(quad1.frame_a,sensors1.frame_a) annotation(Line(points={{88,70},{93,70}}));
    connect(quad2.frame_a,sensors2.frame_a) annotation(Line(points={{88,0},{93,0}}));
    connect(quad3.frame_a,sensors3.frame_a) annotation(Line(points={{88,-70},{93,-70}}));
    connect(actuator1.flange_a,speedSensor1.flange) annotation(Line(points={{33,70},{40,70},{40,50},{42,50}}));
    connect(actuator2.flange_a,speedSensor2.flange) annotation(Line(points={{33,0},{40,0},{40,-20},{42,-20}}));
    connect(actuator3.flange_a,speedSensor3.flange) annotation(Line(points={{33,-70},{40,-70},{40,-90},{42,-90}}));
  end TriplePlantBase;

  model Scene07CSafetyOnRobustV3
    extends TriplePlantBase;
    parameter Real w=2*Modelica.Constants.pi/30;
    Real leaderReference[9];
    Real formationOffset[9];
    Real vehicleState[18]={stateVector1[1],stateVector1[2],stateVector1[3],
      stateVector1[4],stateVector1[5],stateVector1[6],
      stateVector2[1],stateVector2[2],stateVector2[3],
      stateVector2[4],stateVector2[5],stateVector2[6],
      stateVector3[1],stateVector3[2],stateVector3[3],
      stateVector3[4],stateVector3[5],stateVector3[6]};
    Real transition=if time<15 then 0 else if time<25 then
      0.5*(1-cos(Modelica.Constants.pi*(time-15)/10)) else 1;
    Modelica.Blocks.Sources.RealExpression leaderReferenceSource[9](y=leaderReference)
      annotation(Placement(transformation(origin={-125,18},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Sources.RealExpression vehicleStateSource[18](y=vehicleState)
      annotation(Placement(transformation(origin={-125,0},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Sources.RealExpression formationOffsetSource[9](y=formationOffset)
      annotation(Placement(transformation(origin={-125,-18},extent={{-8,-8},{8,8}})));
    Modelica.Blocks.Interfaces.RealOutput formationReference[27]
      annotation(Placement(transformation(origin={-25,38},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput supervisorDiagnostics[8]
      annotation(Placement(transformation(origin={-25,-38},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics1[12]
      annotation(Placement(transformation(origin={20,90},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics2[12]
      annotation(Placement(transformation(origin={20,20},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics3[12]
      annotation(Placement(transformation(origin={20,-50},extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.RealExpression controllerReference1[11](y={
      formationReference[1],formationReference[2],formationReference[3],
      formationReference[4],formationReference[5],formationReference[6],
      formationReference[7],formationReference[8],formationReference[9],0,0})
      annotation(Placement(transformation(origin={-40,82},extent={{-7,-7},{7,7}})));
    Modelica.Blocks.Sources.RealExpression controllerReference2[11](y={
      formationReference[10],formationReference[11],formationReference[12],
      formationReference[13],formationReference[14],formationReference[15],
      formationReference[16],formationReference[17],formationReference[18],0,0})
      annotation(Placement(transformation(origin={-40,12},extent={{-7,-7},{7,7}})));
    Modelica.Blocks.Sources.RealExpression controllerReference3[11](y={
      formationReference[19],formationReference[20],formationReference[21],
      formationReference[22],formationReference[23],formationReference[24],
      formationReference[25],formationReference[26],formationReference[27],0,0})
      annotation(Placement(transformation(origin={-40,-58},extent={{-7,-7},{7,7}})));
    Modelica.Blocks.Sources.RealExpression stateSource1[18](y=stateVector1)
      annotation(Placement(transformation(origin={-40,58},extent={{-7,-7},{7,7}})));
    Modelica.Blocks.Sources.RealExpression stateSource2[18](y=stateVector2)
      annotation(Placement(transformation(origin={-40,-12},extent={{-7,-7},{7,7}})));
    Modelica.Blocks.Sources.RealExpression stateSource3[18](y=stateVector3)
      annotation(Placement(transformation(origin={-40,-82},extent={{-7,-7},{7,7}})));
    A8FormalFormationCBFSupervisorRobustV3A_20260712 supervisor
      annotation(Placement(transformation(origin={-70,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    A8FormalSO3V8PX4AllocV1A_20260712 controller1
      annotation(Placement(transformation(origin={-10,70},extent={{-12,-12},{12,12}})),__MWORKS(SECInstance=true));
    A8FormalSO3V8PX4AllocV1A_20260712 controller2
      annotation(Placement(transformation(origin={-10,0},extent={{-12,-12},{12,12}})),__MWORKS(SECInstance=true));
    A8FormalSO3V8PX4AllocV1A_20260712 controller3
      annotation(Placement(transformation(origin={-10,-70},extent={{-12,-12},{12,12}})),__MWORKS(SECInstance=true));
  equation
    leaderReference={
      0,0,
      if time<5 then 0.3*time else 1.5,
      0,0,
      if time<5 then 0.3 else 0,
      0,0,0};
    formationOffset={0,0,0,
      -0.8+1.6*transition,-1+0.2*sin(Modelica.Constants.pi*transition),0,
      0.8-1.6*transition,-1-0.2*sin(Modelica.Constants.pi*transition),0};
    connect(leaderReferenceSource.y,supervisor.leader_reference) annotation(Line(points={{-117,18},{-98,18},{-98,8},{-85,8}}));
    connect(vehicleStateSource.y,supervisor.vehicle_state) annotation(Line(points={{-117,0},{-85,0}}));
    connect(formationOffsetSource.y,supervisor.formation_offset) annotation(Line(points={{-117,-18},{-98,-18},{-98,-8},{-85,-8}}));
    connect(supervisor.formation_reference,formationReference) annotation(Line(points={{-55,8},{-48,8},{-48,38},{-25,38}}));
    connect(supervisor.diagnostics,supervisorDiagnostics) annotation(Line(points={{-55,-8},{-48,-8},{-48,-38},{-25,-38}}));
    connect(controllerReference1.y,controller1.reference) annotation(Line(points={{-28,82},{-22,82},{-22,76}}));
    connect(stateSource1.y,controller1.state) annotation(Line(points={{-33,58},{-22,58},{-22,64}}));
    connect(controller1.motor_cmd,motorCommand1) annotation(Line(points={{2,76},{8,76},{8,70},{0,70}}));
    connect(controller1.diagnostics,controllerDiagnostics1) annotation(Line(points={{2,64},{12,64},{12,90},{20,90}}));
    connect(controllerReference2.y,controller2.reference) annotation(Line(points={{-28,12},{-22,12},{-22,6}}));
    connect(stateSource2.y,controller2.state) annotation(Line(points={{-33,-12},{-22,-12},{-22,-6}}));
    connect(controller2.motor_cmd,motorCommand2) annotation(Line(points={{2,6},{8,6},{8,0},{0,0}}));
    connect(controller2.diagnostics,controllerDiagnostics2) annotation(Line(points={{2,-6},{12,-6},{12,20},{20,20}}));
    connect(controllerReference3.y,controller3.reference) annotation(Line(points={{-28,-58},{-22,-58},{-22,-64}}));
    connect(stateSource3.y,controller3.state) annotation(Line(points={{-33,-82},{-22,-82},{-22,-76}}));
    connect(controller3.motor_cmd,motorCommand3) annotation(Line(points={{2,-64},{8,-64},{8,-70},{0,-70}}));
    connect(controller3.diagnostics,controllerDiagnostics3) annotation(Line(points={{2,-76},{12,-76},{12,-50},{20,-50}}));
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,
      Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene07CSafetyOnRobustV3;
end A8FormationScene07COnRobustV3Plant20260712;
