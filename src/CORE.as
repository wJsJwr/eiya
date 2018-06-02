package {
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.registerClassAlias;
	import flash.net.URLRequest;
	import flash.system.*;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import mx.utils.SHA256;
	import flash.net.navigateToURL;
	
	public class CORE extends Sprite {
		
		public function CORE(_root:*=null):void {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			registerClassAlias("flash.utils.ByteArray", ByteArray);
		}
		
		public static function loadSc(bytes:Object):Vector.<Vector.<Vector.<Number>>> {
			if (!(bytes is ByteArray)) return null;
			var b:ByteArray = bytes as ByteArray;
			var ret:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>();
			var b1:Vector.<ByteArray> = b.readObject();
			for (var i:int = 0; i < b1.length; i++) {
				var l2s:Vector.<ByteArray> = b1[i].readObject();
				ret.push(new Vector.<Vector.<Number>>());
				for (var j:int = 0; j < l2s.length; j++) {
					ret[i].push(l2s[j].readObject());
				}
			}
			return ret;
		}
		
		public static function loadRlib(bytes:Object):Vector.<Vector.<int>> {
			if (!(bytes is ByteArray)) return null;
			var b:ByteArray = bytes as ByteArray;
			var ret:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var b1:Vector.<ByteArray> = b.readObject();
			for (var i:int = 0; i < b1.length; i++) {
				ret.push(b1[i].readObject());
			}
			return ret;
		}
		
		public static function loadBMP(src:Object,info:Object):Vector.<BitmapData> {
			if (!(src is Array)) return null;
			if (!(info is Vector.<Vector.<int>>)) return null;
			var s:Array = src as Array;
			var r:Vector.<Vector.<int>> = info as Vector.<Vector.<int>>;
			if (s.length != r.length) return null;
			var ret:Vector.<BitmapData> = new Vector.<BitmapData>();
			for (var i:int = 0; i < s.length; i++) {
				var bitmap:BitmapData = new BitmapData(r[i][0], r[i][1], true, 0);
				if (!(s[i] is ByteArray)) return null;
				var t:ByteArray = s[i] as ByteArray;
				t.position = 0;
				bitmap.setPixels(new Rectangle(0, 0, r[i][0], r[i][1]), t);
				ret.push(bitmap);
			}
			return ret;
		}
		
		/*
		 * 0 self
		 * 1 enemy
		 * 2 self bullet
		 * 3 enemy bullet
		 * 4 bonus
		*/	
		public static function gridCollect(w:int = 10, h:int = 12, d:int = 5):Vector.<Vector.<Vector.<Vector.<int>>>> {
			var ret:Vector.< Vector.<Vector.<Vector.<int>>>> = new Vector.< Vector.<Vector.<Vector.<int>>>>(w, true);
			for (var i:int = 0; i < w; i++) {
				ret[i] = new Vector.<Vector.<Vector.<int>>>(h, true);
				for (var j:int = 0; j < h; j++) {
					ret[i][j] = new Vector.<Vector.<int>>(d, true);
					for (var k:int = 0; k < d; k++) {
						ret[i][j][k] = new Vector.<int>();
					}
				}
			}
			return ret;
		}
		
		
		
		public static function getPosVector(dim:uint=15,lock:Boolean=true):Vector.<Number> {
			return new Vector.<Number>(dim, lock);
		}
		
		public static function getPosInfo():Vector.<Vector.<Number>> {
			return new Vector.<Vector.<Number>>();
		}
		
		public static function getStageBitmap(bd:Object):Bitmap {
			if (!(bd is BitmapData)) return null;
			var bmp:Bitmap = new Bitmap();
			bmp.bitmapData = (bd as BitmapData);
			return bmp;
		}
		
		public static function getStageBitmapData():BitmapData {
			return new BitmapData(300, 360,true,0);
		}
		
		public static function getBitmapData(w:int, h:int, stuff:Object):BitmapData {
			if (!(stuff is ByteArray)) return new BitmapData(w, h, true, 0);
			var s:ByteArray = stuff as ByteArray;
			var ret:BitmapData = new BitmapData(w, h, true, 0);
			ret.setPixels(new Rectangle(0, 0, w, h), s);
			return ret;
		}
		
		public static function getColorTransform(redMultiplier:Number = 1.0, greenMultiplier:Number = 1.0, blueMultiplier:Number = 1.0, alphaMultiplier:Number = 1.0, redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0):ColorTransform {
			return new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		}
		
		public static function get pts():Vector.<Point> {
			var ret:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < 8; i++) ret.push(new Point(2 + 12 * i, 1));
			for (var j:int = 0; j < 8; j++) ret.push(new Point(2 + 12 * j, 37));
			for (var k:int = 0; k < 8; k++) ret.push(new Point(2 + 12 * k, 49));
			for (var l:int = 0; l < 4; l++) ret.push(new Point(2 + 12 * l, 77));
			for (var m:int = 0; m < 4; m++) ret.push(new Point(2 + 12 * m, 91));
			for (var n:int = 0; n < 4; n++) ret.push(new Point(2 + 12 * n, 105));
			for (var o:int = 0; o < 4; o++) ret.push(new Point(2 + 12 * o, 119));
			return ret;
		}
		
		
		public static function rank(sc:Number):void {
			var score:String = uint(sc).toString();
			var enc:Base64Encoder = new Base64Encoder();
			enc.encode(score,0,score.length);
			var out:String = "http://jwraymond.net/eiya/?s=";
			out = out.concat(encodeURIComponent(enc.toString()), "&h=");
			var arr:ByteArray = new ByteArray();
			arr.writeUTFBytes("eyiascore");
			arr.writeUTFBytes(score);
			arr.position = 0;
			out = out.concat(SHA256.computeDigest(arr));
			var urlr:URLRequest = new URLRequest(out);
			navigateToURL(urlr, "_blank");
		}
		
	}
}