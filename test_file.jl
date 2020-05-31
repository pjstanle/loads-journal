# include("fatigue_model.jl")

# include("FAST_data.jl")
include("model.jl")
using Random
# include("model_set_2.jl")


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




turb = "low"
ws = 13.0
sep = 4.0

points_x = [0.69,0,-0.69,0]
points_y = [0,0.69,0,-0.69]

fos = 1.15

rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
sections = CCBlade.Section.(r,chord,theta,airfoils)

# off = [-1.,-0.8,-0.6,-0.4,-0.2,0.0,0.2,0.4,0.6,0.8,1.0]
# off = [-1.0,-0.8,-0.6,-0.4,-0.2,0.0]
off = range(-1.0,stop=1.0,length=25)
# off = range(-0.5,stop=-0.2,length=3)
# off = [-0.6]
dams = zeros(length(off))

#low turb
ky = 0.015
kz = 0.015
alpha_star = 5.0
beta_star = 0.5

#high turb
# ky = 0.035
# kz = 0.035
# alpha_star = 6.5
# beta_star = 0.8

horizontal_spread_rate = ky
vertical_spread_rate = kz
wakedeficitmodel = ff.GaussYaw(horizontal_spread_rate,vertical_spread_rate,alpha_star,beta_star,1.0)
# wakedeficitmodel = ff.GaussYawVariableSpread(alpha_star,beta_star,1.0)
wakedeflectionmodel = ff.JiminezYawDeflection(horizontal_spread_rate)
ms = ff.WindFarmModelSet(wakedeficitmodel, wakedeflectionmodel, wakecombinationmodel,local_ti_model)

turbine_x = [0.0,sep*rotor_diameter]
init_inflow_velcities = zeros(length(turbine_x)).+ws

omega_func = Akima(speeds, omegas)
pitch_func = Akima(speeds, pitches)

tilt = deg2rad(5.0)
rho = 1.225

# nCycles = 2500
# naz = 2
# az_arr = range(0.0,stop=2.0*pi-2.0*pi/naz,length=naz)
naz = 2
Nlocs = 200
az_arr = [pi/2,3*pi/2]
# az_arr = [0.0,pi/2,pi,3*pi/2]

# turb_samples = zeros(naz*nCycles)
# using Distributions
# alph = 2.0
# thet = 1.0
# weib = Weibull(alph,thet)
# ray = Rayleigh(alph)
# for i = 1:length(turb_samples)
#     turb_samples[i] = rand(weib)
# end
# using Statistics
# turb_samples = turb_samples./std(turb_samples)
# turb_samples = turb_samples .- mean(turb_samples)

#
# turb_samples = randn(naz*nCycles)

g(x) = 1/sqrt(2.0*pi)*exp(-0.5*x[1]^2)

nCycles = 100
lower = -4.0
upper = 4.0
# diff = LHS(g,nCycles*naz,lower,upper)
# turb_samples = zeros(nCycles*naz)
# for i = 1:nCycles*naz-1
#     turb_samples[i+1] = turb_samples[i]+diff[i]
# end

# turb_samples = LHS(g,nCycles*naz,lower,upper)

turb_samples = [-1.7375742815948083, -1.135389245536721, 0.2630500661591889, -0.3053490870899974, 0.45122718486129615, 1.3409656986041674, -0.5962815531229234, -0.8493480555694776, 0.6848369957940627, -0.7771766418857682, 0.8517520073813781, -1.55121204574954, 0.9905046860451119, -0.4608656968037635, 0.7587262485526834, -1.3704467034953913, -0.831452989259264, -0.056209344897895024, -0.3826758972800919, -0.1160034988857537, 0.8934058398493318, 0.1232662269472102, -1.4259490734091038, 0.08730632432141205, 0.220114136790133, -0.21512941735364838, -0.27219450738624384, 0.1362571602997146, 1.9738755600156555, 0.30585725550110954, 1.1582850981501636, 0.09420837912360198, 0.9228288367395507, 0.17538955539546192, -0.40412325658363457, 3.780851032410102, -0.26388716275783936, -0.020801732384506465, -0.1336549155203504, 0.2906739135354345, 2.1312061518785486, -0.9002466925300798, 0.45720257310523066, -1.7505057790094762, 1.4066197735539343, -0.32494821468167184, -0.6966259079423474, -2.078912472251868, 0.9135061026036851, 0.3910927643533145, -0.09807936478061946, -0.5608043316451404, 0.8652341644152277, 0.7319576001136265, 0.7820837886706138, 0.3427756118883895, -2.2205214713373165, 0.29795270622313863, 0.5265642785081389, -0.14787685963244643, 1.5619455649553944, 0.511198972073372, 0.7084023961683763, -0.861279192574816, 0.02378123660375562, -0.6341896458879221, -0.4807288677229144, -0.23810513426345103, 1.2816747716663464, -0.7683218197813537, -0.3683566101504853, 0.49965767793724625, 0.0030265593973706787, -0.5988579341843617, -0.006944347541253066, 0.04029979208606582, 0.9945395908678365, 0.15698510625217518, -1.2831768394685863, 1.0937721306552926, 0.6613475137268306, -0.44696767128359516, -0.8174140757469877, -1.892303711911644, -1.109804250710215, -0.6617193128709387, -0.7525044828419295, 0.40917572096199556, -0.20236450637456538, -0.17354382607159158, -0.24140283227854467, 1.7087073735018894, 0.36734209684815883, -0.19854734466460922, 0.10184933942978404, 0.6243982847899877, 1.7665493511011094, -0.06938898370740094, -1.9715641041839593, -0.03368414989920392, 0.4290617964907311, 0.05159819743922302, -0.30982117770939815, 1.647604210905681, -1.214982899348507, -2.972245699310368, 0.9567406980673966, -0.9244077825804254, 1.273462174748022, 0.4149364508895135, -1.622897424445604, -1.096072395892489, -1.67722652069405, -1.2440103207394082, -0.3347907992149652, 0.34937500503899444, -1.3956454864454866, -1.8320556682799327, -2.4525716814873615, 1.3158932565438999, 1.0424619550935403, 0.4728613776179114, -0.7993384668244552, 0.8047775976047779, -1.328993822674748, -0.5517542856280235, -0.08570570820963805, -1.2601172953695525, 0.6984883764673556, 1.1079418349876193, -0.5230949927376777, 0.743324533508432, -0.35741280746085, -0.6433547716879965, -0.6248070396487141, -0.975403850134493, 0.06493134905461244, -0.5758050662378422, 0.20171094486367738, -0.10593462776252129, -0.5370144822605072, -0.6853253756977159, -1.4465071106549015, 0.5593089566251558, 1.1803860182434085, 1.8281801860593134, 0.1393077475121944, -0.04181026365029896, 2.300744813553216, 0.5511941888031783, 0.9465601848529518, 1.3755595718496274, -1.1515666852841093, 0.37779029430817546, -0.7292803100887157, -0.16170208773955125, 0.18900362617828753, 1.1448438474771956, 0.8271738491766991, 1.2115257481247956, -1.191875436470305, 1.4486548549389235, 0.49348318462552093, 0.26649753996923525, 2.4724547704542985, 0.6582994207353369, -0.8941392219184868, -0.4946969515871099, 0.8080550523143554, 1.9472346620863374, 0.6014829477177043, 0.23191241572415017, -0.9677362878826911, 0.6417690472085171, -1.0490254136322847, 0.034259889192891274, -0.7168792601975139, -1.0705626259281662, 0.5815176572837153, 0.5875960488417961, -0.17820054924711645, -0.9990232414477314, -0.49625310409382234, 1.0645229366516777, -1.5098752131050561, -0.42153252496880467, -0.3886937922943286, 1.026133272436106, -0.42822963485113064, -0.9346168372838812, -1.0186171457999047, 0.3275533703067123, 1.2486394902352276, 1.4985382411755432, 0.20336081436602027, 1.6052127564433083, -0.2832107440916983, -1.596145704023063, 1.536103270856809, 0.2479806262327784]

