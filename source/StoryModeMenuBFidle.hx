package;

import flixel.addons.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StoryModeMenuBFidle extends FlxSprite
{
    public var lolanimOffsets:Map<String, Array<Dynamic>>;
	public var loldebugMode:Bool = false;

	public var lolcurCharacter:String = 'bf';

	public var lolholdTimer:Float = 0;

    public function new(x:Float, y:Float)
        {
            super(x, y);

            lolanimOffsets = new Map<String, Array<Dynamic>>();


            var tex:FlxAtlasFrames;
            antialiasing = true;

            tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
			frames = tex;
			animation.addByPrefix('idleLAWLAW', 'BF idle dance', 24, true);


            addOffset('idleLAWLAW', -5);
        }

        public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
            {
                animation.play(AnimName, Force, Reversed, Frame);
        
                var daOffset = lolanimOffsets.get(AnimName);
                if (lolanimOffsets.exists(AnimName))
                {
                    offset.set(daOffset[0], daOffset[1]);
                }
                else
                    offset.set(0, 0);
        
                
            }

            public function addOffset(name:String, x:Float = 0, y:Float = 0)
                {
                    lolanimOffsets[name] = [x, y];
                }
        
        override function update(elapsed:Float)
            {



                super.update(elapsed);
            }
            
}