#Creates a set of tables that stores relevant student and course information related to HIP activities
/*
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
SELECT * FROM hip_input;

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
SELECT * FROM hip_input
ORDER BY CurriculumCode, CourseNbr, CourseSectionId, AcademicQtrKeyId;

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
SELECT * FROM student_participation;


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
SELECT * FROM student_participation;

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
SELECT * FROM student_alias;
*/



#DROP TABLE student_alias;


/*
-- Fill student_id_link
INSERT INTO student_id_link
SELECT RandomId, system_key, StudentKeyId
FROM student_alias
INNER JOIN
	(SELECT StudentKeyId, SDBSrcSystemKey
	FROM enterprise_data_warehouse.dimStudent) AS subquery_1
ON subquery_1.SDBSrcSystemKey = system_key
;
SELECT * FROM student_id_link;

-- student_demographic
INSERT INTO student_profile
SELECT student_3.RandomId, student_3.AcademicQtrKeyId, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus, StudentClassCode, GenderCode, ethnic_grp_id, MajorKeyId
FROM
	(SELECT RandomId, AcademicQtrKeyId, MajorKeyId, StudentClassCode, GenderCode, ethnic_grp_id
	FROM student_id_link
	INNER JOIN
		(SELECT student.StudentKeyId, AcademicQtrKeyId, MajorKeyId, StudentClassCode, GenderCode, ethnic_grp_id
		FROM
			(SELECT StudentKeyId, StudentClassCode, GenderCode, 1 AS ethnic_grp_id
			FROM enterprise_data_warehouse.dimStudent
			WHERE HispanicInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 2
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAfricanAmerInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 3
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAmerIndianInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 4
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpAsianInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 5
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpCaucasianInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 6
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpHawaiiPacIslanderInd = 'Y'
			UNION ALL
			SELECT StudentKeyId, StudentClassCode, GenderCode, 7
			FROM enterprise_data_warehouse.dimStudent
			WHERE EthnicGrpNotIndicatedInd = 'Y') AS student
		INNER JOIN
			(SELECT StudentKeyId, AcademicQtrKeyId, MajorKeyId
			FROM enterprise_data_warehouse.dimDate
			INNER JOIN
				-- Join hip_course_student with student_id_link
				(SELECT StudentKeyId, major.MajorKeyId, CalendarDateKeyId
				FROM enterprise_data_warehouse.factStudentProgramEnrollment
				INNER JOIN
					(SELECT MajorKeyId, MajorAbbrCode, MajorName
					FROM enterprise_data_warehouse.dimMajor) AS major
				ON enterprise_data_warehouse.factStudentProgramEnrollment.MajorKeyId = major.MajorKeyId) AS student_major
			ON enterprise_data_warehouse.dimDate.CalendarDateKeyId = student_major.CalendarDateKeyId) AS student_1
		ON student.StudentKeyId = student_1.StudentKeyId) AS student_2
	ON  student_2.StudentKeyId = student_id_link.StudentKeyId) AS student_3
INNER JOIN
	(SELECT RandomId, AcademicQtrKeyId, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus
	FROM student_id_link
	INNER JOIN
		(SELECT SDBSrcSystemKey, dimDate.AcademicQtrKeyId, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus
		FROM enterprise_data_warehouse.dimDate
		INNER JOIN
			(SELECT SDBSrcSystemKey, CalendarDate, FirstGenInd, FirstGen4YearInd, AcademicOriginType, Veteran, PellEligibilityStatus
			FROM enterprise_data_warehouse.UWProfilesStudent) AS uw_profiles
		ON dimDate.CalendarDate = uw_profiles.CalendarDate) AS uw_profiles_1
	ON student_id_link.system_key = uw_profiles_1.SDBSrcSystemKey) AS uw_profiles_2
ON student_3.RandomId = uw_profiles_2.RandomId AND student_3.AcademicQtrKeyId= uw_profiles_2.AcademicQtrKeyId;
SELECT * FROM student_profile;
*/