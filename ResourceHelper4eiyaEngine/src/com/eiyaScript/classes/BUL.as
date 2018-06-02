package com.eiyaScript.classes {
	import com.eiyaScript.Eiya;
	import com.eiyaScript.EiyaAction;

	public final class BUL extends DispObj {
		
		public var speed:int = 0;		
		public var hit_type:int = 0;
		public var round:Boolean = true;
		
		public static const CENTER_POINT:int = 0;
		public static const LINE		:int = 1;
		
		public function BUL() {}
		
		public function clone():BUL {
			var r:BUL = new BUL();
			r.x = this.x;
			r.y = this.y;
			r.rotation = this.rotation;	
			r.hit_range = this.hit_range;
			r.speed = this.speed;
			r.hit_type = this.hit_type;
			r.bmp = this.bmp;
			r.round = this.round;
			return r;
		}
		
		
		public static function clear(f:int):Vector.<EiyaAction> {
			var ret:Vector.<EiyaAction> = new Vector.<EiyaAction>();
			var act:EiyaAction = new EiyaAction();
			act.action = Eiya.S_CLEAR;
			act.frame = f;
			ret.push(act);
			return ret;
		}
	}

}