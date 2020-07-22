using PyPlot
using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade
const ff = FlowFarm

make_plots = false
if make_plots == true
                        af_path = "/Users/ningrsrch/Dropbox/Projects/waked-loads/5MW_AFFiles_julia"
                        path1 = af_path*"/Cylinder1.dat"
                        path2 = af_path*"/Cylinder2.dat"
                        path3 = af_path*"/DU40_A17.dat"
                        path4 = af_path*"/DU35_A17.dat"
                        path5 = af_path*"/DU30_A17.dat"
                        path6 = af_path*"/DU25_A17.dat"
                        path7 = af_path*"/DU21_A17.dat"
                        path8 = af_path*"/NACA64_A17.dat"

                        af1 = readdlm(path1, skipstart=1)
                        af2 = readdlm(path2, skipstart=1)
                        af3 = readdlm(path3, skipstart=1)
                        af4 = readdlm(path4, skipstart=1)
                        af5 = readdlm(path5, skipstart=1)
                        af6 = readdlm(path6, skipstart=1)
                        af7 = readdlm(path7, skipstart=1)
                        af8 = readdlm(path8, skipstart=1)

                        aoa1 = deg2rad.(af1[:,1])
                        aoa2 = deg2rad.(af2[:,1])
                        aoa3 = deg2rad.(af3[:,1])
                        aoa4 = deg2rad.(af4[:,1])
                        aoa5 = deg2rad.(af5[:,1])
                        aoa6 = deg2rad.(af6[:,1])
                        aoa7 = deg2rad.(af7[:,1])
                        aoa8 = deg2rad.(af8[:,1])

                        cl1 = deg2rad.(af1[:,2])
                        cl2 = deg2rad.(af2[:,2])
                        cl3 = deg2rad.(af3[:,2])
                        cl4 = deg2rad.(af4[:,2])
                        cl5 = deg2rad.(af5[:,2])
                        cl6 = deg2rad.(af6[:,2])
                        cl7 = deg2rad.(af7[:,2])
                        cl8 = deg2rad.(af8[:,2])

                        cd1 = deg2rad.(af1[:,3])
                        cd2 = deg2rad.(af2[:,3])
                        cd3 = deg2rad.(af3[:,3])
                        cd4 = deg2rad.(af4[:,3])
                        cd5 = deg2rad.(af5[:,3])
                        cd6 = deg2rad.(af6[:,3])
                        cd7 = deg2rad.(af7[:,3])
                        cd8 = deg2rad.(af8[:,3])


                        plot(rad2deg.(aoa1),cl1)
                        plot(rad2deg.(aoa2),cl2)
                        plot(rad2deg.(aoa3),cl3)
                        plot(rad2deg.(aoa4),cl4)
                        plot(rad2deg.(aoa5),cl5)
                        plot(rad2deg.(aoa6),cl6)
                        plot(rad2deg.(aoa7),cl7)
                        plot(rad2deg.(aoa8),cl8)
end


speed_arr = range(0.0,stop=20.0,length=200)
# speed_arr = [12.0]

# pitch_arr = range(0,stop=deg2rad(15),length=100)
pitch_arr = range(0,0.25,length=100)

m_arr_flap = zeros(length(speed_arr))
m_arr_edge = zeros(length(speed_arr))
# Np = zeros(length(speed_arr))
# Tp = zeros(length(speed_arr))
# Q = zeros(length(speed_arr))

global azimuth
azimuth = pi/2
for k = 1:length(speed_arr)
                        wind_speed = speed_arr[k]
                        include("model.jl")
                        # m_arr_flap = zeros(length(pitch_arr))
                        # m_arr_edge = zeros(length(pitch_arr))
                        # for i = 1:length(pitch_arr)

                                                global azimuth


                                                # Omega = 7.571322070955497*wind_speed/(126.4/2.0)
                                                #
                                                # if Omega > 1.365713158368555
                                                #                         Omega = 1.365713158368555
                                                # end

                                                Omega = 7.55*wind_speed/(126.4/2.0)
                                                if Omega > 1.2671090369478832
                                                                        Omega = 1.2671090369478832
                                                end
                                                # Omega = 1.2671090369478832*0.9


                                                # 1.2671090354999999
                                                # 7.024674652947367
                                                # println("speed: ", wind_speed)
                                                # println("Omega: ", Omega)
                                                # Omega_rpm = omega_func(wind_speed) #in rpm
                                                # Omega = Omega_rpm*0.10471975512 #convert to rad/s
                                                pitch = deg2rad(pitch_func(wind_speed))
                                                # pitch = 0.0
                                                # pitch = pitch_arr[i]

                                                windspeeds = [wind_speed]
                                                windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)

                                                U = ff.get_speeds([0.0],turbine_y,turbine_z,1,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,0.046,
                                                                        sorted_turbine_index,windspeeds,windresource,model_set)
                                                rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
                                                op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[1], tilt, azimuth, air_density)
                                                out = CCBlade.solve.(Ref(rotor), sections, op)
                                                m_arr_flap[k],m_arr_edge[k] = ff.get_moments_twist(out,Rhub,Rtip,r,azimuth,precone,tilt,rotor,sections)
                                                # Np[k] = out[13].Np
                                                # Tp[k] = out[13].Tp
                        # end
                        # plot(pitch_arr,m_arr_edge.-m_arr_edge[1])#,color="C0")
