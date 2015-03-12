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
    <title>manage_friends.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
	    <h1>Friend Management</h1>
<a href="display_profile.jsp">Back to your profile/hub</a><br/><br/>

<form action="display_profile.jsp" method="post">
	View User Profile(Enter userID): <input type="text" name="userProfileID" /><br/>
	<input type="submit" name="viewUserProfileSubmit" value="View Profile" />
</form>
<br/><br/>
<form action="manage_friends.jsp" method="post">
	Sort by:<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="befriendedDESC" checked="checked"/>Sort by Date Befriended, Most Recent First<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="befriendedASC"/>Sort by Date Befriended, Oldest First<br/>
	<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="lastloginDESC"/>Sort by last login time, Most Recent First<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="lastloginASC"/>Sort by last login time, Oldest First<br/>
	<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="registerDESC"/>Sort by date joined, Most Recent First<br/>
	&nbsp;&nbsp;<input type="radio" name="sortBy" value="registerASC"/>Sort by date joined, Oldest First<br/>
	<br/>
	<br/>
	Show friends who<br/>
	&nbsp;&nbsp;username is like: <input type="text" name="searchUserName"/><br/>
	&nbsp;&nbsp;in the state: <input type="text" name="searchUserState"/><br/>
	&nbsp;&nbsp;in the city: <input type="text" name="searchUserCity"/><br/>
	<br/>
	<br/>
	<input type="submit" name="searchFriendsSubmit" value="search / sort friends"/>
