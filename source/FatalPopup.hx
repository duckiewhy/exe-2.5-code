package;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxG;


class FatalPopup extends FlxSpriteGroup {
  public var clickDetector:FlxSprite; // i wish there was FlxSpriteGroup but for any FlxObject because that'd be better than this
  // but whatever
  public var popup:FlxSprite;
  public var onClose:Void->Void;

  var closed:Bool=false;
  public static var popups:Array<FatalPopup> = [];
  public static var limitedPopups:Array<FatalPopup> = [];

  public static var limit:Int = 10;
  public function new(x:Int=0, y:Int=0, type:Int=1, ?ignoreLimit:Bool=false){
    super(x,y);
    var scale:Float = 1.75;
    if(type==2){
      type = 1;
      ignoreLimit = true;
      scale *= 1.2;
    }
    if(type==3){
      type = 1;
      ignoreLimit = true;
      scale *= 1.5;
    }
    switch(type){
      case 1:
        clickDetector = new FlxSprite((88 + 34) * scale, (75 + 46) * scale);
				popup = new FlxSprite();
				popup.frames = Paths.getSparrowAtlas("error_popups");
				popup.animation.addByPrefix("a", "idle", 24, false);
				add(popup);
				popup.animation.play('a', true);
				popup.setGraphicSize(Std.int(popup.width * scale));
				popup.updateHitbox();
        clickDetector.makeGraphic(Std.int(32 * scale), Std.int(16 * scale), 0xFFFFFFFF);
        clickDetector.alpha = 0.000001;
				add(clickDetector);
    }

    if(!ignoreLimit){
      if(limitedPopups.length>=limit){
        for(i in 0...limitedPopups.length - limit){
          limitedPopups[0].close();
          trace("auto-closing " + i);
        }
      }
      limitedPopups.push(this);
    }

    antialiasing = ClientPrefs.globalAntialiasing;
    popups.push(this);
  }

  public function close(){
    if(closed || !alive)return;
    popups.remove(this);
    if(limitedPopups.contains(this))limitedPopups.remove(this);
    if(popup.animation.curAnim!=null){
      if(onClose!=null)onClose();
      popup.animation.reverse();
      popup.animation.callback = function(anim:String, frame:Int, idx:Int){
        if((frame+1)<=0){
          closed=true;
          kill();
        }
      }
    }
  }

  override public function update(elapsed:Float){
    if(!closed)super.update(elapsed);
    if(closed)destroy();
  }

  override public function destroy(){
    popup = null;
    clickDetector = null;
    popups.remove(this);
    if(limitedPopups.contains(this))limitedPopups.remove(this);
    super.destroy();
  }
}