end

flap = true
edge = false

if flap == true
plot(speed_arr,m_arr_flap,color="C0")

model_flap = zeros(length(speed_arr))
if azimuth == pi/2
    for i = 1:length(speed_arr)
        if speed_arr[i] <= 10.62
            model_flap[i] = 9110.0*(speed_arr[i]/10.62)^2
        # elseif speed_arr[i] > 10.62 && speed_arr[i] <= 16.13
        #     model_flap[i] = 9110.0 + (14300.0-9110.0)/(16.13-10.62)*(speed_arr[i]-10.62)
        # elseif speed_arr[i] > 16.13
        #     model_flap[i] = 14300.0 + (16740.0-14300.0)/(25.0-16.13)*(speed_arr[i]-16.13)
        elseif speed_arr[i] > 10.62
            model_flap[i] = 9110.0 + (14300.0-9110.0)/(16.13-10.62)*(speed_arr[i]-10.62)
        end

        pitch = deg2rad(pitch_func(speed_arr[i]))
        # if pitch <= 0.214
            model_flap[i] = model_flap[i] - 48000.0*pitch
        # else
        #     model_flap[i] = model_flap[i] - 45000.0*0.214 - 31000.0*(pitch-0.214)
        # end
    end

elseif azimuth == 3*pi/2
    for i = 1:length(speed_arr)
        if speed_arr[i] <= 10.62
            model_flap[i] = 9110.0*(speed_arr[i]/10.62)^2
        # elseif speed_arr[i] > 10.62 && speed_arr[i] <= 15.4
        #     model_flap[i] = 9110.0 + (12750.0-9110.0)/(15.4-10.62)*(speed_arr[i]-10.62)
        # elseif speed_arr[i] > 15.4
        #     model_flap[i] = 12750.0 + (14750.0-12750.0)/(25.0-15.4)*(speed_arr[i]-15.4)
        elseif speed_arr[i] > 10.62
            model_flap[i] = 9110.0 + (12750.0-9110.0)/(15.4-10.62)*(speed_arr[i]-10.62)
        end

        pitch = deg2rad(pitch_func(speed_arr[i]))
        # if pitch <= 0.194
            model_flap[i] = model_flap[i] -40000.0*pitch
        # else
        #     model_flap[i] = model_flap[i] - 39000.0*0.194 - 20000.0*(pitch-0.194)
        # end
    end
end


plot(speed_arr,model_flap,color="C1")
end



if edge == true
plot(speed_arr,m_arr_edge,color="C0")

model_edge = zeros(length(speed_arr))
if azimuth == pi/2
    for i = 1:length(speed_arr)
        if speed_arr[i] <= 10.62
            model_edge[i] = 1540.0*(speed_arr[i]/10.62)^2
        # elseif speed_arr[i] > 10.62 && speed_arr[i] <= 15.7
        #     model_edge[i] = 1540.0 + (3600.0-1540.0)/(15.7-10.62)*(speed_arr[i]-10.62)
        # elseif speed_arr[i] > 15.7
        #     model_edge[i] = 3600.0 + (4860.0-3600.0)/(25.0-15.7)*(speed_arr[i]-15.7)

        elseif speed_arr[i] > 10.62
            model_edge[i] = 1540.0 + (3600.0-1540.0)/(15.7-10.62)*(speed_arr[i]-10.62)
        end

        pitch = deg2rad(pitch_func(speed_arr[i]))
        # pitch = 0.0
        # if pitch <= 0.202
        if pitch > 0.0 && pitch < 0.05
            model_edge[i] = model_edge[i] - 43000.0*(pitch-0.05)^2 + 100.0
        elseif pitch >= 0.05
            model_edge[i] = model_edge[i] - 43000.0*(pitch-0.05)^1.85 + 100.0
        end
        # else
        #     model_edge[i] = model_edge[i] - 4000.0*0.202 - 1000.0*(pitch-0.202)
    end

