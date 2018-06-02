package com.eiyaScript {
	internal final class ResStruct {
		public var name		:String = "";
		public var type		:String = "";
		public var sub_type	:String = "";
		public var value	:Vector.<int>;
		public var id		:int = 0;
		
		public static const R_ARRAY	:String = "array";
		public static const R_BMP	:String = "bmp";
		public static const R_MON	:String = "mon";
		public static const R_BUL	:String = "bul";
		public static const R_INT	:String = "integer";
		public function ResStruct()	{ }
	}
}