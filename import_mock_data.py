import os
import glob
import psycopg2
import csv

# Параметры подключения к БД
DB_PARAMS = {
    "host": "localhost",
    "port": 25432,
    "dbname": "bigdata",
    "user": "user",
    "password": "password",
}

CSV_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "исходные данные")
TABLE_NAME = "mock_data"

def get_connection():
    return psycopg2.connect(**DB_PARAMS)

def create_temp_table_from_csv_sample(cursor, sample_csv_path):
    with open(sample_csv_path, encoding="utf-8") as f:
        reader = csv.reader(f)
        headers = next(reader)
    columns_sql = ", ".join([f'"{col.strip()}" TEXT' for col in headers])
    create_table_sql = f"""
    DROP TABLE IF EXISTS {TABLE_NAME};
    CREATE TABLE {TABLE_NAME} (
        {columns_sql}
    );
    """
    cursor.execute(create_table_sql)
    print(f"Таблица {TABLE_NAME} создана с колонками: {headers}")

def load_csv_files_into_table(cursor):
    pattern = os.path.join(CSV_FOLDER, "MOCK_DATA*.csv")
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"CSV-файлы не найдены по пути: {pattern}")
        return
    for file in files:
        print(f"Загружаю файл: {file}")
        with open(file, "r", encoding="utf-8") as f:
            cursor.copy_expert(f'COPY {TABLE_NAME} FROM STDIN WITH CSV HEADER', f)

def execute_sql_file(cursor, filepath):
    print(f"Выполняю SQL из файла: {filepath}")
    with open(filepath, "r", encoding="utf-8") as f:
        sql = f.read()
    cursor.execute(sql)

def main():
    try:
        conn = get_connection()
        cur = conn.cursor()

        # Создаем временную таблицу и загружаем данные из CSV
        sample_csv = sorted(glob.glob(os.path.join(CSV_FOLDER, "MOCK_DATA*.csv")))[0]
        create_temp_table_from_csv_sample(cur, sample_csv)
        load_csv_files_into_table(cur)
        conn.commit()
        print("Данные успешно загружены в таблицу mock_data.")

        # Выполняем DDL (создание нормализованных таблиц)
        execute_sql_file(cur, os.path.join(os.path.dirname(os.path.abspath(__file__)), "ddl.sql"))
        conn.commit()
        print("Нормализованные таблицы созданы.")

        # Выполняем DML (заполнение нормализованных таблиц)
        execute_sql_file(cur, os.path.join(os.path.dirname(os.path.abspath(__file__)), "dml.sql"))
        conn.commit()
        print("Нормализованные таблицы заполнены данными.")

    except Exception as e:
        print(f"Ошибка: {e}")

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    main()


