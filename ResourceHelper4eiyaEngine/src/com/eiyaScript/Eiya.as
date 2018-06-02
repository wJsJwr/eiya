package com.eiyaScript {
	/**************************************************************************
	 * 
	 *  eiyaScript, a script for eiyaEngine
	 *  copyright © wjsjwr 2012
	 * 
	 *  Class Eiya
	 *  
	 *  Provides the main translation services. 
	 *  Part of the core of eiyaEngine.
	 * 
	 *************************************************************************/
	import com.eiyaScript.*;
	import com.eiyaScript.classes.BMP;
	import com.eiyaScript.classes.BUL;
	import com.eiyaScript.classes.DispObj;
	import com.eiyaScript.classes.MON;
	import com.eiyaScript.err.ArgErr;
	import com.eiyaScript.err.Go;
	import com.eiyaScript.err.ObjectAlreadyExistErr;
	import com.eiyaScript.err.ObjectNotFoundErr;
	import com.eiyaScript.err.OutOfRangeErr;
	import com.eiyaScript.err.SyntaxErr;
	import com.eiyaScript.err.TypeErr;
	
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.Base64Encoder;
	import mx.utils.DescribeTypeCacheRecord;

	
	public class Eiya {
		
		/************************************************************************************
		 *
		 *  the structure of the final script for excution
		 *  Vector[index,Vector[index,Vector[index,value]]]
		 *           |            |               |
		 *         frame    just a index          |- 0 -> target
		 *                                        |- 1 -> action
		 *                                        |         |- 0x00 -> static (no rotation)
		 *                                        |         |- 0x01 -> standard
		 *                                        |         |- 0x02 -> load (bullet static)
		 *                                        |         |- 0x03 -> load (bullet standard)
		 *                                        |         |- 0x04 -> aim
		 *                                        |         |- 0x08 -> die
		 *                                        |         |- 0x10 -> clear
		 *                                        |
		 *                                        |- 2 -> x
		 *                                        |- 3 -> y
		 *                                        |- 4 -> rotation
		 *                                        |- 5 -> dx
		 *                                        |- 6 -> dy
		 *                                        |- 7 -> dw
		 *                                        |- 8 -> res_idx (bul...)
		 *                                                (index of res_id, or slib_id)
		 *
		 ************************************************************************************/		
		/* uses vector to improve the performance */
		private var o:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>();
		private var rlib:Array = new Array();
		/***************************************************************************
		 * 
		 * blib structure (implemented in eiyaEngine)
		 * Vector[index,Vector[index,value]]
		 *          |               |
		 *         No.              |- 0 -> type
		 *                          |        |- 0 -> bullet static
		 *                          |        |- 1 -> bullet standard
		 *                          |- 1 -> x
		 *                          |- 2 -> y
		 *                          |- 3 -> rotation
		 *                          |- 4 -> dx
		 *                          |- 5 -> dy
		 *                          |- 6 -> slib_id
		 * 
		 **************************************************************************/
		//private var blib:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private var labels:Object = new Object();
		
		public static const S_ACTION	:int = 0;
		public static const S_X			:int = 1;
		public static const S_Y			:int = 2;
		public static const S_ROTATION	:int = 3;
		public static const S_DEC		:int = 4;
		public static const S_STANDARD	:int = 0x01;
		public static const S_AIM		:int = 0x04;
		public static const S_LOAD		:int = 0x02;
		public static const S_STATIC	:int = 0x00;
		public static const S_DIE		:int = 0x08;
		public static const S_CLEAR		:int = 0x10;
		public static const S_BU_STATIC	:int = 0x00;
		public static const S_BU_STD	:int = 0x01;
		
		public static const R_TYPE		:int = 0;
		public static const R_T_BMP		:int = 0;
		public static const R_T_MON		:int = 1;
		public static const R_T_BUL		:int = 2;
		public static const R_P_DATA	:int = 1;
		public static const R_P_X		:int = 2;
		public static const R_P_Y		:int = 3;
		public static const R_P_WIDTH	:int = 4;
		public static const R_P_HEIGHT	:int = 5;
		public static const R_M_BMP		:int = 1;
		public static const R_M_HR		:int = 2;
		public static const R_M_LIFE	:int = 3;
		public static const R_M_PT		:int = 4;
		public static const R_M_PO		:int = 5;
		public static const R_M_SC		:int = 6;
		public static const R_B_BMP		:int = 1;
		public static const R_B_HR		:int = 2;
		public static const R_B_RD		:int = 3;
		public static const R_B_SP		:int = 4;
		
		
		/**********************************************************************
		 * 
		 * 	RESOURCE STRUCT
		 * 	ResStruct {
		 * 		name:String,
		 * 		type:String,
		 * 		sub_type:String,
		 * 		value:Vector.<int>, <- for integer,it's value;else its r_id
		 * 		id:int
		 * 	}
		 * 
		 *********************************************************************/
		private var res:Vector.<ResStruct> = new Vector.<ResStruct>();
		public function get R():Vector.<String> { 
			var result:Vector.<String> = new Vector.<String>();
			
			for each (var r:ResStruct in res) {
				var str:String = "".concat(r.name,":",r.type);
				if (r.type == ResStruct.R_ARRAY) str = str.concat("<",r.sub_type,">(",r.value.length.toString(),")");
				result.push(str);
			}
			
			return result;
		}
				
		public function Eiya() {

		}
		
		/**********************************************************************
		 * 
		 * FINAL INNER SRCIPT FORMAT
		 * region 1: bmp data
		 * var __BMP__000 = extract('Base64Code');
		 *             ┇
		 * var __BMP__xxx = extract('Base64COde');
		 * //use core.loadBMP to load
		 * var BMP_DATA = [__BMP__000, ... , __BMP__xxx];
		 * //use core.loadRlib to load
		 * var BMP_INFO = extract('GeneratedBase64Code');
		 * 
		 * region 2: library data
		 * // use core.loadRlib to load
		 * var RLIB_DATA = extract('GeneratedBase64Code');
		 * 
		 * region 3: scenario data
		 * //use core.loadSc to load
		 * var SC_DATA = extract('GeneratedBase64Code');
		 * 
		 * ********************************************************************/
		public function get Output():String {
			var bmpcount:int = 0;
			var bmpidx:Vector.<int> = new Vector.<int>();
			var Rlib:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var Binfo:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var str:String = "";
			for (var i:int = 0; i < rlib.length; i++) {
				var RlibItem:Vector.<int> = new Vector.<int>();
				var BinfoItem:Vector.<int> = new Vector.<int>();
				if (rlib[i] is BMP) {
					var infop:BMP = rlib[i] as BMP;
					RlibItem.push(infop.rect.x);
					RlibItem.push(infop.rect.y);
					RlibItem.push(infop.rect.width);
					RlibItem.push(infop.rect.height);
					RlibItem.push(bmpcount);
					bmpidx.push(i);
					BinfoItem.push(infop.rect.width);
					BinfoItem.push(infop.rect.height);
					Binfo.push(BinfoItem);
					bmpcount++;
				} else if (rlib[i] is MON) {
					var infom:MON = rlib[i] as MON;
					RlibItem.push(infom.bmp);
					RlibItem.push(infom.hit_range);
					RlibItem.push(infom.life);
					RlibItem.push(infom.point);
					RlibItem.push(infom.power);
					RlibItem.push(infom.bomb);
					RlibItem.push(infom.sc);
					RlibItem.push(-2); //toc
					RlibItem.push(-2); //x
					RlibItem.push(-2); //y
				} else if (rlib[i] is BUL) {
					var infob:BUL = rlib[i] as BUL;
					RlibItem.push(infob.bmp);
					RlibItem.push(infob.hit_range);
					RlibItem.push(infob.round);
					RlibItem.push(infob.speed);
				} else {
					throw new TypeErr("rlib", "known");
				}
				Rlib.push(RlibItem);
			}
			i = 0;
			for (var j:int = 0; j < res.length; j++) {
				if (res[j].type == ResStruct.R_BMP) {
					str = str.concat("/* bmp name ", res[j].name, "*/\n");
					str = str.concat("var __BMP__", padLeft(i.toString(),3,"0"), " = extract('');\n");
					i++;
				} else if (res[j].type == ResStruct.R_ARRAY && res[j].sub_type == ResStruct.R_BMP) {
					for (var l:int = 0; l < res[j].value.length; l++) {
						str = str.concat("/* bmp name ", res[j].name,"(",l,")*/\n");
						str = str.concat("var __BMP__", padLeft(i.toString(),3,"0"), " = extract('');\n");
						i++;
					}
				}
			}
			str = str.concat("var BMP_DATA = [");
			for (var k:int = 0; k < bmpcount; k++) {
				if (k != 0) str = str.concat(",");
				str = str.concat("__BMP__", padLeft(k.toString(),3,"0"));
			}
			str = str.concat("];\n");
			str = str.concat("var BMP_INFO = extract('", intob64(encode_Rlib(Binfo)), "');\n");
			str = str.concat("/* rlib(length=",Rlib.length,") */\n");
			str = str.concat("var RLIB_DATA = extract('", intob64(encode_Rlib(Rlib)), "');\n");
			str = str.concat("var SC_DATA = extract('", intob64(encode_o()), "');\n");
			test(Rlib);
			return str;
		}
		
		private function intob64(src:ByteArray):String {
			var data:ByteArray = src;
			data.deflate();
			data.position = 0;
			var enc:Base64Encoder = new Base64Encoder();
			enc.encodeBytes(data);
			return Base64Convertor.string_filter(enc.toString());
		}
		
		private function test(Rlib:Vector.<Vector.<int>>):void {
			var data:ByteArray = encode_o();
			var rdata:ByteArray = encode_Rlib(Rlib);
			var p:Vector.<Vector.<Vector.<Number>>> = decode_o(data);
			var q:Vector.<Vector.<int>> = decode_Rlib(rdata);
			try {
				for (var i:int = 0; i < o.length; i++) {
					for (var j:int = 0; j < o[i].length; j++) {
						for (var k:int = 0; k < o[i][j].length; k++) {
							if (p[i][j][k] != o[i][j][k]) {
								throw new Error("WTF");
							}
						}
					}
				}
				for (var l:int = 0; l < q.length; l++) {
					for (var m:int = 0; m < q[l].length; m++) {
						if (q[l][m] != Rlib[l][m]) {
							throw new Error("WTF2");
						}
					}
				}
				trace("Good Job");
			} catch (e:Error) {
				trace(e.getStackTrace());
			}
			
		}
		
		private function encode_Rlib(r:Vector.<Vector.<int>>):ByteArray {
			var b1:Vector.<ByteArray> = new Vector.<ByteArray>();
			registerClassAlias("flash.utils.ByteArray", ByteArray);
			for (var i:int = 0; i < r.length; i++) {
				var b2:ByteArray = new ByteArray();
				b2.writeObject(r[i]);
				b2.position = 0;
				b1.push(b2);
			}
			var b:ByteArray = new ByteArray();
			b.writeObject(b1);
			b.position = 0;
			return b;
		}
		
		private function decode_Rlib(bytes:ByteArray):Vector.<Vector.<int>> {
			var ret:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var b1:Vector.<ByteArray> = bytes.readObject();
			for (var i:int = 0; i < b1.length; i++) {
				ret.push(b1[i].readObject());
			}
			return ret;
		}
		
		
		
		private function encode_o():ByteArray {
			var b1:Vector.<ByteArray> = new Vector.<ByteArray>();
			registerClassAlias("flash.utils.ByteArray", ByteArray);
			for (var i:int = 0; i < o.length; i++) {
				var l2s:Vector.<ByteArray> = new Vector.<ByteArray>();
				for (var j:int = 0; j < o[i].length; j++) {
					var b3:ByteArray = new ByteArray();
					b3.writeObject(o[i][j]);
					b3.position = 0;
					l2s.push(b3);
				}
				var b2:ByteArray = new ByteArray();
				b2.writeObject(l2s);
				b2.position = 0;
				b1.push(b2);
			}
			var b:ByteArray = new ByteArray();
			b.writeObject(b1);
			b.position = 0;
			return b;
		}
		
		private function decode_o(bytes:ByteArray):Vector.<Vector.<Vector.<Number>>> {
			var ret:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>();
			var b1:Vector.<ByteArray> = bytes.readObject();
			for (var i:int = 0; i < b1.length; i++) {
				var l2s:Vector.<ByteArray> = b1[i].readObject();
				ret.push(new Vector.<Vector.<Number>>());
				for (var j:int = 0; j < l2s.length; j++) {
					ret[i].push(l2s[j].readObject());
				}
			}
			return ret;
		}
		
		
		private function padLeft(str:String, l:int, pad:String):String {
			var ret:String = "";
			if (str.length >= l) return str;
			for (var i:int = 0; i < l-str.length; i++) {
				ret = ret.concat(pad.charAt(i % pad.length));
			}
			return ret.concat(str);
		}
		
		public function loadScript(eys:Vector.<String>):void {
			var ip:int = 0;
			while(ip<eys.length) {
				try {
					var result:Object = eys[ip].match(Syntax.syntax_comment);
					if (result) throw new Go();
					if (eys[ip].match(Syntax.syntax_blank_line)) throw new Go();
					
					
					if (eys[ip].match(Syntax.syntax_blank_line)) throw new Go();
					
					result = eys[ip].match(Syntax.syntax_int_dec_ass);
					if ( result ) {
						var sub:Object = match_integer_variant(result.n,ip);
						if(sub.idx == -1) {
							assign(sub.name, int(result.v));
						} else {
							assign(sub.name, int(result.v),true,sub.idx);
						}
						
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_class_dec);
					if ( result ) {
						if ( result.i == "") {
							// $a as class
							declare(result.n, result.t);
						} else {
							// $a[i] as class
							declare(result.n, result.t, true, int(result.i));
						}
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_class_copy);
					if ( result ) {
						copy(result.n2, result.n1);
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_label);
					if ( result ) {
						if (labels[result.l] != undefined && labels[result.l] != ip) throw new ObjectAlreadyExistErr(result.l);
						labels[result.l] = ip;
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_goto);
					if ( result ) {
						if (result.v1 != "" || result.n1 != "") {
							// has condition
							var i:int;
							if (result.v1 == "") {
								i = match_integer_variant(result.n1,ip).value;
							} else {
								i = int(result.v1);
							}
							var j:int;
							if (result.v2 == "") {
								i = match_integer_variant(result.n2,ip).value;
							} else {
								j = int(result.v2);
							}
							var k:Boolean;
							switch (result.op) {
								case ">":
									k = i > j; break;
								case ">=":
									k = i >= j; break;
								case "<":
									k = i < j; break;
								case "<=":
									k = i <= j; break;
								case "==":
									k = i == j; break;
							}
							if (!k) throw new Go();
						}
						if (labels[result.l] == undefined) throw new ObjectNotFoundErr(result.l);
						ip = labels[result.l];
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_object_call);
					if ( result ) {
						var argv_s:Array = new Array();
						var parse:Object;
						if (result.a != "") argv_s = result.a.split(",");
						var argv:Array = new Array();
						for (var l:int = 0; l < argv_s.length; l++) {
							if (l == 0) {
								if (result.f == "setBmp") {
									parse = argv_s[0].match(Syntax.syntax_variant);
									if (parse) {
										if (parse.n2 != "") {
											//$a[$b]
											argv.push(search_object(parse.n, true, search_res(parse.n2))[0]);
										} else if (parse.i != "") {
											//$a[1]
											argv.push(search_object(parse.n, true, int(parse.i))[0]);
										} else {
											//$a
											argv.push(search_object(parse.n)[0]);
										}
									} else throw new TypeErr(argv_s[0], "bmp");
									continue;
								}
							}
							if (l == 1) {
								if (result.f == "shootPolar" || result.f == "shootTrace") {
									parse = argv_s[1].match(Syntax.syntax_variant);
									if (parse) {
										if (parse.n2 != "") {
											//$a[$b]
											argv.push(search_object(parse.n, true, search_res(parse.n2))[0]);
										} else if (parse.i != "") {
											//$a[1]
											argv.push(search_object(parse.n, true, int(parse.i))[0]);
										} else {
											//$a
											argv.push(search_object(parse.n)[0]);
										}
									} else throw new TypeErr(argv_s[0], "bul");
									continue;
								}
							}
							if (argv_s[l].charAt(0) == '$') {
								argv.push(match_integer_variant(argv_s[l], ip).value);
							} else {
								argv.push(int(argv_s[l]));
							}
						}
						var oi:int = search_res(result.n);
						var is_num:Boolean = false;
						var obj_result:Vector.<int>;
						if (result.i != "") {
							// $a[b] || $a[$b]

							var idx:int;
							if (result.i.charAt(0) == '$') {
								idx = match_integer_variant(result.i, ip, true).value;
							} else {
								idx = int(result.i);
							}
														
							if (res[oi].type != ResStruct.R_ARRAY) {
								oi = -1;
							} else if (res[oi].sub_type == ResStruct.R_INT) {
								assign(result.n, argv[0], true, idx, result.f);
								throw new Go();
							} else {
								obj_result = search_object(result.n, true, idx);
							}							
						} else {
							
							if (res[oi].type == ResStruct.R_ARRAY) {
								// process as array
								if (res[oi].sub_type == ResStruct.R_INT) {
									assign(result.n, argv[0], false, 0, result.f);
									throw new Go();
								} else {
									obj_result = search_object(result.n);
								}
							} else if (res[oi].type == ResStruct.R_INT) {
								assign(result.n, argv[0], false, 0, result.f);
								throw new Go();
							} else {
								// one object
								obj_result = search_object(result.n);
							}
						}
						
						for (var m:int = 0; m < obj_result.length; m++) {
							oi = obj_result[m];
							if (rlib[oi] is MON) {
								switch (result.f) {
									case "move":
										if (argv.length == 4) {
											postprocess(rlib[oi].move(argv[0], argv[1], argv[2], argv[3]), oi);
										} else if ( argv.length == 5 ) {
											postprocess(rlib[oi].move(argv[0], argv[1], argv[2], argv[3], argv[4]), oi);
										} else {
											throw new ArgErr("move", argv.length.toString());
										}
										break;
									case "setPos":
										if (argv.length	== 3) {
											postprocess(rlib[oi].setPos(argv[0], argv[1], argv[2]), oi);
										} else {
											throw new ArgErr("setPos", argv.length.toString());
										}
										break;
									case "shootPolar":
										if (argv.length == 3) {
											if (rlib[argv[1]] is BUL) {
												postprocess(rlib[oi].shootPolar(argv[0], argv[1], rlib[argv[1]], argv[2]), oi);
											} else throw new TypeErr(argv_s[1], "bul");
											
										} else {
											throw new ArgErr("shootPolar", argv.length.toString());
										}
										break;
									case "shootTrace":
										if (argv.length == 3) {
											if (rlib[argv[1]] is BUL) {
												postprocess(rlib[oi].shootTrace(argv[0], argv[1], argv[2]), oi);
											} else throw new TypeErr(argv_s[1], "bul");
										} else {
											throw new ArgErr("shootTrace", argv.length.toString());
										}
										break;
									case "die":
										if (argv.length == 1) {
											postprocess(rlib[oi].die(argv[0]), oi);
										} else {
											throw new ArgErr("dir", argv.length.toString());
										}
										break;
									case "setLife":
										if (argv.length == 1) {
											rlib[oi].life = argv[0];
										} else {
											throw new ArgErr("setLife", argv.length.toString());
										}
										break;
									case "setBmp":
										if (argv.length == 1) {
											if (rlib[argv[0]] is BMP) rlib[oi].bmp = argv[0];
											else throw new TypeErr(argv_s[0], "bmp");
										} else {
											throw new ArgErr("setBmp", argv.length.toString());
										}
										break;
									case "setHitRange":
										if (argv.length == 1) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											rlib[oi].hit_range = argv[0];
										} else {
											throw new ArgErr("setHitRange", argv.length.toString());
										}
										break;
									case "setBonus":
										if (argv.length == 4) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											if (argv[1] < 0) throw new OutOfRangeErr(argv_s[1], argv[1]);
											if (argv[2] < 0) throw new OutOfRangeErr(argv_s[2], argv[2]);
											if (argv[3] < 0) throw new OutOfRangeErr(argv_s[3], argv[3]);
											rlib[oi].sc = argv[0];
											rlib[oi].power = argv[1];
											rlib[oi].point = argv[2];
											rlib[oi].bomb = argv[3];
										} else {
											throw new ArgErr("setBonus", argv.length.toString());
										}
										break;
									default:
										throw new ObjectNotFoundErr(result.f);
								}
							} else if (rlib[oi] is BMP) {
								switch (result.f) {
									case "setRect":
										if (argv.length == 2) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											if (argv[1] < 0) throw new OutOfRangeErr(argv_s[1], argv[1]);
											rlib[oi].rect.width = argv[0];
											rlib[oi].rect.height = argv[1];
										} else {
											throw new ArgErr("setRect", argv.length.toString());
										}
									break;
									case "setPoint":
										if (argv.length == 2) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											if (argv[1] < 0) throw new OutOfRangeErr(argv_s[1], argv[1]);
											rlib[oi].rect.x = argv[0];
											rlib[oi].rect.y = argv[1];
										} else {
											throw new ArgErr("setPoint", argv.length.toString());
										}
									break;
								default:
									throw new ObjectNotFoundErr(result.f);
								}
							} else if (rlib[oi] is BUL) {
								switch (result.f) {
									case "setBmp":
										if (argv.length == 1) {
											if (rlib[argv[0]] is BMP) rlib[oi].bmp = argv[0];
											else throw new TypeErr(argv_s[0], "bmp");
										} else {
											throw new ArgErr("setBmp", argv.length.toString());
										}
										break;
									case "setHitRange":
										if (argv.length == 1) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											rlib[oi].hit_range = argv[0];
										} else {
											throw new ArgErr("setHitRange", argv.length.toString());
										}
										break;
									case "setSpeed":
										if (argv.length == 1) {
											if (argv[0] < 0) throw new OutOfRangeErr(argv_s[0], argv[0]);
											rlib[oi].speed = argv[0];
										} else {
											throw new ArgErr("setSpeed", argv.length.toString());
										}
										break;
									case "isRound":
										if (argv.length == 1) {
											if (argv[0] != 0 && argv[0] != 1) throw new OutOfRangeErr(argv_s[0], argv[0]);
											rlib[oi].round = argv[0] == 1;
										} else {
											throw new ArgErr("setSpeed", argv.length.toString());
										}
										break;
									default:
										throw new ObjectNotFoundErr(result.f);
								}
							}
							
							
							else {
							trace(getQualifiedClassName(rlib[oi]));
							}
						}					
						
						throw new Go();
					}
					
					result = eys[ip].match(Syntax.syntax_static_call);
					if (result) {
						var f:int = 0;
						if (result.n != "") {
							f = match_integer_variant(result.n, ip).value;
						} else {
							f = int(result.v);
						}
						postprocess(BUL.clear(f),0);
						throw new Go();
					}
					
				} catch (e:Go) {
					ip++;
					continue;
				} catch (e:Error) {
					e.message = "@".concat(ip.toString(), ": ", e.message);
					throw e;
				}
			}
			// all done, optimize
			//optimize();
		}
		
		private function optimize():void {
			// do the things below
			// 1. at one frame, for a certain object, only the latest one with be saved
			// 2. for a certain object, if its position has no difference between this frame 
			//    and last action frame, delete the action
			var la:Array = new Array();
			var opt:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>();
			for (var i:int = 0; i < o.length; i++) {
				var fv:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();

				for (var j:int = o[i].length - 1; j >= 0; j--) {
					var ex:Boolean = false;
					trace(o[i][j][1]);
					if (o[i][j][1]==0||o[i][j][1]==1){
						for (var k:int = 0; k < fv.length; k++) {
							if ( fv[k][0] == o[i][j][0] ) {
								ex = true;
								continue; // skip push the same object's action(move action only)
							}
						}
						if (!ex) fv.push(o[i][j]);
					} else {
						fv.push(o[i][j]);
					}
					
				}
				var v:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
				for (var l:int = 0; l < fv.length; l++) {
					if (la[fv[l][7]] == undefined) {
						v.push(fv[l]);
						la[fv[l][7]] = fv[l];
					} else {
						for (var m:int = 0; m < 8; m++) {
							if (la[fv[l][7]][m] != fv[l][m]) {
								v.push(fv[l]);
								la[fv[l][7]] = fv[l];
								continue;
							}
						}
						// if all same, do nothing
					}
				}
				opt.push(v);
			}
			// replace the output
			this.o = opt;
		}
		
		public function traceAll():String {
			var out:String = "----res----\n";
			for (var k:int = 0; k < res.length; k++) {
				var str:String = "".concat(res[k].name,":",res[k].type);
				if (res[k].type == ResStruct.R_ARRAY) str = str.concat("<", res[k].sub_type, ">(", res[k].value.length.toString(), ")");
				out = out.concat(k, ": ", str,"\n");
			}
			out = out.concat("----rlib----\n");
			for (var l:int = 0; l < rlib.length; l++) {
				out = out.concat(l, ": ", getQualifiedClassName(rlib[l]),"\n");
				if (rlib[l] is BMP) {
					var b:BMP = rlib[l] as BMP;
					out = out.concat(b.rect.toString(),"\n");
				} else if (rlib[l] is BUL) {
					var u:BUL = rlib[l] as BUL;
					out = out.concat("bmp: ", u.bmp.toString(), ",hr: ", u.hit_range.toString(), ",rd: ", u.round.toString(), ",sp: ", u.speed.toString(),"\n");
				} else {
					var m:MON = rlib[l] as MON;
					out = out.concat("bmp: ", m.bmp.toString(), ",hr: ", m.hit_range.toString(), ",life: ", m.life.toString(), ",pt:", m.point.toString(), ",po: ", m.power.toString(), ",sc: ", m.sc.toString(),"\n");
				}
			}
			out = out.concat("-----Script-----\n");
			for (var i:int = 0; i < o.length; i++) {
				for (var j:int = 0; j < o[i].length; j++) {
					out = out.concat("f: ", i, ", v: ", o[i][j],"\n");
				}
			}
			out = out.concat("-----Trace End-----\n");
			return out;
		}
				
		// deal with class functions returns, merge them into final script.
		private function postprocess(result:Vector.<EiyaAction>, target:int):void {
			for each (var act:EiyaAction in result) {
			
				if (act.frame >= o.length) {
					// first, need to place some blank frame
					for (var i:int = o.length; i <= act.frame; i++) o.push(new Vector.<Vector.<Number>>());
				}
				var p:Vector.<Number> = new Vector.<Number>(9, true);
				p[0] = target;
				p[1] = act.action|act.bullet_type;
				p[2] = act.x;
				p[3] = act.y;
				p[4] = act.rotation;
				p[5] = act.dx;
				p[6] = act.dy;
				p[7] = act.dw;
				p[8] = act.res_idx;
				o[act.frame].push(p);
			}
		}
		
		
		private function search_object(aname:String, as_arr:Boolean = false, idx:int = 0):Vector.<int> {
			var i:int = search_res(aname);
			var ret:Vector.<int> = new Vector.<int>();
			if (i == -1) throw new ObjectNotFoundErr(aname);
			if (res[i].type == ResStruct.R_ARRAY) {
				if ( as_arr ) {
					if ( idx < 0 || idx > res[i].value.length) throw new OutOfRangeErr(aname,idx,res[i].value.length);
					ret.push(res[i].value[idx]);
				} else {
					ret = res[i].value;
				}
				return ret;
			} else if (!as_arr) {
				ret.push(res[i].value[0]);
				return ret;
			} else {
				throw new ObjectNotFoundErr(aname);
			}
		}
		
		
		private function copy(sname:String, tname:String):void {
			var i:int = search_res(sname);
			if (i == -1) throw new ObjectNotFoundErr(sname);
			if (search_res(tname) != -1) throw new ObjectAlreadyExistErr(tname);
			var r:ResStruct = new ResStruct();
			r.name = tname;
			r.type = res[i].type;
			r.value = new Vector.<int>();
			r.value.push(rlib.push(rlib[res[i].value[0]].clone()) - 1);
			r.id = res.push(r) - 1;
		}
		
		
		private function declare(vname:String, vclass:String, as_arr:Boolean=false, idx:int=0): void {
			var i:int = search_res(vname);
			if (i == -1) {
				var r:ResStruct = new ResStruct();
				r.name = vname;
				var cl:Class;
				switch (vclass) {
					case ResStruct.R_BMP:
						cl = BMP;
						break;
					case ResStruct.R_BUL:
						cl = BUL;
						break;
					case ResStruct.R_MON:
						cl = MON;
						break;
				}
				if ( as_arr ) {
					r.type = ResStruct.R_ARRAY;
					r.sub_type = vclass;
					r.value = new Vector.<int>();
					
					for (var j:int = 0; j < idx; j++) {
						r.value.push(rlib.push(new cl()) - 1);
					}
					r.id = res.push(r) - 1;
				} else {
					r.type = vclass;
					r.value = new Vector.<int>();
					r.value.push(rlib.push(new cl()) - 1);
					r.id = res.push(r) - 1;
				}
			} else {
				throw new ObjectAlreadyExistErr(vname);
			}
		}
				
		/**********************************************************
		 * 
		 * 	return structure
		 * 	Obj {
		 *      name 
		 *      idx	[opt]
		 *      value 
		 * 		has
		 *  }
		 *
		 **********************************************************/
		private function match_integer_variant(str:String, line_id:int, is_idx:Boolean=false):Object {
			var result:Object = str.match(Syntax.syntax_variant);
			var ret:Object = {
				name:"String",
				idx:-1,
				value:0,
				has:false   //has value
			};
			if (result) {
				var has:Boolean = search_res(result.n) !=-1 ;
				ret.has = has;
				if (result.i != "") {
					if (is_idx) {
						// like this: $a[$b[c]] or $a[$b[$c]]]
						throw new SyntaxErr(line_id, "index can not be a array element");
					} else {
						if (result.n2 != "") {
							var sub_match:Object = result.i.match(Syntax.syntax_variant);
							if (sub_match.i != "") {
								// like this: $a[$b[c]]
								throw new SyntaxErr(line_id, "index can not be a array element");
							} else {
								// like this: $a[$b]
								ret.name = result.n;
								ret.idx = get_value(sub_match.n);
								if (has) ret.value = get_value(result.n,get_value(sub_match.n));
							}
						} else {
							//like this: $a[i]
							ret.name = result.n;
							ret.idx = int(result.i);
							if (has) ret.value = get_value(result.n, int(result.i));
						}
					}
				} else {
					// $a
					ret.name = result.n;
					if (has) ret.value = get_value(result.n);
				}
				return ret;
			} else {
				throw new SyntaxErr(line_id, "not a integer");
			}
		}
		
		private function get_value (vname:String, idx:int = -1):int {
			var i:int = search_res(vname);
			if (i == -1) throw new ObjectNotFoundErr(vname);
			if (res[i].type == ResStruct.R_ARRAY) {
				if (idx < 0 || idx >= res[i].value.length) 
					throw new OutOfRangeErr(vname,idx,res[i].value.length);
				if (res[i].sub_type != ResStruct.R_INT) 
					throw new TypeErr(vname.concat("[", idx, "]"), ResStruct.R_INT);
				return res[i].value[idx];
			} else if (res[i].type == ResStruct.R_INT) {
				return res[i].value[0];
			} else {
				if (idx == -1) {
					throw new TypeErr(vname,ResStruct.R_ARRAY);
				} else {
					throw new TypeErr(vname,ResStruct.R_INT);	
				}
				
			}
		}
		
		private function assign(vname:String, value:int, as_arr:Boolean = false, idx:int = 0, func:String = ""):void {
			var i:int = search_res(vname);
			if (i == -1) {
				// new variant
				var r:ResStruct = new ResStruct();
				r.name = vname;
				if (as_arr) {
					r.type = ResStruct.R_ARRAY;
					r.sub_type = ResStruct.R_INT;
					r.value = new Vector.<int>();
					for (var j:int = 0;j<idx;j++) r.value.push(value);
				} else {
					r.type = ResStruct.R_INT;
					r.value = new Vector.<int>();
					r.value.push(value);
				}
				r.id = res.push(r)-1;
			} else {
				if ( as_arr ) {
					if (res[i].type != ResStruct.R_ARRAY) throw new TypeErr(vname,ResStruct.R_ARRAY);
					if (idx < 0 || idx >= res[i].value.length) throw new OutOfRangeErr(vname,idx,r.value.length);
					if (res[i].sub_type != ResStruct.R_INT) throw new TypeErr(vname.concat("[", idx, "]"), ResStruct.R_INT);
					if (func == "") {
						res[i].value[idx] = value;
					} else if (func == "+") {
						res[i].value[idx] += value;
					} else if (func == "-") {
						res[i].value[idx] -= value;
					} else {
						throw new ObjectNotFoundErr("function '".concat(func, "'"));
					}
					
				} else {
					if (res[i].type == ResStruct.R_ARRAY && res[i].sub_type == ResStruct.R_INT) {
						for (var k:int = 0; k < res[i].value.length; k++) {
							if (func == "") {
								res[i].value[k] = value;
							} else if (func == "+") {
								res[i].value[k] += value;
							} else if (func == "-") {
								res[i].value[k] -= value;
							} else {
								throw new ObjectNotFoundErr("function '".concat(func, "'"));
							}
						}
					} else if (res[i].type == ResStruct.R_INT) {
						if (func == "") {
							res[i].value[0] = value;
						} else if (func == "+") {
							res[i].value[0] += value;
						} else if (func == "-") {
							res[i].value[0] -= value;
						} else {
							throw new ObjectNotFoundErr("function '".concat(func, "'"));
						}
					} else throw new TypeErr(vname,ResStruct.R_INT);
				}				
			}
		}
		
		private function search_res(search_name:String):int {
			for each (var r:ResStruct in res) {
				if (r.name == search_name) return r.id;
			}
			return -1;
		}
		
	}
}