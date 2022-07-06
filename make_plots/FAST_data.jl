


function fastdata(turb,ws,sep)

    FS = [-1.0,-0.8,-0.6,-0.4,-0.2,0.0,0.2,0.4,0.6,0.8,1.0]
    no_pitch = false
    if turb == "low"
        if ws == 10
           if sep == 4.0
               FD = [0.09182389, 0.27367474, 0.43737724, 0.25577379, 0.07315111,
              0.02212047, 0.0219701 , 0.03314924, 0.04282983, 0.03492318,
              0.03608086]
           elseif sep == 7.0
               FD = [0.11118407, 0.20795058, 0.27237578, 0.19238532, 0.07942963,
              0.03005412, 0.02408143, 0.02873857, 0.03003227, 0.02703879,
              0.03532939]
           elseif sep == 10.0
               FD = [0.09962295, 0.14386566, 0.1529574 , 0.10837712, 0.06500144,
              0.03931054, 0.02685782, 0.02341648, 0.02369127, 0.02745877,
              0.03709964]
           end

        elseif ws == 11
            if sep == 4.0
                FD = [0.12474905, 0.44955552, 0.98879786, 0.55243793, 0.13710362,
                        0.02830596, 0.02459855, 0.04351297, 0.0610912 , 0.04793649,
                        0.04335935]
            elseif sep == 7.0
                FD = [0.15679473, 0.33452526, 0.5630296 , 0.43909217, 0.1547891 ,
                        0.04392345, 0.02885432, 0.04226767, 0.04382467, 0.0332834 ,
                        0.0453312 ]
            elseif sep == 10.0
                FD = [0.13796973, 0.24582433, 0.3031502 , 0.26217174, 0.12378311,
                        0.04605147, 0.02505028, 0.02983001, 0.03059458, 0.03172991,
                        0.04559384]
            end

        # elseif ws == 11
        #     if sep == 4.0
        #         FD = [6.87358322e-02, 3.83876072e-01, 8.96546088e-01, 4.59322000e-01,
        #                7.27727268e-02, 5.26962512e-03, 5.55774038e-04, 1.93774126e-04,
        #                2.95744164e-04, 2.37253360e-03, 1.14669822e-02]
        #     elseif sep == 7.0
        #         FD = [0.10089098, 0.26853429, 0.48207893, 0.35967568, 0.09233777,
        #                0.0280947 , 0.00201654, 0.00103108, 0.00175305, 0.00507096,
        #                0.01301602]
        #     elseif sep == 10.0
        #         FD = [0.02048437, 0.02388994, 0.02543785, 0.02455052, 0.02804583,
        #                0.02826675, 0.03240978, 0.03429438, 0.03610691, 0.03474075,
        #                0.03207432]
        #     end


        elseif ws == 12
            if sep == 4.0
                FD = [0.14841399, 0.49595138, 1.34803516, 1.25430712, 0.29605346,
                           0.05068178, 0.02653278, 0.04368748, 0.05165779, 0.03799159,
                           0.07522253]
            elseif sep == 7.0
                FD = [0.18327844, 0.41799378, 0.76867414, 0.86818366, 0.35801523,
                           0.0841998 , 0.02661469, 0.03694555, 0.04142776, 0.03735182,
                           0.07156566]
            elseif sep == 10.0
                FD = [0.2084088 , 0.3576736 , 0.48538222, 0.50291998, 0.29240833,
                           0.1060008 , 0.04258391, 0.02906886, 0.03303259, 0.04580801,
                           0.07174415]
            end
        elseif ws == 13
            if no_pitch == false
                if sep == 4.0
                        FD = [0.120385  , 0.43966496, 1.49963083, 1.283816  , 0.34256675,
                           0.05646229, 0.03843661, 0.05306928, 0.05401545, 0.08259596,
                           0.08577113]
                elseif sep == 7.0
                        FD = [0.17079266, 0.52412727, 1.10421169, 0.91336942, 0.32727372,
                            0.07652119, 0.04013585, 0.04518639, 0.06678548, 0.06778572,
                            0.09812841]
                elseif sep == 10.0
                        FD = [0.20879636, 0.4840231 , 0.88389687, 0.74301718, 0.3106862 ,
                            0.09396246, 0.04306845, 0.0497348 , 0.07675588, 0.07744574,
                            0.10162294]
                end
            else
                if sep == 4.0
                        FD = [0.35977159, 0.82398547, 2.11288369, 1.21422325, 0.36448369,
                           0.09955591, 0.09267249, 0.14133323, 0.30862467, 0.23589413,
                           0.20816489]
                elseif sep == 7.0
                        FD =[0.38682119, 0.75667272, 1.52735424, 0.88946904, 0.39084174,
                           0.1244744 , 0.07347168, 0.13570754, 0.25266818, 0.17772383,
                           0.1965976 ]
                elseif sep == 10.0
                        FD =[0.41971067, 0.62665264, 1.02845494, 0.66679973, 0.37139446,
                           0.16092764, 0.09035186, 0.18336173, 0.14447372, 0.16382193,
                           0.20735961]
                end
            end
        end






    elseif turb == "high"

        if ws == 10
            if sep == 4.0
                    FD = [0.50002881, 0.70466881, 0.73596014, 0.40551527, 0.33580756,
                       0.2376758 , 0.06888055, 0.03889911, 0.03757173, 0.04838122,
                       0.07533215]
            elseif sep == 7.0
                    FD =[0.23863468, 0.2157986 , 0.17003323, 0.08433975, 0.04389997,
                       0.02475212, 0.02191312, 0.02308251, 0.02578362, 0.03166794,
                       0.04341393]
            elseif sep == 10.0
                    FD =[0.19250297, 0.22198425, 0.21469001, 0.12655635, 0.06760805,
                       0.03311422, 0.02353796, 0.02644454, 0.0294028 , 0.03476283,
                       0.04818647]
            end
        end

        if ws == 11
            if sep == 4.0
                    FD = [0.2728365 , 0.65977472, 0.77260459, 0.4778191 , 0.24800923,
                   0.10146671, 0.04171074, 0.06843597, 0.06012162, 0.05531389,
                   0.15369841]
            elseif sep == 7.0
                    FD = [0.30243331, 0.37563574, 0.38496825, 0.30413719, 0.17994517,
                   0.08185298, 0.04101291, 0.04436714, 0.04838322, 0.09869199,
                   0.17469088]
            elseif sep == 10.0
                    FD = [0.25667372, 0.28045112, 0.31380656, 0.26435168, 0.13541739,
                   0.08130023, 0.06937866, 0.05838691, 0.06783909, 0.09664072,
                   0.19967812]
            end

        elseif ws == 12
            if sep == 4.0
                    FD = [0.59436966, 0.86531902, 1.47720059, 1.29034929, 0.39374063,
                       0.0675834 , 0.09811606, 0.0944617 , 0.0546642 , 0.1133815 ,
                       0.30375038]
            elseif sep == 7.0
                    FD = [0.74362544, 0.94617913, 1.12020256, 0.82845987, 0.41520515,
                       0.09437026, 0.08533575, 0.09938972, 0.13268212, 0.24422962,
                       0.28269637]
            elseif sep == 10.0
                    FD = [0.8467823 , 0.76667692, 0.7433349 , 0.69224899, 0.38166549,
                       0.17593557, 0.12199661, 0.12614291, 0.12928943, 0.19476268,
                       0.26522156]
            end

        elseif ws == 13
            if no_pitch == false
                   if sep == 4.0
                           FD = [0.48608728, 0.90662317, 1.39549172, 2.04401001, 1.46901554,
                          0.54139495, 0.14399162, 0.1125801 , 0.14678671, 0.1724072 ,
                          0.33570147]
                   elseif sep == 7.0
                           FD = [0.84783926, 0.90382795, 1.66442715, 2.02387409, 1.79021644,
                          0.47391596, 0.27280782, 0.17559805, 0.20302434, 0.21569954,
                          0.44578776]
                   elseif sep == 10.0
                           FD = [0.91365132, 1.29885624, 1.38659419, 1.02947128, 0.91010369,
                          0.41046279, 0.24486986, 0.20180934, 0.24375777, 0.26666614,
                          0.6751095]
                    end
            else
                if sep == 4.0
                        FD = [2.92287062, 3.49715544, 4.53887881, 4.90866996, 3.61393247,
       2.8180966 , 2.4011507 , 1.79317558, 2.03742589, 3.25427622,
       5.40662913]
                elseif sep == 7.0
                        FD = [3.16334181, 3.06324113, 2.87205899, 3.5118136 , 3.49815298,
       2.24162372, 1.58630646, 1.60752003, 1.34630098, 3.4552718 ,
       5.62141018]
                elseif sep == 10.0
                        FD = [5.20716209, 5.08152203, 3.03568438, 4.08229691, 2.87656213,
       1.68297112, 1.57067148, 1.18215048, 1.64180842, 2.46672772,
       5.91090237]
                 end
         end

        elseif ws == 18
           if sep == 4.0
                   FD = [0.65121052, 0.50784626, 0.71732361, 0.84557725, 0.63113656,
                   0.35273767, 0.20973277, 0.10862101, 0.15168143, 0.15275253,
                   0.14829193]
           elseif sep == 7.0
                   FD = [0.61718423, 0.59091889, 0.80978803, 0.80834002, 0.81278733,
                   0.2595964 , 0.15712106, 0.11604394, 0.13700606, 0.17888938,
                   0.17982584]
           elseif sep == 10.0
                   FD = [0.56238548, 0.55976206, 0.82568202, 0.59673494, 0.54387982,
                   0.27140943, 0.16181742, 0.1457856 , 0.11275286, 0.14128088,
                   0.14321815]
            elseif sep == -2.0
                    FD = [0.45203731, 0.57694529, 0.48230886, 0.40786515, 0.45458318,
                   0.6579893 , 0.57812312, 0.59867996, 0.75592218, 0.72025009,
                   0.53850371]
            end
        end

    end

    return FS, FD
end