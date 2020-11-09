USE [QueensClassScheduleSpring2019];
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:		Henry Weng
-- Procedure:	[dbo].[DropForeignKeys]
-- Create date:	2020-04-25
-- Description: Drops all foreign keys from the database.
-- =========================================================
CREATE PROCEDURE [dbo].[DropForeignKeys]
@GroupMemberUserAuthorizationKey INT
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

    ALTER TABLE Education.Class DROP CONSTRAINT FK_Class_Course;
    ALTER TABLE Education.Class DROP CONSTRAINT FK_Class_Instructor;
    ALTER TABLE Education.Class DROP CONSTRAINT FK_Class_ModeOfInstruction;
    ALTER TABLE Education.Class DROP CONSTRAINT FK_Class_Room;
    ALTER TABLE [Time].ClassDay DROP CONSTRAINT FK_ClassDay_Class;
	ALTER TABLE [Time].ClassDay DROP CONSTRAINT FK_ClassDay_Day;
	ALTER TABLE Education.Course DROP CONSTRAINT FK_Course_Department;
    ALTER TABLE Faculty.InstructorDepartment DROP CONSTRAINT FK_InstructorDepartment_Department;
	ALTER TABLE Faculty.InstructorDepartment DROP CONSTRAINT FK_InstructorDepartment_Instructor;
	ALTER TABLE Campus.Room DROP CONSTRAINT FK_Room_Building;

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Completed the DropForeignKeys procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

-- =============================================
-- Author:		Henry Weng
-- Procedure:   [dbo].[ShowTableStatusRowCount]
-- Create date: 2020-04-25
-- Description:	Prints out the row count for each table.
-- =============================================
CREATE PROCEDURE [dbo].[ShowTableStatusRowCount] 
	@GroupMemberUserAuthorizationKey int,
	@TableStatus VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	select TableStatus = @TableStatus, TableName ='Education.Class', COUNT(*) FROM [Education].Class as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Education.Course', COUNT(*) FROM [Education].Course as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Education.ModeOfInstruction', COUNT(*) FROM [Education].ModeOfInstruction as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Faculty.Department', COUNT(*) FROM [Faculty].Department as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Faculty.Instructor', COUNT(*) FROM [Faculty].Instructor as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Faculty.InstructorDepartment', COUNT(*) FROM [Faculty].InstructorDepartment as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Campus.Building', COUNT(*) FROM [Campus].Building as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Campus.Room', COUNT(*) FROM [Campus].Room as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Time.ClassDay', COUNT(*) FROM [Time].ClassDay as NumberOfRows
	select TableStatus = @TableStatus, TableName ='Time.Day', COUNT(*) FROM [Time].[Day] as NumberOfRows

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Completed the ShowTableStatusRowCount procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[TruncateTable]
 --Create date: 2020-04-25
 --Description:	Truncates all tables.
 --=============================================
CREATE PROCEDURE [dbo].[TruncateTable]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	TRUNCATE TABLE [Education].Class;
	TRUNCATE TABLE [Education].Course;
	TRUNCATE TABLE [Education].ModeOfInstruction;
	TRUNCATE TABLE [Faculty].Department;
	TRUNCATE TABLE [Faculty].Instructor;
	TRUNCATE TABLE [Faculty].InstructorDepartment;
	TRUNCATE TABLE [Campus].[Building];
	TRUNCATE TABLE [Campus].[Room];
	TRUNCATE TABLE [Time].[ClassDay];
	TRUNCATE TABLE [Time].[Day];

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the TruncateTable procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO
--=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadRoom]
 --Create date: 2020-04-30
 --Description:	Loads the Campus.Room table.
