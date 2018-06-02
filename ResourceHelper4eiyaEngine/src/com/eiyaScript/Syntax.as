package com.eiyaScript {
	/*************************************************************************
	 * 
	 *  eiyaScript, a script for eiyaEngine
	 *  copyright © wjsjwr 2012
	 * 
	 *  Class Syntax
	 *  
	 *  A class that contains some static functions for syntax checking, 
	 *  and at the same time, may be applied to semantic analyzing.
	 * 
	 **************************************************************************/

	public class Syntax {
		
		/* int declaration and assignment */
		public static const syntax_int_dec_ass:RegExp = /^\s*(?P<n>\$\w+(\[(\d+|\$\w+)\])?)\s*=\s*(?P<v>-?\d+)\s*\n?$/;
		
		/* class declaration */
		public static const syntax_class_dec:RegExp = /^\s*\$(?P<n>\w+)(\[(?P<i>(\d+|\$\w+))\])?\s+as\s+(?P<t>(mon|bul|bmp))\s*\n?$/;
		
		/* copy a class */
		public static const syntax_class_copy:RegExp = /^\s*\$(?P<n1>\w+)\s+as\s+\$(?P<n2>\w+)\s*\n?$/;
		
		/* goto */
		public static const syntax_goto:RegExp = /^\s*goto\s+L(?P<l>\w+)(\s+when\s+((?P<v1>-?\d+)|((?P<n1>\$\w+(\[(\d+|\$\w+)\])?)))\s*(?P<op>([<>]=?|==))\s*((?P<v2>-?\d+)|((?P<n2>\$\w+(\[(\d+|\$\w+)\])?))))?\s*\n?$/;
		
		/* label */
		public static const syntax_label:RegExp = /^\s*L(?P<l>\w+):\s*\n?$/;
		
		/* object call */
		public static const syntax_object_call:RegExp = /^\s*\$(?P<n>\w+)(\[(?P<i>(\d+|\$\w+))\])?\.(?P<f>([+-]|\w+))\s+(?P<a>(((-?\d+)|(\$\w+(\[(\d+|\$\w+)\])?))\s*,\s*)*((-?\d+)|(\$\w+(\[(\d+|\$\w+)\])?)))\s*\n?$/;
		
		/* static call (for now, only one function: bul.clear)*/
		public static const syntax_static_call:RegExp = /^\s*bul\.clear\s+((?P<v>\d+)|(?P<n>\$\w+(\[(\d+|\$\w+)\])?))\s*\n?$/;
		
		/* comment */
		public static const syntax_comment:RegExp = /^\s*#/;
		
		/* fetch a variant */
		public static const syntax_variant:RegExp = /^\$(?P<n>\w+)(\[(?P<i>(\d+|\$(?P<n2>\w+)))\])?$/;
		
		/* blank line */
		public static const syntax_blank_line:RegExp = /^\s*\n?$/;
				
		
		public static const DeclareAssignInteger:String = "dsi";
		public static const DeclareClass		:String = "dc";
		public static const ClassCopy			:String = "cc";
		public static const Goto				:String = "g";
		public static const CreateLabel			:String = "cl";
		public static const ObjectCall			:String = "oc";
		public static const StaticCall			:String = "sc";
		public static const VariantObject		:String = "vo";
		
		public static const MatchOK				:String = "MatchOk";
		
		
		public function Syntax() {	}
		public static function match_line(input:String):Boolean {
			if (input.match(syntax_int_dec_ass)) return true;
			if (input.match(syntax_class_dec)) return true;
			if (input.match(syntax_class_copy)) return true;
			if (input.match(syntax_goto)) return true;
			if (input.match(syntax_label)) return true;
			if (input.match(syntax_object_call)) return true;
			if (input.match(syntax_static_call)) return true;
			if (input.match(syntax_comment)) return true;
			if (input.match(syntax_blank_line)) return true;
			return false;
		}
	}
}