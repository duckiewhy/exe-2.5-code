package;

import flixel.ui.FlxBar;
import Controls.Control;
import flixel.math.FlxMath;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;

	var grpMenuShit2:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;

	public var practiceMode:Bool = false;

	var camThing:FlxCamera;

	var colorSwap:ColorSwap;

	var grayButton:FlxSprite;

	var bottomPause:FlxSprite;
	var topPause:FlxSprite;

	var coolDown:Bool = true;

	private var timeBarBG:AttachedSprite;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var timeBar:FlxBar;
	public var boyfriend:Boyfriend;
	var songPercent:Float = 0;

	public static var transCamera:FlxCamera;

	var creditsText:FlxTypedGroup<FlxText>;
	var creditoText:FlxText;

	private var curSong:String = "";

	public function new(x:Float, y:Float)
	{

		camThing = new FlxCamera();
		camThing.bgColor.alpha = 0;
		FlxG.cameras.add(camThing);


		super();
		menuItems = menuItemsOG;

		FlxG.sound.play(Paths.sound("pause"));

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = 200;
		timeBarBG.y = 200;
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;


		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), PlayState.current,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, FlxColor.RED);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;

		timeBarBG.sprTracker = timeBar;
		boyfriend = new Boyfriend(0, 0, PlayState.SONG.player1);
		iconP1 = new HealthIcon(boyfriend.healthIcon, false);
		iconP1.x = -1000;
		iconP1.angle = 100;
		iconP1.y = timeBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;

		iconP2 = new HealthIcon('face', false);
		iconP2.y = timeBar.y - 75;

		bottomPause = new FlxSprite(1280, 33).loadGraphic(Paths.image('pauseStuff/bottomPanel'));
		if (PlayState.isFixedAspectRatio)
		{
			/*
			bottomPause.scale.x = 1.4;
			bottomPause.scale.y = 1.4;
			*/
			FlxTween.tween(bottomPause, {x: 589 - 310}, 0.2, {ease: FlxEase.quadOut});
		}
		else FlxTween.tween(bottomPause, {x: 589}, 0.2, {ease: FlxEase.quadOut});
		add(bottomPause);


		topPause = new FlxSprite(-1000, 0).loadGraphic(Paths.image("pauseStuff/pauseTop"));
		add(topPause);
		FlxTween.tween(topPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		/*
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		*/
		grayButton = new FlxSprite().loadGraphic(Paths.image('pauseStuff/graybut'));
		grayButton.x = FlxG.width - 400 + 480;
		grayButton.y = FlxG.height / 2 + 70;
		FlxTween.tween(grayButton, {x: grayButton.x - 480}, 0.2, {ease: FlxEase.quadOut});
		add(grayButton);

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);

		grpMenuShit2 = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit2);

		for (i in 0...menuItems.length)
		{
			var songText:FlxSprite = new FlxSprite(FlxG.width + 400 + 80 * i, FlxG.height / 2 + 70 + 100 * i);
			songText.loadGraphic(Paths.image("pauseStuff/blackbut"));
			songText.x += (i + 1) * 480;
			songText.ID = i;
			FlxTween.tween(songText, {x: songText.x - 480 * (i + 1)}, 0.2, {ease: FlxEase.quadOut});
			grpMenuShit.add(songText);
			var actualText:FlxSprite = new FlxSprite(songText.x + 25, songText.y + 25).loadGraphic(Paths.image(StringTools.replace("pauseStuff/" + menuItems[i], " ", "")));
			actualText.ID = i;
			actualText.x += (i + 1) * 480;
			actualText.y = FlxG.height / 2 + 70 + 100 * i + 5;
			if (!practiceMode){
			FlxTween.tween(actualText, {x: FlxG.width - 400 - 80 * i + 25}, 0.2, {ease: FlxEase.quadOut});}
			grpMenuShit2.add(actualText);
		}

		coolDown = false;
		new FlxTimer().start(0.2, function(lol:FlxTimer)
		{
			coolDown = true;
			changeSelection();
		});
		add(timeBarBG);
		add(timeBar);
		add(iconP1);
		var iconOffset:Int;
		iconOffset = 26;
		var percent = timeBar.percent;
		percent = 100-timeBar.percent;
		iconP2.x = timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		FlxTween.tween(iconP1, {x:timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset)}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(iconP1, {angle: 0}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		cameras = [camThing];
	}

	override function update(elapsed:Float)
	{

		if (PlayState.isFixedAspectRatio) FlxG.fullscreen = false;

		if(FlxG.keys.justPressed.P)
			{
				openSubState(new PracticeSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				FlxG.sound.play(Paths.sound("secretSound"));
			}

		#if debug
		if (FlxG.keys.justPressed.B)
		{
			switch (FlxG.random.int(1,7))
			{
				case 1:
					FlxG.sound.play(Paths.sound("FartHD")); // Fart
				case 2:
					FlxG.sound.play(Paths.sound("vineboom"));
				case 3:
					FlxG.sound.play(Paths.sound("secretSound"));
				case 4:
					FlxG.sound.play(Paths.sound("Ring"));
				case 5:
					FlxG.sound.play(Paths.sound("yay"));
				case 6:
					FlxG.sound.play(Paths.sound("waowaowaowaowao"));
				case 7:
					FlxG.sound.play(Paths.sound("switch"));
			}
			PlayState.cpuControlled = !PlayState.cpuControlled;
			PlayState.usedPractice = true;
			botplayText.visible = PlayState.cpuControlled; //imagine not being a dev
		}
		#else
		if (FlxG.keys.justPressed.B)
			{
				switch (FlxG.random.int(1,7))
				{
					case 1:
						FlxG.sound.play(Paths.sound("FartHD")); // Fart
					case 2:
						FlxG.sound.play(Paths.sound("vineboom"));
					case 3:
						FlxG.sound.play(Paths.sound("secretSound"));
					case 4:
						FlxG.sound.play(Paths.sound("Ring"));
					case 5:
						FlxG.sound.play(Paths.sound("yay"));
					case 6:
						FlxG.sound.play(Paths.sound("waowaowaowaowao"));
					case 7:
						FlxG.sound.play(Paths.sound("switch"));
				}
				Sys.exit(0);
			}
		#end

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (coolDown)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}

			if (accepted)
			{
				var daSelected:String = menuItems[curSelected];
				for (i in 0...difficultyChoices.length-1) {
					if(difficultyChoices[i] == daSelected) {
						var name:String = PlayState.SONG.song.toLowerCase();
						var poop = Highscore.formatSong(name, curSelected);
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.cpuControlled = false;
						return;
					}
				}

				FlxTween.cancelTweensOf(iconP1);
				switch (daSelected)
				{

					case "Resume":

						coolDown = false;
						FlxG.sound.play(Paths.sound("unpause"));
						grpMenuShit.forEach(function(item:FlxSprite)
						{
							FlxTween.tween(item, {x: item.x + 480 * (item.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
						});
						grpMenuShit2.forEach(function(item2:FlxSprite)
						{
							FlxTween.tween(item2, {x: item2.x + 480 * (item2.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
						});
						FlxTween.tween(grayButton, {x: grayButton.x + 480 * (curSelected + 1)}, 0.2, {ease: FlxEase.quadOut});

						FlxTween.tween(topPause, {x: -1000}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(bottomPause, {x: 1280}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
						{
							close();
						}});
					case "Restart Song":
						switch(PlayState.SONG.song.toLowerCase()){
							case 'sunshine':
								MusicBeatState.getState().transOut = OvalTransitionSubstate;
							default:
						}
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
					case "Exit to menu":
						if(PlayState.SONG.song.toLowerCase() == 'milk'){
							ClientPrefs.noteSize == 0.7;
						}
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						if(PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else {
							MusicBeatState.switchState(new FreeplayState());
						}
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						PlayState.usedPractice = false;
						PlayState.changedDifficulty = false;
						PlayState.cpuControlled = false;
				}
			}
		}
	}

	public function fart()
		{
			FlxTween.tween(topPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomPause, {x: 589}, 0.2, {ease: FlxEase.quadOut});
		}

	override function openSubState(SubState:FlxSubState)
		{
			super.openSubState(SubState);
		}

	override function destroy()
	{
		camThing.destroy();
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (change == 1 || change == -1) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;



		for (item in grpMenuShit.members)
		{
			FlxTween.cancelTweensOf(item);

			item.x = FlxG.width - 400 - 80 * item.ID;
			item.y = FlxG.height / 2 + 70 + 100 * item.ID;


			if (item.ID == curSelected)
			{
				FlxTween.cancelTweensOf(grayButton);
				grayButton.x = FlxG.width - 400 - 80 * item.ID;
				grayButton.y = FlxG.height / 2 + 70 + 100 * item.ID;
				FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID - 20}, 0.2, {ease: FlxEase.quadOut, onComplete: function(lol:FlxTween)
				{
					FlxTween.tween(item, {y: item.y + 5}, 1, {ease: FlxEase.quadOut, type: FlxTween.PINGPONG});
					FlxTween.tween(grayButton, {y: grayButton.y - 5}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
				}});

			}
			else
			{
				FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID}, 0.2, {ease: FlxEase.quadOut});
			}
			// item.setGraphicSize(Std.int(item.width * 0.8));
		}
		for (item in grpMenuShit2.members)
		{
			FlxTween.cancelTweensOf(item);
			item.x = grpMenuShit.members[item.ID].x + 25;
			item.y = FlxG.height / 2 + 70 + 100 * item.ID + 5;

			if (item.ID == curSelected) FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID - 20 + 5}, 0.2, {ease: FlxEase.quadOut, onComplete: function(lol:FlxTween)
			{
				FlxTween.tween(item, {y: item.y + 5}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
			}});
			else FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID + 5}, 0.2, {ease: FlxEase.quadOut});
		}
	}


	/*
	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
	*/
}
