import ForwardDiff
using PyPlot

function aep_wrapper(x)
    global turbine_z
    global rotor_diameter
    global hub_height
    global turbine_yaw
    global turbine_ai
    global ct_model
    global generator_efficiency
    global cut_in_speed
    global cut_out_speed
    global rated_speed
    global rated_power
    global windresource
    global power_model
    global model_set
    global rotor_points_y
    global rotor_points_z

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines]
    turbine_y = x[nturbines+1:end]
    turbine_inflow_velcities = zeros(typeof(turbine_x[1]),nturbines)

    AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
                hub_height, turbine_yaw, turbine_ai, ct_model, generator_efficiency, cut_in_speed,
                cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
                rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e7
    return [AEP]
end

global turbine_z
global rotor_diameter
global hub_height
global turbine_yaw
global turbine_ai
global ct_model
global generator_efficiency
global cut_in_speed
global cut_out_speed
global rated_speed
global rated_power
global windresource
global power_model
global model_set
global rotor_points_y
global rotor_points_z


include("model_lowTI.jl")
# scatter(turbine_x,turbine_y)
# println(turbine_x[59], " ", turbine_y[59])
# println(turbine_x[60], " ", turbine_y[60])
# plot(turbine_x[59],turbine_y[59],"o",color="C3")
# plot(turbine_x[60],turbine_y[60],"o",color="C3")
x = [copy(turbine_x);copy(turbine_y)]
t1 = time()
AEP_orig = aep_wrapper(x)
println("call time: ", time()-t1)

# include("model_set_3.jl")
x = [copy(turbine_x);copy(turbine_y)]
t1 = time()
Jfor = ForwardDiff.jacobian(aep_wrapper,x)
println("time for ForwardDiff: ", time()-t1)

# FD
# include("model_set_3.jl")
x = [copy(turbine_x);copy(turbine_y)]
AEP_orig = aep_wrapper(x)
step = 1E-6
grad = zeros(length(x))
t1 = time()
for i = 1:length(x)
    xtemp = copy(x)
    xtemp[i] += step
    AEP = aep_wrapper(xtemp)
    grad[i] = (AEP[1]-AEP_orig[1])/step
end
println("time for finite difference: ", time()-t1)

difference = abs.(grad .- Jfor')./(Jfor')
println(maximum(difference))



# println("forward: ", Jfor)
# println("finite: ", grad)

# for i = 1:nturbines
#     a = grad[i]-Jfor[i]
#     # println(a)
#     if abs(a) > 500
#         println(a)
#         println("grad: ", grad[i])
#         println("Jfor: ", Jfor[i])
#         println("index: ", i)
#         println("________")
#     end
# end
