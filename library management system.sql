-- SQL Code for Library Management System (MySQL)

-- Drop tables if they exist to allow for re-running the script
DROP TABLE IF EXISTS Borrowings;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Books;

-- Books Table
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    genre VARCHAR(50),
    publication_year INT,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1
);

-- Members Table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    registration_date DATE NOT NULL
);

-- Borrowings Table
CREATE TABLE Borrowings (
    borrow_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE, -- NULL if not yet returned
    due_date DATE NOT NULL,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Insert Sample Data

-- Books
INSERT INTO Books (title, author, isbn, genre, publication_year, total_copies, available_copies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 'Classic', 1925, 5, 5),
('1984', 'George Orwell', '9780451524935', 'Dystopian', 1949, 3, 3),
('To Kill a Mockingbird', 'Harper Lee', '9780061120084', 'Fiction', 1960, 4, 4),
('Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', '9780062316097', 'Non-Fiction', 2014, 2, 2),
('The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams', '9780345391803', 'Sci-Fi', 1979, 3, 3);

-- Members
INSERT INTO Members (first_name, last_name, email, phone_number, registration_date) VALUES
('John', 'Doe', 'john.doe@example.com', '111-222-3333', '2024-01-10'),
('Jane', 'Smith', 'jane.smith@example.com', '444-555-6666', '2024-02-15'),
('Peter', 'Jones', 'peter.j@example.com', '777-888-9999', '2024-03-01');

-- Borrowings
INSERT INTO Borrowings (book_id, member_id, borrow_date, due_date) VALUES
(1, 1, '2024-05-01', '2024-05-15'), -- John borrows Gatsby
(3, 2, '2024-05-05', '2024-05-19'), -- Jane borrows Mockingbird
(1, 3, '2024-05-07', '2024-05-21'); -- Peter borrows Gatsby

-- Update available copies after initial borrowings
UPDATE Books SET available_copies = available_copies - 1 WHERE book_id IN (1, 3);

-- Example Queries

-- 1. List all books currently borrowed (not yet returned)
SELECT
    b.title,
    b.author,
    m.first_name,
    m.last_name,
    br.borrow_date,
    br.due_date
FROM Borrowings br
JOIN Books b ON br.book_id = b.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL;

-- 2. Find all overdue books
SELECT
    b.title,
    b.author,
    m.first_name,
    m.last_name,
    br.borrow_date,
    br.due_date
FROM Borrowings br
JOIN Books b ON br.book_id = b.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL AND br.due_date < CURDATE(); -- CURDATE() gets current date in MySQL

-- 3. List books by a specific author
SELECT
    title,
    genre,
    publication_year
FROM Books
WHERE author = 'George Orwell';

-- 4. Count total copies and available copies for each book
SELECT
    title,
    total_copies,
    available_copies
FROM Books;

-- 5. Find members who have borrowed more than one book
SELECT
    m.first_name,
    m.last_name,
    COUNT(br.borrow_id) AS number_of_books_borrowed
FROM Members m
JOIN Borrowings br ON m.member_id = br.member_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(br.borrow_id) > 1;

-- 6. Update a book as returned (example for book_id 1, borrowed by member_id 1)
-- This would typically be handled by an application, updating both Borrowings and Books tables.
-- Here's the SQL:
-- UPDATE Borrowings SET return_date = CURDATE() WHERE book_id = 1 AND member_id = 1 AND return_date IS NULL;
-- UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = 1;