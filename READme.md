[![github](https://img.shields.io/badge/NASA%20ADS-1994ESASP.373...67J-red)](https://articles.adsabs.harvard.edu/pdf/1994ESASP.373...67J)

# HAOS-DIPER: HAO Spectral DIagnostic Package for Emitted Radiation

**Author:** Philip G. Judge

**Contact:** judge@ucar.edu ; mauricew@ucar.edu

Summarizing if HAOS-DIPER is right for you
|---|---|
|Targeted problems |  |
|                  | tenuous plasma, "low energy" regime  |
|                  | LTE to optically thin plasmas  |
|                  | compilation of needed rate coefficients  |
|                  | teaching/learning spectroscopy  |
|                  | simple statistical equilibrium calculations  |
|                  | $\quad$- including escape probabilities  |
|                  | simple non-equilibrium calculations  |
|                  | $\quad$- evolution of atomic systems  |
|                  | provide "building blocks" of data and code to permit the user to make more sophisticated calculations  |
|                  | $\quad$- e.g, detailed radiative transfer or radiation hydrodynamics  |
|Limitations       |  |
|                  | elements lighter than Zn (nuclear charge 30)  |
|                  | principal quantum numbers < 10  |
|                  | incomplete databases  |
|                  | photoionization data are summed over final states, and are split approximately over fine structure  |
|                  | no impact line broadening  |
|                  | no hyperfine structure  |
|                  | no configuration mixing  |
|Cannot handle     |  |
|                  | non-Maxwellian particle distributions  |
|                  | inner shell excitations (high energy phenomena)  |
|                  | atomic and spectral polarization  |
|                  | molecules  |
|                  | accurate radiative transfer  |



What makes (HAOS-)DIPER unique?

- It is based upon the fast, flexible database software system written by D. Lindler for IDL, and takes some advantage of this system.
- It works with quantum numbers for atomic levels, enabling it to perform tasks otherwise difficult or very tedious, including a variety of data checks, calculations
based upon the atomic numbers, and searching and manipulating data based upon these quantum numbers.
- In principle, DIPER can handle conditions from LTE to coronal-like conditions.
- There is some capability for estimating data for which no accurate parameters are
available, and for accounting for the effects of missing atomic levels.


Requirement

- Database file sizes are too large to include in this repository.  
- Download the files here: [![github](https://www.mauricewilson.com/proxyonepager/datastorage/pyDIPER_dbase.tar.gz)](https://www.mauricewilson.com/proxyonepager/datastorage/pyDIPER_dbase.tar.gz)  (with "wget" UNIX command if desired)
- Unpack the file and place the "dbase" directory next to the "classpython" directory.


Example

- See the Jupyter Notebook full of examples on how pyDIPER can be used here: [![github](https://colab.research.google.com/drive/1aU5syF0ddQytI3-UoP6XiEAKPJUeAfay#scrollTo=xKjtYih8IMn9)](https://colab.research.google.com/drive/1aU5syF0ddQytI3-UoP6XiEAKPJUeAfay#scrollTo=xKjtYih8IMn9) 
- "Save a copy" of that Jupyter Notebook onto your own Google Drive.  Access it and run the code through the "Colab" (or "Colaboratory") app on Google.


