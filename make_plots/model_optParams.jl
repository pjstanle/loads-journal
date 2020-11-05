const ff=FlowFarm

diam = 126.4
nturbines = 1
turbine_x = [0.0]
turbine_y = [0.0]
turbine_z = zeros(nturbines)

# Turbine Definition
rotor_diameter = zeros(nturbines) .+ diam
hub_height = zeros(nturbines) .+ 90.0
cut_in_speed = zeros(nturbines) .+ 3.0
cut_out_speed = zeros(nturbines) .+ 25.0
rated_speed = zeros(nturbines) .+ 11.4
rated_power = zeros(nturbines) .+ 5e6
generator_efficiency = zeros(nturbines) .+ 0.944
turbine_ai = zeros(nturbines) .+ 1.0/3.0
turbine_yaw = zeros(nturbines)

ctdata = readdlm("inputfiles/NREL5MWCPCT.txt",  ',', skipstart=1)
velpoints = ctdata[:,1]
ctpoints = ctdata[:,3]

# initialize thurst model
ct_model1 = ff.ThrustModelCtPoints(velpoints, ctpoints)
ct_model = Vector{typeof(ct_model1)}(undef, nturbines)
for i = 1:nturbines
    ct_model[i] = ct_model1
end

power_model = ff.PowerModelPowerCurveCubic()

winddirections = deg2rad.([270.0])
windprobabilities = [1.0]
windspeeds = [wind_speed]

nbins = length(winddirections)
ambient_ti = ones(nbins) .* 0.08
measurementheight = ones(nbins) .* hub_height[1]
shearexponent = 0.15
air_density = 1.225  # kg/m^3
wind_shear_model = ff.PowerLawWindShear(shearexponent)
windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)

# rotor sample points
rotor_points_y = [-0.69,-0.69,0.69,0.69]
rotor_points_z = [-0.69,0.69,-0.69,0.69]


wakecombinationmodel = ff.LinearLocalVelocitySuperposition()

k1 = 0.3837
k2 = 0.003678
alpha_star = 2.32
beta_star = 0.154
wec_factor = 1.0
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
wakedeflectionmodel = ff.JiminezYawDeflection(0.022)

model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

turbine_inflow_velcities = [windspeeds[1]]
turbine_ct = ff.calculate_ct(turbine_inflow_velcities[1],ct_model[1])
# turbine_ct = ff.calculate_ct(10.0,ct_model[1])
sorted_turbine_index = [1]
