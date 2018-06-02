package com.eiyaScript.err {
	public final class OutOfRangeErr extends Error {
		public function OutOfRangeErr(vname:String, value:int, vmax:int = 0) {
			super();
			if (value > 0) {
				this.message = "Out Of Range Error: Try to access index ".concat(value.toString(), " in ", vname, ", but the dimension is ", vmax.toString());
			} else {
				this.message = "Out Of Range Error: Try to access index(".concat(value.toString(), ") that less then 0.");
			}
			this.name = "Out Of Range Error";
		}
	}
}