inot.RelativePopupView = {

    /**
     * 受け取ったステータスのうち最も古いものを描画して
     * 1.5秒後に再度自分自身を呼び出して、次に古いものを描画する
     */
    render: function(target, statuses) {

		var statuses = eval(statuses);
		var targetId = target.id;
		var rpId = '#relative_popup';
		var popupId = rpId + '_' + targetId;
		
		console.log('render is called. statuses is ' + statuses);
        if (statuses.length > 0) {
			if($(popupId).length != 0){
				console.log('relative_popup is found.');
				$(popupId).remove();
			}
			console.log('create relative_popup.');

			//popupの外枠を作成
			var div  = $("<div class='autosuggest'></div>");
			var hcorner = $("<div class='as_corner'></div>");
			var hbar = $("<div class='as_bar'></div>");
			var header = $("<div class='as_header'></div>");
			hcorner.appendTo(header);
			var ul_corner_tl = chrome.extension.getURL('img/ul_corner_tl.gif');
			hcorner.css("background-image", 'url(' + ul_corner_tl + ')');

			hbar.appendTo(header);
			header.appendTo(div);

			var ul_corner_tr = chrome.extension.getURL('img/ul_corner_tr.gif');
			header.css("background-image", 'url(' + ul_corner_tr + ')');
			//検索結果のリストを作成
			var ulId = 'as_ul' + '_' + targetId;
			var ul = $("<ul id='" + ulId + "'></ul>");
			
			console.log('statuses length is' + statuses.length);
			for(var i=0; i<statuses.length;i++){
				var span = $("<span>" + statuses[i].value + "</span>");

				var link = statuses[i].link;
				var a 			= $("<a href='" + link + "'></a>");
				
				var tl 		= $("<span class='tl'></span>");
				var tr 		= $("<span class='tr'></span>");
				tl.appendTo(a);
				tr.appendTo(a);
				span.appendTo(a);
				
				a.name = i+1;
				
				var li = $("<li></li>");
				a.appendTo(li);
				
				li.appendTo(ul);
			}
			console.log('created ul is ' + ul);
			ul.appendTo( div );
			
			//popupを装飾
			var fcorner = $("<div class='as_corner'></div>");

			var fbar = $("<div class='as_bar'></div>");
			var footer = $("<div class='as_footer'></div>");
			fcorner.appendTo(footer);
			
			var ul_corner_bl = chrome.extension.getURL('img/ul_corner_bl.gif');
			fcorner.css("background-image", 'url(' + ul_corner_bl + ')');
			fbar.appendTo(footer);
			footer.appendTo(div);
			var ul_corner_br = chrome.extension.getURL('img/ul_corner_br.gif');
			footer.css("background-image", 'url(' + ul_corner_br + ')');

			var pos = inot.RelativePopupView.getPos(target);

			console.log('pos.y = ' + pos.y +', target.offsetHeight = ' + target.offsetHeight + ', target.offsetY = ' + target.offsetY);
			div.css("left", pos.x + "px");
			div.css("top", ( pos.y + target.offsetHeight) + "px");
			div.css("width",target.offsetWidth + "px");

			var pointerUrl = chrome.extension.getURL('img/as_pointer.gif');
			console.log('pointerUrl is ' + pointerUrl);
			div.css("background-image", 'url(' + pointerUrl + ')');

			$(target).after(div);
        }
    },

	getPos : function ( e )
	{
		var obj = e;

		var curleft = 0;
		if (obj.offsetParent)
		{
			while (obj.offsetParent)
			{
				curleft += obj.offsetLeft;
				obj = obj.offsetParent;
			}
		}
		else if (obj.x)
			curleft += obj.x;
		
		var obj = e;
		
		var curtop = 0;
		if (obj.offsetParent)
		{
			while (obj.offsetParent)
			{
				curtop += obj.offsetTop;
				obj = obj.offsetParent;
			}
		}
		else if (obj.y)
			curtop += obj.y;

		return {x:curleft, y:curtop};
	}
}

