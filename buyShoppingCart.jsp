<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Shopping Cart</title>
</head>
<body>
	<%@ page import="java.sql.*"%>
	<%-- -------- Open Connection Code -------- --%>
	<%
	String db = (String) session.getAttribute("dbType");
	if(db==null){
		db = "postgres";
	}
		String currentUser = (String) session.getAttribute("currentUserName");
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
			String theAction = request.getParameter("action");
	%>
	Hello 
	<%=currentUser%><br /><br />
		<label>Items in Shopping Cart:<br><br></label>
<form action="purchaseConfirmation.jsp" method="post">
	<label>Credit Card Number </label>
	<input type="quantity" value="" />
	<input type="submit" value="Purchase" />
</form>
	<%-- -------- DELETE Code -------- --%>
	<%
		// Check if a delete is requested
			if (theAction != null && theAction.equals("delete")) {

				// Begin transaction
				conn.setAutoCommit(false);

				// Create the prepared statement and use it to
				// DELETE students FROM the Students table.
				pstmt = conn
						.prepareStatement("DELETE FROM carts WHERE cartid = ?");

				pstmt.setInt(1,
						Integer.parseInt(request.getParameter("id")));
				int rowCount = pstmt.executeUpdate();

				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
			}
	%>
<table border="1">
		<tr>
			<th>Item Name</th>
			<th>Quantity</th>
			<th>Price per Item</th>
			<th>Total price of Item</th>
			<th>Remove from cart?</th>
		</tr>
		<%-- -------- SELECT Statement Code -------- --%>
		<%
			// Create the statement
				Statement statement = conn.createStatement();

				// Use the created statement to SELECT
				// the student attributes FROM the Student table.
				rs = statement.executeQuery("SELECT * FROM carts c, products p WHERE c.productname=p.productname AND c.username='"+session.getAttribute("currentUserName")+"'");
				// Iterate over the ResultSet
				while (rs.next()) {
					int quantity = rs.getInt("quantity");
					double price = rs.getDouble("price");
		%>

		<tr>
			<td><%=rs.getString("productname")%></td>
			<td><%=quantity %></td>
			<td><%=price %></td>
			<td><%=(quantity*price)%></td>
			<form action="buyShoppingCart.jsp" method="POST">
				<input type="hidden" name="action" value="delete" /> <input
					type="hidden" value="<%=rs.getInt("cartid")%>" name="id" />
				<%-- Button --%>
				<td><input type="submit" value="Remove" /></td>
			</form>
		</tr>

		<%
			}
		%>
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