import mworks.sysplorer as M

# 固定采样周期和执行器上限用于构建可复现的CAP-ADRC框图。
MODEL = "A8FormalADRCV11PX4AllocV1A_20260712"
TS = "0.01"
QMAX = "3600"
B0_ROLL = "8595.05449458058"
B0_PITCH = "8595.11317201388"
Z3_LIMIT_ROLL = "21.48763623645145"
Z3_LIMIT_PITCH = "21.48778293003470"


def req(label, value):
    if value is not True:
        raise RuntimeError(f"{label}: {value!r}")


def add(block_type, name, x, y):
    req("add " + name, M.AddComponent(block_type, MODEL, name, x, y))


def setp(name, parameter, value):
    req(f"{name}.{parameter}", M.SetModelParamValue(MODEL, name, parameter, value))


def con(source, target):
    req(source + "->" + target, M.ConnectPort(MODEL, source, target))


def fcn(name, expression, x, y, source="input_mux.y"):
    add("SysplorerEmbeddedCoder.Utilities.Fcn", name, x, y)
    setp(name, "ExprEdit", expression)
    con(source, name + ".u")


def delay(name, x, y):
    add("SysplorerEmbeddedCoder.Discrete.UnitDelay", name, x, y)
    setp(name, "InitialCondition", "0")
    setp(name, "SampleTime", TS)


def desaturation_gain_expression(count):
    # 汇总各电机越界修正量，供公共去饱和增益使用。
    corrections = [
        f"(if u[{i}] < 0 then -u[{i}] else if u[{i}] > {QMAX} then {QMAX}-u[{i}] else 0)"
        for i in range(1, count + 1)
    ]
    lower = "0"
    upper = "0"
    for correction in corrections:
        lower = f"min({lower},{correction})"
        upper = f"max({upper},{correction})"
    return lower + "+" + upper


if M.ClassExist(MODEL):
    raise RuntimeError("model exists")
M.NewModel(MODEL, "Sysblock")
if not M.ClassExist(MODEL):
    raise RuntimeError("NewModel did not create the class")

for name, dimension, port_type, x, y in (
    ("reference", 11, "Inport", -170, 45),
    ("state", 18, "Inport", -170, -45),
    ("motor_cmd", 4, "Outport", 190, 45),
    ("diagnostics", 12, "Outport", 190, -45),
):
    add("SysplorerEmbeddedCoder.Port." + port_type, name, x, y)
    setp(name, "Dimension", str(dimension))
    setp(name, "OutDataTypeStr", "double")
    setp(name, "SampleTime", TS)

add("SysplorerEmbeddedCoder.SignalRouting.DeMux", "reference_demux", -150, 45)
setp("reference_demux", "Outputs", "11")
con("reference", "reference_demux.u")
add("SysplorerEmbeddedCoder.SignalRouting.DeMux", "state_demux", -150, -45)
setp("state_demux", "Outputs", "18")
con("state", "state_demux.u")
add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate", "input_mux", -125, 0)
setp("input_mux", "NumInputs", "29")
for index in range(1, 12):
    con(f"reference_demux.y{index}", f"input_mux.u{index}")
for index in range(1, 19):
    con(f"state_demux.y{index}", f"input_mux.u{index + 11}")

mass = 0.163156684
kp_pos = 3.2
kv_pos = 2.4

def outer_integral_axis(axis, error_expression, x, y):
    # 带泄漏和限幅的积分状态用于抑制持续位置偏差。
    error_name = "outer_" + axis + "_error"
    fcn(error_name, error_expression, x, y)
    delay_name = "outer_" + axis + "_integral_delay"
    delay(delay_name, x + 20, y)
    update_mux = "outer_" + axis + "_integral_mux"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", update_mux, x + 40, y)
    setp(update_mux, "Inputs", "2")
    con(error_name + ".y", update_mux + ".u1")
    con(delay_name + ".y", update_mux + ".u2")
    next_name = "outer_" + axis + "_integral_next"
    fcn(next_name, "max(min(0.98*u[2]+0.01*u[1],0.5),-0.5)", x + 60, y, update_mux + ".y")
    con(next_name + ".y", delay_name + ".u1")
    force_input = "force_" + axis + "_input"
    add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate", force_input, x + 80, y)
    setp(force_input, "NumInputs", "2")
    con("input_mux.y", force_input + ".u1")
    con(delay_name + ".y", force_input + ".u2")
    return force_input

