using Snopt
using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade

import ForwardDiff

function boundary_wrapper(x)
    global scale

    R = 990.4415496916475
    center = [0.0,0.0]

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines].*scale
    turbine_y = x[nturbines+1:end].*scale

    return ff.circle_boundary(center, R, turbine_x, turbine_y).*10.0
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

    return (damage .- max_damage).*10.0
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
max_damage_array = [0.2]
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
    max_damage = max_damage_array[k]
    div_sigma = 2.38512084848453
    div_ti = 1.1841406781776536
    fos = 1.25
    scale = 10.0

    # start_x = rand(nturbines).*(maximum(turbine_x)-minimum(turbine_x)).+minimum(turbine_x)
    # start_y = rand(nturbines).*(maximum(turbine_y)-minimum(turbine_y)).+minimum(turbine_y)
    # x = [copy(start_x);copy(start_y)]./scale

    start_x = readdlm("x_FINAL2_circle_37.txt")[:,1]
    start_y = readdlm("y_FINAL2_circle_37.txt")[:,1]
    x = [copy(start_x);copy(start_y)]./scale

    # x = [-39.46807778095461, 95.82021080452013, 98.53332846359405, -14.416712410351975,
    #     -81.95422349009581, 39.72435694415167, -10.35286335297663, -93.07680704431405,
    #     -42.94041447646081, -96.75434933955667, -72.72717960765371, 45.02116496725092,
    #     92.51137725618824, -97.32117132625326, -6.335873744061879, 5.697455154939603,
    #     72.5128204389754, 65.37924228282483, 82.84693384584757, 30.55774597696281,
    #     90.84060639640417, 25.06455367891073, -2.1998218803399916, 21.698986128703933,
    #     -55.61699342259888, 43.46248732204781, -35.11423825692266, 33.8593073200906,
    #     -89.25169755928243, -21.17405345525889, 67.23467906472212, 88.22040238465033,
    #     -30.91853928669541, 8.935092730081001, 90.2988612992185, -98.8801479497849,
    #     67.46581289253699, -74.3995931148944, -54.278268430318235, -94.21236040393298]

    println("start: ", aep_wrapper(x))

    lb = zeros(length(x)) .- 1000000.0
    ub = zeros(length(x)) .+ 1000000.0
    options = Dict{String, Any}()
    options["Derivative option"] = 1
    options["Verify level"] = -1
    options["Major optimality tolerance"] = 1.3e-4
    options["Major feasibility tolerance"] = 1.0e-4
    options["Major iteration limit"] = 1e6
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
    # optAEP = -fopt
    #
    # open("AEP_FINAL2_circle_loads.txt", "a") do io
    #         writedlm(io, optAEP)
    # end

    open("x_loads_circle$max_damage.txt", "w") do io
            writedlm(io, opt_x)
    end

    open("y_loads_circle$max_damage.txt", "w") do io
            writedlm(io, opt_y)
    end
end
