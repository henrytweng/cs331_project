USE [QueensClassScheduleSpring2019]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE SCHEMA [DbSecurity];
GO
CREATE TABLE [DbSecurity].[UserAuthorization] 
(
    [UserAuthorizationKey] [int] NOT NULL DEFAULT -1,
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) DEFAULT N'Your QMail Email Address',
	[GroupName] [nvarchar](20) DEFAULT N'G12-5',
	[DateAdded] [datetime2](7) DEFAULT SYSDATETIME(),
  CONSTRAINT [PK_UserAuthorizationKey] PRIMARY KEY CLUSTERED ([UserAuthorizationKey] ASC)
);
GO

INSERT INTO [DbSecurity].[UserAuthorization](userauthorizationkey, firstname, lastname, QmailEmailAddress)
VALUES 
	(58, N'Rachel', N'Ramphal', N'Rachel.Ramphal58@qmail.cuny.edu'),
	(09, N'Barinderjit', N'Sidhu', N'Barinderjit.Sidhu09@qmail.cuny.edu'),
	(62, N'Ibrahim', N'Suhail', N'ibrahim.suhail62@qmail.cuny.edu'),
	(35, N'Adilah', N'Sultana', N'Adilah.Sultana35@qmail.cuny.edu'),
	(40, N'Khadijatut', N'Taiyeba', N'Khadijatut.Taiyeba40@qmail.cuny.edu'),
	(85, N'Henry', N'Weng', N'Henry.Weng85@qmail.cuny.edu');
GO

CREATE SCHEMA [Process];
GO
CREATE TABLE [Process].[WorkflowSteps]
(
    [WorkFlowStepKey] [int] IDENTITY(1,1) NOT NULL,
	[WorkFlowStepDescription] [nvarchar](100) NOT NULL,
	[WorkFlowStepTableRowCount] [int] NULL 
		CONSTRAINT [DF_WorkflowSteps_WorkFlowStepTableRowCount] DEFAULT 0,
	[LastName] [nvarchar](30) NULL
		CONSTRAINT DF_WorkflowSteps_LastName DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL
		CONSTRAINT DF_WorkflowSteps_FirstName DEFAULT N'Your first name',
	[StartingDateTime] [datetime2](7) NULL
		CONSTRAINT [DF_WorkflowSteps_StartingDateTime] DEFAULT SYSDATETIME(),
	[EndingDateTime] [datetime2](7) NULL
		CONSTRAINT [DF_WorkflowSteps_EndingDateTime] DEFAULT SYSDATETIME(),
	[ClassTime] [char](5) NULL
		CONSTRAINT [DF_WorkflowSteps_ClassTime] DEFAULT N'12:15',
	[QmailEmailAddress][nvarchar](40) NULL
		CONSTRAINT DF_WorkflowSteps_QmailEmailAddress DEFAULT N'Your QMail Email Address',
  CONSTRAINT [PK_WorkflowSteps_WorkFlowStepKey] PRIMARY KEY CLUSTERED ([WorkFlowStepKey] ASC)
);
GO

-- ==============================================================
-- Author: Henry Weng
-- Procedure: [Process].[usp_TrackWorkFlow]
-- Create date: 2020-04-25
-- Description: Tracks the workflow of each step of the project.
-- ==============================================================
CREATE PROCEDURE [Process].[usp_TrackWorkFlow]
	@starttime datetime2,
	@workflowdescription nvarchar(100),
	@workflowsteptablerowcount int,
	@userauthorization int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @endtime as datetime2(7) = SYSDATETIME();
	INSERT INTO [Process].[WorkflowSteps]
		(WorkFlowStepDescription, WorkFlowStepTableRowCount, StartingDateTime, EndingDateTime, 
			LastName, FirstName, QmailEmailAddress)
	VALUES (@workflowdescription, @workflowsteptablerowcount, @starttime, @endtime, 
			(SELECT TOP 1 LastName FROM [DbSecurity].[UserAuthorization] WHERE UserAuthorizationKey = @userauthorization),  
			(SELECT TOP 1 FirstName FROM [DbSecurity].[UserAuthorization] WHERE UserAuthorizationKey = @userauthorization),
			(SELECT TOP 1 QmailEmailAddress FROM [DbSecurity].[UserAuthorization] WHERE UserAuthorizationKey = @userauthorization)
	);
END 
GO

-- ===============================================
-- Add metadata columns.
-- ===============================================
ALTER TABLE [Education].Class
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Education].Course
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Education].ModeOfInstruction
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Faculty].Department
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Faculty].Instructor
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Faculty].InstructorDepartment
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Campus].[Building]
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Campus].[Room]
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Time].[ClassDay]
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
ALTER TABLE [Time].[Day]
ADD
	[UserAuthorizationKey] [int] NOT NULL DEFAULT (-1),
	[ClassTime] [nchar](5) NULL DEFAULT N'12:15',
	[LastName] [nvarchar](30) NULL DEFAULT N'Your last name',
	[FirstName][nvarchar](30) NULL DEFAULT N'Your first name',
	[QmailEmailAddress][nvarchar](40) NULL DEFAULT N'Your QMail Email Address',
	[DateAdded] [datetime2](7) NULL DEFAULT (SYSDATETIME()),
	[DateOfLastUpdate] [datetime2](7) NULL DEFAULT (SYSDATETIME());
