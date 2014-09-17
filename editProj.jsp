<%@ page import="java.sql.*,java.util.*, org.json.simple.*"%>
<%-- -------- Open Connection Code -------- --%>

<%
	String action = (String) request.getParameter("action");

	String db = (String) session.getAttribute("dbType");
	if (db == null) {
		db = "postgres";
	}
	Connection conn = null;
	PreparedStatement pstmt = null;
	PreparedStatement pstmt0 = null;
	ResultSet rs = null;

	try {
		// Registering Postgresql JDBC driver with the DriverManager
		Class.forName("org.postgresql.Driver");

		// Open a connection to the database using DriverManager
		conn = DriverManager
				.getConnection("jdbc:postgresql://localhost:1234/" + db
						+ "?" + "user=postgres&password=cse135");
%>

<%-- -------- INSERT Code -------- --%>
<%
	// Check if an insertion is requested
		if (action != null && action.equals("insert")) {
			int flag = 0;
			String name = request.getParameter("name");
			String SKU = request.getParameter("sku");
			String price = request.getParameter("price");
			String cat = request.getParameter("cat");
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
					flag = 1;
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

<br />
ERROR: SKU already exists or price cannot be negative. Please try again.
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
<br />
Please go back and fill in all the descriptions
<br />
<br />
<%
	}
			if (flag == 1) {
				JSONObject result = new JSONObject();

				result.put("success", true);
				result.put("name", request.getParameter("name"));
				result.put("sku", request.getParameter("sku"));
				result.put("price", request.getParameter("price"));
				result.put("cat", request.getParameter("cat"));

				out.print(result);
				out.flush();
			}
		}
%>

<%-- -------- UPDATE Code -------- --%>
<%
	// Check if an update is requested
		if (action != null && action.equals("update")) {
			int psku = Integer.parseInt(request.getParameter("psku"));
			try {
				// Begin transaction
				conn.setAutoCommit(false);

				// Create the prepared statement and use it to
				// UPDATE

				Statement statement = conn.createStatement();
				rs = statement
						.executeQuery("SELECT categoryid FROM categories WHERE categoryname = '"
								+ request.getParameter("cat") + "'");
				if (!rs.next()) { //if category does not exist
					pstmt0 = conn
							.prepareStatement("INSERT INTO categories (categoryname) VALUES (?)");
					pstmt0.setString(1, request.getParameter("cat"));
					int rowCount = pstmt0.executeUpdate();
				}
				/* conn.setAutoCommit(false); */
				pstmt = conn
						.prepareStatement("UPDATE products SET productname = ?,"
								+ "productsku = ?, price = ? , category = ? WHERE productsku = ?");
				pstmt.setString(1, request.getParameter("name"));
				pstmt.setInt(2,
						Integer.parseInt(request.getParameter("sku")));
				pstmt.setDouble(3, Double.parseDouble(request
						.getParameter("price")));
				pstmt.setString(4, request.getParameter("cat"));
				pstmt.setInt(5, psku);
				int rowCount = pstmt.executeUpdate();

				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);

				JSONObject result = new JSONObject();

				result.put("success", true);

				out.print(result);
				out.flush();

			} catch (SQLException e) {
				conn = DriverManager
						.getConnection("jdbc:postgresql://localhost:1234/"
								+ db
								+ "?"
								+ "user=postgres&password=cse135");
				System.out.println("Got an SQLException: "
						+ e.getMessage());
			}
		}
%>

<%-- -------- DELETE Code -------- --%>
<%
	// Check if a delete is requested
		if (action != null && action.equals("delete")) {
			int psku = Integer.parseInt(request.getParameter("psku"));

			// Begin transaction
			conn.setAutoCommit(false);

			// Create the prepared statement and use it to
			// DELETE students FROM the products table.
			pstmt = conn
					.prepareStatement("DELETE FROM products WHERE productsku = ?");

			pstmt.setInt(1, psku);
			int rowCount = pstmt.executeUpdate();

			// Commit transaction
			conn.commit();
			conn.setAutoCommit(true);

			JSONObject result = new JSONObject();

			result.put("success", true);

			out.print(result);
			out.flush();
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