using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant, Cosine
import IfElse
import Random, Distributions, Plots, StatsPlots

R1 = 0.55
R2 = 0.55
C = 380800
Croom = 60025
V = 303.0
V_heating = 323.0
V_desired = 293.0
Random.seed!(321)
rand_heating_gen = Distributions.Normal(15, 0.1 * 15)

StatsPlots.plot(rand_heating_gen, fill=(0, .5,:orange))
StatsPlots.xlabel!("Heating constant (J/K)")
StatsPlots.ylabel!("Probability Distribution Function")
StatsPlots.savefig("NormalDist_HeatingInput.png")

prop_const_samples = Random.rand(rand_heating_gen, 10)
print(prop_const_samples)
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

## Three Port for Room component
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
        energy(t) = 0.0
    end
    eqs = [v1 ~ p.v - n1.v
           v2 ~ p.v - n2.v
           0 ~ p.i - n1.i - n2.i
           i1 ~ p.i
           i2 ~ n1.i
           i3 ~ n2.i
          ]
    return ModelingToolkit.compose(ODESystem(eqs, t, sts, []; name = name), p, n1, n2)
end

## Three Port for wall component
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
    return ModelingToolkit.compose(ODESystem(eqs, t, sts, []; name = name), p1, p2, n)
end

## Wall function
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

function Room_component(; name, Croom, V_heating, V_desired, proportional_const)
    @named threeport_room = ThreePort_Room()
    @unpack v1,v2,i1,i2,i3,ifcond,energy = threeport_room

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
            D(energy) ~ -i3
        ]
    extend(ODESystem(room_eqs, t, [], pars; name = name, continuous_events), threeport_room)   

end

@named wall1 = wall_2R1C(; R1, R2, C)
Plots.plot()
v_room_final = []
energy_spent = []

for proportional_const in prop_const_samples 

    @named room = Room_component(; Croom, V_heating, V_desired, proportional_const)

    eqs = [
        connect(room.p, wall1.p1)
        connect(variable.output, source.V)
        connect(source.p, wall1.p2)
        connect(room.n1, room.n2, source.n, wall1.n, ground.g)
        ]


    @named single_layer_wall_model = ODESystem(eqs, t, systems=[wall1, room, source, variable, ground])
    sys = structural_simplify(single_layer_wall_model)
    prob = ODAEProblem(sys, Pair[] , (0, 3600))
    sol = solve(prob, Tsit5())
    #plot(sol, vars = capacitor_room.v, title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature"])
    Plots.plot!(sol, vars = [room.v1], labels ="" , linewidth=3, palatte=:blues, thickness_scaling = 1)
    
    #print("Energy Spent: ")
    #println()
    push!(v_room_final, sol(1800)[2])
    push!(energy_spent, sol(3600)[4])
    #plot(sol, vars = [capacitor_room.v, wall.vc], title = "Single-Layer Wall Model (2R1C) Circuit Demonstration", labels = ["Room Temperature" "Wall Temperature"])
end
Plots.title!("1 Room model")
Plots.xlabel!("Time (sec)")
Plots.ylabel!("Temperature (K)")
Plots.savefig("temperature_profile.png")

normal_room_temp = Distributions.fit_mle(Distributions.Normal, Array{Float64}(v_room_final))
println(normal_room_temp)
StatsPlots.plot(normal_room_temp, fill=(0, .5,:blues))
StatsPlots.xlabel!("Room Temperature (K)")
StatsPlots.ylabel!("Probability Distribution Function")
StatsPlots.savefig("NormalDist_RoomTemp.png")

normal_energy = Distributions.fit_mle(Distributions.Normal, Array{Float64}(energy_spent))
println(normal_energy)
StatsPlots.plot(normal_energy, fill=(0, .5,:blues))
StatsPlots.xlabel!("Energy (J)")
StatsPlots.ylabel!("Probability Distribution Function")
StatsPlots.savefig("NormalDist_Energy.png")