using Statistics
include("model.jl")
include("vel_data.jl")
include("coeffs_data_vct.jl")

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

turbine_ct = zeros(nturbines) .+ 0.7620929940139257
turbine_x = [0.0]

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
        include("model.jl")
        ws = ws_arr[j]
        vel_arr, vel_locs = get_vel_data(ws,TI,sep)
        turbine_ct = ones(nturbines) .* ff.calculate_ct(ws,ct_model[1])
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
        alpha_star,beta_star,k1,k2 = get_coeffs(ws,TI)
        wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
        local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
        model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

        turbine_x = [0.0]
        U_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            U_model[i] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                                rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, ws,
                                windresource, model_set)
        end
        data_array = append!(data_array, vel_arr)
        model_array = append!(model_array, U_model)
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
        include("model.jl")
        ws = ws_arr[j]
        vel_arr, vel_locs = get_vel_data(ws,TI,sep)
        turbine_ct = ones(nturbines) .* ff.calculate_ct(ws,ct_model[1])
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
        alpha_star,beta_star,k1,k2 = get_coeffs(ws,TI)
        wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
        local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
        model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

        turbine_x = [0.0]
        U_model = zeros(L)
        for i = 1:L
            loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
            U_model[i] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                                rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, ws,
                                windresource, model_set)
        end
        data_array = append!(data_array, vel_arr)
        model_array = append!(model_array, U_model)
    end
    println("r2 ", TI, " ", ws_arr[j], " ", get_r2(data_array,model_array))
end
