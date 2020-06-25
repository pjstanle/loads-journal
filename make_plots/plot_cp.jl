using PyPlot
using DelimitedFiles

ctdata = readdlm("inputfiles/NREL5MWCPCT.txt",  ',', skipstart=1)
velpoints = ctdata[:,1]
cppoints = ctdata[:,2]
ctpoints = ctdata[:,3]

CP = [0.0,0.0]
append!(CP,cppoints)

CT = [0.0,0.0]
append!(CT,ctpoints)

V = [0.0,2.99]
append!(V,velpoints)

for i = 1:length(CT)
    if CT[i] > 8/9
        CT[i] = 8/9
    end
end

figure(1,figsize=(6,2.5))
subplot(121)
plot(V,CP)
xlabel("wind speed (m/s)")
ylabel(string(L"$C_P$"))
ylim(0,1.02)
xlim(0,25)

subplot(122)
plot(V,CT)
xlabel("wind speed (m/s)")
ylabel(string(L"$C_T$"))
ylim(0,1.02)
xlim(0,25)




subplots_adjust(top=0.95,bottom=0.19,left=0.13,right=0.95,wspace=0.35,hspace=0.1)
savefig("cp_ct.pdf",transparent=true)
