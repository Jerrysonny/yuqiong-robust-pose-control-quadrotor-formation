package A8RAGCACGHTEFormationValidationPlant20260715
  extends Modelica.Icons.Package;

  partial model Scene07BBase
    extends A8FormationScene07V1Plant20260712.TriplePlantBase;
    parameter Real qLimit=3600;
    parameter Real w=2*Modelica.Constants.pi/30;
    Real leaderReference[9];
    Real formationOffset[9];
    Real vehicleState[18]={stateVector1[1],stateVector1[2],stateVector1[3],
      stateVector1[4],stateVector1[5],stateVector1[6],
      stateVector2[1],stateVector2[2],stateVector2[3],
      stateVector2[4],stateVector2[5],stateVector2[6],
      stateVector3[1],stateVector3[2],stateVector3[3],
      stateVector3[4],stateVector3[5],stateVector3[6]};
    Real transition=if time<20 then 0 else if time<30 then
      0.5*(1-cos(Modelica.Constants.pi*(time-20)/10)) else 1;
    Modelica.Blocks.Sources.RealExpression leaderReferenceSource[9](y=leaderReference);
    Modelica.Blocks.Sources.RealExpression vehicleStateSource[18](y=vehicleState);
    Modelica.Blocks.Sources.RealExpression formationOffsetSource[9](y=formationOffset);
    Modelica.Blocks.Interfaces.RealOutput formationReference[27];
    Modelica.Blocks.Interfaces.RealOutput supervisorDiagnostics[8];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics1[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics2[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics3[16];
    Modelica.Blocks.Sources.RealExpression allocatorLimitSource[2](y={0,qLimit});
    Modelica.Blocks.Sources.RealExpression controllerReference1[11](y={
      formationReference[1],formationReference[2],formationReference[3],
      formationReference[4],formationReference[5],formationReference[6],
      formationReference[7],formationReference[8],formationReference[9],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference2[11](y={
      formationReference[10],formationReference[11],formationReference[12],
      formationReference[13],formationReference[14],formationReference[15],
      formationReference[16],formationReference[17],formationReference[18],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference3[11](y={
      formationReference[19],formationReference[20],formationReference[21],
      formationReference[22],formationReference[23],formationReference[24],
      formationReference[25],formationReference[26],formationReference[27],0,0});
    Modelica.Blocks.Sources.RealExpression stateSource1[18](y=stateVector1);
    Modelica.Blocks.Sources.RealExpression stateSource2[18](y=stateVector2);
    Modelica.Blocks.Sources.RealExpression stateSource3[18](y=stateVector3);
  equation
    leaderReference={
      if time<30 then 0 else 2*sin(w*(time-30)),
      if time<30 then 0 else 1.2*(1-cos(w*(time-30))),
      if time<5 then 0.3*time else 1.5,
      if time<30 then 0 else 2*w*cos(w*(time-30)),
      if time<30 then 0 else 1.2*w*sin(w*(time-30)),
      if time<5 then 0.3 else 0,
      if time<30 then 0 else -2*w^2*sin(w*(time-30)),
      if time<30 then 0 else 1.2*w^2*cos(w*(time-30)),0};
    formationOffset={0,0,0,-1+0.25*transition,-0.65*transition,0,
      1-0.25*transition,-0.65*transition,0};
  end Scene07BBase;

  model Scene07B
    extends Scene07BBase;
    A8FormalFormationPredictiveCBFV5C_20260712 supervisor
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller1
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller2
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller3
      annotation(__MWORKS(SECInstance=true));
  equation
    connect(leaderReferenceSource.y,supervisor.leader_reference);
    connect(vehicleStateSource.y,supervisor.vehicle_state);
    connect(formationOffsetSource.y,supervisor.formation_offset);
    connect(supervisor.formation_reference,formationReference);
    connect(supervisor.diagnostics,supervisorDiagnostics);
    connect(controllerReference1.y,controller1.reference);
    connect(stateSource1.y,controller1.state);
    connect(allocatorLimitSource.y,controller1.allocator_limit);
    connect(controller1.motor_cmd,motorCommand1);
    connect(controller1.diagnostics,controllerDiagnostics1);
    connect(controllerReference2.y,controller2.reference);
    connect(stateSource2.y,controller2.state);
    connect(allocatorLimitSource.y,controller2.allocator_limit);
    connect(controller2.motor_cmd,motorCommand2);
    connect(controller2.diagnostics,controllerDiagnostics2);
    connect(controllerReference3.y,controller3.reference);
    connect(stateSource3.y,controller3.state);
    connect(allocatorLimitSource.y,controller3.allocator_limit);
    connect(controller3.motor_cmd,motorCommand3);
    connect(controller3.diagnostics,controllerDiagnostics3);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=60,
      Tolerance=0.0001,NumberOfIntervals=6000));
  end Scene07B;

  partial model Scene07CBase
    extends A8FormationScene07COffV1Plant20260712.TriplePlantBase;
    parameter Real qLimit=3600;
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
    Modelica.Blocks.Sources.RealExpression leaderReferenceSource[9](y=leaderReference);
    Modelica.Blocks.Sources.RealExpression vehicleStateSource[18](y=vehicleState);
    Modelica.Blocks.Sources.RealExpression formationOffsetSource[9](y=formationOffset);
    Modelica.Blocks.Interfaces.RealOutput formationReference[27];
    Modelica.Blocks.Interfaces.RealOutput supervisorDiagnostics[8];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics1[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics2[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics3[16];
    Modelica.Blocks.Sources.RealExpression allocatorLimitSource[2](y={0,qLimit});
    Modelica.Blocks.Sources.RealExpression controllerReference1[11](y={
      formationReference[1],formationReference[2],formationReference[3],
      formationReference[4],formationReference[5],formationReference[6],
      formationReference[7],formationReference[8],formationReference[9],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference2[11](y={
      formationReference[10],formationReference[11],formationReference[12],
      formationReference[13],formationReference[14],formationReference[15],
      formationReference[16],formationReference[17],formationReference[18],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference3[11](y={
      formationReference[19],formationReference[20],formationReference[21],
      formationReference[22],formationReference[23],formationReference[24],
      formationReference[25],formationReference[26],formationReference[27],0,0});
    Modelica.Blocks.Sources.RealExpression stateSource1[18](y=stateVector1);
    Modelica.Blocks.Sources.RealExpression stateSource2[18](y=stateVector2);
    Modelica.Blocks.Sources.RealExpression stateSource3[18](y=stateVector3);
  equation
    leaderReference={0,0,if time<5 then 0.3*time else 1.5,
      0,0,if time<5 then 0.3 else 0,0,0,0};
    formationOffset={0,0,0,
      -0.8+1.6*transition,-1+0.2*sin(Modelica.Constants.pi*transition),0,
      0.8-1.6*transition,-1-0.2*sin(Modelica.Constants.pi*transition),0};
  end Scene07CBase;

  model Scene07COff
    extends Scene07CBase;
    A8FormalFormationNominalSupervisorV1A_20260712 supervisor
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller1
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller2
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller3
      annotation(__MWORKS(SECInstance=true));
  equation
    connect(leaderReferenceSource.y,supervisor.leader_reference);
    connect(vehicleStateSource.y,supervisor.vehicle_state);
    connect(formationOffsetSource.y,supervisor.formation_offset);
    connect(supervisor.formation_reference,formationReference);
    connect(supervisor.diagnostics,supervisorDiagnostics);
    connect(controllerReference1.y,controller1.reference);
    connect(stateSource1.y,controller1.state);
    connect(allocatorLimitSource.y,controller1.allocator_limit);
    connect(controller1.motor_cmd,motorCommand1);
    connect(controller1.diagnostics,controllerDiagnostics1);
    connect(controllerReference2.y,controller2.reference);
    connect(stateSource2.y,controller2.state);
    connect(allocatorLimitSource.y,controller2.allocator_limit);
    connect(controller2.motor_cmd,motorCommand2);
    connect(controller2.diagnostics,controllerDiagnostics2);
    connect(controllerReference3.y,controller3.reference);
    connect(stateSource3.y,controller3.state);
    connect(allocatorLimitSource.y,controller3.allocator_limit);
    connect(controller3.motor_cmd,motorCommand3);
    connect(controller3.diagnostics,controllerDiagnostics3);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,
      Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene07COff;

  partial model Scene07COnPredictiveV5CBase
    extends A8FormationScene07COnRobustV3Plant20260712.TriplePlantBase;
    parameter Real qLimit=3600;
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
    Modelica.Blocks.Sources.RealExpression leaderReferenceSource[9](y=leaderReference);
    Modelica.Blocks.Sources.RealExpression vehicleStateSource[18](y=vehicleState);
    Modelica.Blocks.Sources.RealExpression formationOffsetSource[9](y=formationOffset);
    Modelica.Blocks.Interfaces.RealOutput formationReference[27];
    Modelica.Blocks.Interfaces.RealOutput supervisorDiagnostics[8];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics1[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics2[16];
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics3[16];
    Modelica.Blocks.Sources.RealExpression allocatorLimitSource[2](y={0,qLimit});
    Modelica.Blocks.Sources.RealExpression controllerReference1[11](y={
      formationReference[1],formationReference[2],formationReference[3],
      formationReference[4],formationReference[5],formationReference[6],
      formationReference[7],formationReference[8],formationReference[9],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference2[11](y={
      formationReference[10],formationReference[11],formationReference[12],
      formationReference[13],formationReference[14],formationReference[15],
      formationReference[16],formationReference[17],formationReference[18],0,0});
    Modelica.Blocks.Sources.RealExpression controllerReference3[11](y={
      formationReference[19],formationReference[20],formationReference[21],
      formationReference[22],formationReference[23],formationReference[24],
      formationReference[25],formationReference[26],formationReference[27],0,0});
    Modelica.Blocks.Sources.RealExpression stateSource1[18](y=stateVector1);
    Modelica.Blocks.Sources.RealExpression stateSource2[18](y=stateVector2);
    Modelica.Blocks.Sources.RealExpression stateSource3[18](y=stateVector3);
  equation
    leaderReference={0,0,if time<5 then 0.3*time else 1.5,
      0,0,if time<5 then 0.3 else 0,0,0,0};
    formationOffset={0,0,0,
      -0.8+1.6*transition,-1+0.2*sin(Modelica.Constants.pi*transition),0,
      0.8-1.6*transition,-1-0.2*sin(Modelica.Constants.pi*transition),0};
  end Scene07COnPredictiveV5CBase;

  model Scene07COnPredictiveV5C
    extends Scene07COnPredictiveV5CBase;
    A8FormalFormationPredictiveCBFV5C_20260712 supervisor
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller1
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller2
      annotation(__MWORKS(SECInstance=true));
    A8FormalRAGCACGHTE_20260715 controller3
      annotation(__MWORKS(SECInstance=true));
  equation
    connect(leaderReferenceSource.y,supervisor.leader_reference);
    connect(vehicleStateSource.y,supervisor.vehicle_state);
    connect(formationOffsetSource.y,supervisor.formation_offset);
    connect(supervisor.formation_reference,formationReference);
    connect(supervisor.diagnostics,supervisorDiagnostics);
    connect(controllerReference1.y,controller1.reference);
    connect(stateSource1.y,controller1.state);
    connect(allocatorLimitSource.y,controller1.allocator_limit);
    connect(controller1.motor_cmd,motorCommand1);
    connect(controller1.diagnostics,controllerDiagnostics1);
    connect(controllerReference2.y,controller2.reference);
    connect(stateSource2.y,controller2.state);
    connect(allocatorLimitSource.y,controller2.allocator_limit);
    connect(controller2.motor_cmd,motorCommand2);
    connect(controller2.diagnostics,controllerDiagnostics2);
    connect(controllerReference3.y,controller3.reference);
    connect(stateSource3.y,controller3.state);
    connect(allocatorLimitSource.y,controller3.allocator_limit);
    connect(controller3.motor_cmd,motorCommand3);
    connect(controller3.diagnostics,controllerDiagnostics3);
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=40,
      Tolerance=0.0001,NumberOfIntervals=4000));
  end Scene07COnPredictiveV5C;
end A8RAGCACGHTEFormationValidationPlant20260715;
