#
import pandas as pd
import numpy as np
import sqlite3
import subprocess
import matplotlib.pyplot as plt
import astropy.io.ascii as ascii

filename = 'atom_cbb.ascii'
print('Reading ',filename)
data=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
print('Reading ',filename, ' done')

database = r"cbbsql.db"
subprocess.call(["rm", "cbbsql.db"])
conn = sqlite3.connect(database)
c = conn.cursor()

sql_create_cbb_table = """ CREATE TABLE 
                        cbb(entry integer PRIMARY KEY, type integer, j integer,i integer, t BLOB, o BLOB )"""

c.execute(sql_create_cbb_table)
conn.commit()
#
n=len(data)
#data=np.array(data)
print('SHAPE ', np.shape(data))
#
for entry in range(0,n):
    if(entry % 5000 == 0):
        print(entry,'/',n)
        print('shape ',np.shape(data[entry]))
        print('data ',data[entry])
    type=int(data[entry][2])
    j=int(data[entry][3])
    i=int(data[entry][4])
    array=np.array(data[entry][5:16])
    t=array.tobytes()
    array=np.array(data[entry][16:])
    o=array.tobytes()

    txt="""INSERT OR IGNORE INTO cbb (entry,type,j,i,  t,o) VALUES (?,?,?,?,  ?,?);"""
    vars=[entry,type,j,i,t,o]
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
record = cursor.fetchone()
record = cursor.fetchone()
record = cursor.fetchone()
print( ' entry  ',record[0])
print( ' type   ',record[1])
print( ' j      ',record[2])
print( ' i      ',record[3])
print( '  ',np.frombuffer(record[4]))
print( '  ',np.frombuffer(record[5]))

plt.plot(np.frombuffer(record[4]),np.frombuffer(record[5]))
plt.show()
