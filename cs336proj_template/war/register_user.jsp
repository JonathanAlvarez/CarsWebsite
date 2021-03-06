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
    <title>register_user.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>Registration</h1>
<%

if (request.getParameter("registrationInfoSubmit") == null) {
	%>			
	<form action="register_user.jsp" method="post">
		(First visit to registration page)<br/>
		REQUIRED INFO NEEDED FOR REGISTRATION:<br/>
		username: <input type="text" name="username"/><br/>
		password: <input type="text" name="userPW"/><br/>
		isAdmin?: <input type="text" name="userAdmin"/><br/><br/>
		
		First name: <input type="text" name="userFirstName"/><br/>
		Last name: <input type="text" name="userLastName"/><br/>
		Email address: <input type="text" name="userEmail"/><br/><br/><br/>
		
		OPTIONAL INFO:<br/><br/>
		phone: <input type="text" name="userPhone"/><br/>
		address state: <input type="text" name="userAddrState"/><br/>
		address city: <input type="text" name="userAddrCity"/><br/>
		address street: <input type="text" name="userAddrStreet"/><br/><br/>
		
		<input type="submit" name="registrationInfoSubmit" value="submit registration info"/>
	</form>
	<%
} else if (request.getParameter("registrationInfoSubmit") != null
			&&
			(request.getParameter("username") == null ||
			request.getParameter("userPW") == null ||
			request.getParameter("userFirstName") == null ||
			request.getParameter("userLastName") == null ||
			request.getParameter("userEmail") == null)
			||
			(request.getParameter("username").trim().length() == 0 ||
			request.getParameter("userPW").trim().length() == 0 ||
			request.getParameter("userFirstName").trim().length() == 0 ||
			request.getParameter("userLastName").trim().length() == 0 ||
			request.getParameter("userEmail").trim().length() == 0))
{
	/* they didn't fill out all required information */
	%>
	<form action="register_user.jsp" method="post">
		You didn't supply all required information<br/>
		REQUIRED INFO NEEDED FOR REGISTRATION:<br/>
		username: <input type="text" name="username" value="<%out.println(request.getParameter("username") == null ? "" : request.getParameter("username"));%>"/><br/>
		password: <input type="text" name="userPW" value="<%out.println(request.getParameter("userPW") == null ? "" : request.getParameter("userPW"));%>"/><br/>
		isAdmin?: <input type="text" name="userAdmin" value="<%out.println(request.getParameter("userAdmin") == null ? "" : request.getParameter("userAdmin"));%>"/><br/><br/>
		
		First name: <input type="text" name="userFirstName" value="<%out.println(request.getParameter("userFirstName") == null ? "" : request.getParameter("userFirstName"));%>"/><br/>
		Last name: <input type="text" name="userLastName" value="<%out.println(request.getParameter("userLastName") == null ? "" : request.getParameter("userLastName"));%>"/><br/>
		Email address: <input type="text" name="userEmail" value="<%out.println(request.getParameter("userEmail") == null ? "" : request.getParameter("userEmail"));%>"/><br/><br/><br/>
		
		
		OPTIONAL INFO:<br/><br/>
		phone: <input type="text" name="userPhone" value="<%out.println(request.getParameter("userPhone"));%>"/><br/>
		address state: <input type="text" name="userAddrState" value="<%out.println(request.getParameter("userAddrState"));%>"/><br/>
		address city: <input type="text" name="userAddrCity" value="<%out.println(request.getParameter("userAddrCity"));%>"/><br/>
		address street: <input type="text" name="userAddrStreet" value="<%out.println(request.getParameter("userAddrStreet"));%>"/><br/><br/>
		
		<input type="submit" value="submit registration info"/>
	</form>
	<%
} else if (request.getParameter("registrationInfoSubmit") != null) {
	/* check if username already exists */
	
	Connection conn = null;
	Statement stmt = null;

	try {

		String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
		conn=null;
		Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
		Properties result = driver.parseURL(connectionURL, new Properties());
		
		/* i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful) */
		out.println("Connection Information: " + result + "<br/><br/><br/>");
		
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
		
		ResultSet rset = stmt.executeQuery(
			"SELECT * FROM Users u WHERE u.username = '"
			+ request.getParameter("username").trim() + "'");
		if (rset.next() == false) {
			//  figure out a user ID that is not taken yet (assumes deleted userIDs are never reused)
			int new_userID = 1;
			ResultSet next_userID_rset = stmt.executeQuery("SELECT MAX(u.userID) FROM Users u");
			if (next_userID_rset.next() == true)
				new_userID = 1 + next_userID_rset.getInt(1);
			if (!next_userID_rset.isClosed())	
				next_userID_rset.close();    
			out.println("<br/>Debug: new user ID will be "+new_userID+"<br/>");
			
			/* Construct insert query. */
			// First, do non-null fields
			String ins_str = "INSERT INTO Users(userID, username, userPW, userFirstName, userLastName, userEmail, userDateJoined, userDateLastLogin";
			String vals_str = "VALUES(" + new_userID + ", "
					+ "'" + request.getParameter("username").trim() + "', "
					+ "'" + request.getParameter("userPW").trim() + "', "
					+ "'" + request.getParameter("userFirstName").trim() + "', "
					+ "'" + request.getParameter("userLastName").trim() + "', "
					+ "'" + request.getParameter("userEmail").trim() + "', "
					+ "CURRENT_TIMESTAMP, "
					+ "CURRENT_TIMESTAMP";
			ins_str += ", userAdmin";
			if (request.getParameter("userAdmin").trim().length() == 1)
				vals_str += ", 1";
			else
				vals_str += ", 0";
			// strings look like this so far:
			// insert into users (xx, xxx, xxx
			// values('xxx', 'xxx', 'xxx'
					
			// Second, do optional fields:
			String phone = request.getParameter("userPhone").trim();
			if (phone != null && phone.length() > 0) {
				ins_str += ", userPhone";
				vals_str += ", '" + phone + "'";
			}
			String state = request.getParameter("userAddrState").trim();
			if (state != null && state.length() > 0) {
				if(state.length() == 2) {
				
					ins_str += ", userAddrState";
					vals_str += ", '" + state + "'";
				} else {
					out.println("<br/>Your state '"+state+"'is not a 2 letter abbreviation. We did not save this State in your profile.<br/>You can try again later in the 'edit your profile' page<br/><br/>");
				}
			}
			String city = request.getParameter("userAddrCity").trim();
			if (city != null && city.length() > 0) {
				ins_str += ", userAddrCity";
				vals_str += ", '" + city + "'";
			}
			String street = request.getParameter("userAddrStreet").trim();
			if (street != null && street.length() > 0) {
				ins_str += ", userAddrStreet";
				vals_str += ", '" + street + "'";
			}
			ins_str += ")";
			vals_str += ")";
			String insert_query = ins_str + " " + vals_str;

			out.println("Debug: executing update query '"+ insert_query +"' <br/><br/>");
			
			Statement insert_stmt = conn.createStatement();
			try {
				int rows_altered = insert_stmt.executeUpdate(insert_query);
				if (rows_altered == 1) {
					/* successful at inserting new User row*/
					SessionInfo userInfo =  new SessionInfo();
					userInfo.username = request.getParameter("username");
					userInfo.userID = new_userID;
					session.putValue("info", userInfo);
					
					/* now insert new Profile row */
					insert_query = "INSERT INTO Profile(userID) VALUES("+new_userID+")";
					
					out.println("Debug: executing update query '"+insert_query+"'<br/><br/>");
					
					rows_altered = insert_stmt.executeUpdate(insert_query);
					
					if (rows_altered == 1) {
						%>
						Registration successful.<br/><br/>
						<a href="display_profile.jsp">Click to go to your new profile page</a>			
						<%
					} else {
						/* Failure at inserting new Profile row */
						out.println("failure at creating new Profile<br/>");
					}
					
				
				} else {
					/* failure at inserting new Users row */
					out.println("failure at inserting new User. (insert_stmt.execUpdate() returned "+rows_altered+")<br/><br/>");
					%>
					Failure at inserting new row into Users table<br/><br/>
					<a href="register_user.jsp">Restart registration</a>
					<%
				}
			} catch (SQLException e) {
				out.println("<br/> SQLException caught when inserting: <br/>" + e.getMessage() + "<br/><br/>");

				for(StackTraceElement es : e.getStackTrace())
					out.println(es + "<br/>");

				out.println("SQLstate is   " + e.getSQLState() + "<br/>");
				
			} finally {
				if(insert_stmt != null && !insert_stmt.isClosed())
					insert_stmt.close();
			}	
		}
		else {
			/* a user already exists with the given "username" */
			%>
			<form action="register_user.jsp" method="post">
				Error: choose a different username. Someone is already using '<%out.println(request.getParameter("username"));%>'<br/>
				REQUIRED INFO NEEDED FOR REGISTRATION:<br/><br/><br/>
				username: <input type="text" name="username"/><br/><br/>
				password: <input type="text" name="userPW" value="<%out.println(request.getParameter("userPW"));%>"/><br/>
				isAdmin?: <input type="text" name="userAdmin" value="<%out.println(request.getParameter("userAdmin"));%>"/><br/><br/>
				
				First name: <input type="text" name="userFirstName" value="<%out.println(request.getParameter("userFirstName"));%>"/><br/>
				Last name: <input type="text" name="userLastName" value="<%out.println(request.getParameter("userLastName"));%>"/><br/>
				Email address: <input type="text" name="userEmail" value="<%out.println(request.getParameter("userEmail"));%>"/><br/><br/><br/>
				
				
				OPTIONAL INFO:<br/><br/>
				phone: <input type="text" name="userPhone" value="<%out.println(request.getParameter("userPhone"));%>"/><br/>
				address state: <input type="text" name="userAddrState" value="<%out.println(request.getParameter("userAddrState"));%>"/><br/>
				address city: <input type="text" name="userAddrCity" value="<%out.println(request.getParameter("userAddrCity"));%>"/><br/>
				address street: <input type="text" name="userAddrStreet" value="<%out.println(request.getParameter("userAddrStreet"));%>"/><br/><br/>
				
				<input type="submit" value="submit registration info"/>
			</form>
			<%
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
} else {
	out.println("This shouldn't ever happen<br/>");
}
%>

</body>
</html>