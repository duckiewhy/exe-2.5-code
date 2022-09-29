package;

import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets.FlxGraphicAsset;

class WireSprite extends FlxSprite
{
  public var tweens:Map<String,FlxTween> = [];
  public var extraInfo:Map<String, Any> = [];
	public var shakePoint(default, null):FlxPoint = FlxPoint.get();

  // taken from FlxCamera
  var shakeIntensity:Float = 0;
  var shakeDuration:Float = 0;
  var shakeCallback:Void->Void;
  function updateShake(elapsed:Float){
    if(shakeDuration>0){
      shakeDuration -= elapsed;
      if(shakeDuration<=0){
        if(shakeCallback!=null){
          shakeCallback();
        }
      }else{
        shakePoint.x = FlxG.random.float(-shakeIntensity*frameWidth, shakeIntensity*frameWidth)*scale.x;
        shakePoint.y = FlxG.random.float(-shakeIntensity*frameHeight, shakeIntensity*frameHeight)*scale.y;
      }
    }
  }

  public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true):Void
  {

    if (!Force && shakeDuration > 0)
      return;

    shakeIntensity = Intensity;
    shakeDuration = Duration;
    shakeCallback = OnComplete;
  }


  override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):WireSprite
  {
    var sprite:WireSprite = cast super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
    return sprite;
  }

	override public function destroy():Void
	{
		shakePoint = FlxDestroyUtil.put(shakePoint);

		super.destroy();
	}

  override public function update(elapsed:Float){
    shakePoint.set(0, 0);
    updateShake(elapsed);
    super.update(elapsed);
  }

	override function drawComplex(camera:FlxCamera):Void
	{
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x - shakePoint.x, -origin.y - shakePoint.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		_point.add(origin.x, origin.y);
    _point.add(shakePoint.x, shakePoint.y);
		_matrix.translate(_point.x, _point.y);
    _matrix.translate(shakePoint.x, shakePoint.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		return false; // because too lazy to do drawSimple shit
	}
}
