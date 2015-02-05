package  {
	
	import flash.display.MovieClip;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.sampler.NewObjectSample;
	import flash.media.SoundChannel;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.text.TextField;
	import flash.display.IBitmapDrawable;
	
	public class TechiesMinesweeper extends Minigame {
		private static const _ZEROS:String = "0000000000000000000000000000000000000000"; // 40 zeros, shorten/expand as you wish
		private static const BEGINNER:int = 1;
		private static const INTERMEDIATE:int = 2;
		private static const EXPERT:int = 3;
		private static const CUSTOM:int = 4;
		
		private var boardParams:Object;
		private var leaderboard:String = "Beginner";
		private var gameMode:int = BEGINNER;
		
		private var startTime:Number = 0;
		private var score:Number = 100000;
		private var firstClick:Boolean = true;
		private var gameTimer:Timer;
		private var consumingInput:Boolean = false;
		
		private var gameData:Object;
									 
		private var soundStartup:String = "Tutorial.TaskCompleted";
		private var soundClick:String = "General.ButtonClick";
		private var soundRightClick:String = "General.ButtonClickRelease";
		private var soundBomb:String = "tutorial_bridge_fall"; //"Frostivus.PointScored.Enemy"; //"terrorblade_arcana.stinger.respawn";
		private var soundWon:String = "Game.HappyBirthday"; // "Frostivus.PointScored.Team";
		private var soundEnd:String = "crowd.lv_01";
		private var soundEndNewBest:String = "crowd.lv_04";
		
		private var numToColor:Object = {1:0x0000FF,
										 2:0x008200,
										 3:0xFF0000,
										 4:0x000084,
										 5:0x000084,
										 6:0x008284,
										 7:0x840084,
										 8:0x840084}
		
		public var blocks:Array;
		private var minesDisplay:int = 0;
		private var blanksToGo:int = 0;
		
		public function TechiesMinesweeper() {
			this.title = "#minigame_title";
			this.minigameID = "9fc46940730ff0f9463de5eddbddd39b";
		}
		
		public override function initialize() : void {
			precacheIcons();
			//stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			menuClip.widthText.maxChars = 2;
			menuClip.widthText.restrict = "0-9";
			menuClip.addEventListener(Event.CHANGE, widthChange);
			menuClip.heightText.maxChars = 2;
			menuClip.heightText.restrict = "0-9";
			menuClip.addEventListener(Event.CHANGE, heightChange);
			menuClip.minesText.maxChars = 4;
			menuClip.minesText.restrict = "0-9";
			menuClip.addEventListener(Event.CHANGE, minesChange);
			menuClip.beginnerButton.textField.text = minigameAPI.translate("#beginner");
			menuClip.beginnerButton.addEventListener(MouseEvent.CLICK, beginnerClick);
			menuClip.intermediateButton.textField.text = minigameAPI.translate("#intermediate");
			menuClip.intermediateButton.addEventListener(MouseEvent.CLICK, intermediateClick);
			menuClip.expertButton.textField.text = minigameAPI.translate("#expert");
			menuClip.expertButton.addEventListener(MouseEvent.CLICK, expertClick);
			menuClip.customButton.textField.text = minigameAPI.translate("#custom");
			menuClip.customButton.addEventListener(MouseEvent.CLICK, customClick);
			menuClip.bottomText.text = minigameAPI.translate("#instructions");
			
			retryClip.submitButton.textField.text = minigameAPI.translate("#submit");
			retryClip.retryButton.textField.text = minigameAPI.translate("#retry");
			retryClip.retryButton.addEventListener(MouseEvent.CLICK, retryClick);
			retryClip.mainmenuButton.textField.text = minigameAPI.translate("#main_menu");
			retryClip.mainmenuButton.addEventListener(MouseEvent.CLICK, mainmenuClick);
			retryClip.bestTimeLabel.text = minigameAPI.translate("#best_time");
			retryClip.clockTimeLabel.text = minigameAPI.translate("#clock_time");
			
			menuClip.visible = true;
			gameClip.visible = false;
			retryClip.visible = false;
			
			minigameAPI.resizeGameWindow();
			
			gameData = minigameAPI.getData();
			globals.GameInterface.PlaySound(soundStartup);
			
			gameClip.techiesFace.visible = false;
			gameClip.techiesFace.addEventListener(MouseEvent.CLICK, retryClick);
			gameClip.retryButton.textField.text = minigameAPI.translate("#retry");
			gameClip.retryButton.addEventListener(MouseEvent.CLICK, retryClick);
			gameClip.mainmenuButton.textField.text = minigameAPI.translate("#main_menu");
			gameClip.mainmenuButton.addEventListener(MouseEvent.CLICK, mainmenuClick);
			gameClip.resultsButton.textField.text = minigameAPI.translate("#results");
			gameClip.resultsButton.textField.textColor = "0x00A000";
			gameClip.resultsButton.visible = false;
			gameClip.resultsButton.addEventListener(MouseEvent.CLICK, resultsClick);
		}
		
		public function precacheIcons(){
			/*globals.PrecacheImage("images/spellicons/invoker_empty1.png");
			globals.PrecacheImage("images/spellicons/invoker_alacrity.png");
			globals.PrecacheImage("images/spellicons/invoker_cold_snap.png");
			globals.PrecacheImage("images/spellicons/invoker_ghost_walk.png");
			globals.PrecacheImage("images/spellicons/invoker_tornado.png");
			globals.PrecacheImage("images/spellicons/invoker_emp.png");
			globals.PrecacheImage("images/spellicons/invoker_alacrity.png");
			globals.PrecacheImage("images/spellicons/invoker_chaos_meteor.png");
			globals.PrecacheImage("images/spellicons/invoker_sun_strike.png");
			globals.PrecacheImage("images/spellicons/invoker_forge_spirit.png");
			globals.PrecacheImage("images/spellicons/invoker_ice_wall.png");
			globals.PrecacheImage("images/spellicons/invoker_deafening_blast.png");*/
		}
		
		public override function close() : Boolean{
			if (gameTimer != null)
				gameTimer.stop();
			return true;
		}
		
		public override function resize(stageWidth:int, stageHeight:int, scaleRatio:Number) : Boolean{
			return true;
		}
		
		private function widthChange(e:Event){
			if (menuClip.widthText.text == ""){
				menuClip.widthText.text = "3";
				return;
			}
				
			var w:uint = uint(menuClip.widthText.text);
			if (w < 3)
				menuClip.widthText.text = "3";
			else if (w > 70)
				menuClip.widthText.text = "70";
		}
		
		private function heightChange(e:Event){
			if (menuClip.heightText.text == ""){
				menuClip.heightText.text = "3";
				return;
			}
				
			var w:uint = uint(menuClip.heightText.text);
			if (w < 3)
				menuClip.heightText.text = "3";
			else if (w > 30)
				menuClip.heightText.text = "30";
		}
		
		private function minesChange(e:Event){
			if (menuClip.minesText.text == ""){
				menuClip.minesText.text = "3";
				return;
			}
			
			var w:uint = uint(menuClip.widthText.text);
			var h:uint = uint(menuClip.heightText.text);
			var m:uint = uint(menuClip.minesText.text);
			if (m < 3)
				menuClip.minesText.text = "3";
			else if (m > int(w * h * .4))
				menuClip.minesText.text = int(w * h * .4).toString();
		}
		
		private function beginnerClick(e:MouseEvent){
			trace('Beginner Clicked');
			
			gameMode = BEGINNER;
			leaderboard = "Beginner";
			boardParams = {w:9, h:9, mines:10};
			createBoard();
		}
		
		private function intermediateClick(e:MouseEvent){
			trace('Intermediate Clicked');
			
			gameMode = INTERMEDIATE;
			leaderboard = "Intermediate";
			boardParams = {w:16, h:16, mines:40};
			createBoard();
		}
		
		private function expertClick(e:MouseEvent){
			trace('Expert Clicked');
			
			gameMode = EXPERT;
			leaderboard = "Expert";
			boardParams = {w:30, h:16, mines:99};
			createBoard();
		}
		
		private function customClick(e:MouseEvent){
			trace('Custom Clicked');
			var w:uint = uint(menuClip.widthText.text);
			var h:uint = uint(menuClip.heightText.text);
			var mines:uint = uint(menuClip.minesText.text);
			
			gameMode = CUSTOM;
			leaderboard = null;
			boardParams = {w:w, h:h, mines:mines};
			createBoard();
		}
		
		private function retryClick(e:MouseEvent){
			trace('Retry Clicked');
			createBoard();
		}
		
		private function submitClick(e:MouseEvent){
			trace('Submit Clicked');
			this.minigameAPI.updateLeaderboard(leaderboard, score);
			retryClip.submitButton.textField.text = minigameAPI.translate("#submitted");
			retryClip.submitButton.enabled = false;
			retryClip.submitButton.removeEventListener(MouseEvent.CLICK, submitClick);
		}
		
		private function mainmenuClick(e:MouseEvent){
			trace('Mainmenu Clicked');
			
			menuClip.visible = true;
			retryClip.visible = false;
			gameClip.visible = false;
			
			clearBoard();
			
			minigameAPI.resizeGameWindow();
		}
		
		
		private function clearBoard(){
			var i:int
			var j:int;
			var gb:GameBlock;
			if (blocks != null){
				for (i=0; i<blocks.length; i++){
					for (j=0; j<blocks[i].length; j++){
						gb = blocks[i][j];
						gb.parent.removeChild(gb);
					}
				}
			}
			
			blocks = null;
		}
		
		private function createBoard(){
			var w:uint = boardParams.w;
			var h:uint = boardParams.h;
			var mines:uint = boardParams.mines;
			
			if (gameTimer != null)
				gameTimer.stop();
			
			menuClip.visible = false;
			retryClip.visible = false;
			gameClip.visible = true;
			gameClip.techiesFace.visible = false;
			gameClip.retryButton.visible = true;
			gameClip.mainmenuButton.visible = true;
			gameClip.resultsButton.visible = false;
			gameClip.clockTime.visible = true;
			firstClick = true;
			
			gameClip.clockTime.x = 61.5;
			gameClip.retryButton.x = 255.25;
			gameClip.mainmenuButton.x = 255.25;
			gameClip.resultsButton.x = 255.25;
			gameClip.techiesFace.x = 102.7
			
			minesDisplay = mines;
			gameClip.minesText.text = uint_Zeropadded(mines, 3);
			blanksToGo = w*h - mines;
			
			var i:int
			var j:int;
			var gb:GameBlock;
			clearBoard();
			
			blocks = new Array();
			for (i=0; i<h; i++){
				var row:Array = new Array();
				blocks[i] = row;
				for (j=0; j<w; j++){
					gb = new GameBlock(this, i, j);
					gb.x = j*20;
					gb.y = i*20;
					gameClip.board.addChild(gb);
					row[j] = gb;
				}
			}
			
			if (w*20 < 360){
				gameClip.board.x = 4.25 + (360 - (w * 20)) / 2
			}
			else{
				gameClip.board.x = 4.25;
				gameClip.clockTime.x += (w*20 - 360)/2;
				gameClip.techiesFace.x += (w*20 - 360)/2;
				gameClip.retryButton.x += w*20 - 360;
				gameClip.mainmenuButton.x += w*20 - 360; 
				gameClip.resultsButton.x += w*20 - 360;
			}
			
			gameClip.clockTime.text = "0.00";
			
			minigameAPI.resizeGameWindow(gameClip.board.x*2 + gameClip.board.width + gameClip.x, gameClip.board.y + gameClip.board.height + gameClip.y);
			
			
			var setBlank:Boolean = ((w * h) / 2) < mines;
			
			var cycles = mines;
			if (setBlank){
				cycles = w * h - mines;
				for (i=0; i<h; i++){
					for (j=0; j<w; j++){
						blocks[i][j].bomb = true;
					}
				}
			}
			
			// set up mines
			trace(setBlank);
			trace("MINES");
			for (i=0; i < cycles; i++){
				var ri:int = Math.floor(Math.random()*h);
				var rj:int = Math.floor(Math.random()*w);
				gb = blocks[ri][rj];
				while (gb.bomb != setBlank){
					ri = Math.floor(Math.random()*h);
					rj = Math.floor(Math.random()*w);
					gb = blocks[ri][rj];
				}
				
				gb.bomb = !setBlank;
			}
			
			trace("NUMBERS");
			// set up numbers
			for (i=0; i<h; i++){
				for (j=0; j<w; j++){
					//trace(i + " -- " + j);
					gb = blocks[i][j];
					if (gb.bomb){
						// NW
						if (i!=0 && j!=0 && !blocks[i-1][j-1].bomb)
							blocks[i-1][j-1].num++;
						// W
						if (j!=0 && !blocks[i][j-1].bomb)
							blocks[i][j-1].num++;
						// SW
						if (i!=h-1 && j!=0 && !blocks[i+1][j-1].bomb)
							blocks[i+1][j-1].num++;
						// S
						if (i!=h-1 && !blocks[i+1][j].bomb)
							blocks[i+1][j].num++;
						// SE
						if (i!=h-1 && j!=w-1 && !blocks[i+1][j+1].bomb)
							blocks[i+1][j+1].num++;
						// E
						if (j!=w-1 && !blocks[i][j+1].bomb)
							blocks[i][j+1].num++;
						// NE
						if (i!=0 && j!=w-1 && !blocks[i-1][j+1].bomb)
							blocks[i-1][j+1].num++;
						// N
						if (i!=0 && !blocks[i-1][j].bomb)
							blocks[i-1][j].num++;
					}
				}
			}
		}
		
		private function revealAll(){
			for (var i:int=0; i<blocks.length; i++){
				for (var j:int=0; j<blocks[0].length; j++){
					var gb:GameBlock = blocks[i][j];
					if (!gb.uncovered){
						var flag:Boolean = gb.flag.visible;
						gb.uncover();
						
						if (gb.bomb){
							gb.mine.visible = true;
							if (flag){
								gb.cover.visible = true;
								gb.flag.visible = true;
							}
						}
						else if (flag){
							gb.cross.visible = true;
							trace("bad flag");
						}
						if (gb.num != 0){
							gb.numText.visible = true;
							gb.numText.text = gb.num.toString();
							gb.numText.textColor = numToColor[gb.num];
						}
						
					}
				}
			}
		}
		
		private function gameWon(){
			for (var i:int=0; i<blocks.length; i++){
				for (var j:int=0; j<blocks[0].length; j++){
					var gb:GameBlock = blocks[i][j];
					if (!gb.uncovered){
						gb.uncover();
						
						if (gb.bomb){
							gb.cover.visible = true;
							gb.flag.visible = true;
						}
					}
				}
			}
			
			minesDisplay = 0;
			updateMinesDisplay();
			
			globals.GameInterface.PlaySound(soundWon);
			
			gameClip.resultsButton.visible = true;
			gameClip.retryButton.visible = false;
			gameClip.mainmenuButton.visible = false;
			if (gameTimer != null)
				gameTimer.stop();
			score = Math.floor((new Date().time - startTime) / 10);
		}
		
		private function timeUpdate(e:TimerEvent){
			
			score = Math.floor((new Date().time - startTime) / 10)
			var sec:String = String(Math.floor(score / 100));
			var ms:String = uint_Zeropadded(score % 100, 2);
			
			
			gameClip.clockTime.text = sec + "." + ms;
			
			if (score > 10 * 12000) {
				lostGame();
				gameTimer.stop();
			}
		}
		
		private function resultsClick(){
			clearBoard();
			var sec:String = String(Math.floor(score / 100));
			var ms:String = uint_Zeropadded(score % 100, 2);
			
			retryClip.clockTime.text = sec + "." + ms;
			retryClip.bestTime.visible = true;
			retryClip.submitButton.visible = true;
			retryClip.bestTimeLabel.visible = true;
			trace("END GAME");
			trace(score);
			
			if (leaderboard != null){
				var best:Number = gameData[leaderboard];
				trace(best);
				if (score < best){
					best = score;
					gameData[leaderboard] = best;
					minigameAPI.saveData();
					trace("SAVED");
					globals.GameInterface.PlaySound(soundEndNewBest);
				}
				else{
					globals.GameInterface.PlaySound(soundEnd);
				}
				var sec2:String = String(Math.floor(best / 100));
				var ms2:String = uint_Zeropadded(best % 100, 2);
				
				retryClip.bestTime.text = sec2 + "." + ms2;
			}
			else{
				globals.GameInterface.PlaySound(soundEnd);
				retryClip.bestTime.visible = false;
				retryClip.bestTimeLabel.visible = false;
				retryClip.submitButton.visible = false;
			}
			
			retryClip.submitButton.textField.text = minigameAPI.translate("#submit");
			retryClip.submitButton.addEventListener(MouseEvent.CLICK, submitClick);
			
			menuClip.visible = false;
			gameClip.visible = false;
			retryClip.visible = true;
			
			minigameAPI.resizeGameWindow();
		}
		
		private function uncoverBlock(gb:GameBlock){
			if (!gb.uncovered){
				if (gb.flag.visible)
					flagUnset(gb.xcoord, gb.ycoord);
				
				blanksToGo--;
				gb.uncover();

				if (gb.num == 0){
					var i:int = gb.xcoord;
					var j:int = gb.ycoord;
					var h:int = blocks.length;
					var w:int = blocks[0].length;
					// NW
					if (i!=0 && j!=0)
						uncoverBlock(blocks[i-1][j-1]);
					// W
					if (j!=0)
						uncoverBlock(blocks[i][j-1]);
					// SW
					if (i!=h-1 && j!=0)
						uncoverBlock(blocks[i+1][j-1]);
					// S
					if (i!=h-1)
						uncoverBlock(blocks[i+1][j]);
					// SE
					if (i!=h-1 && j!=w-1)
						uncoverBlock(blocks[i+1][j+1]);
					// E
					if (j!=w-1)
						uncoverBlock(blocks[i][j+1]);
					// NE
					if (i!=0 && j!=w-1)
						uncoverBlock(blocks[i-1][j+1]);
					// N
					if (i!=0)
						uncoverBlock(blocks[i-1][j]);
				}
				else{
					gb.numText.visible = true;
					gb.numText.text = gb.num.toString();
					gb.numText.textColor = numToColor[gb.num];
				}
			}
		}
		
		public function blockClicked(xcoord:int, ycoord:int){
			trace("block clicked");
			trace(xcoord + " -- " + ycoord);
			
			var gb:GameBlock = blocks[xcoord][ycoord];
			if (gb.bomb){
				// clicked a bomb
				gb.uncovered = true;
				gb.cover.visible = false;
				gb.question.visible = false;
				gb.flag.visible = false;
				gb.red.visible = true;
				gb.mine.visible = true;
				lostGame();
				return;
			}
			
			if (firstClick){
				firstClick = false;
				startTime = Number(new Date());
				score = 0;
				
				gameTimer = new Timer(5,0);
				gameTimer.addEventListener(TimerEvent.TIMER, timeUpdate);
				gameTimer.start();
			}
			
			globals.GameInterface.PlaySound(soundClick);
			uncoverBlock(gb);
			
			if (blanksToGo <= 0){
				// victory
				gameWon();
			}
		}
		
		private function updateMinesDisplay(){
			if (minesDisplay < -99){
				gameClip.minesText.text = "-99";
			}
			else if (minesDisplay < 0){
				gameClip.minesText.text = "-" + uint_Zeropadded(minesDisplay * -1, 2);
			}
			else{
				gameClip.minesText.text = uint_Zeropadded(minesDisplay, 3);
			}
		}
		
		public function flagSet(xcoord:int, ycoord:int){
			trace("flag Set");
			trace(xcoord + " -- " + ycoord);
			
			globals.GameInterface.PlaySound(soundRightClick);
			minesDisplay--;
			updateMinesDisplay();
		}
		
		public function questionUnset(xcoord:int, ycoord:int){
			globals.GameInterface.PlaySound(soundRightClick);
		}
		
		public function flagUnset(xcoord:int, ycoord:int){
			trace("flag Unset");
			trace(xcoord + " -- " + ycoord);
			
			globals.GameInterface.PlaySound(soundRightClick);
			minesDisplay++;
			updateMinesDisplay();
		}
		
		private function lostGame(){
			if (gameTimer != null)
				gameTimer.stop();
				
			globals.GameInterface.PlaySound(soundBomb);
			gameClip.techiesFace.visible = true;
			gameClip.clockTime.visible = false;
			revealAll();
		}
		
		/*
         * f: positive integer value
         * z: maximum number of leading zeros of the numeric part (sign takes one extra digit)
         */
        public static function uint_Zeropadded(f:uint, z:int = 0):String {
            var result:String = f.toString();
            while (result.length < z)
                result = _ZEROS.substr(0, z - result.length) + result;
            return result;
        }
	}
	
}
