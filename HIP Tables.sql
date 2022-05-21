#Creates a set of tables that stores relevant student and course information related to HIP activities

CREATE DATABASE uwb_hip;
USE uwb_hip;
SET GLOBAL sql_mode = "";

-- Holds the course and section and HIP identification code for classes identified as HIP. Acts as the input table for the rest of the HIP database.
CREATE TABLE hip_input(
	CurriculumCode VARCHAR(6), #Course_Prefix from hip_participation_data
	CourseNbr SMALLINT, #Course_Number from hip_participation_data
    CourseSectionId VARCHAR(3), #Section from hip_participation_data
    AcademicQtrKeyId INT, #from hip_participation_data
	CBLR VARCHAR(120), #from hip_participation_data
	Internship VARCHAR(25), #from hip_participation_data
	GlobalLearning VARCHAR(25), #from hip_participation_data
	LearningCommunity VARCHAR(25), #from hip_participation_data
	UndergradResearch VARCHAR(25) #from hip_participation_data
);
#SELECT * FROM hip_input;

-- Insert values into hip_participation_data table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ALL UNITS 2020-2021 HIPs Participation Data 12-6-2021.csv'
IGNORE
INTO TABLE hip_input
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@Reporting_Unit, @School_Unit, CurriculumCode, CourseNbr, CourseSectionId, 
@Divison_of_Course_Level, @Combined_Course_Code, @CourseorProgramName, 
AcademicQtrKeyId, @course_year, @course_quarter, @Unique_Count_of_Course, 
@Faculty, @Organizations, @Provost_Report_Activity_Type, CBLR, Internship, 
GlobalLearning, LearningCommunity, UndergradResearch, @Capstone, 
@FirstYearExperience, @Notes);
DELETE FROM hip_input WHERE CurriculumCode = ""; # Need to empty CurriculumCode rows
#SELECT * FROM hip_input
#ORDER BY CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId;

-- Links courses with all students who participated.
CREATE TABLE student_participation (
	StudentKeyId INT,
	CurriculumCourseKeyId INT NOT NULL,
    CourseLongName VARCHAR(120),
    CourseSectionId VARCHAR(3),
    AcademicQtrKeyId INT,
    AcademicYrName VARCHAR(50),
    SCHQty DECIMAL(3, 1),
	TypeOfParticipation VARCHAR(200) DEFAULT NULL
);
#SELECT * FROM student_participation;


-- fill student_participation table
INSERT INTO student_participation
SELECT  StudentKeyId, CurriculumCourseKeyId, CourseLongName, all_courses.CourseSectionId, all_courses.AcademicQtrKeyId, AcademicYrName, SCHQty,  CASE WHEN hip_courses.TypeOfParticipationX IS NOT NULL THEN hip_courses.TypeOfParticipationX ELSE "" END AS TypeOfParticipation
FROM
	(SELECT CurrCourse.CurriculumCourseKeyId, CurriculumCode, CourseNbr, CourseLongName, StudentKeyId, CourseSectionId, SCHQty, AcademicQtrKeyId, AcademicYrName, NULL AS TypeOfParticipation 
	FROM 
		(SELECT CurriculumCourseKeyId, CurriculumCode, CourseNbr, CourseLongName
		FROM enterprise_data_warehouse.dimCurriculumCourse) as CurrCourse
	INNER JOIN
		(SELECT StudentKeyId, CurriculumCourseKeyId, CourseSectionId, SCHQty, AcademicQtrKeyId, AcademicYrName
		FROM enterprise_data_warehouse.factStudentCreditHour
		INNER JOIN
			(SELECT CalendarDateKeyId, AcademicQtrKeyId, AcademicYrName
			FROM enterprise_data_warehouse.dimDate
			WHERE AcademicQtrCensusDayInd = 'Y') AS date_query
		ON enterprise_data_warehouse.factStudentCreditHour.CalendarDateKeyId = date_query.CalendarDateKeyId) AS date_student
	ON CurrCourse.CurriculumCourseKeyId = date_student.CurriculumCourseKeyId) AS all_courses
