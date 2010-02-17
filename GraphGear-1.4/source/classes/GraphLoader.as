import flash.external.ExternalInterface;
import Delegate;
import com.visualcondition.twease.*;

class GraphLoader {
	public var graphsource;
	public var nList = new Array();
	public var eList = new Array();
	public var mcl:MovieClipLoader;
	public var actionAnimation:Boolean = false;
	
	function GraphLoader() {
		// Animation Functions
		Twease.register(Easing); //this registers the Easing class

		_root.liveXML = false;
		if(_root.graphXMLFile == null) {_root.graphXMLFile = "sample.xml";}
		mcl = new MovieClipLoader();
		ExternalInterface.addCallback("liveXML", this, processLiveXML);
		ExternalInterface.addCallback("switchXML", this, processSwitchXML);
		ExternalInterface.addCallback("changeProperty", this, adjustProperty);
		
		ExternalInterface.addCallback("addNode", this, jsAddNode);
		ExternalInterface.addCallback("addRandomNode", this, addRandomNode);
		
		MovieClip.prototype.setRGB = function(newColor) {
			(new Color(this)).setRGB(newColor);
		}
		activateSource();
		// Should be static function main
		GraphLoaderAction();
		
	}

	/* Function: GraphLoaderAction
	   Checks for available XML Graph sources before calling BuildGraph to construct a graph */
	public function GraphLoaderAction() {
		graphsource = new XML();
		graphsource.ignoreWhite = true;
		graphsource.onLoad = Delegate.create(this, BuildGraph);
		if(_root.liveXML == false) {
			
			graphsource.load(_root.graphXMLFile);
		}
		else {
			graphsource.parseXML(_root.liveXML);
			_root.liveXML = false;
			trace("building graph");
			BuildGraph(true);
		}
	}

