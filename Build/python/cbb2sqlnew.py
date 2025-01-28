#
import pandas as pd
import numpy as np
import sqlite3

filename = 'atom_cbb.ascii'
cbb=pd.read_table(filename,delimiter=' ',header='infer')

database = r"cbbsql.db"
conn = sqlite3.connect(database)
c = conn.cursor()
sql_create_cbb_table = """ CREATE TABLE IF NOT EXISTS 
cbb(entry integer PRIMARY KEY,
lo integer,
up integer,
t1 float,t2 float,t3 float,t4 float,t5 float,t6 float,t7 float,t8 float,t9 float,t10 float,t11 float, 
o1 float,    o2 float,o3 float,o4 float,o5 float,o6 float,o7 float,o8 float,o9 float,o10 float,o11 float
)"""

c.execute(sql_create_cbb_table)
conn.commit()

cbb.to_sql(database,conn,if_exists='replace', index = True)

c.close()
#
# retrieve
#
# creating cursor
#
print('RETRIEVAL............................................................   ')
con = sqlite3.connect(database)
cur = con.cursor()

table_list = [a for a in cur.execute("SELECT name FROM sqlite_master WHERE type = 'table'")]
print(table_list)

query='''SELECT 'entry', 'up', 'lo', 't1'  FROM cbb'''
ok=pd.read_sql(query,con)
df=pd.DataFrame(ok,columns=['entry','up','lo','t1'])
print(df)
ok=pd.read_sql(query,con)
df=pd.DataFrame(ok,columns=['entry','up','lo','t1'])
print(df)


print(ok)

# Be sure to close the connection
con.close()


