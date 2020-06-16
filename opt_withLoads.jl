using Snopt
using DelimitedFiles
using FLOWMath
using FlowFarm
using CCBlade

import ForwardDiff

function boundary_wrapper(x)
    global boundary_vertices
    global boundary_normals
    global scale
    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines].*scale
    turbine_y = x[nturbines+1:end].*scale
    return ff.windfarm_boundary(boundary_vertices,boundary_normals,turbine_x,turbine_y) .* 10.0
end

function spacing_wrapper(x)
    global rotor_diameter
    global scale
    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines].*scale
    turbine_y = x[nturbines+1:end].*scale
    return 2.0*rotor_diameter[1] .- ff.turbine_spacing(turbine_x,turbine_y)
end

function aep_wrapper(x)
    global turbine_z
    global rotor_diameter
    global hub_height
    global turbine_yaw
    global turbine_ai
    global ct_model
    global generator_efficiency
    global cut_in_speed
    global cut_out_speed
    global rated_speed
    global rated_power
    global windresource
    global power_model
    global model_set
    global rotor_points_y
    global rotor_points_z

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines] .* scale
    turbine_y = x[nturbines+1:end] .* scale

    AEP = ff.calculate_aep(turbine_x, turbine_y, turbine_z, rotor_diameter,
                hub_height, turbine_yaw, turbine_ai, ct_model, generator_efficiency, cut_in_speed,
                cut_out_speed, rated_speed, rated_power, windresource, power_model, model_set,
                rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z)/1e11
    return [AEP]
end


function damage_wrapper(x)
    global turbine_z
    global rotor_diameter
    global hub_height
    global turbine_yaw
    global turbine_ai
    global ct_model
    global nCycles
    global az_arr
    global turb_samples
    global flap_func
    global edge_func
    global omega_func
    global pitch_func
    global turbulence_func
    global r
    global rotor
    global sections
    global Rhub
    global Rtip
    global precone
    global tilt
    global air_density
    global windresource
    global model_set
    global Nlocs
    global fos
    global rotor_points_y
    global rotor_points_z
    global div_sigma
    global div_ti
    global max_damage

    nturbines = Int(length(x)/2)
    turbine_x = x[1:nturbines] .* scale
    turbine_y = x[nturbines+1:end] .* scale

    # damage = ff.get_total_farm_damage_surr(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,
    #         turbine_ai,ct_model,nCycles,az_arr,turb_samples,flap_func,edge_func,omega_func,pitch_func,
    #         turbulence_func,r,rotor,sections,Rhub,Rtip,precone,tilt,air_density,windresource,model_set;
    #         Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,
    #         div_sigma=div_sigma,div_ti=div_ti)
    damage = ff.get_total_farm_damage_super(turbine_x,turbine_y,turbine_z,rotor_diameter,hub_height,turbine_yaw,
            turbine_ai,ct_model,nCycles,az_arr,turb_samples,omega_func,pitch_func,turbulence_func,r,sections,
            Rhub,Rtip,precone,tilt,windresource,model_set;
            Nlocs=Nlocs,fos=fos,rotor_sample_points_y=rotor_points_y,rotor_sample_points_z=rotor_points_z,
                    div_sigma=div_sigma,div_ti=div_ti)

    return (damage .- max_damage).*10.0
end

function wind_farm_opt(x)
    # t1 = time()
    spacing_con = spacing_wrapper(x)
    # println("spacing call: ", time()-t1)
    # t2 = time()
    ds_dx = ForwardDiff.jacobian(spacing_wrapper,x)
    # println("spacing gradient: ", time()-t2)
    # t3 = time()

    boundary_con = boundary_wrapper(x)
    # println("boundary call: ", time()-t3)
    # t4 = time()
    db_dx = ForwardDiff.jacobian(boundary_wrapper,x)
    # println("boundary gradient: ", time()-t4)
    # t5 = time()

    damage_con = damage_wrapper(x)
    # println("damage call: ", time()-t5)
    println("damage: ", maximum(damage_con))
    # t6 = time()
    dd_dx = ForwardDiff.jacobian(damage_wrapper,x)
    # println("damage gradient: ", time()-t6)


    c = [spacing_con;boundary_con;damage_con]
    dcdx = [ds_dx;db_dx;dd_dx]
    # println("shape c: ", size(c))
    # println("shape dcdx: ", size(dcdx))
    # c = [spacing_con;boundary_con]
    # dcdx = [ds_dx;db_dx]

    # t7 = time()
    AEP = -aep_wrapper(x)[1]
    println("AEP: ", -AEP)
    # println("AEP call: ", time()-t7)
    # t8 = time()
    dAEP_dx = -ForwardDiff.jacobian(aep_wrapper,x)
    # println("AEP gradient: ", time()-t8)

    fail = false
    return AEP, c, dAEP_dx, dcdx, fail
end



global turbine_z
global rotor_diameter
global hub_height
global turbine_yaw
global turbine_ai
global ct_model
global generator_efficiency
global cut_in_speed
global cut_out_speed
global rated_speed
global rated_power
global windresource
global power_model
global model_set
global rotor_points_y
global rotor_points_z

global boundary_center
global boundary_radius
global scale


