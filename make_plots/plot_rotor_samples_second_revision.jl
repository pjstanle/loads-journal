using FlowFarm
const ff = FlowFarm
using DelimitedFiles
using FLOWMath
using CCBlade
using PyPlot
include("../model_lowTI_NEW.jl")

function sunflower_points(n, alpha=1.0)
    # this function generates n points within a circle in a sunflower seed pattern
    # the code is based on the example found at
    # https://stackoverflow.com/questions/28567166/uniformly-distribute-x-points-inside-a-circle

    function radius(k, n, b)
        if (k + 1) > n - b
            r = 1.0 # put on the boundary
        else
            r = sqrt((k + 1.0) - 1.0 / 2.0) / sqrt(n - (b + 1.0) / 2.0)  # apply squareroot
        end
        return r
    end


    x = zeros(n)
    y = zeros(n)

    b = round(alpha * sqrt(n)) # number of boundary points

    phi = (sqrt(5.0) + 1.0) / 2.0  # golden ratio

    for k = 1:n
        r = radius(k, n, b)

        theta = 2.0 * pi * (k+1) / phi^2

        x[k] = r * cos(theta)
        y[k] = r * sin(theta)
    end

    return x, y
end


da = 10.0

figure(1,figsize=(6.0,1.75))

ax1 = subplot(141)

bladeX = [3.,7.,10.,15.,20.,25.,30.,35.,30.,25.,20.,15.,10.,5.,3.,3.]
bladeY = [0.,0.,0.8,1.5,1.7,1.9,2.1,2.3,2.4,2.4,2.4,2.4,2.4,2.4,2.4,0.].-1.5
#
H = 110.
D = 130.
R = 65.
d = [6.3,5.5,4.]


ax1.add_artist(plt.Circle((0.,H), R, fill=false, color="C0",  linestyle = "--", linewidth=1.2*1.5))

c1 = R/35.
#
#add blades
ax1.add_artist(plt.Circle((0.0,H), 3*c1, color="C0", fill=false, linewidth=1*1.5))
#
angle1 = 5.

blade1X = bladeX*cos(deg2rad(angle1))-bladeY*sin(deg2rad(angle1))
blade1Y = bladeX*sin(deg2rad(angle1))+bladeY*cos(deg2rad(angle1))

blade2X = bladeX*cos(deg2rad(angle1+120.))-bladeY*sin(deg2rad(angle1+120.))
blade2Y = bladeX*sin(deg2rad(angle1+120.))+bladeY*cos(deg2rad(angle1+120.))

blade3X = bladeX*cos(deg2rad(angle1+240.))-bladeY*sin(deg2rad(angle1+240.))
blade3Y = bladeX*sin(deg2rad(angle1+240.))+bladeY*cos(deg2rad(angle1+240.))
#
ax1.plot(blade1X.*c1.+0.0, blade1Y.*c1.+H, linewidth=1*1.5, color="C0")
ax1.plot(blade2X.*c1.+0.0, blade2Y.*c1.+H, linewidth=1*1.5, color="C0")
ax1.plot(blade3X.*c1.+0.0, blade3Y.*c1.+H, linewidth=1*1.5, color="C0")
#
x_sample = [0]
y_sample = [0].+H
ax1.plot(x_sample,y_sample,"o",color="C1",markersize=3)
ax1.text(0.0,H+7.0,"(0,0)",horizontalalignment="center",fontsize=8)
ax1.axis("equal")
ax1.axis("off")
# ax1.set_xlim(-R-da,R+da)
ax1.set_ylim(H-R-da,H+R+da)







ax2 = subplot(142)

bladeX = [3.,7.,10.,15.,20.,25.,30.,35.,30.,25.,20.,15.,10.,5.,3.,3.]
bladeY = [0.,0.,0.8,1.5,1.7,1.9,2.1,2.3,2.4,2.4,2.4,2.4,2.4,2.4,2.4,0.].-1.5
#
H = 110.
D = 130.
R = 65.
d = [6.3,5.5,4.]


ax2.add_artist(plt.Circle((0.,H), R, fill=false, color="C0",  linestyle = "--", linewidth=1.2*1.5))

