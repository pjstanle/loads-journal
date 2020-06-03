const ff=FlowFarm

frac = 0.75
locdata = readdlm("inputfiles/horns_rev_locations.txt", ',', Float64, skipstart=1)
diam = 126.4
turbine_x = locdata[:, 1].*(diam*frac)
turbine_y = locdata[:, 2].*(diam*frac)
nturbines = length(turbine_x)
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

# Wind Resource
# Horns rev wind farm

coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0])
coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13]
coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095]

ndirections = 36
nspeeds = 6
fine_dirs = range(0.0,stop=2.0*pi-2.0*pi/ndirections,length=ndirections)
fine_dirs = akima(coarse_dirs,coarse_dirs,fine_dirs)
fine_speeds = akima(coarse_dirs,coarse_speeds,fine_dirs)
fine_probs = akima(coarse_dirs,coarse_probs,fine_dirs)
fine_probs = fine_probs./sum(fine_probs)
# winddirections, windprobabilities, windspeeds = ff.setup_weibull_distribution(fine_dirs,fine_probs,fine_speeds,nspeeds)

# winddirections = deg2rad.([270.0])
# windprobabilities = [1.0]
# windspeeds = [11.4]

winddirections = fine_dirs
windprobabilities = fine_probs
windspeeds = fine_speeds

nbins = length(winddirections)
ambient_ti = ones(nbins) .* 0.046
measurementheight = ones(nbins) .* hub_height[1]
shearexponent = 0.15
air_density = 1.225  # kg/m^3
wind_shear_model = ff.PowerLawWindShear(shearexponent)
windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)

# rotor sample points
rotor_points_y = [-0.69,-0.69,0.69,0.69]
rotor_points_z = [-0.69,0.69,-0.69,0.69]


wakecombinationmodel = ff.LinearLocalVelocitySuperposition()


#low turb
# ky = 0.015
# kz = 0.015
# alpha_star = 5.0
# beta_star = 0.5

# k1 = 0.3837
# k2 = 0.003678
# alpha_star = 2.32
# beta_star = 0.154
k1 = 0.406188555910869
k2 = 0.0
alpha_star = 8.059490825809203
beta_star = 0.0
wec_factor = 1.0
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
# wakedeflectionmodel = ff.JiminezYawDeflection(0.022)
wakedeflectionmodel = ff.NoYawDeflection()

model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)



boundary_vertices = zeros(4,2)
boundary_normals = zeros(4,2)

boundary_vertices[:,1] = [0.,
                            6.30021755e+01,
                            5.70848441e+01,
                            5.91733140e+00].* (diam*frac)
boundary_vertices[:,2] = [-6.90607735e-02,
                           -6.90607735e-02,
                            4.85497238e+01,
                            4.85497238e+01].* (diam*frac)
boundary_normals[:,1] = [0.00000000e+00,
                            9.92735431e-01,
                            3.27941786e-03,
                           -9.93155559e-01]
boundary_normals[:,2] = [-1.00000000e+00,
                            1.20317762e-01,
                            9.99994623e-01,
                            1.16799127e-01]

# boundary_vertices = zeros(9,2)
# boundary_normals = zeros(9,2)
#
# boundary_vertices[:,1] = [3.55271368e-15,
#                             6.30021755e+01,
#                             6.13197970e+01,
#                             5.70848441e+01,
#                             3.60261059e+01,
#                             1.50253807e+01,
#                             5.91733140e+00,
#                             5.10514866e+00,
#                             3.42277012e+00].* diam
# boundary_vertices[:,2] = [-6.90607735e-02,
#                            -6.90607735e-02,
#                             1.38121547e+01,
#                             4.85497238e+01,
#                             4.86187845e+01,
#                             4.86187845e+01,
#                             4.85497238e+01,
#                             4.16436464e+01,
#                             2.76933702e+01].* diam
# boundary_normals[:,1] = [0.00000000e+00,
#                             9.92735431e-01,
#                             9.92650465e-01,
#                             3.27941786e-03,
#                             3.38342000e-16,
#                            -3.29758618e-03,
#                            -9.93155559e-01,
#                            -9.92806407e-01,
#                            -9.92485610e-01]
# boundary_normals[:,2] = [-1.00000000e+00,
#                             1.20317762e-01,
#                             1.21016756e-01,
#                             9.99994623e-01,
#                             1.00000000e+00,
#                             9.99994563e-01,
#                            -1.16799127e-01,
#                            -1.19730689e-01,
#                            -1.22361406e-01]







#CCBlade stuff

r = [2.8667, 5.6000, 8.3333, 11.7500, 15.8500, 19.9500, 24.0500,
             28.1500, 32.2500, 36.3500, 40.4500, 44.5500, 48.6500, 52.7500,
             56.1667, 58.9000, 61.6333]
chord = [3.542, 3.854, 4.167, 4.557, 4.652, 4.458, 4.249, 4.007, 3.748,
                 3.502, 3.256, 3.010, 2.764, 2.518, 2.313, 2.086, 1.419]
theta = pi/180*[13.308, 13.308, 13.308, 13.308, 11.480, 10.162, 9.011, 7.795,
                 6.544, 5.361, 4.188, 3.125, 2.319, 1.526, 0.863, 0.370, 0.106]

Rhub = 1.5
Rtip = 63.0
B = 3
pitch = 0.0
precone = 2.5*pi/180

af_path = "/Users/ningrsrch/Dropbox/Projects/waked-loads/5MW_AFFiles_julia"
path1 = af_path*"/Cylinder1.dat"
path2 = af_path*"/Cylinder2.dat"
path3 = af_path*"/DU40_A17.dat"
path4 = af_path*"/DU35_A17.dat"
path5 = af_path*"/DU30_A17.dat"
path6 = af_path*"/DU25_A17.dat"
path7 = af_path*"/DU21_A17.dat"
path8 = af_path*"/NACA64_A17.dat"

af1 = af_from_files(path1)
af2 = af_from_files(path2)
af3 = af_from_files(path3)
af4 = af_from_files(path4)
af5 = af_from_files(path5)
af6 = af_from_files(path6)
af7 = af_from_files(path7)
af8 = af_from_files(path8)

af = [af1,af2,af3,af4,af5,af6,af7,af8]

af_idx = [1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8]
airfoils = af[af_idx]

speeds = range(3.,stop=25.,length=23)
omegas = [6.972,7.183,7.506,7.942,8.469,9.156,10.296,11.431,11.89,
                   12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,
                   12.1,12.1,12.1]
pitches = 1.0.*[0.,0.,0.,0.,0.,0.,0.,0.,0.,3.823,6.602,8.668,10.45,12.055,
                       13.536,14.92,16.226,17.473,18.699,19.941,21.177,22.347,
                       23.469]
