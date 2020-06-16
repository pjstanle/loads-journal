using FlowFarm
const ff = FlowFarm
using CCBlade
using DelimitedFiles
using FLOWMath
using Dierckx

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
#     local_speed_array = range(0.0,stop=25.0,length=101)
#     freestream_speed_array = range(0.0,stop=25.0,length=100)
#
#     np_arr = zeros(length(local_speed_array),length(freestream_speed_array))
#     tp_arr = zeros(length(local_speed_array),length(freestream_speed_array))
#     plot_speeds_local = zeros(length(local_speed_array),length(freestream_speed_array))
#     plot_speeds_free = zeros(length(local_speed_array),length(freestream_speed_array))
#
#     nr = length(r)
#
#     global func_arr_np
#     global func_arr_tp
#
#     func_arr_np = Array{Spline2D}(undef,nr)
#     func_arr_tp = Array{Spline2D}(undef,nr)
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
#                             np_arr[i,j] = out.Np[loc_index]
#                             tp_arr[i,j] = out.Tp[loc_index]
#                         end
#                     end
#
#                     np_func = Spline2D(local_speed_array,freestream_speed_array,np_arr)
#                     tp_func = Spline2D(local_speed_array,freestream_speed_array,tp_arr)
#                     func_arr_np[k] = np_func
#                     func_arr_tp[k] = tp_func
#     end
#
#
#     function np_function(local_speed,freestream_speed)
#                     global func_arr_np
#                     nr = length(func_arr_np)
#                     Np = zeros(nr)
#                     for i=1:nr
#                                     Np[i] = func_arr_np[i](local_speed[i],freestream_speed)
#                     end
#                     return Np
#     end
#
#
#
#
#     function tp_function(local_speed,freestream_speed)
#                     global func_arr_tp
#                     nr = length(func_arr_tp)
#                     Tp = zeros(nr)
#                     for i=1:nr
#                                     Tp[i] = func_arr_tp[i](local_speed[i],freestream_speed)
#                     end
#                     return Tp
#     end
#
#     println("time to setup functions: ", time()-s)
# end
# figure(1)
# title("flapwise")
# pcolormesh(plot_speeds_local,plot_speeds_free,np_arr,vmin=minimum(np_arr),vmax=maximum(np_arr))
# colorbar()
# figure(2)
# title("edgewise")
# pcolormesh(plot_speeds_local,plot_speeds_free,tp_arr,vmin=minimum(tp_arr),vmax=maximum(tp_arr))
# colorbar()
# plot(local_speed_array,np_arr,label="Np")
# plot(local_speed_array,tp_arr,label="Tp")
# legend()


naz = 2
Nlocs = 20
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

# turbine_ID = 2
# state_ID = 1
#
#
# turb = "low"
# ws = 11.0
# sep = 4.0
#
# windspeeds = [ws]
# windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
# off = range(-1.0,stop=1.0,length=25)
#
# run = true
# if run == true
#     start = time()
#
#     global t1_damage
#     global t2_damage
#
#     t1_damage = zeros(length(off))
#
#     for k=1:length(off)
#
#         global t1_damage
#         global t2_damage
#
#         println("offset: ", off[k])
#         offset = off[k]*rotor_diameter[1]
#         turbine_y = [0.0,offset]
#
#         t1 = time()
#         t1_damage[k] = ff.get_single_damage_surr(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,sorted_turbine_index,ct_model,turbine_ID,state_ID,nCycles,az_arr,
#             turb_samples,np_function,tp_function,omega_func,pitch_func,ff.GaussianTI,r,rotor,sections,Rhub,Rtip,precone,tilt,air_density,windresource,model_set,Nlocs=Nlocs)
#
#         println(time()-t1)
#     end
#
#     scatter(off,t1_damage,color="C0")
#
#     include("FAST_data.jl")
#     FS,FD = fastdata(turb,ws,sep)
#     scatter(FS,FD,color="C2")
#
#     xlabel("offset (D)")
#     ylabel("damage")
#
#
#     legend(["front turbine", "FAST"])
#     title(sep)
#     ylim(-0.1,2.0)
#     # ylim(-0.1,1.1)
# end
#
#
#
#
#

include("model_lowTI.jl")
turbine_x = readdlm("no_loads/x_no_loads170.txt")[:,1]
turbine_y = readdlm("no_loads/y_no_loads170.txt")[:,1]

# include("model.jl")
# turbine_x = [0.0,500.0]
# turbine_y = [0.0,-60.0]
# naz = 1
# Nlocs = 200
# az_arr = [pi/2.0,3.0*pi/2.0]
# nCycles = 2
# turb_samples = [-1.0,3.0,-2.0,1.0]

s1 = time()
println("running")
# damage = ff.get_total_farm_damage_surr(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,ct_model,
#                       nCycles,az_arr,turb_samples,flap_func,edge_func,omega_func,pitch_func,ff.GaussianTI,r,rotor,sections,Rhub,Rtip,precone,tilt,air_density,windresource,model_set,
#                       fos=1.15,Nlocs=Nlocs)
damage = ff.get_total_farm_damage_super(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,ct_model,
        nCycles,az_arr,turb_samples,omega_func,pitch_func,turbulence_func,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set;
        Nlocs=Nlocs,fos=1.25)
println("time to run damage: ", time()-s1)
plot(damage,"o")
