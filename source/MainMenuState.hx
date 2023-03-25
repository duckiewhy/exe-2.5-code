package;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import editors.MasterEditorMenu;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	var curSelected:Int = 0;

	var xval:Int = 585;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var soundCooldown:Bool = true;

	var optionShit:Array<String> = [
		'story_mode',
		'encore',
		'freeplay',
		'sound_test',
		'options',
		'extras'
	];

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var bgdesat:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	var debugKeys:Array<FlxKey>;


	override function create()
	{
		/*#if debug
		optionShit.push('sound test');
		#else
		optionShit.push('sound test locked');
		#end
		if(!ClientPrefs.beatweek){
			optionShit.push('sound_test locked');
			optionShit.push('encore locked');
		}
		else{
			optionShit.push('sound_test');
			optionShit.push('encore');
		}*/
		
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();


		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('storymodemenumusic'));
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('Main_Menu_Spritesheet_Animation');
		bg.animation.addByPrefix('a', 'BG instance 1');
		bg.animation.play('a', true);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bgdesat = new FlxSprite(-80).loadGraphic(Paths.image('backgroundlool2'));
		bgdesat.scrollFactor.x = 0;
		bgdesat.scrollFactor.y = 0;
		bgdesat.setGraphicSize(Std.int(bgdesat.width * .5));
		bgdesat.updateHitbox();
		bgdesat.screenCenter();
		bgdesat.visible = false;
		bgdesat.antialiasing = true;
		bgdesat.color = 0xFFfd719b;
		add(bgdesat);


		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);



		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-500, (i * 100)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('lock', optionShit[i] + " locked", 24);
		if (!ClientPrefs.beatweek && optionShit[i] == 'sound_test') {
				menuItem.animation.play('lock');
				menuItem.animation.addByPrefix('idle', optionShit[i] + " locked", 24);
			}
			else
			{
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.play('idle');
			}
			
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();

			
			
			if (firstStart)
				FlxTween.tween(menuItem,{x: xval},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)
					{
						if(i == optionShit.length - 1)
						{
							finishedFunnyMove = true;
							changeItem();
						}
					}});
			else{
				menuItem.x = xval;
				finishedFunnyMove=true;
			}

			xval = xval + 70;
		}


		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

    var credits:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 20 * 2, 320, "Android Port By MaysLastPlay, MarioMaster, Stefan2008", 3);
	 credits.scrollFactor.set();
	 credits.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(credits);

		var dataerase:FlxText = new FlxText(FlxG.width - 300, FlxG.height - 18 * 2, 300, "Hold C to erase ALL data (this doesn't include ALL options)", 3);
		dataerase.scrollFactor.set();
		dataerase.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dataerase);

		changeItem();

                #if mobile addVirtualPad(UP_DOWN, A_B_C); #end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.DELETE #if mobile || virtualPad.buttonC.justPressed #end)
		{
			var urmom = 0;
			new FlxTimer().start(0.1, function(hello:FlxTimer)
			{
				urmom += 1;
				if (urmom == 30)
				{
					FlxG.save.data.storyProgress = 0;
					FlxG.save.data.soundTestUnlocked = false;
					FlxG.save.data.songArray = [];
					FlxG.switchState(new MainMenuState());
				}
				if (FlxG.keys.pressed.DELETE)
				{
					hello.reset();
				}
			});
		}



		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (!selectedSomethin)
		{
				if (FlxG.keys.justPressed.UP || controls.UI_UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN || controls.UI_DOWN_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

				if (FlxG.keys.justPressed.BACKSPACE || controls.BACK)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}

		if (FlxG.keys.justPressed.ENTER || controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else if (!ClientPrefs.beatweek && optionShit[curSelected] == 'sound_test')
				{
					soundCooldown = false;
					FlxG.sound.play(Paths.sound('deniedMOMENT'));
					camera.shake(0.03,0.03);
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						soundCooldown = true;
					});
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'encore':
										MusicBeatState.switchState(new EncoreState());
									case 'sound_test':										
										MusicBeatState.switchState(new SoundTestMenu());									
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			if (FlxG.keys.justPressed.SIX)
			{
				MusicBeatState.switchState(new EncoreState());
			}
			if (FlxG.keys.justPressed.SEVEN)
			{
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			if (FlxG.keys.justPressed.EIGHT)
			{
				MusicBeatState.switchState(new FreeplayState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;
			
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			
			
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			var daChoice:String = optionShit[curSelected];
			if(!ClientPrefs.beatweek && daChoice == 'sound_test'){
					spr.animation.play('lock');
				}
			spr.animation.play('idle');
			
			/*
			if (huh != 0)
			{
				FlxTween.cancelTweensOf(spr);
			}
			FlxTween.tween(spr, {x: 100 + ((curSelected * -1 + spr.ID + 1) * 220) , y: 40 + ((curSelected * -1 + spr.ID + 1) * 140)}, 0.2);
			*/

			
			
			if (spr.ID == curSelected && finishedFunnyMove)
			{
				if(!ClientPrefs.beatweek && daChoice == 'sound_test'){
					spr.animation.play('lock');
				}
				else
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
