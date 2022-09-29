package;

import flixel.graphics.FlxGraphic;
import sys.FileSystem;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var code:Int = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	override public function create():Void
	{
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null) {
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end

		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		FlxTransitionableState.defaultTransIn = SonicTransitionSubstate;
		FlxTransitionableState.defaultTransOut = SonicTransitionSubstate;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if FREEPLAY
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new ChartingState());
		#elseif MENU
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new EncoreState());
		#else

			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					startIntro();
				});

		#end
	}

	var logoBl:FlxSprite;
	var logoBlBUMP:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(5, 0, 0.7);
		}

		Conductor.changeBPM(190);
		persistentUpdate = true;

		bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('NewTitleMenuBG');
		bg.animation.addByPrefix('idle', "TitleMenuSSBG instance 1", 24);
		bg.animation.play('idle');
		bg.alpha = .75;
		bg.scale.x = 3;
		bg.scale.y = 3;
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		logoBlBUMP = new FlxSprite(0, 0);
		logoBlBUMP.loadGraphic(Paths.image('logo'));
		logoBlBUMP.antialiasing = true;

		logoBlBUMP.scale.x = .5;
		logoBlBUMP.scale.y = .5;

		logoBlBUMP.screenCenter();

		add(logoBlBUMP);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(0, 0);
		titleText.frames = Paths.getSparrowAtlas('titleEnterNEW');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin instance 1", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED instance 1", 24, false);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.sound.play(Paths.sound('TitleLaugh'), 1, false, null, false, function()
			{
				skipIntro();
			});

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		if (FlxG.keys.justPressed.UP)
			if (code == 0)
				code = 1;
			else
				code == 0;

		if (FlxG.keys.justPressed.DOWN)
			if (code == 1)
				code = 2;
			else
				code == 0;

		if (FlxG.keys.justPressed.LEFT)
			if (code == 2)
				code = 3;
			else
				code == 0;

		if (FlxG.keys.justPressed.RIGHT)
			if (code == 3)
				code = 4;
			else
				code == 0;

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter && code != 4)
			{
				//if(titleText != null) titleText.animation.play('press');

				if (FlxG.save.data.flashing)
				{
					titleText.animation.play('press');
					titleText.animation.finishCallback = function(a:String)
					{
						remove(titleText);
					}
				}

				FlxG.camera.flash(FlxColor.RED, 0.2);
				FlxG.sound.play(Paths.sound('menumomentclick', 'exe'));
				FlxG.sound.play(Paths.sound('menulaugh', 'exe'));
				FlxTween.tween(bg, {alpha: 0}, 1);

				new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTween.tween(logoBlBUMP, {alpha: 0}, 1);
					});

				transitioning = true;
				// FlxG.sound.music.stop();
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					remove(titleText); // incase someone turned flashing off
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new EncoreState());
					/*var video = new MP4Handler();
					video.finishCallback = function()
					{
						MusicBeatState.switchState(new MainMenuState());
					}
					video.playVideo(Paths.video('bothCreditsAndIntro'));*/
				});

		/*		new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});*/
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if (pressedEnter && !transitioning && skippedIntro && code == 4)
				{
					transitioning = true;


					PlayState.SONG = Song.loadFromJson('milk', 'milk');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 1;
					PlayState.storyWeek = 1;
					FlxG.camera.fade(FlxColor.WHITE, 0.5, false);
					FlxG.sound.play(Paths.sound('confirmMenu'));


					//if (!FlxG.save.data.songArray.contains('milk') && !FlxG.save.data.botplay)
				//		FlxG.save.data.songArray.push('milk');
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true);
					});
				}

				super.update(elapsed);
		}

		//if (pressedEnter && !skippedIntro)
	//	{
	//		skipIntro();
	//	}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function playBoop1()
		{
			if (!skippedIntro)
			{
				FlxG.sound.play(Paths.sound('boop1', 'shared'));
			}
		}

		function playBoop2()
		{
			if (!skippedIntro)
			{
				FlxG.sound.play(Paths.sound('boop2', 'shared'));
			}
		}

		function playShow()
		{
			if (!skippedIntro)
			{
				FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);
			}
		}


	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

	/*	if(logoBl != null)
			logoBl.animation.play('bump');

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['Psych Engine by'], 45);
				// credTextShit.visible = true;
				case 3:
					addMoreText('Shadow Mario', 45);
					addMoreText('RiverOaken', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['This is a mod to'], -60);
				case 7:
					addMoreText('This game right below lol', -60);
					logoSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					logoSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		} */
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);

			FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);

			FlxG.camera.flash(FlxColor.RED, 2);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