force_x_input = outer_integral_axis("x", "u[1]-u[12]", -120, 105)
force_y_input = outer_integral_axis("y", "u[2]-u[13]", -120, -95)
fcn("force_x", f"{mass}*(-{kp_pos}*(u[12]-u[1])-{kv_pos}*(u[15]-u[4])+u[7]+1.5*u[30])", -20, 75, force_x_input + ".y")
fcn("force_y", f"{mass}*(-{kp_pos}*(u[13]-u[2])-{kv_pos}*(u[16]-u[5])+u[8]+1.5*u[30])", -20, 50, force_y_input + ".y")
fcn("force_z", f"{mass}*(-{kp_pos}*(u[14]-u[3])-{kv_pos}*(u[17]-u[6])+u[9]+9.81)", -105, 25)

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "force_mux", -80, 50)
setp("force_mux", "Inputs", "3")
for index, name in enumerate(("force_x", "force_y", "force_z"), 1):
    con(name + ".y", f"force_mux.u{index}")
for name, expression, y in (
    ("b3x", "u[1]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)", 85),
    ("b3y", "u[2]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)", 65),
    ("b3z", "u[3]/sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)", 45),
    ("force_norm", "sqrt(u[1]^2+u[2]^2+u[3]^2+1e-12)", 25),
):
    fcn(name, expression, -55, y, "force_mux.y")

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "geo_mux", -30, 55)
setp("geo_mux", "Inputs", "5")
for index, name in enumerate(("b3x", "b3y", "b3z", "force_norm"), 1):
    con(name + ".y", f"geo_mux.u{index}")
con("input_mux.y", "geo_mux.u5")

# 将期望合力方向转换为约化姿态误差和推力指令。
denominator = "sqrt(u[2]^2+u[3]^2+1e-9)"
thrust_expression = "u[4]*(u[1]*u[24]+u[2]*u[27]+u[3]*u[30])"
er_x = (
    f"0.5*((u[23]*u[1]+u[26]*u[2]+u[29]*u[3])-"
    f"((u[3]/{denominator})*u[27]+(-u[2]/{denominator})*u[30]))"
)
b1x = f"(u[2]^2+u[3]^2)/{denominator}"
b1y = f"-u[1]*u[2]/{denominator}"
b1z = f"-u[1]*u[3]/{denominator}"
er_y = (
    f"0.5*((u[24]*({b1x})+u[27]*({b1y})+u[30]*({b1z}))-"
    "(u[1]*u[22]+u[2]*u[25]+u[3]*u[28]))"
)
fcn("thrust", thrust_expression, 0, 90, "geo_mux.y")
fcn("attitude_error_x", er_x, 0, 65, "geo_mux.y")
fcn("attitude_error_y", er_y, 0, 40, "geo_mux.y")


def observer_axis(axis, error_block, b0, z3_limit, x, y):
    mux = axis + "_state_mux"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", mux, x, y)
    setp(mux, "Inputs", "4")
    con(error_block + ".y", mux + ".u1")
    for index, state_name in enumerate(("z1", "z2", "z3"), 2):
        delay_name = axis + "_" + state_name + "_delay"
        delay(delay_name, x + 45, y + (index - 3) * 18)
        con(delay_name + ".y", f"{mux}.u{index}")

    expressions = {
        "z1_next": "u[2]+0.01*(u[3]+75*(u[1]-u[2]))",
        "z3_next": f"max(min(u[4]+0.01*(15625*(u[1]-u[2])),{z3_limit}),-{z3_limit})",
    }
    for offset, (suffix, expression) in enumerate(expressions.items()):
        name = axis + "_" + suffix
        fcn(name, expression, x + 20, y + 55 - 18 * offset, mux + ".y")
    con(axis + "_z1_next.y", axis + "_z1_delay.u1")
    con(axis + "_z3_next.y", axis + "_z3_delay.u1")

    feedback = axis + "_feedback_torque"
    fcn(feedback, f"max(min((-100*u[2]-22*u[3])/{b0},0.0045),-0.0045)",
        x + 20, y + 5, mux + ".y")
    remaining = axis + "_remaining_authority"
    fcn(remaining, "0.0045-abs(u)", x + 45, y + 5, feedback + ".y")

    disturbance_mux = axis + "_disturbance_mux"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", disturbance_mux, x + 65, y - 10)
    setp(disturbance_mux, "Inputs", "2")
    con(axis + "_z3_delay.y", disturbance_mux + ".u1")
    con(remaining + ".y", disturbance_mux + ".u2")
    disturbance = axis + "_disturbance_torque"
    fcn(disturbance, f"max(min(-u[1]/{b0},u[2]),-u[2])",
        x + 85, y - 10, disturbance_mux + ".y")

    torque_mux = axis + "_torque_mux"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", torque_mux, x + 105, y + 5)
    setp(torque_mux, "Inputs", "2")
    con(feedback + ".y", torque_mux + ".u1")
    con(disturbance + ".y", torque_mux + ".u2")
    fcn(axis + "_torque", "u[1]+u[2]", x + 125, y + 5, torque_mux + ".y")


