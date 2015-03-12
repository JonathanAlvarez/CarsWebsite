<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <title>login.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
	<h1>Login</h1>

<%
if (request.getParameter("username") == null
	&&
	request.getParameter("password") == null)
{
%>
	(first load of the page)<br/><br/>
	<form action="login.jsp" method="post">
		Existing users: enter your username and password
		<br/>
		username: <input type="text" name="username"/><br/>
		password: <input type="text" name="password"/><br/>
		<input type="submit" value="login!"/>
	</form>
	<br/><br/>
	<a href="register_user.jsp">
		Register a new account here
	</a>
<%
}
else {
%>

	<% 
	Connection conn = null;
	Statement stmt = null;

	try {

		String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
		conn=null;
		Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
		Properties result = driver.parseURL(connectionURL, new Properties()); 
	%>

	<!-- i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful) -->
		 <% out.println("Connection Information: " + result + "<br/><br/><br/>"); %> 

		

		<%
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
		
		ResultSet rset = stmt.executeQuery(
			"SELECT u.username FROM Users u WHERE u.username = '"
			+ request.getParameter("username").trim() + "'");
		%>
		<!--
		successfully queried DB (
			"SELECT u.username FROM Users u WHERE u.username = '"
			+ request.getParameter("username") + "'")<br/>
		calling rset.next()<br/>
		-->
		<%
		/* First, check if username exists*/
		if (rset.next() == false) {
			/* username is bad */
		%>
			<form action="login.jsp" method="post">
				Your username '<%out.println(request.getParameter("username").trim());%>' doesn't exist in the database. try again.
				<br/>
				username: <input type="text" name="username"/><br/>
				password: <input type="text" name="password"/><br/>
				<input type="submit" value="login!"/>
			</form>
			<%
		}
		else {
			%>
			<!--rset.next() == true (username is in the database now check if password matches)<br/>-->
			<%
		
			rset = stmt.executeQuery(
				"SELECT * FROM Users u WHERE u.username = '"
				+ request.getParameter("username").trim() + "'"
				+ "AND u.userPW = '"
				+ request.getParameter("password").trim() + "'");
			
			/* username is in database, now check if password matches */
			if (rset.next() == false) {
				/* password is incorrect for the given valid username */
			%>
				<form action="login.jsp" method="post">
					Your password '<%out.println(request.getParameter("password").trim());%>' for username '<%out.println(request.getParameter("username").trim());%>' is WRONG. try again.
					<br/>
					username: <input type="text" name="username"/><br/>
					password: <input type="text" name="password"/><br/>
					<input type="submit" value="login!"/>
				</form>
				<%
			}
			else {
				/* username and password exist and they match, so they are logged in now */
				
				SessionInfo userInfo = new SessionInfo();
				userInfo.username = request.getParameter("username").trim();
				userInfo.userID = rset.getInt("userID");
				session.putValue("info", userInfo);
				
				// user just logged in, so update their "dateLastLogin" timestamp
				int rows_altered = stmt.executeUpdate("UPDATE Users SET userDateLastLogin = CURRENT_TIMESTAMP WHERE userID = "+ userInfo.userID);
				if (rows_altered != 1) {
					out.println("ERROR: rows altered when setting userDateLastLogin was "+rows_altered+" (it should be 1)<br/><br/>");
				}
				
				%>
				Login successful
				<br/>
				<a href="display_profile.jsp">Click here to view your profile.</a>
				<%
			}
		}

		if (!rset.isClosed())	
			rset.close();    

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

}
		%>

</body>
</html>

