using FLOWMath
using CCBlade

global Rhub
global Rtip
global B
global precone
global sections
global r
global Vinf
global Omega
global yaw
global tilt
global azangles
global hubHt
global shearExp
global rho
global Prated

r = [2.8667, 5.6000, 8.3333, 11.7500, 15.8500, 19.9500, 24.0500,
              28.1500, 32.2500, 36.3500, 40.4500, 44.5500, 48.6500, 52.7500,
              56.1667, 58.9000, 61.6333]
chord = [3.542, 3.854, 4.167, 4.557, 4.652, 4.458, 4.249, 4.007, 3.748,
                  3.502, 3.256, 3.010, 2.764, 2.518, 2.313, 2.086, 1.419]
theta = pi/180*[13.308, 13.308, 13.308, 13.308, 11.480, 10.162, 9.011, 7.795,
                  6.544, 5.361, 4.188, 3.125, 2.319, 1.526, 0.863, 0.370, 0.106]

Rhub = 1.5
Rtip = 63.0
B = 3
pitch = 0.0
precone = 2.5*pi/180
tilt = deg2rad(5.0)

af_path = "/Users/ningrsrch/Dropbox/Projects/waked-loads/5MW_AFFiles_julia"
path1 = af_path*"/Cylinder1.dat"
path2 = af_path*"/Cylinder2.dat"
path3 = af_path*"/DU40_A17.dat"
path4 = af_path*"/DU35_A17.dat"
path5 = af_path*"/DU30_A17.dat"
path6 = af_path*"/DU25_A17.dat"
path7 = af_path*"/DU21_A17.dat"
path8 = af_path*"/NACA64_A17.dat"

# af1 = af_from_files(path1)
# af2 = af_from_files(path2)
# af3 = af_from_files(path3)
# af4 = af_from_files(path4)
# af5 = af_from_files(path5)
# af6 = af_from_files(path6)
# af7 = af_from_files(path7)
# af8 = af_from_files(path8)

aftypes = Array{Any}(undef, 8)
aftypes[1] = af_from_files(path1)
aftypes[2] = af_from_files(path2)
aftypes[3] = af_from_files(path3)
aftypes[4] = af_from_files(path4)
aftypes[5] = af_from_files(path5)
aftypes[6] = af_from_files(path6)
aftypes[7] = af_from_files(path7)
aftypes[8] = af_from_files(path8)

# af = [af1,af2,af3,af4,af5,af6,af7,af8]

af_idx = [1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8]
# airfoils = af[af_idx]
airfoils = aftypes[af_idx]

pitch = 0.
Rhub = 1.5
hubHt = 90.

rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
sections = CCBlade.Section.(r,chord,theta,airfoils)

Vinf = 11.4
tsr = 7.55
rotorR = Rtip*cos(precone)
Omega = Vinf*tsr/rotorR
rho = 1.225
yaw = 0.0
shearExp = 0.15

azangles = pi/180*[0.0, 90.0, 180.0, 270.0]

ops = windturbine_op.(Vinf, Omega, r, precone, yaw, tilt, azangles', hubHt, shearExp, rho)
outs = solve.(Ref(rotor), sections, ops)

function get_torque1(outputs,rotor,Rhub,r,Rtip)
        rfull = [rotor.Rhub; sections.r; rotor.Rtip]
        nr = length(outputs)
        tps = zeros(nr)
        for i = 1:nr
                tps[i] = outputs[i].Tp
        end
        # Tpfull = [0.0; outputs.Tp; 0.0]
        Tpfull = [0.0; tps; 0.0]
        torque = Tpfull.*rfull*cos(rotor.precone)

        Q = rotor.B * FLOWMath.trapz(rfull, torque)

        return Q
end


function get_torque_full(outputs,rotor,Rhub,r,Rtip)
        Q = 0.0
        nr, naz = size(outputs)
        for j = 1:naz
            Qsub = get_torque1(outputs[:, j],rotor,Rhub,r,Rtip)
            # Qsub = thrusttorque(rotor, sections, outputs[:, j])
            Q += Qsub / naz
        end

        return Q
end

Q = get_torque_full(outs,rotor,Rhub,r,Rtip)
P = Q*Omega*0.93


function find_pitch(p)
        global Rhub
        global Rtip
        global B
        global precone
        global sections
        global r
        global Vinf
        global Omega
        global yaw
        global tilt
        global azangles
        global hubHt
        global shearExp
        global rho
        global Prated

        pitch = deg2rad(p)

        rotor = CCBlade.Rotor(Rhub, Rtip, B, true, pitch, precone)
        ops = CCBlade.windturbine_op.(Vinf, Omega, r, precone, yaw, tilt, azangles', hubHt, shearExp, rho)
        outs = CCBlade.solve.(Ref(rotor), sections, ops)

        Q = get_torque_full(outs,rotor,Rhub,r,Rtip)
        P = Q*Omega*0.93
        return P-Prated
end


speeds = range(0.0,stop=25.0,length=50)
Prated = 5.0e6

power = zeros(length(speeds))
ps = zeros(length(speeds))
for i = 1:length(speeds)
        global Rhub
        global Rtip
        global B
        global precone
        global sections
        global r
        global Vinf
        global Omega
        global yaw
        global tilt
        global azangles
        global hubHt
        global shearExp
        global rho
        global Prated

        Vinf = speeds[i]
        pitch = 0.0
        ops = CCBlade.windturbine_op.(Vinf, Omega, r, precone, yaw, tilt, azangles', hubHt, shearExp, rho)
        outs = CCBlade.solve.(Ref(rotor), sections, ops)

        Q = get_torque_full(outs,rotor,Rhub,r,Rtip)
        Pstart = Q*Omega*0.93

        if Pstart <= Prated
                power[i] = Pstart
                ps[i] = 0.0
        else
                pstar = FLOWMath.brent(find_pitch,0.0,45.0)[1]
                power[i] = find_pitch(pstar)+Prated
                ps[i] = pstar
        end
end

using PyPlot
# figure(1)
plot(speeds,ps,"o")

# figure(2)
# plot(speeds,power)
