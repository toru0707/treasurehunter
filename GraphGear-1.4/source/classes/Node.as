class Node extends MovieClip
{
	public var connectedList:Array;
	public var notConnectedList:Array; 
	public var dx:Number;
	public var dy:Number;
	public var cluster:String;
	public var scale;
	
	public var anchor:Boolean; // anchor nodes do not get repulsed or attracted themselves,
	 						   // although they may repulse and attract other nodes.
	
	function Node() {
		connectedList = new Array();
		notConnectedList = new Array();
		dx=0; dy=0;	
		cluster = "default";
		anchor = false;
		scale = 100;
	}
	
	public function addConnection(node:Node):Void {
		connectedList.push(node);
	}
	public function removeConnection(node:Node):Void {
		notConnectedList.push(node);
	}
	
	public function setAnchor(bool:Boolean):Void {
		anchor = bool;
	}
	
}