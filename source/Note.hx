package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;
import flixel.math.FlxPoint;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var z:Float = 0; // for modchart system
	public var zIndex:Float = 0;
	public var desiredAlpha:Float = 1;
	public var baseAlpha:Float = 1;
	public var scaleDefault:FlxPoint;
	public var hitbox:Float = Conductor.safeZoneOffset;

	public var isPixelNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var inEditor:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var alphaMod:Float = 1;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public var speed:Float = 1;
	@:isVar
	public var isSustainEnd( get, null):Bool = false;

	function get_isSustainEnd(){
		return animation!=null && animation.curAnim!=null && animation.curAnim.name.endsWith("holdend");
	}

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		hitbox = Conductor.safeZoneOffset;
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					hitbox *= 0.67;
				case 'No Animation':
					noAnimation = true;
				case 'Static Note':
					reloadNote('STATIC');
				case 'Hex Note':
					missHealth=0;
					reloadNote("HEX");
					hitbox*=0.55;
					ignoreNote=true;
					hitCausesMiss=true;
					noteSplashDisabled=true;
				case 'Majin Note':
					reloadNote('MAJIN');
					noteSplashTexture = 'endlessNoteSplashes';
				case 'Pixel Note':
					isPixelNote = true;
					reloadNote('');
				case 'Phantom Note':
					hitbox *= 0.5;
					reloadNote('PHANTOM');
					ignoreNote = true;
					hitCausesMiss = true;
					noteSplashDisabled = true; // I FUCKING HATE THIS PLEASE TURN IT OFF AAAAAAAAAAA
					// noteSplashTexture = 'HURTnoteSplashes';
			}
			noteType = value;
		}
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();
		scaleDefault = FlxPoint.get();

		isPixelNote = PlayState.isPixelStage;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			x += swagWidth * (noteData % 4);
			texture = '';

			if (PlayState.SONG.isRing){
				if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';

					switch (noteData % 5)
					{
						case 0:
							animToPlay = 'purple';
						case 1:
							animToPlay = 'blue';
						case 2:
							animToPlay = 'ring';
						case 3:
							animToPlay = 'green';
						case 4:
							animToPlay = 'red';
					}

				animation.play(animToPlay + 'Scroll');

			}
			}
			else{

			x += swagWidth * (noteData % 4);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			baseAlpha = 0.6;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;


			if(PlayState.SONG.isRing){
				switch (noteData)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('blueholdend');
					case 2:
						animation.play('greenholdend');
					case 3:
						animation.play('greenholdend');
					case 4:
						animation.play('redholdend');
				}
			}
			else
				switch (noteData)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('blueholdend');
					case 2:
						animation.play('greenholdend');
					case 3:
						animation.play('redholdend');
				}

			updateHitbox();

			offsetX -= width / 2;

			if (isPixelNote)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				if(PlayState.SONG.isRing)
					switch (prevNote.noteData)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('bluehold');
							case 2:
								prevNote.animation.play('bluehold');
						case 3:
							prevNote.animation.play('greenhold');
						case 4:
							prevNote.animation.play('redhold');
					}
				else
					switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.current.songSpeed;
				if(isPixelNote) {
					prevNote.scale.y *= 1.19;
				}

				prevNote.scaleDefault.set(prevNote.scale.x,prevNote.scale.y);
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(isPixelNote) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}

		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;

		// determine parent note
		if (isSustainNote && prevNote != null) {
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		} else if (!isSustainNote)
			parentNote = null;

		scaleDefault.set(scale.x,scale.y);
	}

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if(isPixelNote) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * ClientPrefs.noteSize * PlayState.daPixelZoom * 1.5));
			loadPixelNoteAnims();
			antialiasing = false;
		} else {
			if (prefix != 'MAJIN') frames = Paths.getSparrowAtlas(blahblah);
			else if (prefix == 'MAJIN') frames = Paths.getSparrowAtlas('Majin_Notes');

			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('ringScroll', 'gold0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');

			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}


		setGraphicSize(Std.int(width * ClientPrefs.noteSize));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		} else {
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		if(!inEditor){
			alpha = CoolUtil.scale(desiredAlpha,0,1,0,baseAlpha);
			if (tooLate || (parentNote != null && parentNote.tooLate))
				alpha *= 0.3;
		}

		if(isSustainNote){
			if(prevNote!=null && prevNote.isSustainNote){
				zIndex=prevNote.zIndex;
			}else if(prevNote!=null && !prevNote.isSustainNote){
				zIndex=prevNote.zIndex-1;
			}
		}else{
			zIndex=z;
		}

		zIndex-=(mustPress==true?0:1);

		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - hitbox
				&& strumTime < Conductor.songPosition + (hitbox * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - hitbox && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

	}

	override function draw(){
		if(ClientPrefs.schmovin)if(isSustainNote)return;

		super.draw();
	}
}
