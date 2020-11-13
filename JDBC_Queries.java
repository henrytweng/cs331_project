import java.sql.*;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

public class JDBCProject3 {
    public static void main (String[] args) {
        try {
            Connection myConn = DriverManager.getConnection("jdbc:sqlserver://localhost:11000", "sa", "HW@23626785");
            Statement stmt = myConn.createStatement();
            // Access the QueensClassScheduleSpring2019 database
            stmt.executeUpdate( "USE QueensClassScheduleSpring2019\n" );

            // Execute [dbo].[LoadSchedule]
            CallableStatement cs = myConn.prepareCall("{call [dbo].[LoadSchedule](?)}");
            cs.setString(1, "85");
            boolean hasResult = cs.execute();
            while (hasResult) {
                ResultSet rs = cs.getResultSet();
                JTable output = new JTable(buildModel(rs));
                JOptionPane.showMessageDialog(null, new JScrollPane(output));
                hasResult = cs.getMoreResults();
            }

            //Execute [Process].[usp_ShowWorkflowSteps]
            CallableStatement cs2 = myConn.prepareCall("{call [Process].[usp_ShowWorkflowSteps]}");
            hasResult = cs2.execute();
            while (hasResult) {
                ResultSet rs = cs2.getResultSet();
                JTable table = new JTable(buildModel(rs));
                JOptionPane.showMessageDialog(null, new JScrollPane(table));
                hasResult = cs2.getMoreResults();
            }

            // Show all instructors who are teaching in classes in multiple departments.
            ResultSet rs3_1 = stmt.executeQuery("SELECT fi.InstructorFullName, COUNT(DISTINCT fid.DepartmentKey) as NumDepartments\n" +
//                    "FROM Faculty.Instructor as fi\n" +
//                    "\tINNER JOIN Faculty.InstructorDepartment as fid\n" +
                    "\t\tON fi.InstructorKey = fid.InstructorKey\n" +
                    "GROUP BY fi.InstructorFullName\n" +
                    "HAVING COUNT(DISTINCT fid.DepartmentKey) > 1");

            JTable output = new JTable(buildModel(rs3_1));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));

            // How many instructors are in each department?
            ResultSet rs3_2 = stmt.executeQuery("SELECT fd.DepartmentName, COUNT(DISTINCT InstructorKey) as NumInstructors\n" +
                    "FROM Faculty.Department as fd\n" +
                    "\tINNER JOIN Faculty.InstructorDepartment as fid\n" +
                    "\t\tON fd.DepartmentKey = fid.DepartmentKey\n" +
                    "GROUP BY fd.DepartmentName\n" +
                    "ORDER BY fd.DepartmentName;");

            output = new JTable(buildModel(rs3_2));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));

            // How many classes are being taught that semester, grouped by course and aggregating the total enrollment,
            // total class limit, and percentage enrollment?
            ResultSet rs3_3 = stmt.executeQuery("SELECT t3.DepartmentName, t2.CourseCode, \n" +
                    "\t\tCOUNT(t1.ClassKey) as NumClasses, \n" +
                    "\t\tSUM(t1.Enrolled) as TotalEnrollment, \n" +
                    "\t\tSUM(t1.Limit) as TotalLimit, \n" +
                    "\t\tCAST(100. * SUM(t1.Enrolled)/SUM(t1.Limit) AS NUMERIC(6,2)) AS PercentageEnrollment\n" +
                    "FROM Education.Class as t1\n" +
                    "\tINNER JOIN Education.Course as t2\n" +
                    "\t\tON t1.CourseKey = t2.CourseKey\n" +
                    "\tINNER JOIN Faculty.Department as t3\n" +
                    "\t\tON t2.DepartmentKey = t3.DepartmentKey\n" +
                    "GROUP BY t3.DepartmentName, t2.CourseCode\n" +
                    "HAVING SUM(t1.Limit) <> 0\n" +
                    "ORDER BY t3.DepartmentName;");

            output = new JTable(buildModel(rs3_3));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));

            // What percent of students and of classes are being taught through each mode of instruction?
            ResultSet rs3_4 = stmt.executeQuery("SELECT t2.Mode, \n" +
                    "\tCAST(100. * SUM(t1.Enrolled) / (SELECT SUM(Enrolled) FROM Education.Class) AS NUMERIC(5,2)) as PercentStudents,\n" +
                    "\tCAST(100. * COUNT(t1.ClassKey) / (SELECT COUNT(ClassKey) FROM Education.Class) AS NUMERIC (5,2)) as PercentClasses\n" +
                    "FROM Education.Class AS t1\n" +
                    "\tINNER JOIN Education.ModeOfInstruction AS t2\n" +
                    "\t\tON t1.ModeOfInstructionKey = t2.ModeOfInstructionKey\n" +
                    "GROUP BY t2.Mode;\n");

            output = new JTable(buildModel(rs3_4));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));

            // What is the average length of classes in Kiely Hall?
            ResultSet rs3_5 = stmt.executeQuery("SELECT SUM(DATEDIFF(minute, ec.StartTime, ec.EndTime)) / COUNT(ec.ClassKey) as AverageLengthInMinutes\n" +
                    "FROM Education.Class as ec\n" +
                    "\tINNER JOIN Campus.Room as cr\n" +
                    "\t\tON ec.RoomKey = cr.Roomkey\n" +
                    "\tINNER JOIN Campus.Building as cb\n" +
                    "\t\tON cr.BuildingKey = cb.BuildingKey\n" +
                    "WHERE cb.BuildingName = 'Kiely Hall'");

            output = new JTable(buildModel(rs3_5));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));

            // Which Computer Science courses are held on Mondays?
            ResultSet rs3_6 = stmt.executeQuery("SELECT DISTINCT t3.DepartmentCode, t2.CourseCode, t2.CourseDescription\n" +
                    "FROM Education.Class as t1\n" +
                    "\tINNER JOIN Education.Course as t2\n" +
                    "\t\tON t1.CourseKey = t2.CourseKey\n" +
                    "\tINNER JOIN Faculty.Department as t3\n" +
                    "\t\tON t2.DepartmentKey = t3.DepartmentKey\n" +
                    "\tINNER JOIN Time.ClassDay as t4\n" +
                    "\t\tON t1.ClassKey = t4.ClassKey\n" +
                    "\tINNER JOIN Time.Day as t5\n" +
                    "\t\tON t4.DayKey = t5.DayKey\n" +
                    "WHERE t3.DepartmentCode = 'CSCI' AND t5.Day = 'Monday'");

            output = new JTable(buildModel(rs3_6));
            JOptionPane.showMessageDialog(null, new JScrollPane(output));
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public static DefaultTableModel buildModel(ResultSet rs) throws SQLException {
        DefaultTableModel model = new DefaultTableModel();
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();
        for (int i = 1; i <= columnCount; i++)
            model.addColumn(metaData.getColumnLabel(i));
        Object[] row = new Object[columnCount];
        while (rs.next()) {
            for (int i = 1; i <= columnCount; i++) {
                row[i - 1] = rs.getObject(i);
            }
            model.addRow(row);
        }
        return model;
    }
}