GO
-- ==============================================
-- Add DML triggers.
-- ==============================================
CREATE TRIGGER [Education].[ClassTrigger] 
ON [Education].Class
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Education].Class SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Education].Class.ClassKey = i.ClassKey;
END
GO
CREATE TRIGGER [Education].[CourseTrigger]
ON [Education].Course
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Education].Course SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Education].Course.CourseKey = i.CourseKey;
END
GO
CREATE TRIGGER [Education].[ModeOfInstructionTrigger]
ON [Education].ModeOfInstruction
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Education].ModeOfInstruction SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Education].ModeOfInstruction.ModeOfInstructionKey = i.ModeOfInstructionKey;
END
GO
CREATE TRIGGER [Faculty].[DepartmentTrigger]
ON [Faculty].Department
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Faculty].Department SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Faculty].Department.DepartmentKey = i.DepartmentKey;
END
GO
CREATE TRIGGER [Faculty].[InstructorDepartmentTrigger]
ON [Faculty].InstructorDepartment
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Faculty].InstructorDepartment SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Faculty].InstructorDepartment.InstructorDepartmentKey = i.InstructorDepartmentKey;
END
GO
CREATE TRIGGER [Faculty].[InstructorTrigger]
ON [Faculty].Instructor
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Faculty].Instructor SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Faculty].Instructor.InstructorKey = i.InstructorKey;
END
GO
CREATE TRIGGER [Campus].[BuildingTrigger]
ON [Campus].Building
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Campus].Building SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Campus].Building.BuildingKey = i.BuildingKey;
END
GO
CREATE TRIGGER [Campus].[RoomTrigger]
ON [Campus].Room
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [Campus].Room SET DateOfLastUpdate = SYSDATETIME()
	FROM INSERTED i
	WHERE [Campus].Room.RoomKey = i.RoomKey;
END
GO

DROP TABLE IF EXISTS dbo.CoursesSpring2019;

SELECT * INTO [dbo].[CoursesSpring2019] 
FROM Uploadfile.CoursesSpring2019;

-- Delete duplicate rows for Code (338)
WITH CTE 
AS
(
	SELECT Code, Instructor, ROW_NUMBER() OVER (PARTITION BY Code ORDER BY Code) AS DuplicateCount
	FROM dbo.CoursesSpring2019
)
DELETE FROM CTE
WHERE DuplicateCount > 1;

-- Delete entries with blank section (1)
DELETE FROM dbo.CoursesSpring2019
WHERE Sec = '';

ALTER TABLE dbo.CoursesSpring2019
ADD BuildingCode AS (LEFT(Location,2)),
	Room AS SUBSTRING(Location, CHARINDEX(' ', Location) + 1, LEN(Location)),
	DepartmentCode AS LEFT([Course (hr, crd)], CHARINDEX(' ',[Course (hr, crd)]) - 1),
	CourseCode AS SUBSTRING([Course (hr, crd)], CHARINDEX(' ',[Course (hr, crd)]) + 1, 
							CHARINDEX('(',[Course (hr, crd)]) - CHARINDEX(' ',[Course (hr, crd)]) - 2);

ALTER TABLE dbo.CoursesSpring2019
ADD StartTime time(0) NULL,
	EndTime time(0) NULL;
GO

UPDATE dbo.CoursesSpring2019
SET StartTime = CAST(LEFT(Time, CHARINDEX('-',Time) - 1) AS time),
	EndTime = CAST(SUBSTRING(Time, CHARINDEX('-',Time) + 2,LEN(Time)) AS time)
WHERE [Time] <> '-';
GO

ALTER TABLE dbo.CoursesSpring2019
ADD Day1 nchar(10) NULL,
	Day2 nchar(10) NULL,
	Day3 nchar(10) NULL;
GO

UPDATE dbo.CoursesSpring2019
SET Day1 = CASE WHEN CHARINDEX(',',Day) > 0 THEN SUBSTRING(Day,1,CHARINDEX(',',Day)-1)
				WHEN Day = ''				THEN NULL
				WHEN CHARINDEX(',',Day) = 0 THEN Day
			END

UPDATE dbo.CoursesSpring2019
SET Day2 = CASE WHEN CHARINDEX(',',Day) > 0 THEN LTRIM(SUBSTRING(Day, CHARINDEX(',',Day)+1, LEN(Day)-CHARINDEX(',',Day)))
			ELSE NULL
			END

UPDATE dbo.CoursesSpring2019
SET Day3 = LTRIM(SUBSTRING(Day2, CHARINDEX(',',Day2)+1, LEN(Day2)-CHARINDEX(',',Day2))),
	Day2 = LTRIM(SUBSTRING(Day2,1,CHARINDEX(',',Day2)-1))
WHERE CHARINDEX(',',Day2) > 0
GO

CREATE PROCEDURE [Process].[usp_ShowWorkflowSteps]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM [Process].[WorkflowSteps]
END 
GO


