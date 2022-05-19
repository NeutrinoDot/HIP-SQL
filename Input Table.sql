CREATE DATABASE uwb_hip;
USE uwb_hip;

CREATE TABLE hip_participation_data(
	Reporting_Unit VARCHAR(25),
	School_Unit VARCHAR(25),
	Course_Prefix  VARCHAR(25),
	Course_Number INT,
	Section  VARCHAR(3),
	Divison_of_Course_Level VARCHAR(10),
	Combined_Course_Code VARCHAR(120),
	CourseorProgramName VARCHAR(120),
	AcademicQtrKeyId INT,
	course_year INT,
	course_quarter VARCHAR(25),
	Unique_Count_of_Course VARCHAR(5),
    Faculty VARCHAR(100),
    Organizations VARCHAR(700),
	Provost_Report_Activity_Type VARCHAR(50),
	CBLR VARCHAR(120),
	Internship VARCHAR(25),
	GlobalLearning VARCHAR(25),
	LearningCommunity VARCHAR(25),
	UndergradResearch VARCHAR(25),
	Capstone VARCHAR(25),
	First_Year_Experience VARCHAR(25),
	Notes  VARCHAR(120)
);
-- Insert values into hip_participation_data table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ALL UNITS 2020-2021 HIPs Participation Data 12-6-2021.csv'
INTO TABLE hip_participation_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
SELECT * FROM hip_participation_data;


/*
CREATE TABLE hip_course_section (
	CurriculumCourseKeyId INT,
    CourseSectionId VARCHAR(3),
    CourseHipType INT NOT NULL,
    CourseSectionHipType INT
);

INSERT hip_course_section VALUES 
	(321, NULL, 0, NULL),
    (462, 'A', 1, 3),
    (293, NULL, 2, NULL),
    (423, NULL, 3, NULL);
SELECT * FROM hip_course_section;

*/

	