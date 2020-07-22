using Snopt
import ForwardDiff

function ti_wrapper(x)

    global turbine_x
    global turbine_y
    global rotor_diameter
    global hub_height
    global turbine_ct
    global sorted_turbine_index
    global ambient_ti
    global sweep
    global data_array

    ds = x[1]
    dt = x[2]

    ti_vec = zeros(typeof(ds),length(data_array))
    sep_arr = [4.0,7.0,10.0]

    index = 1
    for k = 1:3
        sep = sep_arr[k]
        x = rotor_diameter[1]*sep
        y_vec = range(-200.0,stop=200.0,length=161)
        z = hub_height[1]
        for j = 1:161
            loc = [x,y_vec[j],z]
            ti_vec[index] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height, turbine_ct, sorted_turbine_index, ambient_ti[1]; div_sigma=ds, div_ti=dt)
            index += 1
        end
    end
    return [sum((ti_vec .- data_array) .^2)]./1.0

end

function params_opt(x)
    vels = ti_wrapper(x)
    dvels_dx = ForwardDiff.jacobian(ti_wrapper,x)

    c = []
    dcdx = []

    fail = false
    return vels[1], c, dvels_dx, dcdx, fail
end


global turbine_x
global turbine_y
global rotor_diameter
global hub_height
global turbine_ct
global sorted_turbine_index
global ambient_ti
global sweep
global data_array


wind_speed = 13.0
TI = "high"
ambient_ti = [0.08]

include("TI_data.jl")
TI4,l = get_ti_data(wind_speed,TI,4.0)
TI7,l = get_ti_data(wind_speed,TI,7.0)
TI10,l = get_ti_data(wind_speed,TI,10.0)

p1 = 1
p2 = 161
sweep = range(-200.0,stop=200.0,length=length(TI4))[p1:p2]

data_array = [TI4[p1:p2];TI7[p1:p2];TI10[p1:p2]]
include("model_optParams.jl")



x = rand(2) .* 5.0

println("start: ", ti_wrapper(x))

lb = zeros(4) .+ 0.000
ub = zeros(4) .+ 1000.0
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

ds = xopt[1]
dt = xopt[2]
#
println("ds = ",ds)
println("dt = ",dt)

plot(data_array)

sep = [4.0,7.0,10.0]
#
ti_points = zeros(typeof(k1),length(sweep)*length(sep))
global index = 1
for k = 1:3
    sep = sep_arr[k]
    x = rotor_diameter[1]*sep
    y_vec = range(-200.0,stop=200.0,length=161)
    z = hub_height[1]
    for j = 1:161
        global index
        loc = [x,y_vec[j],z]
        ti_points[index] = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height, turbine_ct, sorted_turbine_index, ambient_ti[1]; div_sigma=ds, div_ti=dt)
        index += 1
    end
end
#
plot(ti_points)
