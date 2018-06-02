package com.eiyaScript {
	
	public final class EiyaAction {
		
		public var frame:int;
		public var target:int;
		public var action:int = 0;
		public var x:Number = 0;
		public var y:Number = 0;
		public var rotation:Number = 0;
		public var res_idx:int = 0;
		public var dx:Number = 0;
		public var dy:Number = 0;
		public var dw:Number = 0;
		public var bullet_type:int = 0;
		
		
		public function EiyaAction() { }
		
		public function get to_s():String {
			return "@".concat(frame.toString(), ": ",target.toString(),"-> (", x.toString(), ", ", y.toString(), ", ", rotation.toString(), ") act: ", action.toString(), ", dec: ", res_idx.toString());
		} 
		
	}

}