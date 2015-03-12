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
    <title>search_for_users.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>Search for Users</h1>
<a href="display_profile.jsp">Back to your profile.</a><br/>

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

	// get all users' usernames in the database
	ResultSet rset = stmt.executeQuery("SELECT DISTINCT u.username FROM Users u ORDER BY u.username ASC");
	Vector<String> userUsername = new Vector<String>();
	while (rset.next() == true) {
		userUsername.add(rset.getString("username"));
	}
	// get all users' first names in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userFirstName FROM Users u ORDER BY u.userFirstName ASC");
	Vector<String> userFirstName = new Vector<String>();
	while (rset.next() == true) {
		userFirstName.add(rset.getString("userFirstName"));
	}
	// get all users' last names in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userLastName FROM Users u ORDER BY u.userLastName ASC");
	Vector<String> userLastName = new Vector<String>();
	while (rset.next() == true) {
		userLastName.add(rset.getString("userLastName"));
	}
	// get all users' states in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userAddrState FROM Users u ORDER BY u.userAddrState ASC");
	Vector<String> userState = new Vector<String>();
	while (rset.next() == true) {
		userState.add(rset.getString("userAddrState"));
	}
	// get all users' citys in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userAddrCity FROM Users u ORDER BY u.userAddrCity ASC");
	Vector<String> userCity = new Vector<String>();
	while (rset.next() == true) {
		userCity.add(rset.getString("userAddrCity"));
	}
	// get all users' street in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userAddrStreet FROM Users u ORDER BY u.userAddrStreet ASC");
	Vector<String> userStreet = new Vector<String>();
	while (rset.next() == true) {
		userStreet.add(rset.getString("userAddrStreet"));
	}
	// get all users' phone #'s in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userPhone FROM Users u ORDER BY u.userPhone DESC");
	Vector<String> userPhone = new Vector<String>();
	while (rset.next() == true) {
		userPhone.add(rset.getString("userPhone"));
	}
	// get all users' emails in the database
	rset = stmt.executeQuery("SELECT DISTINCT u.userEmail FROM Users u ORDER BY u.userEmail ASC");
	Vector<String> userEmail = new Vector<String>();
	while (rset.next() == true) {
		userEmail.add(rset.getString("userEmail"));
	}
%>
<form action="search_for_users.jsp" method="post">
	Order results by:<br/>
	&nbsp;&nbsp;Username <input type="radio" name="orderByCriteria" value="username" checked/>
	&nbsp;&nbsp;First Name <input type="radio" name="orderByCriteria" value="userFirstName"/>
	&nbsp;&nbsp;Last Name <input type="radio" name="orderByCriteria" value="userLastName"/>
	&nbsp;&nbsp;State <input type="radio" name="orderByCriteria" value="userAddrState"/>
	&nbsp;&nbsp;City <input type="radio" name="orderByCriteria" value="userAddrCity"/>
	&nbsp;&nbsp;Street <input type="radio" name="orderByCriteria" value="userAddrStreet"/>
	&nbsp;&nbsp;Phone # <input type="radio" name="orderByCriteria" value="userPhone"/>
	&nbsp;&nbsp;E-mail <input type="radio" name="orderByCriteria" value="userEmail"/>
	<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;Ascending <input type="radio" name="orderBySort" value="ASC" checked/>
	&nbsp;&nbsp;&nbsp;&nbsp;Descending <input type="radio" name="orderBySort" value="DESC"/>
	<br/>
	<br/>
	SHOW USERS THAT HAVE...<br/>
	Username: <input type="text" name="searchUsername"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedUsername">
		<option value="" selected>Usernames</option>
		<%for(int i = 0; i < userUsername.size(); i++) {
			out.println("<option value=\"" + userUsername.elementAt(i) + "\">" + userUsername.elementAt(i) + "</option>");
		}%>
	</select><br/>
	First Name: <input type="text" name="searchFirstName"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedFirstName">
		<option value="" selected>First Names</option>
		<%for(int i = 0; i < userFirstName.size(); i++) {
			out.println("<option value=\"" + userFirstName.elementAt(i) + "\">" + userFirstName.elementAt(i) + "</option>");
		}%>
	</select><br/>
	Last Name: <input type="text" name="searchLastName"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedLastName">
		<option value="" selected>Last Names</option>
		<%for(int i = 0; i < userLastName.size(); i++) {
			out.println("<option value=\"" + userLastName.elementAt(i) + "\">" + userLastName.elementAt(i) + "</option>");
		}%>
	</select><br/>
	State: <input type="text" name="searchState"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedState">
		<option value="" selected>States</option>
		<%for(int i = 0; i < userState.size(); i++) {
			out.println("<option value=\"" + userState.elementAt(i) + "\">" + userState.elementAt(i) + "</option>");
		}%>
	</select><br/>
	City: <input type="text" name="searchCity"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedCity">
		<option value="" selected>Cities</option>
		<%for(int i = 0; i < userCity.size(); i++) {
			out.println("<option value=\"" + userCity.elementAt(i) + "\">" + userCity.elementAt(i) + "</option>");
		}%>
	</select><br/>
	Street: <input type="text" name="searchStreet"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedStreet">
		<option value="" selected>Streets</option>
		<%for(int i = 0; i < userStreet.size(); i++) {
			out.println("<option value=\"" + userStreet.elementAt(i) + "\">" + userStreet.elementAt(i) + "</option>");
		}%>
	</select><br/>
	Phone #: <input type="text" name="searchPhone"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedPhone">
		<option value="" selected>Phone #'s</option>
		<%for(int i = 0; i < userPhone.size(); i++) {
			out.println("<option value=\"" + userPhone.elementAt(i) + "\">" + userPhone.elementAt(i) + "</option>");
		}%>
	</select><br/>
	E-mail: <input type="text" name="searchEmail"/><br/>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<select name="selectedEmail">
		<option value="" selected>E-mails</option>
		<%for(int i = 0; i < userEmail.size(); i++) {
			out.println("<option value=\"" + userEmail.elementAt(i) + "\">" + userEmail.elementAt(i) + "</option>");
		}%>
	</select><br/>
	<br/>
	<br/>
	<input type="submit" name="searchUserCriteriaSubmit" value="Search among all users"/>
