using PyPlot
using FlowFarm
using CCBlade
using Statistics
include("coeffs_data.jl")
include("TIcoeffs_data.jl")
include("FAST_data_low.jl")
include("model.jl")

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


Nlocs = 50
az_arr = [pi/2,3*pi/2]
naz = length(az_arr)
nCycles = 50

turb_samples = [-2.4167782740354533, 1.9186569844046706, -0.12461240205000693, -1.876252266473231, 1.311276337746329, 0.08434387769762368, -0.7333201347312834, -0.23684083170839468, 1.160783547678078, 1.6612279624993922, 0.08999354910131663, -2.143731507179793, -0.6261443188519292, 3.532991874732216, 0.29839963788881585, 1.4242357982520542, 0.45712307056950696, 0.013320177626415434, -1.294253446643497, -1.742421118811144, -0.7794135049099526, -1.6211963554967606, 0.6836707993233822, 0.25201530861592636, -0.06882503295997454, -0.4106793654743268, -0.65119579179511, 0.47865108312110793, 0.36339428830285686, -0.8244197230695441, -0.2674728183443444, -0.15050620722874625, -1.416215870429576, 1.1850353968039131, 0.04825552793860067, 0.5138078835178227, -0.04867058461720984, -0.5592111652228714, 0.585659992369232, -1.5093320964235764, -0.47094905796700376, -0.8424563427784184, -0.67525039265928, -1.5741912158480484, 0.2708878676277974, -0.43342592675288244, 1.0626190923507177, 0.9529261367224863, 1.2714465846805327, 0.7396156529772956, -1.1300210597993574, 0.6576320404912005, -0.08702221176857615, 0.5451832054591716, -1.2184814910624246, 1.5810483192982299, -0.46334258680520835, -0.5853446923515632, 0.5538497307056427, 0.3942603328606214, -1.1053432268822816, 0.3300014699028309, 2.0697114267595804, 0.41601521744093223, -1.1590820717840027, -0.2845569546843487, 1.3665229753528791, 1.8096827731675704, 0.6418911542590071, 1.1133534282572644, 1.0141969452625146, -0.1937979544469377, 0.963516656298481, 0.8380964742559501, -0.16792623660695485, -0.22679995934133604, 0.8942569232568871, -0.8963132116351336, 0.21051266515826442, -1.3469272146475781, -0.3458293717595495, 0.8414321126717208, -0.3872607046934217, 0.1267319240379616, -1.0268264990593021, -0.5207247224303075, 0.14091546503077407, 0.7078198712900953, -0.32100841443185024, -0.7119777385224016, -0.9499525467819704, 0.7944788465159335, 0.010128243338611722, 0.19245567568428923, -0.9038895710452796, 0.1823337689823329, -0.537682293567395, 0.3468774807475689, -1.0082179146017067, -0.027149157863159676]
# append!(turb_samples,turb_samples)
turbine_ID = 2
state_ID = 1

L = 100
sweep = range(-1.5,stop=1.5,length=L)

sep_arr = [4.0,7.0,10.0]
ws_arr = [12.0]

TI = "low"
ambient_ti = [0.046]


figure(1,figsize=(6.5,2.2))
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        turbine_x = [0.0,sep*rotor_diameter[1]]

        ws = ws_arr[j]
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)

        alpha_star,beta_star,k1,k2 = get_coeffs(ws,"low")
        wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
        local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
        model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

        ds,dt = getTI_coeffs(ws,TI)

        damage_model4 = zeros(L)
        rotor_points_y = [-0.69,-0.69,0.69,0.69]
        rotor_points_z = [-0.69,0.69,-0.69,0.69]
        for i = 1:L
            turbine_y = [0.0,sweep[i]*rotor_diameter[1]]

            turbine_velocities, turbine_ct, turbine_ai, turbine_local_ti = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
            sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
            model_set; wind_farm_state_id=1)

            turbine_ct = zeros(nturbines) .+ 0.7620929940139257

            damage_model4[i] = ff.get_single_damage_FINAL(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,sorted_turbine_index,turbine_ID,state_ID,nCycles,az_arr,
                                turb_samples,pitch_func,ff.GaussianTI,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set,
                                turbine_velocities, turbine_ct,turbine_local_ti;
                                Nlocs=Nlocs,fos=2.0,div_sigma=ds,div_ti=dt)

        end

        rotor_points_y, rotor_points_z = sunflower_points(300)
        damage_model100 = zeros(L)
        for i = 1:L
            turbine_y = [0.0,sweep[i]*rotor_diameter[1]]

            turbine_velocities, turbine_ct, turbine_ai, turbine_local_ti = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
            sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
            model_set; wind_farm_state_id=1)

            turbine_ct = zeros(nturbines) .+ 0.7620929940139257

            damage_model100[i] = ff.get_single_damage_FINAL(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,sorted_turbine_index,turbine_ID,state_ID,nCycles,az_arr,
                                turb_samples,pitch_func,ff.GaussianTI,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set,
                                turbine_velocities, turbine_ct,turbine_local_ti;
                                Nlocs=Nlocs,fos=2.0,div_sigma=ds,div_ti=dt)

        end


        if sep == 4.0 && ws == 12.0
                subplot(131)
                plot(sweep,damage_model4)
                plot(sweep,damage_model100,"--")
                ylabel(string("damage\n",L"$U_\infty=12$ m/s"))
                xlabel("offset (D)")
                title("4 D",fontsize=10)
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both",      # both major and minor ticks are affected
                        labelbottom=false)
        elseif sep == 7.0 && ws == 12.0
                subplot(132)
                plot(sweep,damage_model4)
                plot(sweep,damage_model100,"--")
                xlabel("offset (D)")
                title("7 D",fontsize=10)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(133)
                plot(sweep,damage_model4,label="4 samples")
                plot(sweep,damage_model100,"--",label="300 samples")
                xlabel("offset (D)")
                title("10 D",fontsize=10)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
                legend(loc=1)
             end
                ylim(0.0,0.4)
end
end

suptitle("low turbulence intensity: 4.6%",fontsize=10)
subplots_adjust(top=0.82,bottom=0.1,left=0.13,right=0.99,wspace=0.1,hspace=0.1)
savefig("damage_samples.pdf",transparent=true)