observer_axis("roll", "attitude_error_x", B0_ROLL, Z3_LIMIT_ROLL, 25, 60)
observer_axis("pitch", "attitude_error_y", B0_PITCH, Z3_LIMIT_PITCH, 25, -55)

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "control_mux", 100, 50)
setp("control_mux", "Inputs", "3")
for index, name in enumerate(("thrust", "roll_torque", "pitch_torque"), 1):
    con(name + ".y", f"control_mux.u{index}")

q_expressions = (
    "125*u[1]-2946.028753*u[2]-2946.028753*u[3]",
    "125*u[1]+2946.028753*u[2]-2946.028753*u[3]",
    "125*u[1]+2946.028753*u[2]+2946.028753*u[3]",
    "125*u[1]-2946.028753*u[2]+2946.028753*u[3]",
)
for index, expression in enumerate(q_expressions, 1):
    q_name = f"q{index}"
    fcn(q_name, expression, 120, 90 - 20 * index, "control_mux.y")
    flag_name = f"clip_flag{index}"
    fcn(flag_name, f"if u < 0 or u > {QMAX} then 1 else 0",
        140, -25 - 15 * index, q_name + ".y")

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "q_raw_mux", 140, 90)
setp("q_raw_mux", "Inputs", "4")
for index in range(1, 5):
    con(f"q{index}.y", f"q_raw_mux.u{index}")
fcn("desaturation_gain_1", desaturation_gain_expression(4), 155, 90, "q_raw_mux.y")

for index in range(1, 5):
    pass_mux = f"pass1_mux{index}"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", pass_mux, 155, 75 - 18 * index)
    setp(pass_mux, "Inputs", "2")
    con(f"q{index}.y", pass_mux + ".u1")
    con("desaturation_gain_1.y", pass_mux + ".u2")
    fcn(f"q_pass1_{index}", "u[1]+u[2]", 170, 75 - 18 * index, pass_mux + ".y")

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "q_pass1_mux", 185, 90)
setp("q_pass1_mux", "Inputs", "4")
for index in range(1, 5):
    con(f"q_pass1_{index}.y", f"q_pass1_mux.u{index}")
fcn("desaturation_gain_2", "0.5*(" + desaturation_gain_expression(4) + ")",
    200, 90, "q_pass1_mux.y")

for index in range(1, 5):
    final_mux = f"final_mux{index}"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", final_mux, 200, 75 - 18 * index)
    setp(final_mux, "Inputs", "3")
    con(f"q{index}.y", final_mux + ".u1")
    con("desaturation_gain_1.y", final_mux + ".u2")
    con("desaturation_gain_2.y", final_mux + ".u3")
    fcn(f"q_final_{index}", f"max(min(u[1]+u[2]+u[3],{QMAX}),0)",
        215, 75 - 18 * index, final_mux + ".y")
    sqrt_name = f"sqrt{index}"
    add("SysplorerEmbeddedCoder.MathOperation.Sqrt", sqrt_name, 230, 75 - 18 * index)
    con(f"q_final_{index}.y", sqrt_name + ".u")
    if index in (2, 4):
        sign_name = f"sign{index}"
        add("SysplorerEmbeddedCoder.MathOperation.Gain", sign_name, 245, 75 - 18 * index)
        setp(sign_name, "Gain", "-1")
        con(sqrt_name + ".y", sign_name + ".u")

add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate", "motor_mux", 260, 45)
setp("motor_mux", "NumInputs", "4")
con("sqrt1.y", "motor_mux.u1")
con("sign2.y", "motor_mux.u2")
con("sqrt3.y", "motor_mux.u3")
con("sign4.y", "motor_mux.u4")
con("motor_mux.y", "motor_cmd")

add("SysplorerEmbeddedCoder.SignalRouting.Mux", "allocation_mux", 105, -80)
setp("allocation_mux", "Inputs", "7")
for index, name in enumerate(("thrust", "roll_torque", "pitch_torque",
        "q_final_1", "q_final_2", "q_final_3", "q_final_4"), 1):
    con(name + ".y", f"allocation_mux.u{index}")
