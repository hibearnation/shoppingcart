<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	import="java.sql.*, java.util.*" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<script type="text/javascript"
	src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
<script type="text/javascript" src="editProj.js"></script>
</head>

<body>

	<%-- -------- Open Connection Code -------- --%>
	<%
		String db = (String) session.getAttribute("dbType");
		if (db == null) {
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
					.getConnection("jdbc:postgresql://localhost:1234/" + db
							+ "?" + "user=postgres&password=cse135");
	%>
	<%
		if ("customer".equals(session.getAttribute("usertype"))) {
	%>
	<a href="buyShoppingCart.jsp">Shopping Cart</a>
	<br />
	<%
		}
			String currentUser = (String) session
					.getAttribute("currentUserName");
	%>
	Hello
	<%=currentUser%><br />
	<br />
	<%
		String theAction = request.getParameter("action");
	%>
	<%
		try {
	%>
	<%-- -------- UPDATE Name Code -------- --%>
	<%
		// Check if an update is requested
				if (theAction != null && theAction.equals("updatename")) {

					// Begin transaction
					conn.setAutoCommit(false);

					// Create the prepared statement and use it to
					// UPDATE student values in the Students table.
					pstmt = conn
							.prepareStatement("UPDATE products SET productname = ?"
									+ "WHERE productsku = ?");

					pstmt.setString(1, request.getParameter("uName"));
					pstmt.setInt(2, Integer.parseInt(request
							.getParameter("productsku")));
					int rowCount = pstmt.executeUpdate();

					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
	%>
	<%-- -------- UPDATE Price Code -------- --%>
	<%
		// Check if an update is requested
				if (theAction != null && theAction.equals("updateprice")) {

					// Begin transaction
					conn.setAutoCommit(false);

					// Create the prepared statement and use it to
					// UPDATE student values in the Students table.
					pstmt = conn.prepareStatement("UPDATE products SET "
							+ "price = ?  WHERE productsku = ?");

					pstmt.setDouble(1, Double.parseDouble(request
							.getParameter("uPrice")));
					pstmt.setInt(2, Integer.parseInt(request
							.getParameter("productsku")));
					int rowCount = pstmt.executeUpdate();

					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
	%>
	<%-- -------- UPDATE SKU Code -------- --%>
	<%
		// Check if an update is requested
				if (theAction != null && theAction.equals("updatesku")) {
					try {
						// Begin transaction
						conn.setAutoCommit(false);

						// Create the prepared statement and use it to
						// UPDATE student values in the Students table.
						pstmt = conn
								.prepareStatement("UPDATE products SET productsku = ? "
										+ " WHERE productsku = ?");

						pstmt.setInt(1, Integer.parseInt(request
								.getParameter("uSKU")));
						pstmt.setInt(2, Integer.parseInt(request
								.getParameter("productsku")));
						int rowCount = pstmt.executeUpdate();

						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
					} catch (SQLException e) {
						conn = DriverManager
								.getConnection("jdbc:postgresql://localhost:1234/"
										+ db
										+ "?"
										+ "user=postgres&password=cse135");
						System.out.println("Got an SQLException: "
								+ e.getMessage());
	%>

	<br /> ERROR: SKU already exists. Please try again.
	<br />
	<br />
	<%
		}
				}
	%>

	<%-- -------- UPDATE Category Code -------- --%>
	<%
		// Check if an update is requested
				if (theAction != null && theAction.equals("updatecategory")) {
					Statement statement = conn.createStatement();
					rs = statement
							.executeQuery("SELECT categoryid FROM categories WHERE categoryname = '"
									+ request.getParameter("uCategory")
									+ "'");
					if (rs.next()) {
						// Begin transaction
						conn.setAutoCommit(false);

						// Create the prepared statement and use it to
						// UPDATE student values in the Students table.
						pstmt = conn
								.prepareStatement("UPDATE products SET category = ?"
										+ " WHERE productsku = ?");

						pstmt.setString(1,
								request.getParameter("uCategory"));
						pstmt.setInt(2, Integer.parseInt(request
								.getParameter("productsku")));
						int rowCount = pstmt.executeUpdate();

						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
					} else {
	%>
	Category Does Not Exist
	<br />
	<%
		}
				}
	%>
	<%
		} catch (Exception e) {
				// Open a connection to the database using DriverManager
				conn = DriverManager
						.getConnection("jdbc:postgresql://localhost:1234/"
								+ db + "?"
								+ "user=postgres&password=cse135");
	%>
	Update was unsuccessful. Please make sure the value to be updated is
	valid.
	<br />
	<%
		}
	%>
	Please create a new product.
	<br />
	<form action="productsPage.jsp" method="POST">
		<input type="text" value="" name="sName" /> <input type="hidden"
			name="action" value="searchname" /> <input type="hidden"
			name="thecategory" value="<%=request.getParameter("thecategory")%>" />
		<%-- Button --%>
		<input type="submit" value="Search Product" />
	</form>
	Currently viewing category
	<%=request.getParameter("thecategory")%>.
	<br />
	<div id="response"></div>
	<%-- -------- INSERT Code -------- --%>
	<%
		if (theAction != null && theAction.equals("insert")) {
				String name = request.getParameter("prodName");
				String SKU = request.getParameter("prodSKU");
				String price = request.getParameter("prodPrice");
				String cat = request.getParameter("thecategory");
				if (!name.equals("") && !SKU.equals("")
						&& !price.equals("") && !cat.equals("")) {
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
						conn = DriverManager
								.getConnection("jdbc:postgresql://localhost:1234/"
										+ db
										+ "?"
										+ "user=postgres&password=cse135");
						System.out.println("Got an SQLException: "
								+ e.getMessage());
	%>

	<br /> ERROR: SKU already exists or price cannot be negative. Please
	try again.
	<br />
	<br />
	<%
		} catch (Exception e) {
	%>
	FILL OUT THE FORM CORRECTLY
	<%
		}
				} else {
	%>
	<br /> Please go back and fill in all the descriptions
	<br />
	<br />
	<%
		}
			}
	%>
	<table border="2" width="100%">
		<tr>
			<td style="vertical-align: top;">
				<table border="1" id="categoriesTable">
					<tr>
						<th>Categories</th>
					</tr>
					<tr>
						<td>
							<form action="productsPage.jsp" method="POST">
								<input type="hidden" name="action" value="searchname"> <input
									type="hidden" name="sName" value=""> <input
									type="submit" name="thecategory" value="all categories">
							</form>
						</td>
					</tr>
					<%-- -------- SELECT Statement Code -------- --%>
					<%
						// Create the statement
							Statement statement = conn.createStatement();

							// Use the created statement to SELECT
							// the student attributes FROM the Student table.
							rs = statement.executeQuery("SELECT * FROM categories");

							String productPage = "";
							if ("owner".equals(session.getAttribute("usertype"))) {
								productPage = "productsPage.jsp";
							} else {
								productPage = "productsBrowsingPage.jsp";
							}

							// Iterate over the ResultSet
							while (rs.next()) {
					%>
					<tr>
						<td>
							<form action="productsPage.jsp" method="POST">
								<input type="submit" name="thecategory"
									value="<%=rs.getString("categoryname")%>" />
							</form>
						</td>
					</tr>
					<%
						}
					%>
					<%-- -------- DELETE Code -------- --%>
					<%
						// Check if a delete is requested
							if (theAction != null && theAction.equals("delete")) {

								// Begin transaction
								conn.setAutoCommit(false);

								// Create the prepared statement and use it to
								// DELETE students FROM the products table.
								pstmt = conn
										.prepareStatement("DELETE FROM products WHERE productsku = ?");

								pstmt.setInt(1, Integer.parseInt(request
										.getParameter("productDelete")));
								int rowCount = pstmt.executeUpdate();

								// Commit transaction
								conn.commit();
								conn.setAutoCommit(true);
							}
					%>


				</table>
			</td>
			<td style="vertical-align: top;">
				<table border="1" id="productsTable">
					<tbody id="prods">
						<tr>
							<th><input id="name" value="" name="uName" /></th>
							<th><input id="price" value="" name="prodPrice" /></th>
							<th><input id="sku" value="" name="prodSKU" /></th>
							<th><select id="cat" name="thecategory">
									<%
										rs = statement
													.executeQuery("SELECT categoryname FROM categories");
											while (rs.next()) {
									%>
									<option value="<%=rs.getString("categoryname")%>"><%=rs.getString("categoryname")%></option>

									<%
										}
									%>
							</select></th>
							<th><input onClick="prodAction(null,'insert');"
								type="button" value="Submit Product" /></th>
						</tr>
						<tr>
							<th>Name</th>
							<th>Price</th>
							<th>SKU</th>
							<th>Category</th>
						</tr>
						<%-- -------- SEARCH Code -------- --%>
						<%
							if (theAction != null && theAction.equals("searchname")) {
									statement = conn.createStatement();
									rs = statement
											.executeQuery("SELECT productname, price, productsku, category FROM products WHERE productname LIKE '%"
													+ request.getParameter("sName") + "%'");
									while (rs.next()) {
						%>
						<tr id="<%=rs.getString("productsku")%>">
							<td><input id="name_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("productname")%>" name="uName" /></td>
							<td><input id="price_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("price")%>" name="uPrice" /></td>
							<td><input id="sku_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("productsku")%>" name="uSKU" /></td>
							<td><input id="cat_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("category")%>" name="uCategory" /></td>
							<td>
								<%-- Button --%> <input
								onClick="prodAction(<%=rs.getString("productsku")%>,'delete');"
								type="button" value="Delete" />
							</td>
							<td>
								<%-- Button --%> <input
								onClick="prodAction(<%=rs.getString("productsku")%>,'update');"
								type="button" value="Update" />
							</td>
						</tr>
						<%
							}
								} else {
						%>
						<%
							System.out.println(request.getParameter("thecategory"));
									rs = statement
											.executeQuery("SELECT productname, price, productsku, category FROM products WHERE category='"
													+ request.getParameter("thecategory") + "'");
									while (rs.next()) {
						%>
						<tr id="<%=rs.getString("productsku")%>">
							<td><input id="name_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("productname")%>" name="uName" /></td>
							<td><input id="price_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("price")%>" name="uPrice" /></td>
							<td><input id="sku_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("productsku")%>" name="uSKU" /></td>
							<td><input id="cat_<%=rs.getString("productsku")%>"
								value="<%=rs.getString("category")%>" name="uCategory" /></td>
							<td>
								<%-- Button --%> <input
								onClick="prodAction(<%=rs.getString("productsku")%>,'delete'); return false;"
								type="button" value="Delete" />
							</td>
							<td>
								<%-- Button --%> <input
								onClick="prodAction(<%=rs.getString("productsku")%>, 'update');"
								type="button" value="Update" />
							</td>
						</tr>
						<%
							}
								}
						%>
					</tbody>
				</table>
			</td>
		</tr>
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