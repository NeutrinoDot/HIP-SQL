USE uwb_hip;

CREATE TABLE student_alias (

);


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