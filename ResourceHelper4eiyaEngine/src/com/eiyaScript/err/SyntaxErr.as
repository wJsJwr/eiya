package com.eiyaScript.err {
	public final class SyntaxErr extends Error {
		public function SyntaxErr(line:int, message:String) {
			super();
			this.message = "Syntax Error: Line#".concat(line.toString(), ", ", message);
			this.name = "Syntax Error";
		}
	}
}