run = true
if run == false
    # figure(1)
    # title("original distribution")
    # hist(turb_samples,bins=20)
    difference = zeros(nCycles*naz-1)
    for i = 1:nCycles*naz-1
        difference[i] = turb_samples[i+1]-turb_samples[i]
    end
    # figure(2)
    title("difference distribution")
    hist(difference,bins=20)
    println("finished")
elseif run == true
    start = time()

    global t1_damage
    global t2_damage

    t1_damage = zeros(length(off))
    t2_damage = zeros(length(off))

    for k=1:length(off)

        global t1_damage
        global t2_damage

        println("offset: ", off[k])
        offset = off[k]*rotor_diameter
        turbine_y = [0.0,offset]
        windspeeds = [ws]
        windfarm = ff.WindFarm(turbine_x, turbine_y, turbine_z, turbine_definition_ids, turbine_definitions)
        windfarmstate = ff.SingleWindFarmState(1, turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai, init_inflow_velcities, zeros(nturbines),zeros(nturbines).+ambient_ti,sorted_turbine_index)
        windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, [wind_shear_model])
        pd = ff.WindFarmProblemDescription(windfarm, windresource, [windfarmstate])



        # dams[k] = get_single_damage(ms,pd,2,1,nCycles,az_arr,turb_samples,points_x,points_y,omega_func,pitch_func,turbulence_function,
        #         r,rotor,sections,Rhub,Rtip)

        # # state_damage = get_single_state_damage(ms,pd,1,nCycles,az_arr,
        # #     turb_samples,points_x,points_y,omega_func,pitch_func,turbulence_function,r,rotor,sections,Rhub,Rtip)
        t1 = time()
        total_damage = ff.get_total_farm_damage(ms,pd,nCycles,az_arr,
            turb_samples,points_x,points_y,omega_func,pitch_func,ff.GaussianTI,r,rotor,sections,Rhub,Rtip,precone,tilt,rho,Nlocs=Nlocs)
        # total_damage = ff.get_total_farm_damage(ms,pd,nCycles,az_arr,
        #     turb_samples,points_x,points_y,omega_func,pitch_func,ff.GaussianTI_stanley,r,rotor,sections,Rhub,Rtip,precone,tilt,rho)
        # total_damage = ff.get_total_farm_damage(ms,pd,nCycles,az_arr,
        #     turb_samples,points_x,points_y,omega_func,pitch_func,turbulence_function,r,rotor,sections,Rhub,Rtip,precone,tilt,rho)


        t1_damage[k] = total_damage[1]
        t2_damage[k] = total_damage[2]
        println(time()-t1)
        # println(t2_damage)
    end
    # println((time()-start)/length(off))
    # println("damage: ", dams)



    scatter(off,t1_damage,color="C0")
    scatter(off,t2_damage,color="C3")

     include("FAST_data.jl")
    # FS,FD = fastdata(turb,ws,sep)
    # scatter(FS,FD,color="C2")
    #
    xlabel("offset (D)")
    ylabel("damage")


    legend(["front turbine","back turbine", "FAST"])
    title(sep)
    ylim(-0.1,2.0)
    # ylim(-0.1,1.1)
end
