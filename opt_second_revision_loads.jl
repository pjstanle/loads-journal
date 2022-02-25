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
    return ff.convex_boundary(boundary_vertices,boundary_normals,turbine_x,turbine_y) .* 10.0
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

    AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
                hub_height, turbine_yaw, ct_model, generator_efficiency, cut_in_speed,
                cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
                rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e11

    return [AEP]
end


function damage_wrapper(x)
    global turbine_z
    global rotor_diameter
    global hub_height
    global turbine_yaw
    global turbine_ai
    global ct_model
    global nCycles
    global az_arr
    global turb_samples
    global pitch_func
    global turbulence_func
    global r
    global sections
    global Rhub
    global Rtip
    global precone
    global tilt
    global air_density
    global windresource
    global model_set
    global Nlocs
    global fos
    global rotor_points_y
    global rotor_points_z
    global div_sigma
    global div_ti
    global max_damage

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines] .* scale
    turbine_y = x[nturbines+1:end] .* scale

    damage = ff.get_total_farm_damage_FINAL(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,ct_model,
            nCycles,az_arr,turb_samples,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
            Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,div_sigma=div_sigma,div_ti=div_ti)

    return (damage .- max_damage).*100.0
end

function wind_farm_opt(x)
    println("___________________")
    println(repr(x))
    spacing_con = spacing_wrapper(x)
    ds_dx = ForwardDiff.jacobian(spacing_wrapper,x)

    boundary_con = boundary_wrapper(x)
    db_dx = ForwardDiff.jacobian(boundary_wrapper,x)

    damage_con = damage_wrapper(x)
    println("damage: ", maximum(damage_con))
    dd_dx = ForwardDiff.jacobian(damage_wrapper,x)


    c = [spacing_con;boundary_con;damage_con]
    dcdx = [ds_dx;db_dx;dd_dx]

    AEP = -aep_wrapper(x)[1]
    println("AEP: ", -AEP)
    dAEP_dx = -ForwardDiff.jacobian(aep_wrapper,x)

    fail = false
    return AEP, c, dAEP_dx, dcdx, fail
end

nCycles = 50

global max_damage_array
# max_damage_array = [0.0325,0.03,0.0275,0.025,0.0225,0.02,0.0175,0.015,0.0125,0.01,0.0075,0.005,0.0025]
aep_damage = 0.04277141896198941
# max_damage_array = range(0.99,stop=0,length=100)
# max_damage_array = [0.8,0.78,0.76,0.74,0.72,0.7,0.68,0.66,0.64,0.62,0.6]
max_damage_array = [0.72]
for k = 1:length(max_damage_array)

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


    global nCycles
    global az_arr
    global turb_samples
    global pitch_func
    global turbulence_func
    global r
    global sections
    global Rhub
    global Rtip
    global precone
    global tilt
    global air_density
    global Nlocs
    global fos
    global div_sigma
    global div_ti
    global max_damage

    global max_damage_array

    include("model_lowTI_NEW.jl")
    nCycles = 50
    MD = max_damage_array[k]
    max_damage = MD * aep_damage
    println("max_damage: ", max_damage)
    div_sigma = 2.3486026424379896
    div_ti = 1.1679980785130557
    fos = 2.0
    scale = 10.0

    start_x = readdlm("second_revision_aep/x_40_small_5.txt")[:,1]
    start_y = readdlm("second_revision_aep/y_40_small_5.txt")[:,1]

    x = [copy(start_x);copy(start_y)]./scale

    println("start: ", aep_wrapper(x))

    lb = zeros(length(x)) .- 1000000.0
    ub = zeros(length(x)) .+ 1000000.0
    options = Dict{String, Any}()
    options["Derivative option"] = 1
    options["Verify level"] = -1
    options["Major optimality tolerance"] = 1.3e-4
    options["Major iteration limit"] = 1e6
    options["Minor iteration limit"] = 1e6
    options["Iteration limit"] = 1e6
    options["Superbasics limit"] = 1000
    options["Summary file"] = "snopt-summary.out"
    options["Print file"] = "snopt-print.out"

    xopt, fopt, info = snopt(wind_farm_opt, x, lb, ub, options)
    println("xopt: ", xopt)
    println("opt AEP: ", -fopt)
    println("info: ", info)


    # damage = ff.get_total_farm_damage_FINAL(start_x,start_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,ct_model,
    #         nCycles,az_arr,turb_samples,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
    #         Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,div_sigma=div_sigma,div_ti=div_ti)

    opt_x = copy(xopt[1:nturbines]).*scale
    opt_y = copy(xopt[nturbines+1:end]).*scale
    optAEP = -fopt

    # open("AEP_FINAL2_loads.txt", "a") do io
    #         writedlm(io, optAEP)
    # end


    open("x_$MD.txt", "w") do io
            writedlm(io, opt_x)
    end

    open("y_$MD.txt", "w") do io
            writedlm(io, opt_y)
    end
end
