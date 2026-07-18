import mworks.sysplorer as M

# 构建脚本只负责生成基准控制器框图，不在运行时修改控制参数。
MODEL="A8FormalSO3V1F_20260711"; TS="0.01"
def req(label,v):
    if v is not True: raise RuntimeError(f"{label}: {v!r}")
def add(t,n,x,y): req("add "+n,M.AddComponent(t,MODEL,n,x,y))
def setp(n,p,v): req(f"{n}.{p}",M.SetModelParamValue(MODEL,n,p,v))
def con(a,b): req(a+"->"+b,M.ConnectPort(MODEL,a,b))
def fcn(n,e,x,y):
    add("SysplorerEmbeddedCoder.Utilities.Fcn",n,x,y);setp(n,"ExprEdit",e);con("input_mux.y",n+".u")
if M.ClassExist(MODEL): raise RuntimeError("model exists")
M.NewModel(MODEL,"Sysblock")
if not M.ClassExist(MODEL): raise RuntimeError("NewModel did not create the class")
for n,d,t,x,y in (("reference",11,"Inport",-120,35),("state",18,"Inport",-120,-35),("motor_cmd",4,"Outport",140,35),("diagnostics",12,"Outport",140,-35)):
    add("SysplorerEmbeddedCoder.Port."+t,n,x,y);setp(n,"Dimension",str(d));setp(n,"OutDataTypeStr","double");setp(n,"SampleTime",TS)
add("SysplorerEmbeddedCoder.SignalRouting.DeMux","reference_demux",-100,35);setp("reference_demux","Outputs","11");con("reference","reference_demux.u")
add("SysplorerEmbeddedCoder.SignalRouting.DeMux","state_demux",-100,-35);setp("state_demux","Outputs","18");con("state","state_demux.u")
add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate","input_mux",-80,0);setp("input_mux","NumInputs","29")
for i in range(1,12): con(f"reference_demux.y{i}",f"input_mux.u{i}")
for i in range(1,19): con(f"state_demux.y{i}",f"input_mux.u{i+11}")
m=.163156684;kp=3.2;kv=2.4
# 外环根据位置和速度误差生成期望合力。
for n,e,y in (
 ("force_x",f"{m}*(-{kp}*(u[12]-u[1])-{kv}*(u[15]-u[4])+u[7])",60),
 ("force_y",f"{m}*(-{kp}*(u[13]-u[2])-{kv}*(u[16]-u[5])+u[8])",30),
 ("force_z",f"{m}*(-{kp}*(u[14]-u[3])-{kv}*(u[17]-u[6])+u[9]+9.81)",0)):
 fcn(n,e,-55,y)
add("SysplorerEmbeddedCoder.SignalRouting.Mux","force_mux",-25,30);setp("force_mux","Inputs","3")
for i,n in enumerate(("force_x","force_y","force_z"),1):con(n+".y",f"force_mux.u{i}")
for n,e,y in (("b3x","u[1]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)",65),("b3y","u[2]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)",45),("b3z","u[3]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)",25),("anorm","sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)",5)):
 add("SysplorerEmbeddedCoder.Utilities.Fcn",n,5,y);setp(n,"ExprEdit",e);con("force_mux.y",n+".u")
add("SysplorerEmbeddedCoder.SignalRouting.Mux","geo_mux",30,35);setp("geo_mux","Inputs","5")
for i,n in enumerate(("b3x","b3y","b3z","anorm"),1):con(n+".y",f"geo_mux.u{i}")
con("input_mux.y","geo_mux.u5")
d="sqrt(u[2]^2+u[3]^2+1e-9)"
thrust="u[4]*(u[1]*u[24]+u[2]*u[27]+u[3]*u[30])"
er1=f"0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-((u[3]/{d})*u[27]+(-u[2]/{d})*u[30]))"
b1x=f"(u[2]^2+u[3]^2)/{d}";b1y=f"-u[1]*u[2]/{d}";b1z=f"-u[1]*u[3]/{d}"
er2=f"0.5*((u[24]*({b1x})+u[27]*({b1y})+u[30]*({b1z}))-(u[1]*u[22]+u[2]*u[25]+u[3]*u[28]))"
for n,e,y in (("thrust",thrust,70),("tau_x",f"-0.012*({er1})-0.0025*u[31]",45),("tau_y",f"-0.012*({er2})-0.0025*u[32]",20)):
 add("SysplorerEmbeddedCoder.Utilities.Fcn",n,55,y);setp(n,"ExprEdit",e);con("geo_mux.y",n+".u")
