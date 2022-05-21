# Creates a mock version of the SDB to test new queries.

CREATE DATABASE uw_sdb_datastore;
USE uw_sdb_datastore;
SET SESSION sql_mode = "";

-- Create student_1 table
CREATE TABLE student_1 ( 
	student_no INT,
	system_key INT
);

# Load table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Student_1_20173_20212.csv'
IGNORE
INTO TABLE student_1
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

DELETE FROM student_1 WHERE student_no = 0; # Need to delete. student_no = 0 are students who never enrolled at UW

SELECT * FROM student_1
ORDER BY student_no;

SELECT * FROM student_1 WHERE student_no = 1770048;