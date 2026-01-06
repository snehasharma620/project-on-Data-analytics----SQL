import sqlite3

# ------------------------------
# 1. Connect to Database
# ------------------------------
conn = sqlite3.connect("students.db")
cursor = conn.cursor()

# ------------------------------
# 2. Create Table if not exists
# ------------------------------
cursor.execute("""
CREATE TABLE IF NOT EXISTS students (
    roll_no INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER,
    course TEXT
)
""")
conn.commit()


# ------------------------------
# 3. Functions
# ------------------------------
def add_student(roll_no, name, age, course):
    try:
        cursor.execute("INSERT INTO students (roll_no, name, age, course) VALUES (?, ?, ?, ?)",
                       (roll_no, name, age, course))
        conn.commit()
        print("✅ Student added successfully!")
    except sqlite3.IntegrityError:
        print("❌ Error: Roll number already exists.")


def view_students():
    cursor.execute("SELECT * FROM students")
    rows = cursor.fetchall()
    if rows:
        print("\n📋 Student Records:")
        for row in rows:
            print(f"Roll No: {row[0]}, Name: {row[1]}, Age: {row[2]}, Course: {row[3]}")
    else:
        print("⚠️ No student records found.")


def search_student(roll_no):
    cursor.execute("SELECT * FROM students WHERE roll_no = ?", (roll_no,))
    row = cursor.fetchone()
    if row:
        print(f"\n🔍 Found: Roll No: {row[0]}, Name: {row[1]}, Age: {row[2]}, Course: {row[3]}")
    else:
        print("⚠️ Student not found.")


def delete_student(roll_no):
    cursor.execute("DELETE FROM students WHERE roll_no = ?", (roll_no,))
    conn.commit()
    if cursor.rowcount > 0:
        print("🗑️ Student deleted successfully!")
    else:
        print("⚠️ Student not found.")


# ------------------------------
# 4. Menu-driven Program
# ------------------------------
while True:
    print("\n=== Student Management System ===")
    print("1. Add Student")
    print("2. View Students")
    print("3. Search Student")
    print("4. Delete Student")
    print("5. Exit")

    choice = input("Enter choice: ")

    if choice == "1":
        roll = int(input("Enter Roll No: "))
        name = input("Enter Name: ")
        age = int(input("Enter Age: "))
        course = input("Enter Course: ")
        add_student(roll, name, age, course)

    elif choice == "2":
        view_students()

    elif choice == "3":
        roll = int(input("Enter Roll No to search: "))
        search_student(roll)

    elif choice == "4":
        roll = int(input("Enter Roll No to delete: "))
        delete_student(roll)

    elif choice == "5":
        print("👋 Exiting...")
        break

    else:
        print("❌ Invalid choice. Try again!")

# Close connection
conn.close()
