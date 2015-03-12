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
    <title>view_own_blog.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>View your Blog/Forum threads</h1>
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
		
	if (request.getParameter("viewMessagesSubmit") == null &&
		request.getParameter("addCommentSubmit") == null) {
		/* first visit to page. display summary of all user's blog posts */
		out.println("DEBUG: FIRST VISIT TO PAGE<br/><br/>");
		
		ResultSet rset = stmt.executeQuery(
			"SELECT b.pID, b.bTitle "+
			"FROM Profile p, Blog b "+
			"WHERE p.userID = "+userInfo.userID+
				" AND b.pID = p.pID"
			);
		if (rset.next() == true) {
			String blogTitle = rset.getString("bTitle");
			int profileID = rset.getInt("pID");
			rset.close();
			
			session.putValue("blogTitle", blogTitle); // save it in session to avoid an extra query later on
			
			/* get all BlogEntries belonging to the user's Blog and print out basic info on them */
			ResultSet entries_rset = stmt.executeQuery(
					"SELECT beID, beTitle, beText, beDatePosted, beTags, beHierarchyBottom "+
					"FROM BlogEntry be "+
					"WHERE STRCMP(be.bTitle, '"+blogTitle+"') = 0 "+
					"ORDER BY be.beDatePosted DESC"
					);
			if (entries_rset.next() == true) {
				Statement hier_stmt = conn.createStatement();
				ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy");

				ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);	
				
				%>
				<form action="view_own_blog.jsp" method="post">
					<input type="submit" name="viewMessagesSubmit" value="View selected messages"/>
					<br/>
					<br/>
					<table border=1 cellpadding="10">
						<tr>
							<td>View topic?</td>
							<td>Entry/Thread title</td>
							<td>Date posted</td>
							<td># comments</td>
							<td>Last comment posted at</td>
							<td>Topic hierarchy</td>
							<td>Tags</td>
						</tr>
					<%
					do {
						/* gather a small summary of this BlogEntry's comments */
						Statement cmnt_stmt = conn.createStatement();
						ResultSet cmnt_rset = cmnt_stmt.executeQuery(
								"SELECT COUNT(bc.bcID) as bcCount, MAX(bcDatePosted) as bcLastDate "+
								"FROM BlogComment bc "+
								"WHERE bc.beID = "+entries_rset.getInt("beID")
								);
						cmnt_rset.first();
						int comment_count = cmnt_rset.getInt("bcCount");
						String comment_last_date = new String("-");
						
						if (comment_count > 0) 
							comment_last_date = cmnt_rset.getString("bcLastDate");
						
						out.println("<tr>");
						out.println("<td><input type=\"checkbox\" name=\"viewMessageIDs\" value=\""+entries_rset.getInt("beID")+"\"</td>");
						out.println("<td>"+entries_rset.getString("beTitle")+"</td>");
						out.println("<td>"+entries_rset.getString("beDatePosted")+"</td>");
						out.println("<td>"+comment_count+"</td>");
						out.println("<td>"+comment_last_date+"</td>");
						out.println("<td>"+hierarchy.HierarchyPathOfNode(entries_rset.getInt("beHierarchyBottom"))+"</td>");;
						out.println("<td>"+entries_rset.getString("beTags")+"</td>");
						out.println("</tr>");
					
						cmnt_stmt.close();
						
					} while (entries_rset.next() == true);
					%>
					</table>
				</form>
				<%
				hier_stmt.close();
			} else {
				%>
				You haven't authored any blog entries/forum threads<br/>
				<a href="post_to_blog.jsp">Create an entry here</a>
				<%			
			}
			
		} else {
			%>
			You have no blog set up!  You need a blog before you can post blog entries/forum threads.<br/>
			<a href="post_to_blog.jsp">Set up a Blog here</a>
			<%
		}
	} else if (request.getParameter("viewMessagesSubmit") != null &&
				request.getParameter("addCommentSubmit") == null &&
				request.getParameter("commentBlogEntryID") == null &&
				request.getParameter("commentText") == null &&
				request.getParameter("commentTitle") == null){
		/* user has selected some of their own posts to view in their entirety */
		out.println("DEBUG: USER SELECTED POSTS TO VIEW<br/><br/>");
		
		String[] entryIDsToView = request.getParameterValues("viewMessageIDs");
		if (entryIDsToView != null) {
		
			%>
			<h1><%out.println(userInfo.username+"'s "+(String)session.getValue("blogTitle")+" blog");%></h1>
			<table border=1 cellpadding="10">
			<%
	
			
			for (int e = 0; e < entryIDsToView.length; e++) {			
				/* Blog Entry vital info */
				ResultSet be_rset = stmt.executeQuery(
						"SELECT beTitle, beText, beDatePosted, beTags, beHierarchyBottom, bTitle as blogTitle "+
						"FROM BlogEntry be "+
						"WHERE be.beID = "+entryIDsToView[e]
						);
				if (be_rset.next() == true) {
					/* Display the blog post that got this thread started */
					%>
					<tr>
						<td><h2><%out.println(be_rset.getString("blogTitle")+" / "+be_rset.getString("beTitle"));%></h2></td>
						<td><%out.println("("+be_rset.getString("beDatePosted")+")");%><br/><%out.println(be_rset.getString("beTags"));%></td>
					</tr>
					<tr>
						<td><%out.println(be_rset.getString("beText"));%></td>
					</tr>
					<%
					
					/* Display any comments under the blog post */
					Statement cmnt_stmt = conn.createStatement();
					ResultSet cmnt_rset = cmnt_stmt.executeQuery(
							"SELECT bcID, bcTitle, bcText, bcDatePosted, bcUserId "+
							"FROM BlogComment bc "+
							"WHERE bc.beID = "+entryIDsToView[e]
							);
					
					Statement cmnt_count_stmt = conn.createStatement();
					ResultSet cmnt_count_rset = cmnt_count_stmt.executeQuery("SELECT COUNT(bcID) as comment_count FROM BlogComment bc WHERE bc.beID = "+entryIDsToView[e]);
					cmnt_count_rset.first();
					
					if (cmnt_rset.next() == true) {
						out.println("<tr><td><h3>"+cmnt_count_rset.getInt("comment_count")+" Comments</h3></td></tr>");
						cmnt_count_stmt.close();
						
						do {							
							/* Get username of the comment author */
							Statement user_stmt = conn.createStatement();
							ResultSet user_rset = user_stmt.executeQuery("SELECT u.username FROM Users u WHERE u.userID = "+cmnt_rset.getInt("bcUserID"));
							String comment_authorname = null;
							if (user_rset.next() == true)
								comment_authorname = user_rset.getString("username");
							else
								comment_authorname = new String("-");
							%>
							<tr>
								<td><%out.println(cmnt_rset.getString("bcText"));%></td>
								<td><%out.println(cmnt_rset.getString("bcTitle")+"<br/> by "+comment_authorname+"<br/> at "+cmnt_rset.getString("bcDatePosted"));%></td>
							</tr>
							<%
							user_stmt.close();
						} while (cmnt_rset.next() == true);
						
					} else {
						out.println("<tr><td><h3>No Comments Yet</h3></td></tr>");
					}
					
					/* Display add-a-comment input form */
					%>
					<tr>
						<td>
							<form action="view_own_blog.jsp" method="post">
								Comment on blog entry ID <%out.println(entryIDsToView[e]);%>:<br/>
								<textarea name="commentText" cols=40 rows=3></textarea><br/>
								Optional Tile/header to your comment:<br/>
								<input type="text" name="commentTitle"/><br/>
								<input type="submit" name="addCommentSubmit" value="Add comment to this posting"/><br/>
								<input type="hidden" name="commentBlogEntryID" value="<%out.println(entryIDsToView[e]);%>"/>
							</form>
						</td>
					</tr>
					<%
		
					cmnt_stmt.close();
				} else {
					out.println("<tr><td>user requested a nonexistant BlogEntry ID "+entryIDsToView[e]+"</td></tr>");
				}
			}
			%></table><%
		} else {
			out.println("You must select some entries/topics to view. Please go back and try again<br/>");
		}
		
	} else if (request.getParameter("addCommentSubmit") != null &&
				request.getParameter("commentBlogEntryID") != null &&
				request.getParameter("commentText") != null &&
				request.getParameter("commentTitle") != null) {
					
		
		int blogEntryID = Integer.parseInt(request.getParameter("commentBlogEntryID").trim());
		String commentText = request.getParameter("commentText").trim();
		String commentTitle = request.getParameter("commentTitle").trim();
		
		out.println("DEBUG: ADDING COMMENT to BlogEntry id"+blogEntryID+"<br/>");
		
		if (commentText.length() > 0) {
			String update_query = "INSERT INTO BlogComment(beID, bcTitle, bcText, bcDatePosted,bcUserID) "+
									"VALUES("+blogEntryID+", '"+commentTitle+"', '"+commentText+"', CURRENT_TIMESTAMP, "+userInfo.userID+")";
			
			out.println("DEBUG: sending update query '"+update_query+"'<br/>");
			
			int rows_altered = stmt.executeUpdate(update_query);
			
			if (rows_altered > 0) {
				%>Your comment (of <%out.println(commentText.length());%> characters) was successfully added<br/>
				<a href="display_profile.jsp">Go to your profile/hub</a><br/>
				<a href="view_own_blog.jsp">Return to viewing your blog entries</a><br/>
				<%
			} else {
				out.println("Failed to insert new comment into database<br/");
			}
			
		} else {
			out.println("You must supply some content for the comment. Hit back button and try again<br/>");
		}
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





/*
try {
	String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
	conn=null;
	Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
	Properties result = driver.parseURL(connectionURL, new Properties());
	
	// i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful)
	out.println("Connection Information: " + result + "<br/><br/><br/>");
	
	conn = DriverManager.getConnection(connectionURL, result);
	stmt = conn.createStatement();

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
*/

%>
</body>
</html>
