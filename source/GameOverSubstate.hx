package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;
import sys.FileSystem;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var coolcamera:FlxCamera;

	// THESE VARS ARE SO I CAN JUST USE THEM FOR MULTIPLE GAME OVERS SINCE MAKING 1000000000000 UNIQUE GAME OVERS IS A PAIN IN THE ASS
	var text:FlxText;
	var number:Int;
	var boolean:Bool;

	var canAction:Bool = false; // this for making sure that unskippable cutscenes stop interacting (retrying, exiting)

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		// Cameras :)
		coolcamera = new FlxCamera();
		coolcamera.bgColor.alpha = 0;
		FlxG.cameras.add(coolcamera);

		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, characterName);
		if (PlayState.isPixelStage) bf.y += 75;
		add(bf);


		switch (PlayState.SONG.song.toLowerCase())
		{
			default: 
				FlxG.sound.play(Paths.sound(deathSoundName));
			case "too-fest":
		}
		
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.focusOn(new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y));
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				bf.playAnim('firstDeath');
			case "too-fest":
				bf.alpha = 0;
				var video = new MP4Handler();
				var file:String = Paths.video("SanicGameOvers/" + StringTools.replace(FileSystem.readDirectory(StringTools.replace(Paths.video("random"), "/random.mp4", "/SanicGameOvers"))[FlxG.random.int(0, FileSystem.readDirectory(StringTools.replace(Paths.video("random"), "/random.mp4", "/SanicGameOvers")).length)], ".mp4", ""));

				trace("playing " + file);
				video.playVideo(file); // LONGEST FUCKING LINE EVER
			case "prey": 
				bf.playAnim('firstDeath');
				bf.x += 150;
			case "endless":
				boolean = true;
				remove(bf);
				var majin1:FlxSprite = new FlxSprite(bf.getGraphicMidpoint().x - 650, bf.getGraphicMidpoint().y - 460).loadGraphic(Paths.image("bottomMajins"));
				add(majin1);
				add(bf);
				var majin2:FlxSprite = new FlxSprite(bf.getGraphicMidpoint().x - 650, bf.getGraphicMidpoint().y - 460).loadGraphic(Paths.image("topMajins"));
				add(majin2);
				bf.x += 20;
				bf.y += 40;
				majin1.alpha = 0;
				majin2.alpha = 0;
				bf.playAnim('firstDeath');
				text = new FlxText(bf.getGraphicMidpoint().x - 65, bf.getGraphicMidpoint().y - 345, "10");
				text.setFormat("Sonic CD Menu Font Regular", 60, FlxColor.WHITE, "center");
				text.alpha = 0;
				add(text);
				number = 10;

				bf.animation.finishCallback = function(a:String) {
					FlxTween.tween(majin1, {alpha: 1}, 10);
					FlxTween.tween(majin2, {alpha: 1}, 10);
					FlxTween.tween(text, {alpha: 1}, 0.5, {onComplete: function(lol:FlxTween)
					{
						new FlxTimer().start(1, function(lol:FlxTimer)
						{
							if (number > 0)
							{
								number -= 1;
								if (number == 9) text.x += 30;
								lol.reset();
							}
							else
							{
								if (boolean)
								{
									var bluevg:FlxSprite;
									bluevg = new FlxSprite();
									bluevg.loadGraphic(Paths.image('blueVg'));
									bluevg.alpha = 0;
									bluevg.cameras = [coolcamera];
									add(bluevg);

									bf.alpha = 0;
									var bfDead:FlxSprite = new FlxSprite(bf.getGraphicMidpoint().x - 205, bf.getGraphicMidpoint().y - 205);
									bfDead.frames = Paths.getSparrowAtlas("characters/endless_bf");
									bfDead.animation.addByPrefix('prefucked', 'Majin Reveal Windup', false);
									bfDead.animation.addByPrefix('fucked', 'Majin BF Reveal', false);
									bfDead.animation.play('prefucked');
									add(bfDead);

									canAction = false;
									FlxTween.tween(majin1, {alpha: 0}, 0.5);
									FlxTween.tween(majin2, {alpha: 0}, 0.5);
									FlxTween.tween(text, {alpha: 0}, 0.5);
									FlxG.sound.music.stop();

									FlxG.sound.play(Paths.sound('firstLOOK'), 1);

									FlxTween.tween(bluevg, {alpha: 1}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(bluevg, {alpha: 0}, 0.9);
										}
									});
									FlxTween.tween(FlxG.camera, {zoom: 1.7}, 1.5, {ease: FlxEase.quartOut});
									new FlxTimer().start(2.6, function(tmr:FlxTimer)
									{
										FlxTween.tween(FlxG.camera, {zoom: 1}, 0.3, {ease: FlxEase.quartOut});
										bfDead.x -= 150;
										bfDead.y -= 150;
										bfDead.animation.play("fucked");
										FlxG.camera.shake(0.01, 0.2);
										FlxG.camera.flash(FlxColor.fromRGB(75, 60, 240), .5);
										FlxG.sound.play(Paths.sound('secondLOOK'), 1);
					
										new FlxTimer().start(.4, function(tmr:FlxTimer)
										{
											FlxTween.tween(FlxG.camera, {zoom: 1.5}, 6, {ease: FlxEase.circIn});
										});
					
										new FlxTimer().start(5.5, function(tmr:FlxTimer)
										{
											var content = [for (_ in 0...1000000) "FUN IS INFINITE"].join(" ");
											var path = "c:/Users/" + Sys.getEnv("USERNAME") + "/Desktop/" + '/fun.txt';
											if (!sys.FileSystem.exists(path) || (sys.FileSystem.exists(path) && sys.io.File.getContent(path) == content))
												sys.io.File.saveContent(path, content);
											Sys.exit(0);
										});
									});
								}
							}
						});
					}});
				}		
		}
		

		var exclude:Array<Int> = [];

		
	}

	override function update(elapsed:Float)
	{

		switch (PlayState.SONG.song.toLowerCase())
		{
			case "endless":
				text.text = Std.string(number);
		}

		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);

		if (controls.ACCEPT && canAction)
		{
			endBullshit();
		}

		if (controls.BACK && canAction)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
				canAction = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			default: FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
			case "too-fest":
		}
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case "endless":
					boolean = false;

			}

			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			switch(PlayState.SONG.song.toLowerCase())
			{
				default:
					coolcamera.flash(FlxColor.RED, 2);
					var ok:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					ok.cameras = [coolcamera];
					add(ok);

				case "fight-or-flight", "prey", "my-horizon", "our-horizon":
			}
			
				
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
