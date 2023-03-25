package;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class EncoreState extends MusicBeatState // REWRITE FREEPLAY!?!?!? HELL YEA!!!!!
{
	var whiteshit:FlxSprite;

	var curSelected:Int = 0;

	var songArray:Array<String> = ["too-slow-encore", "you-cant-run-encore", "triple-trouble-encore"];

	var boxgrp:FlxTypedSpriteGroup<FlxSprite>;

	var bg:FlxSprite;

	var cdman:Bool = true;

	var fuck:Int = 0;

	var songtext:FlxText;
	var prevsongtext:FlxText;

	override function create()
	{
		
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		whiteshit = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		whiteshit.alpha = 0;

		bg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
		bg.screenCenter();
		bg.setGraphicSize(1280, 720);
		add(bg);

		boxgrp = new FlxTypedSpriteGroup<FlxSprite>();

		songtext = new FlxText(0, FlxG.height - 100, songArray[curSelected], 25);
		songtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));
		songtext.x = (FlxG.width / 2) - (25 / 2 * songArray[curSelected].length);
		add(songtext);

		FlxG.log.add('sexo: ' + (songtext.width / songArray[curSelected].length));

		prevsongtext = new FlxText(0, FlxG.height - 100, songArray[curSelected], 25);
		prevsongtext.x = (FlxG.width / 2) - (25 / 2 * songArray[curSelected].length);
		prevsongtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));
		
		add(prevsongtext);

		for (i in 0...songArray.length) {
			FlxG.log.add(songArray[i] + ' found');
	
			var box:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('FreeBox'));
			boxgrp.add(box);

			var char:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('fpstuff/' + songArray[fuck].toLowerCase()));
			boxgrp.add(char);

			fuck += 1;
		}

		if (songArray[0] == 'lol')
		{
			remove(songtext);
			remove(prevsongtext);
		}
		
		add(boxgrp);

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Encore Menu", null);
		 #end

		add(whiteshit);

                #if mobile addVirtualPad(LEFT_RIGHT, A_B); #end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.LEFT || controls.UI_LEFT_P;
		var downP = FlxG.keys.justPressed.RIGHT || controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (cdman)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted && cdman && songArray[0] != 'lol')
		{
			cdman = false;

			switch (songArray[curSelected]) // Some charts don't include -hard in their file name so i decided to get focken lazy.
			{
          case "too-slow-encore":
					PlayState.SONG = Song.loadFromJson('too-slow-encore', 'too-slow-encore');
          case "you-cant-run-encore":
					PlayState.SONG = Song.loadFromJson('you-cant-run-encore', 'you-cant-run-encore');
          case "triple-trouble-encore":
					PlayState.SONG = Song.loadFromJson('triple-trouble-encore', 'triple-trouble-encore');
				default:
					PlayState.SONG = Song.loadFromJson(songArray[curSelected].toLowerCase() + '-hard', songArray[curSelected].toLowerCase());
			}

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = 1;
			FlxTween.tween(whiteshit, {alpha: 1}, 0.4);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayStateChangeables.nocheese = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		
	}

	
	function changeSelection(change:Int = 0)
	{

		#if !switch
		// NGio.logEvent('Fresh');
		#end
	
		if (change == 1 && curSelected != songArray.length - 1) 
		{
			cdman = false;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			FlxTween.tween(boxgrp ,{x: boxgrp.x - 780}, 0.2, {ease: FlxEase.expoOut, onComplete: function(sus:FlxTween)
				{
					cdman = true;
				}
			});
			
		}
		else if (change == -1 && curSelected != 0) 
		{
			cdman = false;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			FlxTween.tween(boxgrp ,{x: boxgrp.x + 780}, 0.2, {ease: FlxEase.expoOut, onComplete: function(sus:FlxTween)
				{
					cdman = true;
				}
			});

		}
		if ((change == 1 && curSelected != songArray.length - 1) || (change == -1 && curSelected > 0)) // This is a.
		{
			songtext.alpha = 0;
			songtext.text = songArray[curSelected + change];
			if (songArray[curSelected + change] == 'black-sun') songtext.text = 'black sun';
			FlxTween.tween(songtext ,{alpha: 1, x: (FlxG.width / 2) - (25 / 2 * songArray[curSelected + change].length)}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(prevsongtext ,{alpha: 0, x: (FlxG.width / 2) - (25 / 2 * songArray[curSelected + change].length)}, 0.2, {ease: FlxEase.expoOut});
		}

		curSelected += change;
		if (curSelected < 0) curSelected = 0;
		else if (curSelected > songArray.length - 1) curSelected = songArray.length - 1;
	}
}
