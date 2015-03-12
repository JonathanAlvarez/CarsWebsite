<%@ taglib prefix="c" uri='http://java.sun.com/jsp/jstl/core' %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Properties" %>
<%@ page import="com.mysql.jdbc.Driver" %>
<%@ page import="net.cs336proj.web.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>display_profile.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
<%
SessionInfo userInfo = (SessionInfo)session.getValue("info");
out.println("'"+userInfo.username+"' (userID "+userInfo.userID+" ) has logged in successfully <br/>");

String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
Properties result = driver.parseURL(connectionURL, new Properties());
Connection conn = DriverManager.getConnection(connectionURL, result);
Statement stmt = conn.createStatement();
String userProfileID = null;
String userIDLoggedIn = null;
ResultSet rset;

if (request.getParameter("viewUserProfileSubmit") != null) {
	if (request.getParameter("userProfileID").trim().length() == 0)
		out.println("No ID was entered, displaying your profile.");
	else
		userProfileID = request.getParameter("userProfileID").trim();
}

if(userProfileID != null) {
	rset = stmt.executeQuery(
		"SELECT * FROM Users u WHERE u.userID = "
		+ userProfileID + ";");
	rset.next();
} else {
	rset = stmt.executeQuery(
		"SELECT * FROM Users u WHERE u.userID = "
		+ userInfo.userID + ";");
	rset.next();
}

%> <h1>Profile View</h1> <%
out.println("<br/>");
out.println("Username: " + rset.getString(2) + "<br/>");
out.println("First Name: " + rset.getString(4) + "<br/>");
out.println("Last Name: " + rset.getString(5) + "<br/>");
out.println("E-mail: " + rset.getString(9) + "<br/>");
out.println("Password: " + rset.getString(10) + "<br/>");
out.println("Date Joined: " + rset.getString(11) + "<br/>");
out.println("Date Last Logged In: " + rset.getString(12) + "<br/> <br/>");


if (rset.getString(3) != null) { 
	out.println("Phone Number: " + rset.getString(3) + "<br/>");
} else {
	out.println("No information entered for phone number. <br/>");	
}
if (rset.getString(6) != null) { 
	out.println("State: " + rset.getString(6) + "<br/>");
} else {
	out.println("No information entered for state address. <br/>");	
}
if (rset.getString(7) != null) { 
	out.println("City: " + rset.getString(7) + "<br/>");
} else {
	out.println("No information entered for city address. <br/>");	
}
if (rset.getString(8) != null) { 
	out.println("Address: " + rset.getString(8) + "<br/>");
} else {
	out.println("No information entered for street address. <br/><br/>");	
}

