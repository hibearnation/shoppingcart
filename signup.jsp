<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Sign Up!</title>

<script type='text/javascript' src='http://code.jquery.com/jquery-1.5.2.js'></script>
<script type='text/javascript'>//<![CDATA[
$(document).ready(function() {
	$('#customerBoxes').hide();
    
     $('#usertype').change(function () {
        if ($('#usertype option:selected').text() == "Customer"){
        	$('#ownerButton').hide();
        	$('#customerBoxes').show();
        }
         else {
        	 $('#ownerButton').show();
        	 $('#customerBoxes').hide();
         }
    });

});
//]]>
</script>

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
	 
<form action="signup.jsp" method="post">

	<label>Username:</label>
	<input name="username" value="" />

	<label>Role:</label>
	<select name="usertype" id="usertype">
		<option value="owner">Owner</option>
		<option value="customer">Customer</option>
	</select>

<div id="customerBoxes">
		<label>Age: </label>
		<input name="userage" value=""/>
	
	<label>State:</label>
	<select name="userstate">
		<option value="AL">Alabama</option>
		<option value="AK">Alaska</option>
		<option value="AZ">Arizona</option>
		<option value="AR">Arkansas</option>
		<option value="CA">California</option>
		<option value="CO">Colorado</option>
		<option value="CT">Connecticut</option>
		<option value="DE">Delaware</option>
		<option value="DC">District of Columbia</option>
		<option value="FL">Florida</option>
		<option value="GA">Georgia</option>
		<option value="HI">Hawaii</option>
		<option value="ID">Idaho</option>
		<option value="IL">Illinois</option>
		<option value="IN">Indiana</option>
		<option value="IA">Iowa</option>
		<option value="KS">Kansas</option>
		<option value="KY">Kentucky</option>
		<option value="LA">Louisiana</option>
		<option value="ME">Maine</option>
		<option value="MD">Maryland</option>
		<option value="MA">Massachusetts</option>
		<option value="MI">Michigan</option>
		<option value="MN">Minnesota</option>
		<option value="MS">Mississippi</option>
		<option value="MO">Missouri</option>
		<option value="MT">Montana</option>
		<option value="NE">Nebraska</option>
		<option value="NV">Nevada</option>
		<option value="NH">New Hampshire</option>
		<option value="NJ">New Jersey</option>
		<option value="NM">New Mexico</option>
		<option value="NY">New York</option>
		<option value="NC">North Carolina</option>
		<option value="ND">North Dakota</option>
		<option value="OH">Ohio</option>
		<option value="OK">Oklahoma</option>
		<option value="OR">Oregon</option>
		<option value="PA">Pennsylvania</option>
		<option value="RI">Rhode Island</option>
		<option value="SC">South Carolina</option>
		<option value="SD">South Dakota</option>
		<option value="TN">Tennessee</option>
		<option value="TX">Texas</option>
		<option value="UT">Utah</option>
		<option value="VT">Vermont</option>
		<option value="VA">Virginia</option>
		<option value="WA">Washington</option>
		<option value="WV">West Virginia</option>
		<option value="WI">Wisconsin</option>
		<option value="WY">Wyoming</option>	
	</select>
	<input type="submit" value="Register" name="customerButton" id="customerButton"/>
	</div>

	<input type="hidden" name="action" value="insert"/>
	<input type="submit" value="Register" name="ownerButton" id="ownerButton"/>
	

</form>
	<%
		String theAction = request.getParameter("action");
		String customerButton = request.getParameter("customerButton");
		String ownerButton = request.getParameter("ownerButton");
	%>
<%-- -------- INSERT Code -------- --%>
	<%
		if (theAction != null && theAction.equals("insert")) {
					try {

						// Begin transaction
						conn.setAutoCommit(false);
						// Create the prepared statement and use it to
						// INSERT student values INTO the students table.
						String username = request.getParameter("username").trim();
						String usertype = request.getParameter("usertype");

						String person=request.getParameter("usertype") ;
						if (ownerButton!=null)
						  {
						System.out.println("i'm an owner");
						pstmt = conn
								.prepareStatement("INSERT INTO users (username,usertype) VALUES (?,?)");
						pstmt.setString(1, username);
						pstmt.setString(2, usertype);

						
						  }
						else if (customerButton!=null)
						  {
						System.out.println("i'm a customer");
						pstmt = conn
								.prepareStatement("INSERT INTO users (username,usertype,userage,userstate) VALUES (?,?,?,?)");
						pstmt.setString(1, username);
						pstmt.setString(2, usertype);
						pstmt.setInt(3, Integer.parseInt(request.getParameter("userage")));
						pstmt.setString(4, request.getParameter("userstate"));
						
						  }

						int rowCount = pstmt.executeUpdate();

						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
						
						session.setAttribute("currentUserName",username);
						session.setAttribute("usertype",usertype);
						// New location to be redirected
						String site = "categoriespage.jsp";
						response.setStatus(response.SC_MOVED_TEMPORARILY);
						response.setHeader("Location", site);
					} catch (Exception e) {
						// Open a connection to the database using DriverManager
						conn = DriverManager
			.getConnection("jdbc:postgresql://localhost:1234/" + db + "?"
					+ "user=postgres&password=cse135");
						%>
	<br/>Username already exists or age is not an integer.<br/><br/>
	<%
					}
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
</body>
</html>

