package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'BloodSplash';

		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);

		if(texture == null) {
			texture = 'BloodSplash';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}

		switch(texture){
			case 'BloodSplash':
				alpha = 1;
				antialiasing=true;
				colorSwap.hue = 0;
				colorSwap.saturation = 0;
				colorSwap.brightness = 0;
				offset.set(-40*(ClientPrefs.noteSize/0.7),-90*(ClientPrefs.noteSize/0.7));
				animation.play('splash', true);

				animation.curAnim.frameRate = 24;
			case 'hitmarker':
				alpha = 1;
				antialiasing=true;
				colorSwap.hue = 0;
				colorSwap.saturation = 0;
				colorSwap.brightness = 0;
				animation.play('hit', true);
				updateHitbox();
				offset.set(-90*(ClientPrefs.noteSize/0.7),-90*(ClientPrefs.noteSize/0.7));

				animation.curAnim.frameRate = 24;
			case 'milkSplashes':
				alpha = 0.89;
				antialiasing=true;
				var animNum:Int = FlxG.random.int(1, 2);
				animation.play('note' + note + '-' + animNum, true);
				scale.x = 0.6;
				scale.y = 0.6;
				updateHitbox();
				offset.set(70*(ClientPrefs.noteSize/0.7), 90*(ClientPrefs.noteSize/0.7));
			case 'endlessNoteSplashes':
				alpha = 1;
				antialiasing=true;
				colorSwap.hue = hueColor;
				colorSwap.saturation = satColor;
				colorSwap.brightness = brtColor;
				offset.set(20*(ClientPrefs.noteSize/0.7), -10*(ClientPrefs.noteSize/0.7));
				var animNum:Int = FlxG.random.int(1, 2);
				animation.play('note' + note + '-' + animNum, true);

				animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
			default:
				alpha = 0.6;
				antialiasing=true;
				colorSwap.hue = hueColor;
				colorSwap.saturation = satColor;
				colorSwap.brightness = brtColor;
				offset.set(10*(ClientPrefs.noteSize/0.7), 10*(ClientPrefs.noteSize/0.7));
				var animNum:Int = FlxG.random.int(1, 2);
				animation.play('note' + note + '-' + animNum, true);

				animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}


	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		switch(skin){
			case 'BloodSplash':
					animation.addByPrefix("splash", "Squirt", 24, false);
			case 'hitmarker':
					animation.addByPrefix("hit", "hit", 24, false);
			case 'milkSplashes':
				for (i in 1...3) {
					animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
					animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
					animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
					animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
				}
			default:
				if(PlayState.SONG.isRing)
					for (i in 1...3) {
						animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
						animation.addByPrefix("note3-" + i, "note splash green " + i, 24, false);
						animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
						animation.addByPrefix("note4-" + i, "note splash red " + i, 24, false);
						animation.addByPrefix("note2-" + i, "note splash red " + i, 24, false);
					}
				else
					for (i in 1...3) {
						animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
						animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
						animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
						animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
					}
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}
