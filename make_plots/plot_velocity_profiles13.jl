using PyPlot
L = 161
sweep = range(-1.5,stop=1.5,length=L)
# sweep = range(-200.0,stop=200.0,length=L)

sep_arr = [4.0,7.0,10.0]
wind_speed = 13.0

figure(1,figsize=(6.5,4.0))
for k = 1:length(sep_arr)
    sep = sep_arr[k]
    include("model.jl")

    turbine_x = [0.0]
    U_model = zeros(L)
    for i = 1:L
        loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
        U_model[i] = ff.point_velocity(loc, turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                            rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, wind_speed,
                            windresource, model_set)
    end

    # """low TI"""
    U4 = [13.63909594, 13.63579162, 13.63500827, 13.63232426, 13.63699081,
       13.68102547, 13.6788674 , 13.6766322 , 13.632433  , 13.65794068,
       13.66444868, 13.67247957, 13.67093674, 13.68384727, 13.68739964,
       13.69251055, 13.70585433, 13.72161969, 13.72003337, 13.71832895,
       13.71442614, 13.73739779, 13.74517751, 13.75218503, 13.74415944,
       13.76422999, 13.75697665, 13.75025972, 13.70725136, 13.71830588,
       13.73290564, 13.74728443, 13.75441172, 13.80841026, 13.82572541,
       13.8425333 , 13.8332994 , 13.83198378, 13.79356905, 13.75498024,
       13.69989285, 13.60094029, 13.56770909, 13.53451976, 13.56031367,
       13.54144187, 13.51175464, 13.48294562, 13.43342335, 13.41027173,
       13.33722233, 13.26455803, 13.13183749, 12.9949003 , 12.9072052 ,
       12.82040737, 12.76903928, 12.67206233, 12.57129472, 12.47228478,
       12.37788176, 12.25894987, 12.16725912, 12.07595168, 12.01533862,
       11.88628168, 11.82067909, 11.75551134, 11.74784891, 11.63575846,
       11.56920299, 11.50279636, 11.47825011, 11.37535233, 11.32415189,
       11.27212126, 11.26097273, 11.22252821, 11.19873217, 11.17493818,
       11.16894676, 11.15255514, 11.17376735, 11.19507356, 11.26508215,
       11.31417867, 11.34312608, 11.37185455, 11.39585328, 11.38506438,
       11.4364259 , 11.48760359, 11.61679142, 11.68737567, 11.76955696,
       11.85133864, 11.96822117, 12.04162608, 12.13173242, 12.22169736,
       12.3154833 , 12.38910511, 12.47600119, 12.56245351, 12.63278061,
       12.67860718, 12.73309947, 12.7860242 , 12.85484193, 12.89355273,
       12.94412172, 12.99332822, 13.06466397, 13.10760424, 13.13550696,
       13.16327402, 13.17089602, 13.12294524, 13.08846792, 13.05521905,
       13.02878401, 12.93718661, 12.8971448 , 12.85856802, 12.88353884,
       12.91808787, 12.90078904, 12.88324916, 12.83246895, 12.85709744,
       12.84149019, 12.82380249, 12.77411261, 12.78378209, 12.78158748,
       12.77885007, 12.75277598, 12.75092692, 12.77554594, 12.80095547,
       12.82529954, 12.85368309, 12.86722934, 12.8802851 , 12.85758239,
       12.77462328, 12.76136727, 12.74848412, 12.83175268, 12.85603192,
       12.86495807, 12.87475526, 12.89954646, 12.95186179, 12.95687113,
       12.96288831, 12.91325045, 12.9181338 , 12.90056495, 12.88378216,
       12.83207005]

    U7 = [13.14567749, 13.12790195, 13.1300335 , 13.13216504, 13.16103668,
       13.19466337, 13.21797768, 13.24129198, 13.24544946, 13.24020568,
       13.24336102, 13.24651636, 13.25427007, 13.25592945, 13.27591749,
       13.29590553, 13.35088567, 13.43096066, 13.45964036, 13.48832005,
       13.47178166, 13.48492793, 13.49446699, 13.50400605, 13.50509002,
       13.53381905, 13.55524815, 13.57667725, 13.59148699, 13.64273349,
       13.65629134, 13.6698492 , 13.65004067, 13.64940777, 13.65141924,
       13.65343072, 13.65009797, 13.6370076 , 13.64326028, 13.64951297,
       13.66346486, 13.63604499, 13.64491443, 13.65378388, 13.68939149,
       13.68487676, 13.68117483, 13.6774729 , 13.67199048, 13.67735343,
       13.64169074, 13.60602805, 13.53661426, 13.50225225, 13.44811261,
       13.39397297, 13.31687474, 13.24935327, 13.18251993, 13.11568659,
       13.05149976, 12.96421899, 12.88831454, 12.8124101 , 12.73631451,
       12.64439192, 12.59634887, 12.54830582, 12.52233206, 12.48069151,
       12.43313094, 12.38557037, 12.33605876, 12.24225955, 12.182976  ,
       12.12369245, 12.11530157, 12.06393504, 12.0360892 , 12.00824337,
       12.01659619, 11.98983057, 11.9834452 , 11.97705983, 12.00690562,
       12.01056583, 12.0290325 , 12.04749916, 12.08852867, 12.1294286 ,
       12.14295919, 12.15648978, 12.13955307, 12.10900482, 12.1162173 ,
       12.12342978, 12.17203819, 12.19407917, 12.23321221, 12.27234525,
       12.32314673, 12.36398091, 12.42147628, 12.47897165, 12.54254215,
       12.59349872, 12.63819996, 12.68290121, 12.71369313, 12.71116509,
       12.71919825, 12.72723142, 12.75384105, 12.74396044, 12.74743182,
       12.75090321, 12.7936295 , 12.81044924, 12.79743285, 12.78441647,
       12.75993728, 12.73041269, 12.71955756, 12.70870242, 12.71387907,
       12.75701732, 12.75905962, 12.76110191, 12.70752684, 12.69669437,
       12.67257821, 12.64846205, 12.5905612 , 12.5554802 , 12.53207538,
       12.50867056, 12.49654791, 12.49640399, 12.49027294, 12.48414189,
       12.4923132 , 12.48990046, 12.49818875, 12.50647704, 12.52714207,
       12.53698277, 12.54292408, 12.54886539, 12.56047274, 12.59269572,
       12.58592192, 12.57914812, 12.54406926, 12.51566939, 12.4799248 ,
       12.4441802 , 12.40038502, 12.34803677, 12.3539026 , 12.35976842,
       12.40382846]

    U10 = [13.09928979, 13.10551911, 13.11175712, 13.11799514, 13.11266659,
       13.11573774, 13.11880083, 13.12186392, 13.13017987, 13.1422048 ,
       13.15423837, 13.16627194, 13.18540457, 13.22602605, 13.26664931,
       13.30727257, 13.34427692, 13.36808166, 13.3918791 , 13.41567654,
       13.43866866, 13.46687104, 13.49508568, 13.52330032, 13.5611508 ,
       13.58494388, 13.60872166, 13.63249945, 13.66184567, 13.65601144,
       13.65017255, 13.64433367, 13.63422037, 13.65146847, 13.66874011,
       13.68601175, 13.69816383, 13.72023227, 13.74228988, 13.76434749,
       13.78412169, 13.78788071, 13.79163686, 13.79539302, 13.80173131,
       13.78749654, 13.77324051, 13.75898449, 13.74172781, 13.70578315,
       13.66984098, 13.63389881, 13.60080544, 13.55078975, 13.50076265,
       13.45073554, 13.41088645, 13.36621659, 13.32155299, 13.27688939,
       13.22013267, 13.17431527, 13.12849467, 13.08267407, 13.03747107,
       12.9764471 , 12.91542247, 12.85439784, 12.80973003, 12.78141437,
       12.75311512, 12.72481587, 12.68667162, 12.67138321, 12.6560935 ,
       12.64080378, 12.61915222, 12.61083276, 12.60251615, 12.59419954,
       12.58071141, 12.56786502, 12.55500934, 12.54215366, 12.53766968,
       12.50243275, 12.46718279, 12.43193283, 12.40539444, 12.40050376,
       12.39564149, 12.39077921, 12.37308314, 12.41461359, 12.45616411,
       12.49771464, 12.53650455, 12.56782104, 12.59911021, 12.63039938,
       12.65854323, 12.66726121, 12.67598752, 12.68471383, 12.70063021,
       12.69005599, 12.67946675, 12.66887751, 12.67563911, 12.671725  ,
       12.66782224, 12.66391947, 12.66009862, 12.7021962 , 12.74430417,
       12.78641213, 12.82244438, 12.83194089, 12.84141306, 12.85088522,
       12.86212746, 12.82692998, 12.79172185, 12.75651373, 12.72248675,
       12.70539597, 12.68831462, 12.67123328, 12.6452524 , 12.65500027,
       12.66477401, 12.67454776, 12.68212418, 12.68923572, 12.69633636,
       12.70343699, 12.72138691, 12.71330398, 12.70520067, 12.69709736,
       12.68825224, 12.69218721, 12.69614233, 12.70009745, 12.7019253 ,
       12.71685271, 12.73178113, 12.74670955, 12.75345681, 12.75248148,
       12.75149551, 12.75050954, 12.73432721, 12.7150933 , 12.6958612 ,
       12.6766291 , 12.66075846, 12.62806363, 12.59535789, 12.56265216,
       12.55370933]

    if sep == 4.0
        subplot(231)
        title("4 D",fontsize=10)
        plot(sweep,U4)
        ylabel("wind speed (m/s)\nlow turbulence")
    elseif sep == 7.0
        subplot(232)
        title("7 D",fontsize=10)
        plot(sweep,U7)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    elseif sep == 10.0
        subplot(233)
        plot(sweep,U10)
        title("10 D",fontsize=10)
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
    end
    plot(sweep,U_model)
    ylim(5.0,14.0)
