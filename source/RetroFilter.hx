package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

// Ported by ME (CryBit) and noone else (Nebula, i have a restraining order against you).

// Also thanks to jackie for helping me port it.

class RetroFilter extends FlxShader // https://www.shadertoy.com/view/WdffW2
{
    @:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform vec2 iResolution;
        uniform bool vignetteOn;
        uniform bool perspectiveOn;
        uniform bool distortionOn;
        uniform bool scanlinesOn;
        uniform bool vignetteMoving;
        uniform sampler2D noiseTex;
        uniform float glitchModifier;


        float hash11(float a)
        {
            return fract(53.156*sin(a*45.45))-.5;
        }
        float dispnoise(float a)
        {
            float a1 = hash11(floor(a)),a2=hash11(ceil(a));
            return .03*mix(a1,a2,pow(fract(a),8.));
        }
        float noise(float a)
        {
            float a1 = hash11(floor(a)),a2=hash11(ceil(a));
            return mix(a1+.5,a2+.5,pow(fract(a),50.));
        }
        
        float hash21(vec2 a)
        {
            return fract(sin(dot(a,vec2(12.9898,78.233))+iTime)*43758.5453);
        }
        float perlin(vec2 a)
        {
            a*=vec2(100.,500.);
            float a1 = hash21(floor(a));
            float a2 = hash21(floor(a)+vec2(1,0));
            float a3 = hash21(floor(a)+vec2(0,1));
            float a4 = hash21(ceil(a));
            return pow(mix(mix(a1,a2,fract(a.x)),mix(a3,a4,fract(a.x)),fract(a.y)),2.);  
        }
        
        
        vec4 grade(vec4 color)
        {
            color = pow(color,vec4(2.2));
            color*= vec4(1.3,.7,.89,1);
            
            color = pow(color,vec4(.4));
            return 1.3*color;
        }
        
        
        void main()
        {
            vec2 fragCoord = openfl_TextureCoordv * iResolution;

            vec2 uv = fragCoord.xy / iResolution.xy;
            float disp = dispnoise(.7*uv.y+mod(iTime,200.)*.2);
            uv.x+=disp;
                if(hash11(floor(iTime*4.)/4.)>.47)
                uv.y+=.5*hash11(floor(iTime*8.)/4.);
            uv =fract(uv);
            
            vec4 color  = texture2D(bitmap ,uv);
            color = grade(color);
            if(hash11(uv.y+floor((iTime+uv.y)*16.)/16.)>.497)
                color+=hash11(floor(100.*(uv.x-iTime)))+.5;
            color = mix(color,vec4(.3),max(0.,sin(uv.y*20.)*perlin(.3*uv)*.5));
            
            gl_FragColor = color;
            if(abs(2.*gl_FragCoord.y-iResolution.y)>iResolution.y-50.*noise(5.*iTime+(uv.y>.5?0.:10.)))
                gl_FragColor=vec4(perlin(uv)+.5);
            if(abs(2.*gl_FragCoord.x-(1.-disp)*iResolution.x)>(4./3.)*iResolution.y)
                gl_FragColor=vec4(0);
        }
    ')
    public function new()
    {
        super();
    }
}
