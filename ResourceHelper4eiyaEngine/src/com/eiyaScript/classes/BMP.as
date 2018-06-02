package com.eiyaScript.classes {
	import flash.geom.Rectangle;
	public final class BMP {

		public var rect:Rectangle;
				
		public function BMP() {
			this.rect = new Rectangle(0, 0, 0, 0);
		}
		
		public function clone():BMP {
			var r:BMP = new BMP();
			r.rect = this.rect.clone();
			return r;
		}
		
	}

}