global nCycles
global az_arr
global turb_samples
global omega_func
global pitch_func
global turbulence_func
global r
global rotor
global sections
global Rhub
global Rtip
global precone
global tilt
global air_density
global Nlocs
global fos
global div_sigma
global div_ti
global max_damage

global flap_func
global edge_func

max_damage = 0.2
# max_damage = 0.0
div_sigma=2.5
div_ti=1.2
fos = 1.25
scale = 10.0
include("model_lowTI.jl")

test_call = false
if test_call == true
    start_x = turbine_x = readdlm("no_loads/x_no_loads1.txt")[:,1]
    start_y = turbine_y = readdlm("no_loads/y_no_loads1.txt")[:,1]
    x = [copy(start_x);copy(start_y)]./scale
    AEP, c, dAEP_dx, dcdx, fail = wind_farm_opt(x)
    println(AEP)
end


global filenum
global AEP1
global AEP2
global AEP3
global AEP4
global AEP5

AEP1 = 0.0
AEP2 = 0.0
AEP3 = 0.0
AEP4 = 0.0
AEP5 = 0.0

filenum = 170

optimize = true
if optimize == true
    for k = 1:25
        global filenum
        global AEP1
        global AEP2
        global AEP3
        global AEP4
        global AEP5
        start_x = readdlm("no_loads/x_no_loads$filenum.txt")[:,1]
        start_y = readdlm("no_loads/y_no_loads$filenum.txt")[:,1]
        x = [copy(start_x);copy(start_y)]./scale

        println("start: ", aep_wrapper(x))

        lb = zeros(length(x))
        ub = zeros(length(x)) .+6.30021755e+01*diam*frac
        options = Dict{String, Any}()
        options["Derivative option"] = 1
        options["Verify level"] = 0
        options["Major optimality tolerance"] = 1e-4
        options["Major iteration limit"] = 1e6
        options["Summary file"] = "snopt-summary.out"
        options["Print file"] = "snopt-print.out"

        t1 = time()
        xopt, fopt, info = snopt(wind_farm_opt, x, lb, ub, options)
        println("Finished: ", time()-t1)
        # println("xopt: ", xopt)
        println("opt AEP: ", -fopt)
        println("info: ", info)

        opt_x = copy(xopt[1:nturbines]).*scale
        opt_y = copy(xopt[nturbines+1:end]).*scale

        optAEP = -fopt
        open("AEP_with_loads.txt", "a") do io
                writedlm(io, optAEP)
        end

        open("x_with_loads$filenum.txt", "w") do io
                writedlm(io, opt_x)
        end

        open("y_with_loads$filenum.txt", "w") do io
                writedlm(io, opt_y)
        end

        if optAEP > AEP1
            AEP5 = copy(AEP4)
            AEP4 = copy(AEP3)
            AEP3 = copy(AEP2)
            AEP2 = copy(AEP1)
            AEP1 = copy(optAEP)
        elseif optAEP > AEP2
            AEP5 = copy(AEP4)
            AEP4 = copy(AEP3)
            AEP3 = copy(AEP2)
            AEP2 = copy(optAEP)
        elseif optAEP > AEP3
            AEP5 = copy(AEP4)
            AEP4 = copy(AEP3)
            AEP3 = copy(optAEP)
        elseif optAEP > AEP4
            AEP5 = copy(AEP4)
            AEP4 = copy(optAEP)
        elseif optAEP > AEP5
            AEP5 = copy(optAEP)
        end

        println("best AEPs: ", AEP1, ", ", AEP2, ", ", AEP3, ", ", AEP4, ", ", AEP5)
        filenum += 1
    end
end



# bx = boundary_vertices[:,1]
# by = boundary_vertices[:,2]
# append!(bx,bx[1])
# append!(by,by[1])
# plot(bx,by,color="black")
#
# for i = 1:length(turbine_x)
#     plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C1"))
# end





# turbine_x = copy(x[1:nturbines]).*scale
# turbine_y = copy(x[nturbines+1:end]).*scale
# area = zeros(length(turbine_x)) .+ pi*(rotor_diameter[1]/2.0)^2
# for i = 1:length(turbine_x)
#     plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[1]/2.0, fill=false,color="C0"))
# end
#
# axis("square")
# xlim(-boundary_radius-200,boundary_radius+200)
# ylim(-boundary_radius-200,boundary_radius+200)




# check_gradients = true
# if check_gradients == true
#     start_x = rand(nturbines).*(maximum(turbine_x)-minimum(turbine_x)).+minimum(turbine_x)
#     start_y = rand(nturbines).*(maximum(turbine_y)-minimum(turbine_y)).+minimum(turbine_y)
#     x = [copy(start_x);copy(start_y)]./scale
#
#     AEP, c, dAEP_dx, dcdx, fail = wind_farm_opt(x)
#
#     step = 1e-4
#
#     AEP_FD = zeros(1,2*nturbines)
#     dcdx_FD = zeros(length(c),)
#     # for i = 1:2*nturbines
#     #     x_temp = copy(x)
#     #     x_temp[i] += step
#     #     AEP_temp, c_temp, _, _, _ = wind_farm_opt(x)
#     # end
#
# end
# println("done")
