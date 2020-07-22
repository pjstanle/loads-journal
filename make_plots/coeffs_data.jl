

function get_coeffs(U,TI)
    if TI == "low"
        if U == 10.0
            alpha_star = 4.910613298216593
            beta_star = 0.6334964845427663
            k1 = 0.054208007190668185
            k2 = 0.009999995466545578
        elseif U == 11.0
            alpha_star = 4.859453751668387
            beta_star = 0.3521952853552008
            k1 = 0.18988806762879362
            k2 = 0.0012797446159086834
        elseif U == 12.0
            alpha_star = 10.0
            beta_star = 10.0
            k1 = 0.015782646912059006
            k2 = 0.010887679200026675
        elseif U == 13.0
            alpha_star = 10.0
            beta_star = 10.0
            k1 = 0.20205170208572992
            k2 = 0.006155083538196953
        end
    elseif TI == "high"
        if U == 10.0
            alpha_star = 10.0
            beta_star = 10.0
            k1 = 0.22825765110128518
            k2 = 0.00043586838809197014
        elseif U == 11.0
            alpha_star = 4.51600418189487
            beta_star = 0.35588087540526475
            k1 = 0.12234478220411872
            k2 = 0.034235188496878496
        elseif U == 12.0
            alpha_star = 10.0
            beta_star = 10.0
            k1 = 0.4265761026936039
            k2 = 0.005200957856493224
        elseif U == 13.0
            alpha_star = 10.0
            beta_star = 10.0
            k1 = 0.6719702040012256
            k2 = 0.014726485059016825
        end
    end

    return alpha_star,beta_star,k1,k2
end
