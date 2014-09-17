<%@ page import="java.sql.*"%>
	<%-- -------- Open Connection Code -------- --%>
	<%
	
	final String[] STATES = { "AK", "AL",  "AR", "AZ", "CA",
		"CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN",  
		"KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT",
		"NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR",
		"PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", 
		"WV", "WY" };
	
	int row = Integer.parseInt(request.getParameter("row"));
	int col = Integer.parseInt(request.getParameter("col"));
	
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
//Create the statement
Statement statement = conn.createStatement();
rs = statement.executeQuery("SELECT categoryname FROM categories ORDER BY categoryname");
int theRow = 0;
while(rs.next()){
	if(theRow!=row){
		theRow++;
		continue;
	}
	Statement ss = conn.createStatement();
	String theCategory = rs.getString("categoryname");
	ResultSet quantities = ss.executeQuery("SELECT sum(o.quantity) AS quantity FROM orders o LEFT JOIN users u ON o.username = u.username " +
				"LEFT JOIN products p ON o.productname = p.productname WHERE u.userstate = '"+ STATES[col] + "' AND p.category = '" + theCategory + "'"
				+ "GROUP BY u.userstate");
	
	String quantity = "0";
	if(quantities.next()){
			quantity = quantities.getString("quantity");
	}
	%>
	<%=quantity%>
	<%
	break;
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