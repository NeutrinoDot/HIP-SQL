# Creates a mock version of the EDW to test new queries.

CREATE DATABASE enterprise_data_warehouse;
USE enterprise_data_warehouse;

-- Create dimStudent table
CREATE TABLE dimStudent (
	StudentKeyId INT PRIMARY KEY,
    SDBSrcSystemKey INT,
    StudentClassCode INT,
    StudentClassDesc VARCHAR(100),
	GenderCode VARCHAR(10),
    AssignedEthnicDesc VARCHAR(100),
    HispanicInd CHAR(1),
    EthnicGrpAfricanAmerInd CHAR(1),
    EthnicGrpAmerIndianInd CHAR(1),
    EthnicGrpAsianInd CHAR(1),
    EthnicGrpCaucasianInd CHAR(1),
    EthnicGrpHawaiiPacIslanderInd CHAR(1),
    EthnicGrpNotIndicatedInd CHAR(1)
);

-- Insert values into dimStudent table
INSERT dimStudent VALUES 
	(10001, 1657429, 4, 'Senior', 'M', 'Asian', 'N', 'N', 'N', 'Y', 'N', 'N', 'N'), 
    (20001, 1895477, 1, 'Freshman', 'F', 'Not Indicated', 'N', 'N', 'N', 'N', 'N', 'N', 'Y'),
    (30001, 1961658, 4, 'Senior', 'M', 'Caucasian', 'N', 'N', 'N', 'N', 'Y', 'N', 'N'),
    (40001, 1949480, 3, 'Junior', 'M', 'International', 'N', 'N', 'N', 'N', 'N', 'N', 'Y'),
    (10002, 1657429, 3, 'Junior', 'M', 'Asian', 'N', 'N', 'N', 'Y', 'N', 'N', 'N')
;
SELECT * FROM dimstudent;

-- Create dimMajor table
CREATE TABLE dimMajor (
	MajorKeyId INT PRIMARY KEY,
    MajorAbbrCode VARCHAR(10),
    MajorName VARCHAR(100)
);

-- Insert values into dimMajor table
INSERT dimMajor VALUES 
	(5001, '1_CSSE_00', 'COMP SCI & SOFTWARE ENGR'), 
    (1001, '1_B PRE_00', 'PREMAJOR (BOTHELL)'),
    (2001, '1_B BUS_00', 'BUSINESS ADMIN (BOTHELL)'),
    (2007, '1_B BUS_10', 'BUS ADMIN:ACCT (BOTHELL)')
;
SELECT * from dimMajor;

-- Create dimDate table
CREATE TABLE dimDate (
	CalendarDateKeyId INT PRIMARY KEY,
    CalendarDate DATETIME,
    AcademicQtr TINYINT,
	AcademicQtrKeyId INT,
    AcademicYrName VARCHAR(50),
    AcademicQtrBeginInd CHAR,
	AcademicQtrCensusDayInd CHAR,
	AcademicQtrLastInstructionDayInd CHAR
);

-- Insert values into dimDate table
INSERT dimDate VALUES 
	(20181010, '2018-10-10', 20182, 1, 20182, 2018),
    (20180110, '2018-01-10', 20183, 2, 20183, 2018),
    (20190410, '2019-04-10', 20194, 3, 20194, 2019),
	(20191010, '2019-10-10', 20192, 1, 20192, 2019),
    (20180710, '2018-07-10', 20181, 1, 20181, 2018),
    (20190710, '2019-07-10', 20191, 1, 20191, 2019),
    (20200710, '2020-07-10', 20201, 1, 20201, 2020)
;
SELECT * from dimDate;

-- Create dimCurriculumCourse table
CREATE TABLE dimCurriculumCourse (
	CurriculumCourseKeyId INT,
    CurriculumCode VARCHAR(6),
    CourseNbr SMALLINT,
    CurriculumFullName VARCHAR(200),
    CourseLongName VARCHAR(120)
);

-- Insert values into dimCurriculumCourse table
INSERT dimCurriculumCourse VALUES
	(497, 'CSS', 497, 'CSS 497: CSSE Capstone', 'Computer Science and Software Engineering Capstone'),
    (135, 'B WRIT', 135, 'B WRIT 135:', 'Research Writing'),
    (406, 'BIS', 406, 'BIS 406: Urban Planning and Geography', 'Urban Planning and Geography'),
    (300, 'FSTDY', 300, 'UW Study Abroad', 'FOREIGN STUDY'),
    (312, 'BBUS', 312, 'BIS 312: Approaches to Social Research', 'Approaches to Social Research'),
    (126, 'xBUS', 126, 'xBUS 126: Mock Class', 'Mock Class')
;
SELECT * from dimCurriculumCourse;

-- Create factStudentCreditHour table
CREATE TABLE factStudentCreditHour (
	StudentKeyId INT,
    CalendarDateKeyID INT,
    CurriculumCourseKeyId INT,
    CourseSectionId VARCHAR(3),
    SCHQty DECIMAL(3, 1)
);

-- Insert values into factStudentCreditHour table
INSERT factStudentCreditHour VALUES
	(10001, 20181010, 497, 'B', 3),
    (20001, 20180110, 135, 'A', 4),
    (30001, 20190410, 406, 'A', 5),
    (40001, 20191010, 300, 'A', 3),
    (50001, 20191010, 300, 'B', 3)
;
SELECT * from factStudentCreditHour;

-- Create factStudentProgramEnrollment table
CREATE TABLE factStudentProgramEnrollment (
	CalendarDateKeyId INT,
    StudentKeyId INT,
    MajorKeyId INT
);

-- Insert values into factStudentProgramEnrollment table
INSERT factStudentProgramEnrollment VALUES 
	(20181010, 10001, 5001), 
    (20180110, 20001, 1001),
    (20190410, 30001, 2001),
    (20191010, 40001, 2007)
;
SELECT * FROM factStudentProgramEnrollment;

-- Create UWProfilesStudent table
CREATE TABLE UWProfilesStudent (
	SDBSrcSystemKey INT NOT NULL,
    CalendarDate DATETIME NOT NULL,
    Class SMALLINT,
	FirstGenInd CHAR(1),
    FirstGen4YearInd CHAR(1),
    Veteran SMALLINT,
    PellEligibilityStatus VARCHAR(100),
    AcademicOriginType VARCHAR(100)
);

-- Insert values into UWProfilesStudent table
INSERT UWProfilesStudent VALUES 
	(1657429, '2018-10-10', 4, 'N', 'N', 0, 'Y', 'FTFY'), 
    (1895477, '2018-01-10', 1, 'Y', 'Y', 0, 'Y', 'FTFY'),
    (1961658, '2019-04-10', 4, 'N', 'Y', 1, 'N', 'Trans2YrWACC'),
    (1949480, '2019-10-10', 3, 'N', 'N', 0, 'N', 'Trans2YrWACC')
;
SELECT * from UWProfilesStudent;
