#Creates a set of tables that stores relevant student and course information related to HIP activities
/*
USE uwb_hip;

-- duplicate of the input CSV

*/


/*
-- Links courses with all students who participated.
CREATE TABLE hip_type_code (
	hip_type INT,
    hip_description VARCHAR(25)
);
SELECT * FROM hip_type_code;

-- Holds the course and section and HIP identification code for classes identified as HIP. Acts as the input table for the rest of the HIP database.
CREATE TABLE hip_input(
	CurriculumCourseKeyId INT,
    course_section CHAR(1),
    AcademicQtrKeyId INT,
	hip_type INT
);
SELECT * FROM hip_input;

-- Links courses with all students who participated.
CREATE TABLE student_participation (
	StudentKeyId INT,
	CurriculumCourseKeyId INT NOT NULL,
    CourseLongName VARCHAR(120),
    CourseSectionId VARCHAR(3),
    AcademicQtrKeyId INT,
    SCHQty DECIMAL(3, 1),
	hip_type INT
);
SELECT * FROM student_participation;

-- Converts student identification information from EDW and SDB into a non-personalized ID value. The purpose is to mask personally identifiable information regarding students in the database.
CREATE TABLE student_alias (
	RandomID INT PRIMARY KEY NOT NULL auto_increment,
    system_key INT UNIQUE,
	student_no INT UNIQUE
);
SELECT * FROM student_alias;

-- Creates a link between all various forms of student identification values.
CREATE TABLE student_id_link (
	RandomID INT,
    system_key INT,
    StudentKeyId INT
);
SELECT * FROM student_id_link;

-- Contains student information
CREATE TABLE student_profile (
	RandomID INT NOT NULL,
    AcademicQtrKeyId INT,
	FirstGenerationMatriculated CHAR(1),
	FirstGeneration4YrDegree CHAR(1),
	AcademicCareerEntryType VARCHAR(100),
    Veteran SMALLINT,
    PellEligibilityStatus VARCHAR(100),
    StudentClassCode INT,
    GenderCode VARCHAR(10),
    ethnic_grp_id INT,
    MajorKeyId INT
);
SELECT * FROM student_profile;

/*

CREATE TABLE student_demographic (
	RandomID INT NOT NULL,
	AcademicQtrKeyId INT,
	StudentClass TINYINT,
    GenderCode VARCHAR(10),
    ethnic_grp_id INT
);
SELECT * FROM student_demographic;

CREATE TABLE ethnic_grp (
	ethnic_grp_id INT NOT NULL,
	ethnic_grp_description VARCHAR(100)
);
SELECT * FROM student_major;

CREATE TABLE student_major (
	RandomID INT NOT NULL,
	AcademicQtrKeyId INT,
	PreMajorInd CHAR(1),
	MajorName VARCHAR(100),
	MajorCode VARCHAR(25),
	Department CHAR(1),
	SchoolAbbr  CHAR(6)
);
SELECT * FROM student_major;
*/