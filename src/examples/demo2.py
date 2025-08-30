
####################################################################################################
#
# Main subprograms for dipper package
#
####################################################################################################
import numpy as np
from matplotlib import pyplot as plt
from collections import defaultdict
from astropy.io import fits
from astropy.io import ascii
import os
#
import dipper as dp
#
####################################################################################################
#
# MAIN 
####################################################################################################
#
# here are global variables, i.e. with global scope
#
print("DIAGNOSTIC PACKAGE IN PYTHON (dipper)")
print('Global variables all are of the kind dipper_XXX                                          ')
print('       where  XXX is, e.g., regime, approx, dbdir')
print()
dipper_regime=0
dipper_approx=0
dipall_init = dp.dipall()
dipper_dbdir= dipall_init.dipper_dbdir
dipper_spdir= dipall_init.dipper_spdir
#
np.set_printoptions(precision=2)
plt.rcParams["figure.figsize"] = (18,6)
#
#
print()
print('Reading UV spectrum of Alpha Centauri')
file=dipper_spdir + os.path.sep + 'alphacena.fits'
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
f*=1.7e17/phip/phip/dp.dipall.pi

rv=-21.4 * 1.e5
w -= rv/dp.dipall.cc * w
print(dp.dipall.cc/1.e10)
#w=dp.convl(w)
plt.plot(w,f,label='alpha Cen A Ayres')

####################################################################################################
file=dipper_spdir+ os.path.sep + '78tnth83.dat'
d=ascii.read(file, guess=False, format='basic')
w=d['wave']
f=d['flux']
e=dp.dipall.hh*dp.dipall.cc*1.e8/w
f*=215.*215.*e/dp.dipall.pi

dw = w-dp.dipall.convl(w)

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
atomN = 26
ionN = 2
boundonly=True
diprd_init=dp.diprd(atomN,ionN,boundonly, dipper_regime=dipper_regime, dipper_approx=dipper_approx)
diprd_init.redatom(lowestn=True)
bb=diprd_init.bbdata(ionN)
x=diprd_init.specid()
#
plt.savefig('demo2.pdf')
plt.show()

####################################################################################################

