#
import pandas as pd
import numpy as np
import sqlite3
import subprocess
import matplotlib.pyplot as plt
import astropy.io.ascii as ascii


dippy_dir='~/pydiper'
indir=dippy_dir+'/temporary/'

filename = indir+'atom_bb.ascii'
tab=ascii.read(filename)
bb = tab.copy()

print('TAB ',len(tab))
print(tab.keys())



print('Reading ',filename)
data=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
print('Reading ',filename, ' done')

filename = indir+'atom_lvl.ascii'
print('Reading ',filename)
dlvl=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
nl=len(dlvl)
print('Reading ',filename, ' done')

database = r"cbbsql.db"
subprocess.call(["rm", "cbbsql.db"])
conn = sqlite3.connect(database)
c = conn.cursor()

sql_create_cbb_table = """ CREATE TABLE 
  cbb(entry integer PRIMARY KEY, atom integer, ion integer, type integer, j integer,i integer, t BLOB, o BLOB )"""

c.execute(sql_create_cbb_table)
conn.commit()
#
n=len(data)
print('SHAPE ', np.shape(data))
#
# get atom and ion associated with j or i

#
for entry in range(0,n):
    if(entry % 5000 == 0):
        print(entry,'/',n)
        print(data[entry])
    type=int(data[entry][2])
    j=int(data[entry][3])
    i=int(data[entry][4])

    #
    if(j < nl):
        atom=int(dlvl[j]['atom'])
        ion =int(dlvl[j]['ion'])
        array=np.array(data[entry][5:14])
        t=array.tobytes()
        array=np.array(data[entry][14:])
        o=array.tobytes()
        
        txt="""INSERT OR IGNORE INTO cbb (entry, atom, ion, type, j,i,  t,o) VALUES (?,?,?,?,?,?,  ?,?);"""
        vars=[entry,atom,ion,type,j,i,t,o]
        c.execute(txt,vars)
        conn.commit()

print("Number of records after inserting rows:")
cursor = c.execute('select * from cbb;')
print(len(cursor.fetchall()))


sqlite_select_query = """SELECT * from cbb"""
cursor.execute(sqlite_select_query)
print("Fetching single row")
record = cursor.fetchone()
record = cursor.fetchone()
print( ' entry  ',record[0])
print( ' atom   ',record[1])
print( ' ion      ',record[2])
print( ' type      ',record[3])
print( ' j      ',record[4])
print( ' i      ',record[5])
print( '  ',np.frombuffer(record[6]))
print( '  ',np.frombuffer(record[7]))

plt.plot(np.frombuffer(record[6]),np.frombuffer(record[7]),'.')
plt.show()
plt.close()
