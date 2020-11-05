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
max_damage_array = [0.0325,0.03,0.0275,0.025,0.0225,0.02,0.0175,0.015,0.0125,0.01,0.0075,0.005,0.0025]
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
    fos = 2.0
    scale = 10.0

    # start_x = rand(nturbines).*(maximum(turbine_x)-minimum(turbine_x)).+minimum(turbine_x)
    # start_y = rand(nturbines).*(maximum(turbine_y)-minimum(turbine_y)).+minimum(turbine_y)
    # x = [copy(start_x);copy(start_y)]./scale

    # start_x = readdlm("x_FINAL2_17.txt")[:,1]
    # start_y = readdlm("y_FINAL2_17.txt")[:,1]



    start_x = readdlm("layout_opt_small/x_40_small_26.txt")[:,1]
    start_y = readdlm("layout_opt_small/y_40_small_26.txt")[:,1]
    # x = [74.62835790467558, 96.24487360835423, 154.7390380148238, 76.940120391648, 131.9001110349114, 7.5667210651691015, 151.74988867010538, -17.85328197655721, 202.77060877173366, 40.06032358580818, 24.580669806621884, -13.394261340750733, 306.28011108954684, 281.13987710207437, -6.506282922824992, 48.88510998506487, 177.33216011729903, 234.36390715738028, 104.67425552205279, -4.842729645856914, 15.260485666866897, 177.90286509931195, 125.84327335687206, 51.66012581500048, 229.98519383201642, 252.58016081392057, 300.24154512979237, 267.5044232270395, 142.80373110066586, 254.7867708699692, 102.09290672799364, 180.0127491219712, 73.86268755539163, 228.25472935359338, 0.27618724255419136, 274.0713173326423, 277.2488586717766, 205.19959991664967, 287.3501981983801, 32.83168280268644, 137.45513420315154, 220.50686848427185, 232.24031231608717, -0.3359289502762173, 221.40099187740734, 17.429619625529398, 12.79878390786671, 218.5398584315955, 2.876443120182572, 115.52248993918344, 229.2030115975768, 109.71582615634672, 0.2837624682797359, 95.69611664336172, 164.43724734138524, 236.15805204419888, 5.933790834115881, 108.98960170090179, 196.6730290124586, 39.454240694783714, 110.02290185361244, 141.59853334245713, 18.187550731409768, -0.3193694879668013, 229.99711944470116, 218.6465542486473, 48.74710092161503, -0.33592895027621805, 38.72101090898128, 25.584498039534584, 2.1982844454135564, 232.80416442076273, 232.25938168992067, 18.456910105522955, 236.15805204419888, 180.22036512714243, 235.78739941685555, 234.97233153165521, 156.53782452488002, 16.557777378256162]
    # start_x = readdlm("x_40_19.txt")[:,1]
    # start_y = readdlm("y_40_19.txt")[:,1]

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

    open("x_$max_damage.txt", "w") do io
            writedlm(io, opt_x)
    end

    open("y_$max_damage.txt", "w") do io
            writedlm(io, opt_y)
    end
end
