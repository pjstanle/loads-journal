using PyPlot
using FlowFarm
using CCBlade
using Statistics
include("coeffs_data_vct.jl")
include("TIcoeffs_data.jl")
# include("TIcoeffs_data.jl")
# include("FAST_data_NEW.jl")
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
# naz = 100
# az_arr = range(0,stop=2*pi-2*pi/naz,length=naz)
nCycles = 50
#
function LHS(func,N,lower,upper;n_int=1000)
                samples = zeros(N)
                x = range(lower,stop=upper,length=n_int)
                total_area = trapz(x,func.(x))
                single_area = total_area/N
                left = lower
                for i = 1:N
                                f(x) = single_area - trapz(range(left,stop=x[1],length=n_int),func.(range(left,stop=x[1],length=n_int)))
                                xstar, _ = brent(f, left, left+upper)
                                samples[i] = rand(1)[1]*(xstar-left) + left
                                left = xstar
                end
                shuffle!(samples)
                return samples
end
# g(x) = 1/sqrt(2.0*pi)*exp(-0.5*x[1]^2)
#
# lower = -2.0
# upper = 2.0
# nCycles = 50
# turb_samples = LHS(g,nCycles*naz,lower,upper)
#
# turb_samples = turb_samples.-mean(turb_samples)
# turb_samples = turb_samples./std(turb_samples)

turb_samples = [-2.4167782740354533, 1.9186569844046706, -0.12461240205000693, -1.876252266473231, 1.311276337746329, 0.08434387769762368, -0.7333201347312834, -0.23684083170839468, 1.160783547678078, 1.6612279624993922, 0.08999354910131663, -2.143731507179793, -0.6261443188519292, 3.532991874732216, 0.29839963788881585, 1.4242357982520542, 0.45712307056950696, 0.013320177626415434, -1.294253446643497, -1.742421118811144, -0.7794135049099526, -1.6211963554967606, 0.6836707993233822, 0.25201530861592636, -0.06882503295997454, -0.4106793654743268, -0.65119579179511, 0.47865108312110793, 0.36339428830285686, -0.8244197230695441, -0.2674728183443444, -0.15050620722874625, -1.416215870429576, 1.1850353968039131, 0.04825552793860067, 0.5138078835178227, -0.04867058461720984, -0.5592111652228714, 0.585659992369232, -1.5093320964235764, -0.47094905796700376, -0.8424563427784184, -0.67525039265928, -1.5741912158480484, 0.2708878676277974, -0.43342592675288244, 1.0626190923507177, 0.9529261367224863, 1.2714465846805327, 0.7396156529772956, -1.1300210597993574, 0.6576320404912005, -0.08702221176857615, 0.5451832054591716, -1.2184814910624246, 1.5810483192982299, -0.46334258680520835, -0.5853446923515632, 0.5538497307056427, 0.3942603328606214, -1.1053432268822816, 0.3300014699028309, 2.0697114267595804, 0.41601521744093223, -1.1590820717840027, -0.2845569546843487, 1.3665229753528791, 1.8096827731675704, 0.6418911542590071, 1.1133534282572644, 1.0141969452625146, -0.1937979544469377, 0.963516656298481, 0.8380964742559501, -0.16792623660695485, -0.22679995934133604, 0.8942569232568871, -0.8963132116351336, 0.21051266515826442, -1.3469272146475781, -0.3458293717595495, 0.8414321126717208, -0.3872607046934217, 0.1267319240379616, -1.0268264990593021, -0.5207247224303075, 0.14091546503077407, 0.7078198712900953, -0.32100841443185024, -0.7119777385224016, -0.9499525467819704, 0.7944788465159335, 0.010128243338611722, 0.19245567568428923, -0.9038895710452796, 0.1823337689823329, -0.537682293567395, 0.3468774807475689, -1.0082179146017067, -0.027149157863159676]
# append!(turb_samples,turb_samples)
turbine_ID = 2
state_ID = 1

x_spl = range(1.0,stop=100.0,length=100)
spl = Akima(x_spl,turb_samples)

nbig = 100
x_spl_big = range(1.0,stop=50.0,length=Integer(length(turb_samples)*nbig/2))
turb_samples = spl.(x_spl_big)

L = 100
sweep = range(-1.5,stop=1.5,length=L)

sep_arr = [4.0,7.0,10.0]
ws_arr = [10.0,11.0,12.0,13.0]

# TI = "low"
# ambient_ti = [0.046]
TI = "high"
ambient_ti = [0.08]

# rotor_points_y, rotor_points_z = sunflower_points(300)

