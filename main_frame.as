/******************************************************************************/
/*                                                                            */
/*                           EiyaEngine Main Src                              */
/*                                                                            */
/* This script can only be used in bilibili.tv, and may be obsoleted due to   */
/* the new security policy, so just for fun.                                  */
/*                                                                            */
/*        I especially recommend you to read the comment on this site:        */
/*        http://jsfiddle.net/L4jrL/2/ It's very good for a rookie.           */
/*                                                                            */
/* All resources used in the script are serialized, deflated, and encoded in  */
/* `base64`.                                                                  */
/*                                                                            */
/*   There are two binary excutable libraries:                                */
/*                                                                            */
/*   1. KeyboardHelper   Modified from nekofs's code, works on keyboard       */
/*                       listening and setting framerate.                     */
/*                                                                            */
/*   2. CORE             A library used to handle bitmap processing, scenario */
/*                       and resource library decoding, etc., which may be    */
/*                       impossible to implement with bilibili's barrage code.*/
/*                                                                            */
/******************************************************************************/

ScriptManager.clearEl();
var create = $.root.loaderInfo.content.create;
var takeFocus = $.root.loaderInfo.content.document.playerContainer.playerHolder.setFocus;
var R = $G._get('r');
var key = R.key;
var core = R.core;
var sc = R.sc;
trace(sc.length);
var rlib = core.loadRlib($G._get('rlib'));
var	bmp = R.bmp;
var bs = R.bs;
var pts = core.pts;
/* bullet information */
var blib = core.getPosInfo();
/* player shooting bullet information */
var sblib = core.getPosInfo();
/* enemies position information */
var elib = core.getPosInfo();
/* bonus */
var bonus = core.getPosInfo();
/* user plane and bullet */
var p0 = R.p0;
var p1 = R.p1; 
/* remember: the center is at (5,5) and the r is 5*/
/* w:10,h:42*/
var b0 = R.b0; 
var b1 = R.b1; 
/* bonus 2:power 3:point 4:bomb */
var b2 = R.b2; 
var b3 = R.b3; 
var b4 = R.b4; 
var bb = R.bb; 
var sa = R.sa; 
var sb = R.sb; 
var sm = R.sm; 
var jp = R.jp; 
var slash = R.slash;
var fin = R.fin;
var submit = R.submit;
var quit = R.quit;
var canvas = $.createCanvas({x:30,y:13,lifeTime:214748364});
var board = $.createCanvas({x:380,y:33,lifeTime:214748364});
var board_bg = core.getBitmapData(150,200,"");
var blank1 = core.getBitmapData(150,200,"");
blank1.lock();
blank1.copyPixels(slash,slash.rect,$.createPoint(38,105));
blank1.copyPixels(bs[1],bs[1].rect,$.createPoint(50,105));
blank1.copyPixels(bs[0],bs[0].rect,$.createPoint(62,105));
blank1.copyPixels(bs[0],bs[0].rect,$.createPoint(74,105));
blank1.copyPixels(slash,slash.rect,$.createPoint(50,119));
blank1.copyPixels(bs[8],bs[8].rect,$.createPoint(62,119));
blank1.copyPixels(bs[5],bs[5].rect,$.createPoint(74,119));
blank1.copyPixels(bs[0],bs[0].rect,$.createPoint(86,119));
blank1.copyPixels(bs[0],bs[0].rect,$.createPoint(98,119));
blank1.unlock();
board.addChild(core.getStageBitmap(board_bg));
var bg = core.getStageBitmapData();
var blank0 = core.getStageBitmapData();
canvas.addChild(core.getStageBitmap(bg));
/********************************************/
/*             for bomb                     */
/********************************************/
var bubble = core.getPosInfo();
for(var atv = 0;atv<8;atv++) {
	var atb = core.getPosVector();
	bubble.push(atb);
}
var b_h_x = 20;
var b_h_y = 200;
var b_v_x = 100;
var b_v_y = -50;
var bmbf = R.bmbf;
var bmbb = R.bmbb;
var bmbz = R.bmbz;
/******************************************************************************/
/*                            Stage Wide Variant                              */
/******************************************************************************/
var LEFT_TOP = $.createPoint(0,0);
/********************************/
/* values of playing_state:     */
/* 0: normal                    */
/* 1: pause                     */
/* 2: loading                   */
/* 3: when using bomb           */
/* 4: when talking with boss    */
/* 5: when going to die         */
/* 6: after die(1s invincible)	*/
/********************************/
var game_state = 2;
/* player position */
var p_x = 138;
var p_y = 303;
/* player center position */
var p_cx = 150;
var p_cy = 320;
/* power */
var p_pw = 0;
/* bomb */
var p_b = 3;
var bomb_down = 0;
/* life */
var p_l = 1;
/* score */
var p_s = 0;
/* invincible */
var p_i = 0;
/* hit range */
var p_hr = 2;
/* graze range */
var p_gr = 10;
var p_grc = 0;
/* player speed */
var p_v = 5;
var p_v1 = 3;
var sp = 0;
/* Time */
var p_ti = 0;
/* point */
var p_pt = 0;
/* matrix */
var mat = create('flash.geom.Matrix');
/* frame count */
var f_count = 0;
var f_subc = 0;
/* some local variant */
var dx = 0;
var dy = 0;
var nx = 0;
var ny = 0;
var ox = 0;
var oy = 0;
var r = 0;
var a = 0;
var t = 0;
var i = 0;
var j = 0;
var k = 0;
var l = 0;
/* object count */
var o_c = 0;
var toc = 0;

