//
//  Twease Extended [AS2] - Extended Functions For Twease
// 
// 	Copyright (c) 2007-2008 Andrew Fitzgerald - MIT License
//  Original Release: 08/21/07 | Updated: 04/02/08
//  Author: Andrew Fitzgerald
//  Homepage: http://play.visualcondition.com/twease/
//
import com.visualcondition.twease.*;
class com.visualcondition.twease.Extend {
	static var version:Number = 1.92;
	//standard class init
	static function init():Void {
		Twease.extensions.Extend = com.visualcondition.twease.Extend;
	}
	
	//initiates extended classes into the Twease engine
	static function initExtended(ep:Object, ef:Array, clname:String, cl):Void{
		Extend.init();
		Twease.extensions[clname] = cl;
		initExtendedProps(ep);
		initExtendedMethods(ef, cl);
	};
	
	//checks to see if property is an exteded property
	static function checkExtendedProp(prop):Boolean{
		for ( var i in Twease.extendedprops ) if(Twease.extendedprops[i][0] == prop) return true;
		return false;
	};
		
	//initiate extended methods for Twease, so methods can be called via Twease.method_name()
	static function initExtendedMethods(nexfuncs:Array, cl):Void{
		for ( var i in nexfuncs ) Twease[nexfuncs[i]] = cl[nexfuncs[i]];
	};
	
	//initiate extended props for Twease
	static function initExtendedProps(nexprops:Object):Void{
		if (Twease.extendedprops == undefined) Twease.extendedprops = {};
		for ( var i in nexprops ){
			var pr:Array = nexprops[i];
			for ( var j in pr ) Twease.extendedprops[pr[j]] = [pr[j], i];
		};
	};
	
	//prop setup function
	static function propSetup(parr:Array, tobj:Object):Void{
		if(parr[1] != 'nullhelpers') Twease.extensions[parr[1]].setup(parr[0], tobj);
	};
	
	//target object (the real thing being tweened) passed as an object, or a string to use a variable in the helper object, or "helper" to use the helper object as the target itself
	static function createSubtween(target:Object, prop:String, tto, tobj:Object, func:Function, helper:Object):Object{
		var tg:Object = (Twease.tweens[target] == undefined) ? Twease.tweens[target] = {propcount:0} : Twease.tweens[target];
		if(tg.active == undefined){
			tg.active = true;
			Twease.activetweens[target] = {};
		}
		var dostack:Boolean = (tobj.stack != undefined) ? tobj.stack : Twease.stacking;
		if(tg[prop] != undefined && !dostack) tg.propcount--;
		var tarr:Array = (tg[prop] == undefined || !dostack) ? tg[prop] = [] : tg[prop];
		if(tarr.active == undefined) {
			tarr.active = true;
			tg.propcount++;
			Twease.activetweens[target][prop] = true;
		}
		tarr.subtween = true;
		var sto:Object = tarr[tarr.push({target: target, originaltobj: tobj, applyfunc: func, helper:helper})-1];
		sto.temptweentarget = (typeof tto == 'string') ? (tto == 'helper') ? sto.helper : sto.helper[tto] : tto;
		sto.tweenobject = Twease.tween(tobj, sto.temptweentarget, true);
		return sto;
	};
}