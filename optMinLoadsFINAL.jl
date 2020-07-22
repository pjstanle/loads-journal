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
    global aep_min

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines] .* scale
    turbine_y = x[nturbines+1:end] .* scale

    AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
                hub_height, turbine_yaw, ct_model, generator_efficiency, cut_in_speed,
                cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
                rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e11

    return [aep_min-AEP]
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

    return [maximum(damage)]
end

function wind_farm_opt(x)
    println("___________________")
    println(repr(x))
    spacing_con = spacing_wrapper(x)
    ds_dx = ForwardDiff.jacobian(spacing_wrapper,x)

    boundary_con = boundary_wrapper(x)
    db_dx = ForwardDiff.jacobian(boundary_wrapper,x)

    AEP_con = aep_wrapper(x)
    println("AEP constraint: ", AEP_con)
    dAEP_dx = ForwardDiff.jacobian(aep_wrapper,x)

    c = [spacing_con;boundary_con;AEP_con]
    dcdx = [ds_dx;db_dx;dAEP_dx]

    damage = damage_wrapper(x)[1]
    println("damage: ", damage)
    dd_dx = ForwardDiff.jacobian(damage_wrapper,x)

    fail = false
    return damage, c, dd_dx, dcdx, fail
    # return AEP, c, dAEP_dx, dcdx, fail
end

nCycles = 50

global filenum

filenum = 1
for k = 1:1000
    global filenum

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

    global aep_min

    aep_min = 11.075958276599959

    include("model_lowTI_NEW.jl")
    nCycles = 50
    # max_damage = 0.2
    max_damage = 0.16
    div_sigma = 2.38512084848453
    div_ti = 1.1841406781776536
    fos = 1.25
    scale = 10.0

    start_x = rand(nturbines).*(maximum(turbine_x)-minimum(turbine_x)).+minimum(turbine_x)
    start_y = rand(nturbines).*(maximum(turbine_y)-minimum(turbine_y)).+minimum(turbine_y)
    x = [copy(start_x);copy(start_y)]./scale

    # start_x = readdlm("x_FINAL11.txt")[:,1]
    # start_y = readdlm("y_FINAL11.txt")[:,1]
    # x = [copy(start_x);copy(start_y)]./scale

    println("start: ", aep_wrapper(x))

    lb = zeros(length(x))
    ub = zeros(length(x)) .+6.30021755e+01*diam*frac
    options = Dict{String, Any}()
    options["Derivative option"] = 1
    options["Verify level"] = -1
    options["Major optimality tolerance"] = 1.0e-4
    options["Major iteration limit"] = 1.0e6
    options["Summary file"] = "snopt-summary.out"
    options["Print file"] = "snopt-print.out"

    # t1 = time()
    xopt, fopt, info = snopt(wind_farm_opt, x, lb, ub, options)
    println("Finished: ", time()-t1)
    println("xopt: ", xopt)
    println("opt damage: ", fopt)
    println("info: ", info)


    # damage = ff.get_total_farm_damage_FINAL(start_x,start_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,ct_model,
    #         nCycles,az_arr,turb_samples,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
    #         Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,div_sigma=div_sigma,div_ti=div_ti)

    # opt_x = copy(xopt[1:nturbines]).*scale
    # opt_y = copy(xopt[nturbines+1:end]).*scale

    # optAEP = -fopt
    # open("AEP_minLoads.txt", "a") do io
    #         writedlm(io, optAEP)
    # end

    open("x_minLoads$filenum.txt", "w") do io
            writedlm(io, opt_x)
    end

    open("y_minLoads$filenum.txt", "w") do io
            writedlm(io, opt_y)
    end

    filenum += 1
end
