package;

import flixel.addons.transition.TransitionSubstate;
import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;

class BlankTransitionSubstate extends TransitionSubstate
{
  var _finalDelayTime:Float = 0.0;

  public static var defaultCamera:FlxCamera;
  public static var nextCamera:FlxCamera;

  var curStatus:TransitionStatus;

  public function new(){
    super();
  }

  public override function destroy():Void
  {
    super.destroy();
    finishCallback = null;
  }

  function onFinish(f:FlxTimer):Void
  {
    if (finishCallback != null)
    {
      finishCallback();
      finishCallback = null;
    }
  }

  function delayThenFinish():Void
  {
    new FlxTimer().start(_finalDelayTime, onFinish); // force one last render call before exiting
  }

  public override function update(elapsed:Float){

    super.update(elapsed);
  }


  override public function start(status: TransitionStatus){
    var cam = nextCamera!=null?nextCamera:(defaultCamera!=null?defaultCamera:FlxG.cameras.list[FlxG.cameras.list.length - 1]);
    cameras = [cam];

    nextCamera = null;
    trace('transitioning $status');
    curStatus=status;
    var zoom:Float = FlxMath.bound(cam.zoom,0.001);
    var width:Int = Math.ceil(cam.width/zoom);
    var height:Int = Math.ceil(cam.height/zoom);

    switch(status){
      case IN:

      case OUT:


      default:
        trace("bruh");
    }

    delayThenFinish(); // this should be called whenever the transition is finished


  }
}
