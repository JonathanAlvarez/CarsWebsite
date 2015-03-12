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
    <title>search_blog_entries.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>View Blog Entries/Forum Topics</h1>
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
	<form action="search_blog_entries.jsp" method="post">
		Search and Filter all Blog Entries/topics by:<br/>
		Sort by:<br/>
		<input type="radio" name="sortBy" value="dateDesc" checked="checked"/>Sort By Date Most Recent First<br/>
		<input type="radio" name="sortBy" value="dateAsc"/>Sort By Date Oldest First<br/>
		<br/>
		<input type="radio" name="sortBy" value="usernameDesc"/>Sort By by author's Username, Z's first (descending)<br/>
		<input type="radio" name="sortBy" value="usernameAsc"/>Sort By topics by author's Username, A's first (ascending)<br/> 
		<br/>
		<br/>
		<%
		/* Only output nodes that BlogEntries are pointing to.
		 * the entries are checkbox inputs with name="selectedHier"
		 */
		Statement hierLeaf_stmt = conn.createStatement();
		ResultSet hierLeaf_rset = hierLeaf_stmt.executeQuery("SELECT distinct(bh.bhNodeID), bh.bhString, bh.bhNodeParent FROM BlogHierarchy bh, BlogEntry be WHERE bh.bhNodeID = be.beHierarchyBottom");
		
		Statement hier_stmt = conn.createStatement();
		ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy bh");
		ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);
		
		out.println(hierarchy.SelectableXMLHierarchyNodes("checkbox", "selectedHier"));
		/*if (hierLeaf_rset.next() == true) {
			out.println("Only show entries from the topics...<br/>");
			out.println("<table cellpadding=\"5\">");
			do {
				out.println("<tr><td><input type=\"checkbox\" name=\"selectedHier\" value=\""+hierLeaf_rset.getInt("bhNodeID")+"\"/></td><td>"+hierarchy.HierarchyPathOfNode(hierLeaf_rset.getInt("bhNodeID"))+"</td></tr>");
			} while (hierLeaf_rset.next() == true);
			
			out.println("</table>");
		}*/
		
		hier_stmt.close();
		hierLeaf_stmt.close();
		%>
		<br/>
		<br/>
		Show only entries:<br/>
		&nbsp;&nbsp;&nbsp;&nbsp;Containing the substring: <input type="text" name="searchString"/><br/>
		&nbsp;&nbsp;&nbsp;&nbsp;Title contains the substring<input type="text" name="searchTitle"/><br/>
		&nbsp;&nbsp;&nbsp;&nbsp;Authored by username: <input type="text" name="searchAuthorUsername"/><br/>
		&nbsp;&nbsp;&nbsp;&nbsp;Has any of the tags (comma separated)<input type="text" name="searchTags"/><br/>
		
	
		<input type="submit" name="sortAndFilterCriteriaSubmit" value="search all entries/topics"/>
	</form>
	<br/>
	<%
	
	if (request.getParameter("sortAndFilterCriteriaSubmit") == null &&
		request.getParameter("viewMessagesSubmit") == null &&
		request.getParameter("addCommentSubmit") == null) {
		/* First page load. Display all BlogEntry titles showing newest first (no filtering) */
		
		out.println("DEBUG: FIRST PAGE VIEW, no filtering, displaying all Blog Entries<br/>");
		
		/* get ALL BlogEntries (and their author's name) and display a small amount of info about each one */
		ResultSet entries_rset = stmt.executeQuery(
				"SELECT u.username as authorname, be.beID, be.beTitle, be.beText, be.beDatePosted, be.beTags, be.beHierarchyBottom, b.bTitle "+
				"FROM BlogEntry be, Blog b, Profile p, Users u "+
				"WHERE be.bTitle = b.bTitle "+
				" AND b.pID = p.pID "+
				" AND p.userID = u.userID "+
				"ORDER BY be.beDatePosted DESC"
				);
		if (entries_rset.next() == true) {
			
			Statement hier_display_stmt = conn.createStatement();
			ResultSet hier_display_rset = hier_display_stmt.executeQuery("SELECT * FROM BlogHierarchy");

			ParseBlogHierarchy hierarchy_display = new ParseBlogHierarchy(hier_display_rset);	
			
			%>
			<form action="search_blog_entries.jsp" method="post">
				<input type="submit" name="viewMessagesSubmit" value="View selected messages"/>
				<br/>
				<br/>
				<table border=1 cellpadding="10">
					<tr>
						<td>View topic?</td>
						<td>Entry/Thread title</td>
						<td>Author name</td>
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
					out.println("<td>"+entries_rset.getString("authorname")+"</td>");
					out.println("<td>"+entries_rset.getString("beDatePosted")+"</td>");
					out.println("<td>"+comment_count+"</td>");
					out.println("<td>"+comment_last_date+"</td>");
					out.println("<td>"+hierarchy_display.HierarchyPathOfNode(entries_rset.getInt("beHierarchyBottom"))+"</td>");;
					out.println("<td>"+entries_rset.getString("beTags")+"</td>");
					out.println("</tr>");
				
					cmnt_stmt.close();
					
				} while (entries_rset.next() == true);
				%>
				</table>
			</form>
			<%
			
			hier_display_stmt.close();
		} else {
			%>
			There are no blog entries/forum topics<br/>
			<a href="post_to_blog.jsp">Create the first entry here!</a>
			<%
		}
	} else if (request.getParameter("sortAndFilterCriteriaSubmit") != null) {
		/* Filter and sort all blog entries */
		
		/* construct query's ORDER BY clause */
		String orderByCriteria = request.getParameter("sortBy");
		String orderBy = new String("ORDER BY ");
		if (orderByCriteria.equalsIgnoreCase("dateDesc"))
			orderBy += "be.beDatePosted DESC";
		else if (orderByCriteria.equalsIgnoreCase("dateAsc"))
			orderBy += "be.beDatePosted ASC";
		else if (orderByCriteria.equalsIgnoreCase("usernameDesc"))
			orderBy += "u.username DESC";
		else if (orderByCriteria.equalsIgnoreCase("usernameAsc"))
			orderBy += "u.username ASC";
		else
			orderBy = "";
		
		/* construct query's GROUP BY clauses */
		String groupBy = new String();
		/*String[] groupByCriteria = request.getParameterValues("groupBy");
		if (groupByCriteria != null && groupByCriteria.length > 0) {
			for (int g = 0; g < groupByCriteria.length; g++) {
				String newGroupCriteria = new String();
				
				if (groupByCriteria[g].equalsIgnoreCase("username"))
					newGroupCriteria = "u.username";
				//else if (groupByCriteria[g].equalsIgnoreCase("xxxx"))
				
				// if adding a new criteria, make it "and" if there's already an existing criteria.
				if (newGroupCriteria.length() > 0) {
					if (groupBy.length() > 0)
						groupBy += ", ";
					groupBy += newGroupCriteria;
				}
			}
		}
		*/
		if (groupBy.length() > 0)
			groupBy = "GROUP BY "+groupBy;
		
		/* construct query's WHERE clause */
		String substring_match = request.getParameter("searchString").trim();
		String titlesubstring_match = request.getParameter("searchTitle").trim();
		String authorname_match = request.getParameter("searchAuthorUsername").trim();
		String tags_match = request.getParameter("searchTags").trim();
		String[] tags = tags_match.split(",");

		String where_clause =	"WHERE be.bTitle = b.bTitle "+
								" AND b.pID = p.pID "+
								" AND p.userID = u.userID ";
		if (substring_match.length() > 0) {
			where_clause += " AND be.beText LIKE '%"+substring_match+"%'";
		}
		if (titlesubstring_match.length() > 0) {
			where_clause += " AND be.beTitle LIKE '%"+titlesubstring_match+"%'";
		}
		if (authorname_match.length() > 0) {			
			where_clause += " AND STRCMP(u.username, '"+authorname_match+"') = 0";
		}
		
		out.println("dEBUG: tags critera '"+tags_match+"' split into "+tags.length+" tags<br/>");
		
		String tag_conditionals = new String();
		if (tags.length > 0) {
			/* assemble conditional statements for all the tags */
			for (int t = 0; t < tags.length; t++) {
				String tag = tags[t].trim();
				if (tag.length() > 0) {
					if (tag_conditionals.length() > 0)
						tag_conditionals += " OR ";
					
					tag_conditionals += "(be.beTags = '"+tag+"'" + // first and only tag
										" OR be.beTags LIKE '"+tag+",%'" + // first tag among many
										" OR be.beTags LIKE '%, "+tag+",%'"+ // middle tag
										" OR be.beTags LIKE '%, "+tag+"')"; // last tag among many
				}
			}
			
			if (tag_conditionals.length() > 0) {				
				where_clause += " AND ("+tag_conditionals+")";
			}
		}
		
		String query = "SELECT be.beID, u.username as authorname, be.beTitle, be.beText, be.beDatePosted, be.beTags, be.beHierarchyBottom, b.bTitle ";
		query += " FROM BlogEntry be, Blog b, Profile p, Users u ";
		query += " " + where_clause;
		query += " " + groupBy;
		query += " " + orderBy;
		
		out.println("DEBUG: selection query is '"+query+"' <br/>");

		/* get BlogEntries (and their author's name) and display a small amount of info about each one */
		ResultSet entries_rset = stmt.executeQuery(query);
		if (entries_rset.next() == true) {
			
			Statement hier_display_stmt = conn.createStatement();
			ResultSet hier_display_rset = hier_display_stmt.executeQuery("SELECT * FROM BlogHierarchy");
			ParseBlogHierarchy hierarchy_display = new ParseBlogHierarchy(hier_display_rset);
			
			/* create list of all selected hierarchy paths */
			String[] user_selected_nodeIDs = request.getParameterValues("selectedHier");
			java.util.Vector<String> selected_paths = new  java.util.Vector<String>();
//			java.util.TreeSet<Integer> selected_nodeIDs = new java.util.TreeSet<Integer>();
			
			if (user_selected_nodeIDs != null) {
				for (int p = 0; p < user_selected_nodeIDs.length; p++) {
					//String path = hierarchy_display.HierarchyPathOfNode(Integer.parseInt(selected_nodeIDs[p]));
					
					out.println("DEBUG: user selected node '"+user_selected_nodeIDs[p]+"'<br/>");
					
					selected_paths.add(hierarchy_display.HierarchyPathOfNode(Integer.parseInt(user_selected_nodeIDs[p])));
//					selected_nodeIDs.add(Integer.parseInt(user_selected_nodeIDs[p]));
				}
			}
			
			%>
			<form action="search_blog_entries.jsp" method="post">
				<input type="submit" name="viewMessagesSubmit" value="View selected messages"/><br/>
				<table border=1 cellpadding="10">
					<tr>
						<td>View topic?</td>
						<td>Entry/Thread title</td>
						<td>Author name</td>
						<td>Date posted</td>
						<td># comments</td>
						<td>Last comment posted at</td>
						<td>Topic hierarchy</td>
						<td>Tags</td>
					</tr>
				<%
				do {
					// if user selected no hierarchies to display, or this BlogEntry is under a hierarchy-node that was selected.
					boolean entry_under_selected_hierarchy = false;
					for (int p = 0; p < selected_paths.size(); p++) {
						String entry_hier_path = hierarchy_display.HierarchyPathOfNode(entries_rset.getInt("beHierarchyBottom"));
						
						if (entry_hier_path.indexOf(selected_paths.elementAt(p)) != -1)
							entry_under_selected_hierarchy = true;
					}
					
					if (selected_paths.size() == 0 ||
						entry_under_selected_hierarchy
						//|| selected_nodeIDs.contains(new Integer(entries_rset.getInt("beHierarchyBottom")))
						)
					{
					
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
						out.println("<td>"+entries_rset.getString("authorname")+"</td>");
						out.println("<td>"+entries_rset.getString("beDatePosted")+"</td>");
						out.println("<td>"+comment_count+"</td>");
						out.println("<td>"+comment_last_date+"</td>");
						out.println("<td>"+hierarchy_display.HierarchyPathOfNode(entries_rset.getInt("beHierarchyBottom"))+"</td>");
						out.println("<td>"+entries_rset.getString("beTags")+"</td>");
						out.println("</tr>");
					
						cmnt_stmt.close();
					}
				} while (entries_rset.next() == true);
				%>
				</table>
			</form>
			<%
			
			hier_display_stmt.close();
		} else {
			%>
			No blog entries/forum topics match your criteria<br/>
			<%
		}
			
		
	} else if (request.getParameter("viewMessagesSubmit") != null) {
		/* User wants to view the selected entries/topics */
		
		String[] entryIDsToView = request.getParameterValues("viewMessageIDs");
		
		if (entryIDsToView != null) {
			%><table border=1 cellpadding="10"><%
			for (int e = 0; e < entryIDsToView.length; e++) {			
				/* Blog Entry vital info */
				
				/* retrieve selected BlogEntryIDs and their author's username */
				ResultSet be_rset = stmt.executeQuery(
						"SELECT u.userID, u.username as authorname, be.beID, be.beTitle, be.beText, be.beDatePosted, be.beTags, be.beHierarchyBottom, b.bTitle as blogTitle "+
						"FROM BlogEntry be, Blog b, Profile p, Users u "+
						"WHERE be.beID = "+entryIDsToView[e]+
						" AND be.bTitle = b.bTitle "+
						" AND b.pID = p.pID "+
						" AND p.userID = u.userID "
						);
				if (be_rset.first()) {
					/* Display the blog post that got this thread started */
					%>
					<tr>
						<td><h2><%out.println(be_rset.getString("blogTitle")+" / "+be_rset.getString("beTitle"));%></h2></td>
						<td>by 
							<form action="display_profile.jsp" method="post">
								<input type="hidden" name="userProfileID" value="<%out.println(be_rset.getInt("userID")); %>"/>
								<input type="submit" name="viewUserProfileSubmit" value="<%out.println(be_rset.getString("authorname")); %>"/>
							</form>
							<%out.println(" at ("+be_rset.getString("beDatePosted")+")");%><br/>
							<%out.println(be_rset.getString("beTags"));%>
						</td>
					</tr>
					<tr>
						<td>
							<%
							/* allow user to edit a BlogEntry they created */
							if (be_rset.getInt("userID") == userInfo.userID) {
								%>
								<form action="edit_blog_entry.jsp" method="post">
									<input type="hidden" name="blogEntryID" value="<%out.println(be_rset.getInt("beID"));%>"/>
									<input type="hidden" name="blogTitle" value="<%out.println(be_rset.getString("blogTitle"));%>"/>
									<input type="submit" name="editBlogEntrySubmit" value="Edit this entry"/>
								</form>
								<br/>
								<br/>
								<%								
							}
							out.println(be_rset.getString("beText"));
							%>
						</td>
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
								<td>
									<%
									/* allow a user to edit a comment that they authored */
									if (cmnt_rset.getInt("bcUserID") == userInfo.userID) {
										%>
										<form action="edit_blog_comment.jsp" method="post">
											<input type="hidden" name="blogCommentID" value="<%out.println(cmnt_rset.getInt("bcID")); %>"/>
											<input type="hidden" name="blogEntryID" value="<%out.println(entryIDsToView[e]);%>"/>
											<input type="submit" name="editBlogCommentSubmit" value="Edit this comment"/>
										</form>
										<br/>
										<br/>
										<%
									}
									out.println(cmnt_rset.getString("bcText"));
									%>
								</td>
								<td><%out.println(cmnt_rset.getString("bcTitle"));%>
									<br/>by 
									<form action="display_profile.jsp" method="post">
										<input type="hidden" name="userProfileID" value="<%out.println(cmnt_rset.getInt("bcUserID")); %>"/>
										<input type="submit" name="viewUserProfileSubmit" value="<%out.println(comment_authorname); %>"/>
									</form>
									<br/>at 
									<%out.println(cmnt_rset.getString("bcDatePosted"));%>
								</td>
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
							<form action="search_blog_entries.jsp" method="post">
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
			out.println("You selected no entries/topics to view. Please go back and select some<br/>");
		}
	} else if (request.getParameter("addCommentSubmit") != null) {
		/* user is submitting a comment to be added to a specific BlogEntry */
	
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
				<a href="search_blog_entries.jsp">Return to viewing/searching for blog entries</a><br/>
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