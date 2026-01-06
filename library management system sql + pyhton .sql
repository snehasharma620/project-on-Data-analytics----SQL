import sqlite3
from datetime import datetime, timedelta

# ------------------------------
# Connect to database
# ------------------------------
conn = sqlite3.connect("library.db")
cursor = conn.cursor()

# ------------------------------
# Create tables
# ------------------------------
cursor.execute("""
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    author TEXT,
    available INTEGER DEFAULT 1
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS borrow (
    borrow_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    book_id INTEGER,
    borrow_date TEXT,
    return_date TEXT,
    returned INTEGER DEFAULT 0,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(book_id) REFERENCES books(book_id)
)
""")
conn.commit()


# ------------------------------
# User Authentication
# ------------------------------
def register(username, password):
    try:
        cursor.execute("INSERT INTO users (username, password) VALUES (?, ?)", (username, password))
        conn.commit()
        print("✅ User registered successfully!")
    except sqlite3.IntegrityError:
        print("❌ Username already exists.")


def login(username, password):
    cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (username, password))
    return cursor.fetchone()


# ------------------------------
# Book Management
# ------------------------------
def add_book(title, author):
    cursor.execute("INSERT INTO books (title, author) VALUES (?, ?)", (title, author))
    conn.commit()
    print("📚 Book added successfully!")


def view_books():
    cursor.execute("SELECT * FROM books")
    for row in cursor.fetchall():
        status = "Available" if row[3] else "Not Available"
        print(f"ID: {row[0]}, Title: {row[1]}, Author: {row[2]}, Status: {status}")


def update_book(book_id, title, author):
    cursor.execute("UPDATE books SET title=?, author=? WHERE book_id=?", (title, author, book_id))
    conn.commit()
    print("✏️ Book updated successfully!")


def delete_book(book_id):
    cursor.execute("DELETE FROM books WHERE book_id=?", (book_id,))
    conn.commit()
    print("🗑️ Book deleted successfully!")


# ------------------------------
# Borrow / Return System
# ------------------------------
def borrow_book(user_id, book_id):
    cursor.execute("SELECT available FROM books WHERE book_id=?", (book_id,))
    result = cursor.fetchone()
    if result and result[0] == 1:
        borrow_date = datetime.now().strftime("%Y-%m-%d")
        return_date = (datetime.now() + timedelta(days=14)).strftime("%Y-%m-%d")
        cursor.execute("INSERT INTO borrow (user_id, book_id, borrow_date, return_date) VALUES (?, ?, ?, ?)",
                       (user_id, book_id, borrow_date, return_date))
        cursor.execute("UPDATE books SET available=0 WHERE book_id=?", (book_id,))
        conn.commit()
        print("✅ Book borrowed successfully!")
    else:
        print("❌ Book not available.")


def return_book(book_id):
    cursor.execute("UPDATE borrow SET returned=1 WHERE book_id=? AND returned=0", (book_id,))
    cursor.execute("UPDATE books SET available=1 WHERE book_id=?", (book_id,))
    conn.commit()
    print("📦 Book returned successfully!")


# ------------------------------
# Reports
# ------------------------------
def borrowed_books():
    cursor.execute("""
    SELECT b.book_id, b.title, u.username, br.borrow_date, br.return_date 
    FROM borrow br
    JOIN users u ON br.user_id = u.user_id
    JOIN books b ON br.book_id = b.book_id
    WHERE br.returned=0
    """)
    rows = cursor.fetchall()
    print("\n📊 Borrowed Books:")
    for row in rows:
        print(f"Book ID: {row[0]}, Title: {row[1]}, Borrower: {row[2]}, Borrow Date: {row[3]}, Return Due: {row[4]}")


def overdue_books():
    today = datetime.now().strftime("%Y-%m-%d")
    cursor.execute("""
    SELECT b.title, u.username, br.return_date 
    FROM borrow br
    JOIN users u ON br.user_id = u.user_id
    JOIN books b ON br.book_id = b.book_id
    WHERE br.returned=0 AND br.return_date < ?
    """, (today,))
    rows = cursor.fetchall()
    print("\n⚠️ Overdue Books:")
    for row in rows:
        print(f"Title: {row[0]}, Borrower: {row[1]}, Due: {row[2]}")


# ------------------------------
# Main Program
# ------------------------------
def main():
    print("=== 📚 Library Management System ===")
    while True:
        print("\n1. Register\n2. Login\n3. Exit")
        choice = input("Enter choice: ")

        if choice == "1":
            username = input("Enter username: ")
            password = input("Enter password: ")
            register(username, password)

        elif choice == "2":
            username = input("Username: ")
            password = input("Password: ")
            user = login(username, password)
            if user:
                print(f"👋 Welcome {user[1]}!")
                user_id = user[0]
                while True:
                    print("\n--- Menu ---")
                    print("1. Add Book\n2. View Books\n3. Update Book\n4. Delete Book")
                    print("5. Borrow Book\n6. Return Book\n7. Borrowed Books Report\n8. Overdue Books Report\n9. Logout")
                    ch = input("Enter choice: ")

                    if ch == "1":
                        title = input("Book Title: ")
                        author = input("Author: ")
                        add_book(title, author)

                    elif ch == "2":
                        view_books()

                    elif ch == "3":
                        bid = int(input("Enter Book ID: "))
                        title = input("New Title: ")
                        author = input("New Author: ")
                        update_book(bid, title, author)

                    elif ch == "4":
                        bid = int(input("Enter Book ID to delete: "))
                        delete_book(bid)

                    elif ch == "5":
                        bid = int(input("Enter Book ID to borrow: "))
                        borrow_book(user_id, bid)

                    elif ch == "6":
                        bid = int(input("Enter Book ID to return: "))
                        return_book(bid)

                    elif ch == "7":
                        borrowed_books()

                    elif ch == "8":
                        overdue_books()

                    elif ch == "9":
                        print("👋 Logged out.")
                        break
                    else:
                        print("❌ Invalid choice.")

            else:
                print("❌ Invalid login credentials.")

        elif choice == "3":
            print("👋 Exiting system...")
            break
        else:
            print("❌ Invalid choice.")


if __name__ == "__main__":
    main()
    conn.close()