</form>
<%
	if (request.getParameter("searchUserCriteriaSubmit") == null) {
		/* first load of page */
		out.println("<br/>Search for users on this page<br/>");
	} else {
		// filter according to user's criteria
		// gather search criteria from user input
		// the <select> boxes take priority over the text fields
		String searchUsername = request.getParameter("selectedUsername");
		String searchFirstName = request.getParameter("selectedFirstName");
		String searchLastName = request.getParameter("selectedLastName");
		String searchState = request.getParameter("selectedState");
		String searchCity = request.getParameter("selectedCity");
		String searchStreet = request.getParameter("selectedStreet");
		String searchPhone = request.getParameter("selectedPhone");
		String searchEmail = request.getParameter("selectedEmail");
		if (searchUsername.length() == 0)
			searchUsername = request.getParameter("searchUsername").trim();
		if (searchFirstName.length() == 0)
			searchFirstName = request.getParameter("searchFirstName").trim();
		if (searchLastName.length() == 0)
			searchLastName = request.getParameter("searchLastName").trim();
		if (searchState.length() == 0)
			searchState = request.getParameter("searchState").trim();
		if (searchCity.length() == 0)
			searchCity = request.getParameter("searchCity").trim();
		if (searchStreet.length() == 0)
			searchStreet = request.getParameter("searchStreet").trim();
		if (searchPhone.length() == 0)
			searchPhone = request.getParameter("searchPhone").trim();
		if (searchEmail.length() == 0)
			searchEmail = request.getParameter("searchEmail").trim();
		
		/* build the conditional search criteria as SQL */
		String where_clauses = new String();
		if (searchUsername.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.username = '" + searchUsername + "'"; 
		}
		if (searchFirstName.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userFirstName = '" + searchFirstName + "'"; 
		}
		if (searchLastName.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userLastName = '" + searchLastName + "'"; 
		}
		if (searchState.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userAddrState = '" + searchState + "'"; 
		}
		if (searchCity.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userAddrCity = '" + searchCity + "'"; 
		}
		if (searchStreet.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userAddrStreet = '" + searchStreet + "'"; 
		}
		if (searchPhone.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userPhone = '" + searchPhone + "'"; 
		}
		if (searchEmail.length() > 0) {
			if (where_clauses.length() > 0)
				where_clauses += " AND ";
	
			where_clauses += "u.userEmail = '" + searchEmail + "'"; 
		}
		
		// if no search criteria was specified, we'll list all the users
		if (where_clauses.length() == 0)
			where_clauses = "WHERE p.userID = u.userID";
		else
			where_clauses = "WHERE p.userID = u.userID AND " + where_clauses;
		
		/* assemble the entire query */
		String query =
			"SELECT u.userID, u.username, u.userFirstName, u.userLastName, u.userAddrState, u.userAddrCity, u.userAddrStreet, u.userPhone, u.userEmail " +
			"FROM Profile p, Users u ";
		
		query += where_clauses;
		query += " ORDER BY u." + request.getParameter("orderByCriteria") + " " + request.getParameter("orderBySort");
		
		out.println("DEBUG: executing query: <br/>&nbsp;&nbsp;" + query + "<br/><br/>");
		
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
					<td>Username</td>
					<td>First Name</td>
					<td>Last Name</td>
					<td>Location</td>
					<td>Phone #</td>
					<td>E-mail Address</td>
				</tr>
<%
			do {
				out.println("<tr>");
				out.println("<td><input type=\"radio\" name=\"userProfileID\" value=\""+rset.getInt("userID")+"\" />"+"</td>");
				out.println("<td>" + rset.getString("username")+"</td>");
				out.println("<td>" + (rset.getString("userFirstName") != null ? rset.getString("userFirstName") : "-") + "</td>");
				out.println("<td>" + (rset.getString("userLastName") != null ? rset.getString("userLastName") : "-") + "</td>");
				out.println("<td>" + (rset.getString("userAddrState") != null ? rset.getString("userAddrState") + ", " : "") 
					+ (rset.getString("userAddrCity") != null ? rset.getString("userAddrCity") + ", " : "") 
					+ (rset.getString("userAddrStreet") != null ? rset.getString("userAddrStreet") : "") 
					+ "</td>");
				out.println("<td>" + (rset.getString("userPhone") != null ? rset.getString("userPhone") : "-") + "</td>");
				out.println("<td>" + (rset.getString("userEmail") != null ? rset.getString("userEmail") : "-") + "</td>");
				out.println("</tr>");
			} while(rset.next() == true);
			%>
			</table>
			</form>
			<%
			
		} else {
			out.println("No users matched your criteria!<br/>");
		}	
	}
} catch (SQLException e) {
	out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");

	for(StackTraceElement es : e.getStackTrace())
		out.println(es + "<br/>");

	out.println("SQLstate is " + e.getSQLState() + "<br/>");

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
%>
</body>
</html>

