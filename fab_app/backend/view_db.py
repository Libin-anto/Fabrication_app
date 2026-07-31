import sqlite3

def show_database():
    conn = sqlite3.connect('fab_app.db')
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [row[0] for row in cursor.fetchall()]
    
    print('# Database Contents\\n')
    
    for table_name in tables:
        if table_name != 'sqlite_sequence':
            print(f'## Table: {table_name}')
            cursor.execute(f'SELECT * FROM {table_name} LIMIT 10;')
            rows = cursor.fetchall()
            
            if not rows:
                print("*Table is empty*")
            else:
                # Print column names
                col_names = [description[0] for description in cursor.description]
                print(" | ".join(col_names))
                print("-" * (len(" | ".join(col_names))))
                for row in rows:
                    print(" | ".join(map(str, row)))
            print('\\n')

    conn.close()

if __name__ == '__main__':
    try:
        show_database()
    except Exception as e:
        print(f"Error reading database: {e}")
