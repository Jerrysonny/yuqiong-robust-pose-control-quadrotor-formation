model A8FormalINDICommandProxyV1A_20260712
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(reference, state), Right(motor_cmd, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  SysplorerEmbeddedCoder.Port.Inport reference 
    annotation (Placement(transformation(origin = {-120, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[11],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport state 
    annotation (Placement(transformation(origin = {-120, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[18],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport motor_cmd 
    annotation (Placement(transformation(origin = {140, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[4],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {140, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[12],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux reference_demux(portNumber=11) 
    annotation (Placement(transformation(origin = {-100, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=18) 
    annotation (Placement(transformation(origin = {-100, -35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate input_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=29) 
    annotation (Placement(transformation(origin = {-80, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18,u19,u20,u21,u22,u23,u24,u25,u26,u27,u28,u29)))));
  SysplorerEmbeddedCoder.Utilities.Fcn force_x(y=0.163156684*(-3.1*(u[12]-u[1])-3.0*(u[15]-u[4])+u[7])) 
    annotation (Placement(transformation(origin = {-55, 60}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_y(y=0.163156684*(-3.1*(u[13]-u[2])-3.0*(u[16]-u[5])+u[8])) 
    annotation (Placement(transformation(origin = {-55, 30}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_z(y=0.163156684*(-3.0*(u[14]-u[3])-2.7*(u[17]-u[6])+u[9]+9.81)) 
    annotation (Placement(transformation(origin = {-55, 0}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux force_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {-25, 30}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn b3x(y=u[1]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {5, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3y(y=u[2]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {5, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3z(y=u[3]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {5, 25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn anorm(y=sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {5, 5}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux geo_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {30, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn thrust(y=u[4]*(u[1]*u[24]+u[2]*u[27]+u[3]*u[30])) 
    annotation (Placement(transformation(origin = {55, 70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn alpha_cmd_x(y=8595.05449458058*(-0.013*(0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-((u[3]/sqrt(u[2]^2+u[3]^2+1e-9))*u[27]+(-u[2]/sqrt(u[2]^2+u[3]^2+1e-9))*u[30])))-0.0030*u[31])) 
    annotation (Placement(transformation(origin = {55, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn alpha_cmd_y(y=8595.11317201388*(-0.013*(0.5*((u[24]*((u[2]^2+u[3]^2)/sqrt(u[2]^2+u[3]^2+1e-9))+u[27]*(-u[1]*u[2]/sqrt(u[2]^2+u[3]^2+1e-9))+u[30]*(-u[1]*u[3]/sqrt(u[2]^2+u[3]^2+1e-9)))-(u[1]*u[22]+u[2]*u[25]+u[3]*u[28])))-0.0030*u[32])) 
    annotation (Placement(transformation(origin = {55, 20}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay omega_x_filtered_delay(initCond=0) 
    annotation (Placement(transformation(origin = {65, 5}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate omega_x_filter_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {80, 5}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn omega_x_filtered_next(y=0.533488091091103*u[30]+(1-0.533488091091103)*u[27]) 
    annotation (Placement(transformation(origin = {95, 5}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux alpha_x_filter_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {110, 5}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn alpha_filtered_x(y=(u[1]-u[2])/0.01) 
    annotation (Placement(transformation(origin = {125, 5}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux alpha_increment_mux_x(portNumber=2) 
    annotation (Placement(transformation(origin = {140, 5}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn delta_alpha_x(y=u[1]-u[2]) 
    annotation (Placement(transformation(origin = {155, 5}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay omega_y_filtered_delay(initCond=0) 
    annotation (Placement(transformation(origin = {65, -15}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate omega_y_filter_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {80, -15}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn omega_y_filtered_next(y=0.533488091091103*u[30]+(1-0.533488091091103)*u[28]) 
    annotation (Placement(transformation(origin = {95, -15}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux alpha_y_filter_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {110, -15}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn alpha_filtered_y(y=(u[1]-u[2])/0.01) 
    annotation (Placement(transformation(origin = {125, -15}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux alpha_increment_mux_y(portNumber=2) 
    annotation (Placement(transformation(origin = {140, -15}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn delta_alpha_y(y=u[1]-u[2]) 
    annotation (Placement(transformation(origin = {155, -15}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay q_previous_1(initCond=200.070883755) 
    annotation (Placement(transformation(origin = {170, 2}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay q_previous_2(initCond=200.070883755) 
    annotation (Placement(transformation(origin = {170, -16}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay q_previous_3(initCond=200.070883755) 
    annotation (Placement(transformation(origin = {170, -34}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay q_previous_4(initCond=200.070883755) 
    annotation (Placement(transformation(origin = {170, -52}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate indi_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=7) 
    annotation (Placement(transformation(origin = {185, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q1(y=u[4]-0.342758589267605*u[2]-0.342756249310719*u[3]+(500*u[1]-(u[4]+u[5]+u[6]+u[7]))/4) 
    annotation (Placement(transformation(origin = {200, 60}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag1(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {215, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q2(y=u[5]+0.342758589267605*u[2]-0.342756249310719*u[3]+(500*u[1]-(u[4]+u[5]+u[6]+u[7]))/4) 
    annotation (Placement(transformation(origin = {200, 40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag2(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {215, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q3(y=u[6]+0.342758589267605*u[2]+0.342756249310719*u[3]+(500*u[1]-(u[4]+u[5]+u[6]+u[7]))/4) 
    annotation (Placement(transformation(origin = {200, 20}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag3(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {215, -55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q4(y=u[7]-0.342758589267605*u[2]+0.342756249310719*u[3]+(500*u[1]-(u[4]+u[5]+u[6]+u[7]))/4) 
    annotation (Placement(transformation(origin = {200, 0}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag4(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {215, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn tau_cmd_x(y=0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])+u[2]/8595.05449458058) 
    annotation (Placement(transformation(origin = {200, 100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn tau_cmd_y(y=0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])+u[3]/8595.11317201388) 
    annotation (Placement(transformation(origin = {200, 115}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux control_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {80, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_raw_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {115, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn desaturation_gain_1(y=min(min(min(min(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))+max(max(max(max(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))) 
    annotation (Placement(transformation(origin = {130, 70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux1(portNumber=2) 
    annotation (Placement(transformation(origin = {130, 32}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {145, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux2(portNumber=2) 
    annotation (Placement(transformation(origin = {130, 14}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {145, 14}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux3(portNumber=2) 
    annotation (Placement(transformation(origin = {130, -4}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {145, -4}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux4(portNumber=2) 
    annotation (Placement(transformation(origin = {130, -22}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_4(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {145, -22}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_pass1_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {160, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn desaturation_gain_2(y=0.5*(min(min(min(min(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))+max(max(max(max(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0)))) 
    annotation (Placement(transformation(origin = {175, 70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux1(portNumber=3) 
    annotation (Placement(transformation(origin = {175, 32}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_1(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {190, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt1 
    annotation (Placement(transformation(origin = {205, 32}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux2(portNumber=3) 
    annotation (Placement(transformation(origin = {175, 14}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_2(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {190, 14}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt2 
    annotation (Placement(transformation(origin = {205, 14}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign2(k=-1) 
    annotation (Placement(transformation(origin = {220, 14}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux3(portNumber=3) 
    annotation (Placement(transformation(origin = {175, -4}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_3(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {190, -4}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt3 
    annotation (Placement(transformation(origin = {205, -4}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux4(portNumber=3) 
    annotation (Placement(transformation(origin = {175, -22}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_4(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {190, -22}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt4 
    annotation (Placement(transformation(origin = {205, -22}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign4(k=-1) 
    annotation (Placement(transformation(origin = {220, -22}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate motor_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=4) 
    annotation (Placement(transformation(origin = {235, 35}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.SignalRouting.Mux allocation_mux(portNumber=7) 
    annotation (Placement(transformation(origin = {80, -5}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7)))));
  SysplorerEmbeddedCoder.Utilities.Fcn allocation_residual(y=sqrt((0.002*(u[4]+u[5]+u[6]+u[7])-u[1])^2+(0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])-u[2])^2+(0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])-u[3])^2)) 
    annotation (Placement(transformation(origin = {95, -5}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_flag_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {80, -25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_count(y=u[1]+u[2]+u[3]+u[4]) 
    annotation (Placement(transformation(origin = {95, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn position_error_norm(y=sqrt((u[12]-u[1])^2+(u[13]-u[2])^2+(u[14]-u[3])^2)) 
    annotation (Placement(transformation(origin = {55, -75}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_x(y=0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-((u[3]/sqrt(u[2]^2+u[3]^2+1e-9))*u[27]+(-u[2]/sqrt(u[2]^2+u[3]^2+1e-9))*u[30]))) 
    annotation (Placement(transformation(origin = {55, -45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_y(y=0.5*((u[24]*((u[2]^2+u[3]^2)/sqrt(u[2]^2+u[3]^2+1e-9))+u[27]*(-u[1]*u[2]/sqrt(u[2]^2+u[3]^2+1e-9))+u[30]*(-u[1]*u[3]/sqrt(u[2]^2+u[3]^2+1e-9)))-(u[1]*u[22]+u[2]*u[25]+u[3]*u[28]))) 
    annotation (Placement(transformation(origin = {55, -60}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux attitude_error_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {75, -55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_norm(y=sqrt(u[1]^2+u[2]^2)) 
    annotation (Placement(transformation(origin = {90, -55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant zero(k=0) 
    annotation (Placement(transformation(origin = {75, -90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.SignalRouting.Mux innovation_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {75, -105}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn innovation_norm(y=sqrt(u[1]^2+u[2]^2)) 
    annotation (Placement(transformation(origin = {90, -105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant status_code(k=31) 
    annotation (Placement(transformation(origin = {90, -120}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diag_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {100, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
equation
  connect(reference, reference_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state, state_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y1, input_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y2, input_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y3, input_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y4, input_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y5, input_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y6, input_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y7, input_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y8, input_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y9, input_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y10, input_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y11, input_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y1, input_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y2, input_mux.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y3, input_mux.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, input_mux.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, input_mux.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, input_mux.u17) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y7, input_mux.u18) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y8, input_mux.u19) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, input_mux.u20) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y10, input_mux.u21) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y11, input_mux.u22) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, input_mux.u23) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y13, input_mux.u24) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y14, input_mux.u25) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, input_mux.u26) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, input_mux.u27) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, input_mux.u28) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y18, input_mux.u29) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, force_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, force_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, force_z.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_x.y, force_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_y.y, force_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_z.y, force_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_mux.y, b3x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_mux.y, b3y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_mux.y, b3z.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_mux.y, anorm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3x.y, geo_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3y.y, geo_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3z.y, geo_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(anorm.y, geo_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, geo_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, thrust.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, alpha_cmd_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, alpha_cmd_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, omega_x_filter_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_x_filtered_delay.y, omega_x_filter_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_x_filter_mux.y, omega_x_filtered_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_x_filtered_next.y, omega_x_filtered_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_x_filtered_next.y, alpha_x_filter_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_x_filtered_delay.y, alpha_x_filter_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_x_filter_mux.y, alpha_filtered_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_cmd_x.y, alpha_increment_mux_x.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_filtered_x.y, alpha_increment_mux_x.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_increment_mux_x.y, delta_alpha_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, omega_y_filter_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_y_filtered_delay.y, omega_y_filter_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_y_filter_mux.y, omega_y_filtered_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_y_filtered_next.y, omega_y_filtered_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_y_filtered_next.y, alpha_y_filter_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(omega_y_filtered_delay.y, alpha_y_filter_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_y_filter_mux.y, alpha_filtered_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_cmd_y.y, alpha_increment_mux_y.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_filtered_y.y, alpha_increment_mux_y.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(alpha_increment_mux_y.y, delta_alpha_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust.y, indi_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(delta_alpha_x.y, indi_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(delta_alpha_y.y, indi_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_previous_1.y, indi_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_previous_2.y, indi_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_previous_3.y, indi_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_previous_4.y, indi_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, q1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q1.y, clip_flag1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, q2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q2.y, clip_flag2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, q3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q3.y, clip_flag3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, q4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q4.y, clip_flag4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, tau_cmd_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(indi_mux.y, tau_cmd_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust.y, control_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_x.y, control_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_y.y, control_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q1.y, q_raw_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q2.y, q_raw_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q3.y, q_raw_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q4.y, q_raw_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_mux.y, desaturation_gain_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q1.y, pass1_mux1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, pass1_mux1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux1.y, q_pass1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q2.y, pass1_mux2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, pass1_mux2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux2.y, q_pass1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q3.y, pass1_mux3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, pass1_mux3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux3.y, q_pass1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q4.y, pass1_mux4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, pass1_mux4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux4.y, q_pass1_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_1.y, q_pass1_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_2.y, q_pass1_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_3.y, q_pass1_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_4.y, q_pass1_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_mux.y, desaturation_gain_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q1.y, final_mux1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, final_mux1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_2.y, final_mux1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux1.y, q_final_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, q_previous_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, sqrt1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q2.y, final_mux2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, final_mux2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_2.y, final_mux2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux2.y, q_final_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, q_previous_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, sqrt2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt2.y, sign2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q3.y, final_mux3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, final_mux3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_2.y, final_mux3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux3.y, q_final_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, q_previous_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, sqrt3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q4.y, final_mux4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_1.y, final_mux4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(desaturation_gain_2.y, final_mux4.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux4.y, q_final_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, q_previous_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, sqrt4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt4.y, sign4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt1.y, motor_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sign2.y, motor_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt3.y, motor_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sign4.y, motor_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(motor_mux.y, motor_cmd) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust.y, allocation_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_x.y, allocation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_y.y, allocation_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, allocation_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, allocation_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, allocation_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, allocation_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocation_mux.y, allocation_residual.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag1.y, clip_flag_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag2.y, clip_flag_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag3.y, clip_flag_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag4.y, clip_flag_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag_mux.y, clip_count.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, position_error_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, attitude_error_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, attitude_error_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_x.y, attitude_error_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, attitude_error_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_mux.y, attitude_error_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(delta_alpha_x.y, innovation_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(delta_alpha_y.y, innovation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_mux.y, innovation_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_x.y, diag_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_y.y, diag_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_z.y, diag_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_x.y, diag_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_cmd_y.y, diag_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(zero.y, diag_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocation_residual.y, diag_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_count.y, diag_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(position_error_norm.y, diag_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_norm.y, diag_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_norm.y, diag_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(status_code.y, diag_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diag_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8FormalINDICommandProxyV1A_20260712;