/* let the constant be the literal value */
/* p_w = 24; */
/* p_h = 34; */
/* b_speed = 18 */
/******************************************************************************/
/*                                Main Area                                   */
/******************************************************************************/
function _index(l,t){
	var __j=0;
	while (__j<l.length){
		if (l[__j][12]==t) return __j;
		__j++;
	}
	return -1;
}
function check_enemy_bullet_colli(eid,bid) {
	if (sblib[bid][12] == -1) return 0;
	dx = elib[eid][7]-sblib[bid][7];
	dy = elib[eid][8]-sblib[bid][8];
	r = elib[eid][11]+sblib[bid][11];
	if (dx*dx+dy*dy<r*r) {
		k=elib[eid][5];
		rlib[k][2]-=2;
		p_s += 503;
		p_ti += 1;
		sblib[bid][12] = -1;
	}
	return 0;
}
function check_player_enemy_colli(eid) {
	dx = p_cx - elib[eid][7];
	dy = p_cy - elib[eid][8];
	r = p_hr + elib[eid][11];
	if (dx*dx+dy*dy<r*r) {
		k=elib[eid][5];
		rlib[k][2] -= 1000;
		return -1;
	}
	return 0;
}
function check_player_bullet_colli(bid){
	dx = p_cx - blib[bid][7];
	dy = p_cy - blib[bid][8];
	r = p_gr + blib[bid][11];
	if (dx*dx+dy*dy<r*r) {
		/* go into graze range */
		p_s += 489;
		p_grc += 1;
		/* check hit */
		r = p_hr + blib[bid][11];
		if (dx*dx+dy*dy<r*r) {
			blib[bid][12]=-1;
			return -1;
		}
	}
	return 0;	
}
function check_player_bonus_colli(bid) {
	if (bonus[bid][12] == -1) return;
	dx = p_cx - bonus[bid][7];
	dy = p_cy - bonus[bid][8];
	r = p_gr + bonus[bid][11];
	if (dx*dx+dy*dy<r*r) {
		switch (bonus[bid][9]) {
			case 0:
				p_pt += bonus[bid][10];
				p_s  += bonus[bid][10]*367;
				if (p_pt>100){
					p_pt=0;
					p_l+=1;
				}
				break;
			case 1:
				p_pw += bonus[bid][10];
				break;
			case 2:
				p_b += bonus[bid][10];
				break;
			default:break;
		}
		bonus[bid][12]=-1;
	}
}
function check_one_grid(g,x,y){
	var _i=0;
	var _j=0;
	for(_i=0;_i<g[x][y][1].length;_i++) {
		/* check enemy h_it */
		for(_j=0;_j<g[x][y][2].length;_j++) {
			check_enemy_bullet_colli(g[x][y][1][_i],g[x][y][2][_j]);
		}
	}
	if(g[x][y][0].length>0){
		/* contains self plane */
		for (_i=0;_i<g[x][y][3].length;_i++) {
			if (check_player_bullet_colli(g[x][y][3][_i]) == -1) return -1;
		}
		for (_i=0;_i<g[x][y][1].length;_i++) {
			/* check self and enemy */
			if (check_player_enemy_colli(g[x][y][1][_i]) == -1) return -2;
		}
		for (_i=0;_i<g[x][y][4].length;_i++) {
			check_player_bonus_colli(g[x][y][4][_i]);
		}
	}
	return 0;
}
function check_two_grids(g,x1,y1,x2,y2){
	if (x2<0 || x2>=10 || y2>=12) return 0;
	var _i=0;
	var _j=0;
	/* 1->2 */
	for(_i=0;_i<g[x1][y1][1].length;_i++) {
		/* check enemy hit */
		for(_j=0;_j<g[x2][y2][2].length;_j++) {
			check_enemy_bullet_colli(g[x1][y1][1][_i],g[x2][y2][2][_j]);
		}
	}
	
	/* 2->1 */
	for(_i=0;_i<g[x2][y2][1].length;_i++) {
		/* check enemy hit */
		for(_j=0;_j<g[x1][y1][2].length;_j++) {
			check_enemy_bullet_colli(g[x2][y2][1][_i],g[x1][y1][2][_j]);
		}
	}
	/* 1->2 */
	if(g[x1][y1][0].length>0){
		/* contains self plane */
		for (_i=0;_i<g[x2][y2][3].length;_i++) {
			if (check_player_bullet_colli(g[x2][y2][3][_i]) == -1) return -1;
		}
		for (_i=0;_i<g[x2][y2][1].length;_i++) {
			/* check self and enemy */
			if (check_player_enemy_colli(g[x2][y2][1][_i]) == -1) return -2;
		}
		for (_i=0;_i<g[x2][y2][4].length;_i++) {
			check_player_bonus_colli(g[x2][y2][4][_i]);
		}
	}
	/* 2->1 */
	if(g[x2][y2][0].length>0){
		/* contains self plane */
		for (_i=0;_i<g[x1][y1][3].length;_i++) {
			if (check_player_bullet_colli(g[x1][y1][3][_i]) == -1) return -1;
		}
		for (_i=0;_i<g[x1][y1][1].length;_i++) {
			/* check self and enemy */
			if (check_player_enemy_colli(g[x1][y1][1][_i]) == -1) return -2;
		}
		for (_i=0;_i<g[x1][y1][4].length;_i++) {
			check_player_bonus_colli(g[x1][y1][4][_i]);
		}
	}
	return 0;
}
function create_self_bullet_bpos(bt,ba) {
	var bpos = core.getPosVector();
	bpos[0] = p_cx-5;
	if (bt==0) {
		bpos[1] = p_cy-21;
	} else {
		bpos[1] = p_cy-5;
		bpos[5] = 1;
	}
	switch (ba) {
		case 0:
			bpos[4] = -18;
			break;
		case -1:
			bpos[2] = -0.1309;
			bpos[3] = -2.3495;
			bpos[4] = -17.846;
			break;
		case 1:
			bpos[2] = 0.1309;
			bpos[3] = 2.3495;
			bpos[4] = -17.846;
			break;
		case 2:
			bpos[2] = 0.5236;
			bpos[3] = 9;
			bpos[4] = -15.5884;
			break;
		case -2:
			bpos[2] = -0.5236;
			bpos[3] = -9;
			bpos[4] = -15.5884;
			break;
		case 3:
			bpos[2] = -0.7854;
			bpos[3] = -12.7279;
			bpos[4] = -12.7279;
			break;
		case -3:
			bpos[2] = 0.7854;
			bpos[3] = 12.7279;
			bpos[4] = -12.7279;
		break;
	}
	bpos[7] = p_cx;
	bpos[8] = p_cy;
	bpos[11] = 9;
	bpos[12] = o_c++;
	sblib.push(bpos);	
}
function generate_bonus(_type,_num,_x,_y) {
	var i1=20;
	var j1=_num;
	var bpos = core.getPosVector();
	while(j1>0){
		if(j1<i1){
			i1 = Math.floor(i1/4);
		} else {
			bpos = core.getPosVector();
			bpos[0] = _x + (50*Math.random()-25);
			bpos[1] = _y + (30*Math.random()-25);
			bpos[4] = 3;
			bpos[7] = bpos[0]+5;
			bpos[8] = bpos[1]+5;
			bpos[9] = _type;
			bpos[10] = i1;
			bpos[11] = 5;
			bonus.push(bpos);
			j1-=i1;
		}
	}
}

