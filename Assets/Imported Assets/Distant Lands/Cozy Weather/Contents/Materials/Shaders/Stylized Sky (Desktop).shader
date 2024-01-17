// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Sky Desktop"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent-100" "IsEmissive" = "true"  }
		Cull Front
		Stencil
		{
			Ref 220
			Comp Always
			Pass Replace
		}
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 CZY_HorizonColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_ZenithColor;
		uniform float CZY_Power;
		uniform float3 CZY_SunDirection;
		uniform float CZY_SunHaloFalloff;
		uniform float4 CZY_SunHaloColor;
		uniform float4 CZY_SunFilterColor;
		uniform float4 CZY_SunColor;
		uniform float CZY_SunSize;
		uniform float3 CZY_EclipseDirection;
		uniform float3 CZY_MoonDirection;
		uniform float CZY_MoonFlareFalloff;
		uniform float4 CZY_MoonFlareColor;
		uniform sampler2D CZY_GalaxyVariationMap;
		uniform sampler2D CZY_StarMap;
		uniform sampler2D CZY_GalaxyMap;
		uniform sampler2D CZY_GalaxyStarMap;
		uniform float4 CZY_StarColor;
		uniform float4 CZY_GalaxyColor1;
		uniform float4 CZY_GalaxyColor2;
		uniform float4 CZY_GalaxyColor3;
		uniform float CZY_GalaxyMultiplier;
		uniform float CZY_RainbowSize;
		uniform float CZY_RainbowWidth;
		uniform float CZY_RainbowIntensity;
		uniform sampler2D CZY_LightScatteringMap;
		uniform float4 CZY_LightColumnColor;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 hsvTorgb2_g1 = RGBToHSV( CZY_HorizonColor.rgb );
			float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
			float4 HorizonColor497 = temp_output_10_0_g1;
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_ZenithColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 ZenithColor496 = temp_output_10_0_g2;
			float2 temp_output_493_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult495 = dot( temp_output_493_0 , temp_output_493_0 );
			float SimpleGradient494 = dotResult495;
			float GradientPos489 = ( 1.0 - saturate( pow( saturate( (0.0 + (SimpleGradient494 - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) ) , CZY_Power ) ) );
			float4 lerpResult467 = lerp( HorizonColor497 , ZenithColor496 , GradientPos489);
			float4 SimpleSkyGradient484 = lerpResult467;
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult419 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult423 = dot( normalizeResult419 , CZY_SunDirection );
			float SunDot429 = dotResult423;
			float3 hsvTorgb2_g4 = RGBToHSV( CZY_SunHaloColor.rgb );
			float3 hsvTorgb3_g4 = HSVToRGB( float3(hsvTorgb2_g4.x,saturate( ( hsvTorgb2_g4.y + CZY_FilterSaturation ) ),( hsvTorgb2_g4.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g4 = ( float4( hsvTorgb3_g4 , 0.0 ) * CZY_FilterColor );
			half4 SunFlare500 = abs( ( saturate( pow( saturate( (SunDot429*0.5 + 0.4) ) , ( ( CZY_SunHaloFalloff * 40.0 ) + 5.0 ) ) ) * ( temp_output_10_0_g4 * CZY_SunFilterColor ) ) );
			float3 normalizeResult590 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult591 = dot( normalizeResult590 , CZY_EclipseDirection );
			float EclipseDot594 = dotResult591;
			float eclipse565 = ( ( 1.0 - EclipseDot594 ) > ( pow( CZY_SunSize , 3.0 ) * 0.0006 ) ? 0.0 : 1.0 );
			float4 SunRender576 = ( CZY_SunColor * saturate( ( ( ( 1.0 - SunDot429 ) > ( pow( CZY_SunSize , 3.0 ) * 0.0007 ) ? 0.0 : 1.0 ) - eclipse565 ) ) );
			float3 normalizeResult584 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult585 = dot( normalizeResult584 , CZY_MoonDirection );
			float MoonDot597 = dotResult585;
			float3 hsvTorgb2_g3 = RGBToHSV( CZY_MoonFlareColor.rgb );
			float3 hsvTorgb3_g3 = HSVToRGB( float3(hsvTorgb2_g3.x,saturate( ( hsvTorgb2_g3.y + CZY_FilterSaturation ) ),( hsvTorgb2_g3.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g3 = ( float4( hsvTorgb3_g3 , 0.0 ) * CZY_FilterColor );
			half4 MoonFlare410 = abs( ( saturate( pow( saturate( (MoonDot597*0.5 + 0.4) ) , ( ( CZY_MoonFlareFalloff * 20.0 ) + 5.0 ) ) ) * temp_output_10_0_g3 ) );
			float2 Pos374 = i.uv_texcoord;
			float mulTime398 = _Time.y * 0.005;
			float cos375 = cos( mulTime398 );
			float sin375 = sin( mulTime398 );
			float2 rotator375 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos375 , -sin375 , sin375 , cos375 )) + float2( 0.5,0.5 );
			float mulTime393 = _Time.y * -0.02;
			float simplePerlin2D376 = snoise( (Pos374*5.0 + mulTime393) );
			simplePerlin2D376 = simplePerlin2D376*0.5 + 0.5;
			float StarPlacementPattern528 = saturate( ( min( tex2D( CZY_GalaxyVariationMap, (Pos374*5.0 + mulTime398) ).r , tex2D( CZY_GalaxyVariationMap, (rotator375*2.0 + 0.0) ).r ) * simplePerlin2D376 * (0.2 + (SimpleGradient494 - 0.0) * (0.0 - 0.2) / (1.0 - 0.0)) ) );
			float2 panner402 = ( 1.0 * _Time.y * float2( 0.0007,0 ) + Pos374);
			float mulTime432 = _Time.y * 0.001;
			float cos414 = cos( mulTime432 );
			float sin414 = sin( mulTime432 );
			float2 rotator414 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos414 , -sin414 , sin414 , cos414 )) + float2( 0.5,0.5 );
			float temp_output_417_0 = min( tex2D( CZY_StarMap, (panner402*4.0 + mulTime432) ).r , tex2D( CZY_GalaxyVariationMap, (rotator414*0.1 + 0.0) ).r );
			float2 panner366 = ( 1.0 * _Time.y * float2( 0.0007,0 ) + Pos374);
			float mulTime370 = _Time.y * 0.005;
			float2 panner371 = ( 1.0 * _Time.y * float2( 0.001,0 ) + Pos374);
			float mulTime368 = _Time.y * 0.005;
			float cos367 = cos( mulTime368 );
			float sin367 = sin( mulTime368 );
			float2 rotator367 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos367 , -sin367 , sin367 , cos367 )) + float2( 0.5,0.5 );
			float2 panner373 = ( mulTime368 * float2( 0.004,0 ) + rotator367);
			float2 GalaxyPos420 = panner373;
			float GalaxyPattern549 = saturate( ( min( (0.3 + (tex2D( CZY_GalaxyVariationMap, (panner366*4.0 + mulTime370) ).r - 0.0) * (1.0 - 0.3) / (0.8 - 0.0)) , (0.3 + (( 1.0 - tex2D( CZY_GalaxyVariationMap, (panner371*3.0 + mulTime370) ).r ) - 0.0) * (1.0 - 0.3) / (1.0 - 0.0)) ) * (0.3 + (SimpleGradient494 - 0.0) * (-0.2 - 0.3) / (0.2 - 0.0)) * tex2D( CZY_GalaxyMap, GalaxyPos420 ).r ) );
			float4 break437 = MoonFlare410;
			float StarPattern447 = ( ( ( StarPlacementPattern528 * temp_output_417_0 ) + ( temp_output_417_0 * GalaxyPattern549 ) + ( tex2D( CZY_GalaxyStarMap, GalaxyPos420 ).r * 0.2 ) ) * ( 1.0 - ( break437.r + break437.g + break437.b + break437.a ) ) );
			float cos557 = cos( 0.002 * _Time.y );
			float sin557 = sin( 0.002 * _Time.y );
			float2 rotator557 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos557 , -sin557 , sin557 , cos557 )) + float2( 0.5,0.5 );
			float cos556 = cos( 0.004 * _Time.y );
			float sin556 = sin( 0.004 * _Time.y );
			float2 rotator556 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos556 , -sin556 , sin556 , cos556 )) + float2( 0.5,0.5 );
			float cos558 = cos( 0.001 * _Time.y );
			float sin558 = sin( 0.001 * _Time.y );
			float2 rotator558 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos558 , -sin558 , sin558 , cos558 )) + float2( 0.5,0.5 );
			float4 appendResult400 = (float4(tex2D( CZY_GalaxyVariationMap, (rotator557*10.0 + 0.0) ).r , tex2D( CZY_GalaxyVariationMap, (rotator556*8.0 + 2.04) ).r , tex2D( CZY_GalaxyVariationMap, (rotator558*6.0 + 2.04) ).r , 1.0));
			float4 GalaxyColoring426 = appendResult400;
			float4 break481 = GalaxyColoring426;
			float4 FinalGalaxyColoring546 = ( ( CZY_GalaxyColor1 * break481.r ) + ( CZY_GalaxyColor2 * break481.g ) + ( CZY_GalaxyColor3 * break481.b ) );
			float4 GalaxyFullColor477 = ( saturate( ( StarPattern447 * CZY_StarColor ) ) + ( GalaxyPattern549 * FinalGalaxyColoring546 * CZY_GalaxyMultiplier ) );
			Gradient gradient452 = NewGradient( 0, 8, 4, float4( 1, 0, 0, 0.1205921 ), float4( 1, 0.3135593, 0, 0.2441138 ), float4( 1, 0.8774895, 0.2216981, 0.3529412 ), float4( 0.3030533, 1, 0.2877358, 0.4529488 ), float4( 0.3726415, 1, 0.9559749, 0.5529412 ), float4( 0.4669811, 0.7253776, 1, 0.6470588 ), float4( 0.1561944, 0.3586135, 0.735849, 0.802945 ), float4( 0.2576377, 0.08721964, 0.5283019, 0.9264668 ), float2( 0, 0 ), float2( 0, 0.08235294 ), float2( 0.6039216, 0.8264744 ), float2( 0, 1 ), 0, 0, 0, 0 );
			float temp_output_443_0 = ( 1.0 - SunDot429 );
			float temp_output_448_0 = ( CZY_RainbowSize * 0.01 );
			float temp_output_453_0 = ( temp_output_448_0 + ( CZY_RainbowWidth * 0.01 ) );
			float4 RainbowClipping469 = ( SampleGradient( gradient452, (0.0 + (temp_output_443_0 - temp_output_448_0) * (1.0 - 0.0) / (temp_output_453_0 - temp_output_448_0)) ) * ( ( temp_output_443_0 < temp_output_448_0 ? 0.0 : 1.0 ) * ( temp_output_443_0 > temp_output_453_0 ? 0.0 : 1.0 ) ) * SampleGradient( gradient452, (0.0 + (temp_output_443_0 - temp_output_448_0) * (1.0 - 0.0) / (temp_output_453_0 - temp_output_448_0)) ).a * CZY_RainbowIntensity );
			float cos427 = cos( -0.005 * _Time.y );
			float sin427 = sin( -0.005 * _Time.y );
			float2 rotator427 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos427 , -sin427 , sin427 , cos427 )) + float2( 0.5,0.5 );
			float cos424 = cos( 0.01 * _Time.y );
			float sin424 = sin( 0.01 * _Time.y );
			float2 rotator424 = mul( Pos374 - float2( 0.5,0.5 ) , float2x2( cos424 , -sin424 , sin424 , cos424 )) + float2( 0.5,0.5 );
			float4 transform542 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float saferPower544 = abs( ( ( abs( transform542.y ) * 0.03 ) + -0.3 ) );
			float LightColumnsPattern450 = saturate( ( min( tex2D( CZY_LightScatteringMap, rotator427 ).r , tex2D( CZY_LightScatteringMap, rotator424 ).r ) * (1.0 + (saturate( pow( saferPower544 , 1.0 ) ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) );
			float4 LightColumnsColor471 = ( LightColumnsPattern450 * CZY_LightColumnColor );
			o.Emission = ( SimpleSkyGradient484 + SunFlare500 + SunRender576 + MoonFlare410 + GalaxyFullColor477 + RainbowClipping469 + LightColumnsColor471 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;104.1543,85.88161;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Sky Desktop;False;False;False;False;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;Front;0;False;;7;False;;False;0;False;;0;False;;True;0;Translucent;0.5;True;False;-100;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;True;220;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;358;-1696,-1632;Inherit;False;999.7085;277.6771;;6;595;581;578;577;565;564;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;359;-4128,-336;Inherit;False;2040.225;680.2032;;27;597;596;594;593;592;591;590;589;588;587;586;585;584;583;582;562;526;525;521;520;517;503;425;410;399;390;388;Moon Block;0.514151,0.9898598,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;360;-4160,512;Inherit;False;2156.234;658.7953;;16;511;510;509;482;469;465;462;460;459;453;452;451;448;443;442;438;Rainbow Block;1,0.9770144,0.5137255,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;361;-4128,-1168;Inherit;False;2385.535;665.2547;;32;580;579;576;575;574;573;572;571;570;569;568;567;566;563;561;560;559;524;523;522;504;500;499;498;464;454;429;423;419;408;403;401;Sun Block;0.514151,0.9898598,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;362;-4096,-2272;Inherit;False;2319.161;920.8362;;25;518;506;505;502;501;497;496;495;494;493;492;491;490;489;488;487;486;485;420;396;374;373;368;367;365;Variable Declaration;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;363;16,-2288;Inherit;False;2833.51;1041.92;;29;554;553;552;550;549;548;547;531;508;507;480;477;468;461;457;455;415;409;395;392;387;382;380;379;372;371;370;369;366;Galaxy Pattern;1,0.5235849,0.5235849,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;364;416,-3264;Inherit;False;2059.286;778.0105;;23;551;533;532;527;449;447;437;436;435;434;433;432;431;430;428;422;418;417;414;406;405;402;391;Stars;1,0.7345774,0.5254902,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;365;-4000,-2096;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;366;304,-2176;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.0007,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;367;-3792,-1552;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;368;-3984,-1472;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;370;48,-2016;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;371;304,-1984;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.001,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;48,-2096;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;373;-3600,-1552;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.004,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;374;-3792,-2112;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;375;3744,-2720;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;376;4208,-2528;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;3552,-2848;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;378;3920,-2720;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;379;1296,-2032;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;380;976,-1952;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;4096,-2384;Inherit;False;494;SimpleGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;382;992,-2144;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;3;FLOAT;0.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;3776,-1440;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;384;4016,-2528;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;3776,-1232;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;386;3856,-2528;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;387;928,-1776;Inherit;False;494;SimpleGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;388;-3424,-224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;389;3856,-2912;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;-3152,-240;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;391;480,-3056;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;392;1120,-1776;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0.3;False;4;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;393;3808,-2448;Inherit;False;1;0;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;394;4400,-2832;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;395;1120,-1952;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.3;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-3984,-1552;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;3776,-1040;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;398;3552,-2768;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;399;-3008,-240;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;400;4704,-1296;Inherit;False;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;401;-4080,-736;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;402;672,-3136;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.0007,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;403;-4016,-880;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;404;4144,-1040;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;6;False;2;FLOAT;2.04;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;405;848,-2928;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;406;848,-3136;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;407;4704,-2720;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;408;-3824,-816;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;409;1584,-1760;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;-2880,-240;Half;False;MoonFlare;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;411;4288,-2384;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;412;4144,-1440;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;413;4144,-1232;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;8;False;2;FLOAT;2.04;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;414;672,-2928;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;1456,-1760;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;416;4576,-2720;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;417;1344,-3040;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;1392,-2880;Inherit;False;549;GalaxyPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;419;-3696,-816;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;420;-3424,-1552;Inherit;False;GalaxyPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;421;2128,-496;Inherit;False;374;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;1376,-3200;Inherit;False;528;StarPlacementPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;423;-3536,-816;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;424;2400,-384;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.01;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;425;-3568,-224;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;4864,-1296;Inherit;False;GalaxyColoring;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;427;2400,-544;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;-0.005;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;428;1616,-2992;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;429;-3376,-816;Inherit;False;SunDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;430;1984,-2880;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;431;1776,-3056;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;432;480,-2976;Inherit;False;1;0;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;1600,-2880;Inherit;False;410;MoonFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;1872,-2880;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;1616,-3088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;1360,-2752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;437;1760,-2880;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;438;-3840,992;Inherit;False;429;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;3392,-1760;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;440;3216,-368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;3392,-1504;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-3872,880;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;443;-3648,992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;3392,-1632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;445;2064,528;Inherit;False;450;LightColumnsPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;2272,-3056;Inherit;True;StarPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;448;-3872,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;2144,-3056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;3488,-368;Inherit;False;LightColumnsPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;451;-2960,736;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;452;-3008,608;Inherit;False;0;8;4;1,0,0,0.1205921;1,0.3135593,0,0.2441138;1,0.8774895,0.2216981,0.3529412;0.3030533,1,0.2877358,0.4529488;0.3726415,1,0.9559749,0.5529412;0.4669811,0.7253776,1,0.6470588;0.1561944,0.3586135,0.735849,0.802945;0.2576377,0.08721964,0.5283019,0.9264668;0,0;0,0.08235294;0.6039216,0.8264744;0,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;453;-3728,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;454;-3552,-1072;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;455;2224,-2048;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-704,-976;Inherit;False;497;HorizonColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;2336,-1744;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;458;3344,-368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;459;-3424,768;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;-3216,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;2144,-1808;Inherit;False;549;GalaxyPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;462;-3424,928;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;463;3616,-1648;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;464;-3392,-1072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;-2416,832;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;466;2336,560;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;467;-432,-896;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;468;2496,-1888;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;469;-2240,832;Inherit;False;RainbowClipping;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;470;-688,-896;Inherit;False;496;ZenithColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;471;2496,560;Inherit;False;LightColumnsColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;-496,96;Inherit;False;576;SunRender;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;-496,176;Inherit;False;410;MoonFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;474;-544,320;Inherit;False;469;RainbowClipping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;475;-480,16;Inherit;False;500;SunFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;476;-544,400;Inherit;False;471;LightColumnsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;477;2624,-1904;Inherit;False;GalaxyFullColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;478;-528,-64;Inherit;False;484;SimpleSkyGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;479;-528,256;Inherit;False;477;GalaxyFullColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;480;2368,-2048;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;481;3120,-1312;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GradientSampleNode;482;-2752,688;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;483;-272,80;Inherit;False;7;7;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;484;-240,-896;Inherit;False;SimpleSkyGradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;485;-3008,-1568;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;486;-2736,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;487;-3216,-1568;Inherit;False;494;SimpleGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;488;-2432,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;489;-2128,-1568;Inherit;False;GradientPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;490;-2288,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;491;-2576,-1568;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;492;-4000,-1792;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;493;-3792,-1792;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;494;-3408,-1792;Inherit;False;SimpleGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;495;-3600,-1792;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-3200,-1984;Inherit;False;ZenithColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;497;-3184,-2176;Inherit;False;HorizonColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;-2976,-1072;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;499;-2848,-1072;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;-2720,-1072;Half;False;SunFlare;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;501;-3376,-2176;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;502;-3392,-1984;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;503;-3360,-128;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;504;-3184,-1008;Inherit;False;Filter Color;-1;;4;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;505;-3600,-2176;Inherit;False;Global;CZY_HorizonColor;CZY_HorizonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6399965,0.9474089,0.9622642,0;0.02745098,0.09019608,0.1215686,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;506;-3600,-1984;Inherit;False;Global;CZY_ZenithColor;CZY_ZenithColor;4;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.4000979,0.6638572,0.764151,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;507;2016,-1984;Inherit;False;Global;CZY_StarColor;CZY_StarColor;18;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;16,16,16,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;508;2048,-1648;Inherit;False;Global;CZY_GalaxyMultiplier;CZY_GalaxyMultiplier;20;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;509;-2736,912;Inherit;False;Global;CZY_RainbowIntensity;CZY_RainbowIntensity;21;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;-4048,768;Inherit;False;Global;CZY_RainbowSize;CZY_RainbowSize;8;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;-4064,880;Inherit;False;Global;CZY_RainbowWidth;CZY_RainbowWidth;7;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;512;2064,640;Inherit;False;Global;CZY_LightColumnColor;CZY_LightColumnColor;19;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;0.04927626,0.6960272,1.176471,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;513;3040,-1488;Inherit;False;Global;CZY_GalaxyColor3;CZY_GalaxyColor3;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6399965,0.9474089,0.9622642,0;0.3537736,0.6836287,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;514;3040,-1664;Inherit;False;Global;CZY_GalaxyColor2;CZY_GalaxyColor2;2;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6399965,0.9474089,0.9622642,0;0.4681289,0.4470588,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;515;3040,-1840;Inherit;False;Global;CZY_GalaxyColor1;CZY_GalaxyColor1;3;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6399965,0.9474089,0.9622642,0;0.110582,0.2331686,0.6698113,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;516;2976,-480;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;517;-3568,-128;Inherit;False;Global;CZY_MoonFlareColor;CZY_MoonFlareColor;9;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.355693,0.4595688,0.4802988,1;0.02352941,0.08627451,0.1490196,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;518;-2736,-1488;Inherit;False;Global;CZY_Power;CZY_Power;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0.574;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;-688,-800;Inherit;False;489;GradientPos;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;520;-3904,-224;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;521;-3712,-224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;522;-3680,-1104;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;523;-3872,-1104;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;-4064,-1104;Inherit;False;429;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-3856,-96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;526;-3712,-96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;4848,-2720;Inherit;False;StarPlacementPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;532;1024,-3152;Inherit;True;Global;CZY_StarMap;CZY_StarMap;0;0;Create;True;0;0;0;False;0;False;-1;610adfdc91abe6e49a06f9b16aaeed7e;610adfdc91abe6e49a06f9b16aaeed7e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;533;1056,-2752;Inherit;True;Global;CZY_GalaxyStarMap;CZY_GalaxyStarMap;3;0;Create;True;0;0;0;False;0;False;-1;831ed62fbc9349041bf2404184ed2461;831ed62fbc9349041bf2404184ed2461;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;538;1712,-144;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;539;2048,-144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;540;2192,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.03;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;541;2640,-144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;542;1872,-144;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;543;2784,-144;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;544;2480,-144;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;545;2336,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;546;3760,-1648;Inherit;False;FinalGalaxyColoring;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;547;496,-1984;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;548;496,-2176;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;549;1712,-1760;Inherit;False;GalaxyPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;550;1792,-2080;Inherit;True;447;StarPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;551;896,-2752;Inherit;False;420;GalaxyPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;552;1120,-1616;Inherit;True;Global;CZY_GalaxyMap;CZY_GalaxyMap;4;0;Create;True;0;0;0;False;0;False;-1;9e328e1f846025e47ad7a9f00ca77f9b;9e328e1f846025e47ad7a9f00ca77f9b;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;553;928,-1616;Inherit;False;420;GalaxyPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;554;2096,-1712;Inherit;False;546;FinalGalaxyColoring;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;555;2896,-1280;Inherit;False;426;GalaxyColoring;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;556;3952,-1232;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.004;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;557;3952,-1440;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.002;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;558;3952,-1040;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.001;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;-3824,-976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;40;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;560;-3680,-976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;-4048,-976;Inherit;False;Global;CZY_SunHaloFalloff;CZY_SunHaloFalloff;6;0;Create;False;0;0;0;False;0;False;0.5;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;562;-4080,-224;Inherit;False;597;MoonDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;563;-3008,-736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0007;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;564;-1104,-1552;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;565;-928,-1552;Inherit;False;eclipse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;566;-3168,-816;Inherit;False;429;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;567;-3008,-816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;568;-3184,-736;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;569;-3392,-736;Inherit;False;Global;CZY_SunSize;CZY_SunSize;10;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;570;-2816,-784;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-2816,-640;Inherit;False;565;eclipse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;572;-2624,-752;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;573;-2480,-752;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;574;-2544,-928;Inherit;False;Global;CZY_SunColor;CZY_SunColor;13;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;10.43295,10.43295,10.43295,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;575;-2272,-800;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;576;-2128,-800;Inherit;False;SunRender;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;577;-1296,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;578;-1440,-1488;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;579;-3744,-688;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;5;0;Create;True;0;0;0;False;0;False;0,0,0;-0.5008489,-0.7973944,-0.3366193;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;580;-3392,-1008;Inherit;False;Global;CZY_SunHaloColor;CZY_SunHaloColor;8;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.355693,0.4595688,0.4802988,1;0.1021271,0.1492821,0.1603774,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;581;-1280,-1488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0006;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;582;-4096,-96;Float;False;Global;CZY_MoonFlareFalloff;CZY_MoonFlareFalloff;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.752;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;583;-3792,48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;584;-3664,48;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;585;-3488,64;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;586;-3968,0;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;587;-4032,144;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;588;-3728,160;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;12;0;Create;True;0;0;0;False;0;False;0,0,0;0.2042888,-0.9751408,-0.08582935;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;589;-2848,48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;590;-2720,48;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;591;-2544,48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;592;-3024,-16;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;593;-3088,128;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;-2400,48;Inherit;False;EclipseDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;595;-1488,-1568;Inherit;False;594;EclipseDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;596;-2784,160;Inherit;False;Global;CZY_EclipseDirection;CZY_EclipseDirection;12;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;597;-3344,48;Inherit;False;MoonDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;531;688,-2176;Inherit;True;Global;CZY_GalaxyVariationMap;CZY_GalaxyVariationMap;2;0;Create;True;0;0;0;False;0;False;-1;638cc442ec8c58c4fa3027cb13d4c95c;638cc442ec8c58c4fa3027cb13d4c95c;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;369;688,-1984;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;529;4096,-2944;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;530;4096,-2752;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;446;2672,-400;Inherit;True;Property;_TextureSample9;Texture Sample 9;1;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;534;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;534;2672,-592;Inherit;True;Global;CZY_LightScatteringMap;CZY_LightScatteringMap;1;0;Create;True;0;0;0;False;0;False;-1;cd724bd74f795ff4ba24bfa98a6c9cd8;cd724bd74f795ff4ba24bfa98a6c9cd8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;535;4352,-1440;Inherit;True;Property;_TextureSample6;Texture Sample 6;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;536;4336,-1232;Inherit;True;Property;_TextureSample7;Texture Sample 7;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;537;4352,-1040;Inherit;True;Property;_TextureSample8;Texture Sample 8;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;527;1024,-2960;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;531;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;0;2;483;0
WireConnection;366;0;372;0
WireConnection;367;0;396;0
WireConnection;367;2;368;0
WireConnection;371;0;372;0
WireConnection;373;0;367;0
WireConnection;373;1;368;0
WireConnection;374;0;365;0
WireConnection;375;0;377;0
WireConnection;375;2;398;0
WireConnection;376;0;384;0
WireConnection;378;0;375;0
WireConnection;379;0;382;0
WireConnection;379;1;395;0
WireConnection;380;0;369;1
WireConnection;382;0;531;1
WireConnection;384;0;386;0
WireConnection;384;2;393;0
WireConnection;388;0;425;0
WireConnection;389;0;377;0
WireConnection;389;2;398;0
WireConnection;390;0;388;0
WireConnection;390;1;503;0
WireConnection;392;0;387;0
WireConnection;394;0;529;1
WireConnection;394;1;530;1
WireConnection;395;0;380;0
WireConnection;399;0;390;0
WireConnection;400;0;535;1
WireConnection;400;1;536;1
WireConnection;400;2;537;1
WireConnection;402;0;391;0
WireConnection;404;0;558;0
WireConnection;405;0;414;0
WireConnection;406;0;402;0
WireConnection;406;2;432;0
WireConnection;407;0;416;0
WireConnection;408;0;403;0
WireConnection;408;1;401;0
WireConnection;409;0;415;0
WireConnection;410;0;399;0
WireConnection;411;0;381;0
WireConnection;412;0;557;0
WireConnection;413;0;556;0
WireConnection;414;0;391;0
WireConnection;414;2;432;0
WireConnection;415;0;379;0
WireConnection;415;1;392;0
WireConnection;415;2;552;1
WireConnection;416;0;394;0
WireConnection;416;1;376;0
WireConnection;416;2;411;0
WireConnection;417;0;532;1
WireConnection;417;1;527;1
WireConnection;419;0;408;0
WireConnection;420;0;373;0
WireConnection;423;0;419;0
WireConnection;423;1;579;0
WireConnection;424;0;421;0
WireConnection;425;0;521;0
WireConnection;425;1;526;0
WireConnection;426;0;400;0
WireConnection;427;0;421;0
WireConnection;428;0;417;0
WireConnection;428;1;418;0
WireConnection;429;0;423;0
WireConnection;430;0;434;0
WireConnection;431;0;435;0
WireConnection;431;1;428;0
WireConnection;431;2;436;0
WireConnection;434;0;437;0
WireConnection;434;1;437;1
WireConnection;434;2;437;2
WireConnection;434;3;437;3
WireConnection;435;0;422;0
WireConnection;435;1;417;0
WireConnection;436;0;533;1
WireConnection;437;0;433;0
WireConnection;439;0;515;0
WireConnection;439;1;481;0
WireConnection;440;0;516;0
WireConnection;440;1;543;0
WireConnection;441;0;513;0
WireConnection;441;1;481;2
WireConnection;442;0;511;0
WireConnection;443;0;438;0
WireConnection;444;0;514;0
WireConnection;444;1;481;1
WireConnection;447;0;449;0
WireConnection;448;0;510;0
WireConnection;449;0;431;0
WireConnection;449;1;430;0
WireConnection;450;0;458;0
WireConnection;451;0;443;0
WireConnection;451;1;448;0
WireConnection;451;2;453;0
WireConnection;453;0;448;0
WireConnection;453;1;442;0
WireConnection;454;0;522;0
WireConnection;454;1;560;0
WireConnection;455;0;550;0
WireConnection;455;1;507;0
WireConnection;457;0;461;0
WireConnection;457;1;554;0
WireConnection;457;2;508;0
WireConnection;458;0;440;0
WireConnection;459;0;443;0
WireConnection;459;1;448;0
WireConnection;460;0;459;0
WireConnection;460;1;462;0
WireConnection;462;0;443;0
WireConnection;462;1;453;0
WireConnection;463;0;439;0
WireConnection;463;1;444;0
WireConnection;463;2;441;0
WireConnection;464;0;454;0
WireConnection;465;0;482;0
WireConnection;465;1;460;0
WireConnection;465;2;482;4
WireConnection;465;3;509;0
WireConnection;466;0;445;0
WireConnection;466;1;512;0
WireConnection;467;0;456;0
WireConnection;467;1;470;0
WireConnection;467;2;519;0
WireConnection;468;0;480;0
WireConnection;468;1;457;0
WireConnection;469;0;465;0
WireConnection;471;0;466;0
WireConnection;477;0;468;0
WireConnection;480;0;455;0
WireConnection;481;0;555;0
WireConnection;482;0;452;0
WireConnection;482;1;451;0
WireConnection;483;0;478;0
WireConnection;483;1;475;0
WireConnection;483;2;472;0
WireConnection;483;3;473;0
WireConnection;483;4;479;0
WireConnection;483;5;474;0
WireConnection;483;6;476;0
WireConnection;484;0;467;0
WireConnection;485;0;487;0
WireConnection;486;0;485;0
WireConnection;488;0;491;0
WireConnection;489;0;490;0
WireConnection;490;0;488;0
WireConnection;491;0;486;0
WireConnection;491;1;518;0
WireConnection;493;0;492;0
WireConnection;494;0;495;0
WireConnection;495;0;493;0
WireConnection;495;1;493;0
WireConnection;496;0;502;0
WireConnection;497;0;501;0
WireConnection;498;0;464;0
WireConnection;498;1;504;0
WireConnection;499;0;498;0
WireConnection;500;0;499;0
WireConnection;501;1;505;0
WireConnection;502;1;506;0
WireConnection;503;1;517;0
WireConnection;504;1;580;0
WireConnection;516;0;534;1
WireConnection;516;1;446;1
WireConnection;520;0;562;0
WireConnection;521;0;520;0
WireConnection;522;0;523;0
WireConnection;523;0;524;0
WireConnection;525;0;582;0
WireConnection;526;0;525;0
WireConnection;528;0;407;0
WireConnection;532;1;406;0
WireConnection;533;1;551;0
WireConnection;539;0;542;2
WireConnection;540;0;539;0
WireConnection;541;0;544;0
WireConnection;542;0;538;0
WireConnection;543;0;541;0
WireConnection;544;0;545;0
WireConnection;545;0;540;0
WireConnection;546;0;463;0
WireConnection;547;0;371;0
WireConnection;547;2;370;0
WireConnection;548;0;366;0
WireConnection;548;2;370;0
WireConnection;549;0;409;0
WireConnection;552;1;553;0
WireConnection;556;0;385;0
WireConnection;557;0;383;0
WireConnection;558;0;397;0
WireConnection;559;0;561;0
WireConnection;560;0;559;0
WireConnection;563;0;568;0
WireConnection;564;0;577;0
WireConnection;564;1;581;0
WireConnection;565;0;564;0
WireConnection;567;0;566;0
WireConnection;568;0;569;0
WireConnection;570;0;567;0
WireConnection;570;1;563;0
WireConnection;572;0;570;0
WireConnection;572;1;571;0
WireConnection;573;0;572;0
WireConnection;575;0;574;0
WireConnection;575;1;573;0
WireConnection;576;0;575;0
WireConnection;577;0;595;0
WireConnection;578;0;569;0
WireConnection;581;0;578;0
WireConnection;583;0;586;0
WireConnection;583;1;587;0
WireConnection;584;0;583;0
WireConnection;585;0;584;0
WireConnection;585;1;588;0
WireConnection;589;0;592;0
WireConnection;589;1;593;0
WireConnection;590;0;589;0
WireConnection;591;0;590;0
WireConnection;591;1;596;0
WireConnection;594;0;591;0
WireConnection;597;0;585;0
WireConnection;531;1;548;0
WireConnection;369;1;547;0
WireConnection;529;1;389;0
WireConnection;530;1;378;0
WireConnection;446;1;424;0
WireConnection;534;1;427;0
WireConnection;535;1;412;0
WireConnection;536;1;413;0
WireConnection;537;1;404;0
WireConnection;527;1;405;0
ASEEND*/
//CHKSM=68A8668CC44997E1C5717F070B21248444B7EBFD