#!/bin/bash 

##################################################################################################################
# pDosBandPlot.sh is an auxiliary tool for Quantum Espresso Linux users. It semiautomates the plotting of        #
# electronic band structure and Total[Partial] Density of States from Quantum Espresso output simulation data.   #
# This program does an integration between Shell Script, Zenity, Gnuplot and Latex. FOR ITS OPERATION IT IS      #
# NECESSARY TO HAVE GNUPLOT (http://www.gnuplot.info/), LATEX, AND ZENITY (sudo apt install zenity) INSTALLED    #
# ON YOUR COMPUTER. The description of the input variables is done in the README.md file.                        #
# Copyright (C) <2022>  <J.R.M. Monteiro and Henrique Pecinatto>                                                 #
# e-mail: joziano@protonmail.com | pecinatto@ufam.edu.br                                                         #
# Version 1, Aug 20, 2022                                                                                        #
##################################################################################################################
############################################################################################ p ###################
# LICENSE INFORMATION                                                     ################## D ###################
#                                                                         ################## o ###################
# This program is free software: you can redistribute it and/or modify    ################## s ###################
# it under the terms of the GNU General Public License as published by    ################## B ###################
# the Free Software Foundation, either version 3 of the License, or       ################## a ###################
# (at your option) any later version.                                     ################## n ###################
#                                                                         ################## d ###################
# This program is distributed in the hope that it will be useful,         ################## P ###################
# but WITHOUT ANY WARRANTY; without even the implied warranty of          ################## l ###################
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           ################## o ###################
# GNU General Public License for more details.                            ################## t ###################
#                                                                         ################## . ###################
# You should have received a copy of the GNU General Public License       ################## s ###################
# along with this program.  If not, see <https://www.gnu.org/licenses/>5. ################## h ###################
##################################################################################################################

##################################################################################################################
# INFORMATION ####################################################################################################
# This program is run in terminal as: bash pDosBandPlot.sh                ########################################
##################################################################################################################

# function to convert RGB to HEX color format 
rgb_to_hex() {
    printf '#%02x%02x%02x\n' "$1" "$2" "$3"
}

# Primary interface function: no previous data
INTERFACEFUNCTION1() {
    rc=0
    until [[ $rc == 1 ]]
    do
        interface=$(
        zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
        --add-entry="Hight symmetry points (Gamma sintax is G)" \
        --add-entry="Energy range (format Emin:Emax)" \
        --add-combo="Y axis title" \
        --combo-values="Energy (eV)|Energia (eV)" \
        --add-combo="Y axis offset" \
        --combo-values="-2.0|-1.5|-1.0|-0.5|0|0.5|1.0|1.5|2.0" \
        --add-combo="Font size" \
        --combo-values="10|12|14" \
        --add-combo="Line width" \
        --combo-values="1.0|1.5|2.0|2.5|3.0|3.5|4.0" \
        --add-entry="Title graph"\
        --add-list="Energy reference" \
        --column-values="Option|Description" \
        --list-values="0|Not normalized energy|1|Normalized by Fermi Energy OR highest occupied level energy|2|Normalized by first level energy below of Fermi energy" --show-header \
        --add-combo="Energy reference line color" \
        --combo-values="black|red|blue|green|" \
        --add-combo="Gap color (it works if nbnd is set in scf.in)" \
        --combo-values="NONE|black|red|blue|green|yellow|orange|violet|cyan|brown" \
        --add-combo="[P]DOS plot" \
        --combo-values="yes|no" \
        ) 

        rc=$?

        if [[ $rc == 0 ]]
        then  
            break  
        fi   
    done

    if [ $rc == 1 ]
    then
        exit
    fi

    mkdir -p plot/cache

    if [ -d pdos-data ]
    then
        pdosDataVar="yes"
    elif [ ! -d pdos-data ]
    then
        pdosDataVar="no"
    fi

    cd plot/cache   

        echo $interface | cut -d \| -f1 > symmetryPoints.txt
        echo $interface | cut -d \| -f2 > yRange.txt
        echo $interface | cut -d \| -f3 > yTitle.txt
        echo $interface | cut -d \| -f4 > yOffSet.txt
        echo $interface | cut -d \| -f5 > fontSize.txt                                                                               
        echo $interface | cut -d \| -f6 > lineWidth.txt
        echo $interface | cut -d \| -f7 > titleGraph.txt
        echo $interface | cut -d \| -f8 | cut -b 1 > reference.txt
        echo $interface | cut -d \| -f9 > referenceLineColor.txt
        echo $interface | cut -d \| -f10 > gapColor.txt
        echo $interface | cut -d \| -f11 > dospdosplot.txt

        symmetryPoints=($(awk '{print $0}' symmetryPoints.txt))
        yRange=$(awk '{print $0}' yRange.txt)
        yTitle=$(awk '{print $0}' yTitle.txt)
        yOffSet=$(awk '{print $0}' yOffSet.txt)
        fontSize=$(awk '{print $0}' fontSize.txt)                                                                               
        lineWidth=$(awk '{print $0}' lineWidth.txt)
        titleGraph=$(awk '{print $0}' titleGraph.txt)
        reference=$(awk '{print $0}' reference.txt)
        referenceLineColor=$(awk '{print $0}' referenceLineColor.txt)
        gapColor=$(awk '{print $0}' gapColor.txt)
        dospdosplot=$(awk '{print $0}' dospdosplot.txt)

        if [ "$dospdosplot" == "yes" -a "$pdosDataVar" == "yes" ]
        then
            rc=0
            until [[ $rc == 1 ]]
            do
                interfacex=$(
                zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                --add-entry="DOS-PDOS range maximmum (format Dmax)" \
                --add-entry="DOS-PDOS tics (format start,step,end)" \
                --add-combo="PDOS legend position" \
                --combo-values="top|bottom" \
                --add-combo="PDOS (atoms)" \
                --combo-values="yes|no" \
                --add-combo="PDOS (orbitals)" \
                --combo-values="yes|no" \
                --add-combo="DOS" \
                --combo-values="yes|no" \
                ) 

                rc=$?

                if [[ $rc == 0 ]]
                then  
                    break  
                fi   
            done

            if [ $rc == 1 ]
            then
                exit
            fi

            echo $interfacex | cut -d \| -f1 > dosRangeMax.txt
            echo $interfacex | cut -d \| -f2 > dosTics.txt
            echo $interfacex | cut -d \| -f3 > dosLegend.txt
            echo $interfacex | cut -d \| -f4 > pdosAtoms.txt
            echo $interfacex | cut -d \| -f5 > pdosOrbitals.txt
            echo $interfacex | cut -d \| -f6 > dos.txt

            dosRangeMax=$(awk '{print $0}' dosRangeMax.txt)
            dosTics=$(awk '{print $0}' dosTics.txt)
            dosLegend=$(awk '{print $0}' dosLegend.txt)
            pdosAtoms=$(awk '{print $0}' pdosAtoms.txt)
            pdosOrbitals=$(awk '{print $0}' pdosOrbitals.txt)
            dos=$(awk '{print $0}' dos.txt)

        elif [ "$dospdosplot" == "yes" -a "$pdosDataVar" == "no" ]
        then
            cd .. && cd ..
            rm -r plot 
            zenity --error --text="Invalid option '$dospdosplot' for '[P]DOS plot'. The 'pdos-data' folder not found. Set 'no' for this option or copy 'pdos-data' folder for the current directory." \
            --width=400 --height=100
            exit
        fi

        rcx=0
        until [[ $rcx == 1 ]]; do
            colorRGBL=`zenity --color-selection --title="band Line Color" --show-palette`

            rcx=$?

            if [[ $rcx == 0 ]]
            then  
                break  
            fi     
        done

        if [ $rcx == 1 ]
        then
            exit
        fi

        echo $colorRGBL | sed -e 's/,/ /g' | sed -e 's/(//g'| sed -e 's/)//g'| sed -e 's/rgb//g' > colorTEMPL.txt
        colorx=$(awk '{print $1}' colorTEMPL.txt)
        colory=$(awk '{print $2}' colorTEMPL.txt)
        colorz=$(awk '{print $3}' colorTEMPL.txt)
        echo $(rgb_to_hex "$colorx" "$colory" "$colorz") > bandLineColor.txt
        bandLineColor=$(rgb_to_hex "$colorx" "$colory" "$colorz")

    cd .. && cd .. 

}