figure(1,figsize=(6.5,5.0))
for k = 1:length(sep_arr)
    for j = 1:length(ws_arr)
        sep = sep_arr[k]
        turbine_x = [0.0,sep*rotor_diameter[1]]

        ws = ws_arr[j]
        windspeeds = [ws]
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)

        alpha_star,beta_star,k1,k2 = get_coeffs(ws,TI)
        wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star, beta_star, k1, k2, wec_factor)
        local_ti_model = ff.LocalTIModelMaxTI(alpha_star, beta_star, k1, k2)
        # local_ti_model = ff.GaussianTI(loc,turbine_x, turbine_y, rotor_diameter, hub_height, turbine_ct, sorted_turbine_index, a_ti; div_sigma=2.5, div_ti=1.2)
        model_set = ff.WindFarmModelSet(wakedeficitmodel,wakedeflectionmodel,wakecombinationmodel,local_ti_model)

        ds,dt = getTI_coeffs(ws,TI)

        damage_model = zeros(L)
        for i = 1:L
            turbine_y = [0.0,sweep[i]*rotor_diameter[1]]

            turbine_velocities, turbine_ct, turbine_ai, turbine_local_ti = ff.turbine_velocities_one_direction(turbine_x, turbine_y, turbine_z, rotor_diameter, hub_height, turbine_yaw,
            sorted_turbine_index, ct_model, rotor_points_y, rotor_points_z, windresource,
            model_set; wind_farm_state_id=1)
            # println("turbine_ct: ", turbine_ct)
            # turbine_ct = zeros(nturbines) .+ 0.7620929940139257


            damage_model[i] = ff.get_single_damage_FINAL(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,turbine_ai,sorted_turbine_index,turbine_ID,state_ID,nCycles,az_arr,
                                turb_samples,pitch_func,ff.GaussianTI,r,sections,Rhub,Rtip,precone,tilt,windresource,model_set,
                                turbine_velocities, turbine_ct,turbine_local_ti;
                                Nlocs=Nlocs,fos=1.15,div_sigma=ds,div_ti=dt)

        end

        if sep == 4.0 && ws == 10.0
            subplot(431)
            plt.xticks(fontsize=8)
            plt.yticks(fontsize=8)
            title("4 D",fontsize=8)
            FS, FD = fastdata(TI,ws,sep)
            plot(FS,FD,"o")
            plot(sweep,damage_model)
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            # ylabel(string("damage\n",L"$U_\infty=10$ m/s"))
            # ylabel("10\nm/s",rotation=0,labelpad=16,verticalalignment="center")
            ylabel("damage\n10 m/s",fontsize=8,horizontalalignment="center")
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false)
            text(-2.7,0.5,"wind\nspeed",fontsize=8,horizontalalignment="center")
        elseif sep == 7.0 && ws == 10.0
            subplot(432)
            plt.xticks(fontsize=8)
            plt.yticks(fontsize=8)
            title("7 D",fontsize=8)
            FS, FD = fastdata(TI,ws,sep)
            plot(FS,FD,"o")
            plot(sweep,damage_model)
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 10.0
            subplot(433)
            plt.xticks(fontsize=8)
            plt.yticks(fontsize=8)
            FS, FD = fastdata(TI,ws,sep)
            plot(FS,FD,"o")
            plot(sweep,damage_model)
            gca().spines["right"].set_visible(false)
            gca().spines["top"].set_visible(false)
            title("10 D",fontsize=8)
            tick_params(
                axis="both",          # changes apply to the x-axis
                which="both",      # both major and minor ticks are affected
                labelbottom=false,
                labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 11.0
                subplot(434)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("damage\n",L"$U_\infty=11$ m/s"))
                ylabel("damage\n11 m/s",fontsize=8,horizontalalignment="center")
                # ylabel("11\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false)
        elseif sep == 7.0 && ws == 11.0
                subplot(435)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 11.0
                subplot(436)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 12.0
                subplot(437)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("damage\n",L"$U_\infty=12$ m/s"))
                # ylabel("12\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                ylabel("damage\n12 m/s",fontsize=8,horizontalalignment="center")
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both",      # both major and minor ticks are affected
                        labelbottom=false)
        elseif sep == 7.0 && ws == 12.0
                subplot(438)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 12.0
                subplot(439)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",      # both major and minor ticks are affected
                    labelbottom=false,
                    labelleft=false) # labels along the bottom edge are off

        elseif sep == 4.0 && ws == 13.0
                subplot(4,3,10)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                # ylabel(string("damage\n",L"$U_\infty=13$ m/s"))
                # ylabel("13\nm/s",rotation=0,labelpad=16,verticalalignment="center")
                ylabel("damage\n13 m/s",fontsize=8,horizontalalignment="center")
                xlabel("offset (D)",fontsize=8)
                tick_params(
                        axis="both",          # changes apply to the x-axis
                        which="both")
        elseif sep == 7.0 && ws == 13.0
                subplot(4,3,11)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o")
                plot(sweep,damage_model)
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                xlabel("offset (D)",fontsize=8)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    labelleft=false) # labels along the bottom edge are off
        elseif sep == 10.0 && ws == 13.0
                subplot(4,3,12)
                plt.xticks(fontsize=8)
                plt.yticks(fontsize=8)
                FS, FD = fastdata(TI,ws,sep)
                plot(FS,FD,"o",label="SOWFA")
                plot(sweep,damage_model,label="model")
                gca().spines["right"].set_visible(false)
                gca().spines["top"].set_visible(false)
                xlabel("offset (D)",fontsize=8)
                tick_params(
                    axis="both",          # changes apply to the x-axis
                    which="both",
                    labelleft=false) # labels along the bottom edge are off
                legend(loc=1,fontsize=8)
        end

        # if j == 4
        #         ylim(0.0,3)
        #         yticks([1.0,2.0,3.0])
        # else
                ylim(0.0,0.3)
                yticks([0.05,0.1,0.15,0.2,0.25])
        # end
        end
end


# suptitle("low turbulence intensity: 4.6%",fontsize=8)
suptitle("high turbulence intensity: 8%",fontsize=8)
subplots_adjust(top=0.91,bottom=0.1,left=0.13,right=0.99,wspace=0.1,hspace=0.1)
# savefig("damage_highTI_second_revision.pdf",transparent=true)
