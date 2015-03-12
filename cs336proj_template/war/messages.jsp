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

<%@page import="java.util.Vector"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>messages.jsp</title>
    <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>
    <meta content="en" http-equiv="content-language"/>
    <meta content="no-cache" http-equiv="Cache-Control"/>
  </head>
<body>
    <h1>Send/Receive Messages</h1>
<%

SessionInfo userInfo = (SessionInfo)session.getValue("info");

if (request.getParameter("messageTextArea") == null &&
	request.getParameter("sendToUsername") == null &&
	request.getParameter("sendMessageSubmitButton") == null &&
	request.getParameter("deleteMsgsSubmitButton") == null)
{
	/* first load of message page */
	out.println("FIRST LOAD OF MESSAGE PAGE<br/><br/>");
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
				"SELECT p.pID "+
				"FROM Profile p "+
				"WHERE p.userID = "+userInfo.userID
				);
			
		if (rset.next() == true) {
			int profileID = rset.getInt("pID");
			/* have the profile ID of the user. */
			
			/*********************************/
			/* (1) Display send message input form */
			%>
			<form action="messages.jsp" method="post">
				Type message below:<br/>
				<textarea name="messageTextArea" cols=40 rows=4></textarea><br/><br/>
				
				Send message to username: <input type="text" name="sendToUsername"/><br/>
				<input type="submit" name="sendMessageSubmitButton" value="Send message"/><br/>
				
			</form>
			<%
			/********************************************/
			/* (2) Display all of this PROFILE's RECEIVED messages */
			/*rset = stmt.executeQuery(
					"SELECT m.msgID, m.msgText, m.msgDatePosted, m.msgFromID, m.msgToID "+
					"FROM hasMessage hm, Messages m, MessagesDeletionState mdstate "+
					"WHERE hm.pID = "+profileID+
						" AND hm.msgID = m.msgID" +
						" AND mdstate.msgID = m.msgID" +
						" AND mdstate.msgDeletedByReceiver = false"
					);*/
			/*rset = stmt.executeQuery(
					"SELECT m.msgID, m.msgText, m.msgDatePosted, m.msgFromID, m.msgToID "+
					"FROM Messages m, MessagesDeletionState mdstate "+
					"WHERE m.msgToID = "+userInfo.userID +
						" AND mdstate.msgID = m.msgID" +
						" AND mdstate.msgDeletedByReceiver = false"
					);*/
			rset = stmt.executeQuery(
					"SELECT m.msgID, m.msgText, m.msgDatePosted, m.msgFromID, m.msgToID "+
					"FROM Messages m  "+
					"WHERE m.msgToID = "+userInfo.userID +
						" AND m.msgDeletedByReceiver = false"
					);
			if (rset.next() == true) {
				/* gather all the usernames of the senders of the received messages */
				Vector<String> msgFrom_usernames = new Vector<String>();
				Statement stmt_msgFrom = conn.createStatement();
				ResultSet msgFrom_rset;
				do {
					msgFrom_rset = stmt_msgFrom.executeQuery(
							"SELECT u.username "+
							"FROM Users u "+
							"WHERE u.userID = "+ rset.getInt("msgFromID")
							);
					if (msgFrom_rset.next() == true) {
						msgFrom_usernames.add(msgFrom_rset.getString("username"));
					} else {
						out.println("<br/>ERROR getting user name for userID "+rset.getInt("msgFromID")+"(msgFromID of a received message ID"+rset.getInt("msgID")+")<br/>");
						break;
					}
				} while (rset.next() == true);
				rset.beforeFirst();
				stmt_msgFrom.close();
				
				/* display the sent messages in a table*/
				%>
				<form action="messages.jsp" method="post">
					<input type="submit" name="deleteMsgsSubmitButton" value="Delete selected messages"/>
					
					<br/>MESSAGES RECEIVED FROM OTHER USERS:<br/>
					<table border=1 cellpadding="10">
						<tr><td>Delete it</td><td>From</td><td>Message</td><td>Date Received</td><td>(msgID)</td></tr>
						<%
						for (int m = 0; rset.next() == true; m++) {
							%>
							<tr>
								<td><input type="checkbox" name="deleteMsgIDs" value="<%out.println(rset.getInt("msgID"));%>"/></td>
								<td><%out.println(msgFrom_usernames.elementAt(m));%> (<%out.println(rset.getInt("msgFromID"));%>)</td>
								<td><%out.println(rset.getString("msgText"));%></td>
								<td><%out.println(rset.getString("msgDatePosted"));%></td>
								<td><%out.println(rset.getInt("msgID"));%></td>
							</tr>
							<%
						}
						%>
					</table>
				</form>
				<%	
			} else {
				/* This userID has no messages received in their profile */
				%>
				<br/>You've no received no messages<br/>
				<%
			}
			/*************************************/
			/* (3) Display all of this USER's SENT messages */
			/*rset = stmt.executeQuery(
					"SELECT m.msgID, m.msgText, m.msgDatePosted, m.msgFromID, m.msgToID "+
					"FROM Messages m, MessagesDeletionState mdstate "+
					"WHERE m.msgFromID = "+ userInfo.userID +
						" AND mdstate.msgID = m.msgID" +
						" AND mdstate.msgDeletedBySender = false"
					);*/
			rset = stmt.executeQuery(
					"SELECT m.msgID, m.msgText, m.msgDatePosted, m.msgFromID, m.msgToID "+
					"FROM Messages m "+
					"WHERE m.msgFromID = "+ userInfo.userID +
						" AND m.msgDeletedBySender = false"
					);
			if (rset.next() == true) {
				/* gather all the usernames of the recipients of the sent messages */
				Vector<String> msgTo_usernames = new Vector<String>();
				Statement stmt_msgTo = conn.createStatement();
				ResultSet msgTo_rset;
				do {
					msgTo_rset = stmt_msgTo.executeQuery("SELECT u.username FROM Users u WHERE u.userID = "+ rset.getInt("msgToID"));
					if (msgTo_rset.next() == true) {
						msgTo_usernames.add(msgTo_rset.getString("username"));
					} else {
						out.println("<br/>ERROR getting user name for userID "+rset.getInt("msgToID")+"(msgToID of sent message ID"+rset.getInt("msgID")+")<br/>");
						break;
					}
				}
				while (rset.next() == true);
				rset.beforeFirst();
				stmt_msgTo.close();
				
				/* display the sent messages in a table*/
				%>
				<form action="messages.jsp" method="post">
					<input type="submit" name="deleteMsgsSubmitButton" value="Delete selected messages"/>
				
					<br/>MESSAGES SENT BY YOU TO OTHER USERS:<br/>
					<table border=1 cellpadding="10">
						<tr><td>Delete it</td><td>To</td><td>Message</td><td>Date Sent</td><td>(msgID)</td></tr>
						<%
						for (int m = 0; rset.next() == true; m++) {
							%>
							<tr>
								<td><input type="checkbox" name="deleteMsgIDs" value="<%out.println(rset.getInt("msgID"));%>"/></td>
								<td><%out.println(msgTo_usernames.elementAt(m));%> (<%out.println(rset.getInt("msgToID"));%>)</td>
								<td><%out.println(rset.getString("msgText"));%></td>
								<td><%out.println(rset.getString("msgDatePosted"));%></td>
								<td><%out.println(rset.getInt("msgID"));%></td>
							</tr>
							<%
						}
						%>
					</table>
				</form>
				<%			
			} else {
				/* This userID has not sent any messages out to other users */
				%>
				<br/>You've not sent out any messages to other users<br/>
				<%
			}		
				
		} else {
			/* failure to get user's Profile ID */
			out.println("Error: Tried to get '"+userInfo.username+"''s profile ID. Could not associate userID" + userInfo.userID + "with any profile<br/>");
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
} else if (request.getParameter("messageTextArea") != null &&
		request.getParameter("sendToUsername") != null &&
		request.getParameter("sendMessageSubmitButton") != null)
	{
	/* user is sending a message */
	String message = request.getParameter("messageTextArea").trim();
	String sendToUsername = request.getParameter("sendToUsername").trim();
	
	if (sendToUsername.compareToIgnoreCase(userInfo.username) == 0) {
		%>
		You're not allowed to send yourself messages<br/>
		<a href="messages.jsp">Go back to Messages</a>
		<%
	} else {
	
		if (message != null) {
			if (sendToUsername != null) {
				// user specifed a message and a username to send it to
				
	
				out.println("FIRST LOAD OF MESSAGE PAGE<br/><br/>");
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
					
					
					/* check if username exists in the database */
					ResultSet rset = stmt.executeQuery(
							"SELECT u.userID "+
							"FROM Users u "+
							"WHERE STRCMP(u.username, '"+sendToUsername+"') = 0" // STRCMP is case insensitive.
							);
						
					if (rset.next() == true) {
						int sendToUserID = rset.getInt("userID");
						/* get that user's profile ID */
						rset = stmt.executeQuery(
							"SELECT p.pID "+
							"FROM Profile p "+
							"WHERE p.userID = "+sendToUserID
							);
						if (rset.next() == true) {
							int sendToUserProfileID = rset.getInt("pID");
							/* all required info has been collected. now create a new Message row/entry */
							
							//  figure out a msgID that is not taken yet (assumes deleted msgIDs are never reused)
							int new_msgID = 1;
							Statement new_msgID_stmt = conn.createStatement();
							ResultSet next_msgID_rset = new_msgID_stmt.executeQuery("SELECT MAX(m.msgID) FROM Messages m");
							if (next_msgID_rset.next() == true)
								new_msgID = 1 + next_msgID_rset.getInt(1);
							new_msgID_stmt.close(); 
							out.println("<br/>Debug: new msgID will be "+new_msgID+"<br/>");
							
							String update_query =	"INSERT INTO Messages(msgID, msgText, msgDatePosted, msgFromID, msgToID) "+
													"VALUES("+new_msgID+", '"+message+"', CURRENT_TIMESTAMP, "+userInfo.userID+", "+sendToUserID+")";
							out.println("Debug: executing update query '"+update_query+"'<br/>");
							int rows_altered = stmt.executeUpdate(update_query);
							out.println("Debug: "+rows_altered+" rows altered after update <br/><br/");
									
							if (rows_altered > 0) {
								/* create a new hasMessages row (destination user's pID, new msgID) */
								/*update_query = "INSERT INTO hasMessage(pID, msgID) VALUES ("+sendToUserProfileID+", "+new_msgID+")";
								out.println("Debug: executing update query '"+update_query+"'<br/>");
								rows_altered = stmt.executeUpdate(update_query);
								out.println("Debug: "+rows_altered+" rows altered after update <br/><br/");*/
								
								if (rows_altered > 0) {
									/* SUCCESSfully entered a new message into all the right places in the database */
									%>
									Your message (with <%out.println(message.length());%> characters) to <%out.println(sendToUsername);%> has successfully been delivered
									<br/><br/>
									<a href="messages.jsp">Return to your Messages</a>
									<%
									
								} else {
									/* error creating entry in hasMessage. Must rollback row inserting into Message in order to maintain relational integrity
									XXX: could this be done with a trigger or constraint in mySQL?
									*/
									out.println("ERROR: failed to associate user '"+sendToUsername+"' (userID "+sendToUserID+")'s profile id "+sendToUserProfileID+" with newly creaed message id "+new_msgID+" in hasMessage table<br/>");
									out.println("&nbsp;&nbsp;&nbsp;&nbsp; deleting the newly created message (msgID "+new_msgID+") from Message table to maintain database sanity/integrity<br/>");
									rows_altered = stmt.executeUpdate("DELETE FROM Message WHERE msgID = "+new_msgID);
									out.println("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+rows_altered+" rows successfully removed from Message table<br/>");
								}
								
							} else {
								/* did not successfully create a new Message row/entry */
								out.println("ERROR: unable to create/send new message (msgID would've been "+new_msgID+")<br/>");
							}
							
							
						} else {
							/* critical error. a userID is not associated with a pID */
							out.println("ERROR: user to send message ("+sendToUsername+") to's userID "+sendToUserID+" is NOT associated with a Profile pID<br/>");
						}
					} else {
						/* the specfied [username to send the message to] doesn't exist in the database */
						%>
						No user with username '<%out.println(sendToUsername);%>' exists!<br/>
						Try entering a different username to send the message to<br/><br/>
						<form action="messages.jsp" method="post">
							Type message below:<br/>
							<textarea name="messageTextArea" cols=40 rows=8><%out.println(message);%></textarea><br/><br/>
							
							Send message to username: <input type="text" name="sendToUsername"/><br/>
							<input type="submit" name="sendMessageSubmitButton" value="Send message"/>
							
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
				/* user typed in a message, but didn't specify what user to send it to */
				%>
				You have to send the message to some username.<br/>
				Please type the username of the person you're sending the message to.<br/><br/>"
				<form action="messages.jsp" method="post">
					Type message below:<br/>
					<textarea name="messageTextArea" cols=40 rows=8><%out.println(message);%></textarea><br/><br/>
					
					Send message to username: <input type="text" name="sendToUsername"/><br/>
					<input type="submit" name="sendMessageSubmitButton" value="Send message"/>
					
				</form>
				<%
			}
		} else {
			/* user filled out "send message to this username" text field but left message blank */
			%>
			You cannot send empty messages.<br/>
			Please type something as a message you intended to send to '<%out.println(sendToUsername);%>'<br/><br/>"
			<form action="messages.jsp" method="post">
				Type message below:<br/>
				<textarea name="messageTextArea" cols=40 rows=8></textarea><br/><br/>
				
				Send message to username: <input type="text" name="sendToUsername" value="<%out.println(sendToUsername);%>"/><br/>
				<input type="submit" name="sendMessageSubmitButton" value="Send message"/>
				
			</form>
			<%
		}
	}
	
} else if (request.getParameter("deleteMsgsSubmitButton") != null) {
	/* user is deleting some of their messages */
	out.println("DELETING MESSAGES<br/>");
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

		String[] msgIDsToDelete = request.getParameterValues("deleteMsgIDs");
		
		if (msgIDsToDelete != null) {
			for (int m = 0; m < msgIDsToDelete.length; m++) {
				
				/* first determine if user is the receiver or sender of this msgID */
				ResultSet m_rset = stmt.executeQuery("SELECT m.msgToID, m.msgFromID FROM Messages m WHERE m.msgID = "+msgIDsToDelete[m]);
				if (m_rset.next() == true) {
					Statement update_stmt = conn.createStatement();
					String update_query = new String();
					int rows_altered = 0;
					boolean msgstate_updated = false;
					
					if (userInfo.userID == m_rset.getInt("msgToID")) {
						/* user is the receiver of the msg to delete */
						update_query = "UPDATE Messages SET msgDeletedByReceiver=true WHERE msgID = "+msgIDsToDelete[m];
						rows_altered = update_stmt.executeUpdate(update_query);
						msgstate_updated = true;
						
						out.println("DEBUG: receiver deleting: "+rows_altered+" rows altered by query '"+update_query+"'<br/>");
						
					} else if (userInfo.userID == m_rset.getInt("msgFromID")) {
						/* user is the sender of the msg to delete */
						update_query = "UPDATE Messages SET msgDeletedBySender=true WHERE msgID = "+msgIDsToDelete[m];
						rows_altered = update_stmt.executeUpdate(update_query);
						msgstate_updated = true;
						
						out.println("DEBUG: sender deleting "+rows_altered+" rows altered by query '"+update_query+"'<br/>");
						
					} else {
						out.println("ERROR: user "+userInfo.username+" (userID "+userInfo.userID+") tried to delete msgID "+msgIDsToDelete[m]+" and wasn't the sender or receiver of that message<br/>");
					}
					
					/* must clean up database manually because mySQL trigger support is severly lacking */
					if (msgstate_updated) {
						rows_altered = update_stmt.executeUpdate("DELETE FROM Messages WHERE msgDeletedByReceiver = true AND msgDeletedBySender = true");
						if (rows_altered > 0) out.println("----deleted "+rows_altered+" rows<br/>");
						else out.println("----no rows needed deleting from Messages rows<br/>");
	
					}
					
					out.println("You deleted "+rows_altered+" messages<br/><br/>");
					out.println("<a href=\"messages.jsp\">Go back to Messages</a>");
					
					update_stmt.close();
				} else {
					out.println("ERROR: the msgID "+msgIDsToDelete[m]+" specified in a delete request was not found in the Messages table<br/>");
				}
			}
		} else {
			out.println("You didn't select any messages to delete. Go back and try again<br/>");
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
	out.println("this conditional case should never happen<br/>");
}

%>

</body>
</html>