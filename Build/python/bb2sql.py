#
import pandas as pd
import numpy as np
from astropy.io import ascii
import sqlite3
from sqlite3 import Error
#from astrotable_to_sql.py import load_db, create_data_dictionaries



######################################################################
# SQL
######################################################################

def create_connection(db_file):
    """ create a database connection to a SQLite database """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print("conn  is   ",conn) #earler , " version ",sqlite3.version)
    except Error as e:
        print(e)
    return conn
######################################################################
#
######################################################################

def create_table(conn, create_table_sql):
    """ create a table from the create_table_sql statement
    :param conn: Connection object
    :param create_table_sql: a CREATE TABLE statement
    :return:
    """
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
    except Error as e:
        print(e)

######################################################################
# create main 
######################################################################
def main():
    database = r"bbsql.db"
    sql_create_bb_table = """ CREATE TABLE IF NOT EXISTS bb (entry integer  PRIMARY KEY,
    f float,
    wl float,
    j integer,
    i integer,
    type text NOT NULL,
    atom integer,
    ion integer,
    isos integer
    ); """

    conn = create_connection(database)

    # create tables
    if conn is not None:
        # create bb table
        create_table(conn, sql_create_bb_table)

    else:
        print("Error! cannot create the database connection.")

    with conn:
        # create a new project
        project = ('DIPER python ');
        project_id = create_bb(conn, bb)



######################################################################
#
#
######################################################################        
def create_bb(conn, bb):
    """
    Create a new project into the bb table
    :param conn:
    :param bb:
    :return: project entry
    """
    cur = conn.cursor()
    n=len(bb)
    m=len(bb[0].items())
    print(n,m)
    for j in range(0,n-1):
        cur.execute("INSERT INTO bb VALUES(?, ?, ?,?, ?, ?,?, ?, ?)", 
        (bb[j]['entry'],bb[j]['f'],bb[j]['wl'],bb[j]['j'],bb[j]['i'],
        bb[j]['type'],bb[j]['atom'],bb[j]['ion'],bb[j]['isos']))
    conn.commit()
    return cur.lastrowid    

######################################################################
#  MAIN CALLING PROGRAM
######################################################################


dippy_dir='~/pydiper'
indir=dippy_dir+'/temporary/'

filename = indir+'atom_bb.ascii'
tab=ascii.read(filename)
bb = tab.copy()

print('TAB ',len(tab))
print(tab.keys())

filename = indir+'atom_bbstr.ascii'
tabs=ascii.read(filename,delimiter=',',guess=False,fast_reader=False)
bb.update(tabs) 
print('TABS ',len(tabs))


print(bb.keys())
bb=bb.to_pandas().to_dict(orient='records')
#bb=bb.to_pandas().to_dict()

######################################################################
if __name__ == '__main__':
    main()
