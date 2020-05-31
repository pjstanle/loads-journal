import FlowFarm; const ff = FlowFarm

# based on https://backend.orbit.dtu.dk/ws/portalfiles/portal/146793996/Pena18_wes_3_191_2018.pdf

diam = 120.0

locdata = readdlm("inputfiles/AnholtOffshoreWindFarmLocations.txt", ' ', skipstart=1)
turbine_x = locdata[:, 1]*diam
turbine_y = locdata[:, 2]*diam

nturbines = 25
turbine_x = rand(nturbines).*2000.0.-1000.0
turbine_y = rand(nturbines).*2000.0.-1000.0
nturbines = length(turbine_x)

turbine_z = zeros(nturbines)
rotor_diameter = zeros(nturbines).+diam
hub_height = zeros(nturbines).+81.6
turbine_yaw = zeros(nturbines).+0.0
turbine_ai = zeros(nturbines).+(1.0/3.0)

generator_efficiency = zeros(nturbines).+0.944
cut_in_speed = zeros(nturbines).+3.5  # m/s
cut_out_speed = zeros(nturbines).+25.  # m/s
rated_speed = zeros(nturbines).+12.0  # m/s
rated_power = zeros(nturbines).+3.6E6  # W


# load cp data
cpdata = readdlm("inputfiles/power_curve_siemens_swp3.6-120.txt",  ',', skipstart=1)
vel_points = cpdata[:, 1]
power_points = cpdata[:, 2]
power_model = ff.PowerModelPowerPoints(vel_points, power_points)

# rotor sample points
rotor_points_y = [0.0]
rotor_points_z = [0.0]


# winddirections = deg2rad.(range(0,stop=350,length=36))
# windspeeds = zeros(36).+(9.23)
# windprobabilities = [1.3,1.1,1.3,1.1,1.0,1.3,1.7,2.2,2.1,3.3,3.5,4.1,4.5,5.0,
#                             3.6,3.3,2.8,2.6,2.8,3.7,4.7,4.3,3.6,3.5,3.1,3.6,4.0,3.6,
#                             4.2,3.8,1.8,1.6,1.6,1.4,1.2,1.3]
# windprobabilities = windprobabilities./(sum(windprobabilities))

winddirections = deg2rad.([270.0])
windspeeds = [10.0]
windprobabilities = [1.0]

air_density = 1.1716  # kg/m^3
ambient_ti = 0.1
measurementheight = ones(length(winddirections)).*hub_height[1]
ambient_tis = ones(length(winddirections)).*ambient_ti
shearexponent = 0.15
wind_shear_model = ff.PowerLawWindShear(shearexponent)
windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_tis, wind_shear_model)


wec_factor = 1.0

# alpha_hat = 0.04
# wakedeficitmodel = ff.JensenTopHat(alpha_hat)

alpha_cos = 0.1
# beta_cos = 20.0*pi/180.0
# wakedeficitmodel = ff.JensenCosine(alpha_cos, beta_cos, wec_factor)

k1 = 0.3837
k2 = 0.003678
alpha_star = 2.32
beta_star = 0.154
# wakedeficitmodel = ff.GaussYaw(0.022, 0.022, 2.32, 0.154, 1.0)
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)

wakedeflectionmodel = ff.JiminezYawDeflection(alpha_cos)
wakecombinationmodel = ff.LinearLocalVelocitySuperposition()
# LinearFreestreamSuperposition
# SumOfSquaresFreestreamSuperposition
# SumOfSquaresLocalVelocitySuperposition
# LinearLocalVelocitySuperposition

# localtimodel = ff.LocalTIModelNoLocalTI()
localtimodel = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)

model_set = ff.WindFarmModelSet(wakedeficitmodel, wakedeflectionmodel, wakecombinationmodel, localtimodel)

ct = 0.689
ct_model1 = ff.ThrustModelConstantCt(ct)
ct_model = Vector{typeof(ct_model1)}(undef, nturbines)
for i = 1:nturbines
    ct_model[i] = ct_model1
end