INNER JOIN #Change to LEFT JOIN to include all courses
	(SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "CBLR" AS TypeOfParticipationX
	FROM hip_input
	WHERE CBLR <> "" AND Internship = "" AND UndergradResearch = ""
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "CBLR/Internship"
	FROM hip_input
	WHERE CBLR <> "" AND Internship <> ""
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "CBLR/Undergrad Research"
	FROM hip_input
	WHERE CBLR <> "" AND UndergradResearch <> ""
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "COIL"
	FROM hip_input
	WHERE GlobalLearning = "COIL"
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "Global Scholars"
	FROM hip_input
	WHERE GlobalLearning = "Global Scholars"
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "Internship"
	FROM hip_input
	WHERE Internship <> "" AND CBLR = ""
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "Study Abroad"
	FROM hip_input
	WHERE GlobalLearning = "Study Abroad"
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "Learning Community"
	FROM hip_input
	WHERE LearningCommunity <> "" AND LearningCommunity <> 'N/A'
	UNION ALL
	SELECT CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId, "Undergrad Research"
	FROM hip_input
	WHERE UndergradResearch <> "" AND CBLR = "") AS hip_courses
ON TRIM(all_courses.CurriculumCode) = hip_courses.CurriculumCode AND all_courses.CourseNbr = hip_courses.CourseNbr AND TRIM(all_courses.CourseSectionId) = hip_courses.CourseSectionId AND all_courses.AcademicQtrKeyId = hip_courses.AcademicQtrKeyId
;
#SELECT * FROM student_participation;

-- Converts student identification information from EDW and SDB into a non-personalized ID value. The purpose is to mask personally identifiable information regarding students in the database.
CREATE TABLE student_alias (
	RandomId INT PRIMARY KEY AUTO_INCREMENT,
    system_key INT,
	student_no INT
);
 ALTER TABLE student_alias AUTO_INCREMENT=4694927;

-- Creates a masked ID for every student in the UW system
INSERT INTO student_alias (system_key, student_no)
SELECT system_key, student_no
FROM uw_sdb_datastore.student_1
;
#SELECT * FROM student_alias;


-- Contains student information
CREATE TABLE student_profile (
	RandomId INT,
    StudentKeyId INT,
    student_no INT,
    AcademicQtrKeyId INT,
	FirstGenerationMatriculated CHAR(1),
	FirstGeneration4YrDegree CHAR(1),
	AcademicCareerEntryType VARCHAR(100),
    Veteran SMALLINT,
    PellEligibilityStatus VARCHAR(100),
    StudentClassDesc VARCHAR(100),
    GenderCode VARCHAR(10),
    RaceEthnicityCategory VARCHAR(100),
    MajorFullName VARCHAR(100),
    MajorAbbrCode VARCHAR(10)
);

