using FlowFarm
const ff = FlowFarm
using DelimitedFiles
using FLOWMath
using CCBlade
using PyPlot


include("../model_lowTI_NEW.jl")

bx = boundary_vertices[:,1]
by = boundary_vertices[:,2]
append!(bx,bx[1])
append!(by,by[1])

# figure(1,figsize=(6.5,3.5))
figure(1,figsize=(6.5,2.75))

turbine_x = readdlm("second_revision_aep/x_40_small_5.txt")[:,1]
turbine_y = readdlm("second_revision_aep/y_40_small_5.txt")[:,1]
subplot(121)
grid(alpha=0.5)
plot(bx,by,"--",color="black",linewidth=0.5)
# R = 990.4415496916475
# plt.gcf().gca().add_artist(plt.Circle((0.0,0.0), R, fill=false,color="black",linestyle="--"))

damage_array_aep = [0.02967349527785025, 0.03045963958432398, 0.03123606873204911,
        0.03315114330625044, 0.03524857189885387, 0.0327565045868454,
        0.030209460999192122, 0.028125368151581204, 0.031243102435033164,
        0.0323319732958887, 0.03264430038676447, 0.04033490118652246,
        0.03369010515661054, 0.02841069033509447, 0.03158096200302084,
        0.03058596823584107, 0.0319436337850457, 0.02909825880248888,
        0.03239058954591872, 0.04265659601630978, 0.0351743952053305,
        0.03868961874528306, 0.030658728574667313, 0.03737869976773521,
        0.031366677041051526, 0.029240355151596897, 0.02984277333955222,
        0.03194894838941491, 0.04140118425419409, 0.03132268013646172,
        0.034364249847715564, 0.03524906786672994, 0.03012214153868347,
        0.03396317702886598, 0.030399390549366405, 0.03694240188730925,
        0.0340382961143281, 0.04277141896198941, 0.029899611109220937,
        0.03084128190481184]

damage_array_loads = [0.029258614991828406, 0.028099036975207024, 0.030505771870545206,
        0.030796958471666646, 0.030020642871958512, 0.028239219432861378,
        0.030380712149452992, 0.02926508424706444, 0.027761390343614155,
        0.030722871585321738, 0.030815216140668455, 0.030809354807089018,
        0.03060390731800522, 0.022082173075824493, 0.030054002490703086,
        0.03074576366394852, 0.030164634990028086, 0.030782967066622553,
        0.03083831598159119, 0.03080584809140598, 0.030792751795152142,
        0.030732449533685483, 0.026849974531986828, 0.026644575922698522,
        0.026681166081859917, 0.026504559747966, 0.02909493510383671,
        0.03001210807496786, 0.03080164957166409, 0.030791596505594453,
        0.029673905408370675, 0.030808922402014757, 0.02815047568132644,
        0.030796983244357257, 0.03025741914140329, 0.03080693128229611,
        0.030629213336744076, 0.030797604627671043, 0.02629022105849065,
        0.030726411265189692]

for i = 1:length(turbine_x)
    if damage_array_aep[i] > maximum(damage_array_loads)
        plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill="C2",color="C2"))
    else
        plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C0"))
    end
end
title("no damage constraints",y=0.95,fontsize=10)

ylim(-500,2500)
# ylim(-R-100,R+100)
# xlim(-R-100,R+100)
axis("equal")
gca().spines["right"].set_visible(false)
gca().spines["top"].set_visible(false)
gca().spines["left"].set_visible(false)
gca().spines["bottom"].set_visible(false)
tick_params(
    which="both",      # both major and minor ticks are affected
    bottom=false,      # ticks along the bottom edge are off
    top=false,         # ticks along the top edge are off
    left=false,
    right=false,
    labelleft=false,
    labelbottom=false) # labels along the bottom edge are off





# text(1500,-300,"AEP: 1129 GWh",horizontalalignment="center",fontsize=10)
#
turbine_x = readdlm("second_revision_loads/x_0.72.txt")[:,1].*10
turbine_y = readdlm("second_revision_loads/y_0.72.txt")[:,1].*10
# #
subplot(122)
grid(alpha=0.5)
plot(bx,by,"--",color="black",linewidth=0.5)

for i = 1:length(turbine_x)
    if i == 21
        plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C1"))
    else
        plt.gcf().gca().add_artist(plt.Circle((turbine_x[i],turbine_y[i]), rotor_diameter[i]/2.0, fill=false,color="C1"))
    end
end
title("with damage constraints",y=0.95,fontsize=10)
#
#
ylim(-500,2500)

axis("equal")
gca().spines["right"].set_visible(false)
gca().spines["top"].set_visible(false)
gca().spines["left"].set_visible(false)
gca().spines["bottom"].set_visible(false)
tick_params(
    which="both",      # both major and minor ticks are affected
    bottom=false,      # ticks along the bottom edge are off
    top=false,         # ticks along the top edge are off
    left=false,
    right=false,
    labelleft=false,
    labelbottom=false) # labels along the bottom edge are off
#
# text(1500,-300,"AEP: 1069 GWh",horizontalalignment="center",fontsize=10)
#
subplots_adjust(top=0.93,bottom=0.01,left=0.01,right=0.99,wspace=0.05)
# #
# #
# tight_layout()
# #
# # savefig("opt_layouts2.pdf",transparent=true)
