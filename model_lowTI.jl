
const ff=FlowFarm
using GridInterpolations



# setup = true
# if setup == true
#     s = time()
#     include("model.jl")
#
#     omega_func = Akima(speeds, omegas)
#     pitch_func = Akima(speeds,pitches)
#     sep = 7.0
#     turbine_x = [0.0,sep*rotor_diameter[1]]
#     turb_index = 1
#     azimuth = pi/2.0
#
#     global local_speed_array
#     global freestream_speed_array
#
#
#     local_speed_array = range(0.0,stop=25.0,length=101)
#     freestream_speed_array = range(0.0,stop=25.0,length=100)
#     meshgrid = zeros(length(local_speed_array),length(freestream_speed_array))
#
#     np_arr = zeros(length(local_speed_array),length(freestream_speed_array))
#     tp_arr = zeros(length(local_speed_array),length(freestream_speed_array))
#     plot_speeds_local = zeros(length(local_speed_array),length(freestream_speed_array))
#     plot_speeds_free = zeros(length(local_speed_array),length(freestream_speed_array))
#
#     nr = length(r)
#
#     global nr
#     global func_arr_np
#     global func_arr_tp
#
#     func_arr_np = Array{Spline2D}(undef,nr)
#     func_arr_tp = Array{Spline2D}(undef,nr)
#
#     global fdata
#     fdata_np = zeros(nr,length(local_speed_array),length(freestream_speed_array))
#     fdata_tp = zeros(nr,length(local_speed_array),length(freestream_speed_array))
#     for k =1:nr
#                     loc_index = k
#
#                     for i = 1:length(local_speed_array)
#                         for j = 1:length(freestream_speed_array)
#                             windspeeds = [freestream_speed_array[j]]
#                             windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
#                             turbine_velocities, turbine_ct, turbine_local_ti = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
#                                                 turbine_ai, sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
#                                                 model_set, wind_farm_state_id=1)
#                             Omega_rpm = omega_func(turbine_velocities[turb_index]) #in rpm
#                             Omega = Omega_rpm*0.10471975512 #convert to rad/s
#                             pitch = deg2rad(pitch_func(turbine_velocities[turb_index]))
#                             # pitch = pi/6.0
#
#                             windspeeds = [local_speed_array[i]]
#                             windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
#                             U = ff.get_speeds(turbine_x,turbine_y,turbine_z,turb_index,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,turbine_local_ti,
#                                                 sorted_turbine_index,turbine_velocities,windresource,model_set;wind_farm_state_id=1,downwind_turbine_id=1)
#
#                             rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
#                             op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[turb_index], tilt, azimuth, air_density)
#                             out = CCBlade.solve.(Ref(rotor), sections, op)
#                             plot_speeds_local[i,j] = local_speed_array[i]
#                             plot_speeds_free[i,j] = freestream_speed_array[j]
#                             np_arr[i,j] = out[loc_index].Np
#                             tp_arr[i,j] = out[loc_index].Tp
#                         end
#                     end
#
#                     fdata_np[k,:,:] = np_arr
#                     fdata_tp[k,:,:] = tp_arr
#                     np_func = Spline2D(local_speed_array,freestream_speed_array,np_arr)
#                     tp_func = Spline2D(local_speed_array,freestream_speed_array,tp_arr)
#                     func_arr_np[k] = np_func
#                     func_arr_tp[k] = tp_func
#     end
#
#     global flap_func
#     global edge_func
#
#     function flap_func(local_speed,freestream_speed)
#                     global func_arr_np
#                     global nr
#                     arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
#                     # nr = length(func_arr_np)
#                     Np = zeros(arr_type,nr)
#                     for i=1:nr
#                                     Np[i] = func_arr_np[i](local_speed[i],freestream_speed)
#                     end
#                     return Np
#     end
#
#
#
#
#     function edge_func(local_speed,freestream_speed)
#                     global func_arr_tp
#                     global nr
#                     arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
#                     # nr = length(func_arr_tp)
#                     Tp = zeros(arr_type,nr)
#                     for i=1:nr
#                                     Tp[i] = func_arr_tp[i](local_speed[i],freestream_speed)
#                     end
#                     return Tp
#     end
#
#     function flap_func2(local_speed,freestream_speed)
#                     global nr
#                     global local_speed_array
#                     global freestream_speed_array
#                     global fdata_np
#                     arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
#                     Np = zeros(arr_type,nr)
#                     println("flap function")
#                     for i=1:nr
#                                     Np[i] = interp2d(akima, local_speed_array, freestream_speed_array, fdata_np[i,:,:], [local_speed[i]],[freestream_speed])[1]
#                     end
#                     return Np
#     end
#
#     function edge_func2(local_speed,freestream_speed)
#                     global nr
#                     global local_speed_array
#                     global freestream_speed_array
#                     global fdata_tp
#                     arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
#                     Tp = zeros(arr_type,nr)
#
#                     for i=1:nr
#                                     Tp[i] = interp2d(akima, local_speed_array, freestream_speed_array, fdata_tp[i,:,:], [local_speed[i]],[freestream_speed])[1]
#                     end
#                     return Tp
#     end

