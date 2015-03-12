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
    <title>post_to_blog.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>Post to Blog/Create Forum Topic</h1>

<a href="view_own_blog.jsp">View Blogs</a><br/>
<a href="search_blog_entries.jsp">View Forum Topics</a><br/>

<%
SessionInfo userInfo = (SessionInfo)session.getValue("info");
Connection conn = null;
Statement stmt = null;

if (request.getParameter("submitBlogEntry")==null &&
	request.getParameter("submitBlogTitle")==null)
{
	/* first visit to page */
	
	try {
		String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
		conn=null;
		Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
		Properties result = driver.parseURL(connectionURL, new Properties());
		
		// i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful)
		out.println("Connection Information: " + result + "<br/><br/><br/>");
		
		conn = DriverManager.getConnection(connectionURL, result);
		stmt = conn.createStatement();
		
		ResultSet rset = stmt.executeQuery(
				"SELECT b.pID, b.bTitle "+
				"FROM Profile p, Blog b "+
				"WHERE p.userID = "+userInfo.userID+
					" AND b.pID = p.pID"
				);
		if (rset.next() == false) {
			/* user doesn't have a Blog yet */
			rset = stmt.executeQuery("SELECT p.pID FROM Profile p WHERE p.userID = "+userInfo.userID);
			if (rset.next() == true) {
				/* save user's pID in session so we dont have to query it after user submits a blog title */
				session.putValue("pID", rset.getInt("pID"));
				%>
				You must create a Blog before posting any messages<br/>
				Please give your Blog a name/title. It must be unique among the entire website<br/>
				<form action="post_to_blog.jsp" method="post">
					<input type="text" name="blogTitle"/><br/>
					<input type="submit" name="submitBlogTitle" value="Create your own blog"/>
				</form>
				<%
			} else {
				out.println("ERROR: couldn't find user ID"+userInfo.userID+"'s profile ID<br/>");
			}
			
		} else {
			/* user has a Blog, so allow them to create a blog entry */
			%>
			<form action="post_to_blog.jsp" method="post">
				FIRST VISIT TO PAGE.<br/>
				<h3>You must give a title and some content to create a topic/entry</h3><br/>
				<br/>
				Title of BlogEntry/ForumTopic:<br/>
				<input type="text" name="entryTitle"/><br/>
				<br/>
				Content of the entry/topic:<br/>
				<textarea name="entryText" cols=40 rows=4></textarea><br/>
				<br/>
				<br/>
				<h3>Optional info:</h3>
				Tags (comma separated): <input type=text" name="entryTags"/><br/>
				<br/>
				<br/>
				File your topic/entry under a category.  Choose to create a new category or select an existing one.<br/>
				Create your own topic category, separate the hierarchy levels with a period<br/>
				ex: trucks.work.hauling<br/>
				<input type="text" name="newTopicHierarchy"/><br/>
				<br/>
				Choose an existing topic category:<br/>
				<%
					/* Print out the tree of existing topic hierarchies
					 * the entries are radio-button inputs with name="entryHierarchy"
					 */
					Statement hier_stmt = conn.createStatement();
					ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy");
					ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);
					
					out.println(hierarchy.SelectableXMLHierarchyNodes("radio", "entryHierarchy"));
					
					hier_stmt.close();
				%>
				<br/>
				<br/>
				<input type="submit" name="submitBlogEntry" value="submit blog post"/>
			</form>
			<%			
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

} else if (request.getParameter("submitBlogEntry") != null) {
	/* user is submitting a BlogEntry */
	String entryTitle = request.getParameter("entryTitle");
	String entryText = request.getParameter("entryText");
	String entryTags = request.getParameter("entryTags");
	String selectedHierarchy = request.getParameter("entryHierarchy");
	String typedHierarchy = request.getParameter("newTopicHierarchy");
	
	if (entryTitle != null) entryTitle = entryTitle.trim();
	if (entryText != null) entryText = entryText.trim();
	if (entryTags != null) entryTags = entryTags.trim();
	if (typedHierarchy != null) typedHierarchy = typedHierarchy.trim();
	

	
	if (entryTitle.length() > 0 &&
		entryText.length() > 0) {
		/* user gave at least a title and content for the BlogEntry */
		try {
			String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
			conn=null;
			Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
			Properties result = driver.parseURL(connectionURL, new Properties());
			
			/* i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful) */
			out.println("Connection Information: " + result + "<br/><br/><br/>");
			
			conn = DriverManager.getConnection(connectionURL, result);
			stmt = conn.createStatement();
			
			/* must get the profile ID of user in order to get the user's Blog */
			ResultSet rset = stmt.executeQuery(
					"SELECT b.pID, b.bTitle "+
					"FROM Profile p, Blog b "+
					"WHERE p.userID = "+userInfo.userID+
						" AND b.pID = p.pID"
					);
			if (rset.next() == true) {
				int profileID = rset.getInt("pID");
				String blogTitle = rset.getString("bTitle");
				
				/* santize/normalize the tag string into format "tag, tag, tag, tag" */
				String tags_normalized = new String();
				if (entryTags.length() > 0) {
					String[] tags = entryTags.split(",");
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
				
				/* determine the BlogHierarchy nodeID to give this new BlogEntry */
				int hierarchyNodeID = 0;
				if (typedHierarchy.length() > 0) {
					// if user typed their own hierarchy path, we'll use that regardless if they selected an existing hierarchy node
							
					/* determine if the hierarchy path already exists */
					Statement hier_stmt = conn.createStatement();
					ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy");

					ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);
					hierarchyNodeID = hierarchy.DiscoverNodeIDFromPath(typedHierarchy);
					
					if (hierarchyNodeID == -1) {
						// user's hierarchy path doesn't exist.  Must create it.
						
						out.println("DEBUG: user given path '"+typedHierarchy.replaceAll("\\.", "/")+"' doesn't exist in the DB hierarchy, must create it...<br/>");
						
						/* must go through every level of the hierarchy and insert nodes as necessary to complete the hierarchy. */
						
						// chop up the path into its individual levels
						java.util.Vector<String> hierNodeStrings = new java.util.Vector<String>();
						int searchIndex = 0;
						int delim_index = typedHierarchy.indexOf('.', searchIndex);
						while (delim_index != -1) {
							String substr = typedHierarchy.substring(searchIndex, delim_index).trim();
							// skip contiguous delimiters and empty tokens ( ".."   ".    .")
							if (substr.length() > 0) {
								hierNodeStrings.addElement(substr);
							}
							
							// continue splitting the path
							searchIndex = delim_index + 1;
							delim_index = typedHierarchy.indexOf('.', searchIndex);
						}
						// grab the last (or first & only) token
						String substr = typedHierarchy.substring(searchIndex).trim();
						if (substr.length() > 0) {
							hierNodeStrings.addElement(substr);
						}
						
						// go through each level, verifying where on the user given path the hierarchy doesnt exist
						int nodeParentID = 0;
						for (int l = 0; l < hierNodeStrings.size(); l++) {
							
							// construct the path up to the current level
							String hierPath = new String();
							for (int i = 0; i <= l; i++) {
								if (i == 0)
									hierPath = hierNodeStrings.elementAt(i);
								else
									hierPath += "." + hierNodeStrings.elementAt(i);
							}
							
							hierarchyNodeID = hierarchy.DiscoverNodeIDFromPath(hierPath);
							if (hierarchyNodeID == -1) {
								// node doesn't exist in hierarchy, so add IT and all its children
								
								out.println("DEBUG: node '"+hierPath+"' doesn't exist in hierarchy, creating it and all of its childrens' nodes...<br/>");
								
								//int nodeParentID = 0;
								Statement ins_stmt = conn.createStatement();
								for (int subl = l; subl < hierNodeStrings.size(); subl++) {
									
									String insQuery = "INSERT INTO BlogHierarchy(bhString, bhNodeParent) ";
									insQuery += " VALUES ('"+hierNodeStrings.elementAt(subl)+"', ";
									
									if (nodeParentID == 0)
										insQuery += "NULL"; // inserting a toplevel node
									else
										insQuery += nodeParentID; // inserting a child node
									
									insQuery +=")";
									
									out.println("DEBUG: inserting new node: '"+insQuery+"'<br/>");
									
									ins_stmt.executeUpdate(insQuery);
									
									// newly inserted node will have the highest NodeID since its automatically incremented by mySQL
									ResultSet newNode_rset = ins_stmt.executeQuery("SELECT MAX(bh.bhNodeID) from BlogHierarchy bh");
									newNode_rset.next();
									hierarchyNodeID = newNode_rset.getInt(1);
									nodeParentID = newNode_rset.getInt(1);
								}
								ins_stmt.close();
								break; // stop searching since we completed the hierarchy.
							} else {
								// node already exists so continue checking the rest of the given path
								// set up next node's parent ID in case we need to create the next node
								out.println("DEBUG: hierarchy path '"+hierPath+"' already exists (nodeID "+hierarchyNodeID+")<br/>");
								out.println("       continuing verifying typed path '"+typedHierarchy+"'....<br/>");
							}
							nodeParentID = hierarchyNodeID;
							
						}
						
						out.println("DEBUG: done creating new hierarchy path. the path's new nodeID is "+hierarchyNodeID+"<br/>");
					}
					else out.println("DEBUG: user given path '"+typedHierarchy+"' exists already in database, nodeID for the path is "+hierarchyNodeID+"<br/>");

					
					
				} else if (selectedHierarchy != null) {
					// use the selected nodeID (use existing hierarchy)
					hierarchyNodeID = Integer.parseInt(selectedHierarchy);
					out.println("<br/>DEBUG: using selected node ID as topic hierarchy "+hierarchyNodeID+"<br/>"); 
				}
				
				/* insert the new BlogEntry */
				String update_query =
					"INSERT INTO BlogEntry(bTitle, beTitle, beText, beDatePosted, beTags, beHierarchyBottom)" +
					" VALUES('"+blogTitle+"', " +
							"'"+entryTitle+"', " +
							"'"+entryText+"', " +
							"CURRENT_TIMESTAMP, " +
							"'"+(tags_normalized.length() > 0 ? tags_normalized : "")+"', "+
							(hierarchyNodeID == 0 ? "NULL" : hierarchyNodeID)+
					")";

				out.println("DEBUG: sending update query '"+update_query+"' <br/>");
				
				int rows_altered = stmt.executeUpdate(update_query);
				
				if (rows_altered > 0) {
					%>
					Successfully created your blogEntry/forum thread<br/>
					<a href="display_profile.jsp">Go back to display profile / the hub page</a>
					<%
					
				} else {
					out.println("Failed to create BlogEntry<br/>");
				}
				
				
			} else {
				out.println("ERROR couldn't get userID "+userInfo.userID+"'s blog title<br/>");
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
		
	} else {
		/* user didn't give the required infomation */
		try {
			String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
			conn=null;
			Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
			Properties result = driver.parseURL(connectionURL, new Properties());
			
			/* i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful) */
			out.println("Connection Information: " + result + "<br/><br/><br/>");
			
			conn = DriverManager.getConnection(connectionURL, result);
			stmt = conn.createStatement();
			
			%>
			<h4>You must supply both a title and content</h4><br/>
			<form action="post_to_blog.jsp" method="post">
				Title of BlogEntry/ForumTopic:<br/>
				<input type="text" name="entryTitle" value="<%out.println(entryTitle);%>"/><br/>
				<br/>
				Content of the entry/topic:<br/>
				<textarea name="entryText" cols=40 rows=4><%out.println(entryText);%></textarea><br/>
				<br/>
				<br/>
				<h3>Optional info:</h3>
				Tags (comma separated): <input type=text" name="entryTags" value="<%out.println(entryTags != null ? entryTags : "");%>"/><br/>
				<br/>
				<br/>
				File your topic/entry under a category.  Choose to create a new category or select an existing one.<br/>
				Create your own topic category, separate the hierarchy levels with a period<br/>
				ex: trucks.work.hauling<br/>
				<input type="text" name="newTopicHierarchy" value="<%out.println(typedHierarchy != null ? typedHierarchy : "");%>"/><br/>
				<br/>
				Choose an existing topic category:<br/>
				<%
					/* Print out the tree of existing topic hierarchies
					 * the entries are radio-button inputs with name="entryHierarchy"
					 */
					Statement hier_stmt = conn.createStatement();
					ResultSet hier_rset = hier_stmt.executeQuery("SELECT * FROM BlogHierarchy");
					ParseBlogHierarchy hierarchy = new ParseBlogHierarchy(hier_rset);
					
					out.println(hierarchy.SelectableXMLHierarchyNodes("radio", "entryHierarchy"));
					
					hier_stmt.close();
				%>
				<br/>
				<br/>
				<input type="submit" name="submitBlogEntry" value="submit blog post"/>
			</form>
			<%			
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
} else if (request.getParameter("submitBlogTitle") != null) {
	/* user needed to create a blog before posting */
	if (request.getParameter("blogTitle") != null) {
		String blogTitle = request.getParameter("blogTitle").trim();
		
		if (blogTitle.length() > 0) {
			/* check if blog title is unique */
			try {
				String connectionURL ="jdbc:mysql://localhost/cs336?user=cs336&password=cs930396";
				conn=null;
				Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
				Properties result = driver.parseURL(connectionURL, new Properties());
				
				// i include the following line ONLY for debugging/tracing information! please don't include this kind of output in your final project (protip - using a session variable like "DEBUG" to enable/disable debugging output is useful)
				out.println("Connection Information: " + result + "<br/><br/><br/>");
				
				conn = DriverManager.getConnection(connectionURL, result);
				stmt = conn.createStatement();
				
				ResultSet rset = stmt.executeQuery(
						"SELECT * FROM Blog b WHERE STRCMP(b.bTitle, '"+blogTitle+"') = 0");
				if (rset.next() == false) {
					/* user has given a unique blog title. so insert it into the database */
					int profileID = ((Integer)session.getValue("pID")).intValue(); // saved from first load of this page
					String update_query = "INSERT INTO Blog(bTitle, pID) VALUES('"+blogTitle+"', "+profileID+")";
					
					out.println("DEBUG: going to send update query '"+update_query+"' <br/>");
					
					int rows_altered = stmt.executeUpdate(update_query);
					if (rows_altered > 0) {
						%>
						Successfully created your blog '<%out.println(blogTitle);%>'<br/>
						You can now create a new BlogEntry/Forum topic!<br/>
						<a href="post_to_blog.jsp">Post an entry/topic</a>
						<%
					} else {
						out.println("couldn't insert new blogtitle into Blog table<br/>");
					}
					
				} else {
					%>
					Blog title '<%out.println(blogTitle);%>' already exists. Pick another one.<br/>
					Please give your Blog a name/title. It must be unique among the entire website<br/>
					<form action="post_to_blog.jsp" method="post">
						<input type="text" name="blogTitle"/><br/>
						<input type="submit" name="submitBlogTitle" value="Create your blog"/>
					</form>
					<%
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
			
		} else {
			%>
			A title for a blog must contain visible characters<br/>
			Please give your Blog a name/title. It must be unique among the entire website<br/>
			<form action="post_to_blog.jsp" method="post">
				<input type="text" name="blogTitle"/><br/>
				<input type="submit" name="submitBlogTitle" value="Create your blog"/>
			</form>
			<%		
		}
	} else {
		%>
		A title for a blog is required<br/>
		Please give your Blog a name/title. It must be unique among the entire website<br/>
		<form action="post_to_blog.jsp" method="post">
			<input type="text" name="blogTitle"/><br/>
			<input type="submit" name="submitBlogTitle" value="Create your blog"/>
		</form>
		<%		
	}
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
