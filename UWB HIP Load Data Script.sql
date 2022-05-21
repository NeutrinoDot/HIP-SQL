USE uwb_hip;


-- student_demographic
#INSERT INTO student_profile
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
SELECT * FROM student_profile;