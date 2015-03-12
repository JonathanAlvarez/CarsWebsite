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
    <title>edit_profile.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>	
	<h1>Edit Profile</h1>
	<form action="edit_profile.jsp" method="post">
		Click submit once you are finished making changes.<br/>
		Password: <input type="text" name="userPW"/><br/>
		First name: <input type="text" name="userFirstName"/><br/>
		Last name: <input type="text" name="userLastName"/><br/>
		Email address: <input type="text" name="userEmail"/><br/><br/><br/>
		<br/>
		phone: <input type="text" name="userPhone"/><br/>
		address state: <input type="text" name="userAddrState"/><br/>
		address city: <input type="text" name="userAddrCity"/><br/>
		address street: <input type="text" name="userAddrStreet"/><br/><br/>
		
		<input type="submit" name="editInfoSubmit" value="Submit"/>
	</form>
	<br/><br/>
<%	if(request.getParameter("editInfoSubmit") != null) {
	int i = 0;
	Connection conn = null;
	Statement stmt = null;
	try {
		SessionInfo userInfo = (SessionInfo)session.getValue("info");
		String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
		conn = null;
		Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
		Properties result = driver.parseURL(connectionURL, new Properties());
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
	
		ResultSet rset = stmt.executeQuery(
			"SELECT * FROM Users u WHERE u.userID = "
			+ userInfo.userID + ";");
		rset.next();
		
		if (request.getParameter("userPW").trim().length() == 0 &&
			request.getParameter("userFirstName").trim().length() == 0 &&
			request.getParameter("userLastName").trim().length() == 0 &&
			request.getParameter("userEmail").trim().length() == 0 &&
			request.getParameter("userPhone").trim().length() == 0 &&
			request.getParameter("userAddrState").trim().length() == 0 &&
			request.getParameter("userAddrCity").trim().length() == 0 &&
			request.getParameter("userAddrStreet").trim().length() == 0) {
			out.println("Nothing was updated.<br/>");
		} else {
		
			String password = request.getParameter("userPW").trim();
			if (password != null && password.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userPW = \"" + password + "\" WHERE userID = "
					+ userInfo.userID + ";"); 
			
			String firstName = request.getParameter("userFirstName").trim();
			if (firstName != null && firstName.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userFirstName = \"" + firstName + "\" WHERE userID = "
					+ userInfo.userID + ";");
	
			String lastName = request.getParameter("userLastName").trim();
			if (lastName != null && lastName.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userLastName = \"" + lastName + "\" WHERE userID = "
					+ userInfo.userID + ";");
		
			String email = request.getParameter("userEmail").trim();
			if (email != null && email.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userEmail = \"" + email + "\" WHERE userID = "
					+ userInfo.userID + ";");
		
			String phone = request.getParameter("userPhone").trim();
			if (phone != null && phone.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userPhone = \"" + phone + "\" WHERE userID = "
					+ userInfo.userID + ";");
	
			String state = request.getParameter("userAddrState").trim();
			if (state != null && state.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userAddrState = \"" + state + "\" WHERE userID = "
					+ userInfo.userID + ";");
		
			String city = request.getParameter("userAddrCity").trim();
			if (city != null && city.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userAddrCity = \"" + city + "\" WHERE userID = "
					+ userInfo.userID + ";");
		
			String street = request.getParameter("userAddrStreet").trim();
			if (street != null && street.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Users SET userAddrStreet = \"" + street + "\" WHERE userID = "
					+ userInfo.userID + ";");
	
			if (!rset.isClosed())	
				rset.close();   
			
			out.println("Profile Updated.<br/>");
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
}
%>
	<a href="display_profile.jsp">Click to go back to your Profile Page.</a><br/>
</body>
</html>