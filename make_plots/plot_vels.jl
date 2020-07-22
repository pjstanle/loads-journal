using PyPlot
include("vel_data.jl")
wind_speed = 13.0
include("model.jl")
include("coeffs_data.jl")
using FlowFarm
const ff = FlowFarm


L = 161
# TI = "low"
# ambient_ti = [0.046]
TI = "high"
ambient_ti = [0.08]
# sweep = range(-1.5,stop=1.5,length=L)
sweep = range(-200.0,stop=200.0,length=L)

sep_arr = [4.0,7.0,10.0]
wind_speed = 13.0

# turbine_ct = ff.calculate_ct(wind_speed, ct_model1)


windresource = ff.DiscretizedWindResource(winddirections, [wind_speed], windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)


# k1 = 0.406188555910869
# alpha_star = 10.0
# beta_star = 10.0
# k1 = 0.20205170208572992
# k2 = 0.006155083538196953

alpha_star,beta_star,k1,k2 = get_coeffs(wind_speed,TI)

wec_factor = 1.0
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)


figure(1,figsize=(6.5,2.5))
for k = 1:length(sep_arr)
    sep = sep_arr[k]

    turbine_x = [0.0]
    U_model = zeros(L)
    for i = 1:L
        loc = [sep*rotor_diameter[1],sweep[i],hub_height[1]]
        U_model[i] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                            rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, wind_speed,
                            windresource, model_set)
    end



    vel_arr, vel_locs = get_vel_data(wind_speed,TI,sep)
    if sep == 4.0
        subplot(131)
        title("4 D",fontsize=10)
        plot(vel_locs,vel_arr)
        ylabel("wind speed (m/s)\nlow turbulence")
    elseif sep == 7.0
        subplot(132)
        title("7 D",fontsize=10)
        plot(vel_locs,vel_arr)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    elseif sep == 10.0
        subplot(133)
        plot(vel_locs,vel_arr)
        title("10 D",fontsize=10)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    end
    plot(sweep,U_model)
    ylim(5.0,14.0)
end


tight_layout()
