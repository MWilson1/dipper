import matplotlib.pyplot as plt
import numpy as np
import scipy.special as sp
import subprocess
import math
import dippy as dp


wm = 3933.e-8
print(wm, dp.planck(wm,4000.), dp.planck(wm,7000.)/dp.planck(wm,4000))
wm = 8542.e-8
print(wm, dp.planck(wm,4000.), dp.planck(wm,7000.)/dp.planck(wm,4000))
       
