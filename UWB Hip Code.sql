CREATE DATABASE uwb_hip;
USE uwb_hip;

CREATE TABLE student_alias_interface (
	student_alias_id INT NOT NULL auto_increment,
	student_no INT,    
	PRIMARY KEY (student_alias_id)
);

CREATE TABLE student_demographic (
	student_alias_id INT NOT NULL,
	GenderCode VARCHAR(10),
	IPEDSRaceEthnicityCategory VARCHAR(50),
	FirstGenerationMatriculated CHAR(1),
	FirstGeneration4YrDegree CHAR(1),
	AcademicCareerEntryType CHAR(1),
    
	FOREIGN KEY (student_alias_id) REFERENCES student_alias_interface (student_alias_id)
);

CREATE TABLE student_quarter_status (
	student_alias_id INT NOT NULL,
	AcademicQtrKeyId VARCHAR(50) NOT NULL,
	SCHQty DECIMAL(3, 1),
	BothellStudentInd CHAR(1),
	PreMajorInd CHAR(1),
	MajorName VARCHAR(100),
	MajorCode VARCHAR(25),
	Department CHAR(1),
	SchoolAbbr  CHAR(6),
	StudentClass TINYINT,
	AcademicQtrCensusDayPellEligibleStudentInd CHAR(1),

	FOREIGN KEY (student_alias_id) REFERENCES student_alias_interface (student_alias_id)
);

CREATE TABLE course (
	course_id INT NOT NULL AUTO_INCREMENT,
	CourseLongName VARCHAR(120) NOT NULL,

	PRIMARY KEY (course_id)
);

CREATE TABLE course_section (
	course_id INT NOT NULL,
	CourseSectionCode VARCHAR(3) NOT NULL,
	AcademicQtrKeyId VARCHAR(50) NOT NULL,

	FOREIGN KEY (course_id) REFERENCES course (course_id),
	PRIMARY KEY (CourseSectionCode)
);

CREATE TABLE hip (
	hip_id INT NOT NULL AUTO_INCREMENT,
	TypeofParticipation VARCHAR(25) NOT NULL,    

	PRIMARY KEY (hip_id)
);

CREATE TABLE hip_per_course_interface (
	course_id INT NOT NULL,
	hip_id INT NOT NULL,

	FOREIGN KEY (course_id) REFERENCES course (course_id),
	FOREIGN KEY (hip_id) REFERENCES hip (hip_id)
);

CREATE TABLE student_course_interface (
	student_alias_id INT NOT NULL,
	CourseSectionCode VARCHAR(3) NOT NULL,
	hip_id INT NOT NULL,

	FOREIGN KEY (student_alias_id) REFERENCES student_alias_interface (student_alias_id),
	FOREIGN KEY (CourseSectionCode) REFERENCES course_section (CourseSectionCode),
	FOREIGN KEY (hip_id) REFERENCES hip (hip_id)
);

CREATE TABLE hips_per_course_section_interface (
	CourseSectionCode VARCHAR(3) NOT NULL,
	hip_id INT NOT NULL,
    
	FOREIGN KEY (CourseSectionCode) REFERENCES course_section (CourseSectionCode),
	FOREIGN KEY (hip_id) REFERENCES hip (hip_id)
);