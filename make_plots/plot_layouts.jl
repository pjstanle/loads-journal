using FlowFarm
const ff = FlowFarm
using DelimitedFiles
using FLOWMath
using CCBlade
using PyPlot


include("../model_lowTI.jl")

bx = boundary_vertices[:,1]
by = boundary_vertices[:,2]
append!(bx,bx[1])
append!(by,by[1])

figure(1,figsize=(6.5,3.5))

turbine_x = readdlm("../no_loads/x_no_loads170.txt")[:,1]
turbine_y = readdlm("../no_loads/y_no_loads170.txt")[:,1]
subplot(121)

plot(bx,by,"--",color="black",linewidth=0.5)
for i = 1:length(turbine_x)
    plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C0"))
end
title("no damage constraints",y=0.9,fontsize=10)

axis("equal")
axis("off")
text(2111.635185911305,-400,"AEP: 1300.067 GWh",horizontalalignment="center",fontsize=10)


turbine_x = readdlm("../with_loads/x_with_loads170.txt")[:,1]
turbine_y = readdlm("../with_loads/y_with_loads170.txt")[:,1]
#
subplot(122)

plot(bx,by,"--",color="black",linewidth=0.5)
for i = 1:length(turbine_x)
    plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C1"))
end
title("with damage constraints",y=0.9,fontsize=10)

axis("equal")
axis("off")
text(2111.635185911305,-400,"AEP: 1291.596 GWh",horizontalalignment="center",fontsize=10)

subplots_adjust(top=0.93,bottom=0.01,left=0.01,right=0.99,wspace=0.05)
#
#
# tight_layout()
#
savefig("opt_layouts.pdf",transparent=true)