-- student_demographic
INSERT INTO student_profile
SELECT RandomId, StudentKeyId, student_no, AcademicQtrKeyId,  FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus, StudentClassDesc, GenderCode, RaceEthnicityCategory, MajorFullName, MajorAbbrCode
FROM uwb_hip.student_alias
INNER JOIN
	(SELECT student.SDBSrcSystemKey, student.AcademicQtrKeyId, StudentKeyId, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus, StudentClassDesc, GenderCode, RaceEthnicityCategory, MajorFullName, MajorAbbrCode
	FROM
		(SELECT SDBSrcSystemKey, student_major.StudentKeyId, AcademicQtrKeyId, MajorFullName, MajorAbbrCode, StudentClassDesc, GenderCode, RaceEthnicityCategory
		FROM
			(SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Hispanic" AS RaceEthnicityCategory
			FROM enterprise_data_warehouse.dimStudent
			WHERE HispanicInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "African American"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAfricanAmerInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "American Indian"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAmerIndianInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Asian"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAsianInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Caucasian"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpCaucasianInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Hawaiian/Pacific Islander"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpHawaiiPacIslanderInd = 'Y' AND EthnicGrpMultipleInd <> 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Multiple"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpMultipleInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, SDBSrcSystemKey, GenderCode,  StudentClassDesc, "Other"
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpNotIndicatedInd = 'Y' AND EthnicGrpMultipleInd <> 'Y') AS student
		INNER JOIN
			(SELECT StudentKeyId, AcademicQtrKeyId, MajorFullName, MajorAbbrCode
			FROM
				(SELECT DISTINCT StudentKeyId, enterprise_data_warehouse.factStudentProgramEnrollment.MajorKeyId, date_table.AcademicQtrKeyId
				FROM enterprise_data_warehouse.factStudentProgramEnrollment
				INNER JOIN
					(SELECT CalendarDateKeyId, AcademicQtrKeyId
					FROM enterprise_data_warehouse.dimDate
					WHERE enterprise_data_warehouse.dimDate.AcademicQtrCensusDayInd = 'Y') AS date_table
				ON date_table.CalendarDateKeyId = enterprise_data_warehouse.factStudentProgramEnrollment.CalendarDateKeyId) AS student_major_quarter
			INNER JOIN
				(SELECT MajorKeyId, MajorAbbrCode, MajorFullName
				FROM enterprise_data_warehouse.dimMajor) AS major
			ON student_major_quarter.MajorKeyId = major.MajorKeyId) AS student_major
		ON student_major.StudentKeyId = student.StudentKeyId) AS student
	INNER JOIN
			(SELECT SDBSrcSystemKey, AcademicQtrKeyId, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus
			FROM
				(SELECT CalendarDate, AcademicQtrKeyId
				FROM enterprise_data_warehouse.dimDate
				WHERE enterprise_data_warehouse.dimDate.AcademicQtrCensusDayInd = 'Y') AS date_table2
			INNER JOIN
				(SELECT SDBSrcSystemKey, CalendarDate, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus
				FROM enterprise_data_warehouse.UWProfilesStudent) AS uw_profiles
			ON date_table2.CalendarDate = uw_profiles.CalendarDate) AS uw_student
	ON student.SDBSrcSystemKey = uw_student.SDBSrcSystemKey AND student.AcademicQtrKeyId = uw_student.AcademicQtrKeyId) AS student_info
ON uwb_hip.student_alias.system_key = student_info.SDBSrcSystemKey
;
#SELECT * FROM student_profile;


CREATE TABLE output (
	student_no INT,
    RandomId INT,
    AcademicQtrKeyId INT,
    FirstGenerationMatriculated CHAR(1),
	FirstGeneration4YrDegree CHAR(1),
	AcademicCareerEntryType VARCHAR(100),
    Veteran SMALLINT,
    PellEligibilityStatus VARCHAR(100),
    AcademicYrName VARCHAR(50),
    StudentClassDesc VARCHAR(100),
    GenderCode VARCHAR(10),
    RaceEthnicityCategory VARCHAR(100),
    MajorFullName VARCHAR(100),
    MajorAbbrCode VARCHAR(10),
    CourseSectionId VARCHAR(3),
    CourseLongName VARCHAR(120),
    SCHQty DECIMAL(3, 1),
    TypeOfParticipation VARCHAR(200)
);

INSERT INTO output
SELECT student_no, RandomId, student_participation.AcademicQtrKeyId, FirstGenerationMatriculated, FirstGeneration4YrDegree, AcademicCareerEntryType, Veteran, PellEligibilityStatus, AcademicYrName, StudentClassDesc, GenderCode, RaceEthnicityCategory, MajorFullName, MajorAbbrCode, CourseSectionId, CourseLongName, SCHQty, TypeOfParticipation
FROM student_participation
INNER JOIN student_profile
ON student_participation.StudentKeyId = student_profile.StudentKeyId AND student_participation.AcademicQtrKeyId = student_profile.AcademicQtrKeyId;
SELECT * FROM output;