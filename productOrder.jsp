<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Product Order</title>
</head>
<body>
	<%@ page import="java.sql.*"%>
	<%@ page import="java.util.*"%>
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
		String productClicked = (String) request.getParameter("productClicked");
		String theAction = request.getParameter("action");
		String currentUser = (String) session.getAttribute("currentUserName");
	%>
	
		Hello 
	<%=currentUser%><br /><br />
	
	<%-- -------- INSERT Code -------- --%>
	<%
	/**
	seasons

	0 - winter	(december to february 12, 1-2)
	1 - spring	(march to may 3-5)
	2 - summer	(june to august, 6-8)
	3 - fall	(spetember to november 9-11)
	**/
		if (theAction != null && theAction.equals("insert")) {
			Calendar calendar = new GregorianCalendar();
			int month = calendar.get(Calendar.MONTH);
			int season = 0;
			if(month==12||month>=0 && month<=2){
				season = 0;
			} else if(month>=3 && month<=5){
				season = 1;
			} else if(month>=6 && month<=8){
				season = 2;
			} else if(month>=9 && month<=11){
				season = 3;
			}
			try {
				// Begin transaction
				conn.setAutoCommit(false);
				// Create the prepared statement and use it to
				// INSERT student values INTO the students table.
				pstmt = conn
						.prepareStatement("INSERT INTO carts (username,productname,quantity,season) VALUES (?,?,?,?)");
				pstmt.setString(1, currentUser);
				pstmt.setString(2, productClicked);
				pstmt.setInt(3, Integer.parseInt(request.getParameter("quantity")));
				pstmt.setInt(4, season);
				int rowCount = pstmt.executeUpdate();

				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
			} catch (SQLException e) {
				// Open a connection to the database using DriverManager
				conn = DriverManager
			.getConnection("jdbc:postgresql://localhost:1234/" + db + "?"
					+ "user=postgres&password=cse135");
	%>
	<br /> ERROR, there was a problem when trying to add to the shopping cart.
	<br />
	<%
			}
					catch(Exception e){
						%>
						Please input an integer.<br/><br/>
						<%
					}
				}
	%>
	
	<label>Product Order<br><br></label>
	<%-- -------- SELECT Statement Code -------- --%>
		<%
		{
				// Create the statement
				Statement statement = conn.createStatement();
				String product =  request.getParameter("productClicked"); 
				// Use the created statement to SELECT
				// the student attributes FROM the Student table.
				rs = statement.executeQuery("SELECT price FROM products WHERE productname='" + product + "'");
				// Iterate over the ResultSet
				if(rs.next()){
					double price = rs.getDouble("price");
		%>
	You have chosen <%=product%>. It costs $<%=price %>. <br/>
	
	<label>How many <%=product%>s do you want to add to your cart? </label>
	<form action="productOrder.jsp" method="post">
	<input type="quantity" name="quantity" value="" />
	<input type="hidden" name="productClicked" value="<%=productClicked %>">
	<input type="hidden" name="action" value="insert">
	<input type="submit" value="Add to cart" /><br><br>
	</form>
	<%
				}//end if statement
	}//end the block of the select statement code above
	%>
	<label>Items in Shopping Cart so far:<br><br></label>

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
			<form action="productOrder.jsp" method="POST">
				<input type="hidden" name="action" value="delete" /> 
				<input type="hidden" value="<%=rs.getInt("cartid")%>" name="id" />
				<input type="hidden" name="productClicked" value = "<%=productClicked%>"/>
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