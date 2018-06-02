package com.eiyaScript.err {
	public class ObjectAlreadyExistErr extends Error {
		public function ObjectAlreadyExistErr(vname:String) {
			super();
			this.message = "Object Already Exist: ".concat(vname);
			this.name = "Object Already Exist Error";
		}
	}
}