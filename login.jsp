<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>Login</title>
<body>
	<%@ page import="java.sql.*"%>
	<%-- -------- Open Connection Code -------- --%>
	<%
	String db = (String) session.getAttribute("dbType");
	if(db==null){
		db = "postgres";
	}
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			// Registering Postgresql JDBC driver with the DriverManager
			Class.forName("org.postgresql.Driver");

			// Open a connection to the database using DriverManager
			conn = DriverManager
			.getConnection("jdbc:postgresql://localhost:1234/" + db + "?"
					+ "user=postgres&password=cse135");
	%>
	
	
	<form action="login.jsp" method="post">

		<label>Username:</label> 
		<input name="username" value="" /> 
		<input type="hidden" name="action" value="loginUser" /> <input type="submit" value="Login" />

	</form>

	<%----------- LOGIN Code -----------------%>
	<%
		String theAction = request.getParameter("action");
			if(theAction != null && theAction.equals("loginUser"))	{
		
		//see if the user actually exists.
		
	            // Create the statement
	            Statement statement = conn.createStatement();

	            // Use the created statement to SELECT
	            // the student attributes FROM the Student table.
	            String username = request.getParameter("username").trim();
	            rs = statement.executeQuery("SELECT username, usertype FROM users WHERE username='"+username+"'");
	            
	            if(rs.next()) {
	            	session.setAttribute("currentUserName",username);
	            	session.setAttribute("usertype",rs.getString("usertype"));
					// New location to be redirected
					String site = "categoriespage.jsp";
					response.setStatus(response.SC_MOVED_TEMPORARILY);
					response.setHeader("Location", site);
				}
	            else{
	%>
	            <br/>The username entered does not exist.<br/>
	<%
	            }
			}
	%>
	
	<%-- -------- Close Connection Code -------- --%>
	<%

			// Close the Connection
			conn.close();
		} catch (SQLException e) {

			// Wrap the SQL exception in a runtime exception to propagate
			// it upwards
			System.out.println("Got an SQLException: " + e.getMessage());
			throw new RuntimeException(e);
		} finally {
			// Release resources in a finally block in reverse-order of
			// their creation

			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
				} // Ignore
				rs = null;
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
				} // Ignore
				pstmt = null;
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
				} // Ignore
				conn = null;
			}
		}
	%>
</body>
</html>
