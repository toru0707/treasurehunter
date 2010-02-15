//名前空間オブジェクト
var inot = new Object();

/**
 * コンストラクタ
 */
inot.RelativePopupController = function() {
	console.log('relative popup is started.');
	this.connection = chrome.extension.connect();
	this.connection.onMessage.addListener(function(info, con) {
	    console.log(info, con);
	});

	//background pageからイベント情報を取得
	this.connection.onMessage.addListener(function(info) {
		console.log('onMessage callback is called.');
	    inot.controller.searchCallback(info); 
	});

    this.inputReady();

}

/**
 * インスタンスメソッド
 */
inot.RelativePopupController.prototype = {

    /**
     * A. ページがロードされた
     * A-1. input要素がfocusされ、変更された0.5秒後に検索を「モデル」に依頼
     */
    inputReady: function(){
		console.log('inputReady is called.');
        $(function(){
		  $('input').keyup(function () {
			inot.controller.target = this;
			var iv = this.value;
			setTimeout(function() {
				console.log('input is changed. keyword is ' + iv);
            	inot.controller.callSearch(iv);
        	}, 500);
		  });
		});
    },

    /**
     * B. Relativeの検索結果を取得した。
     * B-1. 取得されたステータスを描画するように「ビュー」に依頼
     * B-2. 再度input要素がfocusされ、変更された0.5秒後に検索を「モデル」に依頼
     */ 
    searchCallback: function(statuses) {
		//Viewに検索結果の表示を依頼する
		console.log('searchCallBack is called. statuses is ' + statuses);
        inot.RelativePopupView.render(inot.controller.target, statuses);
		$('input').keyup(function () {
			var iv = this.value;
			setTimeout(function() {
            	inot.controller.callSearch(iv);
        	}, 500);
		});
    },

    /**
     * 「モデル」検索結果の取得を依頼する実際の処理
     */ 
    callSearch: function(keyword) {
		console.log('callSearch is called.');
		inot.controller.connection.postMessage({url:keyword});
    }
}

inot.controller = new inot.RelativePopupController();