
const ff=FlowFarm
using Statistics

# frac = 0.5772
frac = 0.38483
locdata = readdlm("inputfiles/horns_rev_locations.txt", ',', Float64, skipstart=1)
diam = 126.4
turbine_x = locdata[:, 1].*(diam*frac)
turbine_y = locdata[:, 2].*(diam*frac)
# nturbines = length(turbine_x)
nturbines = 40
# nturbines = 20
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

# power_model = ff.PowerModelPowerCurveCubic()

power_model1 = ff.PowerModelPowerCurveCubic()
power_model = Vector{typeof(power_model1)}(undef, nturbines)
for i = 1:nturbines
    power_model[i] = power_model1
end

# Wind Resource
# Horns rev wind farm

# coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0])
# coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13] .+ 3.0
# coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095]

coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0,360.0])
# coarse_speeds = [12.0,11.5,11.1,11.0,10.0,11.0,12.0,11.0,10.0,11.0,11.1,11.5,12.0]
coarse_speeds = [11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0,11.0]
coarse_probs = [0.19,0.09,0.04,0.03,0.02,0.05,0.15,0.05,0.02,0.03,0.04,0.09,0.2]

ndirections = 100
# nspeeds = 6
fine_dirs = range(0.0,stop=2.0*pi-2.0*pi/ndirections,length=ndirections)
fine_dirs = akima(coarse_dirs,coarse_dirs,fine_dirs)
fine_speeds = akima(coarse_dirs,coarse_speeds,fine_dirs)
fine_probs = akima(coarse_dirs,coarse_probs,fine_dirs)
fine_probs = fine_probs./sum(fine_probs)
# winddirections, windprobabilities, windspeeds = ff.setup_weibull_distribution(fine_dirs,fine_probs,fine_speeds,nspeeds)

# winddirections = deg2rad.([260.0])
# windprobabilities = [1.0]
# windspeeds = [12.0]

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

# k1 = 0.406188555910869
# k2 = 0.0
# alpha_star = 8.059490825809203
# beta_star = 0.0

# alpha_star = 4.859453751668387
# beta_star = 0.3521952853552008
# k1 = 0.18988806762879362
# k2 = 0.0012797446159086834

# first revision
# alpha_star = 2.6576819658448723
# beta_star = 0.5417156513319318
# k1 = 0.004854221902940827
# k2 = 0.01147114846194034

# second revision
alpha_star = 2.6439519657674815
beta_star = 0.4567898790372122
k1 = 0.06291015958406092
k2 = 0.006933240940328717

wec_factor = 1.0
wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
# wakedeflectionmodel = ff.JiminezYawDeflection(0.022)
wakedeflectionmodel = ff.NoYawDeflection()

model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)



boundary_vertices = zeros(4,2)
boundary_normals = zeros(4,2)

boundary_vertices[:,1] = [turbine_x[71],turbine_x[80],turbine_x[10],turbine_x[1]]
boundary_vertices[:,2] = [turbine_y[71],turbine_y[80],turbine_y[10],turbine_y[1]]
boundary_normals[:,1] = [0.0,
                            0.9926747721522186,
                            0.0,
                           -0.9926747721522186]
boundary_normals[:,2] = [-1.0,
                            0.12081720379375196,
                            1.0,
                           -0.12081720379375196]
# boundary_vertices[:,1] = [0.,
#                             6.30021755e+01,
#                             5.70848441e+01,
#                             5.91733140e+00].* (diam*frac) ./ sqrt(2.0)
# boundary_vertices[:,2] = [-6.90607735e-02,
#                            -6.90607735e-02,
#                             4.85497238e+01,
#                             4.85497238e+01].* (diam*frac) ./ sqrt(2.0)
# boundary_normals[:,1] = [0.00000000e+00,
#                             9.92735431e-01,
#                             3.27941786e-03,
#                            -9.93155559e-01]
# boundary_normals[:,2] = [-1.00000000e+00,
#                             1.20317762e-01,
#                             9.99994623e-01,
#                             1.16799127e-01]

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
tilt = deg2rad(5.0)

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

rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
sections = CCBlade.Section.(r,chord,theta,airfoils)
air_density = 1.225  # kg/m^3

# speeds = range(3.,stop=25.,length=23)
# omegas = [6.972,7.183,7.506,7.942,8.469,9.156,10.296,11.431,11.89,
#                    12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,
#                    12.1,12.1,12.1]
# pitches = 1.0.*[0.,0.,0.,0.,0.,0.,0.,0.,0.,3.823,6.602,8.668,10.45,12.055,
#                        13.536,14.92,16.226,17.473,18.699,19.941,21.177,22.347,
#                        23.469]

