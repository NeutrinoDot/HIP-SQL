USE uwb_hip;

INSERT hip_participation_data VALUES
	('CBLR', 'BUS', 'B BUS', 307, 'A', 'Upper', '#N/A', 'Business Writing', 20203, 2020, 'Summer', 'Y', 'Faculty Name', 'Organization Name', 'Public Service', 'Project-Based', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (NULL, NULL, 'CSS', 497, 'B', NULL, NULL, NULL, 20181, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Internship', NULL, NULL, NULL, NULL, NULL, NULL),
    (NULL, NULL, 'B WRIT', 135, 'A', NULL, NULL, NULL, 20182, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Yes', NULL, NULL, NULL),
    (NULL, NULL, 'BIS', 406, 'A', NULL, NULL, NULL, 20193, NULL, NULL, NULL, NULL, NULL, NULL, 'Project-Based', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (NULL, NULL, 'FSTDY', 300, 'A', NULL, NULL, NULL, 20191, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Study Abroad', NULL, NULL, NULL, NULL, NULL)
;
SELECT * FROM hip_participation_data;

-- Inserts a list of all the HIP courses/sections
-- INSERT INTO hip_input

INSERT hip_type_code VALUES
	(0, 'N/A'),
	(1, 'CBLR'),
    (2, 'Internship'),
    (3, 'GlobalLearning'),
    (4, 'LearningCommunity'),
    (5, 'UndergradResearch'),
    (6, 'Capstone')
;
SELECT * FROM hip_type_code;

INSERT INTO hip_input
SELECT CurriculumCourseKeyId, Section, AcademicQtrKeyId, hip_type
FROM
	(SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 1 AS hip_type
	FROM hip_participation_data
	WHERE CBLR IS NOT NULL AND CBLR <> 'N/A'
	UNION ALL
	SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 2
	FROM hip_participation_data
	WHERE Internship IS NOT NULL AND Internship <> 'N/A'
	UNION ALL
	SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 3
	FROM hip_participation_data
	WHERE GlobalLearning IS NOT NULL AND GlobalLearning <> 'N/A'
	UNION ALL
	SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 4
	FROM hip_participation_data
	WHERE LearningCommunity IS NOT NULL AND LearningCommunity <> 'N/A'
	UNION ALL
	SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 5
	FROM hip_participation_data
	WHERE UndergradResearch IS NOT NULL AND UndergradResearch <> 'N/A'
	UNION ALL
	SELECT Course_Prefix, Course_Number, Section, AcademicQtrKeyId, 6
	FROM hip_participation_data
	WHERE Capstone IS NOT NULL AND Capstone <> 'N/A') AS subquery_0
INNER JOIN
	(SELECT CurriculumCourseKeyId, CurriculumCode, CourseNbr
    FROM enterprise_data_warehouse.dimCurriculumCourse) AS subquery_1
ON subquery_0.course_prefix = subquery_1.CurriculumCode AND subquery_0.course_number = subquery_1.CourseNbr
;
SELECT * FROM hip_input;

-- fill student_participation table
INSERT INTO student_participation
SELECT student_courses.StudentKeyId, student_courses.CurriculumCourseKeyId, CourseLongName, CourseSectionId, student_courses.AcademicQtrKeyId, SCHQty,
	CASE
		WHEN hip_input.hip_type IS NOT NULL THEN hip_input.hip_type
        ELSE student_courses.hip_type
	END AS hip_type
FROM
	(SELECT StudentKeyId, course_quarter.CurriculumCourseKeyId, CourseLongName, CourseSectionId,  AcademicQtrKeyId, SCHQty, NULL AS hip_type
	FROM enterprise_data_warehouse.dimCurriculumCourse
	INNER JOIN
		(SELECT StudentKeyId, CurriculumCourseKeyId, CourseSectionId,  AcademicQtrKeyId, SCHQty
		FROM enterprise_data_warehouse.factStudentCreditHour
		INNER JOIN
			(SELECT CalendarDateKeyId, AcademicQtrKeyId
			FROM enterprise_data_warehouse.dimDate) as date_table
		ON enterprise_data_warehouse.factStudentCreditHour.CalendarDateKeyId = date_table.CalendarDateKeyId) AS course_quarter
	ON enterprise_data_warehouse.dimCurriculumCourse.CurriculumCourseKeyId = course_quarter.CurriculumCourseKeyId) AS student_courses
LEFT JOIN
	hip_input
ON hip_input.CurriculumCourseKeyId = student_courses.CurriculumCourseKeyId AND hip_input.course_section = student_courses.CourseSectionId AND hip_input.AcademicQtrKeyId = student_courses.AcademicQtrKeyId
;
SELECT * FROM student_participation;

-- Creates a masked ID for every student in the UW system
INSERT INTO student_alias (system_key, student_no)
SELECT system_key, student_no
FROM uw_sdb_datastore.student_1
;
SELECT * FROM student_alias;

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

SELECT stu_profile.RandomId, student_no, stu_profile.AcademicQtrKeyId, MajorAbbrCode, MajorName, CurriculumCourseKeyId, CourseSectionId, CourseLongName, SCHQty, hip_type,  FirstGenerationMatriculated, FirstGeneration4YrDegree, AcademicCareerEntryType, Veteran, PellEligibilityStatus, StudentClassCode, GenderCode, ethnic_grp_id
FROM
	(SELECT RandomId, AcademicQtrKeyId, FirstGenerationMatriculated, FirstGeneration4YrDegree, AcademicCareerEntryType, Veteran, PellEligibilityStatus, StudentClassCode, GenderCode, ethnic_grp_id, MajorAbbrCode, MajorName
    FROM student_profile
    INNER JOIN
		enterprise_data_warehouse.dimMajor
    ON enterprise_data_warehouse.dimMajor.MajorKeyId = student_profile.MajorKeyId) AS stu_profile
INNER JOIN
	(SELECT RandomId, student_no, AcademicQtrKeyId, CurriculumCourseKeyId, CourseSectionId, CourseLongName, SCHQty, hip_type
    FROM student_participation
    INNER JOIN
		(SELECT student_alias.RandomId, StudentKeyId, student_no
        FROM student_alias
        INNER JOIN
			student_id_link
        ON student_alias.RandomId = student_id_link.RandomId) AS student_id
	ON student_id.StudentKeyId = student_participation.StudentKeyId) AS student_course
ON stu_profile.RandomId = student_course.RandomId AND stu_profile.AcademicQtrKeyId = student_course.AcademicQtrKeyId;

/*





*/