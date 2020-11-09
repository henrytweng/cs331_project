-- Proposition 1
-- Show all instructors who are teaching in classes in multiple departments.
SELECT fi.InstructorFullName, COUNT(DISTINCT fid.DepartmentKey) as NumDepartments
FROM Faculty.Instructor as fi
	INNER JOIN Faculty.InstructorDepartment as fid
		ON fi.InstructorKey = fid.InstructorKey
GROUP BY fi.InstructorFullName
HAVING COUNT(DISTINCT fid.DepartmentKey) > 1;

-- Proposition 2
-- How many instructors are in each department?
SELECT fd.DepartmentName, COUNT(DISTINCT InstructorKey) as NumInstructors
FROM Faculty.Department as fd
	INNER JOIN Faculty.InstructorDepartment as fid
		ON fd.DepartmentKey = fid.DepartmentKey
GROUP BY fd.DepartmentName
ORDER BY fd.DepartmentName;

-- Proposition 3
-- How many classes are being taught that semester, grouped by course and aggregating the total enrollment, 
-- total class limit, and percentage enrollment?
SELECT t3.DepartmentName, t2.CourseCode, 
		COUNT(t1.ClassKey) as NumClasses, 
		SUM(t1.Enrolled) as TotalEnrollment, 
		SUM(t1.Limit) as TotalLimit, 
		CAST(100. * SUM(t1.Enrolled)/SUM(t1.Limit) AS NUMERIC(6,2)) AS PercentageEnrollment
FROM Education.Class as t1
	INNER JOIN Education.Course as t2
		ON t1.CourseKey = t2.CourseKey
	INNER JOIN Faculty.Department as t3
		ON t2.DepartmentKey = t3.DepartmentKey
GROUP BY t3.DepartmentName, t2.CourseCode
HAVING SUM(t1.Limit) <> 0
ORDER BY t3.DepartmentName;

-- Proposition 4
-- What percent of students and of classes are being taught through each mode of instruction?
SELECT t2.Mode, 
	CAST(100. * SUM(t1.Enrolled) / (SELECT SUM(Enrolled) FROM Education.Class) AS NUMERIC(5,2)) as PercentStudents,
	CAST(100. * COUNT(t1.ClassKey) / (SELECT COUNT(ClassKey) FROM Education.Class) AS NUMERIC (5,2)) as PercentClasses
FROM Education.Class AS t1
	INNER JOIN Education.ModeOfInstruction AS t2
		ON t1.ModeOfInstructionKey = t2.ModeOfInstructionKey
GROUP BY t2.Mode;

-- Proposition 5
-- What is the average length of classes in Kiely Hall?
SELECT SUM(DATEDIFF(minute, ec.StartTime, ec.EndTime)) / COUNT(ec.ClassKey) as AverageLengthInMinutes
FROM Education.Class as ec
	INNER JOIN Campus.Room as cr
		ON ec.RoomKey = cr.Roomkey
	INNER JOIN Campus.Building as cb
		ON cr.BuildingKey = cb.BuildingKey
WHERE cb.BuildingName = 'Kiely Hall'

-- Proposition 6
-- Which Computer Science courses are held on Mondays?
SELECT DISTINCT t3.DepartmentCode, t2.CourseCode, t2.CourseDescription
FROM Education.Class as t1
	INNER JOIN Education.Course as t2
		ON t1.CourseKey = t2.CourseKey
	INNER JOIN Faculty.Department as t3
		ON t2.DepartmentKey = t3.DepartmentKey
	INNER JOIN Time.ClassDay as t4
		ON t1.ClassKey = t4.ClassKey
	INNER JOIN Time.Day as t5
		ON t4.DayKey = t5.DayKey
WHERE t3.DepartmentCode = 'CSCI' AND t5.Day = 'Monday'