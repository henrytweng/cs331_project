-- ****************** SqlDBM: Microsoft SQL Server ******************
-- ******************************************************************
USE QueensClassScheduleSpring2019;
GO
CREATE SCHEMA [Campus];
GO
CREATE SCHEMA [Education];
GO
CREATE SCHEMA [Faculty];
GO
CREATE SCHEMA [Time];
GO

-- ************************************** [Education].[ModeOfInstruction]

CREATE TABLE [Education].[ModeOfInstruction]
(
 [ModeOfInstructionKey] int IDENTITY (1, 1) NOT NULL ,
 [Mode]                 nvarchar(20) NOT NULL ,

 CONSTRAINT [PK_ModeOfInstruction] PRIMARY KEY CLUSTERED ([ModeOfInstructionKey] ASC),
 CONSTRAINT [AK_Mode] UNIQUE NONCLUSTERED ([Mode] ASC)
);
GO

-- ************************************** [Faculty].[Instructor]

CREATE TABLE [Faculty].[Instructor]
(
 [InstructorKey]       int IDENTITY (1, 1) NOT NULL ,
 [InstructorFirstName] nvarchar(30) NOT NULL ,
 [InstructorLastName]  nvarchar(30) NOT NULL ,
 [InstructorFullName]  nvarchar(60) NOT NULL ,

 CONSTRAINT [PK_Instructor] PRIMARY KEY CLUSTERED ([InstructorKey] ASC)
);
GO

-- ************************************** [Faculty].[Department]

CREATE TABLE [Faculty].[Department]
(
 [DepartmentKey]  int IDENTITY (1, 1) NOT NULL ,
 [DepartmentName] nvarchar(30) NOT NULL ,
 [DepartmentCode] nchar(5) NOT NULL ,

 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([DepartmentKey] ASC),
 CONSTRAINT [AK_DepartmentCode] UNIQUE NONCLUSTERED ([DepartmentCode] ASC),
 CONSTRAINT [AK_DepartmentName] UNIQUE NONCLUSTERED ([DepartmentName] ASC)
);
GO

-- ************************************** [Time].[Day]

CREATE TABLE [Time].[Day]
(
 [DayKey] int IDENTITY (1, 1) NOT NULL ,
 [Day]    nchar(10) NOT NULL ,

 CONSTRAINT [PK_Day] PRIMARY KEY NONCLUSTERED ([DayKey] ASC),
 CONSTRAINT [AK_Day] UNIQUE NONCLUSTERED ([Day] ASC)
);
GO

-- ************************************** [Campus].[Building]

CREATE TABLE [Campus].[Building]
(
 [BuildingKey]  int IDENTITY (1, 1) NOT NULL ,
 [BuildingCode] nchar(2) NOT NULL ,
 [BuildingName] nvarchar(30) NOT NULL ,


 CONSTRAINT [PK_Building] PRIMARY KEY CLUSTERED ([BuildingKey] ASC),
 CONSTRAINT [AK_BuildingCode] UNIQUE NONCLUSTERED ([BuildingCode] ASC),
 CONSTRAINT [AK_BuildingName] UNIQUE NONCLUSTERED ([BuildingName] ASC)
);
GO

-- ************************************** [Campus].[Room]

CREATE TABLE [Campus].[Room]
(
 [RoomKey]     int IDENTITY (1, 1) NOT NULL ,
 [BuildingKey] int NOT NULL ,
 [Room]        nchar(10) NOT NULL ,


 CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED ([RoomKey] ASC),
 CONSTRAINT [AK_RoomBuildingKey] UNIQUE NONCLUSTERED ([BuildingKey] ASC, [Room] ASC),
 CONSTRAINT [FK_Room_Building] FOREIGN KEY ([BuildingKey])  REFERENCES [Campus].[Building]([BuildingKey])
);
GO

CREATE NONCLUSTERED INDEX [idx_nc_buildingkey] ON [Campus].[Room] 
 (
  [BuildingKey] ASC
 )
GO

-- ************************************** [Faculty].[InstructorDepartment]

