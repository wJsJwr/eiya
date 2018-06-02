package com.eiyaScript.err {
	public final class ObjectNotFoundErr extends Error {
		public function ObjectNotFoundErr(vname:String)	{
			super();
			this.message = "Object Not Found Error: ".concat(vname);
			this.name = "Object Not Found Error";
		}
	}
}