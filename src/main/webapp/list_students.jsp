<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student List</title>

        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 {
                color: #333;
            }

            .message {
                padding: 12px;
                margin-bottom: 20px;
                border-radius: 6px;
                font-size: 15px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .success {
                background-color: #d4edda;
                color: #155724;
                border-left: 6px solid #28a745;
            }
            .error {
                background-color: #f8d7da;
                color: #721c24;
                border-left: 6px solid #dc3545;
            }

            .btn {
                display: inline-block;
                padding: 10px 20px;
                margin-bottom: 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
            }

            .table-responsive {
                overflow-x: auto;
                background: white;
                padding: 10px;
                border-radius: 6px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                background-color: #007bff;
                color: white;
                padding: 12px;
            }
            td {
                padding: 10px;
                border-bottom: 1px solid #ddd;
            }
            tr:hover {
                background-color: #f8f9fa;
            }

            .action-link {
                color: #007bff;
                margin-right: 10px;
            }
            .delete-link {
                color: #dc3545;
            }

            @media (max-width: 768px) {
                table {
                    font-size: 12px;
                }
                th, td {
                    padding: 6px;
                }
            }

            .pagination {
                margin-top: 20px;
                text-align: center;
            }
            .pagination a, .pagination strong {
                margin: 0 5px;
                padding: 6px 12px;
                background: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 4px;
            }
            .pagination strong {
                background: #0056b3;
            }
        </style>

        <script>
            setTimeout(function () {
                var messages = document.querySelectorAll('.message');
                messages.forEach(function (msg) {
                    msg.style.display = 'none';
                });
            }, 3000);
        </script>
    </head>

    <body>
        <h1>📚 Student Management System</h1>

        <% if (request.getParameter("message") != null) {%>
        <div class="message success">✓ <%= request.getParameter("message")%></div>
        <% } %>

        <% if (request.getParameter("error") != null) {%>
        <div class="message error">✗ <%= request.getParameter("error")%></div>
        <% }%>

        <form action="list_students.jsp" method="GET" class="search-box">
            <input 
                type="text" 
                name="keyword"
                placeholder="Search by name or code..."
                value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : ""%>"
                style="padding: 8px; width: 250px;"
                >
            <button type="submit" style="padding: 8px 15px;">Search</button>
            <a href="list_students.jsp" style="padding: 8px 15px; background:#6c757d; color:white; border-radius:4px;">Clear</a>
        </form>

        <a href="add_student.jsp" class="btn" style="margin-top: 20px">➕ Add New Student</a>
        
        <a href="export_csv.jsp" class="btn">📄 Export CSV</a>

        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student Code</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Major</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>

                    <%

                        String keyword = request.getParameter("keyword");

                        String pageParam = request.getParameter("page");
                        int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;

                        int recordsPerPage = 5;
                        int offset = (currentPage - 1) * recordsPerPage;

                        int totalRecords = 0;
                        int totalPages = 1;

                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;

                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/student_management",
                                    "root",
                                    "mysql"
                            );

                            PreparedStatement countStmt;
                            if (keyword != null && !keyword.trim().isEmpty()) {
                                countStmt = conn.prepareStatement(
                                        "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ?"
                                );
                                countStmt.setString(1, "%" + keyword + "%");
                                countStmt.setString(2, "%" + keyword + "%");
                            } else {
                                countStmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
                            }

                            ResultSet countRs = countStmt.executeQuery();
                            if (countRs.next()) {
                                totalRecords = countRs.getInt(1);
                            }
                            countRs.close();
                            countStmt.close();

                            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

                            String sql;

                            if (keyword != null && !keyword.trim().isEmpty()) {
                                sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? "
                                        + "ORDER BY id DESC LIMIT ? OFFSET ?";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setString(1, "%" + keyword + "%");
                                pstmt.setString(2, "%" + keyword + "%");
                                pstmt.setInt(3, recordsPerPage);
                                pstmt.setInt(4, offset);
                            } else {
                                sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, recordsPerPage);
                                pstmt.setInt(2, offset);
                            }

                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                int id = rs.getInt("id");
                                String sc = rs.getString("student_code");
                                String name = rs.getString("full_name");
                                String email = rs.getString("email");
                                String major = rs.getString("major");
                                Timestamp created = rs.getTimestamp("created_at");
                    %>

                    <tr>
                        <td><%= id%></td>
                        <td><%= sc%></td>
                        <td><%= name%></td>
                        <td><%= email != null ? email : "N/A"%></td>
                        <td><%= major != null ? major : "N/A"%></td>
                        <td><%= created%></td>
                        <td>
                            <a href="edit_student.jsp?id=<%= id%>" class="action-link">✏️ Edit</a>
                            <a href="delete_student.jsp?id=<%= id%>" class="action-link delete-link"
                               onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                        </td>
                    </tr>

                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) {
                                rs.close();
                            }
                            if (pstmt != null) {
                                pstmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        }
                    %>

                </tbody>
            </table>
        </div>

        <div class="pagination">
            <% if (currentPage > 1) {%>
            <a href="list_students.jsp?page=<%= currentPage - 1%><%= (keyword != null ? "&keyword=" + keyword : "")%>">Previous</a>
            <% } %>

            <% for (int i = 1; i <= totalPages; i++) { %>
            <% if (i == currentPage) {%>
            <strong><%= i%></strong>
            <% } else {%>
            <a href="list_students.jsp?page=<%= i%><%= (keyword != null ? "&keyword=" + keyword : "")%>"><%= i%></a>
            <% } %>
            <% } %>

            <% if (currentPage < totalPages) {%>
            <a href="list_students.jsp?page=<%= currentPage + 1%><%= (keyword != null ? "&keyword=" + keyword : "")%>">Next</a>
            <% }%>
        </div>

    </body>
</html>
