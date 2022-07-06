import matplotlib.pyplot as plt
import numpy as np
from math import sin, cos, radians

if __name__=='__main__':

    fig = plt.figure(figsize=[5.5,6.])
    ax1 = plt.subplot(321)
    ax2 = plt.subplot(322)
    ax3 = plt.subplot(323)
    ax4 = plt.subplot(324)
    ax5 = plt.subplot(325)
    ax6 = plt.subplot(326)

    import matplotlib as mpl
    mpl.rc('font', family = 'serif', serif = 'cmr10')

    n_angles = 200
    angle = np.linspace(720,0,n_angles)
    for k in range(n_angles):
        ax1.cla()
        ax2.cla()
        ax3.cla()
        ax4.cla()
        ax5.cla()
        ax6.cla()
        ax1.axis('off')
        ax3.axis('off')
        ax5.axis('off')

        angle1 = angle[k]
        H1 = 0.
        D1 = 100
        R1 = D1/2.
        spacing = 0.8
        r = D1/2.
        x1 = 100

        c1 = R1/35.

        #add blades
        hub1 = plt.Circle((x1,H1), 3*c1, color='black', fill=False, linewidth=1)
        ax1.add_artist(hub1)
        bladeX = np.array([3.,3.,5.,6.,10.,13.,18.,23.,28.,33.,38.,33.,28.,23.,18.,13.,7.,6.,3.])
        bladeY = -(np.array([2.,0.6,0.6,0.,0.,0.8,1.5,1.7,1.9,2.1,2.3,2.4,2.4,2.4,2.4,2.4,2.4,2.4,2.])-1.5)*1.5

        

        blade1X = bladeX*cos(radians(angle1))-bladeY*sin(radians(angle1))
        blade1Y = bladeX*sin(radians(angle1))+bladeY*cos(radians(angle1))

        blade2X = bladeX*cos(radians(angle1+120.))-bladeY*sin(radians(angle1+120.))
        blade2Y = bladeX*sin(radians(angle1+120.))+bladeY*cos(radians(angle1+120.))

        blade3X = bladeX*cos(radians(angle1+240.))-bladeY*sin(radians(angle1+240.))
        blade3Y = bladeX*sin(radians(angle1+240.))+bladeY*cos(radians(angle1+240.))

        tx = np.array([x1-3.,x1-3.,x1+3.,x1+3.])
        ty = np.array([H1-60.,H1-3.*c1,H1-3.*c1,H1-60.])
        ax1.plot(tx,ty,'-k')

        ax1.fill(blade1X*c1+x1, blade1Y*c1+H1, linewidth=1, facecolor='C0', edgecolor="C0")
        ax1.fill(blade2X*c1+x1, blade2Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")
        ax1.fill(blade3X*c1+x1, blade3Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")

        # ax1.text(x1-30.,-42.,'gravity',family='serif',fontsize=10,horizontalalignment='center',verticalalignment='center',color='C0')
        # ax1.text(x1-40.,32.,'aerodynamic',family='serif',fontsize=10,horizontalalignment='center',verticalalignment='center',color='C1')


        N = 200
        wakerad = np.linspace(1.,120.,N)
        a = np.linspace(1.,0.1,N)
        for i in range(N):
            wake = plt.Circle((x1+70.,H1), wakerad[i]/2., edgecolor='C0', linewidth=.3,fill=None, alpha=a[i])
            ax5.add_artist(wake)

        ax5.text(x1+60.,H1+25,"wake",family="serif")

        #add blades
        hub1 = plt.Circle((x1,H1), 3*c1, color='black', fill=False, linewidth=1)
        ax5.add_artist(hub1)

        tx = np.array([x1-3.,x1-3.,x1+3.,x1+3.])
        ty = np.array([H1-60.,H1-3.*c1,H1-3.*c1,H1-60.])
        ax5.plot(tx,ty,'-k')
        ax5.fill(blade1X*c1+x1, blade1Y*c1+H1, linewidth=1, facecolor='C0', edgecolor="C0")
        ax5.fill(blade2X*c1+x1, blade2Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")
        ax5.fill(blade3X*c1+x1, blade3Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")

        N = 200
        wakerad = np.linspace(1.,120.,N)
        a = np.linspace(1.,0.1,N)
        for i in range(N):
            wake = plt.Circle((x1-70.,H1), wakerad[i]/2., edgecolor='C0', linewidth=.3,fill=None, alpha=a[i])
            ax3.add_artist(wake)
        
        ax3.text(x1-80.,H1+25,"wake",family="serif")

        hub1 = plt.Circle((x1,H1), 3*c1, color='black', fill=False, linewidth=1)
        ax3.add_artist(hub1)
        tx = np.array([x1-3.,x1-3.,x1+3.,x1+3.])
        ty = np.array([H1-60.,H1-3.*c1,H1-3.*c1,H1-60.])
        ax3.plot(tx,ty,'-k')
        ax3.fill(blade1X*c1+x1, blade1Y*c1+H1, linewidth=1, facecolor='C0', edgecolor="C0")
        ax3.fill(blade2X*c1+x1, blade2Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")
        ax3.fill(blade3X*c1+x1, blade3Y*c1+H1, linewidth=1, facecolor='white', edgecolor="black")

        ax1.axis('equal')
        ax3.axis('equal')
        ax5.axis('equal')

        ax1.set_xlim([0,200.])
        ax1.set_ylim([-120,120])
        ax3.set_xlim([0,200.])
        ax3.set_ylim([-120,120])
        ax5.set_xlim([0,200.])
        ax5.set_ylim([-120,120])

        r_grav = 30.0
        r_aero = 40.0

        x_grav = r_grav * np.cos(np.deg2rad(angle1))
        y_grav = r_grav * np.sin(np.deg2rad(angle1))
        x_aero = r_aero * np.cos(np.deg2rad(angle1))
        y_aero = r_aero * np.sin(np.deg2rad(angle1))

        len_grav = 30.0
        len_aero = 20.0
        ax1.arrow(x1+x_grav, y_grav, 0.0,
                -len_grav,head_width=5.,
                head_length=5.,ec='C0',fc='C0')
        ax1.arrow(x1+x_aero, y_aero, len_aero*np.sin(np.deg2rad(angle1)),
                -len_aero*np.cos(np.deg2rad(angle1)),head_width=5.,
                head_length=5.,ec='C1',fc='C1')

        if x_aero < 0:
            x = (angle1+90.0 % 180.0) * 2.0
            len_aero = 20.0* (0.75/2.0*(np.cos(np.deg2rad(x))+1.0)+0.25)
        else:
            len_aero = 20.0

        ax3.arrow(x1+x_grav, y_grav, 0.0,
                -len_grav,head_width=5.,
                head_length=5.,ec='C0',fc='C0')
        ax3.arrow(x1+x_aero, y_aero, len_aero*np.sin(np.deg2rad(angle1)),
                -len_aero*np.cos(np.deg2rad(angle1)),head_width=5.,
                head_length=5.,ec='C1',fc='C1')

        if x_aero > 0:
            x = (angle1+90.0 % 180.0) * 2.0
            len_aero = 20.0* (0.75/2.0*(np.cos(np.deg2rad(x))+1.0)+0.25)
        else:
            len_aero = 20.0
        
        ax5.arrow(x1+x_grav, y_grav, 0.0,
                -len_grav,head_width=5.,
                head_length=5.,ec='C0',fc='C0')
        ax5.arrow(x1+x_aero, y_aero, len_aero*np.sin(np.deg2rad(angle1)),
                -len_aero*np.cos(np.deg2rad(angle1)),head_width=5.,
                head_length=5.,ec='C1',fc='C1')


        def loads_grav(a, P=0.75):
            angle = np.deg2rad(a)
            return P*np.sin(angle+np.pi/2)

        def loads1_aero(a, P=0.75):
            return P

        def loads2_aero(angle, P=0.75):
            if np.cos(np.deg2rad(angle)) < 0:
                x = (angle+90.0 % 180.0) * 2.0
                return P* (0.9/2.0*(np.cos(np.deg2rad(x))+1.0)+0.1)
            else:
                return P

        def loads3_aero(angle, P=0.75):
            if np.cos(np.deg2rad(angle)) > 0:
                x = (angle+90.0 % 180.0) * 2.0
                return P* (0.9/2.0*(np.cos(np.deg2rad(x))+1.0)+0.1)
            else:
                return P

        xline = np.array([0.,720])
        yline = np.zeros_like(xline)
        ax2.plot(xline,yline,'--k')
        ax4.plot(xline,yline,'--k')
        ax6.plot(xline,yline,'--k')

        N = 1000
        angle_arr = np.linspace(0,720,N)
        grav = np.zeros(N)
        aero1 = np.zeros(N)
        aero2 = np.zeros(N)
        aero3 = np.zeros(N)
        for i in range(N):
            grav[i] = loads_grav(angle_arr[i])
            aero1[i] = loads1_aero(angle_arr[i])
            aero2[i] = loads2_aero(angle_arr[i])
            aero3[i] = loads3_aero(angle_arr[i])

        ax2.plot(angle_arr,grav,color="C0",label="gravity")
        ax2.plot(angle_arr,aero1,color="C1",label="aerodynamic")
        ax2.plot(angle_arr,grav+aero1,color="C3",label="combined")
        ax2.legend(fontsize=8)
        ax2.plot(720-angle1,loads_grav(720-angle1),"o",color="C0")
        ax2.plot(720-angle1,loads1_aero(720-angle1),"o",color="C1")
        ax2.plot(720-angle1,loads_grav(720-angle1)+loads1_aero(720-angle1),"o",color="C3")

        ax4.plot(angle_arr,grav,color="C0")
        ax4.plot(angle_arr,aero2,color="C1")
        ax4.plot(angle_arr,grav+aero2,color="C3")

        ax4.plot(720-angle1,loads_grav(720-angle1),"o",color="C0")
        ax4.plot(720-angle1,loads2_aero(720-angle1),"o",color="C1")
        ax4.plot(720-angle1,loads_grav(720-angle1)+loads2_aero(720-angle1),"o",color="C3")

        ax6.plot(angle_arr,grav,color="C0")
        ax6.plot(angle_arr,aero3,color="C1")
        ax6.plot(angle_arr,grav+aero3,color="C3")

        ax6.plot(720-angle1,loads_grav(720-angle1),"o",color="C0")
        ax6.plot(720-angle1,loads3_aero(720-angle1),"o",color="C1")
        ax6.plot(720-angle1,loads_grav(720-angle1)+loads3_aero(720-angle1),"o",color="C3")


        ax2.set_yticks((-1.5,-1.,-0.5,0.,0.5,1.,1.5))
        ax2.set_yticklabels(('','','','','','',''))
        ax2.set_xticks((0.,180,360,540,720))
        ax2.set_xticklabels(('','','','',''))

        ax4.set_yticks((-1.5,-1.,-0.5,0.,0.5,1.,1.5))
        ax4.set_yticklabels(('','','','','','',''))
        ax4.set_xticks((0.,180,360,540,720))
        ax4.set_xticklabels(('','','','',''))

        ax6.set_yticks((-1.5,-1.,-0.5,0.,0.5,1.,1.5))
        ax6.set_yticklabels(('','','','','','',''))
        ax6.set_xticks((0.,180,360,540,720))
        ax6.set_xticklabels(('','','','',''))

        ax2.set_xlim(0,720)
        ax4.set_xlim(0,720)
        ax6.set_xlim(0,720)

        ax2.grid()
        ax4.grid()
        ax6.grid()

        ax2.set_ylabel('root loads',fontsize=10,color='black',family='serif',labelpad=-3.)
        ax4.set_ylabel('root loads',fontsize=10,color='black',family='serif',labelpad=-3.)
        ax6.set_ylabel('root loads',fontsize=10,color='black',family='serif',labelpad=-3.)

        ax6.set_xlabel('azimuth angle',fontsize=10,color='black',family='serif',labelpad=-3.)

        plt.subplots_adjust(top = 0.98, bottom = 0.1, right = 0.98, left = 0.02,
                hspace = 0.2, wspace = 0.1)

        if k < 10:
            plt.savefig('frame00%s.pdf'%k)
        elif k < 100:
            plt.savefig('frame0%s.pdf'%k)
        else:
            plt.savefig('frame%s.pdf'%k)
        # plt.pause(0.1)