//beFriend? and Show Cars, Hobbies, and Friends
if(userProfileID != null) {
	int insertQuery = 0;
	//Send friend request
%>
	<form action="display_profile.jsp" method="post">
	<input type="hidden" name="userID_toBefriend" value="<%out.println(userProfileID);%>"/>
	<input type="submit" name="beFriend" value="Make Friend Request?" />
	</form>
<%
	if(request.getParameter("beFriend") != null) {
		insertQuery = stmt.executeUpdate(
			"INSERT INTO befriend(initiatorID, recipientID) values(" 
			+ userInfo.userID + ", " + userProfileID + ");"); //userID_toBefriend causes crash.
	out.println("EXECUTING QUERY: " + "INSERT INTO befriend(initiatorID, recipientID) values(" 
			+ userInfo.userID + ", " + userProfileID + ");");
	}
	
	//Displays Cars
	rset = stmt.executeQuery(
	"SELECT * FROM Car c, hasCar hc, Profile p WHERE p.userID = " 
	+ userProfileID + " AND p.pID = hc.pID AND c.carID = hc.carID;");
	/* print out the results */
	if (rset.next() == true) {
		%><h1>Car(s):</h1>
			<table border=1 cellpadding="10">
				<tr>
					<td>Make</td>
					<td>Model</td>
					<td>Type</td>
					<td>Color</td>
					<td>Year</td>
					<td>Engine</td>
					<td>Modifications</td>
				</tr>
<%
			do {
				out.println("<tr>");
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
<%
	}
	
	
	//Displays hobbies
	rset = stmt.executeQuery(
		"SELECT * FROM Hobby h, hasHobby hh, Profile p WHERE p.userID = " 
		+ userProfileID + " AND p.pID = hh.pID AND h.hID = hh.hID;");
	/* print out the results */
	if (rset.next() == true) {
%>
		<h1>Hobby(ies):</h1>
			<table border=1 cellpadding="10">
			<tr>
				<td>Hobby Title</td>
				<td>Hobby Text</td>
			</tr>
<%
			do {
				out.println("<tr>");
				out.println("<td>"+(rset.getString("hTitle") != null ? rset.getString("hTitle") : "-")+"</td>");
				out.println("<td>"+(rset.getString("hText") != null ? rset.getString("hText") : "-")+"</td>");
				out.println("</tr>");
			} while(rset.next() == true);
%>
			</table>
<%
	}
	
	
	//Display Friends
	String frCount_query =
		"SELECT COUNT(hf.userID) as friend_count " +
		"FROM Profile p, hasFriend hf, Users u " +
		"WHERE p.userID = " + userProfileID +
			" AND p.pID = hf.pID" +
			" AND hf.userID = u.userID;";
	// get count of friends
	ResultSet fr_rset = stmt.executeQuery(frCount_query);
	if (fr_rset.next() == true && fr_rset.getInt("friend_count") > 0) {
		// get some basic info about friends.
		String query =
			"SELECT u.username, u.userFirstname, u.userLastName, u.userDateJoined, u.userDateLastLogin"+
				", u.userAddrState, u.userAddrCity" +
				", hf.frDateBefriended, hf.userID as friendUserID " +
			"FROM Profile p, hasFriend hf, Users u " +
			"WHERE p.userID = " + userProfileID +
				" AND p.pID = hf.pID" +
				" AND hf.userID = u.userID;";
		
		fr_rset = stmt.executeQuery(query);
		if (fr_rset.next() == true) {
			%><h1>Friend(s):</h1>
				<br/>
				<table border=1 cellpadding="10">
					<tr>
						<td>Username</td>
						<td>Name</td>
						<td>Location</td>
						<td>Date befriended</td>
						<td>Date of Last Login</td>
						<td>Date joined</td>
					</tr>
				<%
				do {
					out.println("<tr>");
					out.println("<td>"+fr_rset.getString("username")+"</td>");
					out.println("<td>"+fr_rset.getString("userFirstname")+" "+fr_rset.getString("userLastName")+"</td>");
					out.println("<td>"+(fr_rset.getString("userAddrCity") != null ? fr_rset.getString("userAddrCity")+", " : "")+(fr_rset.getString("userAddrState") != null ? fr_rset.getString("userAddrState") : "")+"</td>");
					out.println("<td>"+fr_rset.getString("frDateBefriended")+"</td>");
					out.println("<td>"+fr_rset.getString("userDateLastLogin")+"</td>");
					out.println("<td>"+fr_rset.getString("userDateJoined")+"</td>");
					out.println("</tr>");
				} while (fr_rset.next() == true);
				%>
				</table>
			
			<%
		} 
	}
} else {
%>
	<a href="manage_cars.jsp">Manage Cars</a><br/>
	<a href="manage_hobbies.jsp">Manage Hobbies</a><br/>
	<a href="manage_friends.jsp">Manage Friends</a><br/><br/>
<% 
	//Administrator Page Access if applicable
	if (rset.getInt(13) == 1) {
%>
		<a href="direct_sql_query.jsp">Administrator Page</a><br/><br/>
<%		
	}
%>	
	<a href="edit_profile.jsp">Edit your Profile</a><br/>
	<a href="messages.jsp">Go to Messages center</a><br/>
	<a href="post_to_blog.jsp">Post a topic/thread/blog-entry</a><br/><br/>
	<a href="search_for_users.jsp">Search for Users</a><br/>
	<a href="search_for_cars.jsp">Search for Cars</a><br/>
	<a href="search_blog_entries.jsp">Search for Blogs</a><br/><br/>
	<a href="index.jsp">Back to Index Page</a><br/>
	<a href="logout.jsp">Logout</a><br/>
<%	
}
%>
</body>
</html>