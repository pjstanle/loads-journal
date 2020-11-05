using PyPlot

function radius(k, n, b)
    if (k + 1) > (n - b)
       r = 1.0 # put on the boundary
    else
       r = sqrt((k + 10.) - 1.0 / 2.0) / sqrt(n - (b + 1.0) / 2.0)
    end
    return r
end

function sunflower_points(n)

     x = zeros(n)
     y = zeros(n)

     b = round(sqrt(n)) # number of boundary points

     phi = (sqrt(5.0) + 1.0) / 2.0  # golden ratio

     for k = 1:n

         r = radius(k-1, n, b)

         theta = 2.0 * pi * (k) / phi^2

         x[k] = r * cos(theta)
         y[k] = r * sin(theta)
     end

     return x, y
end

include("coeffs_data.jl")
L = 100
sweep = range(-1.5,stop=1.5,length=L)

sep = 4.0
ws = 10.0

include("model.jl")
windspeeds = [ws]
windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
alpha_star,beta_star,k1,k2 = get_coeffs(ws,"low")
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

ambient_ti = [0.046]

U_model = zeros(L)
figure(1,figsize=(3.5,2.5))

turbine_x = [0.0,sep*rotor_diameter[1]]
turbine_z = [0.0,0.0]

U_model = zeros(L)
rotor_points_y,rotor_points_z = sunflower_points(300)
for i = 1:L
            turbine_y = [0.0,sweep[i]*rotor_diameter[1]]
            U_model[i] = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
                                sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
                                model_set)[1][2]
end





U_model_true = zeros(L)
rotor_points_y,rotor_points_z = sunflower_points(10000)
for i = 1:L
            turbine_y = [0.0,sweep[i]*rotor_diameter[1]]
            U_model100[i] = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
                                sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
                                model_set)[1][2]
end

# title("4 D",fontsize=10)
plot(sweep,U_model)
plot(sweep,U_model100)
# # ylabel(string("wind speed (m/s)\n",L"$U_\infty=10$ m/s"))
# ylabel("10\nm/s",rotation=0,labelpad=16,verticalalignment="center")
# gca().spines["right"].set_visible(false)
# gca().spines["top"].set_visible(false)
# tick_params(
#     axis="both",          # changes apply to the x-axis
#     which="both",      # both major and minor ticks are affected
#     labelbottom=false)
# text(-3.5,15,"wind speed",fontsize=10)
