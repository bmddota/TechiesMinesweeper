package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	
	
	public class GameBlock extends MovieClip {
		
		private var inClick:Boolean = false;
		private var tm:TechiesMinesweeper;
		public var xcoord:int;
		public var ycoord:int;
		public var bomb:Boolean = false;
		public var uncovered:Boolean = false;
		public var flagged:Boolean = false;
		public var num:Number = 0;
		
		public function GameBlock(tm:TechiesMinesweeper, xcoord:int, ycoord:int) {
			this.tm = tm;
			this.xcoord = xcoord;
			this.ycoord = ycoord;
			
			this.mine.visible = false;
			this.cover.visible = true;
			this.numText.visible = false;
			this.cross.visible = false;
			this.red.visible = false;
			this.flag.visible = false;
			this.question.visible = false;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseClick, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			this.addEventListener(MouseEvent.RIGHT_CLICK, rightClick, false, 0, true);
		}
		
		public function uncover(){
			uncovered = true;
			cover.visible = false;
			flag.visible = false;
			question.visible = false;
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseClick, false);
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver, false);
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut, false);
			this.removeEventListener(MouseEvent.RIGHT_CLICK, rightClick, false);
		}
		
		public function mouseDown(event:MouseEvent){
			if (!event.buttonDown){
				rightClick(event);
			}
			else if (!flag.visible){
				this.cover.visible = false;
				inClick = true;
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			}
		}
		
		public function mouseUp(event:MouseEvent){
			if (inClick && !uncovered){
				this.cover.visible = true;
			}
			inClick = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		public function mouseOver(event:MouseEvent){
			if (inClick && !uncovered)
				this.cover.visible = false;
		}
		
		public function mouseOut(event:MouseEvent){
			if (inClick && !uncovered)
				this.cover.visible = true;
		}
		
		public function mouseClick(event:MouseEvent){
			if (inClick && !flag.visible){
				trace('click');
				
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false);
				this.removeEventListener(MouseEvent.MOUSE_UP, mouseClick, false);
				this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver, false);
				this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut, false);
				this.removeEventListener(MouseEvent.RIGHT_CLICK, rightClick, false);
				
				tm.blockClicked(xcoord, ycoord);
			}
		}
		
		public function rightClick(event:MouseEvent){
			if (!flagged){
				flagged = true;
				
				flag.visible = true;
				this.removeEventListener(MouseEvent.MOUSE_UP, mouseClick, false);
				this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver, false);
				this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut, false);
				
				tm.flagSet(xcoord, ycoord);
				
				
				//this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false);
			}
			else if (question.visible){
				flagged = false;
				question.visible = false;
				//this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
				this.addEventListener(MouseEvent.MOUSE_UP, mouseClick, false, 0, true);
				this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
				this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			}
			else if (flag.visible){
				question.visible = true;
				flag.visible = false;
				
				tm.flagUnset(xcoord, ycoord);
			}
		}
	}
	
}