# Secundary interface function: previous data 
INTERFACEFUNCTION2() {
    if [ -d pdos-data ]
    then
        pdosDataVar="yes"
    elif [ ! -d pdos-data ]
    then
        pdosDataVar="no"
    fi

    cd plot/cache

        symmetryPoints=($(awk '{print $0}' symmetryPoints.txt))
        yRange=$(awk '{print $0}' yRange.txt)
        yTitle=$(awk '{print $0}' yTitle.txt)
        yOffSet=$(awk '{print $0}' yOffSet.txt)
        fontSize=$(awk '{print $0}' fontSize.txt)                                                                               
        lineWidth=$(awk '{print $0}' lineWidth.txt)
        titleGraph=$(awk '{print $0}' titleGraph.txt)
        reference=$(awk '{print $0}' reference.txt)
        referenceLineColor=$(awk '{print $0}' referenceLineColor.txt)
        gapColor=$(awk '{print $0}' gapColor.txt)
        bandLineColor=$(awk '{print $0}' bandLineColor.txt)
        dospdosplot=$(awk '{print $0}' dospdosplot.txt)

        if [ "$dospdosplot" == "yes" ]
        then
            dosRangeMax=$(awk '{print $0}' dosRangeMax.txt)
            dosTics=$(awk '{print $0}' dosTics.txt)
            dosLegend=$(awk '{print $0}' dosLegend.txt)
            pdosAtoms=$(awk '{print $0}' pdosAtoms.txt)
            pdosOrbitals=$(awk '{print $0}' pdosOrbitals.txt)
            dos=$(awk '{print $0}' dos.txt)

            cache=$(zenity --list --checklist --title="Previous data was found" --ok-label=Submit --height=500 --width=700\
            --text="Previously used data was found, select to change"\
            --column="Select to modify"\
            --column="Parameter"\
            --column="Value"\
            FALSE  "Hight symmetry points" "$(awk '{print $0}' symmetryPoints.txt)"\
            FALSE "Energy range" " $yRange"\
            FALSE "Y axis title" "$yTitle"\
            FALSE "Y axis offset" " $yOffSet"\
            FALSE "Font size" "$fontSize"\
            FALSE "Line width" "$lineWidth"\
            FALSE "Title graph" " $titleGraph"\
            FALSE "Energy reference" " Option $reference"\
            FALSE "Energy reference line color" "$referenceLineColor"\
            FALSE "Gap color" "$gapColor"\
            FALSE "Band line color" "$bandLineColor"\
            FALSE "DOS-PDOS range maximmum (format Dmax)" "$dosRangeMax"\
            FALSE "DOS-PDOS tics (format start,step,end)" "$dosTics"\
            FALSE "PDOS legend position" "$dosLegend"\
            FALSE "PDOS (atoms)" "$pdosAtoms"\
            FALSE "PDOS (orbitals)" "$pdosOrbitals"\
            FALSE "DOS" "$dos"\
            )
            rc=$? 

            if [ $rc == 1 ]
            then
                exit
            fi

        elif [ "$dospdosplot" == "no" ]
        then
            cache=$(zenity --list --checklist --title="Previous data was found" --ok-label=Submit --height=500 --width=700\
            --text="Previously used data was found, select to change"\
            --column="Select to modify"\
            --column="Parameter"\
            --column="Value"\
            FALSE  "Hight symmetry points" "$(awk '{print $0}' symmetryPoints.txt)"\
            FALSE "Energy range" " $yRange"\
            FALSE "Y axis title" "$yTitle"\
            FALSE "Y axis offset" " $yOffSet"\
            FALSE "Font size" "$fontSize"\
            FALSE "Line width" "$lineWidth"\
            FALSE "Title graph" " $titleGraph"\
            FALSE "Energy reference" " Option $reference"\
            FALSE "Energy reference line color" "$referenceLineColor"\
            FALSE "Gap color" "$gapColor"\
            FALSE "Band line color" "$bandLineColor"\
            FALSE "[P]DOS plot" "$dospdosplot"\
            )
            rc=$? 

            if [ $rc == 1 ]
            then
                exit
            fi
        fi


        echo $cache | sed -z 's/|/\n/g' > cache.txt
        numberLine=$(wc -l < cache.txt)

        for i in $(seq 1 1 $numberLine)
        do
            lineCache=$(awk 'NR=='$i'{print $0}' cache.txt)
            rc=0

            if [ "$lineCache" == "Hight symmetry points" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-entry="Hight symmetry points (Gamma sintax is G)"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > symmetryPoints.txt && symmetryPoints=($(awk '{print $0}' symmetryPoints.txt))

            elif [ "$lineCache" == "Energy range" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-entry="Energy range (format Emin:Emax)"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > yRange.txt && yRange=$(awk '{print $0}' yRange.txt)
                
            elif [ "$lineCache" == "Y axis title" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Y axis title" \
                    --combo-values="Energy (eV)|Energia (eV)"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > yTitle.txt && yTitle=$(awk '{print $0}' yTitle.txt)
            
            elif [ "$lineCache" == "Y axis offset" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Y axis offset" \
                    --combo-values="-2.0|-1.5|-1.0|-0.5|0|0.5|1.0|1.5|2.0"
                    ) 
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > yOffSet.txt && yOffSet=$(awk '{print $0}' yOffSet.txt)
            
            elif [ "$lineCache" == "Font size" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Font size" \
                    --combo-values="10|12|14"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > fontSize.txt && fontSize=$(awk '{print $0}' fontSize.txt)
            
            elif [ "$lineCache" == "Line width" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Line width" \
                    --combo-values="1.0|1.5|2.0|2.5|3.0|3.5|4.0"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > lineWidth.txt && lineWidth=$(awk '{print $0}' lineWidth.txt)
            
            elif [ "$lineCache" == "Title graph" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-entry="Title graph"
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi
                echo $interface > titleGraph.txt && titleGraph=$(awk '{print $0}' titleGraph.txt)

            elif [ "$lineCache" == "Energy reference" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" --width=400 --height=200 \
                    --add-list="Energy reference" \
                    --column-values="Option|Description" \
                    --list-values="0|Not normalized energy|1|Normalized by Fermi Energy OR highest occupied level energy|2|Normalized by first level energy below of Fermi energy" --show-header \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface | cut -b 1 > reference.txt && reference=$(awk '{print $0}' reference.txt)
                
            elif [ "$lineCache" == "Energy reference line color" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Energy reference line color" \
                    --combo-values="black|red|blue|green|" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > referenceLineColor.txt && referenceLineColor=$(awk '{print $0}' referenceLineColor.txt)

            elif [ "$lineCache" == "Band line color" ]
            then
                until [[ $rc == 1 ]]; do
                    colorRGBL=`zenity --color-selection --title="band Line Color" --show-palette`

                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi     
                done

                if [ $rc == 1 ]
                then
                    exit
                fi

                echo $colorRGBL | sed -e 's/,/ /g' | sed -e 's/(//g'| sed -e 's/)//g'| sed -e 's/rgb//g' > colorTEMPL.txt
                colorx=$(awk '{print $1}' colorTEMPL.txt)
                colory=$(awk '{print $2}' colorTEMPL.txt)
                colorz=$(awk '{print $3}' colorTEMPL.txt)
                echo $(rgb_to_hex "$colorx" "$colory" "$colorz") > bandLineColor.txt
                bandLineColor=$(rgb_to_hex "$colorx" "$colory" "$colorz")

            elif [ "$lineCache" == "[P]DOS plot" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="[P]DOS plot" \
                    --combo-values="yes|no" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi

                echo $interface > dospdosplot.txt && dospdosplot=$(awk '{print $0}' dospdosplot.txt)

                if [ "$dospdosplot" == "yes" -a "$pdosDataVar" == "no" ]
                then
                    cd .. && cd ..
                    rm -r plot 
                    zenity --error --text="Invalid option '$dospdosplot' for '[P]DOS plot'. The 'pdos-data' folder not found. Set 'no' for this option or copy 'pdos-data' folder for the current directory." \
                    --width=400 --height=100 
                    exit
                fi
                
                if [ "$dospdosplot" == "yes" -a "$pdosDataVar" == "yes" ]
                then
                    rc=0
                    until [[ $rc == 1 ]]
                    do
                        interfacex=$(
                        zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                        --add-entry="DOS-PDOS range maximmum (format Dmax)" \
                        --add-entry="DOS-PDOS tics (format start,step,end)" \
                        --add-combo="PDOS legend position" \
                        --combo-values="top|bottom" \
                        --add-combo="PDOS (atoms)" \
                        --combo-values="yes|no" \
                        --add-combo="PDOS (orbitals)" \
                        --combo-values="yes|no" \
                        --add-combo="DOS" \
                        --combo-values="yes|no" \
                        ) 

                        rc=$?

                        if [[ $rc == 0 ]]
                        then  
                            break  
                        fi   
                    done

                    if [ $rc == 1 ]
                    then
                        exit
                    fi

                    echo $interfacex | cut -d \| -f1 > dosRangeMax.txt
                    echo $interfacex | cut -d \| -f2 > dosTics.txt
                    echo $interfacex | cut -d \| -f3 > dosLegend.txt
                    echo $interfacex | cut -d \| -f4 > pdosAtoms.txt
                    echo $interfacex | cut -d \| -f5 > pdosOrbitals.txt
                    echo $interfacex | cut -d \| -f6 > dos.txt

                    dosRangeMax=$(awk '{print $0}' dosRangeMax.txt)
                    dosTics=$(awk '{print $0}' dosTics.txt)
                    dosLegend=$(awk '{print $0}' dosLegend.txt)
                    pdosAtoms=$(awk '{print $0}' pdosAtoms.txt)
                    pdosOrbitals=$(awk '{print $0}' pdosOrbitals.txt)
                    dos=$(awk '{print $0}' dos.txt)
                fi 


            elif [ "$lineCache" == "DOS-PDOS range maximmum (format Dmax)" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-entry="DOS-PDOS range maximmum (format Dmax)" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > dosRangeMax.txt && dosRangeMax=$(awk '{print $0}' dosRangeMax.txt)

            elif [ "$lineCache" == "DOS-PDOS tics (format start,step,end)" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-entry="DOS-PDOS tics (format start,step,end)" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > dosTics.txt && dosTics=$(awk '{print $0}' dosTics.txt)

            elif [ "$lineCache" == "PDOS legend position" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="PDOS legend position" \
                    --combo-values="top|bottom" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > dosLegend.txt && dosLegend=$(awk '{print $0}' dosLegend.txt)

            elif [ "$lineCache" == "PDOS (atoms)" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="PDOS (atoms)" \
                    --combo-values="yes|no" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > pdosAtoms.txt && pdosAtoms=$(awk '{print $0}' pdosAtoms.txt)

            elif [ "$lineCache" == "PDOS (orbitals)" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="PDOS (orbitals)" \
                    --combo-values="yes|no" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > pdosOrbitals.txt && pdosOrbitals=$(awk '{print $0}' pdosOrbitals.txt)

            elif [ "$lineCache" == "DOS" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="DOS" \
                    --combo-values="yes|no" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > dos.txt && dos=$(awk '{print $0}' dos.txt)

            elif [ "$lineCache" == "Gap color" ]
            then
                until [[ $rc == 1 ]]
                do
                    interface=$(
                    zenity --forms --title="tools-pDosBandPlot" --ok-label=Submit --text="Input Parameters:" \
                    --add-combo="Gap color" \
                    --combo-values="NONE|black|red|blue|green|yellow|orange|violet|cyan|brown" \
                    )
                    rc=$?

                    if [[ $rc == 0 ]]
                    then  
                        break  
                    fi   
                done

                if [ $rc == 1 ]
                then
                    exit
                fi 
                echo $interface > gapColor.txt && gapColor=$(awk '{print $0}' gapColor.txt)
            fi
        done

    cd .. && cd ..

}

# Run Graphical interface to input variables with Zenity 
if [ ! -d band-data ]
then
    if [ -f "$(ls *.scf.out)" ] && [ -f "bands.out" ] && [ -f "$(ls *.dat.gnu)" ]
    then
        echo "files was found..."
    else
        zenity --error --text="band files not found." --width=200
        exit
    fi
fi

if [ -d plot ] && [ ! -d plot/cache ]                                                                              
then
    rm -r plot
    INTERFACEFUNCTION1                                                                                       
fi 

if [ -d plot/cache ]                                                                             
then
    INTERFACEFUNCTION2                                                                                      
fi

if [ ! -d plot ]                                                                              
then
  INTERFACEFUNCTION1
fi

ARRAYSP=(0 HSPA1 HSPB2 HSPC3 HSPD4 HSPE5 HSPF6 HSPH7 HSPI8 HSPJ9 HSPK10 HSPL11 HSPM12 HSPN13 HSPO14 HSPP15 HSPQ16)
CNOHSP=${#symmetryPoints[@]}

for m in $(seq 1 1 $CNOHSP)
do 
    n=$(($m-1))
    if [ $m -eq 1 ]
    then
        echo -n "'${symmetryPoints[n]}' ${ARRAYSP[m]}" > simmetryPoints.txt
    else
        echo -n ", '${symmetryPoints[n]}' ${ARRAYSP[m]}" >> simmetryPoints.txt
    fi
done

sed -e 's/G/$\\Gamma$/g' -i simmetryPoints.txt

plotSimmetryP=$(awk '{print $0}' simmetryPoints.txt) && rm simmetryPoints.txt 

FolderJob=${PWD##*/}

if [ ! -d band-data ]
then
    if [ -f "$(ls *.scf.out)" ]
    then
        echo "$(ls *.scf.out) file was found in $FolderJob folder"
    else
        zenity --error --text="scf.out file not found in $FolderJob folder."
        exit
    fi
    
    if [ -f "bands.out" ]
    then
        echo "bands.out file was found in $FolderJob folder"
    else
        zenity --error --text="bands.out file not found in $FolderJob folder."
        exit
    fi
    
    if [ -f "$(ls *.dat.gnu)" ]
    then
        echo "$(ls *.dat.gnu) file was found in $FolderJob folder"
    else
        zenity --error --text="bands.out file not found in $FolderJob folder."
        exit
    fi

    mkdir band-data
    cp $(ls *.scf.out) bands.out $(ls *.dat.gnu) ./band-data
fi

if [ -d band-data ]
then
    cd band-data

        if [ -f "$(ls *.scf.out)" ]
        then
            echo "$(ls *.scf.out) file was found in band-data folder"
        else
            zenity --error --text="scf.out file not found in band-data folder."
            exit
        fi
        
        if [ -f "bands.out" ]
        then
            echo "bands.out file was found in band-data folder"
        else
            zenity --error --text="bands.out file not found in band-data folder."
            exit
        fi
        
        if [ -f "$(ls *.dat.gnu)" ]
        then
            echo "$(ls *.dat.gnu) file was found in band-data folder"
        else
            zenity --error --text="bands.out file not found in band-data folder."
            exit
        fi

    cd ..
fi

bandFiles=$(ls band-data/* | sed 's/band-data\///g')
cp ./band-data/* ./plot

if [ -d pdos-data ]
then
    pdosFiles=$(ls pdos-data/* | sed 's/pdos-data\///g')
    cp ./pdos-data/* ./plot
    pdosDataVar="yes"
fi

cd plot

    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out//g")

    # Metal 
    if grep -Fq "the Fermi energy" $(ls *.scf.out)
    then                                                                                                                                                                    
        grep "high-symmetry point:" bands.out > high.txt                                           
        awk '{print $NF}' high.txt >> hight.txt                                                     
        NUMBER_HSP=$(wc -l < hight.txt)                                                             
        rm high.txt                                                                                 
        echo $(grep -w "the Fermi energy" $(ls *.scf.out)) > Fermi.txt                                       
        sed -e "s/the Fermi energy is//g" -i Fermi.txt                                              
        sed -e "s/ev//g" -i Fermi.txt                                                               
        FERMIENERGY=$(awk '{print $1}' Fermi.txt)                                                   
                                                                                                
        awk '{FERMI='$FERMIENERGY'; print FERMI - $2}' $(ls *.dat.gnu) > RefA.txt                     
        grep -v "-" RefA.txt > RefB.txt                                                             
        awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' RefB.txt > min.txt          
        REF=$(awk '{print $1}' min.txt) 
        rm RefA.txt RefB.txt min.txt                                                           
                                                                                                
        if [ $reference -eq 0 ]                                                                     
        then                                                                                                
            REFHOLVB1=$(echo $FERMIENERGY*0 | bc -l)                                                
            REFHOLVB2=$(echo $REF*0 | bc -l)
            RLINE=$(echo $FERMIENERGY)                                                                                                                                                           
                                                                                                
        elif [ $reference -eq 1 ]                                                                     
        then                                                                                                
            REFHOLVB1=$(echo $FERMIENERGY)                                                          
            REFHOLVB2=$(echo $REF*0 | bc -l)
            RLINE=0                                                                                                                                                             
                                                                                                
        elif [ $reference -eq 2 ]                                                                     
        then                                                                                        
            REFHOLVB1=$(echo $FERMIENERGY)                                                          
            REFHOLVB2=$(echo $REF)
            RLINE=0                                                                  
        fi                                                                                          
                                                                                                
        REFHOLVB=$(echo $REFHOLVB1-$REFHOLVB2 | bc -l)

        if [ "$dospdosplot" == "yes" ]
        then
            if [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.135
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set key $dosLegend right
set key font ",9"
set key spacing 1.5

set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize5=xsize

set size xsize5,1                      
set lmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+xsize5+sum+sum+sum         


EOF5

                sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu
                
                #pdos-orb
                A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                COL='$1'
                
                if [[ "${A[*]}" =~ "s" ]]; 
                then
                    echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                fi
                
                if [[ "${A[*]}" =~ "p" ]]; 
                then
                    echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "d" ]]; 
                then
                    echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "f" ]]; 
                then
                    echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                fi

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #dos
                COL='$1'
                echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                #pdos-atom
                E=($(awk '{print $0}' elements.txt))
                CNE=${#E[@]}

                for q in $(seq 1 1 $CNE)
                do 
                    n=$(($q-1))
                    styleLine=$(($q+4))
                    COL='$1'
                    
                    if [ $n -eq 0 ]                                                                     
                    then
                        echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                    else
                        echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 5-pdos-atom-plot.gnu
                    fi
                done

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu

            elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital/g")

cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.8
set key font ",7"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF5

                sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
                
                #pdos-orb
                A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                COL='$1'
                
                if [[ "${A[*]}" =~ "s" ]]; 
                then
                    echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                fi
                
                if [[ "${A[*]}" =~ "p" ]]; 
                then
                    echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "d" ]]; 
                then
                    echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "f" ]]; 
                then
                    echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                fi

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #pdos-atom
                E=($(awk '{print $0}' elements.txt))
                CNE=${#E[@]}

                for q in $(seq 1 1 $CNE)
                do 
                    n=$(($q-1))
                    styleLine=$(($q+4))
                    COL='$1'
                    
                    if [ $n -eq 0 ]                                                                     
                    then
                        echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                    else
                        echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                    fi
                done

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
            
            elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom/g")
            
        
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset ylabel
set format y ""

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF5

                sed -e "s/*//g" -i 3-band-plot.gnu 5-pdos-atom-plot.gnu
                
                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #pdos-atom
                E=($(awk '{print $0}' elements.txt))
                CNE=${#E[@]}

                for q in $(seq 1 1 $CNE)
                do 
                    n=$(($q-1))
                    styleLine=$(($q+4))
                    COL='$1'
                    
                    if [ $n -eq 0 ]                                                                     
                    then
                        echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                    else
                        echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                    fi
                done

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu


            elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 2-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF2 > 3-pdos-orb-plot.gnu
###### PDOS-ORB

unset ylabel
set format y ""

unset xtics 
set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set ytics out
set ytics nomirror

set xrange [0:$dosRangeMax]

set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum  


EOF2

                sed -e "s/*//g" -i 2-band-plot.gnu 3-pdos-orb-plot.gnu
                
                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 2-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 2-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 2-band-plot.gnu                                             
                done

                #pdos-orb
                A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                COL='$1'
                
                if [[ "${A[*]}" =~ "s" ]]; 
                then
                    echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 3-pdos-orb-plot.gnu
                fi
                
                if [[ "${A[*]}" =~ "p" ]]; 
                then
                    echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 3-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "d" ]]; 
                then
                    echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 3-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "f" ]]; 
                then
                    echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 3-pdos-orb-plot.gnu
                fi

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 2-band-plot.gnu 3-pdos-orb-plot.gnu 
            
            elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum          


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset ylabel
set format y ""
set ytics nomirror

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF4


                sed -e "s/*//g" -i 3-band-plot.gnu 4-dos-plot.gnu

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #dos
                COL='$1'
                echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

            elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4


                sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu
                
                #pdos-orb
                A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                COL='$1'
                
                if [[ "${A[*]}" =~ "s" ]]; 
                then
                    echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                fi
                
                if [[ "${A[*]}" =~ "p" ]]; 
                then
                    echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "d" ]]; 
                then
                    echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                fi

                if [[ "${A[*]}" =~ "f" ]]; 
                then
                    echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                fi

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #dos
                COL='$1'
                echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

            elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-atom-plot.gnu
###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4
    
                sed -e "s/*//g" -i 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 

                #pdos-atom
                E=($(awk '{print $0}' elements.txt))
                CNE=${#E[@]}

                for q in $(seq 1 1 $CNE)
                do 
                    n=$(($q-1))
                    styleLine=$(($q+4))
                    COL='$1'
                    
                    if [ $n -eq 0 ]                                                                     
                    then
                        echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 2-pdos-atom-plot.gnu
                    else
                        echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 2-pdos-atom-plot.gnu
                    fi
                done
                
                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                #dos
                COL='$1'
                echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                rm 1-essentials-plot.gnu 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

            elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                dospdos="no"
            fi
        fi

        if [[ $dospdosplot == "no" || $dospdos == "no" ]]
        then
            name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-100:100]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out
set ytics nomirror

unset key
set title "\*\scriptsize $titleGraph"

xsize3=xsize+0.55
#xsize3=xsize2+0.34

set size 1,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3
    
EOF3
            sed -e "s/*//g" -i 3-band-plot.gnu

            #band
            COL='$2'

            echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

            VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                        
            for k in $(seq 2 $VARHSP)                                                                    
            do                                                                                          
                echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
            done                                                                                          
                                                                                                        
            for i in $(seq 1 $NUMBER_HSP)                                                                
            do                                                                                           
                Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
            done

            awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
    
            rm 1-essentials-plot.gnu 3-band-plot.gnu
        fi
    fi

    # Semiconductor or isolant
    if grep -Fq "highest occupied" $(ls *.scf.out)
    then
        # With nbnd in scf calculation
        if grep -Fq "lowest unoccupied level" $(ls *.scf.out)
        then
            if [ "$gapColor" == "NONE" ] || [ "$gapColor" == " " ]
            then
                gapColor='white'
            fi
                                                                                                              
            grep "high-symmetry point:" bands.out > high.txt
            awk '{print $NF}' high.txt > hight.txt
            NUMBER_HSP=$(wc -l < hight.txt)
            rm high.txt                                                                                                           
            echo $(grep -w "highest" $(ls *.scf.out)) > HL.txt                                                             
            sed -e "s/highest occupied, lowest unoccupied level (ev)://g" -i HL.txt                                 
            awk '{print $2-$1}' HL.txt > gap.txt                                                                                                       
            HIX=$(awk '{print $1}' HL.txt)                                                                                                              
            LOX=$(awk '{print $2}' HL.txt)
            rm HL.txt                                                                

            if [ $reference -eq 0 ]                                                                     
            then                                                                                                
                REFHOLVB=$(echo $HIX*0 | bc -l)
                YHL1=$(echo $HIX)
                YHL2=$(echo $LOX)
                RLINE=$(echo $HIX)                                                                                                               
        
            elif [ $reference -eq 1 ]                                                                     
            then                                                                                                
                REFHOLVB=$(echo $HIX)
                YHL1=0
                YHL2=$(echo $LOX-$HIX | bc -l)
                RLINE=0                                                                                                                

            elif [ $reference -eq 2 ]
            then
                zenity --error --text="Invalid option for 'Energy reference' for current Job. \nSet 0 or 1 for this variable" \
                --width=200 --height=100 
                exit
            fi

            if [ "$dospdosplot" == "yes" ]
            then
                if [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital-dos/g")
                                                                                                                             
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.135
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set key $dosLegend right
set key font ",9"
set key spacing 1.5

set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize5=xsize

set size xsize5,1                      
set lmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+xsize5+sum+sum+sum         


EOF5

                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu

                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital/g")

cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.8
set key font ",7"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF5

                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
                
                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom/g")
                
            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset ylabel
set format y ""

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF5

                    sed -e "s/*//g" -i 3-band-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu


                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital/g")
                                                                                                                             
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 2-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF2 > 3-pdos-orb-plot.gnu
###### PDOS-ORB

unset ylabel
set format y ""

unset xtics 
set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set ytics out
set ytics nomirror

set xrange [0:$dosRangeMax]

set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key spacing 1.5
set key font ",9"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum  


EOF2

                    sed -e "s/*//g" -i 2-band-plot.gnu 3-pdos-orb-plot.gnu
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 2-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 2-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 2-band-plot.gnu                                             
                    done

                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 3-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 3-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 3-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 3-pdos-orb-plot.gnu
                    fi

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-band-plot.gnu 3-pdos-orb-plot.gnu 
                
                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-dos/g")
                                                                                                                                
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum          


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset ylabel
set format y ""
set ytics nomirror

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF4


                    sed -e "s/*//g" -i 3-band-plot.gnu 4-dos-plot.gnu

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital-dos/g")
                                                                                                                             
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4


                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-dos/g")
                                                                                                                             
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-atom-plot.gnu
###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $dosRangeMax,$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel
set ytics nomirror

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4
     
                    sed -e "s/*//g" -i 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 2-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 2-pdos-atom-plot.gnu
                        fi
                    done
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                    dospdos="no"
                fi
            fi

            if [[ $dospdosplot == "no" || $dospdos == "no" ]]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                                                                                                                             
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
LULCB=$LOX
M(t)=t
set parametric
set trange [-100:100]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out
set ytics nomirror

unset key
set title "\*\scriptsize $titleGraph"

xsize3=xsize+0.55
#xsize3=xsize2+0.34

set size 1,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3

set style rect fc "$gapColor" fs solid 0.20 noborder
set obj rect from $(awk 'NR==1{print $1}' hight.txt),$YHL1 to $(awk 'END{print}' hight.txt),$YHL2
      
EOF3
                sed -e "s/*//g" -i 3-band-plot.gnu

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
        
                rm 1-essentials-plot.gnu 3-band-plot.gnu
            fi
        fi

        #without nbnd in scf calculation
        if ! grep -Fq "lowest unoccupied level" $(ls *.scf.out)
        then
                                                                                                    
            grep "high-symmetry point:" bands.out > high.txt
            awk '{print $NF}' high.txt > hight.txt
            NUMBER_HSP=$(wc -l < hight.txt)
            rm high.txt                                                                                                        
            echo $(grep -w "highest" $(ls *.scf.out)) > HL.txt                                                                
            sed -e "s/highest occupied level (ev)://g" -i HL.txt                                                                               
            HIX=$(awk '{print $1}' HL.txt)                                                                                                              
    
            if [ $reference -eq 0 ]                                                                     
            then                                                                                                
                REFHOLVB=$(echo $HIX*0 | bc -l)
                RLINE=$(echo $HIX)                                                                                                                
            fi 
            
            if [ $reference -eq 1 ]                                                                     
            then                                                                                                
                REFHOLVB=$(echo $HIX)
                RLINE=0                                                                                                              
            fi

            if [ $reference -eq 2 ]
            then
                zenity --error --text="Invalid option for 'Energy reference' for current Job. \nSet 0 or 1 for this variable" \
                --width=200 --height=100  
                exit
            fi                                                                                                                             

            if [ "$dospdosplot" == "yes" ]
            then
                if [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.135
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set key $dosLegend right
set key font ",9"
set key spacing 1.5

set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize5=xsize

set size xsize5,1                      
set lmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+xsize5+sum+sum+sum         


EOF5

                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 5-pdos-atom-plot.gnu

                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-orbital/g")

cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.8
set key font ",7"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF5

                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu
                
                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom/g")
            
        
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
#xsize=0.15
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF5 > 5-pdos-atom-plot.gnu

###### PDOS-ATOM

unset ylabel
set format y ""

unset xtics

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key font ",7"
set key spacing 1.8

set noylabel
set ytics out
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF5

                    sed -e "s/*//g" -i 3-band-plot.gnu 5-pdos-atom-plot.gnu
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 4 ti '\tiny Total' , '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 5-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\tiny ${E[n]}'" >> 5-pdos-atom-plot.gnu
                        fi
                    done

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 3-band-plot.gnu 5-pdos-atom-plot.gnu


                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 2-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum         


EOF3

cat << EOF2 > 3-pdos-orb-plot.gnu
###### PDOS-ORB

unset ylabel
set format y ""

unset xtics 
set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set ytics out
set ytics nomirror

set xrange [0:$dosRangeMax]

set xtics $dosTics
set xtics nomirror

set key $dosLegend right
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum  


EOF2

                    sed -e "s/*//g" -i 2-band-plot.gnu 3-pdos-orb-plot.gnu
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 2-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 2-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 2-band-plot.gnu                                             
                    done

                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 3-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 3-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 3-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 3-pdos-orb-plot.gnu
                    fi

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-band-plot.gnu 3-pdos-orb-plot.gnu 
                
                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize+0.35
#xsize3=xsize2+0.34

set size xsize3,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3+sum          


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset ylabel
set format y ""
set ytics nomirror

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize3+sum+sum          
set rmargin at screen  xinit+xsize3+xsize4+sum+sum          


EOF4


                    sed -e "s/*//g" -i 3-band-plot.gnu 4-dos-plot.gnu

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "yes" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-orbital-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-orb-plot.gnu
###### PDOS-ORB

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4


                    sed -e "s/*//g" -i 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu
                    
                    #pdos-orb
                    A=($(ls *orb.dat | sed "s/_orb.dat//g"))

                    COL='$1'
                    
                    if [[ "${A[*]}" =~ "s" ]]; 
                    then
                        echo -n "plot 's_orb.dat' u 2:($COL-HOLVB) w l ls 5 ti '\scriptsize s', t,$RLINE w l ls 2 ti ''" >> 2-pdos-orb-plot.gnu
                    fi
                    
                    if [[ "${A[*]}" =~ "p" ]]; 
                    then
                        echo -n ", 'p_orb.dat' u 2:($COL-HOLVB) w l ls 6 ti '\scriptsize p'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "d" ]]; 
                    then
                        echo -n ", 'd_orb.dat' u 2:($COL-HOLVB) w l ls 7 ti '\scriptsize d'" >> 2-pdos-orb-plot.gnu
                    fi

                    if [[ "${A[*]}" =~ "f" ]]; 
                    then
                        echo -n ", 'f_orb.dat' u 2:($COL-HOLVB) w l ls 8 ti '\scriptsize f'" >> 2-pdos-orb-plot.gnu
                    fi

                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-orb-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "yes" -a "$pdosOrbitals" == "no" -a "$dos" == "yes" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band-pdos-atom-dos/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set multiplot layout 1,4
set tmargin at screen 0.89

xsize=0.18
xinit= 0.12   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-$dosRangeMax:$dosRangeMax]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF2 > 2-pdos-atom-plot.gnu
###### PDOS-ATOM

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]

set ytics out

set xrange [$dosRangeMax:0]

set xtics $dosTics
set xtics nomirror

set key $dosLegend left
set key spacing 1.5
set key font ",9"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize2=xsize

set size xsize2,1           
set lmargin at screen  xinit          
set rmargin at screen  xinit + xsize2   


EOF2

cat << EOF3 > 3-band-plot.gnu

###### BAND

unset ylabel
set format y ""
set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out

unset key
set title "\*\scriptsize $titleGraph"

set label 1 '' at graph 0.92,0.9 font ',8'

xsize3=xsize2+0.25

set size xsize3,1                      
set lmargin at screen  xinit+xsize2+sum          
set rmargin at screen  xinit+xsize2+xsize3+sum         


EOF3

cat << EOF4 > 4-dos-plot.gnu

###### DOS

unset xtics

set title "\*\scriptsize DOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"

set xrange [0:$dosRangeMax]
set xtics $dosTics

set xtics nomirror

set noylabel
set ytics nomirror

set label 1 '' at graph 0.92,0.9 font ',8'

xsize4=xsize

set size xsize4,1                      
set lmargin at screen  xinit+xsize2+xsize3+sum+sum          
set rmargin at screen  xinit+xsize2+xsize3+xsize4+sum+sum          


EOF4
    
                    sed -e "s/*//g" -i 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu 

                    #pdos-atom
                    E=($(awk '{print $0}' elements.txt))
                    CNE=${#E[@]}

                    for q in $(seq 1 1 $CNE)
                    do 
                        n=$(($q-1))
                        styleLine=$(($q+4))
                        COL='$1'
                        
                        if [ $n -eq 0 ]                                                                     
                        then
                            echo -n "plot '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}', t,$RLINE w l ls 2 ti ''" >> 2-pdos-atom-plot.gnu
                        else
                            echo -n ", '${E[n]}.dat' u 2:($COL-HOLVB) w l ls $styleLine ti '\scriptsize ${E[n]}'" >> 2-pdos-atom-plot.gnu
                        fi
                    done
                    
                    #band
                    COL='$2'

                    echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                    VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                                
                    for k in $(seq 2 $VARHSP)                                                                    
                    do                                                                                          
                        echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                    done                                                                                          
                                                                                                                
                    for i in $(seq 1 $NUMBER_HSP)                                                                
                    do                                                                                           
                        Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                        sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                    done

                    #dos
                    COL='$1'
                    echo -n "plot '$(ls *pdos_tot)' u 2:($COL-HOLVB) w l ls 1 ti '', t,$RLINE w l ls 2" >> 4-dos-plot.gnu

                    awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
                    rm 1-essentials-plot.gnu 2-pdos-atom-plot.gnu 3-band-plot.gnu 4-dos-plot.gnu

                elif [ "$pdosAtoms" == "no" -a "$pdosOrbitals" == "no" -a "$dos" == "no" ]
                then
                    name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                    dospdos="no"
                fi
            fi

            if [[ $dospdosplot == "no" || $dospdos == "no" ]]
            then
                name=$(echo $(ls *.scf.out) | sed -e "s/.scf.out/-band/g")
                                                                                                                            
cat << EOF1 > 1-essentials-plot.gnu
###### ESSENTIALS

set terminal epslatex standalone color colortext $fontSize
set output '${name}.tex'
set border lw $lineWidth

set tmargin at screen 0.89

xsize=0.18
xinit= 0.16   # The starting possition of the first plot
sum= 0.025     # Controls the separation between plots

HOLVB=$REFHOLVB
M(t)=t
set parametric
set trange [-100:100]

set style line 1 lc rgb "$bandLineColor" lw $lineWidth  
set style line 2 lc rgb "$referenceLineColor" dt 2 lw $lineWidth
set style line 3 lc rgb "black"
set style line 4 lc rgb "black" lw $lineWidth
set style line 5 lc rgb "red" lw $lineWidth 
set style line 6 lc rgb "blue" lw $lineWidth
set style line 7 lc rgb "dark-green" lw $lineWidth
set style line 8 lc rgb "dark-orange" lw $lineWidth
set style line 9 lc rgb "violet" lw $lineWidth
set style line 10 lc rgb "cyan" lw $lineWidth


EOF1

cat << EOF3 > 3-band-plot.gnu

###### BAND

set title "\*\scriptsize PDOS $\*\left(\*\frac{1}{\*\mbox{eV}}\*\right)$"
set ylabel "$yTitle" offset $yOffSet
set ytics format "%g"
set yrange [$yRange]
set ytics out

set xtics ($plotSimmetryP)
set xrange [$(awk 'NR==1{print $1}' hight.txt):$(awk 'NR=='$CNOHSP'{print}' hight.txt)]
set ytics out
set ytics nomirror

unset key
set title "\*\scriptsize $titleGraph"

xsize3=xsize+0.55
#xsize3=xsize2+0.34

set size 1,1                      
set lmargin at screen  xinit+sum          
set rmargin at screen  xinit+xsize3
    
EOF3
                sed -e "s/*//g" -i 3-band-plot.gnu

                #band
                COL='$2'

                echo -n "plot '$(ls *.dat.gnu)' u 1:($COL-HOLVB) w l ls 1, t,$RLINE w l ls 2" >> 3-band-plot.gnu      

                VARHSP=$(($NUMBER_HSP-1))                                                                    
                                                                                                            
                for k in $(seq 2 $VARHSP)                                                                    
                do                                                                                          
                    echo -n ", ${ARRAYSP[k]},t w l ls 3" >> 3-band-plot.gnu                                            
                done                                                                                          
                                                                                                            
                for i in $(seq 1 $NUMBER_HSP)                                                                
                do                                                                                           
                    Z=$(awk '{if(NR=='$i') print $0}' hight.txt)                                             
                    sed -e "s/${ARRAYSP[i]}/$Z/g" -i 3-band-plot.gnu                                             
                done

                awk '{print $0}' $(ls *plot.gnu) > dos-pdos-band-plot.gnu
        
                rm 1-essentials-plot.gnu 3-band-plot.gnu
            fi
        fi
    fi                                                                                          

gnuplot dos-pdos-band-plot.gnu                                                                          
latex ${name}.tex                                                                                                                         
dvips -o ${name}.eps ${name}.dvi                                                                                                   
epstopdf ${name}.eps                                                                                                                        
pdfcrop ${name}.pdf; mv ${name}-crop.pdf ${name}.pdf                                                
gs -r1600 -dNOPAUSE -dUseCropBox -dBATCH -sDEVICE=jpeg -sOutputFile=${name}.jpg ${name}.eps
rm $bandFiles $pdosFiles *.log *.dvi *.aux hight.txt dos-pdos-band-plot.gnu
if [ ! -d PDF ]
then
    mkdir PDF EPS JPG TEX
fi
mv ${name}.pdf ./PDF && mv ${name}.eps ./EPS && mv ${name}.jpg ./JPG && mv *-inc.eps ${name}.tex ./TEX
cd EPS && evince $name.eps

exit 0 
