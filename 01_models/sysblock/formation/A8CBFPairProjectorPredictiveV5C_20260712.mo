model A8CBFPairProjectorPredictiveV5C_20260712
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  // 对单个机对执行预测CBF投影，只在名义加速度违反安全约束时修正。
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(pair_state, acceleration_in), Right(acceleration_out, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  SysplorerEmbeddedCoder.Port.Inport pair_state 
    annotation (Placement(transformation(origin = {-120, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[12],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport acceleration_in 
    annotation (Placement(transformation(origin = {-120, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[6],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport acceleration_out 
    annotation (Placement(transformation(origin = {150, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[6],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {150, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[4],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=12) 
    annotation (Placement(transformation(origin = {-95, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux accel_demux(portNumber=6) 
    annotation (Placement(transformation(origin = {-95, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate context(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=18) 
    annotation (Placement(transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18)))));
  // 投影修正沿预测相对位置方向成对施加，保持两机作用对称。
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a1_1(y=u[13]+((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[1]-u[7])+0.08*(u[4]-u[10])))) 
    annotation (Placement(transformation(origin = {0, 55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a2_1(y=u[16]-((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[1]-u[7])+0.08*(u[4]-u[10])))) 
    annotation (Placement(transformation(origin = {0, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a1_2(y=u[14]+((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[2]-u[8])+0.08*(u[5]-u[11])))) 
    annotation (Placement(transformation(origin = {0, 35}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a2_2(y=u[17]-((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[2]-u[8])+0.08*(u[5]-u[11])))) 
    annotation (Placement(transformation(origin = {0, -45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a1_3(y=u[15]+((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[3]-u[9])+0.08*(u[6]-u[12])))) 
    annotation (Placement(transformation(origin = {0, 15}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn projected_a2_3(y=u[18]-((max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9)))*(((u[3]-u[9])+0.08*(u[6]-u[12])))) 
    annotation (Placement(transformation(origin = {0, -65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate acceleration_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {70, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate projected_context(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=18) 
    annotation (Placement(transformation(origin = {70, -20}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18)))));
  SysplorerEmbeddedCoder.Utilities.Fcn residual_before(y=((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))-(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))) 
    annotation (Placement(transformation(origin = {90, -35}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn residual_after(y=((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))-(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))) 
    annotation (Placement(transformation(origin = {90, -50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn correction_norm(y=sqrt(2)*(max(0,(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225))-((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))))/(2*sqrt(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)+1e-9))) 
    annotation (Placement(transformation(origin = {90, -65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn active(y=if ((((u[1]-u[7])+0.08*(u[4]-u[10])))*(u[13]-u[16])+(((u[2]-u[8])+0.08*(u[5]-u[11])))*(u[14]-u[17])+(((u[3]-u[9])+0.08*(u[6]-u[12])))*(u[15]-u[18]))<(-(((u[4]-u[10]))^2+((u[5]-u[11]))^2+((u[6]-u[12]))^2)-5*((((u[1]-u[7])+0.08*(u[4]-u[10])))*((u[4]-u[10]))+(((u[2]-u[8])+0.08*(u[5]-u[11])))*((u[5]-u[11]))+(((u[3]-u[9])+0.08*(u[6]-u[12])))*((u[6]-u[12])))-3*(((((u[1]-u[7])+0.08*(u[4]-u[10])))^2+(((u[2]-u[8])+0.08*(u[5]-u[11])))^2+(((u[3]-u[9])+0.08*(u[6]-u[12])))^2)-0.378225)) then 1 else 0) 
    annotation (Placement(transformation(origin = {90, -80}, extent = {{-10, -10}, {10, 10}})));
  // 诊断输出投影前后残差、修正范数和激活标志。
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diagnostic_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=4) 
    annotation (Placement(transformation(origin = {120, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
equation
  connect(pair_state, state_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_in, accel_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, context.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, context.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, context.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, context.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, context.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, context.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, context.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, context.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, context.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, context.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, context.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, context.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y1, context.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y2, context.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y3, context.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y4, context.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y5, context.u17) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(accel_demux.y6, context.u18) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a2_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a2_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, projected_a2_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_1.y, acceleration_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_2.y, acceleration_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_3.y, acceleration_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_1.y, acceleration_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_2.y, acceleration_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_3.y, acceleration_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_mux.y, acceleration_out) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, projected_context.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, projected_context.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, projected_context.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, projected_context.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, projected_context.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, projected_context.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, projected_context.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, projected_context.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, projected_context.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, projected_context.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, projected_context.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, projected_context.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_1.y, projected_context.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_2.y, projected_context.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a1_3.y, projected_context.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_1.y, projected_context.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_2.y, projected_context.u17) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_a2_3.y, projected_context.u18) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, residual_before.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(projected_context.y, residual_after.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, correction_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(context.y, active.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(residual_before.y, diagnostic_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(residual_after.y, diagnostic_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(correction_norm.y, diagnostic_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(active.y, diagnostic_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diagnostic_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8CBFPairProjectorPredictiveV5C_20260712;