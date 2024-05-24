#
import pandas as pd
import numpy as np
import sqlite3
import subprocess
import matplotlib.pyplot as plt


from astropy.io import ascii

filename = 'atom_bf.ascii'

data=pd.read_csv(filename, sep=' ')

database = r"bfsql.db"
subprocess.call(["rm", "bfsql.db"])
conn = sqlite3.connect(database)
c = conn.cursor()
sql_create_bf_table = """ CREATE TABLE 
                        bf(entry integer PRIMARY KEY, atom INTEGER, ion INTEGER,isos INTEGER,
                           term1 INTEGER, orb1 INTEGER, term2 INTEGER,orb2 INTEGER, term3 INTEGER,orb3 INTEGER,
                           nq INTEGER, edgepm INTEGER, lam BLOB, sigma BLOB)"""
c.execute(sql_create_bf_table)
conn.commit()

data=np.array(data)
n=len(data)
for ijk in range(0,n):
    entry=ijk
    nq=data[ijk,0]
    edgepm=data[ijk,1]
    atom=data[ijk,2]
    ion=data[ijk,3]
    isos=data[ijk,4]
    term1=data[ijk,5]
    orb1=data[ijk,6]
    term2=data[ijk,7]
    orb2=data[ijk,8]
    term3=data[ijk,9]
    orb3=data[ijk,10]

    lam=data[ijk,11:86]
    sigma=data[ijk,86:161]

    lam= lam.tobytes()
    sigma = sigma.tobytes()
#(entry,atom,ion,isos,term1,orb1,term2,orb2, term3,orb3,nq,edgepm,lam,sigma) 
    txt="""INSERT OR IGNORE INTO bf 
         VALUES (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?);"""
    vars=[entry,atom,ion,isos,term1,orb1,term2,orb2,term3,orb3,nq,edgepm,lam,sigma]
#    print()
#    print()
#    print(vars)
    c.execute(txt,vars)
    conn.commit()

print("Number of records after inserting rows:")
cursor = c.execute('select * from bf;')
print(len(cursor.fetchall()))


sqlite_select_query = """SELECT * from bf"""
cursor.execute(sqlite_select_query)
print("Fetching single row")
record = cursor.fetchone()
record = cursor.fetchone()
record = cursor.fetchone()
print( ' entry  ',record[0])
print( ' atom   ',record[1])
print( ' ion    ',record[2])
print( ' isos   ',record[3])
print( ' term1  ',record[4])
print( '  orb1  ',record[5])
print( ' term2  ',record[6])
print( '  orb2  ',record[7])
print( ' term3  ',record[8])
print( '  orb3  ',record[9])
print( ' nq     ',record[10])
print( ' egdepm ',record[11])
lam=np.frombuffer(record[12])**3.
sig=np.frombuffer(record[13])**3.
print( '  ',lam)

print( '  ',sig)

plt.step(lam,sig)
plt.xlabel(r'\lambda \AA')
plt.ylabel(r'Mbarn')
plt.show()
