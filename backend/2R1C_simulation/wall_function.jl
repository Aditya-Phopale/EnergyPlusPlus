using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant

R1 = 1.0
R2 = 1.0
C = 1.0
Croom = 2.0
C_second_room = 100.0
Vin1 = 20.0
Vin2 = 10.0

@named capacitor_room = Capacitor(C=Croom, v_start=Vin1)
@named capacitor_second_room = Capacitor(C=C_second_room, v_start=Vin2)
@named ground = Ground()

@parameters t
D = Differential(t)

function ThreePort(; name, v1_start = 0.0, v2_start = 0.0, i1_start = 0.0, i2_start = 0.0, i3_start = 0.0)
    @named p1 = Pin()
    @named p2 = Pin()
    @named n = Pin()
    sts = @variables begin
        v1(t) = v1_start
        v2(t) = v2_start
        i1(t) = i1_start
        i2(t) = i2_start
        i3(t) = i3_start
        vc(t) = v1_start
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

# function OnePort(; name, v_start = 0.0, i_start = 0.0)
#     @named p = Pin()
#     @named n = Pin()
#     sts = @variables begin
#         v(t) = v_start
#         i(t) = i_start
#     end
#     eqs = [v ~ p.v - n.v
#            0 ~ p.i + n.i
#            i ~ p.i]
#     return compose(ODESystem(eqs, t, sts, []; name = name), p, n)
# end

function wall_2R1C(; name, R1, R2, C)
    
    @named threeport = ThreePort()
    @unpack v1,v2,i1,i2,i3,vc = threeport

    pars = @parameters begin 
        R1 = R1
        R2 = R2
        C = C
    end 

    # @named r1 = Resistor(R=R1)
    # @named r2 = Resistor(R=R2)
    # @named capacitor = Capacitor(C=C)

    wall_eqs = [
        v2 ~ R2*i2 + vc
        v1 ~ R1*i1 + vc
        D(vc) ~ i3/C
        
        
        # v ~ r1.p.v - r1.n.v
        # connect(oneport.p, r1.p),
        # connect(oneport.n, r2.n)
        # i ~ r1.p.i
        ]
    extend(ODESystem(wall_eqs, t, [], pars; name = name), threeport)   

end

# function wall_2R1C(; name, R1, R2, C, ground)
    
#     @named twoport = TwoPort()
#     @unpack v1, v2, i1, i2 = twoport

#     @named r1 = Resistor(R=R1)
#     @named r2 = Resistor(R=R2)
#     @named capacitor = Capacitor(C=C)

#     wall_eqs = [
#         connect(r1.n, capacitor.p, r2.p)
#         connect(capacitor.n, r2.n, ground.g)
#         v1 ~ r1.p.v - r2.n.v
#         v2 ~ r1.p.v - capacitor.n.v
#         i1 ~ r1.p.i

#         ]
#     extend(ODESystem(wall_eqs, t, systems=[r1, r2, capacitor, ground]; name = name), oneport)   
# end

@named wall = wall_2R1C(; R1, R2, C)

eqs = [
    connect(capacitor_room.p, wall.p1)
    connect(capacitor_second_room.p, wall.p2)
    connect(capacitor_room.n, capacitor_second_room.n, wall.n, ground.g)
    #connect(capacitor_room.n, wall.p2, wall.n, ground.g)
    ]
 
# wall.p = capacitor_room.p
# wall.n = r2.n


@named single_layer_wall_model = ODESystem(eqs, t, systems=[wall, capacitor_room, capacitor_second_room, ground])
sys = structural_simplify(single_layer_wall_model)
prob = ODAEProblem(sys, Pair[] , (0, 50.0))
sol = solve(prob, Tsit5())
#plot(sol, vars = capacitor_room.v, title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature"])
plot(sol, vars = [capacitor_room.v, capacitor_second_room.v, wall.vc], title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature" "Second Room Temperature" "Wall Temperature"])
#plot(sol, vars = [capacitor_room.v, wall.vc], title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature" "Wall Temperature"])

savefig("plot.png")