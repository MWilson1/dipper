####################################################################################################
# Plot isoelectronic sequence of Be- and B- like and C-like ions
####################################################################################################
import dippy as dp
import numpy as np
from matplotlib import pyplot as plt
import time
import subprocess
import platform
from astropy.io import ascii
from scipy.interpolate import CubicSpline

figure, axis = plt.subplots(3, 2,figsize=(10,11))

col=['r','b','k']

iseq=-1
for sequence in (np.array([13,14],int)):   # loop over sequence
    iseq+=1
    atoms = np.arange(sequence,30)

    if(sequence == 14):
        ulab=['3S2 3P2 3PE 1','3S 3P3 3DO 1','3S2 3P 4S 1PO 1']
        llab=['3S2 3P2 3PE 0']

    if(sequence == 13):
        ulab=['3S2 3P 2PO 3/2','3S 3P2 4PE 3/2','3S 3P2 2DE 3/2']
        llab=['3S2 3P 2PO 1/2']

    atoms = np.arange(sequence,30)

######################################################################
#   Collision strength plot
######################################################################

    const=1.
    kount=-1
    for uab in ulab:
        kount+=1
        out= atoms*0  +np.nan
        outt=out*0.
        count=-1
        for at in range(sequence+1,30):
            count+=1
            ion= at-sequence+1
            atom=dp.diprd(at,ion,False)
            if(atom['ok'] == True):
            
                tl, omega = dp.matchcol(atom,llab[0],uab)
                out[count]=omega
                outt[count]=tl
                            
                #if(sequence == 14 and at == 20): out[count]*=10

        use= np.logical_not(np.isnan(out))

        axis[0,iseq].plot(atoms[use]+1,out[use]*const, col[kount]+'.-',label=llab[0]+' -- '+uab)
        axis[0,iseq].set_yscale('log')
        axis[0,iseq].set_ylabel(r'$\Upsilon(T_e)$ ')
        axis[0,iseq].set_xticks(atoms[::2])
        axis[0,iseq].set_xticklabels(atoms[::2], fontsize=10)
        axis[0,iseq].set_title(r"Collision strengths of "+
                               dp.atomname(sequence)+' sequence',fontsize=9)
        axis[0,iseq].legend(fontsize=8)
    
######################################################################
#   Oscillator strength plot
######################################################################

    const=1.
    kount=-1
    for uab in ulab:
        kount+=1
        out= atoms*0  +np.nan
        outt=out*0.
        count=-1
        for at in range(sequence+1,30):
            count+=1
            ion= at-sequence+1
            atom=dp.diprd(at,ion,False)
            if(atom['ok'] == True):
                f = dp.matchf(atom,llab[0],uab)
                out[count]=f

        use= np.logical_not(np.isnan(out))
        axis[1,iseq].plot(atoms[use]+1,out[use]*const, col[kount]+'.-',label=llab[0]+' -- '+uab)
        axis[1,iseq].set_yscale('log')
        #axis[1,iseq].set_xlabel('Atomic number Z')
        axis[1,iseq].set_ylabel(r'$f_{ABS}$ ')
        axis[1,iseq].set_xticks(atoms[::2])
        axis[1,iseq].set_xticklabels(atoms[::2], fontsize=10)
        axis[1,iseq].set_title(r"Oscillator strengths of "+dp.atomname(sequence)+' sequence',fontsize=9)
        axis[1,iseq].legend(fontsize=8)
        axis[1,iseq].set_ylim([1.e-8, .1])
        
    
######################################################################
#   Energy level plot
######################################################################

######################################################################
#  ionization potential
    out= atoms*0  +np.nan
    count=-1
    coli='g'
    for at in range(sequence+1,30):
        count+=1
        ion= at-sequence+1
        atom=dp.diprd(at,ion,False)
        out[count]=dp.ipotl(at,ion)
#  
        use= np.logical_not(np.isnan(out))


    axis[2,iseq].plot(atoms[use]+1,out[use]*const, coli+'.-',label='IP')
    axis[2,iseq].set_yscale('log')
    axis[2,iseq].set_xlabel('Atomic number A')
    axis[2,iseq].set_ylabel('Level energy eV  ')
    axis[2,iseq].set_xticks(atoms[::2])
    axis[2,iseq].set_xticklabels(atoms[::2], fontsize=10)
    axis[2,iseq].set_title(r"Level energy eV"
                           +dp.atomname(sequence)+' sequence',fontsize=9)
######################################################################

        
    const= 100. * dp.const()['hh'] * dp.const()['cc']        / dp.const()['ee'] 
    kount=-1
    for uab in ulab:
        kount+=1
        out= atoms*0  +np.nan
        outt=out*0.
        count=-1
        for at in range(sequence+1,30):
            count+=1
            ion= at-sequence+1
            atom=dp.diprd(at,ion,False)
            e=np.nan
            if(atom['ok'] == True):
                lvl=atom['lvl']
                for il in range(0,len(lvl)):
                    lab=(lvl[il]['label']).strip()
                    #print('HERE ',uab,' : ',lab)
                    if(lab == uab):
                        e=lvl[il]['e']
                out[count]=e*const

        use= np.logical_not(np.isnan(out))
        axis[2,iseq].plot(atoms[use]+1,out[use]*const, coli+'.-',label=uab)
        axis[2,iseq].set_yscale('log')
        axis[2,iseq].set_xticks(atoms[::2])
        axis[2,iseq].set_xticklabels(atoms[::2], fontsize=10)
        axis[2,iseq].set_title(r"Level energies of "+dp.atomname(sequence)+' sequence',fontsize=9)
        axis[2,iseq].legend(fontsize=8)




        
################################################################################

plt.savefig('figisos2.png')
plt.close()
subprocess.run(["open", "figisos2.png"]) 
    
quit()

                    

