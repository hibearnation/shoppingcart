<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Confirmation</title>
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
	%>
	Hello 
	<%=currentUser%><br /><br />
	
		<%-- -------- MOVE TO ORDERS Code -------- --%>
	<%
			/** SELECT **/
		
			// Create the statement
			Statement statement = conn.createStatement();
		
			// Use the created statement to SELECT
			// the student attributes FROM the Student table.
			rs = statement.executeQuery("SELECT * FROM carts WHERE username = '"+currentUser+"'");
			
			Statement s = conn.createStatement();
			ResultSet total = s.executeQuery("SELECT u.totalspent, u.userstate FROM users u WHERE username='"+currentUser+"'");
			total.next();
			
			String userState = total.getString("userstate");
			Statement st = conn.createStatement();
			ResultSet stateTotal = st.executeQuery("SELECT statetotal FROM states u WHERE statename='"+userState+"'");
			stateTotal.next();
			double cost = 0;
			/** INSERT INTO ORDERS **/		
			while(rs.next()){
				// Begin transaction
				conn.setAutoCommit(false);
				
				String productName = rs.getString("productname");
				int quantity = rs.getInt("quantity");
				int season = rs.getInt("season");
				// Create the prepared statement and use it to
				// INSERT student values INTO the students table.
				pstmt = conn.prepareStatement("INSERT INTO orders (username,productname,quantity,season) VALUES (?,?,?,?)");
				pstmt.setString(1, rs.getString("username"));
				pstmt.setString(2, productName);
				pstmt.setInt(3, quantity);
				pstmt.setInt(4,season);
				int rowCount = pstmt.executeUpdate();
		
				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
				
				/***************UPDATE CODE (for the users table on totalspent per user)*********************/
				
				Statement ss = conn.createStatement();
				ResultSet prices = ss.executeQuery("SELECT price FROM products WHERE productname='"+productName+"'");
				prices.next();
				
				cost += prices.getDouble("price")*quantity;
				
			}
			
			// Begin transaction
            conn.setAutoCommit(false);

            // Create the prepared statement and use it to
            // UPDATE student values in the Students table.
            pstmt = conn
                .prepareStatement("UPDATE users SET totalspent = ? WHERE username = ?");

            pstmt.setDouble(1, (total.getDouble("totalspent")+cost) );
            pstmt.setString(2, currentUser);
            int rowCount = pstmt.executeUpdate();

            // Commit transaction
            conn.commit();
            conn.setAutoCommit(true);
            
         // Begin transaction
            conn.setAutoCommit(false);

            // Create the prepared statement and use it to
            // UPDATE student values in the Students table.
            pstmt = conn
                .prepareStatement("UPDATE states SET statetotal = ? WHERE statename = ?");

            pstmt.setDouble(1, (stateTotal.getDouble("statetotal")+cost) );
            pstmt.setString(2, userState);
            rowCount = pstmt.executeUpdate();

            // Commit transaction
            conn.commit();
            conn.setAutoCommit(true);
			
			
			
			// Begin transaction
			conn.setAutoCommit(false);

			// Create the prepared statement and use it to
			// DELETE students FROM the Students table.
			pstmt = conn
					.prepareStatement("DELETE FROM carts WHERE username = ?");

			pstmt.setString(1, (String) session.getAttribute("currentUserName"));
			rowCount = pstmt.executeUpdate();

			// Commit transaction
			conn.commit();
			conn.setAutoCommit(true);
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
Thank you for buying from us.
Click <a href="categoriespage.jsp">here</a> to continue shopping.

</body>
</html>