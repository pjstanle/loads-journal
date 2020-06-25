using PyPlot
using SpecialFunctions

function weibull(U,Umean)
    k = 2.0
    lam = Umean/(gamma(1+1/k))
    f = k/lam*(U/lam)^(k-1)*exp(-(U/lam)^k)
    return f
end

Umean = [5.0,10.0,15.0]
U = range(0,stop=30,length=1000)
figure(1,figsize=(3.5,3))
for k = 1:length(Umean)
    plot(U,weibull.(U,Umean[k]))
end

ylabel("probability density")
xlabel("wind speed (m/s)")
text(8,0.1,L"$\bar{U}=5$ m/s",color="C0",fontsize=10)
text(12,0.07,L"$\bar{U}=10$ m/s",color="C1",fontsize=10)
text(16,0.05,L"$\bar{U}=15$ m/s",color="C2",fontsize=10)
tight_layout()

savefig("weib_fig.pdf",transparent=true)
