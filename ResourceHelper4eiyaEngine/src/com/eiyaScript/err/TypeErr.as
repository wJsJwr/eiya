package com.eiyaScript.err {
	public final class TypeErr extends Error {
		public function TypeErr(vname:String, vtype:String) {
			super();
			this.message = "Type Error: ".concat(vname, " is not a ", vtype);
			this.name = "Type Error";
		}
	}
}