using FlowFarm
const ff = FlowFarm
using DelimitedFiles
using FLOWMath
using CCBlade
using PyPlot


include("../model_lowTI.jl")

turbine_x = readdlm("../no_loads/x_no_loads170.txt")[:,1]
turbine_y = readdlm("../no_loads/y_no_loads170.txt")[:,1]
damage_no_loads = ff.get_total_farm_damage_super(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,ct_model,
        nCycles,az_arr,turb_samples,omega_func,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
        Nlocs=Nlocs,fos=1.25)


turbine_x = readdlm("../with_loads/x_with_loads170.txt")[:,1]
turbine_y = readdlm("../with_loads/y_with_loads170.txt")[:,1]
damage_with_loads = ff.get_total_farm_damage_super(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,ct_model,
        nCycles,az_arr,turb_samples,omega_func,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
        Nlocs=Nlocs,fos=1.25)


figure(1,figsize=(6.5,3.5))
subplot(121)
plot(damage_no_loads,"o",color="C0",markersize=5)
ylim(0.0,0.55)
ylabel("damage")
xlabel("turbine number")
title("no damage constraints",fontsize=10)

subplot(122)
plot(damage_with_loads,"o",color="C1",markersize=5)
ylim(0.0,0.55)
xlabel("turbine number")
title("with damage constraints",fontsize=10)

tight_layout()

savefig("opt_damage_vals.pdf",transparent=true)
