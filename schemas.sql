--- Library System Management ---

--- Table Creation ---

Drop table if exists branch;
create table branch(
branch_id varchar(50) primary key,	
manager_id varchar(50),
branch_address varchar(55),
contact_no integer 
);

alter table branch 
alter column contact_no type varchar(50);


Drop table if exists employees;
Create table employees (
emp_id	varchar(50) primary key,
emp_name varchar(100),	
position varchar(50),
salary	int,
branch_id varchar(50)
);

alter table employees 
alter column salary type float;

Drop table if exists books;
Create table books (
isbn varchar(100) primary key,
book_title varchar(100),
category varchar(100),
rental_price float,
status	varchar(100),
author varchar(100),
publisher varchar(100)
);

Drop table if exists members;
Create table members (
member_id varchar(50) primary key,
member_name varchar(50),
member_address	varchar(100),
reg_date date
);

Drop table if exists issued_status;
Create table issued_status (
issued_id	varchar(50) primary key,
issued_member_id varchar(50),
issued_book_name varchar(150),
issued_date date,
issued_book_isbn varchar(50),
issued_emp_id varchar(50)
);

Drop table if exists return_status;
Create table return_status (
return_id varchar(50) primary key,
issued_id varchar(50),
return_book_name varchar(150),
return_date	date,
return_book_isbn varchar(50)
);


--- Foreign Key ---
alter table issued_status 
add constraint fk_members 
foreign key (issued_member_id)
references members(member_id);

alter table issued_status 
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status 
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees 
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status 
add constraint fk_return
foreign key (issued_id)
references issued_status(issued_id);

--- Inseation of Data ---
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');
