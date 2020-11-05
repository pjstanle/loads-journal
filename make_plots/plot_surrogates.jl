using PyPlot
using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade
const ff = FlowFarm
include("model.jl")

speed_arr = range(0.0,stop=20.0,length=300)
# speed_arr = range(0.0,stop=15.0,length=300)

pitch_arr = range(0,0.25,length=100)

m_arr_flap = zeros(length(speed_arr))
m_arr_edge = zeros(length(speed_arr))

global azimuth_arr
azimuth_arr = [pi/2.0,3.0*pi/2.0]
figure(figsize=(6.5,2.5))
for j = 1:length(azimuth_arr)
    for k = 1:length(speed_arr)
        wind_speed = speed_arr[k]

        global azimuth_arr
        azimuth = azimuth_arr[j]

        Omega = 7.55*wind_speed/(126.4/2.0)
        if Omega > 1.2671090369478832
                                Omega = 1.2671090369478832
        end

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

    end

    global azimuth_arr
    azimuth = azimuth_arr[j]

    println(azimuth)
    model_flap = zeros(length(speed_arr))
    if azimuth == pi/2
        subplot(141)
        for i = 1:length(speed_arr)
            if speed_arr[i] <= 10.62
                model_flap[i] = 9110.0*(speed_arr[i]/10.62)^2
            elseif speed_arr[i] > 10.62
                model_flap[i] = 9110.0 + (14300.0-9110.0)/(16.13-10.62)*(speed_arr[i]-10.62)
            end

            pitch = deg2rad(pitch_func(speed_arr[i]))
            # pitch = 0.0
            model_flap[i] = model_flap[i] - 48000.0*pitch
        end

    elseif azimuth == 3*pi/2
        subplot(143)
        for i = 1:length(speed_arr)
            if speed_arr[i] <= 10.62
                model_flap[i] = 9110.0*(speed_arr[i]/10.62)^2
            elseif speed_arr[i] > 10.62
                model_flap[i] = 9110.0 + (12750.0-9110.0)/(15.4-10.62)*(speed_arr[i]-10.62)
            end

            pitch = deg2rad(pitch_func(speed_arr[i]))
            # pitch = 0.0
            model_flap[i] = model_flap[i] -40000.0*pitch

        end
    end


    plot(speed_arr,m_arr_flap,color="C0")
    plot(speed_arr,model_flap,"--",color="C1")
    ylim(0,13000)
    yticks([0,5000,10000])
    title("flatwise",fontsize=10)
    xlabel("wind speed (m/s)")
    if azimuth == pi/2
        gca().set_yticklabels(["0","5","10"])
        ylabel("root bending\nmoment (MN*m)")
        text(22,15000,"azimuth: 90 degrees",horizontalalignment="center")
    else
        gca().set_yticklabels(["",""])
        text(22,15000,"azimuth: 270 degrees",horizontalalignment="center")
    end



    model_edge = zeros(length(speed_arr))
    if azimuth == pi/2
        subplot(142)
        for i = 1:length(speed_arr)
            if speed_arr[i] <= 10.62
                model_edge[i] = 1540.0*(speed_arr[i]/10.62)^2

            elseif speed_arr[i] > 10.62
                model_edge[i] = 1540.0 + (3600.0-1540.0)/(15.7-10.62)*(speed_arr[i]-10.62)
            end

            pitch = deg2rad(pitch_func(speed_arr[i]))
            # pitch = 0.0
            if pitch > 0.0 && pitch < 0.05
                model_edge[i] = model_edge[i] - 43000.0*(pitch-0.05)^2 + 100.0
            elseif pitch >= 0.05
                model_edge[i] = model_edge[i] - 43000.0*(pitch-0.05)^1.85 + 100.0
            end
        end
        plot(speed_arr,m_arr_edge,color="C0")
        plot(speed_arr,model_edge,"--",color="C1")
        title("edgewise",fontsize=10)
        xlabel("wind speed (m/s)")
        ylim(0,13000)
        yticks([0,5000,10000])
        gca().set_yticklabels(["",""])

    elseif azimuth == 3*pi/2
        subplot(144)
        for i = 1:length(speed_arr)
            if speed_arr[i] <= 10.62
                model_edge[i] = 1540.0*(speed_arr[i]/10.62)^2
            elseif speed_arr[i] > 10.62
                model_edge[i] = 1540.0 + (3250.0-1540.0)/(15.0-10.62)*(speed_arr[i]-10.62)
            end

            pitch = deg2rad(pitch_func(speed_arr[i]))
            # pitch = 0.0
            if pitch > 0.0 && pitch < 0.05
                model_edge[i] = model_edge[i] - 29500.0*(pitch-0.05)^2 + 75.0
            elseif pitch >= 0.05
                model_edge[i] = model_edge[i] - 29500.0*(pitch-0.05)^1.8 + 75.0
            end
        end
        plot(speed_arr,m_arr_edge,color="C0",label="CCBlade")
        plot(speed_arr,model_edge,"--",color="C1",label="surrogate")
        title("edgewise",fontsize=10)
        xlabel("wind speed (m/s)")
        ylim(0,13000)
        yticks([0,5000,10000])
        gca().set_yticklabels(["",""])
        legend(fontsize=8)
    end

    suptitle("with pitch",fontsize=10)
    subplots_adjust(top=0.78,bottom=0.18,left=0.13,right=0.99,wspace=0.1)



end

# savefig("surrogate_pitch.pdf",transparent=true)
