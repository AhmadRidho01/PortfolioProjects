

-- OBJECTIVES
-- 1. Set up the Library Management System Database: Create and populate the database
-- with tables for branches, employees, members, books, issued status, and return status.

-- 2. CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.

-- 3. CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.

-- 4. Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

-- =====
-- =====



-- 1. Set up the Library Management System Database: Create and populate the database
-- with tables for branches, employees, members, books, issued status, and return status.

-- CREATE STAGING TABLE

-- Table "Books"
SELECT *
into Books_staging
from Books
where 1 = 0;

insert into Books_staging
select * from Books;


-- Table "Branch"
SELECT *
into Branch_staging
from Branch
where 1 = 0;

insert into Branch_staging
select * from Branch;


-- Table "Employees"
SELECT *
into Employees_staging
from Employees
where 1 = 0;

insert into Employees_staging
select * from Employees;


-- Table "Issued_Status"
SELECT *
into Issued_Status_staging
from Issued_Status
where 1 = 0;

insert into Issued_Status_staging
select * from Issued_Status;


-- Table "Members"
SELECT *
into Members_staging
from Members
where 1 = 0;

insert into Members_staging
select * from Members;


-- Table "Return_Status"
SELECT *
into Return_Status_staging
from Return_Status
where 1 = 0;

insert into Return_Status_staging
select * from Return_Status;



-- 2. CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.

