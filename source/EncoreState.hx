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

	public static var talk:FlxText;

	override function create()
	{
		talk = new FlxText();
		talk.text = "I wish I could've made a bigger impact to this team.\nI really did kinda feel like a wasted slot, everyone else around me being much more skilled and whatnot.\nI do miss the team, I miss the progress it made. I miss it a lot.\nTeam did feel like a family, despite everything that happened.\nI figured a message like this would appear from someone like me in this state,\nconsidering its the one that people went after me for.\nThe story portraits were not by divide, they were by scorch, only triple trouble's portrait had a concept by divide.\nRegardless, if I had known divide had a hand in their creation, i wouldnt had laid a finger on them. I am beyond sorry.\nI hope exe finally falls and rots like it should.\nRest in peace to the dream that was exe mod, and let anything that tries to recreate it, rot. just like the real mod.\n \n-DuskieWhy";
		talk.alignment = CENTER;
		talk.scale.set(2.3,2.3);
		talk.updateHitbox();
		talk.screenCenter();
		add(talk);
		super.create();
	}
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.ACCEPT)
			MusicBeatState.switchState(new MainMenuState());
	}
}