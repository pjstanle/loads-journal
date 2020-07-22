using PyPlot
include("TI_data.jl")
include("TIcoeffs_data.jl")
include("model.jl")
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
        ws = ws_arr[j]
        ds,dt = getTI_coeffs(ws,TI)

        TI_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            TI_model[i] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height,
                                turbine_ct, sorted_turbine_index, ambient_ti; div_sigma=ds, div_ti=dt)
        end

        if sep == 4.0 && ws == 10.0
            subplot(461)
            title("4 D",fontsize=10)
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
            ylabel(string("TI\n",L"$U_\infty=10$ m/s"))
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                bottom=false,
                labelbottom=false)
        elseif sep == 7.0 && ws == 10.0
            subplot(462)
            title("7 D",fontsize=10)
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
            text(0.0,0.25,"low freestream turbulence: 4.6%",fontsize=10,horizontalalignment="center")
        elseif sep == 10.0 && ws == 10.0
            subplot(463)
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
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
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                ylabel(string("TI\n",L"$U_\infty=11$ m/s"))
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    bottom=false,
                    labelbottom=false)
        elseif sep == 7.0 && ws == 11.0
                subplot(468)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(469)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(4,6,13)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                ylabel(string("TI\n",L"$U_\infty=12$ m/s"))
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both",      # both major and minor ticks are affected
                        bottom=false,
                        labelbottom=false)
        elseif sep == 7.0 && ws == 12.0
                subplot(4,6,14)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(4,6,15)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,6,19)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                ylabel(string("TI\n",L"$U_\infty=13$ m/s"))
                xlabel("offset (D)")
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both")
        elseif sep == 7.0 && ws == 13.0
                subplot(4,6,20)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,6,21)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr,label="SOWFA")
                plot(sweep,TI_model,label="model")
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
                # legend(loc=1)
        end

        ylim(0.0,0.2)

        yticks([0.05,0.1,0.15,0.2])
        end
end





TI = "high"
ambient_ti = 0.08
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        ws = ws_arr[j]
        ds,dt = getTI_coeffs(ws,TI)

        TI_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            TI_model[i] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height,
                                turbine_ct, sorted_turbine_index, ambient_ti; div_sigma=ds, div_ti=dt)
        end

        if sep == 4.0 && ws == 10.0
            subplot(464)
            title("4 D",fontsize=10)
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
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
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                left=false,
                bottom=false,
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
            text(0.0,0.25,"high freestream turbulence: 8%",fontsize=10,horizontalalignment="center")
        elseif sep == 10.0 && ws == 10.0
            subplot(466)
            ti_arr, ti_locs = get_ti_data(ws,TI,sep)
            plot(ti_locs./rotor_diameter[1],ti_arr)
            plot(sweep,TI_model)
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
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
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
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(4,6,12)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(4,6,16)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
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
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(4,6,18)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    bottom=false,
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,6,22)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                # ylabel(string("TI\n",L"$U_\infty=13$ m/s"))
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 7.0 && ws == 13.0
                subplot(4,6,23)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr)
                plot(sweep,TI_model)
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,6,24)
                ti_arr, ti_locs = get_ti_data(ws,TI,sep)
                plot(ti_locs./rotor_diameter[1],ti_arr,label="SOWFA")
                plot(sweep,TI_model,label="model")
                xlabel("offset (D)")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    left=false,
                    labelleft=false) # labels along the bottom edge are off
                legend(loc=1,fontsize=8)
        end

        ylim(0.0,0.2)

        yticks([0.05,0.1,0.15,0.2])
        end
end



subplots_adjust(top=0.91,bottom=0.1,left=0.13,right=0.99,wspace=0.0,hspace=0.03)
savefig("TI_all.pdf",transparent=true)