c1 = R/35.

#
#add blades
ax2.add_artist(plt.Circle((0.0,H), 3*c1, color="C0", fill=false, linewidth=1*1.5))
#
angle1 = 25.

blade1X = bladeX*cos(deg2rad(angle1))-bladeY*sin(deg2rad(angle1))
blade1Y = bladeX*sin(deg2rad(angle1))+bladeY*cos(deg2rad(angle1))

blade2X = bladeX*cos(deg2rad(angle1+120.))-bladeY*sin(deg2rad(angle1+120.))
blade2Y = bladeX*sin(deg2rad(angle1+120.))+bladeY*cos(deg2rad(angle1+120.))

blade3X = bladeX*cos(deg2rad(angle1+240.))-bladeY*sin(deg2rad(angle1+240.))
blade3Y = bladeX*sin(deg2rad(angle1+240.))+bladeY*cos(deg2rad(angle1+240.))
#
ax2.plot(blade1X.*c1.+0.0, blade1Y.*c1.+H, linewidth=1*1.5, color="C0")
ax2.plot(blade2X.*c1.+0.0, blade2Y.*c1.+H, linewidth=1*1.5, color="C0")
ax2.plot(blade3X.*c1.+0.0, blade3Y.*c1.+H, linewidth=1*1.5, color="C0")
#
x_sample = [0.69*R,0.,-0.69*R,0.]
y_sample = [0.,0.69*R,0.,-0.69*R].+H
ax2.plot(x_sample,y_sample,"o",color="C1",markersize=3)
#
ax2.text(0.69*R,H+7.0,"(0.69,0)",horizontalalignment="center",fontsize=8)
ax2.text(0.0,H+0.69*R+7.0,"(0,0.69)",horizontalalignment="center",fontsize=8)
ax2.text(-0.69*R,H+7.0,"(-0.69,0)",horizontalalignment="center",fontsize=8)
ax2.text(0.0,H-0.69*R+7.0,"(0,-0.69)",horizontalalignment="center",fontsize=8)
#
ax2.axis("equal")
ax2.axis("off")
#
# ax2.set_xlim(-R-da,R+da)
ax2.set_ylim(H-R-da,H+R+da)





ax3 = subplot(143)

sy100,sz100 = sunflower_points(100)
sz100 = sz100.*R.+H
sy100 = sy100.*R

bladeX = [3.,7.,10.,15.,20.,25.,30.,35.,30.,25.,20.,15.,10.,5.,3.,3.]
bladeY = [0.,0.,0.8,1.5,1.7,1.9,2.1,2.3,2.4,2.4,2.4,2.4,2.4,2.4,2.4,0.].-1.5
#
H = 110.
D = 130.
R = 65.
d = [6.3,5.5,4.]


ax3.add_artist(plt.Circle((0.,H), R, fill=false, color="C0",  linestyle = "--", linewidth=1.2*1.5))

c1 = R/35.

#
#add blades
ax3.add_artist(plt.Circle((0.0,H), 3*c1, color="C0", fill=false, linewidth=1*1.5))
#
angle1 = -25.

blade1X = bladeX*cos(deg2rad(angle1))-bladeY*sin(deg2rad(angle1))
blade1Y = bladeX*sin(deg2rad(angle1))+bladeY*cos(deg2rad(angle1))

blade2X = bladeX*cos(deg2rad(angle1+120.))-bladeY*sin(deg2rad(angle1+120.))
blade2Y = bladeX*sin(deg2rad(angle1+120.))+bladeY*cos(deg2rad(angle1+120.))

blade3X = bladeX*cos(deg2rad(angle1+240.))-bladeY*sin(deg2rad(angle1+240.))
blade3Y = bladeX*sin(deg2rad(angle1+240.))+bladeY*cos(deg2rad(angle1+240.))
#
ax3.plot(blade1X.*c1.+0.0, blade1Y.*c1.+H, linewidth=1*1.5, color="C0")
ax3.plot(blade2X.*c1.+0.0, blade2Y.*c1.+H, linewidth=1*1.5, color="C0")
ax3.plot(blade3X.*c1.+0.0, blade3Y.*c1.+H, linewidth=1*1.5, color="C0")
#
ax3.plot(sy100,sz100,"o",color="C1",markersize=3)
#
#
ax3.axis("equal")
ax3.axis("off")
#
# ax3.set_xlim(-R-da,R+da)
ax3.set_ylim(H-R-da,H+R+da)
#



