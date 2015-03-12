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
    <title>edit_blog_entry.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
	<h1>Edit/Delete Your Own Blog Entry/Forum Topic</h1>
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
	//out.println("Connection Information: " + result + "<br/><br/><br/>");
	
	conn = DriverManager.getConnection(connectionURL, result);
	stmt = conn.createStatement();
	
	if (request.getParameter("changeBlogEntrySubmit") != null) {
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		String blogTitle = request.getParameter("blogTitle").trim();
		
		String newEntryTitle = request.getParameter("entryTitle").trim();
		String newEntryTags = request.getParameter("entryTags").trim();
		String newEntryText = request.getParameter("entryText").trim();
		
		if (newEntryTitle.length() > 0 && newEntryText.length() > 0) {
			
			/* santize/normalize the tag string into format "tag, tag, tag, tag" */
			String tags_normalized = new String();
			if (newEntryTags.length() > 0) {
				String[] tags = newEntryTags.split(",");
				for (int t = 0; t < tags.length; t++) {
					String tag_trim = tags[t].trim();
					
					if (tag_trim.length() > 0) {
						tags_normalized += tag_trim + ", ";							
					}
				}
				
				if (tags_normalized.charAt(tags_normalized.length()-2) == ',') {
					tags_normalized = tags_normalized.substring(0, tags_normalized.length()-2);
				}
			}
			
			String query = "UPDATE BlogEntry SET beTitle = '"+newEntryTitle+"', beTags = '"+tags_normalized+"', beText = '"+newEntryText+"', beDatePosted = CURRENT_TIMESTAMP WHERE beID = "+blogEntryID;
			int rows_altered = stmt.executeUpdate(query);
			
			if (rows_altered > 0) {
				out.println("You successfully updated "+rows_altered+" blog entry/forum topic<br/>");
				out.println("<a href=\"search_blog_entries.jsp\">Back to searching for blog entries/forum topics</a><br/>");
				out.println("<a href=\"display_profile.jsp\">Back to your profile / central hub</a><br/>");
				
			} else {
				out.println("Failed to update BlogEntry with beID "+blogEntryID+"<br/>");
			}		
		} else {
			out.println("You must specify at least 1 character for both the title and text/content. Go back and try again<br/>");
		}
		
	} else if (request.getParameter("deleteBlogEntrySubmit") != null) {
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		String blogTitle = request.getParameter("blogTitle").trim();

		// grab some data about this BlogEntry before deleting it.
		ResultSet rset = stmt.executeQuery("SELECT be.beHierarchyBottom FROM BlogEntry be WHERE be.beID = "+blogEntryID);
		if (rset.next() == true) {
			int entryHierarchyID = rset.getInt("beHierarchyBottom");
			
			// (1) delete all comments attached to this BlogEntry
			int rows_altered = stmt.executeUpdate("DELETE FROM BlogComment WHERE beID = "+blogEntryID);
			out.println(rows_altered + " comments have been deleted due to deletion of this BlogEntry<br/>");
			
			// (2) delete this BlogEntry from the DB
			rows_altered = stmt.executeUpdate("DELETE FROM BlogEntry WHERE beID = "+blogEntryID);
			if (rows_altered > 0) {
				out.println("Successfully delete this BlogEntry from the database<br/>");
			} else {
				out.println("Error, failed to delete BlogEntry with beID "+blogEntryID+"<br/>");
			}
			
			// (3) clean up the BlogHierarchy if necessary
			Statement hier_stmt = conn.createStatement();
			ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy");

			ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);
			rows_altered = hierarchy.DeleteHierarchyNode(entryHierarchyID, stmt);
			hier_stmt.close();
			
			out.println(rows_altered + " topic hierarchy nodes where deleted<br/>");			
			
			out.println("<a href=\"search_blog_entries.jsp\">Back to searching for blog entries/forum topics</a><br/>");
			out.println("<a href=\"display_profile.jsp\">Back to your profile / central hub</a><br/>");
			
		} else {
			out.println("Error, failed to get BlogEntry with beID "+blogEntryID+" record in the DB<br/>");
		}
		

		
		
	} else if (request.getParameter("editBlogEntrySubmit") != null) {
		int blogEntryID = Integer.parseInt(request.getParameter("blogEntryID").trim());
		String blogTitle = request.getParameter("blogTitle").trim();
		
		String query =
			"SELECT be.beTitle, be.beText, be.beDatePosted, be.beTags "+
			"FROM BlogEntry be "+
			"WHERE be.beID = "+blogEntryID;
		ResultSet rset = stmt.executeQuery(query);
		if (rset.next() == true) {
			out.println("<h3>"+blogTitle+"</h3>This entry/topic was originally posted at "+rset.getString("beDatePosted")+"<br/><br/>");
			%>
			<form action="edit_blog_entry.jsp" method="post">
				Entry/Topic title:<br/>
				<input type="text" name="entryTitle" value="<%out.println(rset.getString("beTitle"));%>"/><br/>
				<br/>
				Entry/Topic tags (comma separated):<br/>
				<input type="text" name="entryTags" value="<%out.println(rset.getString("beTags"));%>"/><br/>
				<br/>
				Entry/Topic text:<br/>
				<textarea name="entryText" cols=40 rows=4><%out.println(rset.getString("beText"));%></textarea><br/>
				<br/>
				<br/>
				<input type="hidden" name="blogEntryID" value="<%out.println(blogEntryID);%>"/>
				<input type="hidden" name="blogTitle" value="<%out.println(blogTitle);%>"/>
				<input type="submit" name="changeBlogEntrySubmit" value="Update Entry"/>
				<input type="submit" name="deleteBlogEntrySubmit" value="Delete this Entry"/>&nbsp;&nbsp;&nbsp;
			</form>
			<%
		} else {
			out.println("Error, couldn't get BlogEntry data for beID "+blogEntryID+"<br/>");
		}
	} else {
		out.println("No BlogEntry specified to edit<br/>");
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
