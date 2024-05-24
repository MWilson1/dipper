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
    print("create_connection")
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
    print("create_table")
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
    database = r"lvlsql.db"
    print('main def')
    sql_create_lvl_table = """ CREATE TABLE IF NOT EXISTS lvl (
	entry integer PRIMARY KEY,
    atom integer,
    ion integer,
    isos integer,
    e float,
    g integer,
    glande float,
    term1 integer,
    orb1 integer,
    term2 integer,
    orb2 integer,
    term3 integer,
    orb3 integer,
    label text NOT NULL,
	coupling text NOT NULL
    ); """

    # print(sql_create_lvl_table)
    # create a database connection
    print("database is             ",database)
    print("before create_connection(database)")
    conn = create_connection(database)

    # create tables
    print("from main() conn   is            ",conn)
    if conn is not None:
        # create lvl table
        create_table(conn, sql_create_lvl_table)

    else:
        print("Error! cannot create the database connection.")

    with conn:
        # create a new project
        project = ('DIPER python ');
        project_id = create_lvl(conn, lvl)

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
def create_lvl(conn, lvl):
    print("create_lvl")
#    print(lvl['label'])
    """
    Create a new project into the lvl table
    :param conn:
    :param lvl:
    :return: project entry
    """
    sql = ''' INSERT INTO lvl(
    entry,
    atom,
    ion,
    isos,
    e,
    g,
    glande,
    term1,
    orb1,
    term2,
    orb2,
    term3,
    orb3,
    label,
	coupling) 
    VALUES(lvl
    )'''
#    VALUES(lvl['entry'],lvl['atom'],lvl['ion'],lvl['isos'],
#    lvl['e'],lvl['g'],lvl['glande'],lvl['term1'],
#    lvl['orb1'],lvl['term2'],lvl['orb2'],lvl['term3'],lvl['orb3'],
#    lvl['label'],lvl['coupling']
    cur = conn.cursor()
    print('DUH...')
#    cur.executemany("INSERT INTO lvl VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (lvl[0],))
    n=len(lvl)
    for j in range(0,n-1):
        cur.execute("INSERT INTO lvl VALUES(?, ?, ?,?, ?, ?,?, ?, ?,?, ?, ?,?, ?, ?)", 
                        (lvl[j]['entry'],lvl[j]['atom'],lvl[j]['ion'],lvl[j]['isos'],lvl[j]['e'],lvl[j]['g'],
                        lvl[j]['glande'],lvl[j]['term1'],lvl[j]['orb1'],lvl[j]['term2'],lvl[j]['orb2'],
                        lvl[j]['term3'],lvl[j]['orb3'],lvl[j]['label'],lvl[j]['coupling']))
    conn.commit()
    return cur.lastrowid    

######################################################################
######################################################################
#  MAIN CALLING PROGRAM
######################################################################
######################################################################
# read
######################################################################
filename = 'atom_lvl.ascii'
tab=ascii.read(filename)
filename = 'atom_lvlstr.ascii'
tabs=ascii.read(filename,delimiter=',',guess=False,fast_reader=False)
lvl = tab.copy()
lvl.update(tabs) # which returns None since it mutates lvl

tab=lvl

lvl=lvl.to_pandas().to_dict(orient='records')
#lvl=lvl.to_pandas().to_dict()

######################################################################
# dict
######################################################################t

print("my main lvl defined")
######################################################################
# SQL
######################################################################
if __name__ == '__main__':
    main()
