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

    return (damage .- max_damage).*10.0
end

function wind_farm_opt(x)
    t1 = time()
    spacing_con = spacing_wrapper(x)
    println("spacing call: ", time()-t1)
    t2 = time()
    ds_dx = ForwardDiff.jacobian(spacing_wrapper,x)
    println("spacing gradient: ", time()-t2)
    t3 = time()

    boundary_con = boundary_wrapper(x)
    println("boundary call: ", time()-t3)
    t4 = time()
    db_dx = ForwardDiff.jacobian(boundary_wrapper,x)
    println("boundary gradient: ", time()-t4)
    t5 = time()

    damage_con = damage_wrapper(x)
    println("damage call: ", time()-t5)
    println("damage: ", maximum(damage_con))
    t6 = time()
    dd_dx = ForwardDiff.jacobian(damage_wrapper,x)
    println("damage gradient: ", time()-t6)


    c = [spacing_con;boundary_con;damage_con]
    dcdx = [ds_dx;db_dx;dd_dx]

    t7 = time()
    AEP = -aep_wrapper(x)[1]
    println("AEP: ", -AEP)
    println("AEP call: ", time()-t7)
    t8 = time()
    dAEP_dx = -ForwardDiff.jacobian(aep_wrapper,x)
    println("AEP gradient: ", time()-t8)

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

# max_damage = 0.2
max_damage = 0.0
div_sigma = 2.38512084848453
div_ti = 1.1841406781776536
fos = 1.15
scale = 10.0
include("model_lowTI_NEW.jl")

nCycles = 100

start_x = turbine_x = readdlm("no_loads/x_no_loads70.txt")[:,1]
start_y = turbine_y = readdlm("no_loads/y_no_loads70.txt")[:,1]
x = [copy(start_x);copy(start_y)]./scale
AEP, c, dAEP_dx, dcdx, fail = wind_farm_opt(x)
println(AEP)
