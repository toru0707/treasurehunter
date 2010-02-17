//
//  Twease Extended Texts [AS2]
// 
// 	Copyright (c) 2007-2008 Andrew Fitzgerald - MIT License
//  Original Release: 04/02/08
//  Author: Andrew Fitzgerald
//  Homepage: http://play.visualcondition.com/twease/
//

import com.visualcondition.twease.*;
class com.visualcondition.twease.Texts {
	static var version:Number = 1.92;
	static var cl = com.visualcondition.twease.Texts;
	static var clname:String = 'Texts';
	static var exfuncs:Array = [];
	static var exprops:Object = {
		Texts: ['character', 'words'],
		nullhelpers: ['charset']
	};
	static var charsets:Object = {
		lowercase: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'],
		uppercase: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
		numbers: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
		punctuation: [' ', '!', '.', '?', ',', ':', ';', "'", '"', '-', '–', '—'],
		symbols: ['_', '(', ')', '[', ']', '{', '}', '@', '#', '$', '%', '&', '*', '+', '/', '<', '=', '>', '\\', '^', '`', '|', '~'],
		letters: [],
		sentences: [],
		all: []		
	}
	
	//standard class init
	static function init():Void {
		Extend.initExtended(exprops, exfuncs, clname, cl);
		charsets.letters = charsets.uppercase.concat(charsets.lowercase);
		charsets.all = charsets.punctuation.concat(charsets.symbols).concat(charsets.uppercase).concat(charsets.lowercase).concat(charsets.numbers);
		charsets.sentences = charsets.punctuation.concat(charsets.uppercase).concat(charsets.lowercase);
		charsets.uppercase.splice(0,0," ");
		charsets.lowercase.splice(0,0," ");
		charsets.letters.splice(0,0," ");
	}
	
	//sets up special tween property and inserts an applier to update the prop
	static function setup(prop:String, tweenobj:Object):Void {
		var masc:Object = {};
		masc.prop = prop;
		var chs:Array = (tweenobj.charset != undefined) ? charsets[tweenobj.charset] : charsets.all;
		var rn:Object;
		switch(prop){
			case 'character':
				masc.charset = chs;
				masc.oldletter = tweenobj.target.text;
				masc.newletter = tweenobj[prop];
				masc.oldlnum = findIndexOf(masc.oldletter, masc.charset);
				masc.newlnum = findIndexOf(masc.newletter, masc.charset);
				masc.curlnum = new Number(masc.oldlnum);
				tweenobj.round = true;
				tweenobj.curlnum = new Number(masc.newlnum);
				delete tweenobj[prop];
                delete tweenobj.charset;
				Extend.createSubtween(tweenobj.target, clname, 'helper', tweenobj, textsupdater, masc);
			break;
			case 'words':
				masc.charset = chs;
				masc.oldword = tweenobj.target.text;
				masc.newword = tweenobj[prop];
				masc.oldwarr = masc.oldword.split("");
				masc.newwarr = masc.newword.split("");
				masc.oldiarr = [];
				masc.newiarr = [];
				masc.curiarr = [];
				for ( var i in masc.oldwarr ){
					masc.oldiarr.push(findIndexOf(masc.oldwarr[i], masc.charset));
					masc.curiarr.push(findIndexOf(masc.oldwarr[i], masc.charset));
				};
				for ( var i in masc.newwarr ) masc.newiarr.push(findIndexOf(masc.newwarr[i], masc.charset));
				if(masc.oldwarr.length < masc.newwarr.length){
					var samt:Number = masc.newwarr.length - masc.oldwarr.length;
					for ( var i=0; i<samt; i++ ) {
						masc.oldiarr.push(0);
						masc.curiarr.push(0);
					};
				} else if(masc.oldwarr.length > masc.newwarr.length){
					var samt:Number = masc.oldwarr.length - masc.newwarr.length;
					masc.newiarr.reverse();
					for ( var i=0; i<samt; i++ ) masc.newiarr.push(0);
					masc.newiarr.reverse();
				}
				tweenobj.array = masc.newiarr;
				tweenobj.round = true;
				delete tweenobj[prop];
                delete tweenobj.charset;
				Extend.createSubtween(tweenobj.target, clname, 'curiarr', tweenobj, textsupdater, masc);
			break;
		}
	};
	
	//this is the function that gets called on the applier update every frame
	static function textsupdater(ao:Object):Void {
		switch(ao.helper.prop){
			case "character":
				ao.target.text = ao.helper.charset[ao.temptweentarget.curlnum];
			break;
			case 'words':
				var nt:String = "";
				for ( var i in ao.temptweentarget ) nt += ao.helper.charset[ao.temptweentarget[i]];
				ao.target.text = nt;
			break;
		}
	};
	
	//find index of an object in an array
	static function findIndexOf(a:Object, inArr:Array):Number{
		var i:Number = 0;
		var l:Number = inArr.length;
		while (i < l) {
			if (a === inArr[i]) return i;
			i++;
		}
		return null;
	};
}