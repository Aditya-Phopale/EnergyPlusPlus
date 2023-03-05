using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant, Cosine
import IfElse

R1 = 0.55
R2 = 0.55
C = 380800
Croom = 60025
V = 303.0
V_heating = 323.0
V_desired = 293.0
proportional_const = 15
frequency = 0.00001157407 


# @named capacitor_room = Capacitor(C=Croom, v_start=Vin1)
# @named capacitor_second_room = Capacitor(C=C_second_room, v_start=Vin2)
@named ground = Ground()

@variables t
D = Differential(t)

@named source = Voltage()
@named constant = Constant(k=V)
@named variable = Cosine(frequency=frequency, amplitude=10, phase=pi, offset=293.0, smooth=true)
# @named constant = Constant(k=V)

function ThreePort(; name, v1_start = 0.0, v2_start = 0.0, i1_start = 0.0, i2_start = 0.0, i3_start = 0.0, v_wall_start = 283.0)
    @named p1 = Pin()
    @named p2 = Pin()
    @named n = Pin()
    sts = @variables begin
        v1(t) = v1_start
        v2(t) = v2_start
        i1(t) = i1_start
        i2(t) = i2_start
        i3(t) = i3_start
        vc(t) = v_wall_start
    end
    eqs = [v1 ~ p1.v - n.v
           v2 ~ p2.v - n.v
           0 ~ p1.i + p2.i - n.i
           i1 ~ p1.i
           i2 ~ p2.i
           i3 ~ n.i
          ]
    return compose(ODESystem(eqs, t, sts, []; name = name), p1, p2, n)
end

function ThreePort_Room(; name, v1_start = 283.0, v2_start = 0.0, i1_start = 0.0, i2_start = 0.0, i3_start = 0.0)
    @named p = Pin()
    @named n1 = Pin()
    @named n2 = Pin()
    sts = @variables begin
        v1(t) = v1_start
        v2(t) = v2_start
        i1(t) = i1_start
        i2(t) = i2_start
        i3(t) = i3_start
        ifcond(t) = false
    end
    eqs = [v1 ~ p.v - n1.v
           v2 ~ p.v - n2.v
           0 ~ p.i - n1.i - n2.i
           i1 ~ p.i
           i2 ~ n1.i
           i3 ~ n2.i
          ]
    return compose(ODESystem(eqs, t, sts, []; name = name), p, n1, n2)
end

function Room_component(; name, Croom, V_heating, V_desired, proportional_const)
    @named threeport_room = ThreePort_Room()
    @unpack v1,v2,i1,i2,i3,ifcond = threeport_room

    pars = @parameters begin 
        V_heating = V_heating
        V_desired = V_desired
        proportional_const = proportional_const
        Croom = Croom
    end

    continuous_events = [
        (v1 - V_desired ~ 1) => [ifcond ~ true]
        (v1 - V_desired ~ -1) => [ifcond ~ false]
    ]

    room_eqs = [
            i3 ~ IfElse.ifelse(ifcond == true, 0, proportional_const*(v1 - V_heating))
            D(v1) ~ i2/Croom
            D(ifcond) ~ 0   
        ]
    extend(ODESystem(room_eqs, t, [], pars; name = name, continuous_events), threeport_room)   

end

function wall_2R1C(; name, R1, R2, C)
    
    @named threeport = ThreePort()
    @unpack v1,v2,i1,i2,i3,vc = threeport

    pars = @parameters begin 
        R1 = R1
        R2 = R2
        C = C
    end

    wall_eqs = [
        v2 ~ R2*i2 + vc
        v1 ~ R1*i1 + vc
        D(vc) ~ i3/C
        ]
    extend(ODESystem(wall_eqs, t, [], pars; name = name), threeport)   

end

@named wall1 = wall_2R1C(; R1, R2, C)
@named wall2 = wall_2R1C(; R1, R2, C)
@named wall3 = wall_2R1C(; R1, R2, C)
@named wall4 = wall_2R1C(; R1, R2, C)
@named room = Room_component(; Croom, V_heating, V_desired, proportional_const)

eqs = [
    connect(room.p, wall1.p1, wall2.p1, wall3.p1, wall4.p1)
    connect(variable.output, source.V)
    connect(source.p, wall1.p2, wall2.p2, wall3.p2, wall4.p2)
    connect(room.n1, room.n2, source.n, wall1.n, wall2.n, wall3.n, wall4.n, ground.g)
    ]


@named single_layer_wall_model = ODESystem(eqs, t, systems=[wall1, wall2, wall3, wall4, room, source, variable, ground])
sys = structural_simplify(single_layer_wall_model)
prob = ODAEProblem(sys, Pair[] , (0, 86400.0))
sol = solve(prob, Tsit5())
#plot(sol, vars = capacitor_room.v, title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature"])
p = plot(sol, vars = [room.v1, wall1.vc], title = "1 Room 4 Wall model", labels = ["Room Temperature" "Wall Temperature"], linewidth=3, thickness_scaling = 1)
xlabel!(p, "Time (sec)")
ylabel!(p, "Temperature (K)")
#plot(sol, vars = [capacitor_room.v, wall.vc], title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature" "Wall Temperature"])

savefig("plot.png")