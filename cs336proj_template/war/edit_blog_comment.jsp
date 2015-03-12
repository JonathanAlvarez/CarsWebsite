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
    <title>edit_blog_commentjsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
	<h1>Edit/Delete your own comments</h1>
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
	
	
	if (request.getParameter("changeCommentSubmit") != null) {
		/* update database with new comment data */
		String newCommentTitle = request.getParameter("commentTitle").trim();
		String newCommentText= request.getParameter("commentText").trim();
		int commentID = Integer.parseInt(request.getParameter("commentID").trim());
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		
		if (newCommentText.length() > 0) {
			String query = "UPDATE BlogComment SET bcTitle = '"+newCommentTitle+"', bcText = '"+newCommentText+"' WHERE bcID = "+commentID+" AND beID = "+blogEntryID;
			int rows_altered = stmt.executeUpdate(query);
			
			if (rows_altered > 0) {
				out.println("You successfully updated "+rows_altered+" comment<br/>");
				out.println("<a href=\"search_blog_entries.jsp\">Back to searching for blog entries/forum topics</a><br/>");
				out.println("<a href=\"display_profile.jsp\">Back to your profile / central hub</a><br/>");
			} else {
				out.println("Failed to update BlogComment with bcID "+commentID+" and beID "+blogEntryID+"<br/>");
			}
			
		} else {
			out.println("You must give at least 1 character for the comment's text. You gave no characters<br/>Go back and try again<br/>");
		}
			
	} else if (request.getParameter("deleteCommentSubmit") != null) {
		/* delete the comment from the database */
		int commentID = Integer.parseInt(request.getParameter("commentID").trim());
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		
		String query = "DELETE FROM BlogComment WHERE bcID = "+commentID+" AND beID = "+blogEntryID;
		int rows_altered = stmt.executeUpdate(query);
		
		if (rows_altered > 0) {
			out.println("You successfully delete "+rows_altered+" comment<br/>");
			out.println("<a href=\"search_blog_entries.jsp\">Back to searching for blog entries/forum topics</a><br/>");
			out.println("<a href=\"display_profile.jsp\">Back to your profile / central hub</a><br/>");			
		} else {
			out.println("Failed to delete BlogComment with bcID "+commentID+" and beID "+blogEntryID+"<br/>");
		}
		
	} else if (request.getParameter("editBlogCommentSubmit") != null) {
		/* Display the comment that the user wants to edit */
		int blogCommentID = Integer.parseInt(request.getParameter("blogCommentID").trim());
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		
		ResultSet rset = stmt.executeQuery(
				"SELECT bc.beID, bc.bcTitle, bc.bcText, bc.bcDatePosted "+
				"FROM BlogComment bc "+
				"WHERE bc.bcID = "+blogCommentID+
				" AND bc.beID = "+blogEntryID
				); 
		if (rset.next() == true) {
			out.println("Your comment originally posted at "+rset.getString("bcDatePosted")+"<br/><br/>");
			%>
			<form action="edit_blog_comment.jsp" method="post">
				Comment Title: <input type="text" name="commentTitle" value="<%out.println(rset.getString("bcTitle"));%>"/><br/>
				Comment text:<br/>
				<textarea name="commentText" cols=40 rows=3><%out.println(rset.getString("bcText"));%></textarea><br/>
				<br/>
				<input type="hidden" name="commentID" value="<%out.println(blogCommentID);%>"/>
				<input type="hidden" name="blogEntryID" value="<%out.println(rset.getString("beID"));%>"/>
				<input type="submit" name="changeCommentSubmit" value="Update comment"/>&nbsp;&nbsp;&nbsp;
				<input type="submit" name="deleteCommentSubmit" value="Delete this comment"/>
			</form>
			<br/>
			<br/>
			<%
			
			/* display the BlogEntry that this comment is attached to for convenience */
			rset = stmt.executeQuery("SELECT be.beTitle, be.beText, be.beDatePosted, be.beTags FROM BlogEntry be WHERE be.beID = "+blogEntryID);
			if (rset.next() == true) {
				%>
				<br/>
				<h3><%out.println(rset.getString("beTitle"));%></h3><br/>
				<br/>
				Posted at <%out.println(rset.getString("beDatePosted"));%><br/>
				Tagged with: <%out.println(rset.getString("beTags"));%><br/>
				<br/>
				<%out.println(rset.getString("beText"));%>
				<br/>
				<%				
			} else {
				out.println("Error, unable to get the BlogEntry (beID "+blogEntryID+") attached to this comment<br/>");
			}			
		} else {
			out.println("Error, unable to get the BlogComment for bcID "+blogCommentID+"<br/>");
		}
	} else {
		out.println("No blog comment specified to edit/delete<br/>");
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

%>
</body>
</html>
