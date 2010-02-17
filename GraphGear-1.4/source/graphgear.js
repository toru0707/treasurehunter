/* GraphGear JS Functions */
function setPropertyToValue(value) {
	 flashMovie = document.getElementById("graphgear");
	 flashMovie.changeProperty("propertyname", value);
}

function nodeNotify(nodeIdString) {
	if(nodeIdString == "n1") {
		document.getElementById("infospace").innerHTML = "somehtml";
	}
}

function jsSwitchXML(urlString) {
	flashMovie = document.getElementById("graphgear");
	flashMovie.switchXML(urlString);
}

function jsLiveXML(newXMLString) {
	flashMovie = document.getElementById("graphgear");
	flashMovie.liveXML(newXMLString);
}

function addNode(jId,jNodeType,jNodeCluster,jNodeText,jLinkValue,jImageValue,jScaleValue,jTextColor,jBackgroundColor,jEdgeId,jTarget,jLabel,jLabelColor) {
	flashMovie = document.getElementById("graphgear");
	flashMovie.jsAddNode(jId,jNodeType,jNodeCluster,jNodeText,jLinkValue,jImageValue,jScaleValue,jTextColor,jBackgroundColor,jEdgeId,jTarget,jLabel,jLabelColor);
}