	/* Function: BuildGraph
	   Handler to XML graph file, constructs a native GraphVis object.
	   Parameters:
	      success - The success or failure of the xml load operation.*/	
	public function BuildGraph(success) {

		_root.Graph.GraphFrame.GraphBG.setRGB("0x" + graphsource.firstChild.attributes.bgcolor);
		_root.Graph.edgeColor = "0x" + graphsource.firstChild.attributes.linecolor;
		_root.GraphTitle.htmlText = graphsource.firstChild.attributes.title;
		_root.linkColor = graphsource.firstChild.attributes.linkcolor;
		_root.viewMode = graphsource.firstChild.attributes.viewmode;
		_root.hideLabels = graphsource.firstChild.attributes.hidelabels;
		if(_root.viewMode != "explore") {_root.toggleViewMode.gotoAndStop(2);}

		// Set optional values
		_root.GraphWidth = graphsource.firstChild.attributes.width;
		_root.GraphHeight = graphsource.firstChild.attributes.height;
		if(_root.GraphWidth == null || _root.GraphWidth == undefined) {_root.GraphWidth = 725;}
		if(_root.GraphHeight == null || _root.GraphHeight == undefined) {_root.GraphHeight = 400;}
		
		_root.GraphDirection = graphsource.firstChild.attributes.type;
		if(_root.GraphDirection == null || _root.GraphDirection == undefined) {_root.GraphDirection = "undirected";}

		_root.LineLock = graphsource.firstChild.attributes.lock;
		
		var GraphSegment = graphsource.firstChild.attributes.segmentlength;
		var GraphBounce = graphsource.firstChild.attributes.bounce;
		var GraphSpring = graphsource.firstChild.attributes.springforce;
		var GraphRepel = graphsource.firstChild.attributes.repelforce;
		var GraphResist = graphsource.firstChild.attributes.resistance;
		var GraphMass = graphsource.firstChild.attributes.mass;
		var GraphGravity = graphsource.firstChild.attributes.gravity;
		var GraphAnimation = graphsource.firstChild.attributes.animation;

	
		if(GraphSegment != null && GraphSegment != undefined) {_root.Graph.idealSegmentLength = GraphSegment;}
		if(GraphBounce != null && GraphBounce != undefined) {_root.Graph.BOUNCE = GraphBounce;}
		if(GraphSpring != null && GraphSpring != undefined) {_root.Graph.SPRINGK = GraphSpring;}
		if(GraphRepel != null && GraphRepel != undefined) {_root.Graph.REPELK = GraphRepel;}
		if(GraphResist != null && GraphResist != undefined) {_root.Graph.RESISTANCE = GraphResist;}
		if(GraphMass != null && GraphMass != undefined) {_root.Graph.MASS = GraphMass;}
		if(GraphGravity != null && GraphGravity != undefined) {_root.Graph.GRAVITY = GraphGravity;}
		if(GraphAnimation != null && GraphAnimation != undefined) {actionAnimation = GraphAnimation;}
		
		_root.Graph.GraphFrame.GraphBG._width = _root.GraphWidth;
		_root.Graph.GraphFrame.GraphBG._height = _root.GraphHeight;
		_root.toggleViewMode._x = 10;
		_root.toggleViewMode._y = _root.GraphHeight - 10;
		_root.GearFrame._width = _root.GraphWidth;
		_root.GearFrame._height = _root.GraphHeight;
		_root.CSBrand._x = _root.GraphWidth;
		_root.CSBrand._y = _root.GraphHeight;
		
		_root.action = graphsource.firstChild.attributes.action;
		if(_root.action == null || _root.action == undefined || _root.action == "") {_root.action = "drag";}
		
		var listener:Object = new Object();
		listener.onLoadInit = function(target_mc:MovieClip) {
			target_mc._height = 40;
			
			target_mc._xscale = target_mc._yscale;
			// changed out for open nodes
		};
		mcl.addListener(listener);
		for(var i=0; i < graphsource.firstChild.childNodes.length; i++)
		{
			if(graphsource.firstChild.childNodes[i].nodeName == "node")
			{
				var tempNode:Node = addXmlNode(graphsource.firstChild.childNodes[i]);
				nList.push(tempNode); // Add new node to node list			
			}
	
			if(graphsource.firstChild.childNodes[i].nodeName == "edge")
			{
				var sourceNode = graphsource.firstChild.childNodes[i].attributes.sourceNode;
				var targetNode = graphsource.firstChild.childNodes[i].attributes.targetNode;
				var sourceRef = eval("_root.Graph.GraphFrame.Node" + sourceNode);
				var targetRef = eval("_root.Graph.GraphFrame.Node" + targetNode);
				sourceRef.connectedList.push(targetRef);
				targetRef.connectedList.push(sourceRef);

				var tempEdge = _root.Graph.GraphFrame.attachMovie("edgeDebug", "Edge" + sourceNode + targetNode, _root.Graph.GraphFrame.getNextHighestDepth());
				tempEdge.content.text = graphsource.firstChild.childNodes[i].attributes.label;
				tempEdge.content.textColor = "0x" + graphsource.firstChild.childNodes[i].attributes.textcolor;

				eList.push(new Edge(sourceRef, targetRef, tempEdge));
		
			}
		}	

		for(var i=0; i < nList.length; i++) 
		{
			nList[i].notConnectedList = nList;
		}

		// Set initial graph properties
		_root.isDragging = false;
		_root.selectedNode = nList[0];
		if(_root.action == "center") {										
			_root.selectedNode._xscale = 300; _root.selectedNode._yscale = 300;
			_root.selectedNode._y = _root.GraphHeight/2;
		}
		_root.selectedNode._visible = true;
		_root.Graph.setUp(nList, eList);
		if(_root.viewMode == "explore") {_root.Graph.toggleConnections();}

	}
	
	public function addXmlNode(nodeDefinition):Node {
		
		// Set Variables and Get Values
		var id:String = nodeDefinition.attributes.id;			
		var nodeType:String = nodeDefinition.attributes.type;
		var nodeCluster:String = nodeDefinition.attributes.cluster;
		var nodeText = nodeDefinition.attributes.text;
		var linkValue:String = nodeDefinition.attributes.link;
		var imageValue:String = nodeDefinition.attributes.image;
		var scaleValue:Number = nodeDefinition.attributes.scale;
		var textColor:String = nodeDefinition.attributes.textcolor;
		var backgroundColor:String = "0x" + nodeDefinition.attributes.color;
		
		// Error check and set defaults
		if(nodeCluster == undefined || nodeCluster == "") { nodeCluster = "default";}			
		if(nodeType == undefined || nodeType == "") { nodeType = "CircleNode";}
		if(nodeText == undefined || nodeText == "") { nodeText = null; }
		if(linkValue == undefined || linkValue == "") { linkValue = null; }
		if(imageValue == undefined || imageValue == "") { imageValue = null; }
		if(scaleValue == undefined || scaleValue == "") {scaleValue = 100;}
		
		return addNode(id,nodeType,nodeCluster,nodeText,linkValue,
				imageValue,scaleValue,textColor,backgroundColor);		
	}

