//
//  Twease Extended Filters [AS2]
// 
// 	Copyright (c) 2007-2008 Andrew Fitzgerald - MIT License
//  Original Release: 04/02/08
//  Author: Andrew Fitzgerald
//  Homepage: http://play.visualcondition.com/twease/
//

//////////////////////////////

//////NOT FUNCTIONAL YET

/////////////////


import com.visualcondition.twease.*;
import flash.filters.*;
import flash.display.BitmapData;
class com.visualcondition.twease.Filters {
	static var version:Number = 1.92;
	static var cl = com.visualcondition.twease.Filters;
	static var clname:String = 'Filters';
	static var exfuncs:Array = ['filterquality'];
	static var exprops:Object = {
		Filters: ['BevelFilter', 'BlurFilter', 'ColorMatrixFilter', 'ConvolutionFilter', 'DisplacementMapFilter', 'DropShadowFilter', 'GlowFilter', 'GradientBevelFilter', 'GradientGlowFilter'],
		nullhelpers: []
	};
	static var filterquality:Number = 3;
	
	static function init():Void {
		Extend.initExtended(exprops, exfuncs, clname, cl);
	}
	
	static function setup(prop:String, tweenobj:Object):Void {
		
		var curfilters:Array = tweenobj.target.filters;
		
		
		switch(prop){
			case 'BevelFilter':
				
				break;
			case 'BlurFilter':
				var newf:BlurFilter = new flash.filters.BlurFilter(0, 0, Twease.filterquality);
				break;
			
			
		}

		
	};
	
	static function filterupdater(ao:Object):Void {
		//stuff
	};
}