speeds = range(0.0,stop=25.0,length=50)
pitches = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.01, 0.1, 1.0, 2.4665620123758987, 4.250994247344594,
    5.558158359095206, 6.661448453292461, 7.644379771413811, 8.546108522076311,
    9.387734419879408, 10.182697739395135, 10.939463292236832, 11.66372831629439,
    12.361696788634076, 13.038653267820896, 13.697713414821868, 14.339164680070546,
    14.963406615582839, 15.57178445366522, 16.166746693353407, 16.751095763259475,
    17.326332536703173, 17.89285677377614, 18.450533941560188, 18.999731988022262,
    19.540167083955026, 20.072178862122602, 20.596584281875597, 21.114152896544486,
    21.625176584198414]


naz = 2
Nlocs = 50
az_arr = [pi/2,3*pi/2]
nCycles = 50

turb_samples_low = [ 9.91804332e-01,  9.08836831e-01,  8.35488750e-01,  7.81379510e-01,        7.41699401e-01,  7.09233857e-01,  6.68351320e-01,  6.01015377e-01,
               4.95201752e-01,  3.68946859e-01,  2.46299248e-01,  1.46497761e-01,        6.47326874e-02, -5.00811076e-03, -6.75343436e-02, -1.15631446e-01,
              -1.40882424e-01, -1.48096990e-01, -1.61323693e-01, -2.08218367e-01,       -2.93590724e-01, -3.94594638e-01, -4.75157285e-01, -5.10027684e-01,
              -4.96800981e-01, -4.61930581e-01, -4.31869893e-01, -4.25857755e-01,       -4.40286885e-01, -4.55918444e-01, -4.40286885e-01, -3.68141232e-01,
              -2.39481484e-01, -8.31659018e-02,  5.03035567e-02,  1.14032217e-01,        9.35909487e-02,  5.81373723e-03, -1.18036301e-01, -2.43088767e-01,
              -3.56116957e-01, -4.47501451e-01, -5.06420401e-01, -5.30468952e-01,       -5.35278662e-01, -5.46100510e-01, -5.85780620e-01, -6.56723845e-01,
              -7.38488919e-01, -7.97407869e-01, -7.97407869e-01, -7.15642795e-01,       -5.48505365e-01, -3.03210144e-01, -1.82348139e-02,  2.88384213e-01,
               5.96205666e-01,  8.79978569e-01,  1.09761796e+00,  1.19862187e+00,        1.16615633e+00,  1.04110386e+00,  9.00419838e-01,  8.21059619e-01,
               8.48715453e-01,  9.82184911e-01,  1.15653691e+00,  1.27798209e+00,        1.27196995e+00,  1.13128593e+00,  9.06431976e-01,  6.63541610e-01,
               4.56724070e-01,  3.08825481e-01,  2.25857980e-01,  1.96999718e-01,        2.01809429e-01,  2.13833704e-01,  1.93392436e-01,  1.10424934e-01,
              -3.62712272e-02, -2.09420795e-01, -3.45295109e-01, -3.93392211e-01,       -3.56116957e-01, -2.97198006e-01, -2.85173731e-01, -3.48902391e-01,
              -4.61930581e-01, -5.73756344e-01, -6.43497142e-01, -6.65140838e-01,       -6.59128700e-01, -6.51914135e-01, -6.51914135e-01, -6.48306852e-01,
              -6.24258301e-01, -5.70149061e-01, -4.85979133e-01, -3.95797066e-01,       -3.24853840e-01, -2.91185869e-01, -3.09222282e-01, -3.71748515e-01,
              -4.70347574e-01, -5.85780620e-01, -7.00011237e-01, -7.92598159e-01,       -8.50314682e-01, -8.68351095e-01, -8.53921964e-01, -8.17849138e-01,
              -7.73359318e-01, -7.27667071e-01, -6.81974824e-01, -6.30270439e-01,       -5.67744206e-01, -4.90788843e-01, -4.10226197e-01, -3.45295109e-01,
              -3.16436847e-01, -3.30865978e-01, -3.81367935e-01, -4.43894168e-01,       -4.93193698e-01, -5.20849532e-01, -5.43695655e-01, -5.86983047e-01,
              -6.69950548e-01, -7.85383594e-01, -9.12840914e-01, -1.03188124e+00,       -1.12927787e+00, -1.20503081e+00, -1.26154491e+00, -1.30723715e+00,
              -1.35172697e+00, -1.40102650e+00, -1.45152846e+00, -1.49361342e+00,       -1.50684013e+00, -1.46475516e+00, -1.34571483e+00, -1.12807545e+00,
              -8.22658848e-01, -4.53513589e-01, -8.31659018e-02,  2.04214284e-01,        3.35278887e-01,  2.94396350e-01,  1.48902616e-01,  1.66355852e-02,
               2.02428679e-02,  2.37882255e-01,  6.56327044e-01,  1.16134662e+00,        1.56656470e+00,  1.73490456e+00,  1.66636619e+00,  1.47998992e+00,
               1.28760151e+00,  1.13609564e+00,  1.02426988e+00,  9.34087809e-01,        8.52322736e-01,  7.69355234e-01,  6.89995016e-01,  6.29873638e-01,
               6.11837225e-01,  6.46707624e-01,  7.28472697e-01,  8.43905743e-01,        9.83387339e-01,  1.14090535e+00,  1.29962579e+00,  1.44030981e+00,
               1.52928945e+00,  1.53650401e+00,  1.44872680e+00,  1.28279180e+00,        1.08318883e+00,  9.10039258e-01,  8.29476612e-01,  8.89597990e-01,
               1.11565437e+00,  1.47758506e+00,  1.87438616e+00,  2.18220761e+00,        2.32649892e+00,  2.33852319e+00,  2.26637754e+00,  2.17018334e+00,
               2.00304591e+00,  1.74572641e+00,  1.43069039e+00,  1.14932234e+00,        9.97816470e-01,  1.01585288e+00,  1.15653691e+00,  1.30323307e+00,
               1.32848405e+00,  1.16014419e+00,  8.25869329e-01,  4.23056099e-01,        1.00805514e-01, -6.03197783e-02, -4.10809374e-02,  1.08020079e-01,
               2.91991495e-01,  4.14639106e-01,  4.24258526e-01,  3.46100735e-01,        2.55918669e-01,  2.27060407e-01,  2.83574502e-01,  3.86983272e-01,
               4.65141063e-01,  4.62736208e-01,  3.68946859e-01,  2.28262835e-01,        9.96030865e-02,  2.38501505e-02,  1.78380128e-02,  8.51739558e-02,
               2.25857980e-01,  4.37485229e-01,  6.99614436e-01,  9.74970346e-01,        1.21184857e+00,  1.35854474e+00,  1.38620057e+00,  1.30563792e+00,
               1.15773933e+00,  9.82184911e-01,  8.33083895e-01,  7.46509111e-01,        7.62140669e-01,  9.02824693e-01,  1.14691749e+00,  1.42588068e+00,
               1.66275891e+00,  1.83711090e+00,  2.00184348e+00,  2.18220761e+00,        2.33852319e+00,  2.33852319e+00,  2.13411051e+00,  1.77217981e+00,
               1.37056901e+00,  1.05312814e+00,  8.67954294e-01,  8.15047481e-01,        8.57132446e-01,  9.38897519e-01,  1.00984075e+00,  1.03869901e+00,
               1.00743589e+00,  9.10039258e-01,  7.51318821e-01,  5.64942550e-01,        4.18246388e-01,  3.78566279e-01,  4.71153201e-01,  6.68351320e-01,
               8.59537301e-01,  9.36492664e-01,  8.31881467e-01,  5.57727985e-01,        1.96999718e-01, -1.51704272e-01, -4.16238334e-01, -5.67744206e-01,
              -6.09829171e-01, -5.70149061e-01, -4.75157285e-01, -3.58521812e-01,       -2.39481484e-01, -1.28858149e-01, -1.94372414e-02,  9.59958038e-02,
               2.21048269e-01,  3.32874032e-01,  4.05019685e-01,  4.21853671e-01,        3.89388127e-01,  3.22052184e-01,  2.39084683e-01,  1.60926892e-01,
               1.05615224e-01,  8.87812385e-02,  1.17639500e-01,  1.87380298e-01,        2.82372075e-01,  3.78566279e-01,  4.36282802e-01,  4.35080374e-01,
               3.86983272e-01,  3.20849756e-01,  2.65538089e-01,  2.27060407e-01,        2.01809429e-01,  1.78963305e-01,  1.46497761e-01,  8.99836660e-02,
              -3.80568321e-03, -1.28858149e-01, -2.63530035e-01, -3.78963080e-01,       -4.41489313e-01, -4.37882030e-01, -3.74153370e-01, -2.76756738e-01,
              -1.79360106e-01, -1.13226591e-01, -8.79756120e-02, -8.67731845e-02,       -8.43683294e-02, -6.63319160e-02, -4.22833650e-02, -4.34857925e-02,
              -9.87974600e-02, -2.14230505e-01, -3.77760653e-01, -5.42493228e-01,       -6.80772396e-01, -7.74561746e-01, -8.32278268e-01, -8.77970515e-01,
              -9.39294321e-01, -1.03909581e+00, -1.18218469e+00, -1.35172697e+00,       -1.51886440e+00, -1.65113143e+00, -1.72327709e+00, -1.72327709e+00,
              -1.65473872e+00, -1.54411538e+00, -1.43950418e+00, -1.38178766e+00,       -1.39862165e+00, -1.49000614e+00, -1.63670230e+00, -1.80383973e+00,
              -1.95775046e+00, -2.06957622e+00, -2.12609032e+00, -2.12128061e+00,       -2.05995680e+00, -1.95414318e+00, -1.81947129e+00, -1.67397756e+00,
              -1.53329353e+00, -1.41906291e+00, -1.33729784e+00, -1.27837889e+00,       -1.22186480e+00, -1.12927787e+00, -9.54925879e-01, -6.57926273e-01,
              -2.29862063e-01,  2.75157509e-01,  7.30877553e-01,  9.91804332e-01,        9.85792194e-01,  7.69355234e-01,  4.80772621e-01,  2.31870117e-01,
               6.23278323e-02, -7.71537640e-02, -2.34671774e-01, -4.25857755e-01,       -6.33877722e-01, -8.29873413e-01, -9.87391423e-01, -1.09080019e+00,
              -1.14009972e+00, -1.14851672e+00, -1.14250458e+00, -1.15573128e+00,       -1.21705509e+00, -1.33128570e+00, -1.48519643e+00, -1.63670230e+00,
              -1.75814749e+00, -1.83149557e+00, -1.85915140e+00, -1.85313926e+00,       -1.82548343e+00, -1.78219604e+00, -1.72568194e+00, -1.65353629e+00,
              -1.56575908e+00, -1.47076730e+00, -1.38058523e+00, -1.30362987e+00,       -1.24471092e+00, -1.20142353e+00, -1.17016041e+00, -1.14490943e+00,
              -1.11965845e+00, -1.09080019e+00, -1.06554921e+00, -1.06073950e+00,       -1.09200262e+00, -1.14370700e+00, -1.17737498e+00, -1.14130215e+00,
              -1.01865454e+00, -8.46707399e-01, -6.95201527e-01, -6.35080149e-01,       -7.00011237e-01, -8.58731674e-01, -1.05592979e+00, -1.23028179e+00,
              -1.34451241e+00, -1.39381194e+00, -1.39982407e+00, -1.39982407e+00,       -1.43108719e+00, -1.51405469e+00, -1.64752415e+00, -1.80985187e+00,
              -1.96977473e+00, -2.09362477e+00, -2.16456800e+00, -2.18380684e+00,       -2.16456800e+00, -2.12609032e+00, -2.08881506e+00, -2.06596894e+00,
              -2.06957622e+00, -2.10564905e+00, -2.17178256e+00, -2.25955978e+00,       -2.35695641e+00, -2.44593605e+00, -2.51086713e+00, -2.53010598e+00,
              -2.48681858e+00, -2.37138554e+00, -2.17058014e+00, -1.89161694e+00,       -1.52728139e+00, -1.08478805e+00, -6.01412178e-01, -1.32465432e-01,
               2.78764792e-01,  6.01015377e-01,  8.17452336e-01,  9.59338788e-01,        1.08078397e+00,  1.18659760e+00,  1.18299031e+00,  9.80982484e-01,
               6.20254218e-01,  2.36679828e-01, -1.82348139e-02, -1.03607170e-01,       -4.46882201e-02,  9.35909487e-02,  2.33072545e-01,  3.11230336e-01,
               3.14837619e-01,  2.81169647e-01,  2.77562365e-01,  3.49708018e-01,        5.04821172e-01,  7.09233857e-01,  9.25670816e-01,  1.12767865e+00,
               1.30443550e+00,  1.42948796e+00,  1.47998992e+00,  1.42708311e+00,        1.26716024e+00,  1.03268687e+00,  8.03023206e-01,  6.65946465e-01,
               6.68351320e-01,  7.78974655e-01,  8.94407700e-01,  9.07634403e-01,        7.69355234e-01,  5.09630883e-01,  2.06619139e-01, -6.51294885e-02,
              -2.34671774e-01, -2.87578586e-01, -2.28659636e-01, -8.55707569e-02,        9.47933763e-02,  2.67942944e-01,  4.11031823e-01,  5.24060013e-01,
               6.19051790e-01,  6.98412009e-01,  7.53723676e-01,  7.75367372e-01,        7.60938241e-01,  7.27270270e-01,  6.92399871e-01,  6.63541610e-01,
               6.23861500e-01,  5.62537695e-01,  5.01213890e-01,  4.87987187e-01,        5.66144978e-01,  7.21258132e-01,  8.89597990e-01,  1.00382861e+00,
               1.02186502e+00,  9.58136360e-01,  8.60739728e-01,  7.92201358e-01,        7.97011068e-01,  8.76371287e-01,  9.78577629e-01,  1.04471114e+00,
               1.03629415e+00,  9.46112085e-01,  7.94606213e-01,  6.15444507e-01,        4.43497367e-01,  2.90789068e-01,  1.47700189e-01, -6.21053832e-03,
              -1.76955251e-01, -3.42890254e-01, -4.67942719e-01, -5.22051959e-01,       -4.99205836e-01, -4.31869893e-01, -3.71748515e-01, -3.63331522e-01,
              -4.23452900e-01, -5.24456814e-01, -6.17043736e-01, -6.57926273e-01,       -6.31472867e-01, -5.47302938e-01, -4.33072320e-01, -3.14031992e-01,
              -2.01003802e-01, -9.03804671e-02,  3.70768536e-02,  2.04214284e-01,        3.94197837e-01,  5.82978963e-01,  7.35687263e-01,  8.37893605e-01,
               9.06431976e-01,  9.70160636e-01,  1.05553299e+00,  1.15533448e+00,        1.23469470e+00,  1.23349227e+00,  1.10964223e+00,  8.69156721e-01,
               5.78169253e-01,  3.19647329e-01,  1.51307471e-01,  9.47933763e-02,        1.16437072e-01,  1.64534174e-01,  1.87380298e-01,  1.62129319e-01,
               8.99836660e-02,  2.20645456e-03, -6.63319160e-02, -8.19634742e-02,       -3.38663721e-02,  7.67569629e-02,  2.36679828e-01,  4.23056099e-01,
               6.07027514e-01,  7.52521249e-01,  8.18654764e-01,  8.06630488e-01,        7.51318821e-01,  7.12841139e-01,  7.35687263e-01,  8.23464474e-01,
               9.47314512e-01,  1.06875970e+00,  1.17216847e+00,  1.27798209e+00,        1.41024912e+00,  1.56776713e+00,  1.70604630e+00,  1.75775068e+00,
               1.66396133e+00,  1.42948796e+00,  1.12046408e+00,  8.40298460e-01,        6.68351320e-01,  6.32278493e-01,  7.04424146e-01,  8.34286322e-01]

               turb_samples_high = [ 3.41739490e+00,  3.65949079e+00,  3.79506449e+00,  3.62075545e+00,        3.20435052e+00,  2.75889408e+00,  2.36185682e+00,  1.94545190e+00,
                       1.56778231e+00,  1.43220861e+00,  1.53873080e+00,  1.72272368e+00,        1.80987820e+00,  1.82924587e+00,  1.96481957e+00,  2.12944477e+00,
                       1.99387107e+00,  1.48062779e+00,  9.48016835e-01,  7.34972453e-01,        8.99597657e-01,  1.19011272e+00,  1.32568642e+00,  1.22884807e+00,
                       9.96436012e-01,  7.25288617e-01,  4.44457386e-01,  1.82993826e-01,        8.68478651e-03, -9.99049034e-04,  1.05523142e-01,  2.60464511e-01,
                       3.28251360e-01,  2.89516017e-01,  2.12045333e-01,  1.34574649e-01,       -3.00505557e-02, -3.10881787e-01, -6.01396853e-01, -7.36970551e-01,
                      -6.98235208e-01, -5.62661511e-01, -4.27087813e-01, -3.98036306e-01,       -5.23926169e-01, -7.56338222e-01, -9.69382604e-01, -1.08558863e+00,
                      -1.12432397e+00, -1.14369164e+00, -1.20857334e+00, -1.28313888e+00,       -1.30831685e+00, -1.22794101e+00, -1.05653712e+00, -8.43492742e-01,
                      -6.88551373e-01, -6.01396853e-01, -5.43293840e-01, -4.17403978e-01,       -2.23727267e-01, -1.06828846e-02,  1.53942320e-01,  3.28251360e-01,
                       5.80031084e-01,  8.12443137e-01,  8.80229986e-01,  7.83391630e-01,        6.86553275e-01,  7.34972453e-01,  8.51178479e-01,  8.99597657e-01,
                       9.18965328e-01,  9.86752177e-01,  1.09327437e+00,  1.11264204e+00,        9.48016835e-01,  6.86553275e-01,  4.25089715e-01,  2.60464511e-01,
                       1.73309991e-01,  1.44258484e-01,  1.63626155e-01,  2.02361497e-01,        2.41096840e-01,  2.79832182e-01,  2.50780675e-01,  1.05523142e-01,
                      -1.84991924e-01, -5.14242333e-01, -7.36970551e-01, -7.75705893e-01,       -6.49816031e-01, -4.36771649e-01, -2.81830280e-01, -2.81830280e-01,
                      -4.85190826e-01, -8.24125071e-01, -1.15337548e+00, -1.39353460e+00,       -1.53588698e+00, -1.64047241e+00, -1.72956369e+00, -1.79444539e+00,
                      -1.83995942e+00, -1.89999920e+00, -1.99683756e+00, -2.11788550e+00,       -2.20891355e+00, -2.21859739e+00, -2.13531640e+00, -1.99199564e+00,
                      -1.82640205e+00, -1.64918786e+00, -1.45551115e+00, -1.24053000e+00,       -1.03716945e+00, -8.82228084e-01, -8.04757399e-01, -7.75705893e-01,
                      -7.66022057e-01, -7.46654386e-01, -7.56338222e-01, -8.62860413e-01,       -1.05653712e+00, -1.25215060e+00, -1.33349482e+00, -1.27151827e+00,
                      -1.10495630e+00, -9.01595755e-01, -7.46654386e-01, -6.01396853e-01,       -3.39933293e-01,  1.53942320e-01,  7.93075466e-01,  1.28695108e+00,
                       1.35473793e+00,  1.03517135e+00,  7.64023959e-01,  9.09281492e-01,        1.36442176e+00,  1.77114286e+00,  1.86798121e+00,  1.60651765e+00,
                       1.15137738e+00,  6.76869439e-01,  2.12045333e-01, -2.33411102e-01,       -5.62661511e-01, -7.07919044e-01, -6.78867537e-01, -5.14242333e-01,
                      -3.20565622e-01, -2.04359596e-01, -1.65624253e-01, -1.75308089e-01,       -2.33411102e-01, -3.39933293e-01, -4.56139320e-01, -5.52977675e-01,
                      -6.30448360e-01, -6.78867537e-01, -7.07919044e-01, -7.07919044e-01,       -6.69183702e-01, -5.91713017e-01, -5.04558497e-01, -4.65823155e-01,
                      -5.04558497e-01, -6.11080689e-01, -7.07919044e-01, -7.66022057e-01,       -8.14441235e-01, -9.20963426e-01, -1.06622096e+00, -1.13400781e+00,
                      -1.02748562e+00, -8.33808906e-01, -7.85389728e-01, -1.02748562e+00,       -1.46035307e+00, -1.85545356e+00, -2.07043471e+00, -2.09270753e+00,
                      -1.95132353e+00, -1.68792320e+00, -1.38288238e+00, -1.16983800e+00,       -1.12432397e+00, -1.19404759e+00, -1.26183444e+00, -1.25699252e+00,
                      -1.17371153e+00, -1.05653712e+00, -9.69382604e-01, -9.30647262e-01,       -8.82228084e-01, -7.66022057e-01, -6.01396853e-01, -4.94874662e-01,
                      -4.94874662e-01, -5.91713017e-01, -7.66022057e-01, -9.88750275e-01,       -1.17467992e+00, -1.27539181e+00, -1.24343515e+00, -1.06622096e+00,
                      -7.85389728e-01, -5.04558497e-01, -3.10881787e-01, -1.94675760e-01,       -1.36572747e-01, -1.46256582e-01, -2.43094938e-01, -3.68984800e-01,
                      -4.27087813e-01, -2.91514115e-01,  4.74201287e-02,  4.15405879e-01,        6.09082590e-01,  5.31611906e-01,  2.79832182e-01,  8.61554709e-02,
                       1.15206978e-01,  4.63825057e-01,  1.05453903e+00,  1.77114286e+00,        2.37154066e+00,  2.57490121e+00,  2.36185682e+00,  2.16818011e+00,
                       2.30375381e+00,  2.59426888e+00,  2.72015874e+00,  2.65237189e+00,        2.42964367e+00,  2.08102559e+00,  1.74209135e+00,  1.56778231e+00,
                       1.47094395e+00,  1.27726724e+00,  9.86752177e-01,  8.02759301e-01,        8.51178479e-01,  1.02548752e+00,  1.11264204e+00,  1.01580368e+00,
                       8.12443137e-01,  6.76869439e-01,  5.99398755e-01,  4.83192728e-01,        2.89516017e-01,  7.64716353e-02, -7.84697334e-02, -1.84991924e-01,
                      -2.72146444e-01, -3.49617129e-01, -3.88352471e-01, -3.98036306e-01,       -3.78668635e-01, -2.72146444e-01, -4.94182268e-02,  3.08883688e-01,
                       7.05920946e-01,  1.01580368e+00,  1.09327437e+00,  8.70546150e-01,        4.34773551e-01, -3.00505557e-02, -3.20565622e-01, -3.39933293e-01,
                      -1.65624253e-01,  5.71039642e-02,  2.41096840e-01,  4.05722044e-01,        5.12244235e-01,  5.02560399e-01,  3.28251360e-01,  6.67877998e-02,
                      -1.65624253e-01, -3.20565622e-01, -4.17403978e-01, -5.43293840e-01,       -7.36970551e-01, -8.82228084e-01, -8.91911919e-01, -8.04757399e-01,
                      -7.46654386e-01, -7.85389728e-01, -8.91911919e-01, -9.88750275e-01,       -1.03716945e+00, -1.04685329e+00, -1.02748562e+00, -9.79066439e-01,
                      -9.40331097e-01, -9.50014933e-01, -1.05653712e+00, -1.24537192e+00,       -1.45066923e+00, -1.59883191e+00, -1.63272534e+00, -1.53395022e+00,
                      -1.32187422e+00, -1.04685329e+00, -7.56338222e-01, -5.14242333e-01,       -3.59300964e-01, -2.81830280e-01, -2.14043431e-01, -1.46256582e-01,
                      -7.84697334e-02, -3.00505557e-02,  2.80524576e-02,  1.34574649e-01,        2.60464511e-01,  3.57302866e-01,  3.66986702e-01,  2.12045333e-01,
                      -1.07521240e-01, -4.46455484e-01, -5.82029182e-01, -4.07720142e-01,       -5.91020623e-02,  2.99199853e-01,  6.18766426e-01,  8.99597657e-01,
                       1.06422286e+00,  1.02548752e+00,  8.89913821e-01,  9.38332999e-01,        1.28695108e+00,  1.75177519e+00,  2.04229025e+00,  2.05197409e+00,
                       1.91640039e+00,  1.76145902e+00,  1.59683382e+00,  1.42252478e+00,        1.18042889e+00,  8.12443137e-01,  3.47619031e-01, -5.91020623e-02,
                      -2.14043431e-01, -5.91020623e-02,  2.79832182e-01,  4.73508893e-01,        3.08883688e-01, -2.04359596e-01, -7.46654386e-01, -1.00811795e+00,
                      -8.82228084e-01, -4.85190826e-01, -4.94182268e-02,  1.92677662e-01,        1.44258484e-01, -5.91020623e-02, -1.94675760e-01, -1.84991924e-01,
                      -1.07521240e-01, -8.81535690e-02, -1.55940418e-01, -2.52778773e-01,       -2.33411102e-01, -4.94182268e-02,  2.79832182e-01,  6.09082590e-01,
                       7.73707795e-01,  7.64023959e-01,  7.44656288e-01,  8.70546150e-01,        1.15137738e+00,  1.39347327e+00,  1.39347327e+00,  1.18042889e+00,
                       8.80229986e-01,  6.47817933e-01,  4.63825057e-01,  3.28251360e-01,        2.31413004e-01,  1.53942320e-01,  9.58393064e-02,  3.77362932e-02,
                       6.67877998e-02,  2.02361497e-01,  4.63825057e-01,  7.64023959e-01,        1.02548752e+00,  1.16106122e+00,  1.15137738e+00,  1.00611985e+00,
                       8.31810808e-01,  6.96237110e-01,  5.89714919e-01,  4.92876564e-01,        4.44457386e-01,  4.92876564e-01,  6.28450262e-01,  7.05920946e-01,
                       6.38134097e-01,  5.12244235e-01,  4.63825057e-01,  5.02560399e-01,        5.21928071e-01,  3.86354373e-01,  8.61554709e-02, -2.62462609e-01,
                      -5.43293840e-01, -6.59499866e-01, -6.01396853e-01, -4.75506991e-01,       -3.68984800e-01, -2.91514115e-01, -2.14043431e-01, -1.17205076e-01,
                      -4.94182268e-02, -1.17205076e-01, -3.30249458e-01, -5.33610004e-01,       -5.14242333e-01, -1.94675760e-01,  2.31413004e-01,  4.34773551e-01,
                       2.70148346e-01, -1.36572747e-01, -4.94874662e-01, -6.69183702e-01,       -6.98235208e-01, -7.27286715e-01, -8.43492742e-01, -1.03716945e+00,
                      -1.22213071e+00, -1.26280282e+00, -1.11464014e+00, -8.24125071e-01,       -5.52977675e-01, -4.17403978e-01, -4.46455484e-01, -5.23926169e-01,
                      -5.33610004e-01, -4.85190826e-01, -4.17403978e-01, -3.68984800e-01,       -3.10881787e-01, -2.72146444e-01, -2.72146444e-01, -3.68984800e-01,
                      -5.82029182e-01, -8.43492742e-01, -1.07590479e+00, -1.19307920e+00,       -1.18339537e+00, -1.09527247e+00, -9.88750275e-01, -8.72544248e-01,
                      -7.36970551e-01, -6.01396853e-01, -5.82029182e-01, -7.07919044e-01,       -8.91911919e-01, -1.01780178e+00, -1.01780178e+00, -9.11279590e-01,
                      -7.36970551e-01, -5.62661511e-01, -4.65823155e-01, -4.36771649e-01,       -4.36771649e-01, -3.59300964e-01, -8.81535690e-02,  4.15405879e-01,
                       9.48016835e-01,  1.12232587e+00,  8.80229986e-01,  5.02560399e-01,        2.02361497e-01,  2.80524576e-02, -9.78374045e-02, -2.23727267e-01,
                      -3.49617129e-01, -4.36771649e-01, -3.98036306e-01, -1.55940418e-01,        2.41096840e-01,  6.28450262e-01,  8.99597657e-01,  1.07390670e+00,
                       1.22884807e+00,  1.33537026e+00,  1.21916423e+00,  9.09281492e-01,        6.47817933e-01,  7.05920946e-01,  1.03517135e+00,  1.25789957e+00,
                       1.10295820e+00,  6.57501768e-01,  2.60464511e-01,  1.44258484e-01,        3.28251360e-01,  6.28450262e-01,  8.12443137e-01,  8.22126972e-01,
                       7.34972453e-01,  6.09082590e-01,  4.15405879e-01,  1.63626155e-01,       -6.87858979e-02, -2.04359596e-01, -2.23727267e-01, -7.84697334e-02,
                       2.89516017e-01,  8.31810808e-01,  1.25789957e+00,  1.16106122e+00,        5.89714919e-01, -3.97343912e-02, -3.39933293e-01, -3.39933293e-01,
                      -2.04359596e-01,  2.80524576e-02,  4.05722044e-01,  8.12443137e-01,        1.07390670e+00,  1.17074505e+00,  1.17074505e+00,  1.14169355e+00,
                       1.11264204e+00,  1.05453903e+00,  8.60862315e-01,  5.89714919e-01,        3.86354373e-01,  3.86354373e-01,  5.60663413e-01,  8.51178479e-01,
                       1.14169355e+00,  1.38378943e+00,  1.54841464e+00,  1.64525299e+00,        1.63556916e+00,  1.55809847e+00,  1.41284094e+00,  1.19979656e+00,
                       9.57700670e-01,  7.34972453e-01,  5.41295742e-01,  3.76670537e-01,        2.89516017e-01,  3.47619031e-01,  4.92876564e-01,  5.89714919e-01,
                       5.12244235e-01,  2.70148346e-01, -7.84697334e-02, -4.65823155e-01,       -8.14441235e-01, -1.03716945e+00, -1.09527247e+00, -1.02748562e+00,
                      -8.53176577e-01, -6.11080689e-01, -3.59300964e-01, -1.84991924e-01,       -1.07521240e-01, -9.78374045e-02, -8.81535690e-02, -7.84697334e-02,
                      -7.84697334e-02, -8.81535690e-02, -7.84697334e-02, -3.97343912e-02,       -1.06828846e-02, -3.97343912e-02, -1.46256582e-01, -3.10881787e-01,
                      -4.65823155e-01, -5.62661511e-01, -5.82029182e-01, -5.62661511e-01,       -5.52977675e-01, -6.11080689e-01, -7.07919044e-01, -8.43492742e-01,
                      -9.50014933e-01, -9.98434110e-01, -9.69382604e-01, -9.11279590e-01,       -9.01595755e-01, -9.69382604e-01, -1.11464014e+00, -1.27539181e+00,
                      -1.39062945e+00, -1.44389055e+00, -1.48068912e+00, -1.55331789e+00,       -1.67436583e+00, -1.80316084e+00, -1.88644183e+00, -1.90290435e+00]


