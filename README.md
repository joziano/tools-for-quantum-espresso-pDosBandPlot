# Please, when using this tool, cite:

J. R. M. Monteiro, & Henrique Pecinatto. (2022). pDosBandPlot.sh/tools-for-quantum-espresso (v1.0). Zenodo. https://doi.org/10.5281/zenodo.7319835

# pDosBandPlot
  
  pDosBandPlot.sh is an auxiliary tool for Quantum Espresso Linux users. It semiautomates the plotting of electronic 
  band structure and Total[Partial] Density of States from Quantum Espresso output simulation data.
    
# 1. Requirements

  ### 1.1 **Gnuplot [version 5.2 or latest] (http://www.gnuplot.info/)** 

    sudo apt install gnuplot
    
  ### 1.2 **Latex (https://www.latex-project.org/)** 

    sudo apt install texlive-full
    
  ### 1.3 **Zenity [version 3.32 or latest] (https://help.gnome.org/users/zenity/3.32/)** 

    sudo apt install zenity
    
 # 2. Procedures  

  ### 2.1 **Only electronic band structure plot**
  
   **2.1.1** Copy pDosBandPlot.sh to folder with electronic band structure output data. 
      
   **2.1.2** Open terminal inside folder with electronic band structure output data and execute: 
   
    bash pDosBandPlot.sh
     
   **2.1.3** Insert the parameters in the respective fields (attention to the requested formats). The "[P]DOS plot" field  must be set to "no". See the example below: 

https://user-images.githubusercontent.com/94269819/201581745-2b2dc668-5a3a-4814-a54f-e52c88512db6.mov

   **2.1.4** A folder called plot is created and contains the graphics in eps, pdf, jpg and tex formats.

   **2.1.5** If you want to modify any parameter entered, just open a terminal in the folder  and run the program again. A dialog box will show the parameters to modify. See the example below:

https://user-images.githubusercontent.com/94269819/201586964-39f11deb-781d-48fa-a17d-bf5ae6b3fb2b.mov

  ### 3.1 **Electronic band structure and [P]DOS (combined) plot**
  
   **3.1.1** After the electronic band structure plot, the band-data folder is created. Copy this folder to a other directory, for example, Band[P]DOS. 
      
   **3.1.2** After the [P]DOS calculation and execution of the pdos-sum.sh (https://github.com/joziano/tools-for-quantum-espresso-pdos), the pdos-data folder is created. Copy this folder to the same directory as band-data.
   
   **3.1.3** Open terminal inside folder and execute:
              
    bash pDosBandPlot.sh
   
   **3.1.4** Insert the parameters in the respective fields (attention to the requested formats). The "[P]DOS plot" field  must be set to "yes". If you want to modify any parameter entered, just open a terminal in the folder  and run the program again. A dialog box will show the parameters to modify. See the example below: 

https://user-images.githubusercontent.com/94269819/201599212-331a1d1a-5201-4fcb-84d0-53f9c31155dd.mov






