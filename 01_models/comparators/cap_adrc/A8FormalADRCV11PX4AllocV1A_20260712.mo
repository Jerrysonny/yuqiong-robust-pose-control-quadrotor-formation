model A8FormalADRCV11PX4AllocV1A_20260712
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(reference, state), Right(motor_cmd, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  SysplorerEmbeddedCoder.Port.Inport reference 
    annotation (Placement(transformation(origin = {-170, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[11],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport state 
    annotation (Placement(transformation(origin = {-170, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[18],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport motor_cmd 
    annotation (Placement(transformation(origin = {190, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[4],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {190, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[12],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux reference_demux(portNumber=11) 
    annotation (Placement(transformation(origin = {-150, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=18) 
    annotation (Placement(transformation(origin = {-150, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate input_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=29) 
    annotation (Placement(transformation(origin = {-125, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18,u19,u20,u21,u22,u23,u24,u25,u26,u27,u28,u29)))));
  SysplorerEmbeddedCoder.Utilities.Fcn outer_x_error(y=u[1]-u[12]) 
    annotation (Placement(transformation(origin = {-120, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay outer_x_integral_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-100, 105}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux outer_x_integral_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {-80, 105}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn outer_x_integral_next(y=max(min(0.98*u[2]+0.01*u[1],0.5),-0.5)) 
    annotation (Placement(transformation(origin = {-60, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate force_x_input(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-40, 105}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn outer_y_error(y=u[2]-u[13]) 
    annotation (Placement(transformation(origin = {-120, -95}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay outer_y_integral_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-100, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux outer_y_integral_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {-80, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn outer_y_integral_next(y=max(min(0.98*u[2]+0.01*u[1],0.5),-0.5)) 
    annotation (Placement(transformation(origin = {-60, -95}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate force_y_input(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=2) 
    annotation (Placement(transformation(origin = {-40, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn force_x(y=0.163156684*(-3.2*(u[12]-u[1])-2.4*(u[15]-u[4])+u[7]+1.5*u[30])) 
    annotation (Placement(transformation(origin = {-20, 75}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_y(y=0.163156684*(-3.2*(u[13]-u[2])-2.4*(u[16]-u[5])+u[8]+1.5*u[30])) 
    annotation (Placement(transformation(origin = {-20, 50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_z(y=0.163156684*(-3.2*(u[14]-u[3])-2.4*(u[17]-u[6])+u[9]+9.81)) 
    annotation (Placement(transformation(origin = {-105, 25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux force_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {-80, 50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn b3x(y=u[1]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-55, 85}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3y(y=u[2]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-55, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3z(y=u[3]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-55, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_norm(y=sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-55, 25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux geo_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {-30, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn thrust(y=u[4]*(u[1]*u[24]+u[2]*u[27]+u[3]*u[30])) 
    annotation (Placement(transformation(origin = {0, 90}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_x(y=0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-((u[3]/sqrt(u[2]^2+u[3]^2+1e-9))*u[27]+(-u[2]/sqrt(u[2]^2+u[3]^2+1e-9))*u[30]))) 
    annotation (Placement(transformation(origin = {0, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_y(y=0.5*((u[24]*((u[2]^2+u[3]^2)/sqrt(u[2]^2+u[3]^2+1e-9))+u[27]*(-u[1]*u[2]/sqrt(u[2]^2+u[3]^2+1e-9))+u[30]*(-u[1]*u[3]/sqrt(u[2]^2+u[3]^2+1e-9)))-(u[1]*u[22]+u[2]*u[25]+u[3]*u[28]))) 
    annotation (Placement(transformation(origin = {0, 40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux roll_state_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {25, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Discrete.UnitDelay roll_z1_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, 42}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay roll_z2_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay roll_z3_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, 78}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_z1_next(y=u[2]+0.01*(u[3]+75*(u[1]-u[2]))) 
    annotation (Placement(transformation(origin = {45, 115}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_z3_next(y=max(min(u[4]+0.01*(15625*(u[1]-u[2])),21.48763623645145),-21.48763623645145)) 
    annotation (Placement(transformation(origin = {45, 97}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_feedback_torque(y=max(min((-100*u[2]-22*u[3])/8595.05449458058,0.0045),-0.0045)) 
    annotation (Placement(transformation(origin = {45, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_remaining_authority(y=0.0045-abs(u)) 
    annotation (Placement(transformation(origin = {70, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux roll_disturbance_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {90, 50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_disturbance_torque(y=max(min(-u[1]/8595.05449458058,u[2]),-u[2])) 
    annotation (Placement(transformation(origin = {110, 50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux roll_torque_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {130, 65}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_torque(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {150, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pitch_state_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {25, -55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Discrete.UnitDelay pitch_z1_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, -73}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay pitch_z2_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, -55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay pitch_z3_delay(initCond=0) 
    annotation (Placement(transformation(origin = {70, -37}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_z1_next(y=u[2]+0.01*(u[3]+75*(u[1]-u[2]))) 
    annotation (Placement(transformation(origin = {45, 0}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_z3_next(y=max(min(u[4]+0.01*(15625*(u[1]-u[2])),21.48778293003470),-21.48778293003470)) 
    annotation (Placement(transformation(origin = {45, -18}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_feedback_torque(y=max(min((-100*u[2]-22*u[3])/8595.11317201388,0.0045),-0.0045)) 
    annotation (Placement(transformation(origin = {45, -50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_remaining_authority(y=0.0045-abs(u)) 
    annotation (Placement(transformation(origin = {70, -50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pitch_disturbance_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {90, -65}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_disturbance_torque(y=max(min(-u[1]/8595.11317201388,u[2]),-u[2])) 
    annotation (Placement(transformation(origin = {110, -65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pitch_torque_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {130, -50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_torque(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {150, -50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux control_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {100, 50}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q1(y=125*u[1]-2946.028753*u[2]-2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {120, 70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag1(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {140, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q2(y=125*u[1]+2946.028753*u[2]-2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {120, 50}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag2(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {140, -55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q3(y=125*u[1]+2946.028753*u[2]+2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {120, 30}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag3(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {140, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q4(y=125*u[1]-2946.028753*u[2]+2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {120, 10}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag4(y=if u < 0 or u > 3600 then 1 else 0) 
    annotation (Placement(transformation(origin = {140, -85}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_raw_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {140, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn desaturation_gain_1(y=min(min(min(min(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))+max(max(max(max(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))) 
    annotation (Placement(transformation(origin = {155, 90}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux1(portNumber=2) 
    annotation (Placement(transformation(origin = {155, 57}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {170, 57}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux2(portNumber=2) 
    annotation (Placement(transformation(origin = {155, 39}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {170, 39}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux3(portNumber=2) 
    annotation (Placement(transformation(origin = {155, 21}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {170, 21}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux4(portNumber=2) 
    annotation (Placement(transformation(origin = {155, 3}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_4(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {170, 3}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_pass1_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {185, 90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn desaturation_gain_2(y=0.5*(min(min(min(min(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0))+max(max(max(max(0,(if u[1] < 0 then -u[1] else if u[1] > 3600 then 3600-u[1] else 0)),(if u[2] < 0 then -u[2] else if u[2] > 3600 then 3600-u[2] else 0)),(if u[3] < 0 then -u[3] else if u[3] > 3600 then 3600-u[3] else 0)),(if u[4] < 0 then -u[4] else if u[4] > 3600 then 3600-u[4] else 0)))) 
    annotation (Placement(transformation(origin = {200, 90}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux1(portNumber=3) 
    annotation (Placement(transformation(origin = {200, 57}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_1(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {215, 57}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt1 
    annotation (Placement(transformation(origin = {230, 57}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux2(portNumber=3) 
    annotation (Placement(transformation(origin = {200, 39}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_2(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {215, 39}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt2 
    annotation (Placement(transformation(origin = {230, 39}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign2(k=-1) 
    annotation (Placement(transformation(origin = {245, 39}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux3(portNumber=3) 
    annotation (Placement(transformation(origin = {200, 21}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_3(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {215, 21}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt3 
    annotation (Placement(transformation(origin = {230, 21}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux4(portNumber=3) 
    annotation (Placement(transformation(origin = {200, 3}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_4(y=max(min(u[1]+u[2]+u[3],3600),0)) 
    annotation (Placement(transformation(origin = {215, 3}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt4 
    annotation (Placement(transformation(origin = {230, 3}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign4(k=-1) 
    annotation (Placement(transformation(origin = {245, 3}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate motor_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=4) 
    annotation (Placement(transformation(origin = {260, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.SignalRouting.Mux allocation_mux(portNumber=7) 
    annotation (Placement(transformation(origin = {105, -80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7)))));
  SysplorerEmbeddedCoder.Utilities.Fcn allocation_residual(y=sqrt((0.002*(u[4]+u[5]+u[6]+u[7])-u[1])^2+(0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])-u[2])^2+(0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])-u[3])^2)) 
    annotation (Placement(transformation(origin = {130, -80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn achieved_roll_torque(y=0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])) 
    annotation (Placement(transformation(origin = {130, -60}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn achieved_pitch_torque(y=0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])) 
    annotation (Placement(transformation(origin = {130, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux roll_z2_update_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {105, -10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn roll_z2_next(y=u[3]+0.01*(u[4]+8595.05449458058*u[5]+1875*(u[1]-u[2]))) 
    annotation (Placement(transformation(origin = {130, -10}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pitch_z2_update_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {105, -25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn pitch_z2_next(y=u[3]+0.01*(u[4]+8595.11317201388*u[5]+1875*(u[1]-u[2]))) 
    annotation (Placement(transformation(origin = {130, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_flag_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {105, -100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_count(y=u[1]+u[2]+u[3]+u[4]) 
    annotation (Placement(transformation(origin = {130, -100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn position_error_norm(y=sqrt((u[12]-u[1])^2+(u[13]-u[2])^2+(u[14]-u[3])^2)) 
    annotation (Placement(transformation(origin = {105, -120}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux attitude_error_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {105, -140}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_norm(y=sqrt(u[1]^2+u[2]^2)) 
    annotation (Placement(transformation(origin = {130, -140}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux disturbance_estimate_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {105, -160}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn disturbance_estimate_norm(y=sqrt(u[1]^2+u[2]^2)) 
    annotation (Placement(transformation(origin = {130, -160}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant zero(k=0) 
    annotation (Placement(transformation(origin = {130, -180}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.Sources.Constant status_code(k=30) 
    annotation (Placement(transformation(origin = {130, -200}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diag_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=12) 
    annotation (Placement(transformation(origin = {160, -80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12)))));
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
  connect(input_mux.y, outer_x_error.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_x_error.y, outer_x_integral_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_x_integral_delay.y, outer_x_integral_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_x_integral_mux.y, outer_x_integral_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_x_integral_next.y, outer_x_integral_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, force_x_input.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_x_integral_delay.y, force_x_input.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, outer_y_error.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_y_error.y, outer_y_integral_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_y_integral_delay.y, outer_y_integral_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_y_integral_mux.y, outer_y_integral_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_y_integral_next.y, outer_y_integral_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, force_y_input.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(outer_y_integral_delay.y, force_y_input.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_x_input.y, force_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_y_input.y, force_y.u) 
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
  connect(force_mux.y, force_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3x.y, geo_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3y.y, geo_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(b3z.y, geo_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_norm.y, geo_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(input_mux.y, geo_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, thrust.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, attitude_error_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(geo_mux.y, attitude_error_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_x.y, roll_state_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z1_delay.y, roll_state_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z2_delay.y, roll_state_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z3_delay.y, roll_state_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_state_mux.y, roll_z1_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_state_mux.y, roll_z3_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z1_next.y, roll_z1_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z3_next.y, roll_z3_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_state_mux.y, roll_feedback_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_feedback_torque.y, roll_remaining_authority.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z3_delay.y, roll_disturbance_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_remaining_authority.y, roll_disturbance_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_disturbance_mux.y, roll_disturbance_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_feedback_torque.y, roll_torque_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_disturbance_torque.y, roll_torque_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_torque_mux.y, roll_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, pitch_state_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z1_delay.y, pitch_state_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z2_delay.y, pitch_state_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z3_delay.y, pitch_state_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_state_mux.y, pitch_z1_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_state_mux.y, pitch_z3_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z1_next.y, pitch_z1_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z3_next.y, pitch_z3_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_state_mux.y, pitch_feedback_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_feedback_torque.y, pitch_remaining_authority.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z3_delay.y, pitch_disturbance_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_remaining_authority.y, pitch_disturbance_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_disturbance_mux.y, pitch_disturbance_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_feedback_torque.y, pitch_torque_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_disturbance_torque.y, pitch_torque_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_torque_mux.y, pitch_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust.y, control_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_torque.y, control_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_torque.y, control_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q1.y, clip_flag1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q2.y, clip_flag2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q3.y, clip_flag3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q4.y, clip_flag4.u) 
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
  connect(roll_torque.y, allocation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_torque.y, allocation_mux.u3) 
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
  connect(allocation_mux.y, achieved_roll_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocation_mux.y, achieved_pitch_torque.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_x.y, roll_z2_update_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z1_delay.y, roll_z2_update_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z2_delay.y, roll_z2_update_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z3_delay.y, roll_z2_update_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(achieved_roll_torque.y, roll_z2_update_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z2_update_mux.y, roll_z2_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z2_next.y, roll_z2_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, pitch_z2_update_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z1_delay.y, pitch_z2_update_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z2_delay.y, pitch_z2_update_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z3_delay.y, pitch_z2_update_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(achieved_pitch_torque.y, pitch_z2_update_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z2_update_mux.y, pitch_z2_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z2_next.y, pitch_z2_delay.u1) 
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
  connect(attitude_error_x.y, attitude_error_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, attitude_error_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_mux.y, attitude_error_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_z3_delay.y, disturbance_estimate_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_z3_delay.y, disturbance_estimate_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(disturbance_estimate_mux.y, disturbance_estimate_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_x.y, diag_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_y.y, diag_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_z.y, diag_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(roll_torque.y, diag_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pitch_torque.y, diag_mux.u5) 
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
  connect(disturbance_estimate_norm.y, diag_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(status_code.y, diag_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diag_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8FormalADRCV11PX4AllocV1A_20260712;