add("SysplorerEmbeddedCoder.SignalRouting.Mux","control_mux",80,45);setp("control_mux","Inputs","3")
for i,n in enumerate(("thrust","tau_x","tau_y"),1):con(n+".y",f"control_mux.u{i}")
qexpr=("125*u[1]-2946.028753*u[2]-2946.028753*u[3]","125*u[1]+2946.028753*u[2]-2946.028753*u[3]","125*u[1]+2946.028753*u[2]+2946.028753*u[3]","125*u[1]-2946.028753*u[2]+2946.028753*u[3]")
# 分配结果先限幅到非负转速平方，再恢复电机旋向符号。
for i,e in enumerate(qexpr,1):
 n=f"q{i}";add("SysplorerEmbeddedCoder.Utilities.Fcn",n,100,80-20*i);setp(n,"ExprEdit",e);con("control_mux.y",n+".u")
 c=f"clip{i}";add("SysplorerEmbeddedCoder.Utilities.Fcn",c,115,80-20*i);setp(c,"ExprEdit","max(u,0)");con(n+".y",c+".u")
 f=f"clip_flag{i}";add("SysplorerEmbeddedCoder.Utilities.Fcn",f,115,-10-15*i);setp(f,"ExprEdit","if u < 0 then 1 else 0");con(n+".y",f+".u")
 r=f"sqrt{i}";add("SysplorerEmbeddedCoder.MathOperation.Sqrt",r,130,80-20*i);con(c+".y",r+".u")
 if i in (2,4):
  g=f"sign{i}";add("SysplorerEmbeddedCoder.MathOperation.Gain",g,145,80-20*i);setp(g,"Gain","-1");con(r+".y",g+".u")
add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate","motor_mux",160,35);setp("motor_mux","NumInputs","4")
con("sqrt1.y","motor_mux.u1");con("sign2.y","motor_mux.u2");con("sqrt3.y","motor_mux.u3");con("sign4.y","motor_mux.u4");con("motor_mux.y","motor_cmd")

add("SysplorerEmbeddedCoder.SignalRouting.Mux","allocation_mux",80,-5);setp("allocation_mux","Inputs","7")
for i,n in enumerate(("thrust","tau_x","tau_y","clip1","clip2","clip3","clip4"),1):con(n+".y",f"allocation_mux.u{i}")
residual="sqrt((0.002*(u[4]+u[5]+u[6]+u[7])-u[1])^2+(0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])-u[2])^2+(0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])-u[3])^2)"
add("SysplorerEmbeddedCoder.Utilities.Fcn","allocation_residual",95,-5);setp("allocation_residual","ExprEdit",residual);con("allocation_mux.y","allocation_residual.u")
add("SysplorerEmbeddedCoder.SignalRouting.Mux","clip_flag_mux",80,-25);setp("clip_flag_mux","Inputs","4")
for i in range(1,5):con(f"clip_flag{i}.y",f"clip_flag_mux.u{i}")
add("SysplorerEmbeddedCoder.Utilities.Fcn","clip_count",95,-25);setp("clip_count","ExprEdit","u[1]+u[2]+u[3]+u[4]");con("clip_flag_mux.y","clip_count.u")
fcn("position_error_norm","sqrt((u[12]-u[1])^2+(u[13]-u[2])^2+(u[14]-u[3])^2)",55,-75)
for n,e,y in (("attitude_error_x",er1,-45),("attitude_error_y",er2,-60)):
 add("SysplorerEmbeddedCoder.Utilities.Fcn",n,55,y);setp(n,"ExprEdit",e);con("geo_mux.y",n+".u")
add("SysplorerEmbeddedCoder.SignalRouting.Mux","attitude_error_mux",75,-55);setp("attitude_error_mux","Inputs","2")
con("attitude_error_x.y","attitude_error_mux.u1");con("attitude_error_y.y","attitude_error_mux.u2")
add("SysplorerEmbeddedCoder.Utilities.Fcn","attitude_error_norm",90,-55);setp("attitude_error_norm","ExprEdit","sqrt(u[1]^2+u[2]^2)");con("attitude_error_mux.y","attitude_error_norm.u")
add("SysplorerEmbeddedCoder.Sources.Constant","zero",75,-90);setp("zero","Value","0");setp("zero","OutDataTypeStr","double");setp("zero","SampleTime",TS)

# 诊断向量集中输出控制量、分配残差和误差范数。
add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate","diag_mux",100,-45);setp("diag_mux","NumInputs","12")
for i,n in enumerate(("force_x","force_y","force_z","tau_x","tau_y"),1):con(n+".y",f"diag_mux.u{i}")
con("zero.y","diag_mux.u6")
con("allocation_residual.y","diag_mux.u7")
con("clip_count.y","diag_mux.u8")
con("position_error_norm.y","diag_mux.u9")
con("attitude_error_norm.y","diag_mux.u10")
con("zero.y","diag_mux.u11");con("zero.y","diag_mux.u12")
con("diag_mux.y","diagnostics")
save_result=M.SaveModel(MODEL)
if save_result is not True and not isinstance(save_result,str):
    raise RuntimeError(f"save: {save_result!r}")
RUN_SCRIPT_RESULT={"model":MODEL,"dir":M.GetDirectory()}