	// Add Node
	function addNode(id,nodeType,nodeCluster,nodeText,linkValue,imageValue,scaleValue,textColor,backgroundColor) {
		var tempNode = _root.Graph.GraphFrame.attachMovie(nodeType, "Node" + id, _root.Graph.GraphFrame.getNextHighestDepth());
		
		tempNode.cluster = nodeCluster;
		
		// Set Viewmode
		if(_root.viewMode == "explore") { tempNode._visible = false;}
		tempNode.MoreIndicator._visible = false;

		// Setup Text
		if(nodeText == null) {
			tempNode.NodeTag.removeMovieClip();
			tempNode.content.removeMovieClip(); } 
		else {
			var textContent = "";
			if(linkValue != null) {
				textContent = "<font color=\"#" + textColor + "\"><u><a href=\"" + linkValue + "\">" + nodeText + "</a></u></font>";
			}
			else {
				textContent = "<font color=\"#" + textColor + "\">" + nodeText + "</font>";
			}		
			tempNode.content.html = true;
			tempNode.content.htmlText = textContent;
		}
		if(_root.hideLabels == "true") {
			tempNode.NodeTag._visible = false;
			tempNode.content._visible = false; }
		// Assign Interaction Hanlers
		tempNode.NodeBG.onPress = Delegate.create(this,pressHandler, tempNode.NodeBG);				
		tempNode.NodeBG.onRelease = Delegate.create(this,releaseHandler, tempNode.NodeBG);
		tempNode.NodeBG.onReleaseOutside = Delegate.create(this,releaseHandler, tempNode.NodeBG);				
		tempNode.NodeBG.onRollOver = Delegate.create(this,rollOverHandler,tempNode.NodeBG);
		tempNode.NodeBG.onRollOut = Delegate.create(this,rollOutHandler,tempNode.NodeBG);
		
		// Load Image
		if(imageValue != null) { mcl.loadClip(imageValue, tempNode.NodeImage.ImageContent);}
		else { tempNode.NodeImage.ImageContent._visible = false; }
		
		// Set Background Colors
		tempNode.NodeBG.setRGB(backgroundColor);
		tempNode.MoreIndicator.setRGB(backgroundColor);
		tempNode.NodeTag.setRGB(backgroundColor);
		
		// Set Scale
		tempNode.scale = scaleValue;
		tempNode._xscale = scaleValue;
		tempNode._yscale = scaleValue;
	
		// Set Position to Origin
		tempNode._x = _root.GraphWidth / 2; 			
		tempNode._y = _root.GraphHeight / 2;
		
		// Adjust Position Randomly if Line locked irgnore that axis
		if(_root.LineLock != "y") {tempNode._x += random(20) - random(20);}			 
		if(_root.LineLock != "x") {tempNode._y += random(20) - random(20);}
		
		// If in a seperate cluster space it out more
		if(tempNode.cluster != "default") { 
			tempNode._x += random(200) - random(200); 
			tempNode._y += random(200) - random(200);
		}
		
		return tempNode;
	}

	// ADD Edge
	function addEdge(sourceN, targetN, labelN, labelColorN) {
		var sourceNode = sourceN;
		var targetNode = targetN;
		var sourceRef = eval("_root.Graph.GraphFrame.Node" + sourceNode);
		var targetRef = eval("_root.Graph.GraphFrame.Node" + targetNode);
		sourceRef.connectedList.push(targetRef);
		targetRef.connectedList.push(sourceRef);

		var tempEdge = _root.Graph.GraphFrame.attachMovie("edgeDebug", "Edge" + sourceNode + targetNode, _root.Graph.GraphFrame.getNextHighestDepth());
		tempEdge.content.text = labelN;
		tempEdge.content.textColor = "0x" + labelColorN;

		eList.push(new Edge(sourceRef, targetRef, tempEdge));
	}

