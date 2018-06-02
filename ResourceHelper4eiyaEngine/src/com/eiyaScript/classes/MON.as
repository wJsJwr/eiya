package com.eiyaScript.classes {
	import adobe.utils.CustomActions;
	
	import com.eiyaScript.Eiya;
	import com.eiyaScript.EiyaAction;
	import com.eiyaScript.err.ArgErr;
	
	import flash.geom.Vector3D;
	
	public final class MON extends DispObj {
		
		public var life:int = 0;
		public var sc:int = 0;
		public var power:int = 0;
		public var point:int = 0;
		public var bomb:int = 0;
			
		public function MON() { }
		
		public function clone():MON {
			var r:MON = new MON();
			r.x = this.x;
			r.y = this.y;
			r.rotation = this.rotation;
			r.hit_range = this.hit_range;
			r.life = this.life;
			r.bmp = this.bmp;
			return r;
		}
		
		public function setPos(f:int, _x:int, _y:int):Vector.<EiyaAction> {
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			act.x = _x;
			act.y = _y;
			act.frame = f;
			act.rotation = 0;
			act.action = Eiya.S_STATIC;
			this.x = _x;
			this.y = _y;
			this.rotation = 0;
			ret.push(act);
			return ret;
		}
		
		public function move(f:int, ... argv):Vector.<EiyaAction> {
			if (argv.length == 4) {
				//means a circle move, jump to move2
				return this.move2(f, argv[0], argv[1], argv[2], argv[3]);
			} else if (argv.length != 3) throw new ArgErr("move", argv.length.toString());
			var tx:Number = argv[0];
			var ty:Number = argv[1];
			var v :Number = argv[2];
			// pick a line angle and calc the v at x and y
			var dx:Number = tx - this.x;
			var dy:Number = ty - this.y;
			var vxy:Vector3D = new Vector3D(dx, dy);
			var l:Number = Math.sqrt(dx * dx + dy * dy);
			var df:int = Math.ceil(l / v);
			if (dx != 0) dx = (dx / Math.abs(dx)) * (Math.abs(dx) / df);
			if (dy != 0) dy = (dy / Math.abs(dy)) * (Math.abs(dy) / df);
			var rot:Number = Vector3D.angleBetween(vxy, Vector3D.Y_AXIS);
			rot = rot * 180 / Math.PI;
			this.rotation = int(rot);

			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			for (var i:int = 0; i < df; i++) {
				this.x += dx;
				this.y += dy;
				act = new EiyaAction();
				act.x = this.x;
				act.y = this.y;
				act.rotation = this.rotation;
				act.action = Eiya.S_STANDARD;
				act.frame = f + i;
				ret.push(act);
			}
			this.x = tx;
			this.y = ty;
			act = new EiyaAction();
			act.x = this.x;
			act.y = this.y;
			act.rotation = 0;
			this.rotation = 0;
			act.frame = f + df;
			act.action = Eiya.S_STANDARD;
			ret.push(act);
			return ret;
		}
		private function move2 (f:int, cx:int, cy:int, an:int, w:int):Vector.<EiyaAction> {
			// first calc the angle, and change the coordinate system to polar,
			// calc the delta, then change back to rectangular coordinate system.
			// FIXME: maybe no need to change the rotation.
			var dx:Number = this.x - cx;
			var dy:Number = this.y - cy;
			var r:Number = Math.sqrt(dx * dx + dy * dy);
			var a:Number = Math.asin(dx/r);
			if (dy<0) a = Math.PI-a;
			var da:Number = -(an/Math.abs(an))*(Number(w)*Math.PI/180);
			var t:int = Math.ceil(Math.abs(an)/Number(w));
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction()
			for (var i:int=0;i<t;i++) {
				act = new EiyaAction();
				act.action = Eiya.S_STANDARD;
				act.x = cx + r*Math.sin(a+i*da);
				act.y = cy + r*Math.cos(a+i*da);
				act.rotation = 0;
				act.frame = f+i;
				ret.push(act);
			}
			act = new EiyaAction();
			act.action = Eiya.S_STANDARD;
			act.x = cx + r*Math.sin(a-an*Math.PI/180);
			act.y = cy + r*Math.cos(a-an*Math.PI/180);
			act.rotation = 0;
			act.frame = f+t;
			ret.push(act);
			
			this.x = act.x;
			this.y = act.y;
			return ret;
		}
		
		public function shootPolar(f:int, b_id:int, b:BUL, rou:int):Vector.<EiyaAction> {
			var ra:Number = rou / 180.0 * Math.PI;
			var dx:Number = b.speed * Math.sin(ra);
			var dy:Number = b.speed * Math.cos(ra);
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			act.res_idx = b_id;
			act.action = Eiya.S_LOAD;
			act.frame = f;
			
			if (!b.round) {
				act.rotation = ra;
				act.bullet_type = Eiya.S_BU_STD;
			}else {
				act.rotation = ra;
				act.bullet_type = Eiya.S_BU_STATIC;
			}
			ret.push(act);
			
			return ret;
			
		}
		
		public function shootTrace (f:int, b_id:int, rou:int):Vector.<EiyaAction> {
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			act.rotation = rou*Math.PI/180;
			act.action = Eiya.S_AIM;
			act.res_idx = b_id;
			act.frame = f;
			ret.push(act);
			return ret;
		}
		
		public function die(f:int):Vector.<EiyaAction> {
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			act.action = Eiya.S_DIE;
			act.frame = f;
			ret.push(act);
			return ret;
		}
		
		
		
		
	}

}