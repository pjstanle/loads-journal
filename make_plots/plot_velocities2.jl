using PyPlot
include("model.jl")
include("vel_data.jl")
include("coeffs_data_vct.jl")
turbine_ct = zeros(nturbines) .+ 0.7620929940139257
turbine_x = [0.0]

L = 100
sweep = range(-1.5,stop=1.5,length=L)

sep_arr = [4.0,7.0,10.0]
ws_arr = [10.0,11.0,12.0,13.0]




figure(1,figsize=(6.5,6.5))


TI = "low"
ambient_ti = 0.046
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        include("model.jl")
        ws = ws_arr[j]
        turbine_ct = ones(nturbines) .* ff.calculate_ct(ws,ct_model[1])
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
        alpha_star,beta_star,k1,k2 = get_coeffs(ws,TI)
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
            subplot(461)
            title("4 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            ylabel(string("U (m/s)\n",L"$U_\infty=10$ m/s"))
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                bottom=false,
                labelbottom=false)
        elseif sep == 7.0 && ws == 10.0
            subplot(462)
            title("7 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
            text(0.0,18.0,"low freestream turbulence: 4.6%",fontsize=10,horizontalalignment="center")
        elseif sep == 10.0 && ws == 10.0
            subplot(463)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            title("10 D",fontsize=10)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 11.0
                subplot(467)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                ylabel(string("U (m/s)\n",L"$U_\infty=11$ m/s"))
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    bottom=false,
                    labelbottom=false)
        elseif sep == 7.0 && ws == 11.0
                subplot(468)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(469)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(4,6,13)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                ylabel(string("U (m/s)\n",L"$U_\infty=12$ m/s"))
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both",      # both major and minor ticks are affected
                        bottom=false,
                        labelbottom=false)
        elseif sep == 7.0 && ws == 12.0
                subplot(4,6,14)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(4,6,15)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,6,19)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                ylabel(string("U (m/s)\n",L"$U_\infty=13$ m/s"))
                xlabel("offset (D)")
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both")
        elseif sep == 7.0 && ws == 13.0
                subplot(4,6,20)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,6,21)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
                # legend(loc=1)
        end

        ylim(0.0,14.0)

        yticks([4.0,8.0,12.0])
        end
end





TI = "high"
ambient_ti = 0.08
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        include("model.jl")
        ws = ws_arr[j]
        turbine_ct = ones(nturbines) .* ff.calculate_ct(ws,ct_model[1])
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
        alpha_star,beta_star,k1,k2 = get_coeffs(ws,TI)
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
            subplot(464)
            title("4 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            # ylabel(string("TI\n",L"$U_\infty=10$ m/s"))
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
        elseif sep == 7.0 && ws == 10.0
            subplot(465)
            title("7 D",fontsize=10)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
            text(0.0,18.0,"high freestream turbulence: 8%",fontsize=10,horizontalalignment="center")
        elseif sep == 10.0 && ws == 10.0
            subplot(466)
            vel_arr, vel_locs = get_vel_data(ws,TI,sep)
            plot(vel_locs./rotor_diameter[1],vel_arr)
            plot(sweep,U_model)
            title("10 D",fontsize=10)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 11.0
                subplot(4,6,10)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                # ylabel(string("TI\n",L"$U_\infty=11$ m/s"))
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 7.0 && ws == 11.0
                subplot(4,6,11)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(4,6,12)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(4,6,16)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                # ylabel(string("TI\n",L"$U_\infty=12$ m/s"))
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 7.0 && ws == 12.0
                subplot(4,6,17)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(4,6,18)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,6,22)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                # ylabel(string("TI\n",L"$U_\infty=13$ m/s"))
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 7.0 && ws == 13.0
                subplot(4,6,23)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr)
                plot(sweep,U_model)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,6,24)
                vel_arr, vel_locs = get_vel_data(ws,TI,sep)
                plot(vel_locs./rotor_diameter[1],vel_arr,label="SOWFA")
                plot(sweep,U_model,label="model")
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
                legend(loc=4,fontsize=8)
        end

        ylim(0.0,14.0)

        yticks([4.0,8.0,12.0])
        end
end



subplots_adjust(top=0.91,bottom=0.1,left=0.13,right=0.99,wspace=0.0,hspace=0.03)
savefig("vels_all2.pdf",transparent=true)