	/*************************************************/	
	/*************** Handler Functions ***************/
	/*************************************************/
	public function pressHandler(targetMC:MovieClip):Void {
		
		if(_root.action == "center") {
		targetMC.centerX = _root.GraphWidth/2;
		targetMC.centerY = _root.GraphHeight/2;
		var mc = targetMC._parent;

		}
		var returnString = targetMC._parent._name;
		returnString = returnString.substr(4, 2, returnString);
		ExternalInterface.call("nodeNotify", returnString); 
		if(_root.selectedNode == targetMC._parent && (_root.selectedNode._xscale > _root.selectedNode.scale)){ 

			if(_root.action == "center") {				
				delete Twease.tweens[targetMC._parent];
		
				targetMC._parent._xscale = targetMC._parent.scale; 
				targetMC._parent._yscale = targetMC._parent.scale; 
			}
		} 
		else {
			if(_root.action == "center") {										
				delete Twease.tweens[targetMC._parent];
				Twease.tween({target:targetMC._parent, time:0.1, cycles:1, _x:targetMC.centerX, _y:targetMC.centerY, ease:'easeOutQuad'});
				Twease.tween({target:targetMC._parent, time:0.1,_xscale:300, _yscale:300, ease:'easeOutQuad'});

				if(targetMC._parent != _root.selectedNode) {
					delete Twease.tweens[_root.selectedNode];
					
				_root.selectedNode._xscale = _root.selectedNode.scale; 
				_root.selectedNode._yscale = _root.selectedNode.scale; 
			}
			}
			_root.selectedNode = targetMC._parent; 
			_root.Graph.toggleOff();} 
			_root.isDragging = true; 
			if(_root.LineLock == "x") { targetMC._parent.startDrag(false, 0, targetMC._parent._y, _root.GraphWidth, targetMC._parent._y);} 
			else if(_root.LineLock == "y") { targetMC._parent.startDrag(false, targetMC._parent._x, 0, targetMC._parent._x, _root.GraphHeight);} 
			else { if(_root.action == "drag"){targetMC._parent.startDrag();} }
			_root.Graph.setRendering(true);

	}
	public function releaseHandler(targetMc:MovieClip):Void {
		_root.isDragging = false; targetMc._parent.stopDrag();
		if(_root.hideLabels) {
			targetMc._parent.content._visible = false;	
			targetMc._parent.NodeTag._visible = false;
		}
	}
	public function rollOverHandler(targetMc:MovieClip):Void {
		if(_root.hideLabels) {
			targetMc._parent.content._visible = true;	
			targetMc._parent.NodeTag._visible = true;
		}
		if(_root.gl.actionAnimation) { 
			if(targetMc._parent != _root.selectedNode || _root.action == "drag") {
				Twease.tween({target:targetMc._parent, time:1, cycles:1, _xscale:'50', _yscale:'50', ease:'easeInOutElastic'});
			}
		}
		targetMc._parent.swapDepths(_root.Graph.GraphFrame.getNextHighestDepth());		
	}
	public function rollOutHandler(targetMc:MovieClip):Void {
		if(_root.hideLabels) {
			targetMc._parent.content._visible = false;	
			targetMc._parent.NodeTag._visible = false;
		}
		if(_root.gl.actionAnimation) {
			if(!(_root.action == "center" && targetMc._parent == _root.selectedNode)) {
				delete Twease.tweens[targetMc._parent];
			}
				
			if(targetMc._parent != _root.selectedNode || _root.action == "drag") {
				targetMc._parent._xscale = targetMc._parent.scale; 
				targetMc._parent._yscale = targetMc._parent.scale;									
			}
		} // End if actionAnimation		
	}
	
	
	// Javascript interaciton, should be moved to its own class.
	