elseif azimuth == 3*pi/2
    for i = 1:length(speed_arr)
        if speed_arr[i] <= 10.62
            model_edge[i] = 1540.0*(speed_arr[i]/10.62)^2
        # elseif speed_arr[i] > 10.62 && speed_arr[i] <= 15.0
        #     model_edge[i] = 1540.0 + (3250.0-1540.0)/(15.0-10.62)*(speed_arr[i]-10.62)
        # elseif speed_arr[i] > 15.0
        #     model_edge[i] = 3250.0 + (4250.0-3250.0)/(25.0-14.8)*(speed_arr[i]-15.0)
        elseif speed_arr[i] > 10.62
            model_edge[i] = 1540.0 + (3250.0-1540.0)/(15.0-10.62)*(speed_arr[i]-10.62)
        end

        pitch = deg2rad(pitch_func(speed_arr[i]))
        # pitch = 0.0
        # if pitch <= 0.202
        if pitch > 0.0 && pitch < 0.05
            model_edge[i] = model_edge[i] - 29500.0*(pitch-0.05)^2 + 75.0
        elseif pitch >= 0.05
            model_edge[i] = model_edge[i] - 29500.0*(pitch-0.05)^1.8 + 75.0
        end
    end
end

plot(speed_arr,model_edge,color="C1")
end


















# wind_speed = 4.0
# include("model.jl")
#
# Omega = 7.024674652947367*wind_speed/(126.4/2.0)
# # if Omega > 1.2671090354999999
# #                         Omega = 1.2671090354999999
# # end
# # pitch = deg2rad(pitch_func(wind_speed))
#
# # Omega = 1.2671090354999999
# pitch = 0.0
#
# U = ff.get_speeds([0.0],turbine_y,turbine_z,1,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,0.046,
#                         sorted_turbine_index,windspeeds,windresource,model_set)
# rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
# op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[1], tilt, azimuth, air_density)
# out = CCBlade.solve.(Ref(rotor), sections, op)
# m_flap_0, m_edge_0 = ff.get_moments_twist(out,Rhub,Rtip,r,azimuth,precone,tilt,rotor,sections)
#
# plot(wind_speed,m_flap_0,"o",color="C2")
#
#
# winds = range(wind_speed-5.0,stop=wind_speed+5.0,length=100)
# model_flap = zeros(length(winds))
# for i = 1:length(winds)
#                         if wind_speed <= 11.4 && winds[i] <= 11.4
#                                                 model_flap[i] = m_flap_0 * (winds[i]/wind_speed)^2
#                         end
# end
#
# plot(winds,model_flap,color="C2")













# plot(speed_arr,Q)

# model = zeros(length(pitch_arr))
# n = 280
# m = 0.05
# for i = 1:length(pitch_arr)
#                         model[i] = 5000.0 - ((pitch_arr[i]-m)*n)^2
# end
# # plot(pitch_arr,model,color="C1")
#
#


# wind_speed = 11.4
# include("model.jl")
#
# Omega = 1.365713158368555
# pitch = 0.0
#
# U = ff.get_speeds([0.0],turbine_y,turbine_z,1,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,0.046,
#                         sorted_turbine_index,windspeeds,windresource,model_set)
# rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
# op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[1], tilt, azimuth, air_density)
# out = CCBlade.solve.(Ref(rotor), sections, op)
# m_flap_0, m_edge_0 = ff.get_moments_twist(out,Rhub,Rtip,r,azimuth,precone,tilt,rotor,sections)
# #
#
# n = 11.4
# model_ws = range(0,stop=11.4,length=100)
# model = zeros(100)








# pon = 1.3

# pon = range(0.0,stop=5.0,length=100)
# res = zeros(length(pon))
# for j = 1:length(pon)
#                         for i = 1:100
#                                                 model[i] = -m_edge_0 * (model_ws[i]/n)^pon[j] - 3429.0
#                         end
#                         # plot(model_ws,model,color="C1")
#                         res[j] = sum((m_arr_edge.-model).^2)
#                         # println(res[j])
# end
# for i = 1:100
                        # model[i] = -m_edge_0 * (model_ws[i]/n)^1.285 - 3429.0
                        # model[i] = m_flap_0 * (model_ws[i]/n)^1.285
# end
# plot(model_ws,model,color="C1")
# model = zeros(length(speed_arr))
# n = 11.4
# for k = 1:length(speed_arr)
#                         if speed_arr[k] < n
#                                                 model[k] = m_flap_0 * (speed_arr[k]/n)^1.5
#                         elseif speed_arr[k] > n && speed_arr[k] < 11.4
#                                                 model[k] = m_flap_0
#                         else
#                                                 slope_flap = -1781.08
#                                                 model[k] = m_flap_0 + (speed_arr[k]-11.4)*slope_flap
#                         end
# end
# plot(speed_arr,model)