ax4 = subplot(144)

freestream = 12.366698488144875
turbine_x = [0.0]
turbine_y = [0.0]
turbine_z = [0.0]
hub_height = [H]
turbine_yaw = [0.0]
rotor_diameter = [D]
turbine_ct = [ff.calculate_ct(freestream, ct_model[1])]
turbine_ai = [ff._ct_to_axial_ind_func(turbine_ct[1])]
ambient_ti = 0.056
turbine_local_ti = [0.0]
sorted_turbine_index = [1]
wtvelocities = [freestream]
turbine_local_ti = [0.056]

locx = 5*D
locy = 0.5*D
locz = H

sy100,sz100 = sunflower_points(100)
sz100 = sz100.*R.+H
sy100 = sy100.*R

sy4 = [0.0,0.69,0.0,-0.69]
sz4 = [-0.69,0.0,0.69,0.0]
sz4 = sz4.*R.+H
sy4 = sy4.*R

sy1 = [0.0]
sz1 = [H]


nys = 100
yloc = range(-D,stop=D,length=nys)

v100 = zeros(nys)
v4 = zeros(nys)
v1 = zeros(nys)

for i=1:nys
    s = 0.0
    for j=1:100
        s += ff.point_velocity(locx, sy100[j]+yloc[i], sz100[j], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                        rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, wtvelocities,
                        windresource, model_set)
    end
    v100[i] = s/100

    s = 0.0
    for j=1:4
        s += ff.point_velocity(locx, sy4[j]+yloc[i], sz4[j], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                        rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, wtvelocities,
                        windresource, model_set)
    end
    v4[i] = s/4


    v1[i] += ff.point_velocity(locx, sy1[1]+yloc[i], sz1[1], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
                        rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, wtvelocities,
                        windresource, model_set)

end

# plt.plot(sx.*R.+R,sy.*R.+H,"o")

# plt.gca().axis("equal")
# plt.gca().axis("off")



ax4.plot(yloc/D,v100./freestream,color="black",label="100 points")
ax4.plot(yloc/D,v4./freestream,color="C0","--",label="4 points")
ax4.plot(yloc/D,v1./freestream,color="C1",label="1 point")

ax4.set_xlabel("offset (D)",fontsize=8,labelpad=-0.05)
ax4.set_ylabel("normalized average\nrotor speed",fontsize=8,labelpad=-0.05)


ax4.legend(fontsize=6)

plt.xticks(fontsize=8)
plt.yticks(fontsize=8)

box = ax1.get_position()
box.x0 = box.x0 - 0.15
box.x1 = box.x1 + 0.02
box.y0 = box.y0 - 0.
box.y1 = box.y1 + 0.15
ax1.set_position(box)
ax1.text(0,H-R-15,"1 point",horizontalalignment="center",fontsize=8)

box = ax2.get_position()
box.x0 = box.x0 - 0.13
box.x1 = box.x1 + 0.04
box.y0 = box.y0 - 0.035
box.y1 = box.y1 + 0.19
ax2.set_position(box)
ax2.text(0,H-R-15,"4 points",horizontalalignment="center",fontsize=8)

box = ax3.get_position()
box.x0 = box.x0 - 0.0975
box.x1 = box.x1 + 0.0725
box.y0 = box.y0 - 0.1
box.y1 = box.y1 + 0.25
ax3.set_position(box)
ax3.text(0,H-R-15,"100 points",horizontalalignment="center",fontsize=8)
#
box = ax4.get_position()
box.x0 = box.x0 + 0.08
box.x1 = box.x1 + 0.095
box.y0 = box.y0 + 0.158
box.y1 = box.y1 + 0.1
ax4.set_position(box)


# axis("tight")
# subplots_adjust(left=0.01,right=0.99,top=0.99,bottom=0.1)


plt.savefig("rotor_samples_second_revision.pdf",transparent=true)
