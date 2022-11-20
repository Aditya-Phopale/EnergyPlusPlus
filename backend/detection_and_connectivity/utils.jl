__precompile__() 

using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant
using Compose, Cairo

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

## Three Port for wall componenet
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