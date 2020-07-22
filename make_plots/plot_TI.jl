using FlowFarm
using PyPlot
const ff = FlowFarm



include("model.jl")
include("TIcoeffs_data.jl")
ws = 13.0
# turbine_ct = zeros(nturbines) .+ ff.calculate_ct(ws, ct_model1)
turbine_ct = zeros(nturbines) .+ 0.7620929940139257
TI_amb = 0.08
global ti
ti = "high"
plot_model = true
plot_data = true
# ds = 1.5
# dt = 2.75
ds,dt = getTI_coeffs(ws,ti)

sep_arr = [4.0,7.0,10.0]

figure(1,figsize=[6.0,2.5])
for k = 1:3
    sep = sep_arr[k]

    x = rotor_diameter[1]*sep
    y_vec = range(-1.5*rotor_diameter[1],stop = 1.5*rotor_diameter[1],length=100)
    z = hub_height[1]
    TI = zeros(length(y_vec))

    for i = 1:length(TI)
               loc = [x,y_vec[i],z]
               TI[i] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height, turbine_ct, sorted_turbine_index, TI_amb; div_sigma=ds, div_ti=dt)
    end

    if k == 1
        subplot(131)
        ylabel("TI")
    elseif k == 2
        subplot(132)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    elseif k == 3
        subplot(133)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    end


    if plot_data == true
        global ti
        include("TI_data.jl")
        ti_data,x_TI = get_ti_data(ws,ti,sep)
        plot(x_TI./rotor_diameter[1],ti_data,label="SOWFA")

    end

    if plot_model == true
        if k == 3
            plot(y_vec./rotor_diameter[1],TI,label="TI model")
            legend(loc=1)
        else
            plot(y_vec./rotor_diameter[1],TI)
        end
    end

    ylim(0.0,0.225)
    xlabel("offset (D)")

end

subplots_adjust(top=0.91,bottom=0.18,left=0.11,right=0.99,wspace=0.05)
