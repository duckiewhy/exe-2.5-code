package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

// wooo I made this :] -Neb

class BlueMaskShader extends FlxShader
{

  @:glFragmentSource('
    #pragma header
    uniform sampler2D mask;
    void main()
    {
    	vec2 uv = openfl_TextureCoordv;

    	vec4 base = flixel_texture2D(bitmap, uv);
      vec4 mask = flixel_texture2D(mask, uv);
    	float alpha = 1.0 - (mask.b * mask.a);

    	gl_FragColor = vec4(base.rgb*alpha*base.a, alpha*base.a);
    }

  ')
  public function new()
  {
    super();
  }
}
