#
import pandas as pd
import numpy as np
import sqlite3
import subprocess
import matplotlib.pyplot as plt


from astropy.io import ascii


database='bbsql.db'
conn = sqlite3.connect(database)
cursor=conn.cursor()

#res = cursor.execute("SELECT * FROM lvl where atom= "+str(atom)+" and ion="+str(ions))
#lvl=res.fetchall()

str="""SELECT * from bb where atom = 6 and ion = 4 """
res=cursor.execute(str)
record = cursor.fetchall()
print(record[0])
print(record[1])
print()
#str="""SELECT * from bb where entry = 116031"""
str="""SELECT * from bb where entry = 116032"""
res=cursor.execute(str)
record = cursor.fetchone()
print(record)

