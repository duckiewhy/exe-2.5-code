package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class StaticShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{

  @:glFragmentSource('
  #pragma header

  uniform float iTime;
  uniform bool vignetteOn;
  uniform bool perspectiveOn;
  uniform bool distortionOn;
  uniform bool scanlinesOn;
  uniform bool vignetteMoving;
  uniform sampler2D noiseTex;
  uniform float glitchModifier;
  uniform vec3 iResolution;
  uniform float alpha;

  float vertJerkOpt = 1.0;
  float vertMovementOpt = 1.0;
  float bottomStaticOpt = 1.0;
  float scalinesOpt = 1.0;
  float rgbOffsetOpt = 1.0;
  float horzFuzzOpt = 1.0;

  void main()
  {
      vec2 uv =  openfl_TextureCoordv.xy;
      vec2 pos=vec2(0.5+0.5*sin(iTime),uv.y);
      vec3 col=vec3(texture2D(bitmap,uv));
      vec3 col2=vec3(texture2D(bitmap,pos))*0.2;
      col+=col2;
      
      
      // Output to screen
      gl_FragColor = vec4(col,1.0);
  }

    ')
  public function new()
  {
    super();
  }
}//haMBURGERCHEESBEUBRGER!!!!!!!!