function main(){
	if (Player.state == "pause") return;
	var kc = key.code;
	i = f_count;
	if (i>1800&&i<1870) {
		if ((kc&0x100)!=0) {
			Player.seek(100500);
			f_count = 1870;
		}
		kc &= 0xf;
	} else if (i>3270&&i<3870) {
		if ((kc&0x100)!=0) {
			Player.seek(200500);
			f_count = 3870;
		}
		kc &= 0xf;
	} else if (i>7620&&i<7850) {
		if ((kc&0x100)!=0) {
			Player.seek(399500);
			f_count = 7850;
		}
		kc &= 0xf;
	}
	if (f_count>=sc.length) {
		/* end */
		Player.seek(400000);
		canvas.removeEventListener('enterFrame',main);
		canvas.remove();
		board.remove();
		var t0001 = $.createCanvas({x:200,y:100,lifeTime:2147483647});
		var t0002 = core.getStageBitmap(fin);
		t0001.addChild(t0002);
		var t000s = $.createComment(p_s.toString(),{
			x:200,
			y:175,
			fontsize:40,
			lifeTime:2147483647});
		var t0005 = $.createCanvas({x:200,y:250,lifeTime:2147483647});
		var t0004 = $.createButton({
			x:200,
			y:250,
			text:" ",
			lifeTime:2147483647,
			onclick:function(){
				core.rank(p_s);
				ScriptManager.clearTimer();
				ScriptManager.clearEl();
				ScriptManager.clearTrigger();
				Player.seek(405000);
				Player.play();
			}
			});
		t0004.width = 245;
		t0004.alpha = 0;
		var t0003 = core.getStageBitmap(submit);
		t0003.x = 3;
		t0005.addChild(t0003);
		var t0006 = $.createCanvas({x:200,y:300,lifeTime:2147483647});
		var t0007 = $.createButton({
			x:200,
			y:300,
			text:" ",
			lifeTime:2147483647,
			onclick:function(){
				ScriptManager.clearTimer();
				ScriptManager.clearEl();
				ScriptManager.clearTrigger();
				Player.seek(405000);
				Player.play();
			}
			});
		t0007.width = 119;
		t0007.alpha = 0;
		var t0008 = core.getStageBitmap(quit);
		t0008.x = 3;
		t0006.addChild(t0008);
		t0001.x = (Player.width-151)/2;
		t000s.x = (Player.width-t000s.width)/2;
		t0005.x = (Player.width-239)/2;
		t0004.x = (Player.width-245)/2;
		t0006.x = (Player.width-113)/2;
		t0007.x = (Player.width-119)/2;
		Player.pause();
		Utils.interval(function(){Player.seek(400000);},2000,0);
		return;
	}
	
	canvas.visible = true;
	board.visible = true;
	var no_bul = false;
	var bpos = core.getPosVector();
	
	/* new collision grid */
	var ncg = core.gridCollect();

	/* place the game elements on stage & grid */
	bg.lock();
	bg.copyPixels(blank0,blank0.rect,LEFT_TOP);
		
	
	
	
	if (game_state==6){
		p_i++;
		if (p_i>90) {
			p_i=0;
			game_state=2;
		}
	}
		
	
	/* bomb */
	if (game_state == 3) {
		if (f_subc > 60) {
			f_subc = 0;
			bomb_down = 0;
			game_state = 2;
		} else {
			no_bul = true;
		}
	}
	if ((kc&0x20)!=0 && bomb_down==0 && p_b > 0) {
		bomb_down = 1;
	}
	if ((kc&0x20)==0 && bomb_down==1) {
		p_b -= 1;
		/* set bomb */
		game_state = 3;		
		f_subc = 0;
		bomb_down = 2;
		/* clear bullet */
		blib = core.getPosInfo();
		sblib = core.getPosInfo();
		/* hurt all the enemies */
		for(i=0;i<elib.length;i++) {
			k = elib[i][5];
			if (game_state!=5){
				rlib[k][2]-=200;
			} else {
				rlib[k][2]-=500;
			}
			if (rlib[k][2] < 0) {
				/* die */
				rlib[k][7]=-1;		
				dx = elib[i][0];
				dy = elib[i][1];
				generate_bonus(0,rlib[k][4],dx,dy);
				generate_bonus(1,rlib[k][3],dx,dy);
				generate_bonus(2,rlib[k][5],dx,dy);
				elib.splice(i,1);
				i--;
			}
		}
		for(i=0;i<8;i++) {
			bubble[i][7] = p_cx-15;
			bubble[i][8] = p_cy-15;
		}
		b_h_x = 20;
		b_h_y = 200;
		b_v_x = 100;
		b_v_y = -50;
		/* wait next frame throwing bomb */
		return;
		no_bul=true;
	}
	/* going to die, only bomb is allowed */
	if (game_state == 5) {
		if (f_subc < 10) {
			f_subc++;
			return;
		} else {
			/* die */
			p_l--;
			if (p_l<=0) {
				/* game over */
				f_count = sc.length;
				return;
			} else {
				/* bonus */
				generate_bonus(0,p_pw,150,30);
				generate_bonus(2,p_b,150,30);
				p_b = 3;
				p_pw = 1;
				/* reset position */
				p_x = 138;
				p_y = 303;
				p_cx = 150;
				p_cy = 320;
				f_subc = 0;
				game_state=6;
				blib = core.getPosInfo();
				sblib = core.getPosInfo();
				no_bul=true;
			}
		}
	}
			
	/* player */
	sp = 0;
	if ((((kc|(kc>>1))&((kc>>2)|(kc>>3)))&0x1)==1) {
		/* both horizon and vertical */
		sp = 0.707;
	} else {
		sp = 1;
	}
	if ((kc&0x80)!=0){
		/* shift */
		sp *= p_v1;
	} else {
		sp *= p_v;
	}
	if ((kc&0x04)!=0) {
		/* left */
		p_x -= sp;
		if (p_x<0){
			p_x = 0;
			p_cx = 12;
		} else {
			p_cx -= sp;
		}
	} else if ((kc&0x08)!=0){
		p_x += sp;
		
		if (p_x>276){
			p_x = 276;
			p_cx = 288;
		} else {
			p_cx += sp;
		}
	}
	if ((kc&1)!=0){
		/* up */
		p_y -= sp;
		
		if (p_y<0){
			p_y = 0;
			p_cy = 17;
		} else {
			p_cy -= sp;
		}
	} else if ((kc&2) != 0){
		p_y += sp;
		if (p_y>326){
			p_y = 326;
			p_cy = 343;
		} else {
			p_cy += sp;
		}
	}

	ncg[(Math.floor(p_cx/30))][(Math.floor(p_cy/30))][0].push(1);
	
	/* move the bullet */
	i=0;
	while (i<blib.length){
		dx = blib[i][3];
		dy = blib[i][4];
		blib[i][7] += dx;
		blib[i][8] += dy;
		nx = blib[i][7];
		ny = blib[i][8];
		if (nx<0||nx>300||ny<0||ny>360) {
			blib.splice(i,1);
		} else {
			blib[i][0] += dx;
			blib[i][1] += dy;
			ncg[Math.floor(blib[i][7]/30)][Math.floor(blib[i][8]/30)][3].push(i);
			i++;
		}	
	}

	/* move self bullet */
	i=0;
	while (i<sblib.length){
		toc = sblib[i][12];
		if (sblib[i][5] == 0) {
			/* normal bullet */
			dx = sblib[i][3];
			dy = sblib[i][4];
			sblib[i][7] += dx;
			sblib[i][8] += dy;
		} else {
			/* trace */
			if (elib.length == 0){
				/* go as normal */
				dx = sblib[i][3];
				dy = sblib[i][4];
				sblib[i][7] += dx;
				sblib[i][8] += dy;
			} else {
				dx = elib[0][7] - sblib[i][7];
				dy = elib[0][8] - sblib[i][8];
				nx = dx - sblib[i][3];
				ny = dy - sblib[i][4];
				if (nx<0.01 && nx>-0.01 && ny<0.01&& ny>-0.01){
					/* consider as the same, go normal */
					sblib[i][7] += dx;
					sblib[i][8] += dy;
				} else {
					r = Math.sqrt(dx*dx+dy*dy);
					a = Math.asin(dx/r);
					if (dy<0) a = 3.14159-a;
					t = r/18;
					dx /= t;
					dy /= t;
					sblib[i][7] += dx;
					sblib[i][8] += dy;
					sblib[i][2] = -a;
				}
			}
		}
		nx = sblib[i][7];
		ny = sblib[i][8];
		if (nx<0||nx>300||ny<0||ny>360) {
			sblib.splice(i,1);
		} else {
			sblib[i][0] += dx;
			sblib[i][1] += dy;
			ncg[Math.floor(nx/30)][Math.floor(ny/30)][2].push(i);
			i++;
		}
	}
	/* player shoot */
	if ((kc&0x10)!=0 && f_count%3==0){
		create_self_bullet_bpos(0,0);
		if (p_pw>7) {
			/* add two tracing bullets */
			create_self_bullet_bpos(1,2);
			create_self_bullet_bpos(1,-2);
		}
		if (p_pw>47) {
			/* add two more bullets */
			create_self_bullet_bpos(0,1);
			create_self_bullet_bpos(0,-1);
		}
		if (p_pw>127) {
			/* add two tracing bullets */
			create_self_bullet_bpos(1,3);
			create_self_bullet_bpos(1,-3);
		}
	}

	/* move the bonus */
	if ((p_pw>125||(kc&0x80)!=0)&&p_cy<90) {
		/* absorb */
		/* set speed = 18 */
		i=0;
		while (i<bonus.length){
			dx = p_cx - bonus[i][7];
			dy = p_cy - bonus[i][8];
			nx = dx - bonus[i][3];
			ny = dy - bonus[i][4];
			if (nx<0.01 && nx>-0.01 && ny<0.01&& ny>-0.01){
				/* consider as the same, go normal */
				bonus[i][7] += dx;
				bonus[i][8] += dy;
			} else {
				r = Math.sqrt(dx*dx+dy*dy);
				a = Math.asin(r/dx);
				if (dy<0) a = 3.14159-a;
				t = r/18;
				dx /= t;
				dy /= t;
				bonus[i][7] += dx;
				bonus[i][8] += dy;
				bonus[i][2] = a;
			}
			nx = bonus[i][7];
			ny = bonus[i][8];
			if (nx<0||nx>300||ny<0||ny>360) {
				bonus.splice(i,1);
			} else {
				bonus[i][0] += dx;
				bonus[i][1] += dy;
				ncg[Math.floor(nx/30)][Math.floor(ny/30)][4].push(i);
				i++;
			}
		}
	} else {
		i=0;
		while (i<bonus.length) {
			/* set the speed to 4 */
			bonus[i][8] += 4;
			ny = bonus[i][8];
			if (ny<0||ny>360) {
				bonus.splice(i,1);
			} else {
				bonus[i][1] += 4;
				ncg[Math.floor(bonus[i][7]/30)][Math.floor(bonus[i][8]/30)][4].push(i);
				i++;
			}
		}	
	}
	
	for(i=0;i<sc[f_count].length;i++){
		bpos = core.getPosVector();
		switch(sc[f_count][i][1]){
			/* action */
			case 0x10:
				no_bul = true;
				break;
			case 0x8:
				k = sc[f_count][i][0];
				toc = rlib[k][7];
				if (toc != -1) {
					j = _index(elib, toc);
					if (j == -1) break;
					rlib[k][7] = -1;
					elib.splice(j,1);
				}
				break;
			case 0x4:
				/* shoot an aim bullet */
				/* calc the dx,dy,rot */
				if (no_bul) break;
				k = sc[f_count][i][0];
				toc = rlib[k][7];
				if (toc==-1) break;
				j = _index(elib, toc);
				if (j==-1) break;
				/*
				dx = p_cx - elib[j][7];
				dy = p_cy - elib[j][8];
				r = Math.sqrt(dx*dx+dy*dy);
				k = sc[f_count][i][8];
				t = r/(rlib[k][3]);
				a = Math.asin(dx/r);
				//if (dy<0) a = 3.14159-a;
				a += sc[f_count][i][4];
				dx = r*Math.sin(a);
				dy = r*Math.cos(a);
				*/
				k = sc[f_count][i][8];
				bpos[11] = rlib[k][1];
				bpos[6] = rlib[k][0];
				
				if (f_count-elib[j][14] <= 5) {
					a = elib[j][13] + sc[f_count][i][4];				
				} else {
					dx = p_cx - elib[j][7];
					dy = p_cy - elib[j][8];
					r = Math.sqrt(dx*dx+dy*dy);
					a = Math.asin(dx/r);
					if(dy<0) a=3.14159-a;
					elib[j][13] = a;
					elib[j][14] = f_count;
					a += sc[f_count][i][4];
				}
				r = rlib[k][3];
				k = bpos[6];
				bpos[0] = elib[j][7]-rlib[k][0];
				bpos[1] = elib[j][8]-rlib[k][1];
				bpos[2] = -a;
				bpos[3] = r*Math.sin(a);
				bpos[4] = r*Math.cos(a);
				bpos[7] = elib[j][7];
				bpos[8] = elib[j][8];
				bpos[9] = rlib[k][2];
				bpos[10] = rlib[k][3];
				bpos[12] = o_c++;
				blib.push(bpos);
				/* collision check go to next frame */
				break;
			case 0x3:
			case 0x2:
				if (no_bul) break;
				k = sc[f_count][i][0];
				toc = rlib[k][7];
				if (toc==-1) break;
				j = _index(elib, toc);
				if (j==-1) break;
				k = sc[f_count][i][8];
				r = rlib[k][3];
				bpos[6] = rlib[k][0];
				bpos[11] = rlib[k][1];
				k = bpos[6];
				bpos[9] = rlib[k][2];
				bpos[10] = rlib[k][3];				
				bpos[0] = elib[j][7]-rlib[k][0];
				bpos[1] = elib[j][8]-rlib[k][1];
				bpos[2] = sc[f_count][i][4];
				bpos[3] = -r*Math.sin(bpos[2]);
				bpos[4] = r*Math.cos(bpos[2]);
				bpos[7] = elib[j][7];
				bpos[8] = elib[j][8];
				bpos[12] = o_c++;
				blib.push(bpos);
				break;
			case 0x1:
				k = sc[f_count][i][0];
				toc = rlib[k][7];
				if (toc < 0) break;
				j = _index(elib, toc);
				
				elib[j][11] = rlib[k][1];
				elib[j][7] = sc[f_count][i][2];
				elib[j][8] = sc[f_count][i][3];
				elib[j][2] = sc[f_count][i][4];
				elib[j][5] = sc[f_count][i][0];
				k = elib[j][5];
				elib[j][6] = rlib[k][0];
				k = elib[j][6];
				elib[j][0] = elib[j][7] - rlib[k][0];
				elib[j][1] = elib[j][8] - rlib[k][1];
				k = sc[f_count][i][0];
				if (rlib[k][1] != 0) {
					ox = Math.floor(elib[j][7]/30);
					oy = Math.floor(elib[j][8]/30);
					if (ox>=0&&oy>=0&&ox<10&&oy<12) ncg[ox][oy][1].push(j);	
				}
				break;
			case 0x0:
				k = sc[f_count][i][0];
				toc = rlib[k][7];
				if (toc == -1) break;
				if (toc != -2) {
					j = _index(elib, toc);
					if (j==-1) break;
					elib[j][7] = sc[f_count][i][2];
					elib[j][8] = sc[f_count][i][3];
					elib[j][2] = sc[f_count][i][4];
					elib[j][5] = sc[f_count][i][0];
					k=elib[j][5];
					elib[j][6] = rlib[k][0];
					k=elib[j][6];
					elib[j][0] = elib[j][7] - rlib[k][0];
					elib[j][1] = elib[j][8] - rlib[k][1];
				} else {
					bpos[7] = sc[f_count][i][2];
					bpos[8] = sc[f_count][i][3];
					bpos[2] = sc[f_count][i][4];
					bpos[5] = sc[f_count][i][0];
					k=bpos[5];
					bpos[6] = rlib[k][0];
					k=bpos[6];
					bpos[0] = bpos[7] - rlib[k][0];
					bpos[1] = bpos[8] - rlib[k][1];
					k=sc[f_count][i][0];
					bpos[11] = rlib[k][1];
					bpos[12] = o_c++;
					rlib[k][7] = bpos[12];
					bpos[13]=0;
					bpos[14]=-100;
					j = elib.length;
					elib.push(bpos);
					ox = -1000;
					oy = -1000;
				}
				k=sc[f_count][i][0];
				if (rlib[k][1] != 0) {
					ox = Math.floor(elib[j][7]/30);
					oy = Math.floor(elib[j][8]/30);
					if (ox>=0&&oy>=0&&ox<10&&oy<12) ncg[ox][oy][1].push(j);
				}
				break;
			default:break;
		}
	}

	//trace('after read');
		//trace("f=",f_count);
	for(i=0;i<elib.length;i++) {
		ox = Math.floor(elib[i][7]/30);
		oy = Math.floor(elib[i][8]/30);
		if (ox>=0&&oy>=0&&ox<10&&oy<12) {
			if (ncg[ox][oy][1].indexOf(i) == -1) {
				ncg[ox][oy][1].push(i);
			}
		}
	}
	
	
	/* hit test */
	for(i=0;i<10;i++) {
		for (j=0;j<12;j++) {
			k=check_one_grid(ncg,i,j);
			k+=check_two_grids(ncg,i,j,i+1,j);
			k+=check_two_grids(ncg,i,j,i-1,j+1);
			k+=check_two_grids(ncg,i,j,i,j+1);
			k+=check_two_grids(ncg,i,j,i+1,j+1);
			if (k<0) {
				/* TODO: player got hit */
				if (game_state != 6) game_state=5;
			}
		}
	}
	/* draw bullet */
	if (!no_bul) {			
		i=0;
		while (i<sblib.length) {
			if (sblib[i][12]==-1) {
				sblib.splice(i,1);
			} else {
				mat.identity();
				mat.rotate(sblib[i][2]);
				mat.translate(sblib[i][0],sblib[i][1]);
				if (sblib[i][5] == 0) {
					bg.draw(b0,mat);
				} else {
					bg.draw(b1,mat);
				}
				i++;
			}
		}
	} else {
		blib = core.getPosInfo();
		sblib = core.getPosInfo();
	}
	/* draw enemies */
	i=0;
	while (i<elib.length) {
		k=elib[i][5];
		if (rlib[k][2]<0) {
			/* die */
			rlib[k][7]=-1;		
			dx = elib[i][0];
			dy = elib[i][1];
			generate_bonus(0,rlib[k][3],dx,dy);
			generate_bonus(1,rlib[k][4],dx,dy);
			generate_bonus(2,rlib[k][5],dx,dy);
			elib.splice(i,1);
		} else {
			mat.identity();
			mat.rotate(elib[i][3]);
			mat.translate(elib[i][0],elib[i][1]);
			k=elib[i][6];
			l=rlib[k][4];
			bg.draw(bmp[l],mat);
			i++;
		}
	}
	/* draw bonus */
	
	i=0;
	while (i<bonus.length) {
		if (bonus[i][12] == -1) {
			bonus.splice(i,1);
		} else {
			mat.identity();
			mat.translate(bonus[i][0],bonus[i][1]);
			if (bonus[i][9]==0) {
				bg.draw(b2,mat);
			} else if (bonus[i][9]==1) {
				bg.draw(b3,mat);
			} else if (bonus[i][9]==2) {
				bg.draw(b4,mat);
			}
			i++;
		}	
	}	
	/* draw player */
	if (p_i%2==0) {	
		mat.identity();
		if ((((kc>>2)|(kc>>3))&1)!=0){
			if ((kc&8)!=0){
				mat.translate(-12,0);
				mat.scale(-1,1);
				mat.translate(12,0);
			}
			mat.translate(p_x,p_y);
			bg.draw(p1,mat);
		}else{
			mat.translate(p_x,p_y);
			bg.draw(p0,mat);
		}
	}
	if (!no_bul) {
		i=0;
		while (i<blib.length) {
			if (blib[i][12]==-1) {
				blib.splice(i,1);
			} else {
				mat.identity();
				mat.rotate(blib[i][2]);
				mat.translate(blib[i][0],blib[i][1]);
				k=blib[i][6];
				l=rlib[k][4];
				bg.draw(bmp[l],mat);
				i++;
			}
		}
	}
	if ((kc&0x80)!=0) {
		bg.copyPixels(jp,jp.rect,$.createPoint(p_cx-4,p_cy-4));
	}
	/* draw bomb */
	if (game_state==3){	
		if(f_subc<20){
			a = 3.5*f_subc;
		} else if (f_subc>40) {
			a = 210-3.5*f_subc;
		} else {
			a = 70;
		}
		a = a*2.55;
		b_h_x -= 1.67;
		b_h_y += 0.83;
		b_v_x += 1.67;
		b_v_y += 0.83;
		/* draw f*/
		
		mat.identity();
		mat.rotate(-1.571);
		mat.translate(b_h_x,b_h_y);
		bg.draw(bmbf,mat,core.getColorTransform(1,1,1,0,0,0,0,75));
		
		mat.identity();
		mat.translate(b_v_x,b_v_y);
		bg.draw(bmbf,mat,core.getColorTransform(1,1,1,0,0,0,0,75));
		
		mat.identity();
		k = 110-2*f_subc;
		mat.translate(0,k);
		bg.draw(bb,mat,core.getColorTransform(1,1,1,0,0,0,0,a));
		
		
		if (f_subc < 36){
			bubble[0][7] += 10;
			bubble[1][7] += 7.071;
			bubble[1][8] += 7.071; 
			bubble[2][8] += 10;
			bubble[3][7] -= 7.071;
			bubble[3][8] += 7.071;
			bubble[4][7] -= 10;
			bubble[5][7] -= 7.071;
			bubble[5][8] -= 7.071;
			bubble[6][8] -= 10;
			bubble[7][7] += 7.071;
			bubble[7][8] -= 7.071;
			for(i=0;i<8;i++) {
				k=bubble[i][7];
				l=bubble[i][8];
				bg.copyPixels(bmbb,bmbb.rect,$.createPoint(k,l));
			}
		}
		
		bg.copyPixels(bmbz,bmbz.rect,$.createPoint(25,310));
		f_subc++;
	}

	bg.unlock();
	/* draw score,etc */
	board_bg.lock();
	board_bg.copyPixels(blank1,blank1.rect,LEFT_TOP);
	
	//trace(f_count);
	k=p_s;
	for(i=7;i>=0;i--) {
		board_bg.copyPixels(bs[k%10],bs[k%10].rect,pts[i]);
		if(k>1){ k=Math.floor(k/10); }else{ k=0; }
	}
	
	for(i=0;i<p_l;i++) board_bg.copyPixels(sb,sb.rect,pts[8+i]);
	for(i=0;i<p_b;i++) board_bg.copyPixels(sa,sa.rect,pts[16+i]);
	if (p_pw>127){
		board_bg.copyPixels(sm,sm.rect,pts[24]);
	} else {
		k=p_pw;
		for(i=2;i>=0;i--) {
			board_bg.copyPixels(bs[k%10],bs[k%10].rect,pts[24+i]);
			if(k>1){ k=Math.floor(k/10); }else{ k=0; }
		}
	}
	k=p_grc;	
	if (k>9999) k=9999;
	for(i=3;i>=0;i--) {
		board_bg.copyPixels(bs[k%10],bs[k%10].rect,pts[28+i]);
		if(k>1){ k=Math.floor(k/10); }else{ k=0; }
	}
	k=p_pt;
	for(i=2;i>=0;i--) {
		board_bg.copyPixels(bs[k%10],bs[k%10].rect,pts[32+i]);
		if(k>1){ k=Math.floor(k/10); }else{ k=0; }
	}
	k=p_ti;
	if (k > 8500) k = 8500;
	for(i=3;i>=0;i--) {
		board_bg.copyPixels(bs[k%10],bs[k%10].rect,pts[36+i]);
		if(k>1){ k=Math.floor(k/10); }else{ k=0; }
	}
	
	board_bg.unlock();
	switch (f_count) {
		case 1730:
			p_s+=20000;
			break;
		case 2640:
			p_s+=50000;
			generate_bonus(2,1,150,30);
			break;
		case 4680:
			p_s+=40000;
			break;
		case 5360:
			p_s+=60000;
			break;
		case 6130:
			p_s+=60000;
			break;
		case 6920:
			p_s+=80000;
			break;
		case 7590:
			p_s+=100000;
			break;
	}

	if (f_count == 1780) {
		l = (Player.time-7000)/50;
		if (l > 1910) {
			f_count = 1910;
			Player.seek(102500);
		} else {
			f_count = Math.floor(l);
			if (f_count == 1780) f_count++;
		}
	} else if (f_count == 3275) {
		l = (Player.time-7000)/50;
		if (l>3890) {
			f_count = 3890;
			Player.seek(201500);
		} else {
			f_count = Math.floor(l);
			if (f_count == 3275) f_count++;
		}
	} else {
		f_count++;
	}

}
canvas.addEventListener('enterFrame', main);


