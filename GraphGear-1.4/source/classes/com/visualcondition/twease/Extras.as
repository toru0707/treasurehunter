//
//  Twease Extended Extra Features [AS2]
// 
// 	Copyright (c) 2007-2008 Andrew Fitzgerald - MIT License
//  Original Release: 04/02/08
//  Author: Andrew Fitzgerald
//  Homepage: http://play.visualcondition.com/twease/
//

import com.visualcondition.twease.*;
class com.visualcondition.twease.Extras {
	static var version:Number = 1.92;
	static var cl = com.visualcondition.twease.Extras;
	static var clname:String = 'Extras';
	static var exfuncs:Array = ['getTweens'];
	static var exprops:Object = {};
	
	static function init():Void {
		Extend.initExtended(exprops, exfuncs, clname, cl);
	}
	
	static function setup(prop:String):Void{
	
	};
	
	//get tweens function
	static function getTweens(target:Object, active:Boolean):Array {
		var a:Array = [];		
		for ( var i in Twease.tweens[target] )	{
			if(i != 'active' && i != 'propcount'){
				if(active) if(Twease.tweens[target][i].active) a.push(i)
				else a.push(i);
			}
		}
		return a;
	};
}