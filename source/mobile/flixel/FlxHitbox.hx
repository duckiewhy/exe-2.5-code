package mobile.flixel;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.Shape;
import mobile.flixel.FlxButton;

enum FlxHitboxType
{
	DEFAULT;
	SPACE;
}

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonDodge:FlxButton = new FlxButton(0, 0); //real
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
	
	public var altpos:Bool = false;
	
	/**
	 * Create the zone.
	 */
	public function new(type:FlxHitboxType)
	{
		//altpos = ClientPrefs.dodgepos; not yet

		super();

		switch (type)
		{

    case DEFAULT:
    add(buttonLeft = createHint(0, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FF));
    add(buttonDown = createHint(FlxG.width / 4, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FFFF));
    add(buttonUp = createHint(FlxG.width / 2, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FF00));
    add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF0000));
 
    case SPACE:
     add(buttonLeft = createHint(0, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FF));
     add(buttonDown = createHint(FlxG.width / 4, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FFFF));
     add(buttonDodge = createHint(0, 0, FlxG.width, Std.int(FlxG.height / 4), 0xFFD000));
     add(buttonUp = createHint(FlxG.width / 2, Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0x00FF00));
     add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), Std.int(FlxG.height / 4), Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF0000));
		}

		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		super.destroy();

		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonDodge = FlxDestroyUtil.destroy(buttonDodge); //omg
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		shape.graphics.lineStyle(10, Color, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):FlxButton
	{
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function()
		{
			if (hint.alpha != 0.2)
				hint.alpha = 0.2;
		}
		hint.onUp.callback = hint.onOut.callback = function()
		{
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}

  enum HitboxType {
    DEFAULT;
    DODGE;
}