setup = false
if setup == true
    s = time()
    include("model.jl")

    omega_func = Akima(speeds, omegas)
    pitch_func = Akima(speeds,pitches)
    sep = 7.0
    turbine_x = [0.0,sep*rotor_diameter[1]]
    turb_index = 1
    azimuth = pi/2.0

    global local_speed_array
    global freestream_speed_array
    global grid

    local_speed_array = range(0.0,stop=25.0,length=101)
    freestream_speed_array = range(0.0,stop=25.0,length=100)
    grid = RectangleGrid(local_speed_array,freestream_speed_array)

    np_arr = zeros(length(local_speed_array),length(freestream_speed_array))
    tp_arr = zeros(length(local_speed_array),length(freestream_speed_array))
    plot_speeds_local = zeros(length(local_speed_array),length(freestream_speed_array))
    plot_speeds_free = zeros(length(local_speed_array),length(freestream_speed_array))

    nr = length(r)

    global nr
    global func_arr_np
    global func_arr_tp

    # func_arr_np = zeros(nr,length(meshgrid_local))
    # func_arr_tp = zeros(nr,length(meshgrid_local))

    global fdata
    fdata_np = zeros(nr,length(local_speed_array)*length(freestream_speed_array))
    fdata_tp = zeros(nr,length(local_speed_array)*length(freestream_speed_array))
    for k =1:nr
                    println(k)
                    loc_index = k

                    for i = 1:length(local_speed_array)
                        for j = 1:length(freestream_speed_array)
                            freestream_windspeeds = [freestream_speed_array[j]]
                            windresource = ff.DiscretizedWindResource(winddirections, freestream_windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
                            turbine_velocities, turbine_ct, turbine_local_ti = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
                                                turbine_ai, sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
                                                model_set, wind_farm_state_id=1)
                            Omega_rpm = omega_func(turbine_velocities[turb_index]) #in rpm
                            Omega = Omega_rpm*0.10471975512 #convert to rad/s
                            pitch = deg2rad(pitch_func(turbine_velocities[turb_index]))

                            windspeeds = [local_speed_array[i]]
                            windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
                            U = ff.get_speeds(turbine_x,turbine_y,turbine_z,turb_index,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,turbine_local_ti,
                                                sorted_turbine_index,turbine_velocities,windresource,model_set;wind_farm_state_id=1,downwind_turbine_id=1)
                            rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
                            op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[turb_index], tilt, azimuth, air_density)
                            out = CCBlade.solve.(Ref(rotor), sections, op)
                            # plot_speeds_local[i,j] = local_speed_array[i]
                            # plot_speeds_free[i,j] = freestream_speed_array[j]
                            np_arr[i,j] = out[loc_index].Np
                            tp_arr[i,j] = out[loc_index].Tp
                        end
                    end

                    fdata_np[k,:] = vec(np_arr)
                    fdata_tp[k,:] = vec(tp_arr)
                    # np_func = Spline2D(local_speed_array,freestream_speed_array,np_arr)
                    # tp_func = Spline2D(local_speed_array,freestream_speed_array,tp_arr)
                    # func_arr_np[k] = np_func
                    # func_arr_tp[k] = tp_func
    end

    global flap_func
    global edge_func

    function flap_func(local_speed,freestream_speed)
            global fdata_np
            global nr
            global grid
            arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
            Np = zeros(arr_type,nr)
            for i=1:nr
                    Np[i] = interpolate(grid,fdata_np[i,:],[local_speed[i],freestream_speed])
            end
            return Np
    end




    function edge_func(local_speed,freestream_speed)
            global fdata_np
            global nr
            global grid
            arr_type = promote_type(typeof(local_speed[1]),typeof(freestream_speed))
            Tp = zeros(arr_type,nr)
            for i=1:nr
                    Tp[i] = interpolate(grid,fdata_tp[i,:],[local_speed[i],freestream_speed])
            end
            return Tp
    end

