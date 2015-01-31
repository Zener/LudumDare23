/*
* El petit Messi
* A Game developed in 48h for Ludum Dare #23
* @author Carlos Peris
* 22/04/2012
*/


package
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	
	[SWF(width=900, height=700, backgroundColor='0x200040', frameRate='30', allowScriptAccess='always', allowfullscreen='true')]
	public class ElPetitMessiWeb extends Sprite
	{
		private static const PLANET_RADIUS:int = 180;
		private static const PLANET_ATMOSPHERE_RADIUS:int = 340;
		private static const SUN_RADIUS:int = 40;
		private static const SUN_DISTANCE:int = 400;
		private static const PLAYER_HEIGHT:int = 32;
		private static const ITEM_WIDTH:int = 16;
		private static const GRAVITY:Number = 0.98*0.3;
		private static const EPSILON:Number = 0.02;
		
		private var mDate:Date = new Date();
		private var mGameTime:Number;
		private var mGameTimer:int = 0;
		private var mCoinsLeft:int = 0;
		
		private static const MAP_ROWS:int = 5;
		private static const MAP_COLUMNS:int = 50;
		private var mMap:Array;
		
		
		private var mSunAngle:Number;
		private var mLastSunAngle:Number;
		private var mSunSprite:Sprite;
		private var mPlanetSprite:Sprite;
		private var mPlayerSprite:Sprite;
		private var mBallSprite:Sprite;
		
		private var mPlayerX:Number;
		private var mPlayerY:Number;
		private var mPlayerDX:int;
		private var mPlayerDY:int;
		private var mPlayerSX:Number;
		private var mPlayerSY:Number;
		private var mPlayerFire:int;
		private var mPlayerAngle:Number;
		private var mPlayerHeight:Number;
		
		private var mBallAngle:Number;
		private var mBallHeight:Number;
		private var mBallSX:Number;
		private var mBallSY:Number;
		
		private var mCoinsLeftTextfield:TextField;
		private var mTimeTextfield:TextField;
		private var mStageClearTextfield:TextField = new TextField();
		private var mTutorialTextfield:TextField = new TextField();
		
		[Embed(source="../assets/messi01.png")]
		private static const gfxPlayer0:Class;
		[Embed(source="../assets/messi02.png")]
		private static const gfxPlayer1:Class;
		[Embed(source="../assets/messi03.png")]
		private static const gfxPlayer2:Class;
		[Embed(source="../assets/messi02.png")]
		private static const gfxPlayer3:Class;
		[Embed(source="../assets/messi04.png")]
		private static const gfxPlayer4:Class;
		
		[Embed(source="../assets/star.png")]
		private static const gfxStar:Class;
		
		[Embed(source="../assets/item.png")]
		private static const gfxItem:Class;
		
		[Embed(source="../assets/ball.png")]
		private static const gfxBall:Class;
		
		[Embed(source="../assets/pepe.png")]
		private static const gfxEnemy:Class;
		
		private var mTimePerStage:Array = [60, 100, 100];
		private var mCoinsToCollect:Array = [0.5, 0.6, 0.7];
		private var mStage:int = 0;
		private var mEllapsedTime:int = 0;
		private var mTimeLeft:int = 0;
		
		private static const STATE_LOAD_STAGE:int = 0;
		private static const STATE_COUNTDOWN:int = 1;
		private static const STATE_PLAY:int = 2;
		private static const STATE_GAMEOVER:int = 3;
		private static const STATE_STAGE_COMPLETED:int = 4;
		private var mState:int = STATE_LOAD_STAGE;
		
		
		private var mAnimTimer:int = 0;
		private var mAnimFrame:int = 0;
		
		//Enemies
		private var mEnemies:Array = new Array();
		private var mMaxEnemySpeed:Number;
		private var mMaxEnemySpeedY:Number;
		
		
		
		public function ElPetitMessiWeb()
		{
			init();
		}
		
		
		public function fillPlanet(ori:Sprite):void
		{
			var mat:Matrix;
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			mat= new Matrix();
			colors=[0x8080ff,0xffffff];
			alphas=[0,0.1];
			ratios=[226, 255];
			mat.createGradientBox(2*PLANET_ATMOSPHERE_RADIUS,2*PLANET_ATMOSPHERE_RADIUS,0,-PLANET_ATMOSPHERE_RADIUS*1,-PLANET_ATMOSPHERE_RADIUS*1);
			var s:Sprite = new Sprite();
			s.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, mat);       
			s.graphics.drawCircle(0,0, PLANET_ATMOSPHERE_RADIUS);
			s.graphics.endFill();
			ori.addChild(s);
		}
		
		
		public function refillPlanet(s:Sprite, angle:Number):void
		{
			var mat:Matrix;
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			mat= new Matrix();
			//colors=[0xFF00FF, 0x4000ff];
			colors=[0x80ff00,0x008f00];
			alphas=[1, 1];
			ratios=[0, 255];
			mat.createGradientBox(2*PLANET_RADIUS,2*PLANET_RADIUS,0,-PLANET_RADIUS+(PLANET_RADIUS*0.5*Math.cos(angle)),-PLANET_RADIUS+(PLANET_RADIUS*0.5*Math.sin(angle)));
			s.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, mat);       
			s.graphics.drawCircle(0,0, PLANET_RADIUS);
			s.graphics.endFill();
		}
		
		
		
		public function fillSun(s:Sprite):void
		{
			var mat:Matrix;
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			mat= new Matrix();
			colors=[0xFFFF80, 0xff8f40];
			alphas=[1,0.75];
			ratios=[0, 255];
			mat.createGradientBox(2*SUN_RADIUS,2*SUN_RADIUS,0,-SUN_RADIUS,-SUN_RADIUS);
			s.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, mat);       
			s.graphics.drawCircle(0,0, SUN_RADIUS);
			s.graphics.endFill();
			
			var aura:Sprite = new Sprite();
			colors=[0xFFFF00, 0xff8f00];
			alphas=[0.5,0.025];
			ratios=[0, 255];
			mat.createGradientBox(20*SUN_RADIUS,20*SUN_RADIUS,0,-SUN_RADIUS*10,-SUN_RADIUS*10);
			aura.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, mat);       
			aura.graphics.drawCircle(0,0, SUN_RADIUS*10);
			aura.graphics.endFill();
			s.addChild(aura);
		}
		
		
		public function initStage():void
		{
			var i:int;
			var s:Sprite;
			
			// Remove items
			for(i = 0; i < MAP_ROWS*MAP_COLUMNS; i++)
			{
				if (mMap[i].value >= 1)
				{
					mMap[i].value = 0;
					mPlanetSprite.removeChild(mMap[i].sprite);
				}				
			}
			for(i = 0; i < mEnemies.length; i++)
			{
				var isAlive:Boolean = mEnemies[i].isAlive;
				if (isAlive)
				{
					mPlanetSprite.removeChild(mEnemies[i].sprite);
				}
			}
			
			
			mPlayerSX = 0;
			mPlayerSY = 0;
			mPlayerAngle = 0;
			mPlayerHeight = 0;
			mBallAngle = 0;
			mBallHeight = 0;
			mBallSX = 0;
			mBallSY = 0;
			
			// Add items
			for(i = 0; i < MAP_ROWS*MAP_COLUMNS; i++)
			{
				var tile:Object = mMap[i];
				s = new Sprite();
				var itemBitmap:Bitmap = new gfxItem as Bitmap;
				itemBitmap.x = -itemBitmap.width / 2;
				itemBitmap.y = -itemBitmap.height / 2;
				s.addChild(itemBitmap);
				tile.value = 0;
				tile.sprite = s;
				switch(mStage % 4)
				{
					case 0:
						if ((i%MAP_COLUMNS) % 6 != 0)
						{
							tile.value = 1;
						}
						break;
					case 1:
						if (i% 6 != 0)
						{
							tile.value = 1;
						}
						break;
					case 2:
						if ((i%MAP_COLUMNS) % 16 != 0)
						{
							tile.value = 1;
						}
						break;
					case 3:
						if (i% 5 != 0)
						{
							tile.value = 1;
						}
						break;
				}
				
				
				if (tile.value == 1)
				{
					var r:Number = Math.random(); 
					if (mStage > 10 && r > 0.95)
					{
						tile.value = 2;
					}
					if (tile.value == 2)
					{
						s.scaleX = 1.5;
						s.scaleY = 1.5;
					}
					else
					{
						s.scaleX = 1;
						s.scaleY = 1;
					}
					mPlanetSprite.addChild(tile.sprite);
				}
			}
			// Set item pos
			mCoinsLeft = 0;
			for(i = 0; i < MAP_ROWS*MAP_COLUMNS; i++)
			{
				if (mMap[i].value >= 1)
				{
					var x:int = (i % MAP_COLUMNS);
					var y:int = (i / MAP_COLUMNS) + 1;
					s = mMap[i].sprite;
					var xAngle:Number = (Math.PI * 2 * x) / MAP_COLUMNS;
					s.x = Math.cos(mPlayerAngle+xAngle)*(PLANET_RADIUS + (y*24));
					s.y = Math.sin(mPlayerAngle+xAngle)*(PLANET_RADIUS + (y*24));
					
					mCoinsLeft++;
				}
			}
			var mCoinFactor:Number = mCoinsToCollect[0];
			mCoinFactor += 0.02 * (mStage+1);
			if (mCoinFactor > 1)
			{
				mCoinFactor = 1;
			}
			mCoinsLeft = Math.floor((mCoinsLeft*mCoinFactor) );			
			mTimeLeft = ((mTimePerStage[0]-mStage) * 1000);
			if (mStage == 0) mTimeLeft*2;
			
			//Init Enemies
			mEnemies = new Array();
			
			var numEnemies:int = (mStage + 1) / 2;
			for(i=0; i < numEnemies; i++)
			{
				var enemy:Object = new Object();
				
				var enemyBitmap:Bitmap = new gfxEnemy as Bitmap;
				enemyBitmap.x = -enemyBitmap.width/2;
				enemyBitmap.y = -enemyBitmap.height/2;
				var enemySprite:Sprite = new Sprite();
				enemySprite.addChild(enemyBitmap);
				mPlanetSprite.addChild(enemySprite);
				
				enemy.sprite = enemySprite;
				enemy.height = 32*6;
				enemy.sx = 0.0;
				enemy.sy = 0.0;
				enemy.angle = Math.random()*Math.PI*2;
				enemy.isAlive = true;
				mEnemies.push(enemy);
			}
			mMaxEnemySpeed = 0.01;
			mMaxEnemySpeedY = 1.4;
		}
		
		
		public function init():void
		{
			var s:Sprite;
			var i:int;
			
		
			for(i = 0; i < 64;i++)
			{
				var starBitmap:Bitmap = new gfxStar as Bitmap;
				starBitmap.x = Math.random()*stage.stageWidth - starBitmap.width/2;
				starBitmap.y = Math.random()*stage.stageHeight - starBitmap.height/2;
				starBitmap.rotation = Math.random()*360;
				starBitmap.scaleX = 0.05 + Math.random()*0.4;
				starBitmap.scaleY = starBitmap.scaleX;
				starBitmap.alpha = Math.random()*0.4;
				this.addChild(starBitmap);				
			}
			
			mSunAngle = Math.PI;
			mLastSunAngle = Math.PI;
			mSunSprite = new Sprite();
			fillSun(mSunSprite);
			
			
			mPlanetSprite = new Sprite();
			refillPlanet(mPlanetSprite, mSunAngle);
			fillPlanet(mPlanetSprite);
			mPlanetSprite.x = stage.stageWidth/2;
			mPlanetSprite.y = stage.stageHeight*2/3;
			this.addChild(mPlanetSprite);
			mPlanetSprite.addChild(mSunSprite);
			
			
			mPlayerSprite = new Sprite();
			
			var playerBitmap:Bitmap = new gfxPlayer0 as Bitmap;
			playerBitmap.x = -playerBitmap.width/2;
			playerBitmap.y = -playerBitmap.height/2;
			mPlayerSprite.addChild(playerBitmap);
			
			playerBitmap = new gfxPlayer1 as Bitmap;
			playerBitmap.x = -playerBitmap.width/2;
			playerBitmap.y = -playerBitmap.height/2;
			playerBitmap.visible = false;
			mPlayerSprite.addChild(playerBitmap);
			
			playerBitmap = new gfxPlayer2 as Bitmap;
			playerBitmap.x = -playerBitmap.width/2;
			playerBitmap.y = -playerBitmap.height/2;
			playerBitmap.visible = false;
			mPlayerSprite.addChild(playerBitmap);
			
			playerBitmap = new gfxPlayer3 as Bitmap;
			playerBitmap.x = -playerBitmap.width/2;
			playerBitmap.y = -playerBitmap.height/2;
			playerBitmap.visible = false;
			mPlayerSprite.addChild(playerBitmap);
			
			playerBitmap = new gfxPlayer4 as Bitmap;
			playerBitmap.x = -playerBitmap.width/2;
			playerBitmap.y = -playerBitmap.height/2;
			playerBitmap.visible = false;
			mPlayerSprite.addChild(playerBitmap);
			
			
			mPlayerSX = 0;
			mPlayerSY = 0;
			mPlayerAngle = 0;
			mPlayerHeight = 0;
			mBallAngle = 0;
			mBallHeight = 0;
			mBallSX = 0;
			mBallSY = 0;
			
			
			mMap = new Array();
			for(i = 0; i < MAP_ROWS*MAP_COLUMNS; i++)
			{
				/*s = new Sprite();
				var itemBitmap:Bitmap = new gfxItem as Bitmap;
				itemBitmap.x = -itemBitmap.width / 2;
				itemBitmap.y = -itemBitmap.height / 2;
				s.addChild(itemBitmap);*/
				
				var tile:Object = new Object();
				tile.value = 0;
				tile.sprite = null;
				/*tile.value = 1;
				tile.sprite = s;*/
				
				mMap.push(tile);
				//mPlanetSprite.addChild(tile.sprite);
				
			}
			
			
			
			mPlanetSprite.addChild(mPlayerSprite);
			
			var ballBitmap:Bitmap = new gfxBall as Bitmap;
			ballBitmap.x = -ballBitmap.width/2;
			ballBitmap.y = -ballBitmap.height/2;
			mBallSprite = new Sprite();
			mBallSprite.addChild(ballBitmap);
			mPlanetSprite.addChild(mBallSprite);
			
			
			//HUD
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 18;
			
			mTimeTextfield = new TextField();
			mTimeTextfield.defaultTextFormat = myFormat;
			mTimeTextfield.width = 150;
			mTimeTextfield.x = 6;
			mTimeTextfield.y = 6;
			mTimeTextfield.textColor = 0xffffff;
			this.addChild(mTimeTextfield);
			mCoinsLeftTextfield = new TextField();
			mCoinsLeftTextfield.width = 150;
			mCoinsLeftTextfield.defaultTextFormat = myFormat;
			mCoinsLeftTextfield.x = 6;
			mCoinsLeftTextfield.y = 26;
			mCoinsLeftTextfield.textColor = 0xffffff;
			
			this.addChild(mCoinsLeftTextfield);
			
			myFormat.align = TextFormatAlign.CENTER;			
			mTutorialTextfield.defaultTextFormat = myFormat;				
			mTutorialTextfield.x = (stage.stageWidth/2)-100;
			mTutorialTextfield.width = 220;
			mTutorialTextfield.height = 90;
			mTutorialTextfield.y = 86;
			mTutorialTextfield.textColor = 0xffffff;			
			mTutorialTextfield.wordWrap = true;
			
			
			myFormat = new TextFormat();
			myFormat.size = 44;
			myFormat.align = TextFormatAlign.CENTER;					
			
			mCountdownTimerTextfield.defaultTextFormat = myFormat;				
			mCountdownTimerTextfield.x = stage.stageWidth/2;
			mCountdownTimerTextfield.y = stage.stageHeight/2;
			mCountdownTimerTextfield.textColor = 0xffffff;
			
			mStageTextfield.defaultTextFormat = myFormat;				
			mStageTextfield.x = (stage.stageWidth/2)-100;
			mStageTextfield.y = 32;
			mStageTextfield.width = 200;
			mStageTextfield.textColor = 0xffffff;
			
			mGameOverTextfield.defaultTextFormat = myFormat;				
			mGameOverTextfield.x = (stage.stageWidth/2)-100;
			mGameOverTextfield.width = 220;
			mGameOverTextfield.y = 32;
			mGameOverTextfield.textColor = 0xffffff;
			mGameOverTextfield.text = "Game Over"
			
			mStageClearTextfield.defaultTextFormat = myFormat;				
			mStageClearTextfield.x = (stage.stageWidth/2)-100;
			mStageClearTextfield.width = 220;
			mStageClearTextfield.y = 32;
			mStageClearTextfield.textColor = 0xffffff;
			mStageClearTextfield.text = "Stage Clear!";
				
				
			mGameTime = currentTimeMillis();
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);						
		}
		
		
		private var mCountdownTimer:int;
		private var mCountdownTimerTextfield:TextField = new TextField();
		private var mStageTextfield:TextField = new TextField();
		private var mGameOverTextfield:TextField = new TextField();
		
		public function onEnterFrame(e:Event):void
		{
			var timeMillis:Number = currentTimeMillis();
			var dt:int = timeMillis - mGameTime;
			mGameTime = timeMillis;
			
			
			switch(mState)
			{
				case STATE_LOAD_STAGE:
					initStage();
					mState = STATE_COUNTDOWN;
					mCountdownTimer = 4*1000;
					logicUpdate(0);
					
					stage.addChild(mCountdownTimerTextfield);
					
					
					mStageTextfield.text = "Stage "+(mStage+1);
					stage.addChild(mStageTextfield);
					if (mStage == 0)
					{
						mTutorialTextfield.text = "Use cursor keys to move and space to kick the ball.     (Click window first)";
						stage.addChild(mTutorialTextfield);						
					}
					if (mStage == 1)
					{
						mTutorialTextfield.text = "Collect all the coins before time runs out.";
						stage.addChild(mTutorialTextfield);
					}
					if (mStage == 2)
					{
						mTutorialTextfield.text = "Beware of the enemies. Kill them with the ball.";
						stage.addChild(mTutorialTextfield);
					}
					break;
				case STATE_COUNTDOWN:
					mCountdownTimer -= dt;
					if (mCountdownTimer < 1000)
					{
						mCountdownTimerTextfield.text = "GO!";
					}
					else
					{
						mCountdownTimerTextfield.x = (stage.stageWidth/2) - 44;
						mCountdownTimerTextfield.text = ""+(int)(mCountdownTimer/1000);
					}
					if (mCountdownTimer < 0)
					{
						mState = STATE_PLAY;
						stage.removeChild(mCountdownTimerTextfield);
						stage.removeChild(mStageTextfield);
					}
					break;
				case STATE_PLAY:
					mGameTimer += dt;
					while (mGameTimer >= 33)
					{
						logicUpdate(33);
						mGameTimer -= 33;
					}
					
					if (mTimeLeft < 0)
					{
						mState = STATE_GAMEOVER;
						stage.addChild(mGameOverTextfield);
						if (mStage < 3)
						{
							stage.removeChild(mTutorialTextfield);
						}
						mCountdownTimer = 5*1000;
					}
					if (mCoinsLeft <= 0)
					{
						mState = STATE_STAGE_COMPLETED;
						stage.addChild(mStageClearTextfield);
						if (mStage < 3)
						{
							stage.removeChild(mTutorialTextfield);
						}
						mCountdownTimer = 4*1000;
					}
					break;
				case STATE_GAMEOVER:
					mCountdownTimer -= dt;
					if (mCountdownTimer < 0)
					{
						mState = STATE_LOAD_STAGE;
						stage.removeChild(mGameOverTextfield);
					}
					break;
				case STATE_STAGE_COMPLETED:
					mCountdownTimer -= dt;
					if (mCountdownTimer < 0)
					{
						mStage++;
						mState = STATE_LOAD_STAGE;
						stage.removeChild(mStageClearTextfield);
					}
					break;
					
			}
		}
		
		
	
		
		public function logicUpdate(dt:int):void
		{
			mEllapsedTime += dt;
			mTimeLeft -= dt;
			mSunAngle += 0.005;
			var centerX:int = stage.stageWidth/2;
			var centerY:int = stage.stageHeight/2;
			
			mSunSprite.x = Math.cos(mSunAngle)*SUN_DISTANCE;
			mSunSprite.y = Math.sin(mSunAngle)*SUN_DISTANCE;
			
			if (Math.abs(mLastSunAngle-mSunAngle) > 0.05)
			{
				refillPlanet(mPlanetSprite, mSunAngle);
				mLastSunAngle = mSunAngle;
			}
			
			
			
			//Player Update
			if (mPlayerDX != 0)
			{
				mPlayerSX = mPlayerDX*0.02;
			}
			else
			{
				mPlayerSX = mPlayerSX*0.8;
			}
			if (mPlayerHeight == 0 && mPlayerDY == 1)
			{
				mPlayerSY = 8;
			}
			
			if (mPlayerHeight > EPSILON)
			{
				mPlayerSY -= GRAVITY*2;
			}
			
			
			mPlayerAngle += mPlayerSX;
			mPlayerHeight += mPlayerSY;
			if (mPlayerHeight < 0)
			{
				mPlayerHeight = 0;
			}
			//Kick
			if (mPlayerFire)
			{
				if (Math.abs(mPlayerSprite.x - mBallSprite.x) < 24)
				{
					if (Math.abs(mPlayerSprite.y+PLAYER_HEIGHT/2 - mBallSprite.y) < 32)
					{
						mBallSY += 8;
						mBallSX += mPlayerSX*4;
						mPlayerFire = 0;
					}
				}
			}
			//Head shot
			if (mBallSY < 0)
			{
				if (Math.abs(mPlayerAngle - mBallAngle) < Math.PI/48)
				{
					if (Math.abs(mPlayerHeight+25 - mBallHeight) < 4)
					{
						mBallSY = Math.abs(mBallSY)*0.95;
						if (mPlayerSY > 0) mBallSY += mPlayerSY*0.25;
						mBallHeight = mPlayerHeight+25;
						mBallSX += mPlayerSX*0.25;
					}
				}
			}
			
			//Ball update
			if (mBallHeight > EPSILON)
			{
				mBallSY -= GRAVITY;
			}
			mBallAngle += mBallSX;
			mBallHeight += mBallSY;
			if (mBallHeight < EPSILON)
			{				
				mBallSY = -mBallSY*0.7;
				if (Math.abs(mBallSY) < EPSILON)
				{
					mBallSY = 0;
				}
				mBallHeight = 0;
			}
			if (mBallSX != 0)
			{
				mBallSX = mBallSX*0.99;				
			}
			
			
			
			
			mPlayerSprite.x = Math.cos(mPlayerAngle-Math.PI/2)*(PLANET_RADIUS + mPlayerHeight + PLAYER_HEIGHT/2);
			mPlayerSprite.y = Math.sin(mPlayerAngle-Math.PI/2)*(PLANET_RADIUS + mPlayerHeight + PLAYER_HEIGHT/2);
			mPlayerSprite.rotation = mPlayerAngle*180/Math.PI;
			
			mPlanetSprite.rotation = -mPlayerAngle*180/Math.PI;
			
			mBallSprite.x = Math.cos(mBallAngle-Math.PI/2)*(PLANET_RADIUS + mBallHeight + mBallSprite.width/2);
			mBallSprite.y = Math.sin(mBallAngle-Math.PI/2)*(PLANET_RADIUS + mBallHeight + mBallSprite.height/2);
			mBallSprite.rotation += (mBallSX)*720;
			
			/*mBallAngle += 0.02;
			mBallHeight = PLAYER_HEIGHT;
			mBallSY = 0;*/
			for(var i:int = 0; i < MAP_ROWS*MAP_COLUMNS; i++)
			{
				if (mMap[i].value >= 1)
				{
				
					var s:Sprite = mMap[i].sprite;
					//var x:int = (i % MAP_COLUMNS);
					//var xAngle:Number = (Math.PI * 2 * x) / MAP_COLUMNS;
					//s.scaleX = Math.cos((mEllapsedTime/1000) + xAngle);//*Math.cos(xAngle);
					//s.scaleY = Math.cos(mEllapsedTime/1000)*Math.sin(  xAngle);
					if (Math.abs(mPlayerSprite.x - s.x) < 16)
					{
						if (Math.abs(mPlayerSprite.y - s.y) < 8)
						{
							mPlanetSprite.removeChild(s);
							if (mMap[i].value == 2)
							{
								mCoinsLeft -= 5;	
							}
							else
							{
								mCoinsLeft--;	
							}
							mMap[i].value = 0;
							
						}
					}
					if (mMap[i].value >= 1)
					{
						if (Math.abs(mBallSprite.x - s.x) < 16)
						{
							if (Math.abs(mBallSprite.y - s.y) < 8)
							{
								mPlanetSprite.removeChild(s);
								
								if (mMap[i].value == 2)
								{
									mCoinsLeft -= 5;	
								}
								else
								{
									mCoinsLeft--;	
								}
								mMap[i].value = 0;
							}
						}
					}
				}
			}
			if (mCoinsLeft < 0)
			{
				mCoinsLeft = 0;
			}
			
			// Enemies
			updateEnemies();
			
			
			// Animation
			if (mAnimTimer < 0)
			{
				
				for (i = 0; i < 4; i++)
				{
					mPlayerSprite.getChildAt(i).visible = false;
				}	
				mPlayerSprite.getChildAt(4).visible = true;
				mAnimTimer += dt;
				if (mAnimTimer >= 0)
				{
					mAnimTimer = 300;
				}
			}
			else
			{
				mAnimTimer += Math.abs(mPlayerSX)*1500;
				if (mAnimTimer > 250)
				{
					mAnimTimer -= 100;
					mAnimFrame++;
					if (mAnimFrame >= 4) mAnimFrame = 0;
					for (i = 0; i < 5; i++)
					{
						mPlayerSprite.getChildAt(i).visible = (i == mAnimFrame);
					}				
				}
			}
			//Normalize angles
			if (mPlayerAngle < 0) mPlayerAngle += Math.PI*2;
			if (mPlayerAngle >= Math.PI*2) mPlayerAngle -= Math.PI*2;
			if (mBallAngle < 0) mBallAngle += Math.PI*2;
			if (mBallAngle >= Math.PI*2) mBallAngle -= Math.PI*2;
			
			
			// Update HUD
			mCoinsLeftTextfield.text = "Coins needed: "+mCoinsLeft;
			mTimeTextfield.text = "Time Left: "+(int)(mTimeLeft / 1000);
			if (mTimeLeft < 15*1000 && (mTimeLeft % 1000) < 500)
			{
				mTimeTextfield.textColor = 0xff4040;
			}
			else
			{
				mTimeTextfield.textColor = 0xffffff;
			}
		}
		
		
		public function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.RIGHT)
			{
				mPlayerDX = 1;
				mPlayerSprite.scaleX = 1;
			}
			if (e.keyCode == Keyboard.LEFT)
			{
				mPlayerDX = -1;
				mPlayerSprite.scaleX = -1;
			}
			if (e.keyCode == Keyboard.UP)
			{
				mPlayerDY = 1;
				
			}
			if (e.keyCode == Keyboard.SPACE)
			{
				mPlayerFire = 1;
				mAnimTimer = -250;
			}
		}
		
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.RIGHT)
			{
				mPlayerDX = 0;
			}
			if (e.keyCode == Keyboard.LEFT)
			{
				mPlayerDX = 0;
			}
			if (e.keyCode == Keyboard.UP)
			{
				mPlayerDY = 0;			
			}
			if (e.keyCode == Keyboard.SPACE)
			{
				mPlayerFire = 0;
			}					
		}
		
		public function rotatedX(x:Number):Number
		{
			return Math.cos(mPlayerAngle-Math.PI/2)*(x);
		}
		
		public function rotatedY(y:Number):Number
		{
			return Math.sin(mPlayerAngle-Math.PI/2)*(y);
		}
		
		
		
		public function currentTimeMillis():Number
		{
			mDate = new Date();
			return mDate.getTime();
		}
		
		
		public function updateEnemies():void
		{
			var i:int;
			
			for(i = 0; i < mEnemies.length; i++)
			{
				var isAlive:Boolean = mEnemies[i].isAlive;
				if (isAlive)
				{
					var enemySprite:Sprite = mEnemies[i].sprite;
					var angle:Number = mEnemies[i].angle;
					var height:Number = mEnemies[i].height;
					enemySprite.x = Math.cos(angle-Math.PI/2)*(PLANET_RADIUS + height + enemySprite.width/2);
					enemySprite.y = Math.sin(angle-Math.PI/2)*(PLANET_RADIUS + height + enemySprite.height/2);
					enemySprite.rotation = (mEnemies[i].angle*180/Math.PI) + Math.sin(mEllapsedTime/20)*10;
					
					//IA?
					if (mPlayerAngle > angle)
					{
						mEnemies[i].sx += 0.005;
						
					}
					else
					{
						mEnemies[i].sx -= 0.005;							
					}
					if (height < 16)
					{
						mEnemies[i].sy += 0.05;
					}
					else if (height > 32*3)
					{
						mEnemies[i].sy -= 0.05;
					}
					else
					{
						mEnemies[i].sy += Math.random()*0.05 - Math.random()*0.05;
					}
					
					if (mEnemies[i].sx > mMaxEnemySpeed)
					{
						mEnemies[i].sx = mMaxEnemySpeed;
					}
					if (mEnemies[i].sx < -mMaxEnemySpeed)
					{
						mEnemies[i].sx = -mMaxEnemySpeed;
					}
					if (mEnemies[i].sy > mMaxEnemySpeedY)
					{
						mEnemies[i].sy = mMaxEnemySpeedY;
					}
					if (mEnemies[i].sy < -mMaxEnemySpeedY)
					{
						mEnemies[i].sy = -mMaxEnemySpeedY;
					}
					
					
					// Ball hits enemy
					if (Math.abs(mBallSprite.x - enemySprite.x) < 8)
					{
						if (Math.abs(mBallSprite.y - enemySprite.y) < 8)
						{
							mPlanetSprite.removeChild(mEnemies[i].sprite);							
							mEnemies[i].isAlive = false
						}
					}
					// Enemy hits player
					if (Math.abs(mPlayerSprite.x - enemySprite.x) < 8)
					{
						if (Math.abs(mPlayerSprite.y - enemySprite.y) < 16)
						{
							mTimeLeft = -1;
						}
					}
					
					angle += mEnemies[i].sx;
					height += mEnemies[i].sy;
					mEnemies[i].angle = angle;
					mEnemies[i].height = height;
				}
			}
		}
		
	}
}