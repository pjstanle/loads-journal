using PyPlot
using DelimitedFiles
using FlowFarm
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


speed_arr = range(0.0,stop=25,length=100)
m_arr_flap = zeros(length(speed_arr))
m_arr_edge = zeros(length(speed_arr))

for i = 1:length(speed_arr)

                        wind_speed = speed_arr[i]
                        azimuth = pi/2
                        include("model.jl")

                        Omega_rpm = omega_func(wind_speed) #in rpm
                        Omega = Omega_rpm*0.10471975512 #convert to rad/s
                        pitch = deg2rad(pitch_func(wind_speed))

                        U = ff.get_speeds([0.0],turbine_y,turbine_z,1,hub_height,r,turbine_yaw,azimuth,turbine_ct,turbine_ai,rotor_diameter,0.046,
                                                sorted_turbine_index,windspeeds,windresource,model_set)
                        rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
                        op = ff.distributed_velocity_op.(U, Omega, r, precone, turbine_yaw[1], tilt, azimuth, air_density)
                        out = CCBlade.solve.(Ref(rotor), sections, op)

                        # m_arr_flap[i],m_arr_edge[i] = ff.get_moments(out,Rhub,Rtip,r,azimuth,precone,tilt)
                        m_arr_flap[i],m_arr_edge[i] = ff.get_moments_twist(out,Rhub,Rtip,r,azimuth,precone,tilt,rotor,sections)
end

plot(speed_arr,m_arr_flap)
