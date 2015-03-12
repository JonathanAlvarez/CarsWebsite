<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.ResultSetMetaData" %>
<%@ page import="java.util.Properties" %>
<%@ page import="com.mysql.jdbc.Driver" %>
<%@ page import="net.cs336proj.web.*" %>

<%@ page import="java.util.Vector" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>search_for_cars.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>Search for Cars</h1>
<a href="display_profile.jsp">Back to your profile/hub</a><br/>

<%
SessionInfo userInfo = (SessionInfo)session.getValue("info");
Connection conn = null;
Statement stmt = null;

try {
	String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
	conn=null;
	Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
	Properties result = driver.parseURL(connectionURL, new Properties());
	
	// i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful)
	out.println("Connection Information: " + result + "<br/><br/><br/>");
	
	conn = DriverManager.getConnection(connectionURL, result);
	stmt = conn.createStatement();

	// get all car manufacturers in the database
	ResultSet rset = stmt.executeQuery("SELECT DISTINCT c.carMake FROM Car c ORDER BY c.carMake ASC");
	Vector<String> carManufacturers = new Vector<String>();
	while (rset.next() == true) {
		carManufacturers.add(rset.getString("carMake"));
	}
	// get all car models in the database
	rset = stmt.executeQuery("SELECT DISTINCT c.carModel FROM Car c ORDER BY c.carModel ASC");
	Vector<String> carModels = new Vector<String>();
	while (rset.next() == true) {
		carModels.add(rset.getString("carModel"));
	}
	// get all engine types in the database
	rset = stmt.executeQuery("SELECT DISTINCT c.carEngine FROM Car c ORDER BY c.carEngine ASC");
	Vector<String> carEngines = new Vector<String>();
	while (rset.next() == true) {
		carEngines.add(rset.getString("carEngine"));
	}
	// get all car colors in the database
	rset = stmt.executeQuery("SELECT DISTINCT c.carColor FROM Car c ORDER BY c.carColor ASC");
	Vector<String> carColors = new Vector<String>();
	while (rset.next() == true) {
		carColors.add(rset.getString("carColor"));
	}
	// get all car years in the database
	rset = stmt.executeQuery("SELECT DISTINCT c.carYear FROM Car c ORDER BY c.carYear DESC");
	Vector<String> carYears = new Vector<String>();
	while (rset.next() == true) {
		carYears.add(rset.getString("carYear"));
	}
	// get all car-types in the database
	rset = stmt.executeQuery("SELECT DISTINCT c.carType FROM Car c ORDER BY c.carType ASC");
	Vector<String> carTypes = new Vector<String>();
	while (rset.next() == true) {
		carTypes.add(rset.getString("carType"));
	}
%>
<form action="search_for_cars.jsp" method="post">
	Order results by:<br/>
	&nbsp;&nbsp;Manufacturer <input type="radio" name="orderByCriteria" value="carMake" checked/>
	&nbsp;&nbsp;Model <input type="radio" name="orderByCriteria" value="carModel"/>
	&nbsp;&nbsp;Type <input type="radio" name="orderByCriteria" value="carType"/>
	&nbsp;&nbsp;Year <input type="radio" name="orderByCriteria" value="carYear"/>
	&nbsp;&nbsp;Engine <input type="radio" name="orderByCriteria" value="carEngine"/>
	&nbsp;&nbsp;Color <input type="radio" name="orderByCriteria" value="carColor"/>
	<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;Ascending <input type="radio" name="orderBySort" value="ASC" checked/>
	&nbsp;&nbsp;&nbsp;&nbsp;Descending <input type="radio" name="orderBySort" value="DESC"/>
	<br/>
	<br/>
	SHOW CARS THAT HAVE...<br/>
	Manufacturer: <input type="text" name="searchCarMake"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedMake">
		<option value="" selected>Makes</option>
		<%for(int i = 0; i < carManufacturers.size(); i++) {
			out.println("<option value=\""+carManufacturers.elementAt(i)+"\">"+carManufacturers.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Model Name: <input type="text" name="searchCarModel"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedModel">
		<option value="" selected>Models</option>
		<%for(int i = 0; i < carModels.size(); i++) {
			out.println("<option value=\""+carModels.elementAt(i)+"\">"+carModels.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Car type/form: <input type="text" name="searchCarType"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedType">
		<option value="" selected>Types</option>
		<%for(int i = 0; i < carTypes.size(); i++) {
			out.println("<option value=\""+carTypes.elementAt(i)+"\">"+carTypes.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Year: <input type="text" name="searchCarYear"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedYear">
		<option value="" selected>Years</option>
		<%for(int i = 0; i < carYears.size(); i++) {
			out.println("<option value=\""+carYears.elementAt(i)+"\">"+carYears.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Engine: <input type="text" name="searchCarEngine"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedEngine">
		<option value="" selected>Engines</option>
		<%for(int i = 0; i < carEngines.size(); i++) {
			out.println("<option value=\""+carEngines.elementAt(i)+"\">"+carEngines.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Color: <input type="text" name="searchCarColor"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedColor">
		<option value="" selected>Colors</option>
		<%for(int i = 0; i < carColors.size(); i++) {
			out.println("<option value=\""+carColors.elementAt(i)+"\">"+carColors.elementAt(i)+"</option>");
		}%>
	</select><br/>
	Custom modifications: <input type="text" name="searchCarMods"/><br/>
	<br/>
	<br/>
	Search by Car owner's Info:<br/>
	in state: <input type="text" name="searchUserState"/><br/>
	in city: <input type="text" name="searchUserCity"/><br/>
	by username: <input type="text" name="searchUserName"/><br/>
	<br/>
	<br/>
	<input type="submit" name="searchCarCriteriaSubmit" value="search among all cars"/>
</form>
<%

if (request.getParameter("searchCarCriteriaSubmit") == null) {
	/* first load of page */
	out.println("<br/>Search for cars on this page<br/>");
} else {
	/* filter according to user's criteria */
	
	/* gather search criteria from user input */
	String searchMods = request.getParameter("searchCarMods").trim();
	// the <select> boxes take priority over the text fields
	String searchMake = request.getParameter("selectedMake");
	String searchModel = request.getParameter("selectedModel");
	String searchType = request.getParameter("selectedType");
	String searchYear = request.getParameter("selectedYear");
	String searchEngine = request.getParameter("selectedEngine");
	String searchColor = request.getParameter("selectedColor");
	if (searchMake.length() == 0)
		searchMake = request.getParameter("searchCarMake").trim();
	if (searchModel.length() == 0)
		searchModel = request.getParameter("searchCarModel").trim();
	if (searchType.length() == 0)
		searchType = request.getParameter("searchCarType").trim();
	if (searchYear.length() == 0)
		searchYear = request.getParameter("searchCarYear").trim();
	if (searchEngine.length() == 0)
		searchEngine = request.getParameter("searchCarEngine").trim();
	if (searchColor.length() == 0)
		searchColor = request.getParameter("searchCarColor").trim();
	
	String searchUserState = request.getParameter("searchUserState").trim();
	String searchUserCity = request.getParameter("searchUserCity").trim();
	String searchUserName = request.getParameter("searchUserName").trim();
	
	/* build the conditional search criteria as SQL */
	String where_clauses = new String();
	if (searchMods.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carModifications LIKE '%"+searchMods+"%'"; 
	}
	if (searchMake.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carMake = '"+searchMake+"'"; 
	}
	if (searchModel.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carModel = '"+searchModel+"'";
	}
	if (searchType.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carType = '"+searchType+"'";
	}
	if (searchYear.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carYear = '"+searchYear+"'";
	}
	if (searchEngine.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carEngine = '"+searchEngine+"'";
	}
	if (searchColor.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";

		where_clauses += "c.carColor = '"+searchColor+"'";
	}
	
	if (searchUserState.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
	
		where_clauses += "u.userAddrState = '"+searchUserState+"'";
	}
	if (searchUserCity.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
	
		where_clauses += "u.userAddrCity = '"+searchUserCity+"'";
	}
	if (searchUserName.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
		
		where_clauses += "u.username = '"+searchUserName+"'";
	}
	
	
	// if no search criteria was specified, we'll list all the cars
	if (where_clauses.length() == 0)
		where_clauses = "WHERE c.carID = hc.carID AND hc.pID = p.pID AND p.userID = u.userID";
	else
		where_clauses = "WHERE c.carID = hc.carID AND hc.pID = p.pID AND p.userID = u.userID AND "+where_clauses;
	
	/* assemble the entire query */
	String query =
		"SELECT u.userID, u.username, u.userAddrState, u.userAddrCity, c.carID, c.carMake, c.carModel, c.carType, c.carColor, c.carYear, c.carEngine, c.carModifications "+
		"FROM Car c, hasCar hc, Profile p, Users u ";
	query += where_clauses+" ";
	query += "ORDER BY c."+request.getParameter("orderByCriteria")+" "+request.getParameter("orderBySort");
	
	out.println("DEBUG: executing query: <br/>&nbsp;&nbsp;"+query+"<br/><br/>");
	
	rset = stmt.executeQuery(query);
	
	/* print out the results */
	if (rset.next() == true) {
		%>
		<form action="display_profile.jsp" method="post">
		<input type="submit" name="viewUserProfileSubmit" value="View selected user's profile"/><br/>
		<br/>
		<table border=1 cellpadding="10">
			<tr>
				<td>View User's Profile</td>
				<td>User</td>
				<td>Location</td>
				<td>Make</td>
				<td>Model</td>
				<td>Type</td>
				<td>Color</td>
				<td>Year</td>
				<td>Engine</td>
				<td>Mods</td>
			</tr>
		<%
		do {
			out.println("<tr>");
			out.println("<td><input type=\"radio\" name=\"userProfileID\" value=\""+rset.getInt("userID")+"\" />"+"</td>");
			out.println("<td>"+rset.getString("username")+"</td>");
			out.println("<td>"+(rset.getString("userAddrCity") != null ? rset.getString("userAddrCity") +", " : "")+ (rset.getString("userAddrState") != null ? rset.getString("userAddrState") : "")+"</td>");
			out.println("<td>"+(rset.getString("carMake") != null ? rset.getString("carMake") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carModel") != null ? rset.getString("carModel") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carType") != null ? rset.getString("carType") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carColor") != null ? rset.getString("carColor") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carYear") != null ? rset.getString("carYear") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carEngine") != null ? rset.getString("carEngine") : "-")+"</td>");
			out.println("<td>"+(rset.getString("carModifications") != null ? rset.getString("carModifications") : "-")+"</td>");
			out.println("</tr>");
		} while(rset.next() == true);
		%>
		</table>
		</form>
		<%
		
	} else {
		out.println("no cars matched your criteria!<br/>");
	}	
}

}
catch (SQLException e) {
	out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");

	for(StackTraceElement es : e.getStackTrace())
		out.println(es + "<br/>");

	out.println("SQLstate is   " + e.getSQLState() + "<br/>");

	if(stmt != null && !stmt.isClosed())
		stmt.close();
	if(conn != null && !conn.isClosed())
		conn.close();
}
finally {
	stmt.close();
	if(conn != null)
		conn.close();	
}
/*
try {
	String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
	conn=null;
	Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
	Properties result = driver.parseURL(connectionURL, new Properties());
	
	// i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful)
	out.println("Connection Information: " + result + "<br/><br/><br/>");
	
	conn = DriverManager.getConnection(connectionURL, result);
	stmt = conn.createStatement();

}
catch (SQLException e) {
	out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");

	for(StackTraceElement es : e.getStackTrace())
		out.println(es + "<br/>");

	out.println("SQLstate is   " + e.getSQLState() + "<br/>");

	if(stmt != null && !stmt.isClosed())
		stmt.close();
	if(conn != null && !conn.isClosed())
		conn.close();
}
finally {
	stmt.close();
	if(conn != null)
		conn.close();	
}
*/

%>
</body>
</html>
