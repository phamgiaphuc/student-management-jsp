<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
response.setContentType("text/csv; charset=UTF-8");
response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

out.println("ID,Student Code,Full Name,Email,Major,Created At");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String keyword = request.getParameter("keyword");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/student_management",
        "root", "mysql"
    );

    String sql;
    if (keyword != null && !keyword.trim().isEmpty()) {
        sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + keyword + "%");
        pstmt.setString(2, "%" + keyword + "%");
    } else {
        sql = "SELECT * FROM students ORDER BY id DESC";
        pstmt = conn.prepareStatement(sql);
    }

    rs = pstmt.executeQuery();

    while (rs.next()) {
        out.println(
            rs.getInt("id") + "," +
            "\"" + rs.getString("student_code") + "\"," +
            "\"" + rs.getString("full_name") + "\"," +
            "\"" + (rs.getString("email") != null ? rs.getString("email") : "") + "\"," +
            "\"" + (rs.getString("major") != null ? rs.getString("major") : "") + "\"," +
            "\"" + rs.getTimestamp("created_at").toString() + "\""
        );
    }

} catch (Exception e) {
    out.println("ERROR," + e.getMessage());
} finally {
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    if (conn != null) conn.close();
}
%>
