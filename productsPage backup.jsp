<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<body>

<%@ page import="java.sql.*"%>
	<%-- -------- Open Connection Code -------- --%>
	<%
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			// Registering Postgresql JDBC driver with the DriverManager
			Class.forName("org.postgresql.Driver");

			// Open a connection to the database using DriverManager
			conn = DriverManager
					.getConnection("jdbc:postgresql://localhost:1234/postgres?"
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
	<%=currentUser%><br /><br />
	<%
	String theAction = request.getParameter("action");
	
%>
	Please create a new product.<br/>
	Currently viewing category <%=request.getParameter("thecategory")%>.<br/>
	<%-- -------- INSERT Code -------- --%>
	<% 
	if(theAction!=null && theAction.equals("insert")){
		String name = request.getParameter("prodName");
		String SKU = request.getParameter("prodSKU");
		String price = request.getParameter("prodPrice");
		String cat = request.getParameter("thecategory");
		if (!name.equals("") && !SKU.equals("") && !price.equals("") && !cat.equals("")) {
			try {

				// Begin transaction
				conn.setAutoCommit(false);
				// Create the prepared statement and use it to
				// INSERT student values INTO the table.
				pstmt = conn
						.prepareStatement("INSERT INTO products (productname,"
						+ "productsku,price,category) VALUES (?,?,?,?)");
				pstmt.setString(1, name);
				pstmt.setInt(2, Integer.parseInt(SKU));
				pstmt.setDouble(3, Double.parseDouble(price));
				pstmt.setString(4, cat);
				int rowCount = pstmt.executeUpdate();
				
				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
				
				%>
				
				<% 
			} catch (SQLException e) {
				conn = DriverManager.getConnection("jdbc:postgresql://localhost:1234/postgres?"
					                 + "user=postgres&password=cse135");
				System.out.println("Got an SQLException: " + e.getMessage());
				%>

				<br /> ERROR: SKU already exists or price cannot be negative. Please try again.
				<br />
				<br />
				<%
			}
		} else { %>
		<br /> Please go back and fill in all the descriptions
		<br />
		<br />
		<%}
	}
	%>
	<table  border="0">
<td style="background-color:#EEEEEE;width:100px;">
<b>Categories</b><br>
			<%-- -------- SELECT Statement Code -------- --%>
		<%
			// Create the statement
				Statement statement = conn.createStatement();

				// Use the created statement to SELECT
				// the student attributes FROM the Student table.
				rs = statement.executeQuery("SELECT * FROM categories");
				
				String productPage = "";
				if("owner".equals(session.getAttribute("usertype"))){
					productPage="productsPage.jsp";
				}
				else{
					productPage="productsBrowsingPage.jsp";
				}
				
				// Iterate over the ResultSet
				while (rs.next()) {
		%>
<form action="productsPage.jsp" method="POST">
<input type="submit" name="thecategory" value="<%=rs.getString("categoryname")%>" />
</form>
<%
	}
%>
</td>
<td style="background-color:#EEEEEE;">
<b>Products</b><br/>
<%
rs = statement.executeQuery("SELECT productname FROM products WHERE category='"+request.getParameter("thecategory")+"'"); 
while(rs.next()){
%>
<%=rs.getString("productname") %><br/>
<%
}
%>
</td>
<td style="background-color:#EEEEEE;">
	<form method="post" action="productsPage.jsp">

	<label>Name:</label>
	<input type="text" name="prodName" value="" /><br>
	
	<label>SKU:</label>
	<input type="text" name="prodSKU" value="" /><br>
	
	<label>List Price:</label>
	<input type="text" name="prodPrice" value="" /><br>
	
	<label>Category:</label>
	<select name="thecategory">
	<% 
		rs = statement.executeQuery("SELECT categoryname FROM categories");
		while (rs.next()) {
			%>
			<option value="<%=rs.getString("categoryname")%>"><%=rs.getString("categoryname")%></option>
			<%
		}
	%>
	</select><br>

	<input type="hidden" name="action" value="insert" />
	<input type="submit" value="Submit Product" />
</form>
</td>
</table>


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