class Edge
{
	public var fromNode:Node;
	public var toNode:Node; 
	public var mc;
	
	function Edge(from:Node, to:Node, clip) {
		fromNode = from;
		toNode = to;
		mc = clip;
	}
}
