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
import missing
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
dippy_regime=2
dippy_approx=0
dippy_dbdir='/Users/judge/pydiper/dbase/'
dippy_spdir='/Users/judge/pydiper/spectra/'
os=platform.system()
if(os == 'Linux'):
    print(os)
    dippy_dbdir='/home/judge/pydiper/dbase/'
    dippy_spdir='/home/judge/pydiper/spectra/'
#
np.set_printoptions(precision=2)
plt.rcParams["figure.figsize"] = (9,6)
plt.rcParams.update({'font.size': 11})


x=dp.diplist('c')
#x=dp.diplist('o')
#x=dp.diplist('fe')
               
print()
print('Reading BASS spectrum ')
#
lam=input("enter 6302 or 5250: ")
lam=int(lam)
file='bass'+str(lam)
print(file)

d=ascii.read(file+'.txt', guess=False, format='basic')
w=d['wave']
f=d['flux']

plt.plot(w,f,label='Sun BASS ')
#
plt.xlim(lam-8,lam+8)
plt.ylim(00,16000)
plt.xlabel('Wavelength angstrom')
plt.ylabel('Jungfraujoch brightness')

boundonly=True
atom=dp.diprd(26,1,boundonly)
lvl=atom['lvl']
#print(lvl[0])

bb=dp.bbdata(atom)
bbold=bb

print()
print('atom ',type(atom))
print('lvl ', type(lvl))
print('bb ',type(bb))
print()
print(len(bb), 'bef')
#if(lam == 6302): bb=missing.missing(atom)
bb=missing.missing(atom)
print(len(bb), 'aft')
print(' MISSING:')


atom['bb']=bb

x=dp.specid(atom)


plt.savefig(file+'.pdf')
subprocess.run(["open", file+".pdf"]) 

print()
print('LAST EDIT DEC 15 2024 PGJ')

    
