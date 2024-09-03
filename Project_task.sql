select * from books;
select * from branch;
select * from employees;
select * from members;
select * from issued_status;
select * from return_status;

--- Question & Answers ---

--- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books values('978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--- Task 2. Update an Existing Member's Address

update members 
set member_address = '125 Oak St'
where member_id = 'C103';

--- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status where issued_id = 'IS121';

--- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select issued_book_name from issued_status where issued_emp_id = 'E101';

--- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select members.member_name,count(issued_status.issued_member_id) from members 
join issued_status 
on members.member_id = issued_status.issued_member_id
group by members.member_name 
having count(issued_status.issued_member_id) > 1;

--- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_issued_cnt as 
select b.isbn,b.book_title,count(i.issued_id) as issue_count
from issued_status as i
join books as b
on i.issued_book_isbn = b.isbn
group by b.isbn, b.book_title;

select * from book_issued_cnt;

--- Task 7. Retrieve All Books in a Specific Category

select * from books
where category = 'Classic';

--- Task 8: Find Total Rental Income by Category

select category,sum(rental_price) from books
group by category;

--- Task 9: List Members Who Registered in the Last 180 Days

select * from members
where reg_date >= CURRENT_DATE - INTERVAL '180 days';

--- Task 10. List Employees with Their Branch Manager's Name and their branch details

select e2.emp_name as Manager,e1.emp_id, e1.emp_name, e1.position, e1.salary
from employees as e1
join branch as b
on e1.branch_id = b.branch_id
join employees as e2
on e2.emp_id = b.manager_id
order by e1.emp_name;

--- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7.

create table expensive_books as
select * from books
where rental_price > 7;

select * from expensive_books;

--- Task 12: Retrieve the List of Books Not Yet Returned

select * from issued_status as ist
left join return_status as rs 
on ist.issued_id = rs.issued_id
where rs.return_id is NULL;

/* Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

select 
ist.issued_member_id, 
m.member_name, 
b.book_title, 
ist.issued_date, 
-- rs.return_date,
(current_date - ist.issued_date) as overdue_days
from issued_status as ist
join members as m
on m.member_id = ist.issued_member_id
join books as b
on ist.issued_book_isbn = b.isbn
left join 
return_status as rs
ON rs.issued_id = ist.issued_id
where rs.return_date is null
and (current_date - ist.issued_date) > 30
ORDER BY 1;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are 
returned (based on entries in the return_status table).
*/


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

create table branch_reports
select 
	b.branch_id, 
	b.manager_id, 
	count(ist.issued_id) as no_of_books_issued,
	count(rs.return_id) as no_of_books_returned,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join employees as e
on ist.issued_emp_id = e.emp_id
join books as bk
on bk.isbn = ist.issued_book_isbn
left join return_status as rs
on ist.issued_id = rs.issued_id
join branch as b
on b.branch_id = e.branch_id
group by b.manager_id,b.branch_id;

select * from branch_reports;

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 6 months.
*/

CREATE TABLE active_members AS
SELECT DISTINCT m.*
FROM members m
JOIN issued_status ist
ON m.member_id = ist.issued_member_id
WHERE ist.issued_date >= CURRENT_DATE - INTERVAL '6 month';

select * from active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

select e.emp_name, b.branch_id, count(ist.issued_id) as no_of_book_issues
from issued_status as ist
join employees as e
on ist.issued_emp_id = e.emp_id
join branch as b
on e.branch_id = b.branch_id
group by e.emp_name, b.branch_id
order by no_of_book_issues desc
limit 3;
