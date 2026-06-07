from flask import Flask, render_template, request, redirect
import psycopg2
import os
import time

app = Flask(__name__)

def get_db():
    retries = 10
    while retries > 0:
        try:
            return psycopg2.connect(
                host=os.getenv("DB_HOST", "localhost"),
                database=os.getenv("DB_NAME", "demodb"),
                user=os.getenv("DB_USER", "postgres"),
                password=os.getenv("DB_PASS", "webinar2026")
            )
        except Exception:
            retries -= 1
            time.sleep(3)
    raise Exception("No se pudo conectar a la base de datos")

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS tareas (
            id SERIAL PRIMARY KEY,
            titulo VARCHAR(200) NOT NULL,
            completada BOOLEAN DEFAULT FALSE
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

@app.route('/')
def index():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('SELECT * FROM tareas ORDER BY id DESC')
    tareas = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', tareas=tareas)

@app.route('/add', methods=['POST'])
def add():
    titulo = request.form['titulo']
    conn = get_db()
    cur = conn.cursor()
    cur.execute('INSERT INTO tareas (titulo) VALUES (%s)', (titulo,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect('/')

@app.route('/complete/<int:id>')
def complete(id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute('UPDATE tareas SET completada = NOT completada WHERE id = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect('/')

@app.route('/delete/<int:id>')
def delete(id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute('DELETE FROM tareas WHERE id = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect('/')

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
