package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public static var isMajinNote:Bool;
	public var z:Float = 0; // for modchart system
	public var zIndex:Float = 0;
	public var scaleDefault:FlxPoint;

	private var player:Int;

	public function getZIndex(){
    var animZOffset:Float = 0;
    if(animation.curAnim!=null && animation.curAnim.name=='confirm')animZOffset+=1;
    return z + animZOffset - player;
  }

  function updateZIndex(){
    zIndex=getZIndex();
  }

	public function new(x:Float, y:Float, leData:Int, player:Int, skin:String) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		scaleDefault = new FlxPoint();
		this.player = player;
		this.noteData = leData;
		super(x, y);

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + skin));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + skin), true, Math.floor(width), Math.floor(height));
			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);

			antialiasing = false;
			setGraphicSize(Std.int(width * ClientPrefs.noteSize * PlayState.daPixelZoom * 1.5));

			switch (Math.abs(leData))
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			if (!isMajinNote) frames = Paths.getSparrowAtlas(skin);
			else frames = Paths.getSparrowAtlas(skin, 'exe');
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.globalAntialiasing;
			setGraphicSize(Std.int(width * ClientPrefs.noteSize));

			if(PlayState.SONG.isRing)
				switch (Math.abs(leData))
				{
					case 0:
						animation.addByPrefix('static', 'arrowLEFT');
						animation.addByPrefix('pressed', 'left press', 24, false);
						animation.addByPrefix('confirm', 'left confirm', 24, false);
					case 1:
						animation.addByPrefix('static', 'arrowDOWN');
						animation.addByPrefix('pressed', 'down press', 24, false);
						animation.addByPrefix('confirm', 'down confirm', 24, false);
					case 3:
						animation.addByPrefix('static', 'arrowUP');
						animation.addByPrefix('pressed', 'up press', 24, false);
						animation.addByPrefix('confirm', 'up confirm', 24, false);
					case 4:
						animation.addByPrefix('static', 'arrowRIGHT');
						animation.addByPrefix('pressed', 'right press', 24, false);
						animation.addByPrefix('confirm', 'right confirm', 24, false);
					case 2:
						animation.addByPrefix('static', 'arrowSPACE0');
						animation.addByPrefix('pressed', 'space press', 24, false);
						animation.addByPrefix('confirm', 'space confirm', 24, false);
				}

			else
				switch (Math.abs(leData))
				{
					case 0:
						animation.addByPrefix('static', 'arrowLEFT');
						animation.addByPrefix('pressed', 'left press', 24, false);
						animation.addByPrefix('confirm', 'left confirm', 24, false);
					case 1:
						animation.addByPrefix('static', 'arrowDOWN');
						animation.addByPrefix('pressed', 'down press', 24, false);
						animation.addByPrefix('confirm', 'down confirm', 24, false);
					case 2:
						animation.addByPrefix('static', 'arrowUP');
						animation.addByPrefix('pressed', 'up press', 24, false);
						animation.addByPrefix('confirm', 'up confirm', 24, false);
					case 3:
						animation.addByPrefix('static', 'arrowRIGHT');
						animation.addByPrefix('pressed', 'right press', 24, false);
						animation.addByPrefix('confirm', 'right confirm', 24, false);
				}
		}

		updateHitbox();
		scrollFactor.set();
		scaleDefault.set(scale.x,scale.y);
	}

	public function postAddedToGroup() {
		playAnim('static');
		if(player == 0)
			x += 50;
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		updateZIndex();

		/*if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			updateConfirmOffset();
		}*/

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				updateConfirmOffset();
			}
		}
	}

	function updateConfirmOffset() { //TO DO: Find a calc to make the offset work fine on other angles
		// offset.x -= 13*(ClientPrefs.noteSize/0.7);
		// offset.y -= 13*(ClientPrefs.noteSize/0.7);
	}
}
