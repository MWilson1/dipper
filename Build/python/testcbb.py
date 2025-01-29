#
import pandas as pd
import numpy as np
import sqlite3
import subprocess
import matplotlib.pyplot as plt

database = r"cbbsql.db"

conn = sqlite3.connect(database)
c = conn.cursor()


cursor = c.execute('select * from cbb;')
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