end

ambient_ti = [0.08]
windresource = ff.DiscretizedWindResource(winddirections, windspeeds, windprobabilities, measurementheight, air_density, ambient_ti, wind_shear_model)
for k = 1:length(sep_arr)
    sep = sep_arr[k]


    turbine_x = [0.0]
    U_model = zeros(L)
    for i = 1:L
        loc = [sep*rotor_diameter[1],sweep[i]*rotor_diameter[1],hub_height[1]]
        U_model[i] = ff.point_velocity(loc, turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                            rotor_diameter, hub_height, ambient_ti[1], sorted_turbine_index, wind_speed,
                            windresource, model_set)
    end

    # """high TI"""
    U4 = [13.63909594, 13.63579162, 13.63500827, 13.63232426, 13.63699081,
       13.68102547, 13.6788674 , 13.6766322 , 13.632433  , 13.65794068,
       13.66444868, 13.67247957, 13.67093674, 13.68384727, 13.68739964,
       13.69251055, 13.70585433, 13.72161969, 13.72003337, 13.71832895,
       13.71442614, 13.73739779, 13.74517751, 13.75218503, 13.74415944,
       13.76422999, 13.75697665, 13.75025972, 13.70725136, 13.71830588,
       13.73290564, 13.74728443, 13.75441172, 13.80841026, 13.82572541,
       13.8425333 , 13.8332994 , 13.83198378, 13.79356905, 13.75498024,
       13.69989285, 13.60094029, 13.56770909, 13.53451976, 13.56031367,
       13.54144187, 13.51175464, 13.48294562, 13.43342335, 13.41027173,
       13.33722233, 13.26455803, 13.13183749, 12.9949003 , 12.9072052 ,
       12.82040737, 12.76903928, 12.67206233, 12.57129472, 12.47228478,
       12.37788176, 12.25894987, 12.16725912, 12.07595168, 12.01533862,
       11.88628168, 11.82067909, 11.75551134, 11.74784891, 11.63575846,
       11.56920299, 11.50279636, 11.47825011, 11.37535233, 11.32415189,
       11.27212126, 11.26097273, 11.22252821, 11.19873217, 11.17493818,
       11.16894676, 11.15255514, 11.17376735, 11.19507356, 11.26508215,
       11.31417867, 11.34312608, 11.37185455, 11.39585328, 11.38506438,
       11.4364259 , 11.48760359, 11.61679142, 11.68737567, 11.76955696,
       11.85133864, 11.96822117, 12.04162608, 12.13173242, 12.22169736,
       12.3154833 , 12.38910511, 12.47600119, 12.56245351, 12.63278061,
       12.67860718, 12.73309947, 12.7860242 , 12.85484193, 12.89355273,
       12.94412172, 12.99332822, 13.06466397, 13.10760424, 13.13550696,
       13.16327402, 13.17089602, 13.12294524, 13.08846792, 13.05521905,
       13.02878401, 12.93718661, 12.8971448 , 12.85856802, 12.88353884,
       12.91808787, 12.90078904, 12.88324916, 12.83246895, 12.85709744,
       12.84149019, 12.82380249, 12.77411261, 12.78378209, 12.78158748,
       12.77885007, 12.75277598, 12.75092692, 12.77554594, 12.80095547,
       12.82529954, 12.85368309, 12.86722934, 12.8802851 , 12.85758239,
       12.77462328, 12.76136727, 12.74848412, 12.83175268, 12.85603192,
       12.86495807, 12.87475526, 12.89954646, 12.95186179, 12.95687113,
       12.96288831, 12.91325045, 12.9181338 , 12.90056495, 12.88378216,
       12.83207005]

    U7 = [13.14567749, 13.12790195, 13.1300335 , 13.13216504, 13.16103668,
       13.19466337, 13.21797768, 13.24129198, 13.24544946, 13.24020568,
       13.24336102, 13.24651636, 13.25427007, 13.25592945, 13.27591749,
       13.29590553, 13.35088567, 13.43096066, 13.45964036, 13.48832005,
       13.47178166, 13.48492793, 13.49446699, 13.50400605, 13.50509002,
       13.53381905, 13.55524815, 13.57667725, 13.59148699, 13.64273349,
       13.65629134, 13.6698492 , 13.65004067, 13.64940777, 13.65141924,
       13.65343072, 13.65009797, 13.6370076 , 13.64326028, 13.64951297,
       13.66346486, 13.63604499, 13.64491443, 13.65378388, 13.68939149,
       13.68487676, 13.68117483, 13.6774729 , 13.67199048, 13.67735343,
       13.64169074, 13.60602805, 13.53661426, 13.50225225, 13.44811261,
       13.39397297, 13.31687474, 13.24935327, 13.18251993, 13.11568659,
       13.05149976, 12.96421899, 12.88831454, 12.8124101 , 12.73631451,
       12.64439192, 12.59634887, 12.54830582, 12.52233206, 12.48069151,
       12.43313094, 12.38557037, 12.33605876, 12.24225955, 12.182976  ,
       12.12369245, 12.11530157, 12.06393504, 12.0360892 , 12.00824337,
       12.01659619, 11.98983057, 11.9834452 , 11.97705983, 12.00690562,
       12.01056583, 12.0290325 , 12.04749916, 12.08852867, 12.1294286 ,
       12.14295919, 12.15648978, 12.13955307, 12.10900482, 12.1162173 ,
       12.12342978, 12.17203819, 12.19407917, 12.23321221, 12.27234525,
       12.32314673, 12.36398091, 12.42147628, 12.47897165, 12.54254215,
       12.59349872, 12.63819996, 12.68290121, 12.71369313, 12.71116509,
       12.71919825, 12.72723142, 12.75384105, 12.74396044, 12.74743182,
       12.75090321, 12.7936295 , 12.81044924, 12.79743285, 12.78441647,
       12.75993728, 12.73041269, 12.71955756, 12.70870242, 12.71387907,
       12.75701732, 12.75905962, 12.76110191, 12.70752684, 12.69669437,
       12.67257821, 12.64846205, 12.5905612 , 12.5554802 , 12.53207538,
       12.50867056, 12.49654791, 12.49640399, 12.49027294, 12.48414189,
       12.4923132 , 12.48990046, 12.49818875, 12.50647704, 12.52714207,
       12.53698277, 12.54292408, 12.54886539, 12.56047274, 12.59269572,
       12.58592192, 12.57914812, 12.54406926, 12.51566939, 12.4799248 ,
       12.4441802 , 12.40038502, 12.34803677, 12.3539026 , 12.35976842,
       12.40382846]

    U10 = [13.09928979, 13.10551911, 13.11175712, 13.11799514, 13.11266659,
       13.11573774, 13.11880083, 13.12186392, 13.13017987, 13.1422048 ,
       13.15423837, 13.16627194, 13.18540457, 13.22602605, 13.26664931,
       13.30727257, 13.34427692, 13.36808166, 13.3918791 , 13.41567654,
       13.43866866, 13.46687104, 13.49508568, 13.52330032, 13.5611508 ,
       13.58494388, 13.60872166, 13.63249945, 13.66184567, 13.65601144,
       13.65017255, 13.64433367, 13.63422037, 13.65146847, 13.66874011,
       13.68601175, 13.69816383, 13.72023227, 13.74228988, 13.76434749,
       13.78412169, 13.78788071, 13.79163686, 13.79539302, 13.80173131,
       13.78749654, 13.77324051, 13.75898449, 13.74172781, 13.70578315,
       13.66984098, 13.63389881, 13.60080544, 13.55078975, 13.50076265,
       13.45073554, 13.41088645, 13.36621659, 13.32155299, 13.27688939,
       13.22013267, 13.17431527, 13.12849467, 13.08267407, 13.03747107,
       12.9764471 , 12.91542247, 12.85439784, 12.80973003, 12.78141437,
       12.75311512, 12.72481587, 12.68667162, 12.67138321, 12.6560935 ,
       12.64080378, 12.61915222, 12.61083276, 12.60251615, 12.59419954,
       12.58071141, 12.56786502, 12.55500934, 12.54215366, 12.53766968,
       12.50243275, 12.46718279, 12.43193283, 12.40539444, 12.40050376,
       12.39564149, 12.39077921, 12.37308314, 12.41461359, 12.45616411,
       12.49771464, 12.53650455, 12.56782104, 12.59911021, 12.63039938,
       12.65854323, 12.66726121, 12.67598752, 12.68471383, 12.70063021,
       12.69005599, 12.67946675, 12.66887751, 12.67563911, 12.671725  ,
       12.66782224, 12.66391947, 12.66009862, 12.7021962 , 12.74430417,
       12.78641213, 12.82244438, 12.83194089, 12.84141306, 12.85088522,
       12.86212746, 12.82692998, 12.79172185, 12.75651373, 12.72248675,
       12.70539597, 12.68831462, 12.67123328, 12.6452524 , 12.65500027,
       12.66477401, 12.67454776, 12.68212418, 12.68923572, 12.69633636,
       12.70343699, 12.72138691, 12.71330398, 12.70520067, 12.69709736,
       12.68825224, 12.69218721, 12.69614233, 12.70009745, 12.7019253 ,
       12.71685271, 12.73178113, 12.74670955, 12.75345681, 12.75248148,
       12.75149551, 12.75050954, 12.73432721, 12.7150933 , 12.6958612 ,
       12.6766291 , 12.66075846, 12.62806363, 12.59535789, 12.56265216,
       12.55370933]

    if sep == 4.0
        subplot(234)
        plot(sweep,U4)
        xlabel("offset (D)")
        ylabel("wind speed (m/s)\nhigh turbulence")
        plot(sweep,U_model)
    elseif sep == 7.0
        subplot(235)
        plot(sweep,U7)
        xlabel("offset (D)")
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
        plot(sweep,U_model)
    elseif sep == 10.0
        subplot(236)
        plot(sweep,U10,label="SOWFA")
        xlabel("offset (D)")
        tick_params(
            axis="y",          # changes apply to the x-axis
            which="both",      # both major and minor ticks are affected
            left=false,      # ticks along the bottom edge are off
            top=false,         # ticks along the top edge are off
            labelleft=false) # labels along the bottom edge are off
        plot(sweep,U_model,label="wake model")
        legend(loc=4)

    end

    ylim(5.0,14.0)
end

# subplots_adjust(top=0.91,bottom=0.13,left=0.11,right=0.99,wspace=0.05)
# savefig("velocity_profiles.pdf",transparent=true)

tight_layout()
