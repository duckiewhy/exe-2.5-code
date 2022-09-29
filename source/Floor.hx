package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;

/**
 * @author Zaphod
 */
class Floor extends FlxSkewedSprite
{
    public var maxSkew:Float = 30;
    public var minSkew:Float = -30;
    public var skewSpeed:Float = 15;

    var _skewDirection:Int = 1;

    public static var curStage:String = '';


    public function new(X:Float = 0, Y:Float = 0, StartSkew:Float = 0)
    {
        super(X, Y);
        curStage = PlayState.SONG.stage;
        switch (curStage)
        {
            case 'xterion':
                loadGraphic(Paths.image('xterion/floor'));
                updateHitbox();
        }

        //offset.set(width / 2, height / 2);
        //animation.frameIndex = Frame;

        antialiasing = ClientPrefs.globalAntialiasing;
        //skew.x = StartSkew;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        skew.x = -(PlayState.camFollowPos.x + x) / 35;
    }
}