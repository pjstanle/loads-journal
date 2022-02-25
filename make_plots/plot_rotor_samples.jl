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

figure(1,figsize=(4.0,2.5))

plt.subplot(121)

bladeX = [3.,7.,10.,15.,20.,25.,30.,35.,30.,25.,20.,15.,10.,5.,3.,3.]
bladeY = [0.,0.,0.8,1.5,1.7,1.9,2.1,2.3,2.4,2.4,2.4,2.4,2.4,2.4,2.4,0.].-1.5
#
H = 110.
D = 130.
R = 65.
d = [6.3,5.5,4.]


plt.gca().add_artist(plt.Circle((0.,H), R, fill=false, color="C0",  linestyle = "--", linewidth=1.2*1.5))
plt.show()

c1 = R/35.

px1 = [0.0-d[1]/2,0.0-d[2]/2,0.0-d[3]/2,0.0+d[3]/2,0.0+d[2]/2,0.0+d[1]/2,0.0-d[1]/2]
py1 = [0,H/2,H-3.0*c1,H-3.0*c1,H/2,0,0]
plt.gca().plot(px1,py1,color="C0", linewidth=1.2*1.5)
#
#add blades
plt.gcf().gca().add_artist(plt.Circle((0.0,H), 3*c1, color="C0", fill=false, linewidth=1*1.5))
#
angle1 = 5.

blade1X = bladeX*cos(deg2rad(angle1))-bladeY*sin(deg2rad(angle1))
blade1Y = bladeX*sin(deg2rad(angle1))+bladeY*cos(deg2rad(angle1))

blade2X = bladeX*cos(deg2rad(angle1+120.))-bladeY*sin(deg2rad(angle1+120.))
blade2Y = bladeX*sin(deg2rad(angle1+120.))+bladeY*cos(deg2rad(angle1+120.))

blade3X = bladeX*cos(deg2rad(angle1+240.))-bladeY*sin(deg2rad(angle1+240.))
blade3Y = bladeX*sin(deg2rad(angle1+240.))+bladeY*cos(deg2rad(angle1+240.))
#
plt.gca().plot(blade1X.*c1.+0.0, blade1Y.*c1.+H, linewidth=1*1.5, color="C0")
plt.gca().plot(blade2X.*c1.+0.0, blade2Y.*c1.+H, linewidth=1*1.5, color="C0")
plt.gca().plot(blade3X.*c1.+0.0, blade3Y.*c1.+H, linewidth=1*1.5, color="C0")
#
x_sample = [0.69*R,0.,-0.69*R,0.]
y_sample = [0.,0.69*R,0.,-0.69*R].+H
plt.gca().plot(x_sample,y_sample,"o",color="C1",markersize=3)
#
plt.gca().text(0.69*R,H+7.0,"(0.69,0)",horizontalalignment="center",fontsize=8)
plt.gca().text(0.0,H+0.69*R+7.0,"(0,0.69)",horizontalalignment="center",fontsize=8)
plt.gca().text(-0.69*R,H+7.0,"(-0.69,0)",horizontalalignment="center",fontsize=8)
plt.gca().text(0.0,H-0.69*R+7.0,"(0,-0.69)",horizontalalignment="center",fontsize=8)
#
plt.gca().axis("equal")
plt.gca().axis("off")
#
plt.gca().set_ylim(-25.,H+R+25)
plt.gca().set_xlim(-R,R)
#



plt.subplot(122)
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

# N = 100
# r = range(0.0,stop=R,length=N)
# theta = range(0.0,2*pi,length=N)
# y_arr = zeros(N,N)
# z_arr = zeros(N,N)
# for i = 1:N
#     for j = 1:N
#         y_arr[i,j] = r[i]*cos(theta[j])+locy
#         z_arr[i,j] = r[i]*sin(theta[j])+H
#     end
# end

# v = zeros(N,N)
# for i=1:N
#     for j=1:N
#         v[i,j] = ff.point_velocity(locx, y_arr[i,j], z_arr[i,j], turbine_x, turbine_y, turbine_z, turbine_yaw, turbine_ct, turbine_ai,
#                         rotor_diameter, hub_height, turbine_local_ti, sorted_turbine_index, wtvelocities,
#                         windresource, model_set)
#     end
# end


# plt.pcolormesh(y_arr,z_arr,v,shading="gouraud")

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



plt.plot(yloc/D,v100./freestream,color="black",label="100 points")
plt.plot(yloc/D,v4./freestream,color="C0","--",label="4 points")
plt.plot(yloc/D,v1./freestream,color="C1",label="1 point")

plt.xlabel("offset (D)",fontsize=8)
plt.ylabel("normalized average\nrotor speed",fontsize=8)


plt.legend(fontsize=6)

plt.xticks(fontsize=8)
plt.yticks(fontsize=8)


plt.tight_layout()


plt.show()

# plt.savefig("rotor_samples_fatigue2.pdf",transparent=true)
# # # plt.savefig('/Users/ningrsrch/Dropbox/Projects/stanley2019-variable-reduction/paper/paper-figures/rotor_samples.pdf',transparent=True)
# #
# # plt.show()
