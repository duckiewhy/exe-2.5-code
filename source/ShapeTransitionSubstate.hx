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
import openfl.display.BitmapData;

class ShapeTransitionSubstate extends TransitionSubstate
{
  var _finalDelayTime:Float = 0.0;

  public static var defaultCamera:FlxCamera;
  public static var nextCamera:FlxCamera;
  var head:BitmapData;
  var curStatus:TransitionStatus;
  var shape:String = 'circle';
  var time:Float = 0.6;
  var maxScale:Float = 6;

  var top:FlxSprite;
  var bot:FlxSprite;
  var rig:FlxSprite;
  var lef:FlxSprite;
  var trans:FlxSprite;

  var width:Int;
  var height:Int;

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
    if(trans!=null){
      trans.updateHitbox();
      trans.screenCenter(XY);
      if(lef!=null){
        lef.x = trans.x-(lef.width);
        lef.y = trans.y-((lef.height-trans.height)/2);
      }
      if(rig!=null){
        rig.x = trans.x+(trans.width);
        rig.y = trans.y-((rig.height-trans.height)/2);
      }
      if(bot!=null){
        bot.y = trans.y+(trans.height);
        bot.x = trans.x-((bot.width-trans.width)/2);
      }
      if(top!=null){
        top.y = trans.y-(top.height);
        top.x = trans.x-((top.width-trans.width)/2);
      }
    }
    super.update(elapsed);
  }


  override public function start(status: TransitionStatus){
    var cam = nextCamera!=null?nextCamera:(defaultCamera!=null?defaultCamera:FlxG.cameras.list[FlxG.cameras.list.length - 1]);
    cameras = [cam];

    nextCamera = null;
    trace('transitioning $status');
    curStatus=status;
    var zoom:Float = FlxMath.bound(cam.zoom,0.001);
    width = Math.ceil((cam.width)/zoom);
    height = Math.ceil((cam.height)/zoom);

    head = Paths.image(shape).bitmap;
    var black = new BitmapData(width, height, true, 0xFF000000);
    var border = new BitmapData(width*2, height*2, true, 0xFF000000);

    var shader = new BlueMaskShader();
    shader.mask.input = head; // I love over-engineering!
    // LISTEN. I thought it'd be easier to size bitmaps than it actually is
    // i was going to resize the bitmap for the transition but then that turns out isnt a thing.
    trans = new FlxSprite().loadGraphic(black);
    trans.setGraphicSize(width, height);
    trans.shader = shader;
    trans.screenCenter(XY);
    trans.scrollFactor.set();
    add(trans);

    top = new FlxSprite().loadGraphic(border);
    top.screenCenter(XY);
    top.scrollFactor.set();
    add(top);

    bot = new FlxSprite().loadGraphic(border);
    bot.screenCenter(XY);
    bot.scrollFactor.set();
    add(bot);

    lef = new FlxSprite().loadGraphic(border);
    lef.screenCenter(XY);
    lef.scrollFactor.set();
    add(lef);

    rig = new FlxSprite().loadGraphic(border);
    rig.screenCenter(XY);
    rig.scrollFactor.set();
    add(rig);


    switch(status){
      case IN:
        trans.scale.x = maxScale;
        trans.scale.y = maxScale;
        FlxTween.tween(trans.scale,{x: 0, y: 0}, time, {
          onComplete: function(t:FlxTween){
            trace("done");
            delayThenFinish();
          }
        });
      case OUT:
        trans.scale.x = 0;
        trans.scale.y = 0;
        FlxTween.tween(trans.scale,{x: maxScale, y: maxScale}, time, {
          onComplete: function(t:FlxTween){
            trace("done");
            delayThenFinish();
          }
        });
      default:
        trace("bruh");
    }


  }
}
