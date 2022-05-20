CREATE DATABASE test;
USE test;
SET GLOBAL sql_mode = "";

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
INSERT INTO hip_input
VALUES ("BUS", 307, "A", 20203, "Project-Based", "", "", "", ""), ("A A", 308, "B", 20201, "Placement-Based", "Internship", "", "", "");
SELECT * FROM hip_input;

-- Create dimDate table
CREATE TABLE dimDate (
	CalendarDateKeyId INT,
    CalendarDate DATETIME,
    AcademicQtr TINYINT,
	AcademicQtrKeyId INT,
    AcademicYrName VARCHAR(50),
    AcademicQtrBeginInd CHAR,
	AcademicQtrCensusDayInd CHAR,
	AcademicQtrLastInstructionDayInd CHAR
);
INSERT INTO dimDate
VALUES (20200926, '2020-09-26 00:00:00.000', 3, 20201, "2020/2021", 'N', 'Y', 'N'), (20200326, '2020-03-26 00:00:00.000', 3, 20203, "2019/2020", 'N', 'Y', 'N');
SELECT * FROM dimDate;

-- Create factStudentCreditHour table
CREATE TABLE factStudentCreditHour (
	StudentKeyId INT,
    CalendarDateKeyID INT,
    CurriculumCourseKeyId INT,
    CourseSectionId VARCHAR(3),
    SCHQty DECIMAL(3, 1)
);
INSERT INTO factStudentCreditHour
VALUES (9001, 20200926, 1001, "A  ", 5.0), (9002, 20200326, 1002, "B  ", 4.0), (9002, 20200326, 1003, "B  ", 4.0);
SELECT * FROM factStudentCreditHour;

CREATE TABLE dimCurriculumCourse (
	CurriculumCourseKeyId INT,
    CurriculumCode VARCHAR(6),
    CourseNbr SMALLINT,
    CourseLongName VARCHAR(120),
    CourseShortName VARCHAR(50),
    CurriculumFullName VARCHAR(200),
    RecordEffBeginDttm DATETIME,
    RecordEffEndDttm DATETIME
);
INSERT INTO dimCurriculumCourse
VALUES (1001, "BUS   ", 307, "BUS307 LONG", "BUS307 SHORT", "BUS307 Some FULL", '2020-09-26 00:00:00.000', '2020-09-27 00:00:00.000'),
 (1002, "A A   ", 308, "A A308 LONG", "A A308 SHORT", "A A308 Some FULL", '2020-09-26 00:00:00.000', '2020-09-27 00:00:00.000'),
 (1003, "COM   ", 309, "COM309 LONG", "COM309 SHORT", "COM309 Some FULL", '2020-09-26 00:00:00.000', '2020-09-27 00:00:00.000');
 SELECT * FROM dimCurriculumCourse;

-- Links courses with all students who participated.
CREATE TABLE student_participation (
	StudentKeyId INT,
	CurriculumCourseKeyId INT NOT NULL,
    CourseLongName VARCHAR(120),
    CourseSectionId VARCHAR(3),
    AcademicQtrKeyId INT,
    SCHQty DECIMAL(3, 1),
	TypeOfParticipation VARCHAR(200) DEFAULT NULL
);
SELECT * FROM student_participation;



-- fill student_participation table
#INSERT INTO student_participation
SELECT  StudentKeyId, CurriculumCourseKeyId, CourseLongName, all_courses.CourseSectionId, all_courses.AcademicQtrKeyId, SCHQty, CASE WHEN hip_courses.TypeOfParticipationX IS NOT NULL THEN hip_courses.TypeOfParticipationX ELSE "X" END AS TypeOfParticipation
FROM
	(SELECT CurrCourse.CurriculumCourseKeyId, CurriculumCode, CourseNbr, CourseLongName, StudentKeyId, CourseSectionId, SCHQty, AcademicQtrKeyId, NULL AS TypeOfParticipation 
	FROM 
		(SELECT CurriculumCourseKeyId, CurriculumCode, CourseNbr, CourseLongName
		FROM test.dimCurriculumCourse) as CurrCourse
	INNER JOIN
		(SELECT StudentKeyId, CurriculumCourseKeyId, CourseSectionId, SCHQty, AcademicQtrKeyId
		FROM test.factStudentCreditHour
		INNER JOIN
			(SELECT CalendarDateKeyId, AcademicQtrKeyId 
			FROM test.dimDate
			WHERE AcademicQtrCensusDayInd = 'Y') AS date_query
		ON test.factStudentCreditHour.CalendarDateKeyId = date_query.CalendarDateKeyId) AS date_student
	ON CurrCourse.CurriculumCourseKeyId = date_student.CurriculumCourseKeyId) AS all_courses
LEFT JOIN
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
LIMIT 5
;
SELECT * FROM student_participation;
