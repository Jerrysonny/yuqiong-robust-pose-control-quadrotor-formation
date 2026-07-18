model A8CBFPredictiveKernelV5C_20260712
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  // 顺序投影内核将三机名义加速度依次投影到成对安全约束集合。
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(vehicle_state, nominal_acceleration), Right(safe_acceleration, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  SysplorerEmbeddedCoder.Port.Inport vehicle_state 
    annotation (Placement(transformation(origin = {-180, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[18],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport nominal_acceleration 
    annotation (Placement(transformation(origin = {-180, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[9],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport safe_acceleration 
    annotation (Placement(transformation(origin = {230, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[9],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {230, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[8],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=18) 
    annotation (Placement(transformation(origin = {-155, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux accel_demux(portNumber=9) 
    annotation (Placement(transformation(origin = {-155, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9)))));
  // 多轮成对投影减少约束耦合造成的剩余违约量。
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {-88, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {-88, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_1 
    annotation (Placement(transformation(origin = {-76, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_1(portNumber=6) 
    annotation (Placement(transformation(origin = {-66, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_1(portNumber=4) 
    annotation (Placement(transformation(origin = {-66, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {-56, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {-56, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_2 
    annotation (Placement(transformation(origin = {-44, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_2(portNumber=6) 
    annotation (Placement(transformation(origin = {-34, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_2(portNumber=4) 
    annotation (Placement(transformation(origin = {-34, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {-24, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {-24, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_3 
    annotation (Placement(transformation(origin = {-12, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_3(portNumber=6) 
    annotation (Placement(transformation(origin = {-2, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_3(portNumber=4) 
    annotation (Placement(transformation(origin = {-2, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_4(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {8, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_4(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {8, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_4 
    annotation (Placement(transformation(origin = {20, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_4(portNumber=6) 
    annotation (Placement(transformation(origin = {30, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_4(portNumber=4) 
    annotation (Placement(transformation(origin = {30, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_5(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {40, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_5(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {40, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_5 
    annotation (Placement(transformation(origin = {52, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_5(portNumber=6) 
    annotation (Placement(transformation(origin = {62, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_5(portNumber=4) 
    annotation (Placement(transformation(origin = {62, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_6(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {72, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_6(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {72, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_6 
    annotation (Placement(transformation(origin = {84, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_6(portNumber=6) 
    annotation (Placement(transformation(origin = {94, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_6(portNumber=4) 
    annotation (Placement(transformation(origin = {94, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_7(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {104, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_7(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {104, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_7 
    annotation (Placement(transformation(origin = {116, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_7(portNumber=6) 
    annotation (Placement(transformation(origin = {126, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_7(portNumber=4) 
    annotation (Placement(transformation(origin = {126, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_8(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {136, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_8(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {136, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_8 
    annotation (Placement(transformation(origin = {148, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_8(portNumber=6) 
    annotation (Placement(transformation(origin = {158, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_8(portNumber=4) 
    annotation (Placement(transformation(origin = {158, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_9(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {168, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_9(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {168, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_9 
    annotation (Placement(transformation(origin = {180, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_9(portNumber=6) 
    annotation (Placement(transformation(origin = {190, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_9(portNumber=4) 
    annotation (Placement(transformation(origin = {190, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_10(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {200, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_10(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {200, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_10 
    annotation (Placement(transformation(origin = {212, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_10(portNumber=6) 
    annotation (Placement(transformation(origin = {222, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_10(portNumber=4) 
    annotation (Placement(transformation(origin = {222, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_11(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {232, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_11(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {232, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_11 
    annotation (Placement(transformation(origin = {244, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_11(portNumber=6) 
    annotation (Placement(transformation(origin = {254, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_11(portNumber=4) 
    annotation (Placement(transformation(origin = {254, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_state_mux_12(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {264, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pair_accel_mux_12(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {264, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 projector_12 
    annotation (Placement(transformation(origin = {276, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_output_demux_12(portNumber=6) 
    annotation (Placement(transformation(origin = {286, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux projector_diagnostic_demux_12(portNumber=4) 
    annotation (Placement(transformation(origin = {286, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_1(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 98}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_2(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 86}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_3(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 74}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_4(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 62}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_5(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_6(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 38}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_7(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 26}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_8(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 14}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn final_accel_9(y=max(min(u,4),-4)) 
    annotation (Placement(transformation(origin = {180, 2}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate safe_acceleration_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=9) 
    annotation (Placement(transformation(origin = {205, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_state_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {150, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_accel_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 audit_projector_1 
    annotation (Placement(transformation(origin = {180, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux audit_diagnostic_demux_1(portNumber=4) 
    annotation (Placement(transformation(origin = {195, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate distance_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {150, -183}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn distance_1(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {175, -183}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_state_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {150, -126}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_accel_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -126}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 audit_projector_2 
    annotation (Placement(transformation(origin = {180, -126}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux audit_diagnostic_demux_2(portNumber=4) 
    annotation (Placement(transformation(origin = {195, -126}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate distance_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {150, -201}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn distance_2(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {175, -201}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_state_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {150, -154}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_accel_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -154}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  A8CBFPairProjectorPredictiveV5C_20260712 audit_projector_3 
    annotation (Placement(transformation(origin = {180, -154}, extent = {{-10, -10}, {10, 10}})),__MWORKS(SECInstance=true,PortLabels(labelType="PortName")));
  SysplorerEmbeddedCoder.SignalRouting.DeMux audit_diagnostic_demux_3(portNumber=4) 
    annotation (Placement(transformation(origin = {195, -154}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate distance_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {150, -219}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn distance_3(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {175, -219}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate audit_residual_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {205, -125}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn minimum_residual(y=min(u[1],min(u[2],u[3]))) 
    annotation (Placement(transformation(origin = {220, -125}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn infeasible(y=if u < -1e-6 then 1 else 0) 
    annotation (Placement(transformation(origin = {235, -125}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate distance_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {205, -215}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn minimum_distance(y=min(u[1],min(u[2],u[3]))) 
    annotation (Placement(transformation(origin = {220, -215}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate active_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {205, -245}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.Utilities.Fcn active_count(y=u[1]+u[2]+u[3]+u[4]+u[5]+u[6]+u[7]+u[8]+u[9]+u[10]+u[11]+u[12]) 
    annotation (Placement(transformation(origin = {220, -245}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate correction_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {205, -265}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  SysplorerEmbeddedCoder.Utilities.Fcn maximum_correction(y=max(u[1],max(u[2],max(u[3],max(u[4],max(u[5],max(u[6],max(u[7],max(u[8],max(u[9],max(u[10],max(u[11],u[12])))))))))))) 
    annotation (Placement(transformation(origin = {220, -265}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate final_accel_abs_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=9) 
    annotation (Placement(transformation(origin = {205, -285}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9)))));
  SysplorerEmbeddedCoder.Utilities.Fcn maximum_abs_acceleration(y=max(abs(u[1]),max(abs(u[2]),max(abs(u[3]),max(abs(u[4]),max(abs(u[5]),max(abs(u[6]),max(abs(u[7]),max(abs(u[8]),abs(u[9])))))))))) 
    annotation (Placement(transformation(origin = {220, -285}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant projection_count(k=12) 
    annotation (Placement(transformation(origin = {205, -305}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Sources.Constant status_code(k=513) 
    annotation (Placement(transformation(origin = {205, -325}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diagnostic_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=8) 
    annotation (Placement(transformation(origin = {220, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8)))));
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
equation
  connect(vehicle_state, state_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(nominal_acceleration, accel_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_1.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_1.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_1.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_1.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_1.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_1.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y1, pair_accel_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y2, pair_accel_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y3, pair_accel_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y4, pair_accel_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y5, pair_accel_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y6, pair_accel_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_1.y, projector_1.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_1.y, projector_1.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_1.acceleration_out, projector_output_demux_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_1.diagnostics, projector_diagnostic_demux_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_2.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_2.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_2.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_2.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_2.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_2.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y1, pair_accel_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y2, pair_accel_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y3, pair_accel_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y7, pair_accel_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y8, pair_accel_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y9, pair_accel_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_2.y, projector_2.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_2.y, projector_2.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_2.acceleration_out, projector_output_demux_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_2.diagnostics, projector_diagnostic_demux_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_3.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_3.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_3.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_3.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_3.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_3.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y4, pair_accel_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y5, pair_accel_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_1.y6, pair_accel_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y4, pair_accel_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y5, pair_accel_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y6, pair_accel_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_3.y, projector_3.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_3.y, projector_3.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_3.acceleration_out, projector_output_demux_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_3.diagnostics, projector_diagnostic_demux_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_4.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_4.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_4.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_4.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_4.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_4.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_4.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_4.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_4.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_4.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y1, pair_accel_mux_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y2, pair_accel_mux_4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_2.y3, pair_accel_mux_4.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y1, pair_accel_mux_4.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y2, pair_accel_mux_4.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y3, pair_accel_mux_4.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_4.y, projector_4.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_4.y, projector_4.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_4.acceleration_out, projector_output_demux_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_4.diagnostics, projector_diagnostic_demux_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_5.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_5.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_5.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_5.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_5.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_5.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_5.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_5.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_5.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_5.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_5.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y1, pair_accel_mux_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y2, pair_accel_mux_5.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y3, pair_accel_mux_5.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y4, pair_accel_mux_5.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y5, pair_accel_mux_5.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_3.y6, pair_accel_mux_5.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_5.y, projector_5.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_5.y, projector_5.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_5.acceleration_out, projector_output_demux_5.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_5.diagnostics, projector_diagnostic_demux_5.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_6.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_6.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_6.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_6.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_6.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_6.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_6.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_6.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_6.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_6.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_6.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_6.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y4, pair_accel_mux_6.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y5, pair_accel_mux_6.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_4.y6, pair_accel_mux_6.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y4, pair_accel_mux_6.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y5, pair_accel_mux_6.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y6, pair_accel_mux_6.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_6.y, projector_6.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_6.y, projector_6.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_6.acceleration_out, projector_output_demux_6.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_6.diagnostics, projector_diagnostic_demux_6.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_7.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_7.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_7.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_7.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_7.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_7.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_7.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_7.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_7.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_7.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_7.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_7.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y1, pair_accel_mux_7.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y2, pair_accel_mux_7.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_5.y3, pair_accel_mux_7.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y1, pair_accel_mux_7.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y2, pair_accel_mux_7.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y3, pair_accel_mux_7.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_7.y, projector_7.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_7.y, projector_7.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_7.acceleration_out, projector_output_demux_7.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_7.diagnostics, projector_diagnostic_demux_7.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_8.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_8.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_8.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_8.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_8.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_8.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_8.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_8.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_8.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_8.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_8.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_8.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y1, pair_accel_mux_8.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y2, pair_accel_mux_8.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y3, pair_accel_mux_8.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y4, pair_accel_mux_8.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y5, pair_accel_mux_8.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_6.y6, pair_accel_mux_8.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_8.y, projector_8.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_8.y, projector_8.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_8.acceleration_out, projector_output_demux_8.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_8.diagnostics, projector_diagnostic_demux_8.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_9.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_9.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_9.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_9.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_9.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_9.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_9.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_9.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_9.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_9.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_9.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_9.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y4, pair_accel_mux_9.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y5, pair_accel_mux_9.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_7.y6, pair_accel_mux_9.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y4, pair_accel_mux_9.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y5, pair_accel_mux_9.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y6, pair_accel_mux_9.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_9.y, projector_9.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_9.y, projector_9.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_9.acceleration_out, projector_output_demux_9.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_9.diagnostics, projector_diagnostic_demux_9.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_10.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_10.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_10.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_10.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_10.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_10.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_10.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_10.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_10.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_10.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_10.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_10.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y1, pair_accel_mux_10.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y2, pair_accel_mux_10.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_8.y3, pair_accel_mux_10.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y1, pair_accel_mux_10.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y2, pair_accel_mux_10.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y3, pair_accel_mux_10.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_10.y, projector_10.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_10.y, projector_10.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_10.acceleration_out, projector_output_demux_10.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_10.diagnostics, projector_diagnostic_demux_10.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, pair_state_mux_11.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, pair_state_mux_11.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, pair_state_mux_11.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, pair_state_mux_11.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, pair_state_mux_11.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, pair_state_mux_11.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_11.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_11.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_11.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_11.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_11.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_11.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y1, pair_accel_mux_11.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y2, pair_accel_mux_11.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y3, pair_accel_mux_11.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y4, pair_accel_mux_11.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y5, pair_accel_mux_11.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_9.y6, pair_accel_mux_11.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_11.y, projector_11.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_11.y, projector_11.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_11.acceleration_out, projector_output_demux_11.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_11.diagnostics, projector_diagnostic_demux_11.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, pair_state_mux_12.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, pair_state_mux_12.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, pair_state_mux_12.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, pair_state_mux_12.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, pair_state_mux_12.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, pair_state_mux_12.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, pair_state_mux_12.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, pair_state_mux_12.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, pair_state_mux_12.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, pair_state_mux_12.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, pair_state_mux_12.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, pair_state_mux_12.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y4, pair_accel_mux_12.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y5, pair_accel_mux_12.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_10.y6, pair_accel_mux_12.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y4, pair_accel_mux_12.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y5, pair_accel_mux_12.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y6, pair_accel_mux_12.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_state_mux_12.y, projector_12.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pair_accel_mux_12.y, projector_12.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_12.acceleration_out, projector_output_demux_12.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_12.diagnostics, projector_diagnostic_demux_12.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y1, final_accel_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y2, final_accel_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_11.y3, final_accel_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y1, final_accel_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y2, final_accel_5.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y3, final_accel_6.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y4, final_accel_7.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y5, final_accel_8.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_output_demux_12.y6, final_accel_9.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_1.y, safe_acceleration_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_2.y, safe_acceleration_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_3.y, safe_acceleration_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_4.y, safe_acceleration_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_5.y, safe_acceleration_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_6.y, safe_acceleration_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_7.y, safe_acceleration_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_8.y, safe_acceleration_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_9.y, safe_acceleration_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_acceleration_mux.y, safe_acceleration) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, audit_state_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, audit_state_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, audit_state_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, audit_state_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, audit_state_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, audit_state_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, audit_state_mux_1.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, audit_state_mux_1.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, audit_state_mux_1.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, audit_state_mux_1.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, audit_state_mux_1.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, audit_state_mux_1.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_1.y, audit_accel_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_2.y, audit_accel_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_3.y, audit_accel_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_4.y, audit_accel_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_5.y, audit_accel_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_6.y, audit_accel_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_state_mux_1.y, audit_projector_1.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_accel_mux_1.y, audit_projector_1.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_projector_1.diagnostics, audit_diagnostic_demux_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, distance_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, distance_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, distance_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, distance_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, distance_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, distance_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_mux_1.y, distance_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, audit_state_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, audit_state_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, audit_state_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, audit_state_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, audit_state_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, audit_state_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, audit_state_mux_2.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, audit_state_mux_2.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, audit_state_mux_2.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, audit_state_mux_2.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, audit_state_mux_2.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, audit_state_mux_2.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_1.y, audit_accel_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_2.y, audit_accel_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_3.y, audit_accel_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_7.y, audit_accel_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_8.y, audit_accel_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_9.y, audit_accel_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_state_mux_2.y, audit_projector_2.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_accel_mux_2.y, audit_projector_2.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_projector_2.diagnostics, audit_diagnostic_demux_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, distance_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, distance_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, distance_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, distance_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, distance_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, distance_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_mux_2.y, distance_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, audit_state_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, audit_state_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, audit_state_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, audit_state_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, audit_state_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, audit_state_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, audit_state_mux_3.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, audit_state_mux_3.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, audit_state_mux_3.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, audit_state_mux_3.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, audit_state_mux_3.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, audit_state_mux_3.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_4.y, audit_accel_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_5.y, audit_accel_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_6.y, audit_accel_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_7.y, audit_accel_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_8.y, audit_accel_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_9.y, audit_accel_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_state_mux_3.y, audit_projector_3.pair_state) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_accel_mux_3.y, audit_projector_3.acceleration_in) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_projector_3.diagnostics, audit_diagnostic_demux_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, distance_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, distance_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, distance_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, distance_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, distance_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, distance_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_mux_3.y, distance_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_diagnostic_demux_1.y1, audit_residual_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_diagnostic_demux_2.y1, audit_residual_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_diagnostic_demux_3.y1, audit_residual_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(audit_residual_mux.y, minimum_residual.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(minimum_residual.y, infeasible.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_1.y, distance_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_2.y, distance_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_3.y, distance_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(distance_mux.y, minimum_distance.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_1.y4, active_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_2.y4, active_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_3.y4, active_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_4.y4, active_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_5.y4, active_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_6.y4, active_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_7.y4, active_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_8.y4, active_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_9.y4, active_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_10.y4, active_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_11.y4, active_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_12.y4, active_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(active_mux.y, active_count.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_1.y3, correction_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_2.y3, correction_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_3.y3, correction_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_4.y3, correction_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_5.y3, correction_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_6.y3, correction_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_7.y3, correction_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_8.y3, correction_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_9.y3, correction_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_10.y3, correction_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_11.y3, correction_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projector_diagnostic_demux_12.y3, correction_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(correction_mux.y, maximum_correction.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_1.y, final_accel_abs_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_2.y, final_accel_abs_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_3.y, final_accel_abs_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_4.y, final_accel_abs_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_5.y, final_accel_abs_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_6.y, final_accel_abs_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_7.y, final_accel_abs_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_8.y, final_accel_abs_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_9.y, final_accel_abs_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_accel_abs_mux.y, maximum_abs_acceleration.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(minimum_distance.y, diagnostic_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(minimum_residual.y, diagnostic_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(active_count.y, diagnostic_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(maximum_correction.y, diagnostic_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(infeasible.y, diagnostic_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projection_count.y, diagnostic_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(maximum_abs_acceleration.y, diagnostic_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(status_code.y, diagnostic_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diagnostic_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8CBFPredictiveKernelV5C_20260712;