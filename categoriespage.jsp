<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>Categories</title>
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
		String usertype = (String) session.getAttribute("usertype");
		if("customer".equals(usertype)){
			%>
			<a href="buyShoppingCart.jsp">Shopping Cart</a>
			<br/>
			<%
		}
		String theAction = request.getParameter("action");
	%>

	<%
		String newCategory = (String) request.getParameter("category");

			if (newCategory != null) {
				newCategory = newCategory.trim();
			}
	%>

	<%-- -------- INSERT Code -------- --%>
	<%
		if (theAction != null && theAction.equals("insert")) {
					try {
						// Begin transaction
						conn.setAutoCommit(false);
						// Create the prepared statement and use it to
						// INSERT student values INTO the students table.
						pstmt = conn
								.prepareStatement("INSERT INTO categories (categoryname) VALUES (?)");
						pstmt.setString(1, newCategory);
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
	<br /> Cannot enter duplicate category.
	<br />
	<br />
	<%
			}
				}
	%>

	<%-- -------- DELETE Code -------- --%>
	<%
		// Check if a delete is requested
			if (theAction != null && theAction.equals("delete")) {

				// Begin transaction
				conn.setAutoCommit(false);

				// Create the prepared statement and use it to
				// DELETE students FROM the Students table.
				pstmt = conn
						.prepareStatement("DELETE FROM categories WHERE categoryid = ?");

				pstmt.setInt(1,
						Integer.parseInt(request.getParameter("id")));
				int rowCount = pstmt.executeUpdate();

				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
			}
	%>
	
	<%-- -------- UPDATE Code -------- --%>
            <%
            try{
                // Check if an update is requested
                if (theAction != null && theAction.equals("update")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // UPDATE student values in the Students table.
                    pstmt = conn
                        .prepareStatement("UPDATE categories SET categoryname = ? WHERE categoryname = ?");

                    pstmt.setString(1, request.getParameter("updatedCategoryName"));
                    pstmt.setString(2, request.getParameter("previousCategoryName"));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                    
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // UPDATE student values in the Students table.
                    pstmt = conn
                        .prepareStatement("UPDATE products SET category = ? WHERE category = ?");

                    pstmt.setString(1, request.getParameter("updatedCategoryName"));
                    pstmt.setString(2, request.getParameter("previousCategoryName"));
                    rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            }catch(SQLException e){
            	// Open a connection to the database using DriverManager
				conn = DriverManager
			.getConnection("jdbc:postgresql://localhost:1234/" + db + "?"
					+ "user=postgres&password=cse135");
            	%>
            	Cannot update, category already exists.<br/>
            	<%
            }
            %>

	Hello 
	<%=session.getAttribute("currentUserName")%><br />
	
	<%if("owner".equals(usertype)){ %>
	
		<p>
			Go <a href="salesAnalyticsPage.jsp">here</a> to view sales analytics!
		</p>
			<form action="categoriespage.jsp" method="post">
				<label>Category:</label> <input type="text" value="" name="category" />
				<input type="hidden" name="action" value="insert" /> <input
					type="submit" value="Create Category" />
			</form>
				<br />	<br />
	<br /> Please create a new category if you want.
	<br />

	<%} %>
<br />
	<br />
	<table border="1" width="200">
		<tr>
			<th>Categories</th>
			<%if("owner".equals(usertype)){ %><th>Update</th><th>Delete?</th><%} %>
		</tr>
		<%-- -------- SELECT Statement Code -------- --%>
		<%
			// Create the statement
				Statement statement = conn.createStatement();

				// Use the created statement to SELECT
				// the student attributes FROM the Student table.
				rs = statement.executeQuery("SELECT * FROM categories");
				
				String productPage = "";
				if("owner".equals(usertype)){
					productPage="productsPage.jsp";
				}
				else{
					productPage="productsBrowsingPage.jsp";
				}
				
				// Iterate over the ResultSet
				while (rs.next()) {
					Statement s = conn.createStatement();
					ResultSet hasProducts = s.executeQuery("SELECT * FROM products WHERE category='"+rs.getString("categoryname")+"'");
		%>

		<tr>
			<td>
				<form action="<%=productPage%>" method="POST">
				<input type="submit" name="thecategory" value="<%=rs.getString("categoryname")%>" />
				</form>
			</td>
			<%if("owner".equals(usertype)){ %>
			<td>
				<form action="categoriespage.jsp" method="POST">
					<input type="text" name="updatedCategoryName">
					<input type="hidden" name="previousCategoryName" value="<%=rs.getString("categoryname") %>"/>
					<input type="hidden" name="action" value="update"/>
					<input type="submit" value="Update" />
				</form>
			</td>
			<td>
			<%if(!hasProducts.next()){ %>
				<form action="categoriespage.jsp" method="POST">
					<input type="hidden" name="action" value="delete" /> <input
						type="hidden" value="<%=rs.getInt("categoryid")%>" name="id" />
					<%-- Button --%>
					<input type="submit" value="Delete" />
				</form>
				<%} %>
			</td>
			<%} %>
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