CREATE TABLE [Faculty].[InstructorDepartment]
(
 [InstructorDepartmentKey] int IDENTITY (1, 1) NOT NULL ,
 [InstructorKey]           int NOT NULL ,
 [DepartmentKey]           int NOT NULL ,

 CONSTRAINT [PK_InstructorDepartment] PRIMARY KEY NONCLUSTERED ([InstructorDepartmentKey] ASC),
 CONSTRAINT [FK_InstructorDepartment_Department] FOREIGN KEY ([DepartmentKey])  REFERENCES [Faculty].[Department]([DepartmentKey]),
 CONSTRAINT [FK_InstructorDepartment_Instructor] FOREIGN KEY ([InstructorKey])  REFERENCES [Faculty].[Instructor]([InstructorKey])
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_InstructorKeyDepartmentKey] ON [Faculty].[InstructorDepartment] 
 (
  [DepartmentKey] ASC, 
  [InstructorKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_departmentkey] ON [Faculty].[InstructorDepartment] 
 (
  [DepartmentKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_instructorkey] ON [Faculty].[InstructorDepartment] 
 (
  [InstructorKey] ASC
 )
GO

-- ************************************** [Education].[Course]

CREATE TABLE [Education].[Course]
(
 [CourseKey]         int IDENTITY (1, 1) NOT NULL ,
 [DepartmentKey]     int NOT NULL ,
 [CourseCode]        nchar(10) NOT NULL ,
 [CourseDescription] nvarchar(50) NOT NULL ,
 [CourseCredits]     float NOT NULL ,
 [CourseHours]       float NOT NULL ,

 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([CourseKey] ASC),
 CONSTRAINT [AK_DepartmentKeyCourseNumber] UNIQUE NONCLUSTERED ([DepartmentKey] ASC, [CourseCode] ASC),
 CONSTRAINT [FK_Course_Department] FOREIGN KEY ([DepartmentKey])  REFERENCES [Faculty].[Department]([DepartmentKey])
);
GO

CREATE NONCLUSTERED INDEX [idx_nc_departmentkey] ON [Education].[Course] 
 (
  [DepartmentKey] ASC
 )
GO

-- ************************************** [Education].[Class]

CREATE TABLE [Education].[Class]
(
 [ClassKey]             int IDENTITY (1, 1) NOT NULL ,
 [InstructorKey]        int NULL ,
 [RoomKey]              int NULL ,
 [ModeOfInstructionKey] int NOT NULL ,
 [CourseKey]            int NOT NULL ,
 [ClassSection]         nchar(5) NOT NULL ,
 [ClassCode]            int NOT NULL ,
 [StartTime]            time(0) NULL ,
 [EndTime]              time(0) NULL ,
 [Enrolled]             int NOT NULL ,
 [Limit]                int NOT NULL ,
 [ClassSemester]        nvarchar(20) NOT NULL ,

 CONSTRAINT [PK_Class] PRIMARY KEY CLUSTERED ([ClassKey] ASC),
 CONSTRAINT [AK_ClassCode] UNIQUE NONCLUSTERED ([ClassCode] ASC),
 CONSTRAINT [FK_Class_Course] FOREIGN KEY ([CourseKey])  REFERENCES [Education].[Course]([CourseKey]),
 CONSTRAINT [FK_Class_Instructor] FOREIGN KEY ([InstructorKey])  REFERENCES [Faculty].[Instructor]([InstructorKey]),
 CONSTRAINT [FK_Class_ModeOfInstruction] FOREIGN KEY ([ModeOfInstructionKey])  REFERENCES [Education].[ModeOfInstruction]([ModeOfInstructionKey]),
 CONSTRAINT [FK_Class_Room] FOREIGN KEY ([RoomKey])  REFERENCES [Campus].[Room]([RoomKey])
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseKeyClassSection] ON [Education].[Class] 
 (
  [CourseKey] ASC, 
  [ClassSection] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_coursekey] ON [Education].[Class] 
 (
  [CourseKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_instructorkey] ON [Education].[Class] 
 (
  [InstructorKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_modeofinstructionkey] ON [Education].[Class] 
 (
  [ModeOfInstructionKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_roomkey] ON [Education].[Class] 
 (
  [RoomKey] ASC
 )
GO

-- ************************************** [Time].[ClassDay]

CREATE TABLE [Time].[ClassDay]
(
 [ClassDayKey] int IDENTITY (1, 1) NOT NULL ,
 [ClassKey]    int NOT NULL ,
 [DayKey]      int NOT NULL ,

 CONSTRAINT [PK_ClassDays] PRIMARY KEY CLUSTERED ([ClassDayKey] ASC),
 CONSTRAINT [FK_ClassDay_Class] FOREIGN KEY ([ClassKey])  REFERENCES [Education].[Class]([ClassKey]),
 CONSTRAINT [FK_ClassDay_Day] FOREIGN KEY ([DayKey])  REFERENCES [Time].[Day]([DayKey])
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_ClassKeyDayKey] ON [Time].[ClassDay] 
 (
  [ClassKey] ASC, 
  [DayKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_classkey] ON [Time].[ClassDay] 
 (
  [ClassKey] ASC
 )
GO

CREATE NONCLUSTERED INDEX [idx_nc_daykey] ON [Time].[ClassDay] 
 (
  [DayKey] ASC
 )
GO