-- Task 1 Create a New Book Record
INSERT INTO Books_staging(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM Books_staging
WHERE isbn = '978-1-60129-456-2';


-- Task 2 Update an Exisiting Member's Address
UPDATE Members_staging
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

SELECT * FROM Members_staging WHERE member_id = 'C103';


-- Task 3 Delete a Record from the Issued Status Table
DELETE FROM Issued_Status_staging
WHERE issued_id = 'IS121';

SELECT * FROM Issued_Status_staging WHERE issued_id = 'IS121';


-- Task 4 Retrieve All Books Issued by a Specific Employee
SELECT 
    ist.issued_id,
    ist.issued_book_name,
    ist.issued_date,
    b.book_title
FROM Issued_Status_staging AS ist
JOIN Books_staging AS b
ON ist.issued_book_isbn = b.isbn
WHERE ist.issued_emp_id = 'E101';

SELECT DISTINCT issued_emp_id FROM Issued_Status_staging WHERE issued_emp_id = 'E101';


-- Task 5 List Members Who Have Issued More Than One Book
SELECT 
    ist.issued_member_id,
    m.member_name,
    COUNT(ist.issued_id) AS book_count
FROM Issued_Status_staging AS ist
JOIN Members_staging AS m
ON ist.issued_member_id = m.member_id
GROUP BY ist.issued_member_id, m.member_name
HAVING COUNT(ist.issued_id) > 1;

SELECT DISTINCT issued_member_id FROM Issued_Status_staging;



-- 3. CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.

SELECT 
    b.isbn, 
    b.book_title, 
    COUNT(ist.issued_id) AS issue_count
INTO book_issued_cnt
FROM Issued_Status_staging AS ist
JOIN Books_staging AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_issued_cnt
ORDER BY issue_count DESC;



-- 4. Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.
-- Task 1: Retrieve All Books in a Specific Category
SELECT 
    isbn, 
    book_title, 
    category, 
    rental_price, 
    author, 
    publisher
FROM 
    Books_staging
WHERE 
    category = 'Classic'; -- Category


-- Task 2: Find Total Rental Income by Category
SELECT 
    category, 
    SUM(rental_price) AS total_rental_income
FROM 
    Books_staging
GROUP BY 
    category
ORDER BY 
    total_rental_income DESC;


-- Task 3: List Members Who Registered in the Last 180 Days
SELECT * 
FROM 
    Members_staging
WHERE 
    reg_date >= DATEADD(DAY, -180, GETDATE());


-- Task 4: List Employees with Their Branch Manager's Name and Their Branch Details
SELECT 
    e.emp_id, 
    e.emp_name AS Employee_Name, 
    e.position AS Employee_Position, 
    e.salary, 
    b.branch_id, 
    b.manager_id, 
    m.emp_name AS Manager_Name, 
    b.branch_address, 
    b.contact_no
FROM 
    Employees_staging AS e
JOIN 
    Branch_staging AS b
ON 
    e.branch_id = b.branch_id
JOIN 
    Employees_staging AS m
ON 
    b.manager_id = m.emp_id
ORDER BY 
    b.branch_id;


-- Task 5: Create a Table of Books with Rental Price Above a Certain Threshold
SELECT 
    isbn, 
    book_title, 
    rental_price, 
    category, 
    author, 
    publisher
INTO 
    High_Rental_Books
FROM 
    Books_staging
WHERE 
    rental_price > 7;

SELECT * FROM High_Rental_Books;


-- Task 6: Retrieve the List of Books Not Yet Returned
SELECT 
    ist.issued_id, 
    ist.issued_book_isbn, 
    ist.issued_book_name, 
    ist.issued_date, 
    m.member_name AS Issued_To, 
    e.emp_name AS Issued_By
FROM 
    Issued_Status_staging AS ist
LEFT JOIN 
    Return_Status_staging AS rs
ON 
    ist.issued_id = rs.issued_id
JOIN 
    Members_staging AS m
ON 
    ist.issued_member_id = m.member_id
JOIN 
    Employees_staging AS e
ON 
    ist.issued_emp_id = e.emp_id
WHERE 
    rs.return_id IS NULL
ORDER BY 
    ist.issued_date DESC;


-- Task 7: Identify Members with Overdue Books
SELECT 
    m.member_id, 
    m.member_name, 
    b.book_title, 
    i.issued_date, 
    DATEDIFF(DAY, i.issued_date, GETDATE()) - 30 AS days_overdue
FROM 
    Members_staging m
JOIN 
    Issued_Status_staging i ON m.member_id = i.issued_member_id
JOIN 
    Books_staging b ON i.issued_book_isbn = b.isbn
WHERE 
    DATEDIFF(DAY, i.issued_date, GETDATE()) > 30;


-- Task 8: Update Book Status on Return
UPDATE Books_staging
SET status = 'Yes'
WHERE isbn IN (
    SELECT return_book_isbn 
    FROM Return_Status_staging
);


-- Task 9: Branch Performance Report
SELECT 
    b.branch_id, 
    COUNT(DISTINCT i.issued_id) AS total_books_issued, 
    COUNT(DISTINCT r.return_id) AS total_books_returned, 
    SUM(bk.rental_price) AS total_revenue
FROM 
    Branch_staging b
LEFT JOIN 
    Employees_staging e ON b.branch_id = e.branch_id
LEFT JOIN 
    Issued_Status_staging i ON e.emp_id = i.issued_emp_id
LEFT JOIN 
    Return_Status_staging r ON i.issued_id = r.issued_id
LEFT JOIN 
    Books_staging bk ON i.issued_book_isbn = bk.isbn
GROUP BY 
    b.branch_id;


-- Task 10: CTAS: Create a Table of Active Members
SELECT DISTINCT 
    m.member_id, 
    m.member_name, 
    m.member_address, 
    m.reg_date
INTO 
    active_members
FROM 
    Members_staging m
JOIN 
    Issued_Status_staging i ON m.member_id = i.issued_member_id
WHERE 
    i.issued_date >= DATEADD(MONTH, -2, GETDATE());

SELECT *
FROM active_members


-- Task 11: Find Employees with the Most Book Issues Processed
SELECT TOP 3 
    e.emp_name, 
    COUNT(i.issued_id) AS books_processed, 
    b.branch_address
FROM 
    Employees_staging e
JOIN 
    Issued_Status_staging i ON e.emp_id = i.issued_emp_id
JOIN 
    Branch_staging b ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name, b.branch_address
ORDER BY 
    books_processed DESC;


-- Task 12: Identify Members Issuing High-Risk Books
SELECT 
    m.member_name,
    b.book_title,
    COUNT(*) AS damaged_issue_count
FROM 
    Issued_Status_staging i
JOIN 
    Members_staging m ON i.issued_member_id = m.member_id
JOIN 
    Books_staging b ON i.issued_book_isbn = b.isbn
WHERE 
    b.status = 'damaged'
GROUP BY 
    m.member_name, b.book_title
HAVING 
    COUNT(*) > 2;


-- Task 13: Stored Procedure to Manage Book Status
CREATE PROCEDURE UpdateBookStatus
    @book_id NVARCHAR(50)
AS
BEGIN
    -- Check the current status of the book
    IF EXISTS (SELECT 1 FROM Books WHERE isbn = @book_id AND status = 'yes')
    BEGIN
        -- Update the status to 'no'
        UPDATE Books_staging
        SET status = 'no'
        WHERE isbn = @book_id;

        PRINT 'The book has been issued successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Error: The book is currently not available.';
    END
END;


EXEC UpdateBookStatus '978-1-60129-456-2';


-- Task 14: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
SELECT 
    m.member_id,
    COUNT(CASE WHEN DATEDIFF(DAY, i.issued_date, GETDATE()) > 30 AND r.return_id IS NULL THEN 1 END) AS overdue_books_count,
    SUM(CASE WHEN DATEDIFF(DAY, i.issued_date, GETDATE()) > 30 AND r.return_id IS NULL 
             THEN (DATEDIFF(DAY, i.issued_date, GETDATE()) - 30) * 0.50 
             ELSE 0 END) AS total_fines,
    COUNT(i.issued_id) AS total_books_issued
INTO Overdue_Books_Report
FROM 
    Members_staging m
JOIN 
    Issued_Status_staging i ON m.member_id = i.issued_member_id
LEFT JOIN 
    Return_Status_staging r ON i.issued_id = r.issued_id
GROUP BY 
    m.member_id;

SELECT *
FROM Overdue_Books_Report
