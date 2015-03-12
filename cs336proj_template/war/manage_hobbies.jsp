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


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>manage_hobbies.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>	
	<h1>Hobby Management</h1>
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

%>
	<form action="manage_hobbies.jsp" method="post">
		Add New Hobby: <br/>
		Hobby Title: 
		<input type="text" name="hobbyTitle"/><br/>
		Hobby Text: 
		<textarea name="hobbyText" cols=30 rows=3></textarea><br/>
		<input type="submit" name="hobbySubmit" value="Submit"/>
	</form>
	<br/><br/>
	<a href="display_profile.jsp">Click to go back to your Profile Page.</a><br/>
<%
	if(request.getParameter("hobbySubmit") == null) {
		//First load of page.
		out.println("");
	} else if (request.getParameter("hobbySubmit") != null &&
			(request.getParameter("hobbyTitle").trim().length() == 0 &&
			request.getParameter("hobbyText").trim().length() == 0)
		) {
		out.println("Nothing was entered, no changes were made.");
	} else if (request.getParameter("hobbySubmit") != null) {
		//Add Hobbies
		try {
			int i = 0;
			conn = DriverManager.getConnection(connectionURL, result);
			stmt = conn.createStatement();
			
			i = stmt.executeUpdate("INSERT INTO Hobby(hTitle) VALUES(\"A\");"); 
			ResultSet rset = stmt.executeQuery("SELECT * FROM Hobby h WHERE h.hTitle = \"A\";");
			rset.next();
			int hID = rset.getInt("hID");
			
			String title = request.getParameter("hobbyTitle").trim();
			if (title != null && title.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Hobby SET hTitle = \"" + title + "\" WHERE hID = "
					+ hID + ";");
			
			String text = request.getParameter("hobbyText").trim();
			if (text != null && text.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Hobby SET hText = \"" + text + "\" WHERE hID = "
					+ hID + ";");
			
			i = stmt.executeUpdate(
				"INSERT INTO hasHobby(pID, hID) VALUES(" 
				 + userInfo.userID + ", " + hID + ");");
		
			if (!rset.isClosed())	
				rset.close();   
		
		} catch (SQLException e) {
			out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");
			for(StackTraceElement es : e.getStackTrace())
				out.println(es + "<br/>");
			out.println("SQLstate is   " + e.getSQLState() + "<br/>");
			if(stmt != null && !stmt.isClosed())
				stmt.close();
			if(conn != null && !conn.isClosed())
				conn.close();
		} finally {
			stmt.close();
			if(conn != null)
				conn.close();	
		}
	}
	//Displays Hobbies
	try {
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
		
		ResultSet rset = stmt.executeQuery(
		"SELECT * FROM Hobby h, hasHobby hh, Profile p WHERE p.userID = " 
		+ userInfo.userID + " AND p.pID = hh.pID AND h.hID = hh.hID;");
		/* print out the results */
		if (rset.next() == true) {
			%><h1>Your Hobby(ies):</h1>
			<form action="manage_hobbies.jsp" method="post">
				<table border=1 cellpadding="10">
					<br/>
					<tr>
						<td>Delete?</td>
						<td>Hobby Title</td>
						<td>Hobby Text</td>
					</tr>
	<%
				do {
					out.println("<tr>");
					out.println("<td><input type=\"checkbox\" name=\"deleteHobbies\" value=\""+ rset.getInt("hID")+"\"</td>");;
					out.println("<td>"+(rset.getString("hTitle") != null ? rset.getString("hTitle") : "-")+"</td>");
					out.println("<td>"+(rset.getString("hText") != null ? rset.getString("hText") : "-")+"</td>");
					out.println("</tr>");
				} while(rset.next() == true);
	%>
				</table>
				<input type="submit" name="deleteHobbySubmit" value="Remove selected Hobbies."/>
			</form>
	<%		//Delete Hobbies
			if (request.getParameter("deleteHobbySubmit") != null) {
				out.println("<br/>DEBUG: deleting hobbies<br/>");
				
				String[] hobbyIDtoDelete = request.getParameterValues("deleteHobbies");
				if (hobbyIDtoDelete != null) {
			
					int deleted_count = 0;
					for (int f = 0; f < hobbyIDtoDelete.length; f++) {
						// get the hID of the Hobby table and hasHobby table
						Statement h_stmt = conn.createStatement();
						ResultSet h_rset = h_stmt.executeQuery(
							"SELECT h.hID as HobbyID, hh.hID as HasHobbyID FROM Hobby h, hasHobby hh, Profile p WHERE p.userID = " 
							+ userInfo.userID + " AND p.pID = hh.pID AND " + hobbyIDtoDelete[f] + " = hh.hID;"
						);
						if (h_rset.next() == true) {

							int hobbyID = h_rset.getInt("HobbyID");
							int hasHobbyID = h_rset.getInt("HasHobbyID");
							
							int rows_altered = stmt.executeUpdate("DELETE FROM hasHobby WHERE pID = " + userInfo.userID + " AND hID = " + hobbyIDtoDelete[f] + ";");
							if (rows_altered != 1)
								out.println("Error trying to delete Hobby with hID " + hobbyIDtoDelete[f] + " from hasHobby. <br/>rows_altered in the delete request was " + rows_altered + "<br/><br/>"); 
							
							rows_altered = stmt.executeUpdate("DELETE FROM Hobby WHERE hID = " + hobbyIDtoDelete[f] + ";");
							if (rows_altered != 1)
								out.println("Error trying to delete Hobby with hID " + hobbyIDtoDelete[f] + " from Hobby. <br/>rows_altered in the delete request was " + rows_altered + "<br/><br/>"); 
							
							deleted_count += 1;
							
						} else {
							out.println("ERROR: couldn't get " + userInfo.username + "'s (hID " + hobbyIDtoDelete[f] + ")<br/>");
						}
						
						h_stmt.close();
					}
					
					%>
					You successfully deleted <%out.println(deleted_count);%> hobbies from your profile.<br/>
					<br/>
					<a href="manage_hobbies.jsp">Refresh your Hobbies.</a><br/>			
					<%
					
				} else {
					out.println("You didn't specify any hobby to delete. Go Back and try again<br/>");
				}
			}
		} 
	} catch (SQLException e) {
		out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");
		for(StackTraceElement es : e.getStackTrace())
			out.println(es + "<br/>");
		out.println("SQLstate is   " + e.getSQLState() + "<br/>");
		if(stmt != null && !stmt.isClosed())
			stmt.close();
		if(conn != null && !conn.isClosed())
			conn.close();
	} finally {
		stmt.close();
		if(conn != null)
			conn.close();	
	}
	
} catch (SQLException e) {
	out.println("<br/> SQLEXception caught: <br/>" + e.getMessage() + "<br/><br/>");
	for(StackTraceElement es : e.getStackTrace())
		out.println(es + "<br/>");
	out.println("SQLstate is   " + e.getSQLState() + "<br/>");
	if(stmt != null && !stmt.isClosed())
		stmt.close();
	if(conn != null && !conn.isClosed())
		conn.close();
} finally {
	stmt.close();
	if(conn != null)
		conn.close();	
}
%>
</body>
</html>
