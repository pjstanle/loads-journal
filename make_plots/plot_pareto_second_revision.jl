using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade
using PyPlot


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

    return AEP
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
    println(repr(damage))
    return damage
end







nCycles = 50

aep_damage = 0.04277141896198941

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
div_sigma = 2.3486026424379896
div_ti = 1.1679980785130557
fos = 2.0
scale = 10.0

start_x = readdlm("second_revision_aep/x_40_small_5.txt")[:,1]
start_y = readdlm("second_revision_aep/y_40_small_5.txt")[:,1]

x = [copy(start_x);copy(start_y)]./scale
aep = aep_wrapper(x)
damage = maximum(damage_wrapper(x))

max_damage_array = [damage]
aep_array = [aep]


# damage_array = [0.7,0.72,0.74,0.76,0.78,0.8,0.82,0.84,0.86,0.87,0.88,0.89,0.9,0.91,0.92,0.93,0.94,0.95,0.96,0.97,0.98,0.99]
damage_array = [0.72]

for i = 1:length(damage_array)
    d = damage_array[i]
    start_x = readdlm("second_revision_loads/x_$d.txt")[:,1]
    start_y = readdlm("second_revision_loads/y_$d.txt")[:,1]

    x = [copy(start_x);copy(start_y)]
    if d > 0.86
        x = x./scale
    end

    aep = aep_wrapper(x)
    damage = maximum(damage_wrapper(x))

    println(aep)
    println(damage)

    if damage < max_damage_array[1]
        append!(max_damage_array, damage)
        append!(aep_array, aep)
    end
end

max_damage_array = [0.04277141896198941, 0.03083831598159119,
        0.031688238192752134, 0.03251380253372907, 0.033419987012664375,
        0.03721816344753529, 0.038926224017336024,
        0.04106313853279312]
aep_array = [9.435682164392372, 9.345775630690733,
        9.384151053606464, 9.411318710564794, 9.41975710422765,
        9.427560644677104, 9.430564116929395,
        9.43379719880475]

println(repr(max_damage_array./max_damage_array[1]))
println(repr(aep_array./aep_array[1]))

figure(figsize=(3,2.5))
plot(max_damage_array./max_damage_array[1],aep_array./aep_array[1],"o")
xlabel("normalized damage")
ylabel("normalized AEP")
tight_layout()
# for i = 1:length(aep_array)
#     text(max_damage_array[i]/max_damage_array[1],aep_array[i]/aep_array[1],"$i")
end
# savefig("pareto_second_revision.pdf",transparent=true)
