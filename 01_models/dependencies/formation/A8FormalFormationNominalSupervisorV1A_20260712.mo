model A8FormalFormationNominalSupervisorV1A_20260712
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(leader_reference, vehicle_state, formation_offset), Right(formation_reference, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  SysplorerEmbeddedCoder.Port.Inport leader_reference 
    annotation (Placement(transformation(origin = {-210, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[9],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport vehicle_state 
    annotation (Placement(transformation(origin = {-210, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[18],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport formation_offset 
    annotation (Placement(transformation(origin = {-210, -80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[9],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport formation_reference 
    annotation (Placement(transformation(origin = {260, 50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[27],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {260, -50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[8],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux leader_demux(portNumber=9) 
    annotation (Placement(transformation(origin = {-185, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=18) 
    annotation (Placement(transformation(origin = {-185, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux offset_demux(portNumber=9) 
    annotation (Placement(transformation(origin = {-185, -80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9)))));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_1_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_1_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_1_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_1_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_1_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_2_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_2_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_2_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_2_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_2_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_3_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_3_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_3_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_3_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_3_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_4_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_4_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_4_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_4_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_4_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_5_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_5_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_5_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_5_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_5_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_6_1(initCond=0) 
    annotation (Placement(transformation(origin = {-144, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_6_2(initCond=0) 
    annotation (Placement(transformation(origin = {-128, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_6_3(initCond=0) 
    annotation (Placement(transformation(origin = {-112, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_6_4(initCond=0) 
    annotation (Placement(transformation(origin = {-96, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay leader_delay_6_5(initCond=0) 
    annotation (Placement(transformation(origin = {-80, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_1_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_1_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 128}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_1_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_1_1(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 128}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_1_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_1_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 116}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_1_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_1_2(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 116}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_1_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_1_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 104}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_1_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_1_3(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 104}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_2_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_2_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 92}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_2_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_2_1(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 92}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_2_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_2_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_2_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_2_2(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_2_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_2_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 68}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_2_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_2_3(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 68}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_3_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 56}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_3_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 56}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_3_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 56}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_3_1(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 56}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_3_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_3_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_3_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_3_2(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate pnom_mux_3_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-70, 32}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pnom_3_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {-50, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate anom_mux_3_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=5) 
    annotation (Placement(transformation(origin = {-25, 32}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn anom_3_3(y=u[1]+2*(u[2]-u[3])+1.6*(u[4]-u[5])) 
    annotation (Placement(transformation(origin = {-5, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate nominal_acceleration_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=9) 
    annotation (Placement(transformation(origin = {20, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux safe_accel_demux(portNumber=9) 
    annotation (Placement(transformation(origin = {70, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {90, 110}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_scale_1(y=min(1,1.5/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-9))) 
    annotation (Placement(transformation(origin = {110, 110}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_1_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 128}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_1_1(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 128}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_1_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 116}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_1_2(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 116}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_1_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 104}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_1_3(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 104}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {90, 85}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_scale_2(y=min(1,1.5/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-9))) 
    annotation (Placement(transformation(origin = {110, 85}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_2_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_2_1(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 92}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_2_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_2_2(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_2_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 68}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_2_3(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 68}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {90, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_scale_3(y=min(1,1.5/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-9))) 
    annotation (Placement(transformation(origin = {110, 60}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_3_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 56}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_3_1(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 56}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_3_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_3_2(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate velocity_reference_mux_3_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {125, 32}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn velocity_reference_3_3(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {140, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate candidate_reference_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=27) 
    annotation (Placement(transformation(origin = {165, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18,u19,u20,u21,u22,u23,u24,u25,u26,u27)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate formation_error_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -123}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn formation_error_1(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {185, -123}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate formation_error_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -141}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn formation_error_2(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {185, -141}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate formation_error_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=6) 
    annotation (Placement(transformation(origin = {165, -159}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn formation_error_3(y=sqrt((u[1]-u[4])^2+(u[2]-u[5])^2+(u[3]-u[6])^2)) 
    annotation (Placement(transformation(origin = {185, -159}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate formation_error_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {205, -135}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn maximum_formation_error(y=max(u[1],max(u[2],u[3]))) 
    annotation (Placement(transformation(origin = {225, -135}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.DeMux safe_reference_demux(portNumber=27) 
    annotation (Placement(transformation(origin = {210, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18,y19,y20,y21,y22,y23,y24,y25,y26,y27)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate output_speed_mux_1(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {210, -188}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn output_speed_1(y=sqrt(u[1]^2+u[2]^2+u[3]^2)) 
    annotation (Placement(transformation(origin = {230, -188}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate output_speed_mux_2(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {210, -206}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn output_speed_2(y=sqrt(u[1]^2+u[2]^2+u[3]^2)) 
    annotation (Placement(transformation(origin = {230, -206}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate output_speed_mux_3(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {210, -224}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn output_speed_3(y=sqrt(u[1]^2+u[2]^2+u[3]^2)) 
    annotation (Placement(transformation(origin = {230, -224}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate output_speed_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=3) 
    annotation (Placement(transformation(origin = {240, -205}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn maximum_reference_speed(y=max(u[1],max(u[2],u[3]))) 
    annotation (Placement(transformation(origin = {250, -205}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant zero_diagnostic(k=0) 
    annotation (Placement(transformation(origin = {225, -50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=true)=-1)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diagnostic_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=8) 
    annotation (Placement(transformation(origin = {245, -50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8)))));
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
equation
  connect(leader_reference, leader_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(vehicle_state, state_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_offset, offset_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, leader_delay_1_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_1.y, leader_delay_1_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_2.y, leader_delay_1_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_3.y, leader_delay_1_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_4.y, leader_delay_1_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, leader_delay_2_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_1.y, leader_delay_2_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_2.y, leader_delay_2_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_3.y, leader_delay_2_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_4.y, leader_delay_2_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, leader_delay_3_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_1.y, leader_delay_3_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_2.y, leader_delay_3_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_3.y, leader_delay_3_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_4.y, leader_delay_3_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, leader_delay_4_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_1.y, leader_delay_4_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_2.y, leader_delay_4_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_3.y, leader_delay_4_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_4.y, leader_delay_4_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, leader_delay_5_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_1.y, leader_delay_5_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_2.y, leader_delay_5_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_3.y, leader_delay_5_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_4.y, leader_delay_5_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, leader_delay_6_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_1.y, leader_delay_6_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_2.y, leader_delay_6_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_3.y, leader_delay_6_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_4.y, leader_delay_6_5.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y1, pnom_mux_1_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y1, pnom_mux_1_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_1_1.y, pnom_1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y7, anom_mux_1_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_1.y, anom_mux_1_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, anom_mux_1_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y4, anom_mux_1_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, anom_mux_1_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_1_1.y, anom_1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y2, pnom_mux_1_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y2, pnom_mux_1_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_1_2.y, pnom_1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y8, anom_mux_1_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_2.y, anom_mux_1_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, anom_mux_1_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y5, anom_mux_1_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, anom_mux_1_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_1_2.y, anom_1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y3, pnom_mux_1_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y3, pnom_mux_1_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_1_3.y, pnom_1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y9, anom_mux_1_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_3.y, anom_mux_1_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, anom_mux_1_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y6, anom_mux_1_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, anom_mux_1_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_1_3.y, anom_1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_5.y, pnom_mux_2_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y4, pnom_mux_2_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_2_1.y, pnom_2_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y7, anom_mux_2_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_1.y, anom_mux_2_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, anom_mux_2_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, anom_mux_2_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, anom_mux_2_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_2_1.y, anom_2_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_5.y, pnom_mux_2_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y5, pnom_mux_2_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_2_2.y, pnom_2_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y8, anom_mux_2_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_2.y, anom_mux_2_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, anom_mux_2_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, anom_mux_2_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, anom_mux_2_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_2_2.y, anom_2_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_5.y, pnom_mux_2_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y6, pnom_mux_2_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_2_3.y, pnom_2_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y9, anom_mux_2_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_3.y, anom_mux_2_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, anom_mux_2_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, anom_mux_2_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, anom_mux_2_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_2_3.y, anom_2_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_1_5.y, pnom_mux_3_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y7, pnom_mux_3_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_3_1.y, pnom_3_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y7, anom_mux_3_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_1.y, anom_mux_3_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, anom_mux_3_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, anom_mux_3_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, anom_mux_3_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_3_1.y, anom_3_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_2_5.y, pnom_mux_3_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y8, pnom_mux_3_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_3_2.y, pnom_3_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y8, anom_mux_3_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_2.y, anom_mux_3_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, anom_mux_3_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, anom_mux_3_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, anom_mux_3_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_3_2.y, anom_3_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_3_5.y, pnom_mux_3_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(offset_demux.y9, pnom_mux_3_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_mux_3_3.y, pnom_3_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y9, anom_mux_3_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_3.y, anom_mux_3_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, anom_mux_3_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, anom_mux_3_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, anom_mux_3_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_mux_3_3.y, anom_3_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_1_1.y, nominal_acceleration_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_1_2.y, nominal_acceleration_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_1_3.y, nominal_acceleration_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_2_1.y, nominal_acceleration_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_2_2.y, nominal_acceleration_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_2_3.y, nominal_acceleration_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_3_1.y, nominal_acceleration_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_3_2.y, nominal_acceleration_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anom_3_3.y, nominal_acceleration_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(nominal_acceleration_mux.y, safe_accel_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y4, velocity_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y5, velocity_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y6, velocity_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_mux_1.y, velocity_scale_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y4, velocity_reference_mux_1_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_1.y, velocity_reference_mux_1_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_1_1.y, velocity_reference_1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y5, velocity_reference_mux_1_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_1.y, velocity_reference_mux_1_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_1_2.y, velocity_reference_1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_demux.y6, velocity_reference_mux_1_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_1.y, velocity_reference_mux_1_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_1_3.y, velocity_reference_1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, velocity_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, velocity_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, velocity_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_mux_2.y, velocity_scale_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, velocity_reference_mux_2_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_2.y, velocity_reference_mux_2_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_2_1.y, velocity_reference_2_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, velocity_reference_mux_2_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_2.y, velocity_reference_mux_2_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_2_2.y, velocity_reference_2_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, velocity_reference_mux_2_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_2.y, velocity_reference_mux_2_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_2_3.y, velocity_reference_2_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, velocity_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, velocity_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, velocity_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_mux_3.y, velocity_scale_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_4_5.y, velocity_reference_mux_3_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_3.y, velocity_reference_mux_3_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_3_1.y, velocity_reference_3_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_5_5.y, velocity_reference_mux_3_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_3.y, velocity_reference_mux_3_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_3_2.y, velocity_reference_3_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(leader_delay_6_5.y, velocity_reference_mux_3_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_scale_3.y, velocity_reference_mux_3_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_mux_3_3.y, velocity_reference_3_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_1.y, candidate_reference_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_2.y, candidate_reference_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_3.y, candidate_reference_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_1_1.y, candidate_reference_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_1_2.y, candidate_reference_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_1_3.y, candidate_reference_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y1, candidate_reference_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y2, candidate_reference_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y3, candidate_reference_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_1.y, candidate_reference_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_2.y, candidate_reference_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_3.y, candidate_reference_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_2_1.y, candidate_reference_mux.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_2_2.y, candidate_reference_mux.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_2_3.y, candidate_reference_mux.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y4, candidate_reference_mux.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y5, candidate_reference_mux.u17) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y6, candidate_reference_mux.u18) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_1.y, candidate_reference_mux.u19) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_2.y, candidate_reference_mux.u20) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_3.y, candidate_reference_mux.u21) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_3_1.y, candidate_reference_mux.u22) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_3_2.y, candidate_reference_mux.u23) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(velocity_reference_3_3.y, candidate_reference_mux.u24) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y7, candidate_reference_mux.u25) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y8, candidate_reference_mux.u26) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_accel_demux.y9, candidate_reference_mux.u27) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(candidate_reference_mux.y, formation_reference) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, formation_error_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, formation_error_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, formation_error_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_1.y, formation_error_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_2.y, formation_error_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_1_3.y, formation_error_mux_1.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_mux_1.y, formation_error_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, formation_error_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, formation_error_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, formation_error_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_1.y, formation_error_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_2.y, formation_error_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_2_3.y, formation_error_mux_2.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_mux_2.y, formation_error_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, formation_error_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, formation_error_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, formation_error_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_1.y, formation_error_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_2.y, formation_error_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pnom_3_3.y, formation_error_mux_3.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_mux_3.y, formation_error_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_1.y, formation_error_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_2.y, formation_error_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_3.y, formation_error_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(formation_error_mux.y, maximum_formation_error.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(candidate_reference_mux.y, safe_reference_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y4, output_speed_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y5, output_speed_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y6, output_speed_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_mux_1.y, output_speed_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y13, output_speed_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y14, output_speed_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y15, output_speed_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_mux_2.y, output_speed_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y22, output_speed_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y23, output_speed_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(safe_reference_demux.y24, output_speed_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_mux_3.y, output_speed_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_1.y, output_speed_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_2.y, output_speed_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_3.y, output_speed_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(output_speed_mux.y, maximum_reference_speed.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(maximum_formation_error.y, diagnostic_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero_diagnostic.y, diagnostic_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(maximum_reference_speed.y, diagnostic_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diagnostic_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8FormalFormationNominalSupervisorV1A_20260712;