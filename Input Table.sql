CREATE DATABASE input;
USE input;

CREATE TABLE hip_course_section (
	CurriculumCourseKeyId INT PRIMARY KEY NOT NULL,
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




	