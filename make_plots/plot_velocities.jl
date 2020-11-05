using PyPlot
include("vel_data.jl")
include("coeffs_data.jl")
using CCBlade
using FlowFarm
L = 100
sweep = range(-1.5,stop=1.5,length=L)

sep_arr = [4.0,7.0,10.0]
ws_arr = [10.0,11.0,12.0,13.0]

# TI = "high"
# ambient_ti = [0.08]
TI = "low"
ambient_ti = [0.046]


figure(1,figsize=(6.5,6.5))
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        include("model.jl")
        ws = ws_arr[j]
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
        alpha_star,beta_star,k1,k2 = get_coeffs(ws,"low")
        wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
        local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
        model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)
        println(model_set.wake_deficit_model.alpha_star)

        turbine_x = [0.0]
        U_model = zeros(L)
        for i = 1:L
            # println(windresource)
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            U_model[i] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                                rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, ws,
                                windresource, model_set)
        end

        if sep == 4.0 && ws == 10.0
            subplot(431)
            title("4 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,"low",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            vel_arr, vel_locs = get_vel_data(ws,"high",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            # ylabel(string("wind speed (m/s)\n",L"$U_\infty=10$ m/s"))
            ylabel("10\nm/s",rotation=0,labelpad=16,verticalalignment="center")
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false)
            text(-2.7,14,"wind\nspeed",fontsize=10,horizontalalignment="center")
        elseif sep == 7.0 && ws == 10.0
            subplot(432)
            title("7 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,"low",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            vel_arr, vel_locs = get_vel_data(ws,"high",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 10.0
            subplot(433)
            vel_arr, vel_locs = get_vel_data(ws,"low",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            vel_arr, vel_locs = get_vel_data(ws,"high",sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            title("10 D",fontsize=10)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 11.0
                subplot(434)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("wind speed (m/s)\n",L"$U_\infty=11$ m/s"))
                ylabel("11\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false)
        elseif sep == 7.0 && ws == 11.0
                subplot(435)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(436)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(437)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("wind speed (m/s)\n",L"$U_\infty=12$ m/s"))
                ylabel("12\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both",      # both major and minor ticks are affected
                        labelbottom=false)
        elseif sep == 7.0 && ws == 12.0
                subplot(438)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(439)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,3,10)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("wind speed (m/s)\n",L"$U_\infty=13$ m/s"))
                ylabel("13\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                xlabel("offset (D)")
        elseif sep == 7.0 && ws == 13.0
                subplot(4,3,11)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,3,12)
                vel_arr, vel_locs = get_vel_data(ws,"low",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr,label="SOWFA low TI")
                vel_arr, vel_locs = get_vel_data(ws,"high",sep)
                plot(vel_locs./rotor_diameter[1],vel_arr,label="SOWFA high TI")
                plot(sweep,U_model,label="model")
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    labelleft=false) # labels along the bottom edge are off
                legend(loc=4,fontsize=8)
        end

        ylim(5.0,14.0)

        yticks([6,8,10,12])
        end
end


# suptitle("high turbulence intensity: 8%",fontsize=10)
subplots_adjust(top=0.91,bottom=0.1,left=0.15,right=0.99,wspace=0.1,hspace=0.1)
# savefig("vels_all.pdf",transparent=true)
