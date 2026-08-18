package A8RAGCACGHTEStepPlant20260715
  extends Modelica.Icons.Package;

  model Scene01S_X
    extends A8RAGCACGHTEPlant20260715.PlantBase;
    A8FormalRAGCACGHTE_20260715 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[16]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(allocatorLimit.y,controller.allocator_limit)
      annotation(Line(points={{-44,-65},{-34,-65},{-34,-12},{-30,-12}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={if time<10 then 0 else 1,0,if time<5 then 1.5*time/5 else 1.5,0,0,0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=30,Tolerance=0.0001,NumberOfIntervals=3000));
  end Scene01S_X;

  model Scene01S_Y
    extends A8RAGCACGHTEPlant20260715.PlantBase;
    A8FormalRAGCACGHTE_20260715 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[16]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(allocatorLimit.y,controller.allocator_limit)
      annotation(Line(points={{-44,-65},{-34,-65},{-34,-12},{-30,-12}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={0,if time<10 then 0 else 1,if time<5 then 1.5*time/5 else 1.5,0,0,0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=30,Tolerance=0.0001,NumberOfIntervals=3000));
  end Scene01S_Y;

  model Scene01S_Z
    extends A8RAGCACGHTEPlant20260715.PlantBase;
    A8FormalRAGCACGHTE_20260715 controller
      annotation(Placement(transformation(origin={-15,0},extent={{-15,-15},{15,15}})),__MWORKS(SECInstance=true));
    Modelica.Blocks.Interfaces.RealOutput controllerDiagnostics[16]
      annotation(Placement(transformation(origin={5,-35},extent={{-5,-5},{5,5}})));
    Modelica.Blocks.Sources.RealExpression rotorSpeedARDG1Regression[4](y={speedSensor[1].w,speedSensor[2].w,speedSensor[3].w,speedSensor[4].w});
    Modelica.Blocks.Sources.RealExpression enableARDG1Regression[1](y={1});
    Modelica.Blocks.Sources.RealExpression timeARDG1Regression[1](y={time});
  equation
    connect(rotorSpeedARDG1Regression.y,controller.ardg1_rotor_speed);
    connect(enableARDG1Regression.y,controller.ardg1_enable);
    connect(timeARDG1Regression.y,controller.ardg1_time);
    connect(referenceSource.y,controller.reference)
      annotation(Line(points={{-44,35},{-30,35},{-30,8}},color={0,0,127}));
    connect(stateSource.y,controller.state)
      annotation(Line(points={{-44,-35},{-30,-35},{-30,-8}},color={0,0,127}));
    connect(allocatorLimit.y,controller.allocator_limit)
      annotation(Line(points={{-44,-65},{-34,-65},{-34,-12},{-30,-12}},color={0,0,127}));
    connect(controller.motor_cmd,motorCommand)
      annotation(Line(points={{0,8},{5,8},{5,35}},color={0,0,127}));
    connect(controller.diagnostics,controllerDiagnostics)
      annotation(Line(points={{0,-8},{5,-8},{5,-35}},color={0,0,127}));
    referenceVector={0,0,if time<5 then time/5 else if time<10 then 1 else 2,0,0,0,0,0,0,0,0};
    annotation(experiment(Algorithm=Dassl,StartTime=0,StopTime=30,Tolerance=0.0001,NumberOfIntervals=3000));
  end Scene01S_Z;
end A8RAGCACGHTEStepPlant20260715;
