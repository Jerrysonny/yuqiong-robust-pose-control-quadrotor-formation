model A8FormalRAGCACGHTE_20260715
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  // 正式主控制器：约化姿态几何控制、CGHTE估计和约束感知分配共用0.01 s采样周期。
  annotation(__MWORKS(version="26.3.0",PortArrangement(Left(reference, state, allocator_limit, ardg1_rotor_speed, ardg1_enable, ardg1_time), Right(motor_cmd, diagnostics)),modelType=Control,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),OutputInterval=0.01),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),experiment(Algorithm=Euler,Interval=-1));
  // 固定接口为11维参考、18维状态、2维分配边界、4路电机命令和16维诊断。
  SysplorerEmbeddedCoder.Port.Inport reference 
    annotation (Placement(transformation(origin = {-180, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[11],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport state 
    annotation (Placement(transformation(origin = {-180, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[18],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport allocator_limit 
    annotation (Placement(transformation(origin = {-180, -60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[2],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport motor_cmd 
    annotation (Placement(transformation(origin = {250, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[4],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Outport diagnostics 
    annotation (Placement(transformation(origin = {250, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[16],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux reference_demux(portNumber=11) 
    annotation (Placement(transformation(origin = {-160, 60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux state_demux(portNumber=18) 
    annotation (Placement(transformation(origin = {-160, 0}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18)))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux allocator_limit_demux(portNumber=2) 
    annotation (Placement(transformation(origin = {-160, -60}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2)))));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate input_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=31) 
    annotation (Placement(transformation(origin = {-135, 25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16,u17,u18,u19,u20,u21,u22,u23,u24,u25,u26,u27,u28,u29,u30,u31)))));
  // 估计值、协方差和门控计时器均显式延迟一拍，避免离散环路。
  SysplorerEmbeddedCoder.Discrete.UnitDelay scale_estimate_delay(initCond=1) 
    annotation (Placement(transformation(origin = {-110, 145}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay covariance_delay(initCond=0.01) 
    annotation (Placement(transformation(origin = {-110, 130}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay acceleration_filter_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 115}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay previous_vz_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay previous_thrust_delay(initCond=1.60056707004) 
    annotation (Placement(transformation(origin = {-110, 85}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay previous_clip_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay startup_timer_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay activation_timer_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 40}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay return_timer_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-110, 25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay scale_applied_delay(initCond=1) 
    annotation (Placement(transformation(origin = {-110, 10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  // 平移外环生成期望合力，再由约化姿态误差构造滚转和俯仰力矩。
  SysplorerEmbeddedCoder.Utilities.Fcn force_x(y=0.163156684*(-3.1*(u[12]-u[1])-3.0*(u[15]-u[4])+u[7])) 
    annotation (Placement(transformation(origin = {-55, 95}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_y(y=0.163156684*(-3.1*(u[13]-u[2])-3.0*(u[16]-u[5])+u[8])) 
    annotation (Placement(transformation(origin = {-55, 70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_z(y=0.163156684*(-3.0*(u[14]-u[3])-2.7*(u[17]-u[6])+u[9]+9.81)) 
    annotation (Placement(transformation(origin = {-55, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux force_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {-30, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn b3x(y=u[1]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-5, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3y(y=u[2]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-5, 85}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn b3z(y=u[3]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-5, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn force_norm(y=sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)) 
    annotation (Placement(transformation(origin = {-5, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux geo_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {25, 75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn thrust(y=u[4]*(u[1]*u[24]+u[2]*u[27]+u[3]*u[30])) 
    annotation (Placement(transformation(origin = {55, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_x(y=0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-((u[3]/sqrt(u[2]^2+u[3]^2+1e-9))*u[27]+(-u[2]/sqrt(u[2]^2+u[3]^2+1e-9))*u[30]))) 
    annotation (Placement(transformation(origin = {55, 80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_y(y=0.5*((u[24]*((u[2]^2+u[3]^2)/sqrt(u[2]^2+u[3]^2+1e-9))+u[27]*(-u[1]*u[2]/sqrt(u[2]^2+u[3]^2+1e-9))+u[30]*(-u[1]*u[3]/sqrt(u[2]^2+u[3]^2+1e-9)))-(u[1]*u[22]+u[2]*u[25]+u[3]*u[28]))) 
    annotation (Placement(transformation(origin = {55, 55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux torque_x_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {70, 80}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn tau_x(y=-0.013*u[1]-0.0030*u[2]) 
    annotation (Placement(transformation(origin = {85, 80}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux torque_y_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {70, 55}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn tau_y(y=-0.013*u[1]-0.0030*u[2]) 
    annotation (Placement(transformation(origin = {85, 55}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux thrust_scale_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {85, 105}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn thrust_managed(y=u[1]*u[2]) 
    annotation (Placement(transformation(origin = {100, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux control_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {115, 85}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  // 控制分配在平方转速域完成，两次公共偏移后再执行最终限幅。
  SysplorerEmbeddedCoder.Utilities.Fcn q_raw_1(y=125*u[1]-2946.028753*u[2]-2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {125, 85}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q_raw_2(y=125*u[1]+2946.028753*u[2]-2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {125, 65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q_raw_3(y=125*u[1]+2946.028753*u[2]+2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {125, 45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn q_raw_4(y=125*u[1]-2946.028753*u[2]+2946.028753*u[3]) 
    annotation (Placement(transformation(origin = {125, 25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_limit_mux(portNumber=6) 
    annotation (Placement(transformation(origin = {145, 85}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn collective_shift_1(y=min(min(min(min(0,(if u[1] < u[5] then u[5]-u[1] else if u[1] > u[6] then u[6]-u[1] else 0)),(if u[2] < u[5] then u[5]-u[2] else if u[2] > u[6] then u[6]-u[2] else 0)),(if u[3] < u[5] then u[5]-u[3] else if u[3] > u[6] then u[6]-u[3] else 0)),(if u[4] < u[5] then u[5]-u[4] else if u[4] > u[6] then u[6]-u[4] else 0))+max(max(max(max(0,(if u[1] < u[5] then u[5]-u[1] else if u[1] > u[6] then u[6]-u[1] else 0)),(if u[2] < u[5] then u[5]-u[2] else if u[2] > u[6] then u[6]-u[2] else 0)),(if u[3] < u[5] then u[5]-u[3] else if u[3] > u[6] then u[6]-u[3] else 0)),(if u[4] < u[5] then u[5]-u[4] else if u[4] > u[6] then u[6]-u[4] else 0))) 
    annotation (Placement(transformation(origin = {165, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux_1(portNumber=2) 
    annotation (Placement(transformation(origin = {165, 62}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_1(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {180, 62}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux_2(portNumber=2) 
    annotation (Placement(transformation(origin = {165, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_2(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {180, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux_3(portNumber=2) 
    annotation (Placement(transformation(origin = {165, 26}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_3(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {180, 26}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux pass1_mux_4(portNumber=2) 
    annotation (Placement(transformation(origin = {165, 8}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_pass1_4(y=u[1]+u[2]) 
    annotation (Placement(transformation(origin = {180, 8}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux q_pass1_limit_mux(portNumber=6) 
    annotation (Placement(transformation(origin = {195, 85}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn collective_shift_2(y=0.5*(min(min(min(min(0,(if u[1] < u[5] then u[5]-u[1] else if u[1] > u[6] then u[6]-u[1] else 0)),(if u[2] < u[5] then u[5]-u[2] else if u[2] > u[6] then u[6]-u[2] else 0)),(if u[3] < u[5] then u[5]-u[3] else if u[3] > u[6] then u[6]-u[3] else 0)),(if u[4] < u[5] then u[5]-u[4] else if u[4] > u[6] then u[6]-u[4] else 0))+max(max(max(max(0,(if u[1] < u[5] then u[5]-u[1] else if u[1] > u[6] then u[6]-u[1] else 0)),(if u[2] < u[5] then u[5]-u[2] else if u[2] > u[6] then u[6]-u[2] else 0)),(if u[3] < u[5] then u[5]-u[3] else if u[3] > u[6] then u[6]-u[3] else 0)),(if u[4] < u[5] then u[5]-u[4] else if u[4] > u[6] then u[6]-u[4] else 0)))) 
    annotation (Placement(transformation(origin = {210, 105}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux_1(portNumber=5) 
    annotation (Placement(transformation(origin = {210, 62}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_1(y=max(min(u[1]+u[2]+u[3],u[5]),u[4])) 
    annotation (Placement(transformation(origin = {225, 62}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_compare_mux_1(portNumber=2) 
    annotation (Placement(transformation(origin = {238, 62}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag_1(y=if abs(u[1]-u[2])>1e-10 then 1 else 0) 
    annotation (Placement(transformation(origin = {240, 62}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt_1 
    annotation (Placement(transformation(origin = {245, 62}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux_2(portNumber=5) 
    annotation (Placement(transformation(origin = {210, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_2(y=max(min(u[1]+u[2]+u[3],u[5]),u[4])) 
    annotation (Placement(transformation(origin = {225, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_compare_mux_2(portNumber=2) 
    annotation (Placement(transformation(origin = {238, 44}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag_2(y=if abs(u[1]-u[2])>1e-10 then 1 else 0) 
    annotation (Placement(transformation(origin = {240, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt_2 
    annotation (Placement(transformation(origin = {245, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign_2(k=-1) 
    annotation (Placement(transformation(origin = {260, 44}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux_3(portNumber=5) 
    annotation (Placement(transformation(origin = {210, 26}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_3(y=max(min(u[1]+u[2]+u[3],u[5]),u[4])) 
    annotation (Placement(transformation(origin = {225, 26}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_compare_mux_3(portNumber=2) 
    annotation (Placement(transformation(origin = {238, 26}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag_3(y=if abs(u[1]-u[2])>1e-10 then 1 else 0) 
    annotation (Placement(transformation(origin = {240, 26}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt_3 
    annotation (Placement(transformation(origin = {245, 26}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux final_mux_4(portNumber=5) 
    annotation (Placement(transformation(origin = {210, 8}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn q_final_4(y=max(min(u[1]+u[2]+u[3],u[5]),u[4])) 
    annotation (Placement(transformation(origin = {225, 8}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_compare_mux_4(portNumber=2) 
    annotation (Placement(transformation(origin = {238, 8}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_flag_4(y=if abs(u[1]-u[2])>1e-10 then 1 else 0) 
    annotation (Placement(transformation(origin = {240, 8}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Sqrt sqrt_4 
    annotation (Placement(transformation(origin = {245, 8}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.MathOperation.Gain sign_4(k=-1) 
    annotation (Placement(transformation(origin = {260, 8}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate motor_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=4) 
    annotation (Placement(transformation(origin = {275, 45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.SignalRouting.Mux clip_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {120, -15}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn clip_count(y=u[1]+u[2]+u[3]+u[4]) 
    annotation (Placement(transformation(origin = {140, -15}, extent = {{-10, -10}, {10, 10}})));
  // CGHTE仅在飞行状态和创新量满足门控条件时更新推力尺度。
  SysplorerEmbeddedCoder.SignalRouting.Mux raw_acceleration_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {145, -25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn raw_acceleration(y=max(min((u[1]-u[2])/0.01,15),-15)) 
    annotation (Placement(transformation(origin = {160, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux acceleration_filter_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {160, -42}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn acceleration_filter_next(y=0.2*u[1]+0.8*u[2]) 
    annotation (Placement(transformation(origin = {175, -42}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux covariance_prediction_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {145, -58}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn covariance_predicted(y=if u[2]<=0 then u[1] else max(min(u[1]+1.296e-09,0.04),1e-08)) 
    annotation (Placement(transformation(origin = {160, -58}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux measurement_model_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {160, -75}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn predicted_acceleration(y=u[1]/(0.163156684*u[2])-9.81) 
    annotation (Placement(transformation(origin = {175, -72}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn measurement_jacobian(y=-u[1]/(0.163156684*u[2]^2)) 
    annotation (Placement(transformation(origin = {175, -82}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux measurement_noise_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {160, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn measurement_variance(y=0.25*max(max(1,1+abs(u[3])-2),1+sqrt(u[1]^2+u[2]^2)-10)^2) 
    annotation (Placement(transformation(origin = {180, -98}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux innovation_variance_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {190, -82}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn innovation_variance(y=u[1]^2*u[2]+u[3]) 
    annotation (Placement(transformation(origin = {205, -82}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux innovation_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {190, -58}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn innovation(y=u[1]-u[2]) 
    annotation (Placement(transformation(origin = {205, -58}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux normalized_innovation_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {215, -65}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn normalized_innovation(y=u[1]/(3*sqrt(u[2]+1e-12))) 
    annotation (Placement(transformation(origin = {230, -65}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn startup_timer_next(y=min(u+0.01,0.1)) 
    annotation (Placement(transformation(origin = {160, -115}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux fusion_gate_mux(portNumber=8) 
    annotation (Placement(transformation(origin = {180, -125}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8)))));
  SysplorerEmbeddedCoder.Utilities.Fcn fusion_valid(y=if u[1]>=0.1 and abs(u[2])<1 and u[3]>=0.9393727128473789 and u[4]<0.5 and abs(u[5])<=0.75 and abs(u[6])<=1.2 and abs(u[7])<=0.5 and u[8]>0.560198474514 then 1 else 0) 
    annotation (Placement(transformation(origin = {205, -125}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux kalman_gain_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {220, -98}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn kalman_gain(y=u[1]*u[2]/u[3]) 
    annotation (Placement(transformation(origin = {235, -98}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux scale_candidate_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {245, -92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn scale_candidate(y=u[1]+u[2]*u[3]) 
    annotation (Placement(transformation(origin = {260, -92}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux scale_next_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {270, -92}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn scale_estimate_next(y=if u[3]>=0.5 then max(min(u[1],1.35),0.75) else u[2]) 
    annotation (Placement(transformation(origin = {285, -92}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux covariance_next_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {245, -112}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn covariance_next(y=if u[4]>=0.5 then max(min((1-u[2]*u[3])*u[1],0.04),1e-08) else u[1]) 
    annotation (Placement(transformation(origin = {265, -112}, extent = {{-10, -10}, {10, 10}})));
  // 三个发布参数被冻结，运行时不得覆盖。
  SysplorerEmbeddedCoder.Sources.Constant activation_covariance_max_param(k=0.00253218969247675) 
    annotation (Placement(transformation(origin = {220, -170}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.Sources.Constant activation_persistence_s_param(k=0.1) 
    annotation (Placement(transformation(origin = {220, -182}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.Sources.Constant scale_rate_per_step_param(k=0.00868) 
    annotation (Placement(transformation(origin = {220, -194}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.SignalRouting.Mux activation_timer_mux(portNumber=6) 
    annotation (Placement(transformation(origin = {245, -132}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6)))));
  SysplorerEmbeddedCoder.Utilities.Fcn activation_timer_next(y=if u[4]>=0.5 and abs(u[2]-1)>=0.04 and u[3]<=u[5] then min(u[1]+0.01,u[6]) else max(u[1]-0.01,0)) 
    annotation (Placement(transformation(origin = {270, -132}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux estimator_active_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {285, -140}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn estimator_active(y=if u[1]>=u[2] then 1 else 0) 
    annotation (Placement(transformation(origin = {300, -140}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux return_timer_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {245, -150}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn return_timer_next(y=if u[3]>=0.5 and abs(u[2]-1)<=0.02 then min(u[1]+0.01,1.0) else max(u[1]-0.01,0)) 
    annotation (Placement(transformation(origin = {270, -150}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux scale_application_mux(portNumber=8) 
    annotation (Placement(transformation(origin = {310, -122}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8)))));
  SysplorerEmbeddedCoder.Utilities.Fcn scale_applied_next(y=if u[6]>0.5 or u[7]<0.9393727128473789 or u[4]<0.5 then u[1] else max(min(u[1]+max(min((if u[3]>=0.5 then u[2] else if u[5]>=1.0 then 1 else u[1])-u[1],u[8]),-u[8]),1.35),0.75)) 
    annotation (Placement(transformation(origin = {335, -122}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux allocated_vertical_thrust_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {250, -25}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn allocated_vertical_thrust(y=0.002*u[5]*(u[1]+u[2]+u[3]+u[4])) 
    annotation (Placement(transformation(origin = {270, -25}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux allocation_mux(portNumber=7) 
    annotation (Placement(transformation(origin = {105, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7)))));
  SysplorerEmbeddedCoder.Utilities.Fcn allocation_residual(y=sqrt((0.002*(u[4]+u[5]+u[6]+u[7])-u[1])^2+(0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])-u[2])^2+(0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])-u[3])^2)) 
    annotation (Placement(transformation(origin = {130, -95}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn position_error_norm(y=sqrt((u[12]-u[1])^2+(u[13]-u[2])^2+(u[14]-u[3])^2)) 
    annotation (Placement(transformation(origin = {55, -120}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux attitude_norm_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {80, -120}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn attitude_error_norm(y=sqrt(u[1]^2+u[2]^2)) 
    annotation (Placement(transformation(origin = {100, -120}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Sources.Constant zero(k=0) 
    annotation (Placement(transformation(origin = {120, -135}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  SysplorerEmbeddedCoder.Sources.Constant version_code(k=97406) 
    annotation (Placement(transformation(origin = {120, -150}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01,Instance(y(Type(inherit=InheritType.none,ref="double"))))));
  // 诊断11至16依次为估计尺度、应用尺度、融合标志、创新量、分配上界和版本码。
  SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate diag_mux(Mode=SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate.ConnectionMode.Vector,NumInputs=16) 
    annotation (Placement(transformation(origin = {180, -110}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16)))));
  SysplorerEmbeddedCoder.Port.Inport ardg1_rotor_speed 
    annotation (Placement(transformation(origin = {-360, -210}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[4],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport ardg1_enable 
    annotation (Placement(transformation(origin = {-360, -260}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[1],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.Port.Inport ardg1_time 
    annotation (Placement(transformation(origin = {-360, -290}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Dimension(dimensionType=DimensionType.none)=[1],SampleTime(auto=false)=0.01,Type(inherit=InheritType.none,ref="double"))));
  SysplorerEmbeddedCoder.SignalRouting.DeMux ardg1_rotor_speed_demux(portNumber=4) 
    annotation (Placement(transformation(origin = {-330, -210}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(y(y1,y2,y3,y4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_q_1(y=if abs(u)<1e9 then u^2 else 0) 
    annotation (Placement(transformation(origin = {-300, -198}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_q_2(y=if abs(u)<1e9 then u^2 else 0) 
    annotation (Placement(transformation(origin = {-300, -216}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_q_3(y=if abs(u)<1e9 then u^2 else 0) 
    annotation (Placement(transformation(origin = {-300, -234}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_q_4(y=if abs(u)<1e9 then u^2 else 0) 
    annotation (Placement(transformation(origin = {-300, -252}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_tau_x_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {-250, -180}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_actual_tau_x(y=0.002*0.04243*(-u[1]+u[2]+u[3]-u[4])) 
    annotation (Placement(transformation(origin = {-225, -180}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_tau_y_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {-250, -270}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_actual_tau_y(y=0.002*0.04243*(-u[1]-u[2]+u[3]+u[4])) 
    annotation (Placement(transformation(origin = {-225, -270}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_actual_tau_x_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-195, -180}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_actual_tau_y_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-195, -270}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_q_sum_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {-250, -225}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_q_sum(y=u[1]+u[2]+u[3]+u[4]) 
    annotation (Placement(transformation(origin = {-225, -225}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_q_sum_delay(initCond=0) 
    annotation (Placement(transformation(origin = {-195, -225}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_omega_x_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -40}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_alpha_x_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -58}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_observer_x_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {65, -40}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_innovation_x(y=u[1]-(u[2]+0.01*u[3])) 
    annotation (Placement(transformation(origin = {90, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_innovation_limit_x(y=if abs(u)<1e9 then max(min(u,2),-2) else 0) 
    annotation (Placement(transformation(origin = {115, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_omega_next_x_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {140, -40}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_omega_next_x(y=if abs(u[1])<1e9 and abs(u[2])<1e9 and abs(u[3])<1e9 then u[1]+0.01*u[2]+0.64*u[3] else 0) 
    annotation (Placement(transformation(origin = {165, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_alpha_next_x_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {140, -64}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_alpha_next_x(y=if abs(u[1])<1e9 and abs(u[2])<1e9 then max(min(u[1]+16*u[2],150),-150) else 0) 
    annotation (Placement(transformation(origin = {165, -64}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_residual_x_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {195, -40}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_residual_x(y=u[1]/8595.05449458058-u[2]) 
    annotation (Placement(transformation(origin = {220, -40}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_omega_y_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_alpha_y_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -118}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_observer_y_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {65, -100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_innovation_y(y=u[1]-(u[2]+0.01*u[3])) 
    annotation (Placement(transformation(origin = {90, -100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_innovation_limit_y(y=if abs(u)<1e9 then max(min(u,2),-2) else 0) 
    annotation (Placement(transformation(origin = {115, -100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_omega_next_y_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {140, -100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_omega_next_y(y=if abs(u[1])<1e9 and abs(u[2])<1e9 and abs(u[3])<1e9 then u[1]+0.01*u[2]+0.64*u[3] else 0) 
    annotation (Placement(transformation(origin = {165, -100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_alpha_next_y_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {140, -124}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_alpha_next_y(y=if abs(u[1])<1e9 and abs(u[2])<1e9 then max(min(u[1]+16*u[2],150),-150) else 0) 
    annotation (Placement(transformation(origin = {165, -124}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_residual_y_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {195, -100}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_residual_y(y=u[1]/8595.11317201388-u[2]) 
    annotation (Placement(transformation(origin = {220, -100}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_trigger_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {250, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_angular_on(y=if max(abs(u[1]),abs(u[2]))/1e-5>=8*max(1,u[3]) then 1 else 0) 
    annotation (Placement(transformation(origin = {275, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_angular_hold(y=if max(abs(u[1]),abs(u[2]))>=5e-6 and max(abs(u[1]),abs(u[2]))/1e-5>=4*max(1,u[3]) then 1 else 0) 
    annotation (Placement(transformation(origin = {275, -90}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_vx_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -170}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_vy_delay(initCond=0) 
    annotation (Placement(transformation(origin = {40, -190}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_vx_safe(y=if abs(u)<1e9 then u else 0) 
    annotation (Placement(transformation(origin = {15, -170}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_vy_safe(y=if abs(u)<1e9 then u else 0) 
    annotation (Placement(transformation(origin = {15, -190}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_vx_accel_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {65, -170}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_vy_accel_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {65, -190}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_vx_accel(y=(u[1]-u[2])/0.01) 
    annotation (Placement(transformation(origin = {90, -170}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_vy_accel(y=(u[1]-u[2])/0.01) 
    annotation (Placement(transformation(origin = {90, -190}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_trans_residual_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {115, -170}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_trans_residual_norm(y=sqrt((0.163156684*u[1]-0.002*u[3]*u[4])^2+(0.163156684*u[2]-0.002*u[3]*u[5])^2)) 
    annotation (Placement(transformation(origin = {140, -170}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_trans_score(y=max(u,0)/0.005) 
    annotation (Placement(transformation(origin = {165, -170}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_clip_delay(initCond=0) 
    annotation (Placement(transformation(origin = {185, -190}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_alloc_delay(initCond=0) 
    annotation (Placement(transformation(origin = {185, -210}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_time_delay(initCond=0) 
    annotation (Placement(transformation(origin = {185, -230}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_time_valid_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {210, -230}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_time_valid(y=if u[2]<=0.010001 or abs((u[2]-u[1])-0.01)<=1e-6 then 1 else 0) 
    annotation (Placement(transformation(origin = {235, -230}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_finite_mux(portNumber=16) 
    annotation (Placement(transformation(origin = {260, -220}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_finite(y=if abs(u[1])<1e9 and abs(u[2])<1e9 and abs(u[3])<1e9 and abs(u[4])<1e9 and abs(u[5])<1e9 and abs(u[6])<1e9 and abs(u[7])<1e9 and abs(u[8])<1e9 and abs(u[9])<1e9 and abs(u[10])<1e9 and abs(u[11])<1e9 and abs(u[12])<1e9 and abs(u[13])<1e9 and abs(u[14])<1e9 and abs(u[15])<1e9 and abs(u[16])<1e9 then 1 else 0) 
    annotation (Placement(transformation(origin = {285, -220}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_safety_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {300, -220}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_safety_valid(y=if u[1]>=0.5 and u[2]<0.5 and u[3]<=1e-9 and u[4]>=0.5 and u[5]>=0.5 then 1 else 0) 
    annotation (Placement(transformation(origin = {325, -220}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_enter_valid_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {300, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_enter_valid(y=if u[1]>=0.5 and u[2]>=0.5 then 1 else 0) 
    annotation (Placement(transformation(origin = {325, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_hold_valid_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {300, -90}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_hold_valid(y=if u[1]>=0.5 and u[2]>=0.5 then 1 else 0) 
    annotation (Placement(transformation(origin = {325, -90}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_enter_timer_delay(initCond=0) 
    annotation (Placement(transformation(origin = {350, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_enter_timer_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {375, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_enter_timer_next(y=if u[2]>=0.5 then min(u[1]+0.01,0.05) else 0) 
    annotation (Placement(transformation(origin = {400, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_exit_timer_delay(initCond=0) 
    annotation (Placement(transformation(origin = {350, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_exit_timer_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {375, -95}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_exit_timer_next(y=if u[3]>=0.5 and u[2]<0.5 then min(u[1]+0.01,0.1) else 0) 
    annotation (Placement(transformation(origin = {400, -95}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_active_delay(initCond=0) 
    annotation (Placement(transformation(origin = {425, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_active_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {450, -70}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_active_next(y=if u[4]<0.5 or u[3]>=0.099999 then 0 else if u[1]>=0.5 or u[2]>=0.049999 then 1 else 0) 
    annotation (Placement(transformation(origin = {475, -70}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_blend_delay(initCond=0) 
    annotation (Placement(transformation(origin = {425, -110}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_blend_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {450, -110}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_blend_next(y=if u[3]<0.5 then 0 else if u[2]>=0.5 then min(u[1]+0.1,1) else max(u[1]-0.1,0)) 
    annotation (Placement(transformation(origin = {475, -110}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_target_x_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {500, -10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_target_x(y=if u[4]<0.5 then 0 else max(min(-0.89894387*u[3]*u[2]*u[1],0.0003295328),-0.0003295328)) 
    annotation (Placement(transformation(origin = {525, -10}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_correction_x_delay(initCond=0) 
    annotation (Placement(transformation(origin = {550, -10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_correction_x_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {575, -10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_correction_x_next(y=if u[3]<0.5 then 0 else u[2]+max(min(u[1]-u[2],0.00004195751),-0.00004195751)) 
    annotation (Placement(transformation(origin = {600, -10}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_final_x_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {625, -10}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_final_x(y=if u[3]<0.5 or u[4]<0.5 or u[5]<0.5 then u[1] else max(min(u[1]+u[2],0.0045),-0.0045)) 
    annotation (Placement(transformation(origin = {650, -10}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_target_y_mux(portNumber=4) 
    annotation (Placement(transformation(origin = {500, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_target_y(y=if u[4]<0.5 then 0 else max(min(-0.89894387*u[3]*u[2]*u[1],0.0003295328),-0.0003295328)) 
    annotation (Placement(transformation(origin = {525, -45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_correction_y_delay(initCond=0) 
    annotation (Placement(transformation(origin = {550, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_correction_y_mux(portNumber=3) 
    annotation (Placement(transformation(origin = {575, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_correction_y_next(y=if u[3]<0.5 then 0 else u[2]+max(min(u[1]-u[2],0.00004195751),-0.00004195751)) 
    annotation (Placement(transformation(origin = {600, -45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_final_y_mux(portNumber=5) 
    annotation (Placement(transformation(origin = {625, -45}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2,u3,u4,u5)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_final_y(y=if u[3]<0.5 or u[4]<0.5 or u[5]<0.5 then u[1] else max(min(u[1]+u[2],0.0045),-0.0045)) 
    annotation (Placement(transformation(origin = {650, -45}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_r31_safe(y=if abs(u)<1e9 then u else 0) 
    annotation (Placement(transformation(origin = {90, -135}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_r32_safe(y=if abs(u)<1e9 then u else 0) 
    annotation (Placement(transformation(origin = {90, -215}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_torque_mode(y=if u>=0.5 then 1 else 0) 
    annotation (Placement(transformation(origin = {500, -135}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_ax_lpf_delay(initCond=0) 
    annotation (Placement(transformation(origin = {110, -150}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_ax_lpf_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {130, -150}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_ax_lpf_next(y=0.11808862170182366*u[1]+0.8819113782981763*u[2]) 
    annotation (Placement(transformation(origin = {150, -150}, extent = {{-10, -10}, {10, 10}})));
  SysplorerEmbeddedCoder.Discrete.UnitDelay ardg1_ay_lpf_delay(initCond=0) 
    annotation (Placement(transformation(origin = {110, -210}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=0.01)));
  SysplorerEmbeddedCoder.SignalRouting.Mux ardg1_ay_lpf_mux(portNumber=2) 
    annotation (Placement(transformation(origin = {130, -210}, extent = {{-10, -10}, {10, 10}})),__MWORKS(BlockSystem(Instance(u(u1,u2)))));
  SysplorerEmbeddedCoder.Utilities.Fcn ardg1_ay_lpf_next(y=0.11808862170182366*u[1]+0.8819113782981763*u[2]) 
    annotation (Placement(transformation(origin = {150, -210}, extent = {{-10, -10}, {10, 10}})));
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
equation
  connect(reference, reference_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state, state_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit, allocator_limit_demux.u) 
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
  connect(allocator_limit_demux.y1, input_mux.u30) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, input_mux.u31) 
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
  connect(attitude_error_x.y, torque_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, torque_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(torque_x_mux.y, tau_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, torque_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, torque_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(torque_y_mux.y, tau_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust.y, thrust_scale_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_applied_delay.y, thrust_scale_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust_scale_mux.y, thrust_managed.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust_managed.y, control_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q_raw_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q_raw_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q_raw_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(control_mux.y, q_raw_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_1.y, q_limit_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_2.y, q_limit_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_3.y, q_limit_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_4.y, q_limit_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, q_limit_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, q_limit_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_limit_mux.y, collective_shift_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_1.y, pass1_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, pass1_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux_1.y, q_pass1_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_2.y, pass1_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, pass1_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux_2.y, q_pass1_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_3.y, pass1_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, pass1_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux_3.y, q_pass1_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_4.y, pass1_mux_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, pass1_mux_4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(pass1_mux_4.y, q_pass1_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_1.y, q_pass1_limit_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_2.y, q_pass1_limit_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_3.y, q_pass1_limit_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_4.y, q_pass1_limit_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, q_pass1_limit_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, q_pass1_limit_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_pass1_limit_mux.y, collective_shift_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_1.y, final_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, final_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_2.y, final_mux_1.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, final_mux_1.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, final_mux_1.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux_1.y, q_final_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_1.y, clip_compare_mux_1.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, clip_compare_mux_1.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_compare_mux_1.y, clip_flag_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, sqrt_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_2.y, final_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, final_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_2.y, final_mux_2.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, final_mux_2.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, final_mux_2.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux_2.y, q_final_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_2.y, clip_compare_mux_2.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, clip_compare_mux_2.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_compare_mux_2.y, clip_flag_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, sqrt_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt_2.y, sign_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_3.y, final_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, final_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_2.y, final_mux_3.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, final_mux_3.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, final_mux_3.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux_3.y, q_final_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_3.y, clip_compare_mux_3.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, clip_compare_mux_3.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_compare_mux_3.y, clip_flag_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, sqrt_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_4.y, final_mux_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_1.y, final_mux_4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(collective_shift_2.y, final_mux_4.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y1, final_mux_4.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, final_mux_4.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(final_mux_4.y, q_final_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_raw_4.y, clip_compare_mux_4.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, clip_compare_mux_4.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_compare_mux_4.y, clip_flag_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, sqrt_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt_4.y, sign_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt_1.y, motor_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sign_2.y, motor_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sqrt_3.y, motor_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(sign_4.y, motor_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(motor_mux.y, motor_cmd) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag_1.y, clip_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag_2.y, clip_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag_3.y, clip_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_flag_4.y, clip_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_mux.y, clip_count.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, raw_acceleration_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(previous_vz_delay.y, raw_acceleration_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(raw_acceleration_mux.y, raw_acceleration.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_filter_delay.y, acceleration_filter_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(raw_acceleration.y, acceleration_filter_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_filter_mux.y, acceleration_filter_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_filter_next.y, acceleration_filter_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_delay.y, covariance_prediction_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(startup_timer_delay.y, covariance_prediction_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_prediction_mux.y, covariance_predicted.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(previous_thrust_delay.y, measurement_model_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_delay.y, measurement_model_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_model_mux.y, predicted_acceleration.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_model_mux.y, measurement_jacobian.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, measurement_noise_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, measurement_noise_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, measurement_noise_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_noise_mux.y, measurement_variance.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_jacobian.y, innovation_variance_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_predicted.y, innovation_variance_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_variance.y, innovation_variance_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_variance_mux.y, innovation_variance.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(acceleration_filter_next.y, innovation_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(predicted_acceleration.y, innovation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_mux.y, innovation.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation.y, normalized_innovation_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_variance.y, normalized_innovation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(normalized_innovation_mux.y, normalized_innovation.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(startup_timer_delay.y, startup_timer_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(startup_timer_delay.y, fusion_gate_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(normalized_innovation.y, fusion_gate_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, fusion_gate_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(previous_clip_delay.y, fusion_gate_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y6, fusion_gate_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, fusion_gate_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(reference_demux.y9, fusion_gate_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(previous_thrust_delay.y, fusion_gate_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_gate_mux.y, fusion_valid.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_predicted.y, kalman_gain_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_jacobian.y, kalman_gain_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation_variance.y, kalman_gain_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(kalman_gain_mux.y, kalman_gain.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_delay.y, scale_candidate_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(kalman_gain.y, scale_candidate_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(innovation.y, scale_candidate_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_candidate_mux.y, scale_candidate.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_candidate.y, scale_next_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_delay.y, scale_next_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, scale_next_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_next_mux.y, scale_estimate_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_next.y, scale_estimate_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_predicted.y, covariance_next_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(kalman_gain.y, covariance_next_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(measurement_jacobian.y, covariance_next_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, covariance_next_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_next_mux.y, covariance_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_next.y, covariance_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_timer_delay.y, activation_timer_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_next.y, activation_timer_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(covariance_next.y, activation_timer_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, activation_timer_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_covariance_max_param.y, activation_timer_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_persistence_s_param.y, activation_timer_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_timer_mux.y, activation_timer_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_timer_next.y, activation_timer_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_timer_next.y, estimator_active_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(activation_persistence_s_param.y, estimator_active_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(estimator_active_mux.y, estimator_active.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(return_timer_delay.y, return_timer_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_next.y, return_timer_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, return_timer_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(return_timer_mux.y, return_timer_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(return_timer_next.y, return_timer_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_applied_delay.y, scale_application_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_estimate_next.y, scale_application_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(estimator_active.y, scale_application_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, scale_application_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(return_timer_next.y, scale_application_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_count.y, scale_application_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, scale_application_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_rate_per_step_param.y, scale_application_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_application_mux.y, scale_applied_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_applied_next.y, scale_applied_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_1.y, allocated_vertical_thrust_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_2.y, allocated_vertical_thrust_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_3.y, allocated_vertical_thrust_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(q_final_4.y, allocated_vertical_thrust_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y15, allocated_vertical_thrust_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocated_vertical_thrust_mux.y, allocated_vertical_thrust.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y6, previous_vz_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocated_vertical_thrust.y, previous_thrust_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_count.y, previous_clip_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(startup_timer_next.y, startup_timer_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(thrust_managed.y, allocation_mux.u1) 
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
  connect(input_mux.y, position_error_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_x.y, attitude_norm_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_error_y.y, attitude_norm_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(attitude_norm_mux.y, attitude_error_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_x.y, diag_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_y.y, diag_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(force_z.y, diag_mux.u3) 
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
  connect(scale_estimate_delay.y, diag_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(scale_applied_delay.y, diag_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(fusion_valid.y, diag_mux.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(normalized_innovation.y, diag_mux.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocator_limit_demux.y2, diag_mux.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(version_code.y, diag_mux.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(diag_mux.y, diagnostics) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed, ardg1_rotor_speed_demux.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y1, ardg1_q_1.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_1.y, ardg1_tau_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_1.y, ardg1_tau_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_1.y, ardg1_q_sum_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y1, ardg1_finite_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y2, ardg1_q_2.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_2.y, ardg1_tau_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_2.y, ardg1_tau_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_2.y, ardg1_q_sum_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y2, ardg1_finite_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y3, ardg1_q_3.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_3.y, ardg1_tau_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_3.y, ardg1_tau_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_3.y, ardg1_q_sum_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y3, ardg1_finite_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y4, ardg1_q_4.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_4.y, ardg1_tau_x_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_4.y, ardg1_tau_y_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_4.y, ardg1_q_sum_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_rotor_speed_demux.y4, ardg1_finite_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_tau_x_mux.y, ardg1_actual_tau_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_tau_y_mux.y, ardg1_actual_tau_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_actual_tau_x.y, ardg1_actual_tau_x_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_actual_tau_y.y, ardg1_actual_tau_y_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_sum_mux.y, ardg1_q_sum.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_sum.y, ardg1_q_sum_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_x.y, ardg1_trigger_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_y.y, ardg1_trigger_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_trigger_mux.y, ardg1_angular_on.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_trigger_mux.y, ardg1_angular_hold.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, ardg1_vx_safe.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vx_safe.y, ardg1_vx_accel_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vx_delay.y, ardg1_vx_accel_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vx_accel_mux.y, ardg1_vx_accel.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vx_safe.y, ardg1_vx_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, ardg1_vy_safe.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vy_safe.y, ardg1_vy_accel_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vy_delay.y, ardg1_vy_accel_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vy_accel_mux.y, ardg1_vy_accel.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vy_safe.y, ardg1_vy_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ax_lpf_next.y, ardg1_trans_residual_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ay_lpf_next.y, ardg1_trans_residual_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_q_sum_delay.y, ardg1_trans_residual_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_r31_safe.y, ardg1_trans_residual_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_r32_safe.y, ardg1_trans_residual_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_trans_residual_mux.y, ardg1_trans_residual_norm.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_trans_residual_norm.y, ardg1_trans_score.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(clip_count.y, ardg1_clip_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(allocation_residual.y, ardg1_alloc_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time, ardg1_time_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time_delay.y, ardg1_time_valid_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time, ardg1_time_valid_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time_valid_mux.y, ardg1_time_valid.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y4, ardg1_finite_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y5, ardg1_finite_mux.u6) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, ardg1_finite_mux.u7) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, ardg1_finite_mux.u8) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, ardg1_finite_mux.u9) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, ardg1_finite_mux.u10) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_x.y, ardg1_finite_mux.u11) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_y.y, ardg1_finite_mux.u12) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time, ardg1_finite_mux.u13) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enable, ardg1_finite_mux.u14) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_clip_delay.y, ardg1_finite_mux.u15) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alloc_delay.y, ardg1_finite_mux.u16) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_finite_mux.y, ardg1_finite.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_finite.y, ardg1_safety_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_clip_delay.y, ardg1_safety_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alloc_delay.y, ardg1_safety_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_time_valid.y, ardg1_safety_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enable, ardg1_safety_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_mux.y, ardg1_safety_valid.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_enter_valid_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_angular_on.y, ardg1_enter_valid_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_valid_mux.y, ardg1_enter_valid.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_hold_valid_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_angular_hold.y, ardg1_hold_valid_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_hold_valid_mux.y, ardg1_hold_valid.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_timer_delay.y, ardg1_enter_timer_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_valid.y, ardg1_enter_timer_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_timer_mux.y, ardg1_enter_timer_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_timer_next.y, ardg1_enter_timer_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_exit_timer_delay.y, ardg1_exit_timer_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_hold_valid.y, ardg1_exit_timer_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_exit_timer_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_exit_timer_mux.y, ardg1_exit_timer_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_exit_timer_next.y, ardg1_exit_timer_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_active_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enter_timer_next.y, ardg1_active_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_exit_timer_next.y, ardg1_active_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_active_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_mux.y, ardg1_active_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_next.y, ardg1_active_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_blend_delay.y, ardg1_blend_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_blend_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_blend_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_blend_mux.y, ardg1_blend_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_blend_next.y, ardg1_blend_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y16, ardg1_observer_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_x_delay.y, ardg1_observer_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_x_delay.y, ardg1_observer_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_observer_x_mux.y, ardg1_innovation_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_x.y, ardg1_innovation_limit_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_x_delay.y, ardg1_omega_next_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_x_delay.y, ardg1_omega_next_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_limit_x.y, ardg1_omega_next_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_next_x_mux.y, ardg1_omega_next_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_next_x.y, ardg1_omega_x_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_x_delay.y, ardg1_alpha_next_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_limit_x.y, ardg1_alpha_next_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_x_mux.y, ardg1_alpha_next_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_x.y, ardg1_alpha_x_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_x.y, ardg1_residual_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_actual_tau_x_delay.y, ardg1_residual_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_x_mux.y, ardg1_residual_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_x.y, ardg1_target_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_blend_next.y, ardg1_target_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_target_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_target_x_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_target_x_mux.y, ardg1_target_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_target_x.y, ardg1_correction_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_x_delay.y, ardg1_correction_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_correction_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_x_mux.y, ardg1_correction_x_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_x_next.y, ardg1_correction_x_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_x.y, ardg1_final_x_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_x_next.y, ardg1_final_x_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enable, ardg1_final_x_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_final_x_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_final_x_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_x_mux.y, ardg1_final_x.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_x.y, control_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_x.y, allocation_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_x.y, diag_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y17, ardg1_observer_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_y_delay.y, ardg1_observer_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_y_delay.y, ardg1_observer_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_observer_y_mux.y, ardg1_innovation_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_y.y, ardg1_innovation_limit_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_y_delay.y, ardg1_omega_next_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_y_delay.y, ardg1_omega_next_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_limit_y.y, ardg1_omega_next_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_next_y_mux.y, ardg1_omega_next_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_omega_next_y.y, ardg1_omega_y_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_y_delay.y, ardg1_alpha_next_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_innovation_limit_y.y, ardg1_alpha_next_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_y_mux.y, ardg1_alpha_next_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_y.y, ardg1_alpha_y_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_alpha_next_y.y, ardg1_residual_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_actual_tau_y_delay.y, ardg1_residual_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_y_mux.y, ardg1_residual_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_residual_y.y, ardg1_target_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_blend_next.y, ardg1_target_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_target_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_target_y_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_target_y_mux.y, ardg1_target_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_target_y.y, ardg1_correction_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_y_delay.y, ardg1_correction_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_correction_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_y_mux.y, ardg1_correction_y_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_y_next.y, ardg1_correction_y_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(tau_y.y, ardg1_final_y_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_correction_y_next.y, ardg1_final_y_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_enable, ardg1_final_y_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_delay.y, ardg1_final_y_mux.u4) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_safety_valid.y, ardg1_final_y_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_y_mux.y, ardg1_final_y.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_y.y, control_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_y.y, allocation_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_final_y.y, diag_mux.u5) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y9, ardg1_r31_safe.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(state_demux.y12, ardg1_r32_safe.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vx_accel.y, ardg1_ax_lpf_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ax_lpf_delay.y, ardg1_ax_lpf_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ax_lpf_mux.y, ardg1_ax_lpf_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ax_lpf_next.y, ardg1_ax_lpf_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_vy_accel.y, ardg1_ay_lpf_mux.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ay_lpf_delay.y, ardg1_ay_lpf_mux.u2) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ay_lpf_mux.y, ardg1_ay_lpf_next.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_ay_lpf_next.y, ardg1_ay_lpf_delay.u1) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_trans_score.y, ardg1_trigger_mux.u3) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));
  connect(ardg1_active_next.y, ardg1_torque_mode.u) 
    annotation(Line(origin = {0.0, 0.0}, points = {{0, 0}, {0, 0}}));

end A8FormalRAGCACGHTE_20260715;