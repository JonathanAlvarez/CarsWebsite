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
    <title>manage_cars.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>	
	<h1>Car Management</h1>
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
	<form action="manage_cars.jsp" method="post">
		Add New Car: <br/>
		Make: <input type="text" name="carMake"/><br/>
		Model: <input type="text" name="carModel"/><br/>
		Type: <input type="text" name="carType"/><br/>
		Color: <input type="text" name="carColor"/><br/>
		Year: <input type="text" name="carYear"/><br/>
		Engine: <input type="text" name="carEngine"/><br/>
		Modifications: <input type="text" name="carModifications"/><br/><br/>
		<input type="submit" name="editCarsSubmit" value="Submit"/>
	</form>
	<br/><br/>
	<a href="display_profile.jsp">Click to go back to your Profile Page.</a><br/>
<%
	if(request.getParameter("editCarsSubmit") == null) {
		//First load of page.
		out.println("");
	} else if (request.getParameter("editCarsSubmit") != null &&
			(request.getParameter("carMake").trim().length() == 0 &&
			request.getParameter("carModel").trim().length() == 0 &&
			request.getParameter("carType").trim().length() == 0 &&
			request.getParameter("carColor").trim().length() == 0 &&
			request.getParameter("carYear").trim().length() == 0 &&
			request.getParameter("carEngine").trim().length() == 0 &&
			request.getParameter("carModifications").trim().length() == 0)
		) {
		out.println("Nothing was entered, no changes were made.");
	} else if (request.getParameter("editCarsSubmit") != null) {
		//Add Cars
		try {
			int i = 0;
			conn = DriverManager.getConnection(connectionURL, result);
			stmt = conn.createStatement();
			
			i = stmt.executeUpdate("INSERT INTO Car(carMake) VALUES(\"A\");"); 
			ResultSet rset = stmt.executeQuery("SELECT * FROM Car c WHERE c.carMake = \"A\";");
			rset.next();
			int cID = rset.getInt("carID");
			
			String make = request.getParameter("carMake").trim();
			if (make != null && make.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carMake = \"" + make + "\" WHERE carID = "
					+ cID + ";");
			
			String model = request.getParameter("carModel").trim();
			if (model != null && model.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carModel = \"" + model + "\" WHERE carID = "
					+ cID + ";");
			
			String type = request.getParameter("carType").trim();
			if (type != null && type.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carType = \"" + type + "\" WHERE carID = "
					+ cID + ";");
			
			String color = request.getParameter("carColor").trim();
			if (color != null && color.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carColor = \"" + color + "\" WHERE carID = "
					+ cID + ";");
		
			String year = request.getParameter("carYear").trim();
			if (year != null && year.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carYear = \"" + year + "\" WHERE carID = "
					+ cID + ";");
			
			String engine = request.getParameter("carEngine").trim();
			if (engine != null && engine.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carEngine = \"" + engine + "\" WHERE carID = "
					+ cID + ";");
			
			String modifications = request.getParameter("carModifications").trim();
			if (modifications != null && modifications.length() > 0)
				i = stmt.executeUpdate(
					"UPDATE Car SET carModifications = \"" + modifications + "\" WHERE carID = "
					+ cID + ";");
		
			i = stmt.executeUpdate(
				"INSERT INTO hasCar(pID, carID) VALUES(" 
				  + userInfo.userID + ", " + cID + ");");
		
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
	//Displays Cars
	try {
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
		
		ResultSet rset = stmt.executeQuery(
		"SELECT * FROM Car c, hasCar hc, Profile p WHERE p.userID = " 
		+ userInfo.userID + " AND p.pID = hc.pID AND c.carID = hc.carID;");
		/* print out the results */
		if (rset.next() == true) {
			%><h1>Your Car(s):</h1>
			<form action="manage_cars.jsp" method="post">
				<table border=1 cellpadding="10">
					<br/>
					<tr>
						<td>Delete?</td>
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
					out.println("<td><input type=\"checkbox\" name=\"deleteCars\" value=\""+ rset.getInt("carID")+"\"</td>");;
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
				<input type="submit" name="deleteCarsSubmit" value="Remove selected Cars."/>
			</form>
	<%		//Delete Cars
			if (request.getParameter("deleteCarsSubmit") != null) {
				out.println("<br/>DEBUG: deleting cars<br/>");
				
				String[] carIDtoDelete = request.getParameterValues("deleteCars");
				if (carIDtoDelete != null) {
			
					int deleted_count = 0;
					for (int f = 0; f < carIDtoDelete.length; f++) {
						// get the carID of the Car table and hasCar table
						Statement car_stmt = conn.createStatement();
						ResultSet car_rset = car_stmt.executeQuery(
							"SELECT c.carID as CarID, hc.carID as HasCarID FROM Car c, hasCar hc, Profile p WHERE p.userID = " 
							+ userInfo.userID + " AND p.pID = hc.pID AND " + carIDtoDelete[f] + " = hc.carID;"
						);
						if (car_rset.next() == true) {

							int carID = car_rset.getInt("carID");
							int hasCarID = car_rset.getInt("hasCarID");
							
							int rows_altered = stmt.executeUpdate("DELETE FROM hasCar WHERE pID = " + userInfo.userID + " AND carID = " + carIDtoDelete[f] + ";");
							if (rows_altered != 1)
								out.println("Error trying to delete Car with carID " + carIDtoDelete[f] + " from hasHobby. <br/>rows_altered in the delete request was " + rows_altered + "<br/><br/>");
							
							rows_altered = stmt.executeUpdate("DELETE FROM Car WHERE carID = " + carIDtoDelete[f] + ";");
							if (rows_altered != 1)
								out.println("Error trying to delete Car with carID " + carIDtoDelete[f] + "from Hobby. <br/>rows_altered in the delete request was " + rows_altered + "<br/><br/>");
							
							deleted_count += 1;
							
						} else {
							out.println("ERROR: couldn't get " + userInfo.username + "'s (carID " + carIDtoDelete[f] + ")<br/>");
						}
						
						car_stmt.close();
					}
					
					%>
					You successfully deleted <%out.println(deleted_count);%> cars from your profile.<br/>
					<br/>
					<a href="manage_cars.jsp">Refresh your Car Table.</a><br/>			
					<%
					
				} else {
					out.println("You didn't specify any car to delete. Go Back and try again<br/>");
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