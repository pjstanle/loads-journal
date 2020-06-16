using Snopt
using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade

import ForwardDiff

function boundary_wrapper(x)
    global boundary_vertices
    global boundary_normals
    global scale
    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines].*scale
    turbine_y = x[nturbines+1:end].*scale
    return ff.windfarm_boundary(boundary_vertices,boundary_normals,turbine_x,turbine_y) .* 10.0
end

function spacing_wrapper(x)
    global rotor_diameter
    global scale
    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines].*scale
    turbine_y = x[nturbines+1:end].*scale
    return 2.0*rotor_diameter[1] .- ff.turbine_spacing(turbine_x,turbine_y)
end

function aep_wrapper(x)
    global turbine_z
    global rotor_diameter
    global hub_height
    global turbine_yaw
    global turbine_ai
    global ct_model
    global generator_efficiency
    global cut_in_speed
    global cut_out_speed
    global rated_speed
    global rated_power
    global windresource
    global power_model
    global model_set
    global rotor_points_y
    global rotor_points_z

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines] .* scale
    turbine_y = x[nturbines+1:end] .* scale
    turbine_inflow_velcities = zeros(typeof(turbine_x[1]),nturbines)

    AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
                hub_height, turbine_yaw, turbine_ai, ct_model, generator_efficiency, cut_in_speed,
                cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
                rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e11
    return [AEP]
end

function wind_farm_opt(x)

    spacing_con = spacing_wrapper(x)
    ds_dx = ForwardDiff.jacobian(spacing_wrapper,x)

    boundary_con = boundary_wrapper(x)
    db_dx = ForwardDiff.jacobian(boundary_wrapper,x)

    c = [spacing_con;boundary_con]
    dcdx = [ds_dx;db_dx]

    AEP = -aep_wrapper(x)[1]
    dAEP_dx = -ForwardDiff.jacobian(aep_wrapper,x)

    fail = false
    return AEP, c, dAEP_dx, dcdx, fail
end



global turbine_z
global rotor_diameter
global hub_height
global turbine_yaw
global turbine_ai
global ct_model
global generator_efficiency
global cut_in_speed
global cut_out_speed
global rated_speed
global rated_power
global windresource
global power_model
global model_set
global rotor_points_y
global rotor_points_z

global boundary_center
global boundary_radius
global scale

scale = 10.0
include("model_lowTI.jl")


global filenum
global AEP1
global AEP2
global AEP3
global AEP4
global AEP5

AEP1 = 0.0
AEP2 = 0.0
AEP3 = 0.0
AEP4 = 0.0
AEP5 = 0.0

filenum = 1
for k = 1:1000
    global filenum
    global AEP1
    global AEP2
    global AEP3
    global AEP4
    global AEP5
    start_x = rand(nturbines).*(maximum(turbine_x)-minimum(turbine_x)).+minimum(turbine_x)
    start_y = rand(nturbines).*(maximum(turbine_y)-minimum(turbine_y)).+minimum(turbine_y)
    x = [copy(start_x);copy(start_y)]./scale

    println("start: ", aep_wrapper(x))

    lb = zeros(length(x))
    ub = zeros(length(x)) .+6.30021755e+01*diam*frac
    options = Dict{String, Any}()
    options["Derivative option"] = 1
    options["Verify level"] = 0
    options["Major optimality tolerance"] = 1e-4
    options["Major iteration limit"] = 1e6
    options["Summary file"] = "snopt-summary.out"
    options["Print file"] = "snopt-print.out"

    t1 = time()
    xopt, fopt, info = snopt(wind_farm_opt, x, lb, ub, options)
    println("Finished: ", time()-t1)
    # println("xopt: ", xopt)
    println("opt AEP: ", -fopt)
    println("info: ", info)

    opt_x = copy(xopt[1:nturbines]).*scale
    opt_y = copy(xopt[nturbines+1:end]).*scale

    optAEP = -fopt
    open("AEP_no_loads.txt", "a") do io
            writedlm(io, optAEP)
    end

    open("x_no_loads$filenum.txt", "w") do io
            writedlm(io, opt_x)
    end

    open("y_no_loads$filenum.txt", "w") do io
            writedlm(io, opt_y)
    end

    if optAEP > AEP1
        AEP5 = copy(AEP4)
        AEP4 = copy(AEP3)
        AEP3 = copy(AEP2)
        AEP2 = copy(AEP1)
        AEP1 = copy(optAEP)
    elseif optAEP > AEP2
        AEP5 = copy(AEP4)
        AEP4 = copy(AEP3)
        AEP3 = copy(AEP2)
        AEP2 = copy(optAEP)
    elseif optAEP > AEP3
        AEP5 = copy(AEP4)
        AEP4 = copy(AEP3)
        AEP3 = copy(optAEP)
    elseif optAEP > AEP4
        AEP5 = copy(AEP4)
        AEP4 = copy(optAEP)
    elseif optAEP > AEP5
        AEP5 = copy(optAEP)
    end

    println("best AEPs: ", AEP1, ", ", AEP2, ", ", AEP3, ", ", AEP4, ", ", AEP5)
    filenum += 1
end



bx = boundary_vertices[:,1]
by = boundary_vertices[:,2]
append!(bx,bx[1])
append!(by,by[1])
plot(bx,by,color="black")

for i = 1:length(turbine_x)
    plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C1"))
end





# turbine_x = copy(x[1:nturbines]).*scale
# turbine_y = copy(x[nturbines+1:end]).*scale
# area = zeros(length(turbine_x)) .+ pi*(rotor_diameter[1]/2.0)^2
# for i = 1:length(turbine_x)
#     plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[1]/2.0, fill=false,color="C0"))
# end
#
# axis("square")
# xlim(-boundary_radius-200,boundary_radius+200)
# ylim(-boundary_radius-200,boundary_radius+200)
