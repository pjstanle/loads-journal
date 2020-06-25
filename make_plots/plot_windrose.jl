using PyPlot
using FLOWMath


# coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0])
# coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13] .+ 3.0
# coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095]
# ndirections = 24
# fine_dirs = range(0.0,stop=2.0*pi-2.0*pi/ndirections,length=ndirections)
# fine_dirs = akima(coarse_dirs,coarse_dirs,fine_dirs)
# fine_speeds = akima(coarse_dirs,coarse_speeds,fine_dirs)
# fine_probs = akima(coarse_dirs,coarse_probs,fine_dirs)
# fine_probs = fine_probs./sum(fine_probs)
#
# #rotate to meteorological coordinates
# fine_dirs = pi/2 .- fine_dirs
#
# width = 2*pi/ndirections*0.9
# figure(figsize=(6,3))
# subplot(121,projection="polar")
# bar(fine_dirs, fine_probs, width=width, bottom=0.0, color="C0")
# gca().xaxis.set_ticks([0.0,pi/2,pi,3*pi/2])
# gca().xaxis.set_ticklabels(["E","N","W","S"])
# gca().set_rgrids([0.025,0.05,0.075],angle=45)
# gca().yaxis.set_ticklabels(["2.5%","5%","7.5%"],horizontalalignment="left")
# title("wind rose",fontsize=10,y=1.1)
#
# subplot(122,projection="polar")
# bar(fine_dirs, fine_speeds, width=width, bottom=0.0, color="C1")
# gca().xaxis.set_ticks([0.0,pi/2,pi,3*pi/2])
# gca().xaxis.set_ticklabels(["E","N","W","S"])
# gca().set_rgrids([9,11,13],angle=60)
# gca().yaxis.set_ticklabels(["9 m/s","11 m/s","13 m/s"],horizontalalignment="center")
# title("wind speeds",fontsize=10,y=1.1)
#
# subplots_adjust(top=0.85,bottom=0.1,left=0.05,right=0.95,wspace=0.3)
# # savefig("windrose.pdf", transparent=true)



coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0,360.0])
coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13,7.59]
coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095,0.039]
ndirections = 1000
fine_dirs = range(0.0,stop=2.0*pi-2.0*pi/ndirections,length=ndirections)
# fine_dirs = range(pi/2,stop=-3.0*pi/2+2.0*pi/ndirections,length=ndirections) .+ 3*pi/2
fine_dirs = akima(coarse_dirs,coarse_dirs,fine_dirs)
fine_speeds = akima(coarse_dirs,coarse_speeds,fine_dirs)
fine_probs = akima(coarse_dirs,coarse_probs,fine_dirs)
fine_probs = fine_probs./trapz(fine_dirs,fine_probs)

#rotate to meteorological coordinates
# fine_dirs = pi/2 .- fine_dirs
# fine_dirs = fine_dirs .- minimum(fine_dirs)
width = 2*pi/ndirections*0.9
figure(figsize=(6,3))
subplot(121)
println(maximum(fine_dirs))
println(minimum(fine_dirs))
plot(fine_dirs,fine_probs, color="C0")

ylim(0,0.27)
xlim(0,2*pi)
gca().xaxis.set_ticks([0.0,pi/2,pi,3*pi/2,2*pi])
gca().xaxis.set_ticklabels(["0",L"$\pi$/2",L"$\pi$",L"$3\pi/2$",L"$\pi$"])
title("wind direction PDF",fontsize=10,pad=20.0)
ylabel("probability density")
xlabel("wind direction")

coarse_dirs = deg2rad.([0.0,30.0,60.0,90.0,120.0,150.0,180.0,210.0,240.0,270.0,300.0,330.0,360.0])
coarse_speeds = [7.59,6.89,6.39,7.34,8.08,8.01,8.36,8.41,8.34,7.93,8.72,9.13,7.59]
coarse_probs = [0.039,0.037,0.045,0.082,0.087,0.065,0.064,0.101,0.123,0.127,0.135,0.095,0.039]
ndirections = 24
fine_dirs = range(0.0,stop=2.0*pi-2.0*pi/ndirections,length=ndirections)
fine_dirs = akima(coarse_dirs,coarse_dirs,fine_dirs)
fine_speeds = akima(coarse_dirs,coarse_speeds,fine_dirs)
fine_probs = akima(coarse_dirs,coarse_probs,fine_dirs)
fine_probs = fine_probs./sum(fine_probs)
#
# #rotate to meteorological coordinates
fine_dirs = pi/2 .- fine_dirs
#
width = 2*pi/ndirections*0.9
subplot(122,projection="polar")
bar(fine_dirs, fine_probs, width=width, bottom=0.0, color="C0")
gca().xaxis.set_ticks([0.0,pi/2,pi,3*pi/2])
gca().xaxis.set_ticklabels(["E","N","W","S"])
gca().set_rgrids([0.025,0.05,0.075],angle=45)
gca().yaxis.set_ticklabels(["2.5%","5%","7.5%"],horizontalalignment="left")
title("wind rose",fontsize=10,y=1.1)

subplots_adjust(top=0.85,bottom=0.2,left=0.15,right=0.95,wspace=0.2)
savefig("pdf_windrose.pdf", transparent=true)
