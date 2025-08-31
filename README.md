[![github](https://img.shields.io/badge/NASA%20ADS-1994ESASP.373...67J-red)](https://articles.adsabs.harvard.edu/pdf/1994ESASP.373...67J)

# DIPPER: Diagnostics Inferring the Physics of Plasma and Emitted Radiation 

**Author:** Philip G. Judge

**Contact:** judge@ucar.edu ; mauricew@ucar.edu

<br>

## Summarizing if DIPPER is right for you

| <span></span> | <span></span> |
| --- | --- |
| **Targeted problems** |  |
|                  | tenuous plasma, "low energy" regime  |
|                  | LTE to optically thin plasmas  |
|                  | compilation of needed rate coefficients  |
|                  | teaching/learning spectroscopy  |
|                  | simple statistical equilibrium calculations  |
|                  | $\quad\quad$- including escape probabilities  |
|                  | simple non-equilibrium calculations  |
|                  | $\quad\quad$- evolution of atomic systems  |
|                  | provide "building blocks" of data and code to permit the user to make more sophisticated calculations  |
|                  | $\quad\quad$- e.g, detailed radiative transfer or radiation hydrodynamics  |
| **Limitations**       |  |
|                  | elements lighter than Zn (nuclear charge 30)  |
|                  | principal quantum numbers < 10  |
|                  | incomplete databases  |
|                  | photoionization data are summed over final states, and are split approximately over fine structure  |
|                  | no impact line broadening  |
|                  | no hyperfine structure  |
|                  | no configuration mixing  |
| **Cannot handle**     |  |
|                  | non-Maxwellian particle distributions  |
|                  | inner shell excitations (high energy phenomena)  |
|                  | atomic and spectral polarization  |
|                  | molecules  |
|                  | accurate radiative transfer  |


<br>

## What makes DIPPER unique?
- It is based upon the fast, flexible database software system written by D. Lindler for IDL, and takes some advantage of this system.
- It works with quantum numbers for atomic levels, enabling it to perform tasks otherwise difficult or very tedious, including a variety of data checks, calculations
based upon the atomic numbers, and searching and manipulating data based upon these quantum numbers.
- In principle, DIPPER can handle conditions from LTE to coronal-like conditions.
- There is some capability for estimating data for which no accurate parameters are
available, and for accounting for the effects of missing atomic levels.

<span></span>

## Requirement
- A database of atomic quantum states and transition rates is needed. The CHIANTI atomic database has been re-organized and reformatted into an assortment of database files that is convenient for the DIPPER code to access it for education and research purposes. 
- The database file sizes are too large to include in this repository.  
- The files are within a tar archive compressed with gzip that can be downloaded here: [DIPPER_dbase.tar.gz](https://www.mauricewilson.com/static/proxyonepager/datastorage/DIPPER_dbase.tar.gz)
- Unpack the file and place the "dbase" directory next to the "spectra" directory.
```
$ tar -xvz -f DIPPER_dbase.tar.gz
    dbase/
    dbase/ar85ci.dat
    dbase/ar85ct.dat
    dbase/bass5250.txt
    dbase/bass6302.txt
    dbase/bbsql.db
    dbase/bfsql.db
    dbase/cbbsql.db
    dbase/cbfsql.db
    dbase/ctab.dat
    dbase/htab.dat
    dbase/lvlsql.db
    dbase/mooreip.dat
    dbase/shull82.dat
    dbase/shull82changes.txt
    dbase/shull82changes.txt.gz
```

<span></span>

## Setting Conda Environment 
It is useful to create a conda environment first, like so:
```
$ conda create --name dipper
$ conda activate dipper
$ conda install python numpy astropy scipy matplotlib
```
<!--
$ conda install dipper
-->

<span></span>

## Download/clone the repository and (local) installation
The DIPPER package can be installed locally via a terminal (for macOS or Linux) or command prompt (for Windows) by running the following lines of code:
```
$ git clone https://github.com/MWilson1/dipper.git
$ cd dipper
$ pip install dist/dipper-0.0.0.tar.gz
```

<span></span>

## Example
- See the Jupyter Notebook full of examples on how DIPPER can be used [here](https://colab.research.google.com/drive/1aU5syF0ddQytI3-UoP6XiEAKPJUeAfay?usp=sharing). 
- "Save a copy" of that Jupyter Notebook onto your own Google Drive.  Access it and run the code through the "Colab" (or "Colaboratory") app on Google.

<span></span>

## Acknowledgment
DIPPER is the python version of the original HAOS-DIPER code written in IDL. HAOS-DIPER grew out of a need to work with and manipulate data for neutral atoms and atomic ions to understand radiation emitted by some space plasmas, notably the solar atmosphere and stellar atmospheres. An early version was described by [Judge and Meisner (1994)](https://ui.adsabs.harvard.edu/abs/1994ESASP.373...67J/abstract).  This IDL code can be found at [www.hao.ucar.edu/modeling/haos-diper/](https://www.hao.ucar.edu/modeling/haos-diper/).



