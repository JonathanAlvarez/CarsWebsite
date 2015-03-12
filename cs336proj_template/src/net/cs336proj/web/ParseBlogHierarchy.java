package net.cs336proj.web;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.TreeMap;

/**
 * Allows for various handy utility functions when dealing with hierarchical BlogEntry topics.
 * By caching the hierarchy data here, multiple accesses to the hierarchy data can avoid
 * hitting the database too much.
 */
public class ParseBlogHierarchy {
	public class HierNode {
		public int nodeID; // nodeIDs start at 1.
		public String nodeString;
		public int parentNodeID; // a NULL in the database column will be represented by [int = 0]. A NULL in the database represents a toplevel node.
		
		public HierNode(int nodeID, String nodeString, int parentNodeID) {
			this.nodeID = nodeID;
			this.nodeString = new String(nodeString);
			this.parentNodeID = parentNodeID;
		}
	}
	
	public ResultSet hierNodeData;
	public TreeMap<Integer, HierNode> hierTree;
	
	// constructor
	public ParseBlogHierarchy(ResultSet hierNodesFromDatabase) throws SQLException {
		if (hierNodesFromDatabase == null) throw new SQLException();
		
		this.hierNodeData = hierNodesFromDatabase;
		this.hierTree = new TreeMap<Integer, HierNode>();
		
		hierNodeData.beforeFirst();
		while (hierNodeData.next() == true) {
						
			HierNode new_node = new HierNode(hierNodeData.getInt("bhNodeID"), hierNodeData.getString("bhString"), hierNodeData.getInt("bhNodeParent"));
			this.hierTree.put(new_node.nodeID, new_node);
		}
		
		// finally create the top level node. necessary?
		this.hierTree.put(0, new HierNode(0, "/", 0));
	}
	/**
	 * Returns the level of the given node in the hierarchy tree. Top level nodes are on level 0
	 */
	public int HierarchyLevelOfNode(int nodeID) {
		int level = 0;
		
		if (nodeID != 0) {
			HierNode node = (HierNode)this.hierTree.get(nodeID);
			
			if (node != null) {
				level = 1 + HierarchyLevelOfNode(node.parentNodeID);
			}
			
		} // else we have the root node. it's level is defined to be 0
		
		return level;
	}
	/**
	 * Returns a formatted string representing the hierarchy path of the given nodeID.
	 * If nodeID doesn't exist, returns the "toplevel" AKA root of the hierarchy tree AKA "/"
	 */
	public String HierarchyPathOfNode(int nodeID) {
		HierNode node = (HierNode)this.hierTree.get(nodeID);
		
		String nodeString = new String("/");
		
		if (node != null) {
			nodeString = node.nodeString;
			
			if (node.parentNodeID != 0)
				// parsing starts at the bottom, so add this node's String to the end
				nodeString = HierarchyPathOfNode(node.parentNodeID)+ "/"+ nodeString;
			
			// else we've reached the top level node that has no parent.
		}
		
		return nodeString;
	}
	/**
	 * Creates a nice table of all nodes in the hierarchy with the specified user input-type for each node.
	 * The value attribute of each input field is the node's ID.
	 */
	public String SelectableXMLHierarchyNodes(String input_type, String input_name) throws SQLException {
		String XMLinput = new String("<table>");
		
		this.hierNodeData.beforeFirst();
		while (this.hierNodeData.next() == true) {
			HierNode node = (HierNode)this.hierTree.get(this.hierNodeData.getInt("bhNodeID"));
	
			XMLinput += "<tr><td><input type=\""+input_type+"\" name=\""+input_name+"\" value=\""+node.nodeID+"\"/> "+HierarchyPathOfNode(node.nodeID)+"</td><td>("+node.nodeString+")</td></tr>";
		}
	
		XMLinput += "</table>";
		
		return XMLinput;
	}
	/**
	 * Given a hierarchy path with delimiter "." (period), will return the nodeID that represents that path if it exists in the hierarchy
	 * Return -1 if given hierarchy path doesn't exist in the hierarchy.
	 */
	public int DiscoverNodeIDFromPath(String hierarchyPath) throws SQLException {
		int targetNodeID = -1;
		
		if (hierarchyPath != null) {
		
			hierarchyPath = hierarchyPath.replaceAll("\\.", "/"); // replace user-input delimiter with the internally used delimeter
			
			this.hierNodeData.beforeFirst();
			while (this.hierNodeData.next() == true) {
				HierNode node = (HierNode)this.hierTree.get(this.hierNodeData.getInt("bhNodeID"));
				
				String nodeHierPath = this.HierarchyPathOfNode(node.nodeID);
				if (hierarchyPath.equalsIgnoreCase(nodeHierPath)) {
					//System.out.println("&nbsp;&nbsp;comparing given path '"+hierarchyPath+"' to (nodeId "+node.nodeID+") path '"+nodeHierPath+"'<br/>");
					targetNodeID = node.nodeID;
					break;
				}
			}
		}
		
		return targetNodeID;
	}
	
}
