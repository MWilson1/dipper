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
        print("conn  is   ",conn, " version ",sqlite3.version)
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
    sql_create_bb_table = """ CREATE TABLE IF NOT EXISTS bb (
	entry integer PRIMARY KEY,
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

        # tasks
#        task_1 = ('Analyze the requirements of the app', 1, 1, project_id, '2015-01-01', '2015-01-02')
#        task_2 = ('Confirm with user about the top requirements', 1, 1, project_id, '2015-01-03', '2015-01-05')

        # create tasks
#        create_task(conn, task_1)
#        create_task(conn, task_2)
#        print("1. Query task by priority:")
#        select_task_by_priority(conn, 1)


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
######################################################################
#  MAIN CALLING PROGRAM
######################################################################
######################################################################
# read
######################################################################
filename = 'atom_bb.ascii'
tab=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
#tab=ascii.read(filename)
filename = 'atom_bbstr.ascii'
tabs=ascii.read(filename)
bb = tab.copy()
bb.update(tabs) # which returns None since it mutates bb

tab=bb

bb=bb.to_pandas().to_dict(orient='records')
#bb=bb.to_pandas().to_dict()

######################################################################
# dict
######################################################################t

######################################################################
# SQL
######################################################################
if __name__ == '__main__':
    main()
