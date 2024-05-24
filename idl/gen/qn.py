#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: qn.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, September 28, 1995 
# 
# Last Modified: Tue Aug  1 14:12:14 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def qn,ok = ok 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       qn 
    # 
    # PURPOSE: to obtain quantum numbers, multiplet indexes, transition types 
    # 
    # EXPLANATION: 
    #       An atomic level's label (string variable) is examined and the quantum 
    #       numbers n,l,2S+1,L,J of the level are assigned to common block 
    #       variables in common cqn.  The parity of ths state is assigned and the 
    #       number of "active electrons" assigned.  The variables are as follows 
    #       (integer variables except where specified): 
    # 
    #       active:  Number of active electrons in outermost shell 
    #       n:       Principle QN of outermost electron 
    #       eff:     effective "       "           " (FLOAT) 
    #       smalll:  Ang. Mom of individual electron(s) in outermost shell 
    #       coupling:  coupling regime for level ('LS'=LS, 'JJ'=JJ,'PAIR'=other) 
    # 
    # if coupling is LS: 
    #       tsp1:    2S+1 total spin ang. momentum of level 
    #       bigl:    L total orbital ang. momentum of level 
    #  if coupling is JJ: 
    #       tsp1:    j1 total ang. momentum of inner electrons 
    #       bigl:    j2 total ang. momentum of outer electron 
    #  if coupling is PAIR: 
    #       tsp1:    2S+1  spin ang. momentum of outer electron 
    #       bigl:    K remaining total ang. momentum inner electrons 
    # 
    # 
    #       parity:  parity of level (STRING) 
    #       tjp1:    2J+1 , J= total angular momentum of electron cloud. 
    #       eff:     Effective quantum number calculated from lowest 
    #                   level of ion above 
    #       meta:    Index of whether a level is metastable (same parity as 
    #                   ground state of a given ion) 
    #       rydberg:    The Rydberg energy constant for the element's mass 
    #       multnumber: An array listing the index of a multiplet to which a line 
    #                   belongs 
    #       transtype:   A string array showing transition type: 
    #                   'E1'  fully permitted (E1) 
    #                   'IC'  Spin forbidden 
    #                   'M1'  magnetic dipole 
    #                   'M1E2'  magnetic dipole or electric quadrupole 
    # CALLING SEQUENCE: 
    #       qn 
    # 
    # INPUTS: 
    #       None 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       * in common block cqn 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    # 
    # COMMON BLOCKS: 
    # 
    # RESTRICTIONS: 
    #       No checks are done on the contents or type of variable 
    #       label before execution. 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written September 28, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    #       Header updated April 26, 1996 by Phil &, HAO/NCAR, Boulder CO USA 
    #       Updated to include effective quantum number and uses common block 
    #       catom.  Effective quantum number is set to 0. for highest level. 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, September 28, 1995 
    #- 
    # 
    @cdiper 
    # 
    #   effective quantum numbers 
    # 
    nbad = 0 
    ok1 = intarr(atom.nk) 
    for k  in np.arange( 0,atom.nk): 
        energy = lvl(k).ev 
        g = lvl(k).g 
        lvl[k].tjp1 = fix(lvl[k].g) 
        label = lvl(k).label 
        # 
        # if J label is missing 
        # 
        wrd=getwrd(label,/last) 
        if(strpos(wrd,'E') >= 0 or strpos(wrd,'O') >= 0 or       strpos(wrd,'S') >= 0 or strpos(wrd,'P') >= 0 or       strpos(wrd,'D') >= 0 or strpos(wrd,'F') >= 0 or       strpos(wrd,'G') >= 0 or strpos(wrd,'H') >= 0 or       strpos(wrd,'I') >= 0 or strpos(wrd,'J') >= 0 or       strpos(wrd,'K') >= 0 or strpos(wrd,'L') >= 0 or       strpos(wrd,'M') >= 0 or strpos(wrd,'N') >= 0): 
        old=label 
        label=label+' '+gtoj(g,/str) 
    ion = lvl(k).ion 
    ref = lvl(k).ref 
    lvl(k) = lab2qn(energy,g,label,ion,ref,ok = ok) 
    ok1(k) = ok 
ok = ok1 
# 
# fill metastable and effective qn's 
# 
meta_eff 
# 
#  data for transitions 
# 
trndata 
# 
RETURN 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'qn.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
