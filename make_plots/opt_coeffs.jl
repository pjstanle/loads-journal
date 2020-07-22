using Snopt
import ForwardDiff

function vel_wrapper(x)

    global wec_factor
    global wakedeflectionmodel
    global wakecombinationmodel
    global rotor_diameter
    global hub_height
    global turbine_x
    global turbine_y
    global turbine_z
    global turbine_yaw
    global turbine_ct
    global turbine_ai
    global turbine_local_ti
    global sorted_turbine_index
    global ambient_ti
    global wtvelocities
    global wind_resource
    global model_set
    global sweep
    global data_array

    alpha_star = x[1]
    beta_star = x[2]
    k1 = x[3]
    k2 = x[4]

    wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
    local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
    model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)


    sep = [4.0,7.0,10.0]

    vel_points = zeros(typeof(k1),length(sweep)*length(sep))
    index = 1
    for i = 1:length(sep)
        turbine_local_ti = copy(ambient_ti)
        turbine_local_ti = ff.calculate_local_ti(turbine_x, turbine_y, ambient_ti, rotor_diameter, hub_height, turbine_yaw, turbine_local_ti, sorted_turbine_index,
                            turbine_inflow_velcities, turbine_ct, local_ti_model)
        for j = 1:length(sweep)
            loc = [sep[i]*rotor_diameter[1],sweep[j],hub_height[1]]
            vel_points[index] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                            rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, turbine_inflow_velcities,
                            windresource, model_set)
            index += 1
        end
    end
    return [sum((vel_points .- data_array) .^2)]./1.0
end


function params_opt(x)
    vels = vel_wrapper(x)
    dvels_dx = ForwardDiff.jacobian(vel_wrapper,x)

    c = []
    dcdx = []

    fail = false
    return vels[1], c, dvels_dx, dcdx, fail
end


global wec_factor
global wakedeflectionmodel
global wakecombinationmodel
global rotor_diameter
global hub_height
global turbine_x
global turbine_y
global turbine_z
global turbine_yaw
global turbine_ct
global turbine_ai
global turbine_local_ti
global sorted_turbine_index
global ambient_ti
global wtvelocities
global wind_resource
global model_set
global sweep
global data_array


wind_speed = 12.0
TI = "high"

ambient_ti = [0.08]


include("vel_data.jl")
U4,l = get_vel_data(wind_speed,TI,4.0)
U7,l = get_vel_data(wind_speed,TI,7.0)
U10,l = get_vel_data(wind_speed,TI,10.0)

p1 = 1
p2 = 161
sweep = range(-200.0,stop=200.0,length=length(U4))[p1:p2]

data_array = [U4[p1:p2];U7[p1:p2];U10[p1:p2]]
println(length(data_array))

# wind_speed = 14.0
include("model_optParams.jl")

windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
x = [copy(alpha_star);copy(beta_star);copy(k1);copy(k2)]

x = rand(4) .* [5.0,1.0,1.0,0.01]
# x = [5.0,0.5,0.3837,0.003678]

println("start: ", vel_wrapper(x))

lb = zeros(4) .+ 0.000
ub = zeros(4) .+ 10.0
options = Dict{String, Any}()
options["Derivative option"] = 1
options["Verify level"] = 3
options["Major optimality tolerance"] = 1e-6
options["Major iteration limit"] = 1e6
options["Summary file"] = "snopt-summary.out"
options["Print file"] = "snopt-print.out"

xopt, fopt, info = snopt(params_opt, x, lb, ub, options)

println("xopt: ", xopt)
println("fopt: ", fopt)
println("info: ", info)

alpha_star = xopt[1]
beta_star = xopt[2]
k1 = xopt[3]
k2 = xopt[4]

println("alpha_star = ",alpha_star)
println("beta_star = ",beta_star)
println("k1 = ",k1)
println("k2 = ",k2)

plot(data_array)

# alpha_star = 10.0
# beta_star = 10.0
# k1 = 0.4265761026936039
# k2 = 0.005200957856493224

# k1 = 0.15
# k2 = 0.0
# alpha_star = 8.059490825809203
# beta_star = 0.0

wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

sep = [4.0,7.0,10.0]

vel_points = zeros(typeof(k1),length(sweep)*length(sep))
global index = 1
for i = 1:length(sep)
    turbine_local_ti = copy(ambient_ti)
    turbine_local_ti = ff.calculate_local_ti(turbine_x, turbine_y, ambient_ti, rotor_diameter, hub_height, turbine_yaw, turbine_local_ti, sorted_turbine_index,
                        turbine_inflow_velcities, turbine_ct, local_ti_model)
    for j = 1:length(sweep)
        global index
        loc = [sep[i]*rotor_diameter[1],sweep[j],hub_height[1]]
        vel_points[index] = ff.point_velocity(loc[1],loc[2],loc[3], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                        rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, turbine_inflow_velcities,
                        windresource, model_set)
        index += 1
    end
end

plot(vel_points)
