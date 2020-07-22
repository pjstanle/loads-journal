using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade

nCycles = 50


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


nturbines = Int(length(x)/2)
turbine_x = x[1:nturbines] .* scale
turbine_y = x[nturbines+1:end] .* scale

AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
            hub_height, turbine_yaw, ct_model, generator_efficiency, cut_in_speed,
            cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
            rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e11

damage = ff.get_total_farm_damage_FINAL(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,ct_model,
        nCycles,az_arr,turb_samples,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
        Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,div_sigma=div_sigma,div_ti=div_ti)
