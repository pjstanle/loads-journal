include("TI_data.jl")
include("TIcoeffs_data.jl")
# include("TIcoeffs_data_vct.jl")
# include("model.jl")

function get_r2(data,model)
            avg = mean(data)
            N = length(data)
            sq_diff = zeros(N)
            sq_mean = zeros(N)
            for i = 1:N
                        sq_diff[i] = (data[i]-model[i])^2
                        sq_mean[i] = (data[i]-avg)^2
            end
            r2 = 1-sum(sq_diff)/sum(sq_mean)
            return r2
end


# turbine_ct = zeros(nturbines) .+ 0.7620929940139257
# turbine_x = [0.0]

L = 161
sweep = range(-1.5,stop=1.5,length=L)

sep_arr = [4.0,7.0,10.0]
ws_arr = [10.0,11.0,12.0,13.0]

r2_arr_low = zeros(4,3)
r2_arr_high = zeros(4,3)



TI = "low"
ambient_ti = 0.046

for j = 1:length(ws_arr)
    data_array = []
    model_array = []
    for k = 1:length(sep_arr)
        sep = sep_arr[k]

        global wind_speed = ws_arr[j]
        include("model_optParams.jl")
        ds,dt = getTI_coeffs(wind_speed,TI)
        ti_arr, ti_locs = get_ti_data(wind_speed,TI,sep)

        TI_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            TI_model[i] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height,
                                [turbine_ct], sorted_turbine_index, ambient_ti[1]; div_sigma=ds, div_ti=dt)
        end

        data_array = append!(data_array, ti_arr)
        model_array = append!(model_array, TI_model)

        end
    println("r2 ", TI, " ", ws_arr[j], " ", get_r2(data_array,model_array))
end





TI = "high"
ambient_ti = 0.08
for j = 1:length(ws_arr)
    data_array = []
    model_array = []
    for k = 1:length(sep_arr)
        sep = sep_arr[k]
        global wind_speed = ws_arr[j]
        include("model_optParams.jl")
        ds,dt = getTI_coeffs(wind_speed,TI)
        ti_arr, ti_locs = get_ti_data(wind_speed,TI,sep)

        TI_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            TI_model[i] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height,
                                turbine_ct, sorted_turbine_index, ambient_ti[1]; div_sigma=ds, div_ti=dt)
        end

        data_array = append!(data_array, ti_arr)
        model_array = append!(model_array, TI_model)

        end
    println("r2 ", TI, " ", ws_arr[j], " ", get_r2(data_array,model_array))
end

# varinfo()