end








frac = 0.75
locdata = readdlm("inputfiles/horns_rev_locations.txt", ',', Float64, skipstart=1)
diam = 126.4
turbine_x = locdata[:, 1].*(diam*frac)
turbine_y = locdata[:, 2].*(diam*frac)
# nturbines = length(turbine_x)
nturbines = 40
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
coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13] .+ 3.0
coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095]
ndirections = 24
nspeeds = 6
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
                            5.91733140e+00].* (diam*frac) ./ sqrt(2.0)
boundary_vertices[:,2] = [-6.90607735e-02,
                           -6.90607735e-02,
                            4.85497238e+01,
                            4.85497238e+01].* (diam*frac) ./ sqrt(2.0)
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

speeds = range(3.,stop=25.,length=23)
omegas = [6.972,7.183,7.506,7.942,8.469,9.156,10.296,11.431,11.89,
                   12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,
                   12.1,12.1,12.1]
pitches = 1.0.*[0.,0.,0.,0.,0.,0.,0.,0.,0.,3.823,6.602,8.668,10.45,12.055,
                       13.536,14.92,16.226,17.473,18.699,19.941,21.177,22.347,
                       23.469]


naz = 2
Nlocs = 50
az_arr = [pi/2,3*pi/2]
nCycles = 100

turb_samples = [-1.7375742815948083, -1.135389245536721, 0.2630500661591889, -0.3053490870899974, 0.45122718486129615, 1.3409656986041674, -0.5962815531229234,
               -0.8493480555694776, 0.6848369957940627, -0.7771766418857682, 0.8517520073813781, -1.55121204574954, 0.9905046860451119, -0.4608656968037635,
               0.7587262485526834, -1.3704467034953913, -0.831452989259264, -0.056209344897895024, -0.3826758972800919, -0.1160034988857537, 0.8934058398493318,
               0.1232662269472102, -1.4259490734091038, 0.08730632432141205, 0.220114136790133, -0.21512941735364838, -0.27219450738624384, 0.1362571602997146,
               1.9738755600156555, 0.30585725550110954, 1.1582850981501636, 0.09420837912360198, 0.9228288367395507, 0.17538955539546192, -0.40412325658363457,
               3.780851032410102, -0.26388716275783936, -0.020801732384506465, -0.1336549155203504, 0.2906739135354345, 2.1312061518785486, -0.9002466925300798,
               0.45720257310523066, -1.7505057790094762, 1.4066197735539343, -0.32494821468167184, -0.6966259079423474, -2.078912472251868, 0.9135061026036851,
               0.3910927643533145, -0.09807936478061946, -0.5608043316451404, 0.8652341644152277, 0.7319576001136265, 0.7820837886706138, 0.3427756118883895,
               -2.2205214713373165, 0.29795270622313863, 0.5265642785081389, -0.14787685963244643, 1.5619455649553944, 0.511198972073372, 0.7084023961683763,
               -0.861279192574816, 0.02378123660375562, -0.6341896458879221, -0.4807288677229144, -0.23810513426345103, 1.2816747716663464, -0.7683218197813537,
               -0.3683566101504853, 0.49965767793724625, 0.0030265593973706787, -0.5988579341843617, -0.006944347541253066, 0.04029979208606582, 0.9945395908678365,
               0.15698510625217518, -1.2831768394685863, 1.0937721306552926, 0.6613475137268306, -0.44696767128359516, -0.8174140757469877, -1.892303711911644,
               -1.109804250710215, -0.6617193128709387, -0.7525044828419295, 0.40917572096199556, -0.20236450637456538, -0.17354382607159158, -0.24140283227854467,
               1.7087073735018894, 0.36734209684815883, -0.19854734466460922, 0.10184933942978404, 0.6243982847899877, 1.7665493511011094, -0.06938898370740094,
               -1.9715641041839593, -0.03368414989920392, 0.4290617964907311, 0.05159819743922302, -0.30982117770939815, 1.647604210905681, -1.214982899348507,
               -2.972245699310368, 0.9567406980673966, -0.9244077825804254, 1.273462174748022, 0.4149364508895135, -1.622897424445604, -1.096072395892489,
               -1.67722652069405, -1.2440103207394082, -0.3347907992149652, 0.34937500503899444, -1.3956454864454866, -1.8320556682799327, -2.4525716814873615,
               1.3158932565438999, 1.0424619550935403, 0.4728613776179114, -0.7993384668244552, 0.8047775976047779, -1.328993822674748, -0.5517542856280235,
               -0.08570570820963805, -1.2601172953695525, 0.6984883764673556, 1.1079418349876193, -0.5230949927376777, 0.743324533508432, -0.35741280746085,
               -0.6433547716879965, -0.6248070396487141, -0.975403850134493, 0.06493134905461244, -0.5758050662378422, 0.20171094486367738, -0.10593462776252129,
               -0.5370144822605072, -0.6853253756977159, -1.4465071106549015, 0.5593089566251558, 1.1803860182434085, 1.8281801860593134, 0.1393077475121944,
               -0.04181026365029896, 2.300744813553216, 0.5511941888031783, 0.9465601848529518, 1.3755595718496274, -1.1515666852841093, 0.37779029430817546,
               -0.7292803100887157, -0.16170208773955125, 0.18900362617828753, 1.1448438474771956, 0.8271738491766991, 1.2115257481247956, -1.191875436470305,
               1.4486548549389235, 0.49348318462552093, 0.26649753996923525, 2.4724547704542985, 0.6582994207353369, -0.8941392219184868, -0.4946969515871099,
               0.8080550523143554, 1.9472346620863374, 0.6014829477177043, 0.23191241572415017, -0.9677362878826911, 0.6417690472085171, -1.0490254136322847,
               0.034259889192891274, -0.7168792601975139, -1.0705626259281662, 0.5815176572837153, 0.5875960488417961, -0.17820054924711645, -0.9990232414477314,
               -0.49625310409382234, 1.0645229366516777, -1.5098752131050561, -0.42153252496880467, -0.3886937922943286, 1.026133272436106, -0.42822963485113064,
               -0.9346168372838812, -1.0186171457999047, 0.3275533703067123, 1.2486394902352276, 1.4985382411755432, 0.20336081436602027, 1.6052127564433083,
               -0.2832107440916983, -1.596145704023063, 1.536103270856809, 0.2479806262327784]

omega_func = Akima(speeds, omegas)
pitch_func = Akima(speeds,pitches)
turbulence_func = ff.GaussianTI