nCycles = 50

# ntime = 5.0*nCycles
turb_samples = [-2.4167782740354533, 1.9186569844046706, -0.12461240205000693, -1.876252266473231, 1.311276337746329, 0.08434387769762368,
            -0.7333201347312834, -0.23684083170839468, 1.160783547678078, 1.6612279624993922, 0.08999354910131663, -2.143731507179793,
            -0.6261443188519292, 3.532991874732216, 0.29839963788881585, 1.4242357982520542, 0.45712307056950696, 0.013320177626415434,
            -1.294253446643497, -1.742421118811144, -0.7794135049099526, -1.6211963554967606, 0.6836707993233822, 0.25201530861592636,
            -0.06882503295997454, -0.4106793654743268, -0.65119579179511, 0.47865108312110793, 0.36339428830285686, -0.8244197230695441,
            -0.2674728183443444, -0.15050620722874625, -1.416215870429576, 1.1850353968039131, 0.04825552793860067, 0.5138078835178227,
             -0.04867058461720984, -0.5592111652228714, 0.585659992369232, -1.5093320964235764, -0.47094905796700376, -0.8424563427784184,
             -0.67525039265928, -1.5741912158480484, 0.2708878676277974, -0.43342592675288244, 1.0626190923507177, 0.9529261367224863,
             1.2714465846805327, 0.7396156529772956, -1.1300210597993574, 0.6576320404912005, -0.08702221176857615, 0.5451832054591716,
             -1.2184814910624246, 1.5810483192982299, -0.46334258680520835, -0.5853446923515632, 0.5538497307056427, 0.3942603328606214,
              -1.1053432268822816, 0.3300014699028309, 2.0697114267595804, 0.41601521744093223, -1.1590820717840027, -0.2845569546843487,
               1.3665229753528791, 1.8096827731675704, 0.6418911542590071, 1.1133534282572644, 1.0141969452625146, -0.1937979544469377,
               0.963516656298481, 0.8380964742559501, -0.16792623660695485, -0.22679995934133604, 0.8942569232568871, -0.8963132116351336,
                0.21051266515826442, -1.3469272146475781, -0.3458293717595495, 0.8414321126717208, -0.3872607046934217, 0.1267319240379616,
                -1.0268264990593021, -0.5207247224303075, 0.14091546503077407, 0.7078198712900953, -0.32100841443185024, -0.7119777385224016,
                 -0.9499525467819704, 0.7944788465159335, 0.010128243338611722, 0.19245567568428923, -0.9038895710452796, 0.1823337689823329,
                 -0.537682293567395, 0.3468774807475689, -1.0082179146017067, -0.027149157863159676]

pitch_func = Akima(speeds,pitches)
turbulence_func = ff.GaussianTI
