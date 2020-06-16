using PyPlot
using FLOWMath

speeds = range(3.,stop=25.,length=23)
omegas = [6.972,7.183,7.506,7.942,8.469,9.156,10.296,11.431,11.89,
                   12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,
                   12.1,12.1,12.1]
pitches = [0.,0.,0.,0.,0.,0.,0.,0.,0.,3.823,6.602,8.668,10.45,12.055,
                       13.536,14.92,16.226,17.473,18.699,19.941,21.177,22.347,
                       23.469]
omega_func = Akima(speeds, omegas)
pitch_func = Akima(speeds, pitches)

speeds_arr = range(3.0,stop=25.0,length=100)
omegs_arr = omega_func.(speeds_arr)
pitches_arr = pitch_func.(speeds_arr)

figure(1,figsize=(6.0,2.5))
subplot(121)
plot(speeds_arr,omegs_arr)
xlabel("wind speed (m/s)")
ylabel("rotational speed\n(rpm)")
gca().xaxis.set_ticks([3,10,20])
gca().xaxis.set_ticklabels(["cut-in","10","20"])

subplot(122)
plot(speeds_arr,pitches_arr)
xlabel("wind speed (m/s)")
ylabel("blade pitch angle\n(degrees)")
gca().xaxis.set_ticks([3,10,20])
gca().xaxis.set_ticklabels(["cut-in","10","20"])

subplots_adjust(top=0.98,bottom=0.25,left=0.15,right=0.98,wspace=0.5)

savefig("omegas.pdf",transparent=true)