--=============================================
CREATE PROCEDURE [dbo].[LoadRoom]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO [Campus].[Room]
	(Room, BuildingKey, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT dcs.Room, 
					cb.BuildingKey, 
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM [Campus].Building as cb
		INNER JOIN dbo.CoursesSpring2019 as dcs
			ON dcs.BuildingCode = cb.BuildingCode
	WHERE dcs.Location <> '';

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadRoom procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadBuilding]
 --Create date: 2020-04-28
 --Description:	Loads the Campus.Building table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadBuilding]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	--Metadata
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO [Campus].[Building] 
	(BuildingCode, BuildingName, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT LEFT(Location, 2),
					BuildingName = CASE WHEN LEFT(Location, 2) = N'AE' THEN N'Alumni Hall'
										WHEN LEFT(Location, 2) = N'CD' THEN N'Campbell Dome'
										WHEN LEFT(Location, 2) = N'CA' THEN N'Colden Auditorium'
										WHEN LEFT(Location, 2) = N'CH' THEN N'Colwin Hall'
										WHEN LEFT(Location, 2) = N'CI' THEN N'Continuing Ed I'
										WHEN LEFT(Location, 2) = N'DY' THEN N'Delaney Hall'
										WHEN LEFT(Location, 2) = N'DH' THEN N'Dining Hall'
										WHEN LEFT(Location, 2) = N'FG' THEN N'Fitzgerald Gym'
										WHEN LEFT(Location, 2) = N'FH' THEN N'Frese Hall'
										WHEN LEFT(Location, 2) = N'GB' THEN N'G Building'
										WHEN LEFT(Location, 2) = N'GC' THEN N'Gertz Center'
										WHEN LEFT(Location, 2) = N'GT' THEN N'Goldstein Theatre'
										WHEN LEFT(Location, 2) = N'HH' THEN N'Honors Hall'
										WHEN LEFT(Location, 2) = N'IB' THEN N'I Building'
										WHEN LEFT(Location, 2) = N'JH' THEN N'Jefferson Hall'
										WHEN LEFT(Location, 2) = N'KY' THEN N'Kiely Hall'
										WHEN LEFT(Location, 2) = N'KG' THEN N'King Hall'
										WHEN LEFT(Location, 2) = N'KS' THEN N'Kissena Hall'
										WHEN LEFT(Location, 2) = N'KP' THEN N'Klapper Hall'
										WHEN LEFT(Location, 2) = N'MU' THEN N'Music Building'
										WHEN LEFT(Location, 2) = N'PH' THEN N'Powdermaker Hall'
										WHEN LEFT(Location, 2) = N'QH' THEN N'Queens Hall'
										WHEN LEFT(Location, 2) = N'RA' THEN N'Rathaus Hall'
										WHEN LEFT(Location, 2) = N'RZ' THEN N'Razran Hall'
										WHEN LEFT(Location, 2) = N'RE' THEN N'Remsen Hall'
										WHEN LEFT(Location, 2) = N'RO' THEN N'Rosenthal Library'
										WHEN LEFT(Location, 2) = N'SB' THEN N'Science Building'
										WHEN LEFT(Location, 2) = N'SU' THEN N'Student Union'
										WHEN LEFT(Location, 2) = N'C2' THEN N'Tech Incubator'
										WHEN LEFT(Location, 2) = N'AR' THEN N'Tennis Courts'
									END,
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization 
						WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization
					WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization
					WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM [dbo].[CoursesSpring2019]
	WHERE Location <> ''

	-- Metadata
	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadBuilding procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

-- =============================================
-- Author:      Adilah Sultana
-- Procedure:   [dbo].[ModeOfInstruction]
-- Create date: 2020-04-30
-- Description: Loads data into the Education.ModeOfInstruction table
-- =============================================
CREATE PROCEDURE [dbo].[LoadModeOfInstruction]
   @GroupMemberUserAuthorizationKey int
AS
BEGIN
   SET NOCOUNT ON;
   CREATE TABLE #start_time (var1 datetime2(7));
   INSERT INTO #start_time VALUES (sysdatetime());
 
   INSERT INTO Education.ModeOfInstruction (Mode, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
   SELECT DISTINCT [Mode of Instruction], 
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
   FROM dbo.CoursesSpring2019
 
   DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
   DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
   EXEC [Process].[usp_TrackWorkFlow]
               @starttime = @ts,
               @workflowdescription = N'Created the LoadModeOfInstruction table',
               @workflowsteptablerowcount = @rowcount,
               @userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO
 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadInstructor]
 --Create date: 2020-05-04
 --Description:	Loads the Faculty.Instructor table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadInstructor]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO Faculty.Instructor
	(InstructorFullName, InstructorLastName, InstructorFirstName, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT Instructor, 
					LEFT(Instructor, CHARINDEX(',',Instructor)-1), 
					SUBSTRING(Instructor, CHARINDEX(',',Instructor)+2, LEN(Instructor)), 
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM dbo.CoursesSpring2019
	WHERE Instructor <> ','

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadInstructor procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Rachel Ramphal
 --Procedure:   [dbo].[LoadDepartment]
 --Create date: 2020-05-04
 --Description:	Loads the Faculty.Department table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadDepartment]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	--Metadata
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO Faculty.Department (DepartmentCode, DepartmentName, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT DepartmentCode, DepartmentName = CASE WHEN DepartmentCode = N'ACCT' THEN 'Accounting'
															WHEN DepartmentCode = N'AFST' THEN 'Africana Studies'
															WHEN DepartmentCode = N'AMST' THEN 'American Studies'
															WHEN DepartmentCode = N'ANTH' THEN 'Anthropology'
															WHEN DepartmentCode = N'ARAB' THEN 'Arabic'
															WHEN DepartmentCode = N'ARTH' THEN 'Art History'
															WHEN DepartmentCode = N'ARTS' THEN 'Studio Art'
															WHEN DepartmentCode = N'ASTR' THEN 'Astronomy'
															WHEN DepartmentCode = N'BALA' THEN 'Business & Liberal Arts'
															WHEN DepartmentCode = N'BIOCH' THEN 'Biochemistry'
															WHEN DepartmentCode = N'BIOL' THEN 'Biology'
															WHEN DepartmentCode = N'BUS' THEN 'Business'
															WHEN DepartmentCode = N'CERT' THEN 'Certified Full Time'
															WHEN DepartmentCode = N'CESL' THEN 'Col Eng as Second Lang'
															WHEN DepartmentCode = N'CHEM' THEN 'Chemistry'
															WHEN DepartmentCode = N'CHIN' THEN 'Chinese'
															WHEN DepartmentCode = N'CLAS' THEN 'Classics'
															WHEN DepartmentCode = N'CMAL' THEN 'Clas, Mid East & Asian'
															WHEN DepartmentCode = N'CMLIT' THEN 'Comparative Literature'
															WHEN DepartmentCode = N'CO-OP' THEN 'Cooperative Education'
															WHEN DepartmentCode = N'CSCI' THEN 'Computer Science'
															WHEN DepartmentCode = N'CUNBA' THEN 'CUNY BA'
															WHEN DepartmentCode = N'DANCE' THEN 'Dance'
															WHEN DepartmentCode = N'DRAM' THEN 'Drama and Theatre'
															WHEN DepartmentCode = N'EAST' THEN 'East Asian Studies'
															WHEN DepartmentCode = N'ECON' THEN 'Economics'
															WHEN DepartmentCode = N'ECP' THEN 'Edual & Community Progs'
															WHEN DepartmentCode = N'ECPCE' THEN 'Counselor Education'
															WHEN DepartmentCode = N'ECPEL' THEN 'Educ Comm Prog-Leader'
															WHEN DepartmentCode = N'ECPSE' THEN 'Special Education'
															WHEN DepartmentCode = N'ECPSP' THEN 'School Psychology'
															WHEN DepartmentCode = N'EECE' THEN 'Elem & Early Childhood'
															WHEN DepartmentCode = N'ENGL' THEN 'English'
															WHEN DepartmentCode = N'ENSCI' THEN 'Environmental Science'
															WHEN DepartmentCode = N'EURO' THEN 'European Studies'
															WHEN DepartmentCode = N'FNES' THEN 'Family, Nut & Exercise'
															WHEN DepartmentCode = N'FREN' THEN 'French'
															WHEN DepartmentCode = N'GEOL' THEN 'Geology'
															WHEN DepartmentCode = N'GERM' THEN 'German'
															WHEN DepartmentCode = N'GREEK' THEN 'Greek'
															WHEN DepartmentCode = N'GRKMD' THEN 'Modern Greek'
															WHEN DepartmentCode = N'GRKST' THEN 'Byzan & Mdrn Greek St'
															WHEN DepartmentCode = N'HEBRW' THEN 'Hebrew'
															WHEN DepartmentCode = N'HIST' THEN 'History'
															WHEN DepartmentCode = N'HMNS' THEN 'Honors in Math & Sci'
															WHEN DepartmentCode = N'HNRS' THEN 'Honors'
															WHEN DepartmentCode = N'HSS' THEN 'Honors in Social Science'
															WHEN DepartmentCode = N'HTH' THEN 'Honors in the Humanities'
															WHEN DepartmentCode = N'IRST' THEN 'Irish Studies'
															WHEN DepartmentCode = N'ITAL' THEN 'Italian American Std'
															WHEN DepartmentCode = N'JAZZ' THEN 'Jazz'
															WHEN DepartmentCode = N'JEWST' THEN 'Jewish Studies'
															WHEN DepartmentCode = N'JOURN' THEN 'Journalism'
															WHEN DepartmentCode = N'JPNS' THEN 'Japanese'
															WHEN DepartmentCode = N'KOR' THEN 'Korean'
															WHEN DepartmentCode = N'LABST' THEN 'Labor Studies'
															WHEN DepartmentCode = N'LATIN' THEN 'Latin'
															WHEN DepartmentCode = N'LBLST' THEN 'Liberal Studies'
															WHEN DepartmentCode = N'LBSCI' THEN 'Library Science'
															WHEN DepartmentCode = N'LCD' THEN 'Ling & Commun Disorders'
															WHEN DepartmentCode = N'LIBR' THEN 'Library'
															WHEN DepartmentCode = N'MAM' THEN 'Maintain Matriculation'
															WHEN DepartmentCode = N'MATH' THEN 'Mathematics'
															WHEN DepartmentCode = N'MEDST' THEN 'Media Studies'
															WHEN DepartmentCode = N'MES' THEN 'Middle Eastern Studies'
															WHEN DepartmentCode = N'MUSIC' THEN 'Music'
															WHEN DepartmentCode = N'PERM' THEN 'Permit Course'
															WHEN DepartmentCode = N'PHIL' THEN 'Philosophy'
															WHEN DepartmentCode = N'PHYS' THEN 'Physics'
															WHEN DepartmentCode = N'PORT' THEN 'Portuguese'
															WHEN DepartmentCode = N'PSCI' THEN 'Political Science'
															WHEN DepartmentCode = N'PSYCH' THEN 'Psychology'
															WHEN DepartmentCode = N'RLGST' THEN 'Religious Studies'
															WHEN DepartmentCode = N'RM' THEN 'Risk Management'
															WHEN DepartmentCode = N'RUSS' THEN 'Russian'
															WHEN DepartmentCode = N'SEEK' THEN 'SEEK Academic Program'
															WHEN DepartmentCode = N'SEYS' THEN 'Secondary Edu & Youth'
															WHEN DepartmentCode = N'SEYSL' THEN 'Sec Educ: Literacy Edu'
															WHEN DepartmentCode = N'SOC' THEN 'Sociology'
															WHEN DepartmentCode = N'SPAN' THEN 'Spanish'
															WHEN DepartmentCode = N'SPST' THEN 'Interdis & Special St'
															WHEN DepartmentCode = N'STABD' THEN 'Study Abroad'
															WHEN DepartmentCode = N'STPER' THEN 'Student Personnel'
															WHEN DepartmentCode = N'URBST' THEN 'Urban Studies'
															WHEN DepartmentCode = N'WGS' THEN 'Women and Gender Studies'
														END,
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM dbo.CoursesSpring2019;

	-- Metadata
	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadDepartment procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadInstructorDepartment]
 --Create date: 2020-05-04
 --Description:	Loads the Faculty.InstructorDepartment table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadInstructorDepartment]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO Faculty.InstructorDepartment (DepartmentKey, InstructorKey, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT fd.DepartmentKey, 
					fi.InstructorKey, 
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM dbo.CoursesSpring2019 as dcs
		INNER JOIN Faculty.Instructor as fi
			ON dcs.Instructor = fi.InstructorFullName
		INNER JOIN Faculty.Department as fd
			ON dcs.DepartmentCode = fd.DepartmentCode;

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadInstructorDepartment procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadCourse]
 --Create date: 2020-05-04
 --Description:	Loads the Education.Course table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadCourse]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO Education.Course 
	(CourseDescription, DepartmentKey, CourseCode, CourseHours, CourseCredits, UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT dcs.Description, 
					fd.DepartmentKey, 
					dcs.CourseCode,
					CAST(SUBSTRING(dcs.[Course (hr, crd)], CHARINDEX('(',dcs.[Course (hr, crd)]) + 1, 
						CHARINDEX(',', dcs.[Course (hr, crd)]) - CHARINDEX('(', dcs.[Course (hr, crd)]) - 1) AS float) AS CourseHours,
					CAST(SUBSTRING(dcs.[Course (hr, crd)], CHARINDEX(',',dcs.[Course (hr, crd)]) + 1, 
						CHARINDEX(')', dcs.[Course (hr, crd)]) - CHARINDEX(',', dcs.[Course (hr, crd)]) - 1) AS float) AS CourseCredits,
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM dbo.CoursesSpring2019 as dcs
		INNER JOIN Faculty.Department as fd
			ON dcs.DepartmentCode = fd.DepartmentCode

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadCourse procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadClass]
 --Create date: 2020-05-04
 --Description:	Loads the Education.Class table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadClass]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO [Education].Class
	(InstructorKey, RoomKey, ModeOfInstructionKey, CourseKey,
		ClassSection, ClassCode, StartTime, EndTime, Enrolled, Limit, ClassSemester,
		UserAuthorizationKey, LastName, FirstName, QmailEmailAddress)
	SELECT DISTINCT fi.InstructorKey, cr.RoomKey, em.ModeOfInstructionKey, ec.CourseKey, 
					dcs.Sec, dcs.Code, dcs.StartTime, dcs.EndTime, dcs.Enrolled, dcs.Limit, dcs.Semester,
					@GroupMemberUserAuthorizationKey, 
					(SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
					(SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)
	FROM dbo.CoursesSpring2019 as dcs
		LEFT OUTER JOIN Faculty.Instructor as fi
			ON dcs.Instructor = fi.InstructorFullName
		LEFT OUTER JOIN Campus.Building as cb
			ON dcs.BuildingCode = cb.BuildingCode
		LEFT OUTER JOIN Campus.Room as cr
			ON dcs.Room = cr.Room AND cr.BuildingKey = cb.BuildingKey
		INNER JOIN Education.ModeOfInstruction AS em
			ON dcs.[Mode of Instruction] = em.Mode
		LEFT OUTER JOIN Faculty.Department as fd
			ON dcs.DepartmentCode = fd.DepartmentCode
		LEFT OUTER JOIN Education.Course AS ec
			ON dcs.CourseCode = ec.CourseCode AND fd.DepartmentKey = ec.DepartmentKey

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadClass procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Ibrahim Suhail
 --Procedure:   [dbo].[LoadDay]
 --Create date: 2020-05-01
 --Description:	Loads the Time.Day table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadDay]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO [Time].[Day] (Day)
	VALUES (N'Sunday'), (N'Monday'), (N'Tuesday'), (N'Wednesday'), (N'Thursday'), (N'Friday'), (N'Saturday'); 

	UPDATE [Time].[Day]
	SET UserAuthorizationKey = @GroupMemberUserAuthorizationKey, 
		LastName = (SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
		Firstname = (SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
		QmailEmailAddress = (SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadDay procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

 --=============================================
 --Author:		Henry Weng
 --Procedure:   [dbo].[LoadClassDay]
 --Create date: 2020-05-05
 --Description:	Loads the Time.ClassDay table.
 --=============================================
CREATE PROCEDURE [dbo].[LoadClassDay]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	INSERT INTO Time.ClassDay
	(ClassKey, DayKey)
	SELECT DISTINCT ec.ClassKey, DayKey = CASE WHEN dcs.Day1 = 'SU' THEN 1
												WHEN dcs.Day1 = 'M' THEN 2
												WHEN dcs.Day1 = 'T' THEN 3
												WHEN dcs.Day1 = 'W' THEN 4
												WHEN dcs.Day1 = 'TH' THEN 5
												WHEN dcs.Day1 = 'F' THEN 6
												WHEN dcs.Day1 = 'S' THEN 7
											END
	FROM dbo.CoursesSpring2019 as dcs
		INNER JOIN Education.Class as ec
			ON dcs.Code = ec.ClassCode
	WHERE dcs.Day1 IS NOT NULL;

	INSERT INTO Time.ClassDay
	(ClassKey, DayKey)
	SELECT DISTINCT ec.ClassKey, DayKey = CASE WHEN dcs.Day2 = 'SU' THEN 1
												WHEN dcs.Day2 = 'M' THEN 2
												WHEN dcs.Day2 = 'T' THEN 3
												WHEN dcs.Day2 = 'W' THEN 4
												WHEN dcs.Day2 = 'TH' THEN 5
												WHEN dcs.Day2 = 'F' THEN 6
												WHEN dcs.Day2 = 'S' THEN 7
											END
	FROM dbo.CoursesSpring2019 as dcs
		INNER JOIN Education.Class as ec
			ON dcs.Code = ec.ClassCode
	WHERE dcs.Day2 IS NOT NULL;

	INSERT INTO Time.ClassDay
	(ClassKey, DayKey)
	SELECT DISTINCT ec.ClassKey, DayKey = CASE WHEN dcs.Day3 = 'SU' THEN 1
												WHEN dcs.Day3 = 'M' THEN 2
												WHEN dcs.Day3 = 'T' THEN 3
												WHEN dcs.Day3 = 'W' THEN 4
												WHEN dcs.Day3 = 'TH' THEN 5
												WHEN dcs.Day3 = 'F' THEN 6
												WHEN dcs.Day3 = 'S' THEN 7
											END
	FROM dbo.CoursesSpring2019 as dcs
		INNER JOIN Education.Class as ec
			ON dcs.Code = ec.ClassCode
	WHERE dcs.Day3 IS NOT NULL;

	UPDATE [Time].[ClassDay]
	SET UserAuthorizationKey = @GroupMemberUserAuthorizationKey, 
		LastName = (SELECT LastName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
		Firstname = (SELECT FirstName FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey),
		QmailEmailAddress = (SELECT QmailEmailAddress FROM DbSecurity.UserAuthorization WHERE UserAuthorizationKey = @GroupMemberUserAuthorizationKey)

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadClassDay procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

-- ===================================================
-- Author: Henry Weng
-- Procedure: [dbo].[AddForeignKeys]
-- Create date: 2020-05-06
-- Description: Adds foreign keys to the database.
-- ===================================================
CREATE PROCEDURE [dbo].[AddForeignKeys]
@GroupMemberUserAuthorizationKey INT
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

    ALTER TABLE Education.Class
    ADD CONSTRAINT FK_Class_Course FOREIGN KEY (CourseKey) REFERENCES Education.Course(CourseKey);

    ALTER TABLE Education.Class
    ADD CONSTRAINT FK_Class_Instructor FOREIGN KEY (InstructorKey) REFERENCES Faculty.Instructor(InstructorKey);

    ALTER TABLE Education.Class
    ADD CONSTRAINT FK_Class_ModeOfInstruction FOREIGN KEY (ModeOfInstructionKey) REFERENCES Education.ModeOfInstruction(ModeOfInstructionKey);

    ALTER TABLE Education.Class
    ADD CONSTRAINT FK_Class_Room FOREIGN KEY (RoomKey) REFERENCES Campus.Room(RoomKey);

    ALTER TABLE [Time].[ClassDay]
    ADD CONSTRAINT FK_ClassDay_Class FOREIGN KEY (ClassKey) REFERENCES Education.Class(ClassKey);

    ALTER TABLE [Time].[ClassDay]
    ADD CONSTRAINT FK_ClassDay_Day FOREIGN KEY (DayKey) REFERENCES [Time].[Day](DayKey);

	ALTER TABLE Education.Course
    ADD CONSTRAINT FK_Course_Department FOREIGN KEY (DepartmentKey) REFERENCES Faculty.Department(DepartmentKey);

    ALTER TABLE Faculty.InstructorDepartment
    ADD CONSTRAINT FK_InstructorDepartment_Department FOREIGN KEY (DepartmentKey) REFERENCES Faculty.Department(DepartmentKey);

	ALTER TABLE Faculty.InstructorDepartment
    ADD CONSTRAINT FK_InstructorDepartment_Instructor FOREIGN KEY (InstructorKey) REFERENCES Faculty.Instructor (InstructorKey);

	ALTER TABLE [Campus].Room
	ADD CONSTRAINT FK_Room_Building FOREIGN KEY (BuildingKey) REFERENCES Campus.Building(BuildingKey);

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Completed the AddForeignKeys procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

--=============================================
--Author:		Henry Weng
--Procedure:   [dbo].[LoadSchedule]
--Create date: 2020-05-06
--Description:	Loads the class schedule database.
--=============================================
CREATE PROCEDURE [dbo].[LoadSchedule]
	@GroupMemberUserAuthorizationKey int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #start_time (var1 datetime2(7));
	INSERT INTO #start_time VALUES (sysdatetime());

	EXEC [dbo].[DropForeignKeys] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[ShowTableStatusRowCount] @GroupMemberUserAuthorizationKey = 85, @TableStatus = N'''Pre-truncate of tables''';
	EXEC [dbo].[TruncateTable] @GroupMemberUserAuthorizationKey = 85;

	EXEC [dbo].[LoadBuilding] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[LoadRoom] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[LoadModeOfInstruction] @GroupMemberUserAuthorizationKey = 35;
	EXEC [dbo].[LoadInstructor] @GroupMemberUserAuthorizationKey = 40;
	EXEC [dbo].[LoadDepartment] @GroupMemberUserAuthorizationKey = 58;
	EXEC [dbo].[LoadInstructorDepartment] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[LoadCourse] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[LoadClass] @GroupMemberUserAuthorizationKey = 85;
	EXEC [dbo].[LoadDay] @GroupMemberUserAuthorizationkey = 62;
	EXEC [dbo].[LoadClassDay] @GroupMemberUserAuthorizationkey = 85;

	EXEC [dbo].[ShowTableStatusRowCount] @GroupMemberUserAuthorizationKey = 85, @TableStatus = N'''Row count after loading tables''';
	EXEC [dbo].[AddForeignKeys] @GroupMemberUserAuthorizationKey = 85;

	DECLARE @ts as datetime2(7) = (SELECT TOP 1 var1 FROM #start_time);
	DECLARE @rowcount as int = (SELECT COUNT(*) FROM [Process].[WorkflowSteps]);
	EXEC [Process].[usp_TrackWorkFlow] 
				@starttime = @ts,
				@workflowdescription = N'Created the LoadSchedule procedure.',
				@workflowsteptablerowcount = @rowcount,
				@userauthorization = @GroupMemberUserAuthorizationKey;
END;
GO

