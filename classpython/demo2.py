
####################################################################################################
#
# Main subprograms for pydip package
#
####################################################################################################
import numpy as np
from matplotlib import pyplot as plt
from collections import defaultdict
from astropy.io import fits
from astropy.io import ascii
import subprocess
import platform
#
import dippy as dp
#
####################################################################################################
#
# MAIN 
####################################################################################################
#
# here are global variables, i.e. with global scope
#
print("DIAGNOSTIC PACKAGE IN PYTHON (dippy)")
print('Global variables all are of the kind dippy_XXX                                          ')
print('       where  XXX is, e.g., regime, approx, dbdir')
print()
dippy_regime=0
dippy_approx=0
dippy_dbdir='../dbase/'
dippy_spdir='../spectra/'
os=platform.system()
if(os == 'Linux'):
    print(os)
    dippy_dbdir='../dbase/'
    dippy_spdir='../spectra/'
#
np.set_printoptions(precision=2)
plt.rcParams["figure.figsize"] = (18,6)
#
#
print()
print('Reading UV spectrum of Alpha Centauri')
file=dippy_spdir+'alphacena.fits'
hdul=fits.open(file)
data = hdul[1].data # assuming the first extension is a table
data=data[0]

cols = hdul[1].columns
cols.info()

w=data['WAVE']
f=data['FLUX']
e=data['ERROR']
dq=data['DQ']
r=data['RESOL']
phip=8.5  # milli arcsec
f*=1.7e17/phip/phip/dp.dippyClass.pi

rv=-21.4 * 1.e5
w -= rv/dp.dippyClass.cc * w
print(dp.dippyClass.cc/1.e10)
#w=dp.convl(w)
plt.plot(w,f,label='alpha Cen A Ayres')

####################################################################################################
file=dippy_spdir+'78tnth83.dat'
d=ascii.read(file, guess=False, format='basic')
w=d['wave']
f=d['flux']
e=dp.dippyClass.hh*dp.dippyClass.cc*1.e8/w
f*=215.*215.*e/dp.dippyClass.pi

dw = w-dp.dippyClass.convl(w)

#plt.plot(w+dw,f,label='Sun Anderson/Hall')
####################################################################################################

# Alfred:
#274.488 vacuum
#
plt.xlim(2800,2810)
#plt.xlim(2585,2635)
#plt.xlim(1330,1340)
plt.ylim(0,.7e6)
plt.ylabel('Intensity erg/cm2/s/A/sr')
plt.legend(loc='lower right')


####################################################################################################
#atom=dp.atomnum('C')
#ions=[2,3,4]
#atom=dp.diprd_multi(atom,ions)
atomN = 26
ionN = 2
boundonly=True
diprd_init=dp.diprd(atomN,ionN,boundonly, dippy_regime=0, dippy_approx=0)
diprd_init.redatom(lowestn=True)
bb=diprd_init.bbdata(ionN)
x=diprd_init.specid()
#
plt.savefig('demo2.pdf')
plt.show()
#subprocess.run(["open", "demo2.pdf"]) 

print()
print('LAST EDIT MAY 29 2024 PGJ')
####################################################################################################

    
