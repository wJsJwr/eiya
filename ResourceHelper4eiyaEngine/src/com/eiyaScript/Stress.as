package com.eiyaScript {
	/*************************************************************************
	 * 
	 *  eiyaScript, a script for eiyaEngine
	 *  copyright © wjsjwr 2012
	 * 
	 *  Class Stress
	 *  
	 *  Provides a stress test for bitmap rendering.
	 * 
	 *  version 1: use sprite
	 *  version 2: use draw bitmap
	 * 
	 **************************************************************************/
	
	
	
	import adobe.utils.CustomActions;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.utils.*;
	
	import mx.utils.Base64Decoder;

	public class Stress extends MovieClip {
		
		private var raw_png:String = "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";
		private var bmp:BitmapData = new BitmapData(30,43);
		
		private var max_obj:int = 0;
		private var low_obj:int = 0;
		private var Objs:Array = new Array();
		
		private var rendered:Boolean = true;
		private var t:int;
		private var lbl:TextField;
		private var back:MovieClip;
		private var fps_at:int;
		private var spr:Sprite;
		
		
		// for version 2
		//private var mat:Vector.<Matrix> = new Vector.<Matrix>();
		private var pos:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private var bg:BitmapData = new BitmapData(1,1);
		private var _smooth:Boolean;
		
		public function Stress(stress:int,smooth:Boolean = false) {
			
			this.max_obj = stress;
			this._smooth = smooth;
			
			var dec:Base64Decoder = new Base64Decoder();
			dec.decode(this.raw_png);
			var bytes:ByteArray = dec.toByteArray();
			bytes.inflate();
			bytes.position = 0;
			bmp.setPixels(new Rectangle(0,0,30,43),bytes);
		
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0,0,300,360);
			this.graphics.endFill();
			
			var bbg:BitmapData = new BitmapData(300,360);
			bbg.noise(5);
			var bbmp:Bitmap = new Bitmap(bbg);
			bbmp.x = 0;
			bbmp.y = 0;
			this.addChild(bbmp);
			
			bg = new BitmapData(300, 360,true,0);
			var bbbmp:Bitmap = new Bitmap(bg);
			bbbmp.x = 0;
			bbbmp.y = 0;
			this.addChild(bbbmp);
			
			this.scrollRect = new Rectangle(0,0,300,360);
			
			lbl = new TextField();
			lbl.x = 0;
			lbl.y = 0;
			lbl.width = 50;
			lbl.height = 20;
			lbl.text = "fps:";
			
			spr = new Sprite();
			spr.x = 0;
			spr.y = 0;
			
			spr.graphics.beginFill(0xffffff);
			spr.graphics.drawRect(0,0,50,20);
			spr.graphics.endFill();
				
			spr.addChild(lbl);
			this.addChild(spr);
			
			
			
			t = getTimer();
			this.addEventListener(Event.ENTER_FRAME, drawObjv2);
			
			
			
		}
		
		/*
		var sin:Number = Math.sin(angle);
		var cos:Number = Math.cos(angle);
		var x1:Number = xpos - wh / 2; 
		var y1:Number = ypos - wh / 2; 
		var x2:Number = cos * x1 - sin * y1;
		var y2:Number = cos * y1 + sin * x1; 
		xpos = wh / 2 + x2; 
		ypos = wh / 2 + y2;
		matrix.tx = xpos;
		matrix.ty = ypos;
		matrix.a = cos;
		matrix.b = sin;
		matrix.c = -sin;
		matrix.d = cos;
		*/
		protected function drawObjv2(e:Event):void {
			if (!this.rendered) {
				trace("skip frame");
				return;
			} else {
				this.rendered = false;
			}
			lbl.text = "fps: " + (int(1000/(getTimer() - t))).toString();
			t = getTimer();
			
			
			bg.lock();
			var nbg:BitmapData = new BitmapData(300, 360,true,0);
			nbg.lock();
			var i:int = 0;
			while (i < pos.length) {
				if (pos[i][0] < 0 || pos[i][0] > 300 || pos[i][1] > 360) {
					//mat.splice(i, 1);
					pos.splice(i, 1);
				} else {
					pos[i][0] += (Math.random() * 10 -10 );
					pos[i][1] += (Math.random() * 10);
					pos[i][2] += (Math.random() * Math.PI / 3 - Math.PI / 6);
					var mat:Matrix = new Matrix();
					//mat.rotate(pos[i][2]);
					mat.translate(pos[i][0],pos[i][1]);
					
					nbg.draw(bmp, mat, null, null, null, _smooth);
					i += 1;
				}
			}
			if (low_obj < max_obj) low_obj += int(Math.ceil(max_obj / 50.0));
			
			if (Objs.length < low_obj) {
				for (i=0;i<low_obj-pos.length;i++){
					var p:Vector.<Number> = new Vector.<Number>(3,true);
					p[0] = Math.random() * 300;
					p[0] = 0;
					p[1] =  -(20 + Math.random() * 20);
					p[2] = 0;
					pos.push(p);
					//mat.push(new Matrix());
				}
					
				
			}
			nbg.unlock();
			bg.copyPixels(nbg,nbg.rect,new Point(0,0));
			bg.unlock();
			nbg.dispose();
			this.rendered = true;			
		}
		
		public function disposev2():void{
			this.removeEventListener(Event.ENTER_FRAME, drawObjv2);
			this.bmp.dispose();
			
		}
		
		protected function drawObj(event:Event):void {
			if (!this.rendered) {
				trace("Skip frame!");
				return;
			} else {
				this.rendered = false;
			}
			var toDel:Vector.<int> = new Vector.<int>();
			var i:int;
			var sp:Sprite;
			var spc:Sprite;
			lbl.text = "fps: " + (1000/(getTimer() - t)).toFixed().toString();
			t = getTimer();
			
			for (i = 0;i<Objs.length;i++) {
				var ptr:Sprite = Objs[i] as Sprite;
				if (ptr.x > 300 || ptr.x < 0 || ptr.y>360) toDel.push(i);
				ptr.x += int(Math.random()*20 - 10);
				ptr.y += int(Math.random()*10);
				ptr.rotation += int(Math.random()*20 - 10);
			}
			for (i=toDel.length-1;i>=0;i--) {
				this.removeChild(Objs[toDel[i]]);
				Objs[toDel[i]] = null;
			}
			
			if (low_obj<max_obj) low_obj+=10;
			
			if (Objs.length < low_obj) {
				for (i=0;i<low_obj-Objs.length;i++) {
					sp = new Sprite();
					sp.x = -15;
					sp.y = -21.5;
					sp.addChild(new Bitmap(bmp));
					spc = new Sprite();
					spc.addChild(sp);
					spc.x = int(Math.random()*300);
					spc.y = -int(20 + Math.random()*20);
					this.addChild(spc);
					this.setChildIndex(spr,this.numChildren-1);
					Objs.push(spc);
				}
			}
			
			if (toDel.length != 0) {
				var j:int;
				while (toDel.length > 0) {
					j = toDel.pop();
					sp= new Sprite();
					sp.x = -15;
					sp.y = -21.5;
					sp.addChild(new Bitmap(bmp));
					spc = new Sprite();
					spc.addChild(sp);
					spc.x = int(Math.random()*300);
					spc.y = -int(20 + Math.random()*20);
					this.addChild(spc);
					this.setChildIndex(spr,this.numChildren-1);
					Objs[j] = spc;
				}
			}
			this.rendered = true;
			
			
			
		}		
		
	}
}