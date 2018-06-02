//Modified from nekofs's code
class KeyboardHelper extends Object {
    private var _stage:Stage;
    private var _jwplayer:JWPlayer;
	////////////////////////////////////////////
	/*
	 * keyState
	 *  0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7
	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 * |1|1|1|1|1|1|1|1|1|/|/|/|/|/|/|/|
	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 *  | | | | | | | | |
	 * up | | | | | | | ctrl
	 * down | | | | | shift
	 *   left | z x q
	 *      right
	 * up->i,down->k,left->j,right->l
	*////////////////////////////////////////////
    private var _keyState:int
    public function KeyboardHelper(_root:*) {
        _keyState = 0;
        _stage = _root.stage;
        _jwplayer = _root.loaderInfo.content.document.playerContainer;
        _stage.addEventListener('keyDown', keyHandler);
        _stage.addEventListener('keyUp', keyHandler);
    }
    public static function getInstance(_root:*): KeyboardHelper {
        return new KeyboardHelper(_root);
    }
    public function get code():int{
    	return _keyState;
    }
    
    private function keyHandler(e:KeyboardEvent): void {
		if (e.keyCode >= 256) return;
		//if (_stage.displayState == 'normal' && _jwplayer.getFocus() != _jwplayer.playerHolder) return;
		if (e.type == 'keyDown') {
			switch (e.keyCode) {
				case 74:	//left
					_keyState = (_keyState & 0xfff7) | 0x04;
					break;
				case 73:	//up
					_keyState = (_keyState & 0xfffd) | 0x01;
					break;
				case 76:	//right
					_keyState = (_keyState & 0xfffb) | 0x08;
					break;
				case 75:	//down
					_keyState = (_keyState & 0xfffe) | 0x02;
					break;	
				case 88:	//x
					_keyState |= 0x0020;
					break;
				case 90:	//z
					_keyState |= 0x0010;
					break;
				case 81:
					_keyState |= 0x0040;
					break;
				case 16:	//shift
					_keyState |= 0x0080;
					break;
				case 17:	//ctrl
					_keyState |= 0x0100;
					break;
			}
		} else {
			switch (e.keyCode) {
				case 74:	//left
					_keyState &= 0xfffb;
					break;
				case 73:	//up
					_keyState &= 0xfffe;
					break;
				case 76:	//right
					_keyState &= 0xfff7;
					break;
				case 75:	//down
					_keyState &= 0xfffd;
					break;
				case 88:	//x
					_keyState &= 0xffdf;
					break;
				case 90:	//z
					_keyState &= 0xffef;
					break;
				case 81:
					_keyState &= 0xffbf;
					break;
				case 16:	//shift
					_keyState &= 0xff7f;
					break;
				case 17:	//ctrl
					_keyState &= 0xfeff;
					break;
			}
		}
	}
}
function setStageFramerate(_root:*, framerate:Number): void {
    _root.stage.frameRate = framerate;
}