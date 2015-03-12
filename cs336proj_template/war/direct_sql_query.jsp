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


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>direct_sql_query.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
	<h1>SQL Execution</h1>

<a href="index.jsp">Index / Home page</a><br/>
<a href="display_profile.jsp">Back to profile page.</a>
<%
if ((request.getParameter("query") == null) &&
	(request.getParameter("altquery") == null))
{
%>
	<form action="direct_sql_query.jsp" method="post">
		SQL select query: <input type="text" name="query"/><br/>
		SQL ins/del/update query: <input type="text" name="altquery"/><br/>
		<input type="submit" value="execute query!"/>
	</form>
<%
} else {
	/* run the query */	
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
		
		
		if (request.getParameter("query").trim().length() > 0) {
			/* run an innoccous select query */
			out.println("Running ready-only query '"+request.getParameter("query").trim()+"' <br/><br/>");
		
			ResultSet rset = stmt.executeQuery(request.getParameter("query").trim());
			%>
			<table border=1>
				<%
				/* Print out all the column names in the ResultSet */
				out.println("<tr>");
				ResultSetMetaData rset_mdata = rset.getMetaData();
				for (int c = 1; c <= rset_mdata.getColumnCount(); c++) {
					out.println("<td>"/*+rset_mdata.getTableName(c)*/+"."+rset_mdata.getColumnName(c)+"</td>");
				}
				out.println("</tr>");
					
				while(rset.next() == true) {
					out.println("<tr>");
					for (int c = 1; c <= rset_mdata.getColumnCount(); c++) {
						out.println("<td>"+rset.getString(c)+"</td>");
					}
					out.println("</tr>");
				}
				%>
			</table>
			
			<%
			
			if (!rset.isClosed())
				rset.close();
		} else {
			/* run an insert/delete/update query */
			out.println("Running altering query '"+request.getParameter("altquery").trim()+"' <br/><br/>");
			int rows_altered = stmt.executeUpdate(request.getParameter("altquery").trim());
			out.println("Rows Updated by query: "+rows_altered+"<br/><br/>");
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
}
%>

</body>
</html>