	function processSwitchXML(str:String):Void {
		for(var i=0; i<_root.Graph.nodeList.length; i++)
		{
			_root.Graph.nodeList[i].removeMovieClip();
		}
		_root.Graph.nodeList = null;
		
		for(var i=0; i<_root.Graph.edgeList.length; i++)
		{
			_root.Graph.edgeList[i].mc.removeMovieClip();
		}
		_root.Graph.edgeList = null;
		_root.gl.nList = new Array();		
		_root.gl.eList = new Array();
		_root.graphXMLFile = str;
		_root.gl.GraphLoaderAction(); 
	}
	function processLiveXML(str:String):Void {
		for(var i=0; i<_root.Graph.nodeList.length; i++)
		{
			_root.Graph.nodeList[i].removeMovieClip();
		}
		_root.Graph.nodeList = null;
		for(var i=0; i<_root.Graph.edgeList.length; i++)
		{
			_root.Graph.edgeList[i].mc.removeMovieClip();
		}
		_root.Graph.edgeList = null;
		_root.gl.nList = new Array();		
		_root.gl.eList = new Array();
		_root.liveXML = str;
		_root.gl.GraphLoaderAction(); 
	}
	
	function adjustProperty(prop, newvalue):Void {
		_root.Graph[prop] = newvalue;

		
	}
	
	function addRandomNode(scaleN, contentN, linkN, textcolorN, imageN, labelN, labelColorN)
	{
		
		var randomAttachment = random(nList.length)+1;
		var colorList = ["eeeeee", "000fff", "0000ff", "00ff00", "ff0000"];
		var randomColor = colorList[random(colorList.length)];
		var typeList = ["CircleNode", "SquareNode", "CircleTextNode"];			
		var randomType = typeList[random(typeList.length)];
			
		var randomNode = "n" + randomAttachment;
		var newID = "n" + (nList.length+1);
		trace("Adding Node" + newID + "to node" + randomNode);
		jsAddNode(newID, randomType, "default", "Random Node", "", "", 100, "000000", randomColor, newID, randomNode, "", "000000")
	}
	function jsAddNode(jId,jNodeType,jNodeCluster,jNodeText,jLinkValue,jImageValue,jScaleValue,jTextColor,jBackgroundColor,jEdgeId,jTarget,jLabel,jLabelColor) {
		
		// Set Variables and Get Values
		var id:String = jId;			
		var nodeType:String = jNodeType;
		var nodeCluster:String = jNodeCluster;
		var nodeText = jNodeText;
		var linkValue:String = jLinkValue;
		var imageValue:String = jImageValue;
		var scaleValue:Number = jScaleValue;
		var textColor:String = jTextColor;
		var backgroundColor:String = "0x" + jBackgroundColor;

		// Error check and set defaults
		if(nodeCluster == undefined || nodeCluster == "") { nodeCluster = "default";}			
		if(nodeType == undefined || nodeType == "") { nodeType = "CircleNode";}
		if(nodeText == undefined || nodeText == "") { nodeText = null; }
		if(linkValue == undefined || linkValue == "") { linkValue = null; }
		if(imageValue == undefined || imageValue == "") { imageValue = null; }
		if(scaleValue == undefined || scaleValue == "") {scaleValue = 100;}
		
		// AddNode and put it in node list.
		nList.push(addNode(id,nodeType,nodeCluster,nodeText,linkValue,
				imageValue,scaleValue,textColor,backgroundColor));		
		// Setup Edge
		addEdge(jId, jTarget, jLabel, jLabelColor);
		
		// Reset non connected list and setup graph again
		for(var i=0; i < nList.length; i++) { nList[i].notConnectedList = nList;}
		_root.Graph.setUp(nList, eList);		
	}
	
	// Utility Functions
	public function activateSource() {
		var flashSource = "https://collaborative.svn.beanstalkapp.com/public/darkresearch/graphgear/";
		var contentLicense = "http://www.gnu.org/copyleft/gpl.html";
	    var my_cm:ContextMenu = new ContextMenu(); 
	    var sourceMenuItem = new ContextMenuItem("View Source", sourceHandler);
	    sourceMenuItem.url = flashSource;
		my_cm.customItems.push(sourceMenuItem); 

	    var licenseMenuItem = new ContextMenuItem("View License", sourceHandler);
	    licenseMenuItem.url = contentLicense;
		my_cm.customItems.push(licenseMenuItem); 
		_root.menu = my_cm;
	}
	public function sourceHandler(obj, item) { 
	 	getURL(item.url);
	}

	
}