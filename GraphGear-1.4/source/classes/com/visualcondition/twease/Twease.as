//
//  Twease[AS2] 2.0 Beta 2 - AS2 tweening engine and sequencer
// 
// 	Copyright (c) 2007-2008 Andrew Fitzgerald - MIT License
//  Original Release: 07/07/07 | Updated: 04/02/08
//  Author: Andrew Fitzgerald
//  Homepage: http://play.visualcondition.com/twease/
//

dynamic class com.visualcondition.twease.Twease {
	static var version:Number = 1.92;
	static var updatedepth:Number = 9876543;
	static var active:Boolean;
	static var roundresults:Boolean = false;
	static var tweens:Object = {};
	static var activetweens:Object = {};
	static var queue:Array = [];
	static var extensions:Object = {};
	static var collectionrate:Number = 2048;
	static var stacking:Boolean = true;
	static var gcid:Number;
	static var baseprops:Array = ['target', 'time', 'ease', 'delay', 'func', 'startfunc', 'upfunc', 'round', 'queue', 'cycles', 'extra1', 'extra2', 'stack', 'bezier', 'rate'];
	static function register():Void {
		for ( var i:String in arguments ) arguments[i].init();
	};
	static function setActive(setactive:Boolean, target:Object, prop:String):Void {
		var ust:Function = function(apro:Array) {
			if(apro.subtween){
				var sto:Object = apro[0].tweenobject;
				for ( var u in sto ) sto[u][0].starttime = getTimer()-(sto[u][0].lasttime-sto[u][0].starttime);
			} else apro[0].starttime = getTimer()-(apro[0].lasttime-apro[0].starttime);
		}
		if(prop == undefined){
			if(setactive) for ( var i:String in tweens[target] ) if(tweens[target][i].active) ust(tweens[target][i]);
			tweens[target].active = setactive;
		} else {
			if(setactive && !tweens[target][prop].active) ust(tweens[target][prop]);
			tweens[target][prop].active = setactive;
		}
		activetweens = {};
		for ( var j:String in tweens ) {
			if(tweens[j].active) {
				activetweens[j] = {};
				for ( var i:String in tweens[j] ) if(tweens[j][i].active && i != 'active' && i != 'propcount') activetweens[j][i] = true;
			}
		}
		if(target == undefined){
			if(setactive){
				if(setactive) for ( var j:String in tweens ) for ( var i:String in tweens[j] ) if(tweens[j][i].active) ust(tweens[j][i]);
				_root.createEmptyMovieClip("updater", updatedepth).onEnterFrame = update;
				gcid = setInterval(Twease.garbagecollect, collectionrate);
			}
			else {
				delete _root.updater.onEnterFrame;
				_root.updater.removeMovieClip();
				clearInterval(gcid);
			}
			active = setactive;
		}
	};
	static function garbagecollect():Void {
		var tc:Number = 0;
		for ( var i:String in tweens ){
			tc++;
			if(tweens[i].propcount == 0) {delete tweens[i]; delete activetweens[i]};
		};
		if(tc == 0) setActive(null);
	}
	static function advance(id:Number, position:Number):Number {
		var np:Number = queue[id].position = (position == undefined) ? ++queue[id].position : position;
		if(queue[id].length-1 < np) queue[id] = [];
		if(queue[id].length == 0){
			for ( var i:String in queue ) if(queue[i].length != 0) return null;
			queue = [];
		} else {
			var o:Object = {};
			for ( var r:String in  queue[id][np]) o[r] = queue[id][np][r];
			if(queue[id].target != undefined) {
				var oc:Number = 0;
				for ( var l:String in o ) oc++;
				if(o.func != undefined && o.target == undefined && oc <= 2){}
				else o.target = queue[id].target;
			}
			o.queue = [id, np];
			tween(o);
		}
		return id;
	};
	static function compareInObject(prop, cont):Boolean {
		for ( var i in cont ) if(cont[i] == prop) return true;
		return false;
	};
	static function none(t:Number, b:Number, c:Number, d:Number):Number { return c*t/d+b; }
	static function easeIn(t:Number, b:Number, c:Number, d:Number):Number { return c*(t /= d)*t*t*t*t+b; }
	static function easeOut(t:Number, b:Number, c:Number, d:Number):Number { return c*((t=t/d-1)*t*t*t*t+1)+b; }
	static function render(tweenholder:Array, gtt:Number):Boolean{
		var o:Object = tweenholder[0];
		var tmr:Number = (gtt+o.progdif)-o.starttime;
		var dn:Boolean;
		if(o.rate != undefined) dn = (o.rateleft <= 0) ? true : false;
		else dn = (tmr >= (o.time+o.delay)) ? true : false;
		if(dn) {
			o.target[o.prop] = (o.round) ? Math.round(o.newval) : o.newval;
			o.cycles--;
			o.func(o.target, o.prop, o.queue[0]);
			if(o.cycles == undefined || o.cycles == 0){
				tweenholder.shift();
				if(queue[o.queue[0]].position == o.queue[1]) advance(o.queue[0], o.queue[1]+1);
			}
			var ocyc:Number = o.cycles;
			o = tweenholder[0];
			if(o != undefined){
				if(o.oldelay != 0 && o.oldelay != undefined) o.delay = o.oldelay;
				o.value = (ocyc != 0) ? (typeof(o.value) == 'string') ? String(-1*o.value) : o.startpos : o.value;
				o.starttime = gtt;
				o.startpos = o.target[o.prop];
				o.newval = (typeof(o.value) == 'string') ? o.startpos + Number(o.value) : o.value;
				o.dif = (o.startpos > o.newval) ? -1*Math.abs(o.target[o.prop]-o.newval) : Math.abs(o.target[o.prop]-o.newval);
				o.rate = (o.rate != undefined) ? -1*o.rate : undefined;
				o.rateleft = Math.abs(o.dif);
				o.bezier.reverse();
			} else return true;
		} else {
			if(o.delay == 0){
				o.startfunc(o.target, o.prop, o.queue[0]);
				delete o.startfunc;
				var res:Number, nres:Number;
				if(o.rate == undefined) res = o.ease(tmr, o.startpos, o.dif, o.time, o.extra1, o.extra2);
				else{
					res = (o.newval-(Math.abs(o.rateleft/o.rate)*o.rate));
					o.rateleft -= Math.abs(o.rate);
				}
				o.easeposition = (res-o.startpos)/(o.newval-o.startpos);
				if(o.bezier.length < 1) nres = res;
				else if(o.bezier.length == 1)nres = o.startpos + (o.easeposition*(2*(1-o.easeposition)*(o.bezier[0]-o.startpos)+(o.easeposition*o.dif)));
				else {
					var b1:Number, b2:Number;
					var bpos:Number = Math.floor(o.easeposition*o.bezier.length);
					var ipos:Number = (o.easeposition-(bpos*(1/o.bezier.length)))*o.bezier.length;
					if (bpos == 0){
						b1 = o.startpos;
						b2 = (o.bezier[0]+o.bezier[1])/2;
					} else if (bpos == o.bezier.length-1){
						b1 = (o.bezier[bpos-1]+o.bezier[bpos])/2;
						b2 = o.newval;
					} else{
						b1 = (o.bezier[bpos-1]+o.bezier[bpos])/2;
						b2 = (o.bezier[bpos]+o.bezier[bpos+1])/2;
					}
					nres = b1+ipos*(2*(1-ipos)*(o.bezier[bpos]-b1) + ipos*(b2 - b1));
				}
				o.target[o.prop] = (o.round) ? Math.round(nres) : nres;
				o.upfunc(o.target, o.prop, o.queue[0]);
			} else {
				if(gtt >= o.starttime+o.delay){
					o.oldelay = o.delay;
					o.delay = 0;
					o.starttime = gtt;
					if(o.rate != undefined){
						o.rateleft -= o.rateleft*o.startprogress;
						o.target[o.prop] = o.startpos += o.dif *= o.startprogress;
					} else o.progdif = o.time*o.startprogress;
				}
			}
			o.lasttime = gtt;
		}
		return false;
	};
	static function update():Void {
		var gtt:Number = getTimer();
		for (var i:String in activetweens){
			for (var j:String in activetweens[i]){
				var ddi:Boolean;
				if(tweens[i][j].subtween){
					ddi = true;
					var nst:Object = tweens[i][j][0];
					for ( var c in nst.tweenobject ){
						if(render(nst.tweenobject[c], gtt)) delete nst.tweenobject[c];
						ddi = false;
					};
					if(ddi){
						if(tweens[i][j][1] != undefined){
							ddi = false;
							tweens[i][j].shift();
						}
					}
					nst.applyfunc(nst);
				} else ddi = render(tweens[i][j], gtt);
				if(ddi){
					delete tweens[i][j];
					delete activetweens[i][j];
					tweens[i].propcount--;
				}
			}
		}
	};
	static function tween(ao:Object, tovr:Object, nonm:Boolean):Object {
		if(ao[0] == undefined){
			if(active == undefined || active == null) setActive(true);
			if(tweens == undefined) tweens = {};
			var delay:Number = (ao.delay == undefined) ? 0.00001 : ao.delay*1000;
			var ncycles:Number = (ao.cycles == undefined) ? 1 : ao.cycles;
			var snt:Number = getTimer();
			var tg:Object;
			if(ao.func != undefined && ao.target == undefined){
				tg = (tweens.functions == undefined) ? tweens.functions = {propcount:0} : tweens.functions;				
				if(tg.active == undefined){
					tg.active = true;
					activetweens.functions = {};
				}
				var prop:String = "func" + (Math.round(Math.random()*100000)).toString();
				var tarr:Array = tg[prop] = [];
				tarr.active = true;
				activetweens.functions[prop] = true;
				tg.propcount++;
				tarr.push({prop:prop, starttime:snt, time:0, func:ao.func, delay:delay, queue:ao.queue, cycles:ncycles, progdif:0});
			} else {
				var ntarg:Object = (tovr == undefined || tovr == null) ? ao.target : tovr;
				var dostack:Boolean = (ao.stack != undefined) ? ao.stack : stacking;
				var ease:Function;
				if(extensions.Easing != undefined){
					if(ao.ease == undefined) ease = extensions.Easing.linear;
					else ease = (typeof ao.ease == 'string') ? extensions.Easing[ao.ease] : ao.ease;
				} else {ease = (ao.ease == undefined) ? none : ao.ease;}
				if(nonm === true) tg = {propcount:0, active:true};
				else if(typeof nonm == 'object') tg = nonm;
				else {
					tg = (tweens[ntarg] == undefined) ? tweens[ntarg] = {propcount:0} : tweens[ntarg];
					if(tg.active == undefined){
						tg.active = true;
						activetweens[ntarg] = {};
					}
				}
				for( var i:String in ao ){
					if(compareInObject(i, baseprops)){}
					else if(Twease.extendedprops != undefined && extensions.Extend.checkExtendedProp(i)){ extensions.Extend.propSetup(Twease.extendedprops[i], ao); }
					else {
						var newa:Array = [];
						if(i == 'array') for ( var g:String in ao[i] ) newa[g] = {index:[g,ao[i][g]]};
						else {
							var tomk:Object = {};
							tomk[i] = ao[i];
							newa.push(tomk);
						}
						for ( var q:String in newa ){
							for ( var s:String in newa[q] ){
								var prop:String = (s == 'index') ? newa[q][s][0].toString() : i;
								var value = (s == 'index') ? newa[q][s][1] : ao[i];
								if(isNaN(value)) continue;
								if(tg[prop] != undefined && !dostack) tg.propcount--;
								var tarr:Array = (tg[prop] == undefined || !dostack) ? tg[prop] = [] : tg[prop];
								if(tarr.active == undefined) {
									tarr.active = true;
									tg.propcount++;
									if(nonm != true) activetweens[ntarg][prop] = true;
								}								
								var ftv:Number = tarr[tarr.length-1].startpos;
								ftv = (ftv == undefined) ? ((i == 'index') ? ntarg[newa[q][s][0]] : ntarg[prop]) : ftv;
								var newval:Number = (typeof(value) == 'string') ? ftv + Number(value) : value;
								var dif:Number = (ftv > newval) ? -1*Math.abs(ftv-newval) : Math.abs(ftv-newval);
								var bzarr:Array = [];
								var beza:Array = (ao.bezier.length != undefined) ? ao.bezier : [ao.bezier];
								for ( var b in beza ){if(beza[b][prop] != undefined) bzarr.push((typeof(beza[b][prop]) == 'string') ? ftv + Number(beza[b][prop]) : beza[b][prop]);};
								tarr.push({target:ntarg, cycles:ncycles, prop:prop, ease:ease, starttime:snt, queue:ao.queue, startpos:ftv, value:value, dif:dif, newval:newval, time:(ao.time == undefined && ao.rate == undefined) ? 0 : ao.time*1000, rate:(ao.rate != undefined) ? ((ftv > newval) ? -1*ao.rate : ao.rate) : undefined, func:ao.func, startfunc:ao.startfunc, upfunc:ao.upfunc, round:(ao.round == undefined) ? roundresults : ao.round, delay:delay+1, extra1:ao.extra1, extra2:ao.extra2, bezier:bzarr, easeposition:null, rateleft:Math.abs(dif), startprogress:(ao.progress == undefined) ? 0 : ao.progress, progdif:0});
							};
						};
					}
				};
			}
			return tg;
		} else {
			if(queue == undefined) queue = [];
			var nqp:Number = queue.push(ao)-1;
			queue[nqp].target = tovr;
			return advance(nqp, 0);
		}
	}
}