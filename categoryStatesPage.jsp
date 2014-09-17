<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Categories and States</title>
</head>
<body>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList" %>
	<%-- -------- Open Connection Code -------- --%>
	<%
	String currentUser = (String) session.getAttribute("currentUserName");
	ArrayList<String> categories = new ArrayList<String>();
	ArrayList<String> states = new ArrayList<String>();
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
	

<script type="text/javascript">
	var int=self.setInterval(
		function(){
			var row;
			var col;
			var numCategories = document.getElementById("statesCategoriesTable").rows.length-1;
			var numStates = document.getElementById("statesCategoriesTable").rows[0].cells.length-1;
			for(row=0; row<numCategories;row++){
				for(col=0; col<numStates;col++){
					updateTable(row,col);
				}
			}
		},2000);
function updateTable(row, col)
{
var xmlHttp;
xmlHttp=new XMLHttpRequest();

	var responseHandler = function(){
		  if(xmlHttp.readyState==4)
		  { 
			  document.getElementById(row+","+col).innerHTML = xmlHttp.responseText; 
		  }
	}
	var url;
	url="update.jsp";
	url=url+"?row="+row;
	url=url+"&col="+col;
	xmlHttp.onreadystatechange = responseHandler ;
  xmlHttp.open("GET",url,true);
  xmlHttp.send(null);
}
</script>

	
	
	<table border="1" id="statesCategoriesTable">
	<tr>
	<th>States vs Categories</th>
	<%
		Statement s = conn.createStatement();
		rs = s.executeQuery("SELECT statename FROM states ORDER BY statename");
		while(rs.next()){
			String statename = rs.getString("statename");
			states.add(statename);
	%>
	<th><%= statename%></th>
	<%
		}
		%>
		</tr>
	<%
		rs = s.executeQuery("SELECT categoryname FROM categories ORDER BY categoryname");
		int row = 0;
		while(rs.next()){
			String theCategory = rs.getString("categoryname");
	%>
	<tr>
	<td><%=theCategory%></td>
	<%
		Statement ss = conn.createStatement();
		//ResultSet quantities = ss.executeQuery("SELECT sum(o.quantity) FROM orders o LEFT JOIN users u ON o.username = u.username " +
		//		"GROUP BY u.userstate");
		for(int col = 0; col<states.size(); col++){
			ResultSet quantities = ss.executeQuery("SELECT sum(o.quantity) AS quantity FROM orders o LEFT JOIN users u ON o.username = u.username " +
					"LEFT JOIN products p ON o.productname = p.productname WHERE u.userstate = '"+ states.get(col) + "' AND p.category = '" + theCategory + "'"
					+ "GROUP BY u.userstate");
			if(quantities.next()){
			%>
			<td id="<%=row%>,<%=col%>"><%=quantities.getString("quantity") %></td>
			<%
			}
			else{
				%>
				<td id="<%=row%>,<%=col%>">0</td>
				<%
			}
		}
		row++;
	%>
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