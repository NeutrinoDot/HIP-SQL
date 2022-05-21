# Creates a mock version of the EDW to test new queries.
CREATE DATABASE enterprise_data_warehouse;
USE enterprise_data_warehouse;
SET SESSION sql_mode = "";

-- Create dimCurriculumCourse table
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
# Insert values into dimCurriculumCourse table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DimCurriculumCourse_20173_20212.csv'
IGNORE
INTO TABLE dimCurriculumCourse
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * from dimCurriculumCourse;


-- Create factStudentCreditHour table
CREATE TABLE factStudentCreditHour (
	StudentKeyId INT,
    CalendarDateKeyID INT,
    CurriculumCourseKeyId INT,
    CourseSectionId VARCHAR(3),
    SCHQty DECIMAL(3, 1)
);
-- Insert values into factStudentCreditHour table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FactStudentCreditHour_20173_20212.csv'
IGNORE
INTO TABLE factStudentCreditHour
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * from factStudentCreditHour;


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
-- Insert values into dimDate table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DimDate_20173_20212.csv'
IGNORE
INTO TABLE dimDate
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * from dimDate;


-- Create UWProfilesStudent table
CREATE TABLE UWProfilesStudent (
	SDBSrcSystemKey INT NOT NULL,
    CalendarDate DATETIME NOT NULL,
    AcademicOriginType VARCHAR(100),
    Class SMALLINT,
    Veteran SMALLINT,
    FirstGen4YearInd CHAR(1),
	FirstGenInd CHAR(1),
    PellEligibilityStatus VARCHAR(100)
);
-- Insert values into UWProfilesStudent table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/UWProfilesStudent_20173_20212.csv'
IGNORE
INTO TABLE UWProfilesStudent
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * from UWProfilesStudent;


-- Create dimStudent table
CREATE TABLE dimStudent (
	StudentKeyId INT,
    SDBSrcSystemKey INT,
    GenderCode VARCHAR(10),
    AssignedEthnicDesc VARCHAR(100),
    EthnicGrpAfricanAmerInd CHAR(1),
    EthnicGrpAmerIndianInd CHAR(1),
    EthnicGrpAsianInd CHAR(1),
    EthnicGrpCaucasianInd CHAR(1),
    EthnicGrpHawaiiPacIslanderInd CHAR(1),
    EthnicGrpMultipleInd CHAR(1),
    EthnicGrpNotIndicatedInd CHAR(1),
    HispanicInd CHAR(1),
    StudentClassCode INT,
    StudentClassDesc VARCHAR(100),
	RecordEffBeginDttm DATETIME,
    RecordEffEndDttm DATETIME
);
-- Insert values into dimStudent table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DimStudent_20173_20212.csv'
IGNORE
INTO TABLE dimStudent
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * FROM dimstudent;


-- Create factStudentProgramEnrollment table
CREATE TABLE factStudentProgramEnrollment (
	StudentKeyId INT,
    CalendarDateKeyId INT,
    MajorKeyId INT,
    StudentEnrolledCnt INT,
    StudentRegisteredCnt INT  
);
-- Insert values into factStudentProgramEnrollment table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FactStudentProgramEnrollment_20173_20212.csv'
IGNORE
INTO TABLE factStudentProgramEnrollment
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * FROM factStudentProgramEnrollment;


-- Create dimMajor table
CREATE TABLE dimMajor (
	MajorKeyId INT,
    CampusCode VARCHAR(10),
    MajorAbbrCode VARCHAR(10),
    MajorPathwayNum INT,
    MajorFullName VARCHAR(100),
    MajorShortName VARCHAR(100),
    RecordEffBeginDttm DATETIME,
    RecordEffEndDttm DATETIME
);
-- Insert values into dimMajor table from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DimMajor_20173_20212.csv'
IGNORE
INTO TABLE dimMajor
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
#SELECT * from dimMajor;
