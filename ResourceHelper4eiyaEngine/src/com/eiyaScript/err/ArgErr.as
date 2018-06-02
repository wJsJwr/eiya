package com.eiyaScript.err {
	public final class ArgErr extends Error {
			
		public function ArgErr(func:String,arg:String) {
			super();
			this.name = "Argument Error";
			this.message = "Argument Error: function ".concat(func, " does not support ", arg, " arguments");
		}
		
	}

}