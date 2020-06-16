using PyPlot
using FLOWMath

speeds = range(3.,stop=25.,length=23)
omegas = [6.972,7.183,7.506,7.942,8.469,9.156,10.296,11.431,11.89,
                   12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,12.1,
                   12.1,12.1,12.1]
omega_func = Akima(speeds, omegas)

speeds_arr = range(3.0,stop=25.0,length=100)
omegs_arr = omega_func.(speeds_arr)

figure(1,figsize=(4.0,3.0))
plot(speeds_arr,omegs_arr)
xlabel("wind speed (m/s)")
ylabel("rotational speed (rpm)")
tight_layout()
savefig("omegas.pdf",transparent=true)
