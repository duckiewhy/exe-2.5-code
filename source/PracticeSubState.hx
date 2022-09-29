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

class PracticeSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;

	var grpMenuShit2:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Scroll Speed', 'Mechanics', 'Invincibility'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;

	var camThing:FlxCamera;

	var colorSwap:ColorSwap;

    var pauseShit:PauseSubState;

	var grayButton:FlxSprite;

	var bottomPause:FlxSprite;
	var topPause:FlxSprite;
    var warningThingy:FlxSprite;

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
		super();
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

        warningThingy = new FlxSprite(0, 0).loadGraphic(Paths.image("pauseStuff/practice/instructions"));
		warningThingy.alpha = 0;
        add(warningThingy);
		FlxTween.tween(warningThingy, {alpha: 1}, 0.2, {ease: FlxEase.quadOut});

		bottomPause = new FlxSprite(-1280, 0).loadGraphic(Paths.image('pauseStuff/practice/side'));
		if (PlayState.isFixedAspectRatio)
		{
			/*
			bottomPause.scale.x = 1.4;
			bottomPause.scale.y = 1.4;
			*/
			FlxTween.tween(bottomPause, {x: 589 - 310}, 0.2, {ease: FlxEase.quadOut});
		}
		else FlxTween.tween(bottomPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});
		add(bottomPause);

		topPause = new FlxSprite(1280, 0).loadGraphic(Paths.image("pauseStuff/practice/head"));
		add(topPause);
		FlxTween.tween(topPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});

		for (i in 0...menuItems.length)
		{
            var offset:Float = 108 - (Math.max(menuItems.length, 4) - 4) * 80;
            var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);

			var actualText:FlxSprite = new FlxSprite(FlxG.width + 400 + 80 * i, FlxG.height / 2 + 70 + 100 * i).loadGraphic(Paths.image(StringTools.replace("pauseStuff/practice/" + menuItems[i], " ", "")));
			actualText.ID = i;
			actualText.x += (i + 1) * 480;
			actualText.y = FlxG.height / 2 + 70 + 100 * i + 5;
			FlxTween.tween(actualText, {x: FlxG.width - 400 - 80 * i + 25}, 0.2, {ease: FlxEase.quadOut});
			add(actualText);
    	}

		coolDown = false;
		new FlxTimer().start(0.2, function(lol:FlxTimer)
		{
			coolDown = true;
			changeSelection();
		});
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{

		if (PlayState.isFixedAspectRatio) FlxG.fullscreen = false;

        if (FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.sound.play(Paths.sound("unpause"));
                FlxTween.tween(topPause, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
                FlxTween.tween(bottomPause, {x: -1280}, 0.2, {ease: FlxEase.quadOut});
                FlxTween.tween(warningThingy, {alpha: 0}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
                {
                    close();
                }});
        }
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

				switch (daSelected)
				{
					//every option just closes the state since im dumb as fuck and dont wanna do the implementation
					case "Scroll Speed":						
						FlxG.sound.play(Paths.sound("unpause"));
						FlxTween.tween(topPause, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(bottomPause, {x: -1280}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
						{
							close();
						}});
					case "Mechanics":
						FlxG.sound.play(Paths.sound("unpause"));
						FlxTween.tween(topPause, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(bottomPause, {x: -1280}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
						{
							close();
						}});
					case "Invincibility":
						FlxG.sound.play(Paths.sound("unpause"));
						FlxTween.tween(topPause, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(bottomPause, {x: -1280}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
						{
							close();
						}});
				}
			}
		}
	}
	
	override function openSubState(SubState:FlxSubState)
		{
			super.openSubState(SubState);
		}

	override function destroy()
	{
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


	}
}