residual = (
    "sqrt((0.002*(u[4]+u[5]+u[6]+u[7])-u[1])^2+"
    "(0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])-u[2])^2+"
    "(0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])-u[3])^2)"
)
fcn("allocation_residual", residual, 130, -80, "allocation_mux.y")
fcn("achieved_roll_torque", "0.002*0.04243*(-u[4]+u[5]+u[6]-u[7])", 130, -60, "allocation_mux.y")
fcn("achieved_pitch_torque", "0.002*0.04243*(-u[4]-u[5]+u[6]+u[7])", 130, -40, "allocation_mux.y")

def connect_z2_update(axis, error_block, achieved_block, b0, y):
    mux = axis + "_z2_update_mux"
    add("SysplorerEmbeddedCoder.SignalRouting.Mux", mux, 105, y)
    setp(mux, "Inputs", "5")
    con(error_block + ".y", mux + ".u1")
    con(axis + "_z1_delay.y", mux + ".u2")
    con(axis + "_z2_delay.y", mux + ".u3")
    con(axis + "_z3_delay.y", mux + ".u4")
    con(achieved_block + ".y", mux + ".u5")
    fcn(axis + "_z2_next", f"u[3]+0.01*(u[4]+{b0}*u[5]+1875*(u[1]-u[2]))", 130, y, mux + ".y")
    con(axis + "_z2_next.y", axis + "_z2_delay.u1")

connect_z2_update("roll", "attitude_error_x", "achieved_roll_torque", B0_ROLL, -10)
connect_z2_update("pitch", "attitude_error_y", "achieved_pitch_torque", B0_PITCH, -25)
add("SysplorerEmbeddedCoder.SignalRouting.Mux", "clip_flag_mux", 105, -100)
setp("clip_flag_mux", "Inputs", "4")
for index in range(1, 5):
    con(f"clip_flag{index}.y", f"clip_flag_mux.u{index}")
fcn("clip_count", "u[1]+u[2]+u[3]+u[4]", 130, -100, "clip_flag_mux.y")
fcn("position_error_norm", "sqrt((u[12]-u[1])^2+(u[13]-u[2])^2+(u[14]-u[3])^2)", 105, -120)
add("SysplorerEmbeddedCoder.SignalRouting.Mux", "attitude_error_mux", 105, -140)
setp("attitude_error_mux", "Inputs", "2")
con("attitude_error_x.y", "attitude_error_mux.u1")
con("attitude_error_y.y", "attitude_error_mux.u2")
fcn("attitude_error_norm", "sqrt(u[1]^2+u[2]^2)", 130, -140, "attitude_error_mux.y")
add("SysplorerEmbeddedCoder.SignalRouting.Mux", "disturbance_estimate_mux", 105, -160)
setp("disturbance_estimate_mux", "Inputs", "2")
con("roll_z3_delay.y", "disturbance_estimate_mux.u1")
con("pitch_z3_delay.y", "disturbance_estimate_mux.u2")
fcn("disturbance_estimate_norm", "sqrt(u[1]^2+u[2]^2)", 130, -160, "disturbance_estimate_mux.y")

add("SysplorerEmbeddedCoder.Sources.Constant", "zero", 130, -180)
setp("zero", "Value", "0")
setp("zero", "OutDataTypeStr", "double")
setp("zero", "SampleTime", TS)
add("SysplorerEmbeddedCoder.Sources.Constant", "status_code", 130, -200)
setp("status_code", "Value", "30")
setp("status_code", "OutDataTypeStr", "double")
setp("status_code", "SampleTime", TS)

add("SysplorerEmbeddedCoder.SignalRouting.VectorConcatenate", "diag_mux", 160, -80)
setp("diag_mux", "NumInputs", "12")
for index, name in enumerate(("force_x", "force_y", "force_z", "roll_torque", "pitch_torque"), 1):
    con(name + ".y", f"diag_mux.u{index}")
con("zero.y", "diag_mux.u6")
con("allocation_residual.y", "diag_mux.u7")
con("clip_count.y", "diag_mux.u8")
con("position_error_norm.y", "diag_mux.u9")
con("attitude_error_norm.y", "diag_mux.u10")
con("disturbance_estimate_norm.y", "diag_mux.u11")
con("status_code.y", "diag_mux.u12")
con("diag_mux.y", "diagnostics")

save_result = M.SaveModel(MODEL)
if save_result is not True and not isinstance(save_result, str):
    raise RuntimeError(f"save: {save_result!r}")
RUN_SCRIPT_RESULT = {"model": MODEL, "dir": M.GetDirectory(), "save": save_result}
