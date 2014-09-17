<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Sales Analytics</title>
</head>
<body>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*"%>

	<%
		String db = (String) session.getAttribute("dbType");
		if(db==null){
			db = "postgres";
		}
		String switchDB = request.getParameter("switchDB");
		String dbType = request.getParameter("dbType");
		if("changeDB".equals(switchDB)){
			if("performance".equals(dbType)){
				session.setAttribute("dbType","performance");
				db = "performance";
			}
			else{
				//small database, for demos
				session.setAttribute("dbType","postgres");
				db = "postgres";
			}
		}
	%>
	<%-- -------- Open Connection Code -------- --%>
	<%
		String currentUser = (String) session.getAttribute("currentUserName");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			// Registering Postgresql JDBC driver with the DriverManager
			Class.forName("org.postgresql.Driver");

			/*
			// Open a connection to the database using DriverManager
			conn = DriverManager
					.getConnection("jdbc:postgresql://localhost:1234/postgres?"
							+ "user=postgres&password=cse135");
			*/
			conn = DriverManager
			.getConnection("jdbc:postgresql://localhost:1234/" + db + "?"
					+ "user=postgres&password=cse135");
	%>
	Hello 
	<%=currentUser%><br /><br />
	<%
		String usertype = (String) session.getAttribute("usertype");
		if("customer".equals(usertype)){
			%>
			<a href="buyShoppingCart.jsp">Shopping Cart</a>
			<br/>
			<%
		}
		String sortby = request.getParameter("sortby");
		if(sortby!=null){
	%>
	
	Currently sorting by <%=sortby%> <br/>
	<%}%>
	
		<form action="salesAnalyticsPage.jsp" method="post">
		<select name="dbType">
			<option value="demo">Demo</option>
			<option value="performance">Performance</option>
		</select>
		<input type="hidden" name="switchDB" value="changeDB"/>
		<input type="submit" value="switch database"/>
	</form>
	<%
	int colPage = 0;
	int rowPage = 0;
	String temp;
	if( (temp = request.getParameter("colPage"))!=null){
		colPage = Integer.parseInt(temp);
	}
	if( (temp = request.getParameter("rowPage"))!=null){
		rowPage = Integer.parseInt(temp);
	}
	int pageLimit = 10;
	String customerAge = request.getParameter("customerAge");
	String customerState = request.getParameter("customerState");
	String productCategory = request.getParameter("productCategory");
	String quarter = request.getParameter("quarter");
	if(sortby!=null){ 
	%>
	
		<%-- -------- SELECT Statement Code -------- --%>
		<%
			
			String filter = "1=1 ";
				if(productCategory!=null && !"allCategories".equals(productCategory)){
					filter += "AND p.category='"+productCategory+"'";
				}
				// Create the statement
				Statement statement = conn.createStatement();
				rs = statement.executeQuery("SELECT DISTINCT SUM(o.quantity), p.productname FROM products p LEFT JOIN orders o ON p.productname = o.productname WHERE " + filter + " GROUP BY p.productname ORDER BY SUM(o.quantity) DESC NULLS LAST OFFSET " + (colPage*pageLimit) + " FETCH NEXT " + pageLimit + " ROWS ONLY");
				ArrayList<String> productNames = new ArrayList<String>();
				
				//filter = "1=1 ";
				if( !"null".equals(customerAge) && !"allAges".equals(customerAge)){
					filter += "AND u.userage>="+customerAge + " AND u.userage<="+(Integer.parseInt(customerAge)+9) + " ";
				}
				if(!"null".equals(customerState) && !"allStates".equals(customerState)){
					filter += "AND u.userstate='"+customerState+"' ";
				}
				if(!"null".equals(quarter) && !"fullyear".equals(quarter)){
					int season=0;
					System.out.println("quarter: " + quarter);
					if("winter".equals(quarter)){
						season=0;
					} else if("spring".equals(quarter)){
						season=1;
					} else if("summer".equals(quarter)){
						season=2;
					} else if("fall".equals(quarter)){
						season=3;
					}
					filter += "AND o.season="+season;
				}
		%>
		<table border="1" width="200">
		<tr>
			<th><%=sortby %></th>
			<%
				// Iterate over the ResultSet
				while (rs.next()) {
					String theProduct = rs.getString("productname");
					productNames.add(theProduct);
			%>
			<th><%=theProduct %> </th>
			<%} %>
			<th>Total Revenue</th>
		</tr>

		<%
				System.out.println("filter: " + filter);
		
				if(filter.length()=="1=1 ".length()){
					//customers
					if("Customers".equals(sortby)){
						rs = statement.executeQuery("SELECT u.username, u.totalspent AS total FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname WHERE usertype='customer' AND " + filter + " GROUP BY u.username, u.totalspent ORDER BY u.totalspent DESC NULLS LAST OFFSET "+(rowPage*pageLimit) + " FETCH NEXT " + pageLimit + " ROWS ONLY");
					}
					//states
					else{
						rs = statement.executeQuery("SELECT u.userstate, s.statetotal AS total FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname LEFT JOIN states s ON u.userstate=s.statename WHERE u.usertype='customer' AND " + filter + " GROUP BY u.userstate,s.statetotal ORDER BY u.userstate OFFSET "+ (rowPage*pageLimit) + " FETCH NEXT " + pageLimit + " ROWS ONLY");
					}
				}
				else{
					//customers
					if("Customers".equals(sortby)){
						rs = statement.executeQuery("SELECT u.username, sum(p.price*o.quantity) AS total FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname WHERE usertype='customer' AND " + filter + " GROUP BY u.username, u.totalspent ORDER BY u.totalspent DESC NULLS LAST OFFSET "+(rowPage*pageLimit) + " FETCH NEXT " + pageLimit + " ROWS ONLY");
					}
					//states
					else{
						rs = statement.executeQuery("SELECT u.userstate, sum(p.price*o.quantity) AS total FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname LEFT JOIN states s ON u.userstate=s.statename WHERE u.usertype='customer' AND " + filter + " GROUP BY u.userstate,s.statetotal ORDER BY u.userstate OFFSET "+ (rowPage*pageLimit) + " FETCH NEXT " + pageLimit + " ROWS ONLY");
					}
				}
				
				ResultSet quantities;
				Statement s = conn.createStatement();
		
				// Iterate over the ResultSet
				//for every customer or state, list it as the first column of a row. Then each following column is how many of a product was bought by the customer or state.
				while (rs.next()) {
					String theCustomer=null;
					String theState=null;
					if("Customers".equals(sortby)){
						theCustomer = rs.getString("username");
						%>
						<tr><td><%=theCustomer%></td>
						<%
					}
					else{
						theState = rs.getString("userstate");
						%>
						<tr><td><%=theState%></td>
						<%
					}
					
					for(int index = 0; index<productNames.size(); index++){
						String theProduct = productNames.get(index);
						if("Customers".equals(sortby)){
							quantities = s.executeQuery("SELECT SUM(o.quantity) AS result FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname WHERE o.username='"+theCustomer+"' AND o.productname='" + theProduct+"' AND " + filter);
						}
						else{
							quantities = s.executeQuery("SELECT SUM(o.quantity) AS result FROM users u LEFT JOIN orders o ON u.username=o.username LEFT JOIN products p ON o.productname=p.productname WHERE o.username = u.username AND u.userstate = '" + theState +"' AND o.productname='"+theProduct + "' AND " + filter);

						}
						while(quantities.next()){
							System.out.println("quantities.getInt(result): " + quantities.getInt("result"));
		%>
		<td>
		<%=quantities.getInt("result") %>
		</td>
		<%
					}
				}
					%>
					<td>$<%=rs.getInt("total") %></td>
					</tr>
					<%
		} 
		%>
	<%} %>
	

	
	<form action="salesAnalyticsPage.jsp" method="post">
		<label>Sort by</label>
		<select name="sortby">
			<option value="Customers">Customers</option>
			<option value="States">States</option>
		</select>
	<br/><br/>
	Filter Options:
	<br/>
	<%-- The values of the select options for the ages refer to the lower bound of the age selected--%>
	<label>Age Group:</label>
	<select name="customerAge">
		<option value="allAges" selected>All Ages</option>
		<option value="0">0-9</option>
		<option value="10">10-19</option>
		<option value="20">20-29</option>
		<option value="30">30-39</option>
		<option value="40">40-49</option>
		<option value="50">50-59</option>
		<option value="60">60-69</option>
		<option value="70">70-79</option>
		<option value="80">80-89</option>
		<option value="90">90-99</option>
	</select>
	
	<label>State: </label>
	<select name="customerState">
		<option value="allStates" selected>All States</option>
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
	
	<label>Category: </label>
	<select name="productCategory">
	<option value="allCategories" selected>All Categories</option>
	<%
		// Create the statement
		Statement statement = conn.createStatement();
		rs = statement.executeQuery("SELECT categoryname FROM categories");
		while (rs.next()) {
			%>
			<option value="<%=rs.getString("categoryname")%>"><%=rs.getString("categoryname")%></option>
			<%
		}
	%>
	</select>
	
	
		<label>Quarter: </label>
		<select name="quarter">
			<option value="fullyear" selected>Full Year</option>
			<option value="winter">Winter</option>
			<option value="spring">Spring</option>
			<option value="summer">Summer</option>
			<option value="fall">Fall</option>
		</select>
		<input type="hidden" name="action" value="select"/>
		<%-- <input type="hidden" name="sortby" value="<%=request.getParameter("sortby")%>"/> --%>
		<input type="submit" value="Run Query" />
	</form>
	
	<br/>
	
	<form action="salesAnalyticsPage.jsp" method="post">
		<input type="hidden" name="rowPage" value= "<%=Integer.toString(rowPage) %>" />
		<input type="hidden" name="colPage" value= "<%=Integer.toString(colPage+1) %>" />
		
		<input type="hidden" name="customerAge" value="<%=customerAge %>" />
		<input type="hidden" name="customerState" value="<%=customerState %>" />
		<input type="hidden" name="productCategory" value="<%=productCategory %>" />
		<input type="hidden" name="quarter" value="<%=quarter %>" />
		
		<input type="hidden" name="sortby" value= "<%=sortby %>" />
		<input type="submit" value="Next 10 Columns"/>
	</form>
	
	<form action="salesAnalyticsPage.jsp" method="post">
		<input type="hidden" name="rowPage" value= "<%=Integer.toString(rowPage+1) %>" />
		<input type="hidden" name="colPage" value= "<%=Integer.toString(colPage) %>" />
		
		<input type="hidden" name="customerAge" value="<%=customerAge %>" />
		<input type="hidden" name="customerState" value="<%=customerState %>" />
		<input type="hidden" name="productCategory" value="<%=productCategory %>" />
		<input type="hidden" name="quarter" value="<%=quarter %>" />
		
		<input type="hidden" name="sortby" value= "<%=sortby %>" />
		<input type="submit" value="Next 10 Rows"/>
	</form>
	
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