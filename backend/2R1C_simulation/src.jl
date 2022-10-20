using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant

R1 = 1.0
R2 = 1.0
C = 1.0
Croom = 10.0
Vin = 1.0
@variables t
@named r1 = Resistor(R=R1)
@named r2 = Resistor(R=R2)
@named capacitor = Capacitor(C=C)
@named capacitor_room = Capacitor(C=Croom, v_start=Vin)
# @named source = Voltage()
# @named constant = Constant(k=Vin)
@named ground = Ground()

rc_eqs = [
        connect(capacitor_room.p, r1.p)
        connect(r1.n, capacitor.p, r2.p)
        connect(capacitor.n, capacitor_room.n, r2.n, ground.g)
        ]

@named single_layer_wall_model = ODESystem(rc_eqs, t, systems=[r1, r2, capacitor, capacitor_room, ground])
sys = structural_simplify(single_layer_wall_model)
prob = ODAEProblem(sys, Pair[], (0, 200.0))
sol = solve(prob, Tsit5())
plot(sol, vars = [capacitor_room.v, capacitor.v],
    title = "Single-Layer Wall Model (2R1C) Circuit Demonstration",
    labels = ["Room Temperature" "Wall Temperature"])
savefig("plot.png")