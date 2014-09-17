<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Browse for Products</title>
</head>
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
	<%
		if("customer".equals(session.getAttribute("usertype"))){
			%>
			<a href="buyShoppingCart.jsp">Shopping Cart</a>
			<br/>
			<%
		}
		String currentUser = (String) session.getAttribute("currentUserName");
	%>
	
	Hello 
	<%=currentUser%><br />
	
	
		<form action="productsBrowsingPage.jsp" method="POST">
		<input type="text" value="" name="sName" />
		<input type="hidden" name="action" value="searchname" />
		<input type="hidden" name="thecategory" value="<%=request.getParameter("thecategory")%>"/>
	<%-- Button --%>
		<input type="submit" value="Search Product" />
	</form>
	
	
	<table  border="0">
<td style="background-color:#EEEEEE;width:100px;">
<form action="productsBrowsingPage.jsp" method="POST">
<input type="hidden" name="action" value="searchname">
<input type="hidden" name="sName" value="">
<input type="submit" name="thecategory" value="all categories">
</form>
<b>Categories</b><br>



			<%-- -------- SELECT Statement Code -------- --%>
		<%
			// Create the statement
				Statement statement = conn.createStatement();

				// Use the created statement to SELECT
				// the student attributes FROM the Student table.
				rs = statement.executeQuery("SELECT * FROM categories");
				
				// Iterate over the ResultSet
				while (rs.next()) {
		%>
		<form action="productsBrowsingPage.jsp" method="POST">
		<input type="submit" name="thecategory" value="<%=rs.getString("categoryname")%>" />
		</form>
		<%
			}
				String theAction = request.getParameter("action");
		%>
		</td>
		<td style="background-color:#EEEEEE;">
		<b>Products</b><br/>
		<%-- -------- SEARCH Code -------- --%>
            <%
                if (theAction != null && theAction.equals("searchname")) {
                	rs = statement.executeQuery("SELECT productname FROM products WHERE productname LIKE '%" + request.getParameter("sName")+ "%'");
                } else {
					rs = statement.executeQuery("SELECT productname FROM products WHERE category='"+request.getParameter("thecategory")+"'"); 
                }
		while(rs.next()){
		%>
		<form action="productOrder.jsp">
		<a href="productOrder.jsp?productClicked=<%=rs.getString("productname")%>"> <%=rs.getString("productname") %> </a><br/>
		</form>
		<%
		}
		%>
		</td>
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