</form>
<br/>
<br/>
<%
String where_clauses = new String();
String order_by = new String("ORDER BY ");
if (request.getParameter("searchFriendsSubmit") != null) {
	/* grab search criteria from user input */
	String searchUserName = request.getParameter("searchUserName").trim();
	String searchUserState = request.getParameter("searchUserState").trim();
	String searchUserCity = request.getParameter("searchUserCity").trim();
	
	if (searchUserName.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
		
		where_clauses += "u.username LIKE '%"+searchUserName+"%'";
	}
	if (searchUserState.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
		
		where_clauses += "u.userAddrState = '"+searchUserState+"'";
	}
	if (searchUserCity.length() > 0) {
		if (where_clauses.length() > 0)
			where_clauses += " AND ";
		
		where_clauses += "u.userAddrCity = '"+searchUserCity+"'";
	}
	
	if (where_clauses.length() > 0)
		where_clauses = " AND "+where_clauses;
	
	/* grab sort criteria from user input */
	String orderByCriteria = request.getParameter("sortBy");
	if (orderByCriteria.equals("befriendedDESC"))
		order_by += "hf.frDateBefriended DESC";
	else if (orderByCriteria.equals("befriendedASC"))
		order_by += "hf.frDateBefriended ASC";
	else if (orderByCriteria.equals("lastloginDESC"))
		order_by += "u.userDateLastLogin DESC";
	else if (orderByCriteria.equals("lastloginASC"))
		order_by += "u.userDateLastLogin ASC";
	else if (orderByCriteria.equals("registerDESC"))
		order_by += "u.userDateJoined DESC";
	else if (orderByCriteria.equals("registerASC"))
		order_by += "u.userDateJoined ASC";

} else {
	// first page load. use default of: display all friends and sort them by befriend date
	where_clauses = "";
	order_by += "hf.frDateBefriended DESC";
}


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
	
	if (request.getParameter("deleteFriendsSubmit") == null &&
		request.getParameter("acceptFriendRequestSubmit") == null &&
		request.getParameter("rejectFriendRequestSubmit") == null) {
		/* FIRST PAGE LOAD or User directed sort & filter of friends list */
		
		/* DISPLAY EXISTING FRIEND RELATIONSHIPS */	
		String frCount_query =
			"SELECT COUNT(hf.userID) as friend_count "+
			"FROM Profile p, hasFriend hf, Users u "+
			"WHERE p.userID = "+userInfo.userID+
				" AND p.pID = hf.pID "+
				" AND hf.userID = u.userID "+
				where_clauses;
		// get count of friends
		ResultSet fr_rset = stmt.executeQuery(frCount_query);
		if (fr_rset.next() == true && fr_rset.getInt("friend_count") > 0) {
			
			out.println("<h3>Found "+fr_rset.getInt("friend_count")+" friends</h3><br/><br/>");
			
			// get some basic info about friends. search according to search criteria and sort criteria.
			String query =
				"SELECT u.userID, u.username, u.userFirstname, u.userLastName, u.userDateJoined, u.userDateLastLogin"+
					", u.userAddrState, u.userAddrCity"+
					", hf.frDateBefriended, hf.userID as friendUserID "+
				"FROM Profile p, hasFriend hf, Users u "+
				"WHERE p.userID = "+userInfo.userID+
					" AND p.pID = hf.pID "+
					" AND hf.userID = u.userID "+
					where_clauses+" "+
				order_by;
			
			out.println("DEBUG: executing query<br/>"+query+"<br/><br/>");
			
			fr_rset = stmt.executeQuery(query);
			if (fr_rset.next() == true) {
				%>
				<form action="manage_friends.jsp" method="post">
					<input type="submit" name="deleteFriendsSubmit" value="Remove selected friends (defriend them)"/>
					<br/>
					<br/>
					<table border=1 cellpadding="10">
						<tr>
							<td>Defriend?</td>
							<td>Username</td>
							<td>Name</td>
							<td>Location</td>
							<td>Date befriended</td>
							<td>Date of Last Login</td>
							<td>Date joined</td>
							<td>Friend's userID</td>
						</tr>
					<%
					do {
						out.println("<tr>");
						out.println("<td><input type=\"checkbox\" name=\"deleteFriendUserIDs\" value=\""+fr_rset.getInt("friendUserID")+"\"</td>");
						out.println("<td>"+fr_rset.getString("username")+"</td>");
						out.println("<td>"+fr_rset.getString("userFirstname")+" "+fr_rset.getString("userLastName")+"</td>");
						out.println("<td>"+(fr_rset.getString("userAddrCity") != null ? fr_rset.getString("userAddrCity")+", " : "")+(fr_rset.getString("userAddrState") != null ? fr_rset.getString("userAddrState") : "")+"</td>");
						out.println("<td>"+fr_rset.getString("frDateBefriended")+"</td>");
						out.println("<td>"+fr_rset.getString("userDateLastLogin")+"</td>");
						out.println("<td>"+fr_rset.getString("userDateJoined")+"</td>");
						out.println("<td>"+fr_rset.getInt("userID")+"</td>");
						out.println("</tr>");
					} while (fr_rset.next() == true);
					%>
					</table>
				</form>
				<%
			} //else {
			//	out.println("Error: friend count is > 0, but wasn't able to retrieve the friends' info<br/>");
			//}
		} else {
			out.println("Found no friends<br/><br/>");
		}
		
		out.println("<br/><br/>");
		
		/* DISPLAY FRIEND REQUESTS */		
		String query = "SELECT bf.initiatorID, bf.bfDateSubmitted FROM befriend bf WHERE bf.recipientID = "+userInfo.userID;
		ResultSet frqst_rset = stmt.executeQuery(query);
		if (frqst_rset.next() == true) {
			
			%>
			<h3>You have requests from other users to becomes their 'friend'</h3><br/>
			<form action="manage_friends.jsp" method="post">
				<input type="submit" name="acceptFriendRequestSubmit" value="Accept selected friend requests"/><br/>
				<br/>
				<table border=1 cellpadding="10">
					<tr>
						<td>Accept/Reject it</td>
						<td>Username</td>
						<td>Name</td>
						<td>Location</td>
						<td>date request was sent</td>
						<td>potential friend's userID</td>
					</tr>
				<%
				do {
					out.println("<tr>");
					
					/* get userinfo about the requester */
					Statement rqstr_stmt = conn.createStatement();
					ResultSet rqstr_rset = rqstr_stmt.executeQuery(
						"SELECT u.userID, u.username, u.userFirstName, u.userLastName, u.userAddrState, u.userAddrCity"+
						" FROM Users u "+
						" WHERE u.userID = "+frqst_rset.getInt("initiatorID")
						);
					if (rqstr_rset.next() == true) {
						/* display the request*/
						out.println("<td><input type=\"checkbox\" name=\"selectedFriendRequests\" value=\""+frqst_rset.getInt("initiatorID")+"\"/></td>");
						out.println("<td>"+rqstr_rset.getString("username")+"</td>");
						out.println("<td>"+rqstr_rset.getString("userFirstName")+" "+rqstr_rset.getString("userLastName")+"</td>");
						out.println("<td>"+(rqstr_rset.getString("userAddrCity") != null ?rqstr_rset.getString("userAddrCity")+", ":"")+(rqstr_rset.getString("userAddrState") != null ? rqstr_rset.getString("userAddrState"):"")+"</td>");
						out.println("<td>"+frqst_rset.getString("bfDateSubmitted")+"</td>");
						out.println("<td>"+rqstr_rset.getInt("userID")+"</td>");
						
					} else {
						out.println("<td>Error. friend request initiator: userID "+frqst_rset.getInt("initiatorID")+" does not exist as a User</td>");
					}
					
					rqstr_stmt.close();
					
					out.println("</tr>");
				} while (frqst_rset.next() == true);
				%>
				</table>
				<input type="submit" name="rejectFriendRequestSubmit" value="Reject selected friend request"/><br/>
			</form>
			<%			
		} else {
			out.println("<br/>You have no friend requests<br/>");
		}
		
	} else if (request.getParameter("deleteFriendsSubmit") != null) {
		/* USER WANTS TO DELETE SELECTED FRIENDS */
		out.println("<br/>DEBUG: deleting friends<br/>");
		
		String[] friendUserIDtoDelete = request.getParameterValues("deleteFriendUserIDs");
		if (friendUserIDtoDelete != null) {

			int deleted_count = 0;
			for (int f = 0; f < friendUserIDtoDelete.length; f++) {
				// get the profile ID of the user and the friend.
				Statement user_stmt = conn.createStatement();
				ResultSet user_rset = user_stmt.executeQuery(
						"SELECT p1.pID as userPID, p2.pID as friendPID "+
						"FROM Profile p1, Profile p2 "+
						"WHERE p1.userID = "+userInfo.userID+
							" AND p2.userID = "+friendUserIDtoDelete[f]
				);
				if (user_rset.next() == true) {
					int userProfileID = user_rset.getInt("userPID");
					int friendProfileID = user_rset.getInt("friendPID");
				
					/* delete from user_profile-->friend */
					int rows_altered = stmt.executeUpdate("DELETE FROM hasFriend WHERE pID = "+userProfileID+" AND userID = "+friendUserIDtoDelete[f]);
					if (rows_altered != 1)
						out.println("Error trying to delete Friend with userID "+friendUserIDtoDelete[f]+" from "+userInfo.username+"'s profile ID "+userProfileID+"<br/>rows_altered in the delete request was "+rows_altered+"<br/><br/>");
					
					/* delete from friend_profile-->user */
					rows_altered = stmt.executeUpdate("DELETE FROM hasFriend WHERE pID = "+friendProfileID+" AND userID = "+userInfo.userID);
					if (rows_altered != 1)
						out.println("Error trying to delete "+userInfo.username+" with userID "+userInfo.userID+" from friend (userID "+friendUserIDtoDelete[f]+")'s profile ID "+friendProfileID+"<br/>rows_altered in the delete request was "+rows_altered+"<br/><br/>");
					
					deleted_count += 1;
					
				} else {
					out.println("ERROR: couldn't get "+userInfo.username+"'s (userID "+userInfo.userID+") profile ID or the friend-to-delete (userID "+friendUserIDtoDelete[f]+") profile ID<br/>");
				}
				
				user_stmt.close();
			}
			
			%>
			You successfully deleted <%out.println(deleted_count);%> friends from your profile<br/>
			<br/>
			<a href="manage_friends.jsp">Back to friends list</a><br/>
			<a href="display_profile.jsp">Display profile / back to hub</a><br/>			
			<%
			
		} else {
			out.println("You didn't specify any friend to defriend. Go Back and try again<br/>");
		}
	} else if (request.getParameter("acceptFriendRequestSubmit") != null ||
				request.getParameter("rejectFriendRequestSubmit") != null) {
		/* USER WANTS TO ACCEPT OR REJECT SOME FRIEND REQUESTS */
		out.println("DEBUG: accepting or rejecting friend requests<br/>");
		
		boolean accept_request = true;
		if (request.getParameter("acceptFriendRequestSubmit") == null)
			accept_request = false;
		
		String[] requesterUserID = request.getParameterValues("selectedFriendRequests");
		if (requesterUserID != null) {
			for (int r = 0; r < requesterUserID.length; r++) {
				
				/* regardless of accepting/rejecting request, the request is now garbage*/
				int rows_altered = stmt.executeUpdate("DELETE FROM befriend WHERE initiatorID = "+requesterUserID[r]+" AND recipientID = "+userInfo.userID);
				if (rows_altered > 0) {
					
					if (accept_request) {
						// get the profile ID of the user and the friend.
						Statement user_stmt = conn.createStatement();
						ResultSet user_rset = user_stmt.executeQuery(
								"SELECT p1.pID as userPID, p2.pID as friendPID "+
								"FROM Profile p1, Profile p2 "+
								"WHERE p1.userID = "+userInfo.userID+
									" AND p2.userID = "+requesterUserID[r]
						);
						if (user_rset.next() == true) {
							int userProfileID = user_rset.getInt("userPID");
							int requestorProfileID = user_rset.getInt("friendPID");

								/* add requestor-->user hasFriend */
								rows_altered = stmt.executeUpdate("INSERT INTO hasFriend(pID, userID) VALUES("+requestorProfileID+", "+userInfo.userID+")");
								if (rows_altered > 0) {
									/* add user-->requestor hasFriend*/
									rows_altered = stmt.executeUpdate("INSERT INTO hasFriend(pID, userID) VALUES("+userProfileID+", "+requesterUserID[r]+")");
									if (rows_altered > 0) {
										%>
										Successfully created friendship between you (userID <%out.println(userInfo.userID);%>) and userID <%out.println(requesterUserID[r]);%>
										<br/>
										<%
									} else {
										out.println("ERROR: failed to create  user-->requestor  hasFriend relationship<br/>");
									}
								} else {
									out.println("ERROR: failed to create  requestor-->user  hasFriend relationship<br/>");
								}
						} else {
							out.println("ERROR: couldn't get "+userInfo.username+"'s (userID "+userInfo.userID+") profile ID or the friend-to-add (userID "+requesterUserID[r]+") profile ID<br/>");
						}
						
						user_stmt.close();
					} else {
						out.println("Successfully Rejected request from userID "+requesterUserID[r]+"<br/>");
					}
				} else {
					out.println("ERROR: failed to remove befriend request from requestorUserID "+requesterUserID[r]+" to user's ID "+userInfo.userID+"<br/>");
				}
			}
		} else {
			out.println("You didn't specify any friend requests. Go Back and try again<br/>");
		}
	} else {
		out.println("This should never happend<br/>");
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
