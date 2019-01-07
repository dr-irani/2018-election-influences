import mysql.connector
import pandas as pd
from flask import Flask, render_template
app = Flask(__name__)
@app.route("/")

def get_voter_stats():
    db_usrname = 'root'
    db_passwd = 'Eagles1s'
    db_ip = 'localhost' #change when using db in ugrad
    db_name = 'csfinal'
    con = mysql.connector.connect(user=db_usrname, password=db_passwd,
                                  host=db_ip, database=db_name,
                                  auth_plugin='mysql_native_password')
    cursor = con.cursor()
    cursor.callproc('VoteStatByCounty', args=('','census','population'))
    con.commit()
    df = pd.read_sql("select * from result;", con=con)

    cursor.close()
    con.close()
    temp = df.to_dict('records')
    columnNames = df.columns.values
    return render_template('table.html', records=temp, colnames=columnNames)

if __name__ == "__main__":
    get_voter_stats()
