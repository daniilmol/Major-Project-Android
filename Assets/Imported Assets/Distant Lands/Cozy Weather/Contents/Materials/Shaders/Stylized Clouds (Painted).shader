// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Painted"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent-50" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		Stencil
		{
			Ref 221
			Comp Always
			Pass Replace
		}
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 CZY_CloudColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_CloudFilterColor;
		uniform float4 CZY_CloudHighlightColor;
		uniform float4 CZY_SunFilterColor;
		uniform float CZY_WindSpeed;
		uniform float CZY_MainCloudScale;
		uniform float CZY_CumulusCoverageMultiplier;
		uniform float3 CZY_SunDirection;
		uniform half CZY_SunFlareFalloff;
		uniform float3 CZY_MoonDirection;
		uniform half CZY_MoonFlareFalloff;
		uniform float4 CZY_CloudMoonColor;
		uniform float CZY_DetailScale;
		uniform float CZY_DetailAmount;
		uniform float CZY_BorderHeight;
		uniform float CZY_BorderVariation;
		uniform float CZY_BorderEffect;
		uniform float3 CZY_StormDirection;
		uniform float CZY_NimbusHeight;
		uniform float CZY_NimbusMultiplier;
		uniform float CZY_NimbusVariation;
		uniform sampler2D CZY_ChemtrailsTexture;
		uniform float CZY_ChemtrailsMoveSpeed;
		uniform float CZY_ChemtrailsMultiplier;
		uniform sampler2D CZY_CirrusTexture;
		uniform float CZY_CirrusMoveSpeed;
		uniform float CZY_CirrusMultiplier;
		uniform sampler2D CZY_CloudTexture;
		uniform float4 CZY_AltoCloudColor;
		uniform float CZY_AltocumulusScale;
		uniform float2 CZY_AltocumulusWindSpeed;
		uniform float CZY_AltocumulusMultiplier;
		uniform sampler2D CZY_CirrostratusTexture;
		uniform float CZY_CirrostratusMoveSpeed;
		uniform float CZY_CirrostratusMultiplier;
		uniform float CZY_ClippingThreshold;
		uniform float4 CZY_CloudTextureColor;
		uniform float4 CZY_LightColor;
		uniform float CZY_TextureAmount;
		uniform float CZY_CloudThickness;


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


		float2 voronoihash20( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi20( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash20( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return (F2 + F1) * 0.5;
		}


		float2 voronoihash23( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi23( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash23( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return (F2 + F1) * 0.5;
		}


		float2 voronoihash32( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi32( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash32( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		float2 voronoihash120( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi120( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash120( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return (F2 + F1) * 0.5;
		}


		float2 voronoihash158( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi158( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash158( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		float2 voronoihash182( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi182( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash182( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 hsvTorgb2_g3 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g3 = HSVToRGB( float3(hsvTorgb2_g3.x,saturate( ( hsvTorgb2_g3.y + CZY_FilterSaturation ) ),( hsvTorgb2_g3.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g3 = ( float4( hsvTorgb3_g3 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor358 = ( temp_output_10_0_g3 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 CloudHighlightColor357 = ( temp_output_10_0_g2 * CZY_SunFilterColor );
			float2 Pos10 = i.uv_texcoord;
			float mulTime4 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float TIme6 = mulTime4;
			float simplePerlin2D47 = snoise( ( Pos10 + ( TIme6 * float2( 0.2,-0.4 ) ) )*( 100.0 / CZY_MainCloudScale ) );
			simplePerlin2D47 = simplePerlin2D47*0.5 + 0.5;
			float SimpleCloudDensity52 = simplePerlin2D47;
			float time20 = 0.0;
			float2 voronoiSmoothId20 = 0;
			float2 temp_output_18_0 = ( Pos10 + ( TIme6 * float2( 0.3,0.2 ) ) );
			float2 coords20 = temp_output_18_0 * ( 140.0 / CZY_MainCloudScale );
			float2 id20 = 0;
			float2 uv20 = 0;
			float voroi20 = voronoi20( coords20, time20, id20, uv20, 0, voronoiSmoothId20 );
			float time23 = 0.0;
			float2 voronoiSmoothId23 = 0;
			float2 coords23 = temp_output_18_0 * ( 500.0 / CZY_MainCloudScale );
			float2 id23 = 0;
			float2 uv23 = 0;
			float voroi23 = voronoi23( coords23, time23, id23, uv23, 0, voronoiSmoothId23 );
			float2 appendResult25 = (float2(voroi20 , voroi23));
			float2 VoroDetails33 = appendResult25;
			float CumulusCoverage48 = CZY_CumulusCoverageMultiplier;
			float ComplexCloudDensity105 = (0.0 + (min( SimpleCloudDensity52 , ( 1.0 - VoroDetails33.x ) ) - ( 1.0 - CumulusCoverage48 )) * (1.0 - 0.0) / (1.0 - ( 1.0 - CumulusCoverage48 )));
			float4 lerpResult270 = lerp( CloudHighlightColor357 , CloudColor358 , saturate( (2.0 + (ComplexCloudDensity105 - 0.0) * (0.7 - 2.0) / (1.0 - 0.0)) ));
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult288 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult321 = dot( normalizeResult288 , CZY_SunDirection );
			float temp_output_285_0 = abs( (dotResult321*0.5 + 0.5) );
			half LightMask355 = saturate( pow( temp_output_285_0 , CZY_SunFlareFalloff ) );
			float CloudThicknessDetails347 = ( VoroDetails33.x * saturate( ( CumulusCoverage48 - 0.8 ) ) );
			float3 normalizeResult290 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult293 = dot( normalizeResult290 , CZY_MoonDirection );
			half MoonlightMask308 = saturate( pow( abs( (dotResult293*0.5 + 0.5) ) , CZY_MoonFlareFalloff ) );
			float3 hsvTorgb2_g4 = RGBToHSV( CZY_CloudMoonColor.rgb );
			float3 hsvTorgb3_g4 = HSVToRGB( float3(hsvTorgb2_g4.x,saturate( ( hsvTorgb2_g4.y + CZY_FilterSaturation ) ),( hsvTorgb2_g4.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g4 = ( float4( hsvTorgb3_g4 , 0.0 ) * CZY_FilterColor );
			float4 MoonlightColor359 = ( temp_output_10_0_g4 * CZY_CloudFilterColor );
			float4 lerpResult269 = lerp( ( lerpResult270 + ( LightMask355 * CloudHighlightColor357 * ( 1.0 - CloudThicknessDetails347 ) ) + ( MoonlightMask308 * MoonlightColor359 * ( 1.0 - CloudThicknessDetails347 ) ) ) , ( CloudColor358 * float4( 0.5660378,0.5660378,0.5660378,0 ) ) , CloudThicknessDetails347);
			float time32 = 0.0;
			float2 voronoiSmoothId32 = 0;
			float2 coords32 = ( Pos10 + ( TIme6 * float2( 0.3,0.2 ) ) ) * ( 100.0 / CZY_DetailScale );
			float2 id32 = 0;
			float2 uv32 = 0;
			float fade32 = 0.5;
			float voroi32 = 0;
			float rest32 = 0;
			for( int it32 = 0; it32 <3; it32++ ){
			voroi32 += fade32 * voronoi32( coords32, time32, id32, uv32, 0,voronoiSmoothId32 );
			rest32 += fade32;
			coords32 *= 2;
			fade32 *= 0.5;
			}//Voronoi32
			voroi32 /= rest32;
			float temp_output_75_0 = ( (0.0 + (( 1.0 - voroi32 ) - 0.3) * (0.5 - 0.0) / (1.0 - 0.3)) * 0.1 * CZY_DetailAmount );
			float CloudDetail80 = temp_output_75_0;
			float2 temp_output_71_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult77 = dot( temp_output_71_0 , temp_output_71_0 );
			float BorderHeight63 = ( 1.0 - CZY_BorderHeight );
			float temp_output_64_0 = ( -2.0 * ( 1.0 - CZY_BorderVariation ) );
			float clampResult148 = clamp( ( ( ( CloudDetail80 + SimpleCloudDensity52 ) * saturate( (( BorderHeight63 * temp_output_64_0 ) + (dotResult77 - 0.0) * (( temp_output_64_0 * -4.0 ) - ( BorderHeight63 * temp_output_64_0 )) / (0.5 - 0.0)) ) ) * 10.0 * CZY_BorderEffect ) , -1.0 , 1.0 );
			float BorderLightTransport163 = clampResult148;
			float3 normalizeResult58 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float3 normalizeResult53 = normalize( CZY_StormDirection );
			float dotResult67 = dot( normalizeResult58 , normalizeResult53 );
			float2 temp_output_46_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult62 = dot( temp_output_46_0 , temp_output_46_0 );
			float temp_output_74_0 = ( -2.0 * ( 1.0 - ( CZY_NimbusVariation * 0.9 ) ) );
			float NimbusLightTransport175 = saturate( ( ( ( CloudDetail80 + SimpleCloudDensity52 ) * saturate( (( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_74_0 ) + (( dotResult67 + ( CZY_NimbusHeight * 4.0 * dotResult62 ) ) - 0.5) * (( temp_output_74_0 * -4.0 ) - ( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_74_0 )) / (7.0 - 0.5)) ) ) * 10.0 ) );
			float mulTime139 = _Time.y * 0.01;
			float simplePerlin2D170 = snoise( (Pos10*1.0 + mulTime139)*2.0 );
			float mulTime119 = _Time.y * CZY_ChemtrailsMoveSpeed;
			float cos150 = cos( ( mulTime119 * 0.01 ) );
			float sin150 = sin( ( mulTime119 * 0.01 ) );
			float2 rotator150 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos150 , -sin150 , sin150 , cos150 )) + float2( 0.5,0.5 );
			float cos165 = cos( ( mulTime119 * -0.02 ) );
			float sin165 = sin( ( mulTime119 * -0.02 ) );
			float2 rotator165 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos165 , -sin165 , sin165 , cos165 )) + float2( 0.5,0.5 );
			float mulTime140 = _Time.y * 0.01;
			float simplePerlin2D173 = snoise( (Pos10*1.0 + mulTime140)*4.0 );
			float4 ChemtrailsPattern217 = ( ( saturate( simplePerlin2D170 ) * tex2D( CZY_ChemtrailsTexture, (rotator150*0.5 + 0.0) ) ) + ( tex2D( CZY_ChemtrailsTexture, rotator165 ) * saturate( simplePerlin2D173 ) ) );
			float2 temp_output_201_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult211 = dot( temp_output_201_0 , temp_output_201_0 );
			float4 ChemtrailsFinal236 = ( ChemtrailsPattern217 * saturate( (0.4 + (dotResult211 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) * ( CZY_ChemtrailsMultiplier * 0.5 ) );
			float mulTime408 = _Time.y * 0.01;
			float simplePerlin2D439 = snoise( (Pos10*1.0 + mulTime408)*2.0 );
			float mulTime404 = _Time.y * CZY_CirrusMoveSpeed;
			float cos415 = cos( ( mulTime404 * 0.01 ) );
			float sin415 = sin( ( mulTime404 * 0.01 ) );
			float2 rotator415 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos415 , -sin415 , sin415 , cos415 )) + float2( 0.5,0.5 );
			float cos414 = cos( ( mulTime404 * -0.02 ) );
			float sin414 = sin( ( mulTime404 * -0.02 ) );
			float2 rotator414 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos414 , -sin414 , sin414 , cos414 )) + float2( 0.5,0.5 );
			float mulTime410 = _Time.y * 0.01;
			float simplePerlin2D417 = snoise( (Pos10*1.0 + mulTime410) );
			simplePerlin2D417 = simplePerlin2D417*0.5 + 0.5;
			float4 CirrusPattern428 = ( ( saturate( simplePerlin2D439 ) * tex2D( CZY_CirrusTexture, (rotator415*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrusTexture, (rotator414*1.0 + 0.0) ) * saturate( simplePerlin2D417 ) ) );
			float2 temp_output_423_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult426 = dot( temp_output_423_0 , temp_output_423_0 );
			float CirrusAlpha436 = ( ( ( CirrusPattern428 * saturate( (0.0 + (dotResult426 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) ) * ( CZY_CirrusMultiplier * 10.0 ) ).r * 0.6 );
			float4 SimpleRadiance280 = saturate( ( CloudThicknessDetails347 + BorderLightTransport163 + NimbusLightTransport175 + ChemtrailsFinal236 + CirrusAlpha436 ) );
			float4 lerpResult277 = lerp( CloudColor358 , lerpResult269 , ( 1.0 - SimpleRadiance280 ));
			float mulTime61 = _Time.y * 0.5;
			float2 panner88 = ( ( mulTime61 * 0.004 ) * float2( 0.2,-0.4 ) + Pos10);
			float cos79 = cos( ( mulTime61 * -0.01 ) );
			float sin79 = sin( ( mulTime61 * -0.01 ) );
			float2 rotator79 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos79 , -sin79 , sin79 , cos79 )) + float2( 0.5,0.5 );
			float4 CloudTexture135 = min( tex2D( CZY_CloudTexture, (panner88*1.0 + 0.75) ) , tex2D( CZY_CloudTexture, (rotator79*3.0 + 0.75) ) );
			float clampResult162 = clamp( ( 2.0 * 0.5 ) , 0.0 , 0.98 );
			float CloudTextureFinal196 = ( CloudTexture135 * clampResult162 ).r;
			float4 lerpResult279 = lerp( float4( 0,0,0,0 ) , CloudHighlightColor357 , ( saturate( CumulusCoverage48 ) * CloudTextureFinal196 * (0) ));
			float4 SunThroughClouds271 = ( lerpResult279 * 2.0 );
			float3 hsvTorgb2_g5 = RGBToHSV( CZY_AltoCloudColor.rgb );
			float3 hsvTorgb3_g5 = HSVToRGB( float3(hsvTorgb2_g5.x,saturate( ( hsvTorgb2_g5.y + CZY_FilterSaturation ) ),( hsvTorgb2_g5.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g5 = ( float4( hsvTorgb3_g5 , 0.0 ) * CZY_FilterColor );
			float4 CirrusCustomLightColor362 = ( CloudColor358 * ( temp_output_10_0_g5 * CZY_CloudFilterColor ) );
			float time120 = 0.0;
			float2 voronoiSmoothId120 = 0;
			float mulTime81 = _Time.y * 0.003;
			float2 coords120 = (Pos10*1.0 + ( float2( 1,-2 ) * mulTime81 )) * 10.0;
			float2 id120 = 0;
			float2 uv120 = 0;
			float voroi120 = voronoi120( coords120, time120, id120, uv120, 0, voronoiSmoothId120 );
			float time158 = ( 10.0 * mulTime81 );
			float2 voronoiSmoothId158 = 0;
			float2 coords158 = i.uv_texcoord * 10.0;
			float2 id158 = 0;
			float2 uv158 = 0;
			float voroi158 = voronoi158( coords158, time158, id158, uv158, 0, voronoiSmoothId158 );
			float AltoCumulusPlacement197 = saturate( ( ( ( 1.0 - 0.0 ) - (1.0 + (voroi120 - 0.0) * (-0.5 - 1.0) / (1.0 - 0.0)) ) - voroi158 ) );
			float time182 = 51.2;
			float2 voronoiSmoothId182 = 0;
			float2 coords182 = (Pos10*1.0 + ( CZY_AltocumulusWindSpeed * TIme6 )) * ( 100.0 / CZY_AltocumulusScale );
			float2 id182 = 0;
			float2 uv182 = 0;
			float fade182 = 0.5;
			float voroi182 = 0;
			float rest182 = 0;
			for( int it182 = 0; it182 <2; it182++ ){
			voroi182 += fade182 * voronoi182( coords182, time182, id182, uv182, 0,voronoiSmoothId182 );
			rest182 += fade182;
			coords182 *= 2;
			fade182 *= 0.5;
			}//Voronoi182
			voroi182 /= rest182;
			float AltoCumulusLightTransport234 = saturate( (-1.0 + (( AltoCumulusPlacement197 * ( 0.1 > voroi182 ? (0.5 + (voroi182 - 0.0) * (0.0 - 0.5) / (0.15 - 0.0)) : 0.0 ) * CZY_AltocumulusMultiplier ) - 0.0) * (3.0 - -1.0) / (1.0 - 0.0)) );
			float ACCustomLightsClipping318 = AltoCumulusLightTransport234;
			float mulTime144 = _Time.y * 0.01;
			float simplePerlin2D171 = snoise( (Pos10*1.0 + mulTime144)*2.0 );
			float mulTime116 = _Time.y * CZY_CirrostratusMoveSpeed;
			float cos151 = cos( ( mulTime116 * 0.01 ) );
			float sin151 = sin( ( mulTime116 * 0.01 ) );
			float2 rotator151 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
			float cos145 = cos( ( mulTime116 * -0.02 ) );
			float sin145 = sin( ( mulTime116 * -0.02 ) );
			float2 rotator145 = mul( Pos10 - float2( 0.5,0.5 ) , float2x2( cos145 , -sin145 , sin145 , cos145 )) + float2( 0.5,0.5 );
			float mulTime138 = _Time.y * 0.01;
			float simplePerlin2D169 = snoise( (Pos10*10.0 + mulTime138)*4.0 );
			float4 CirrostratPattern220 = ( ( saturate( simplePerlin2D171 ) * tex2D( CZY_CirrostratusTexture, (rotator151*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrostratusTexture, (rotator145*1.5 + 0.75) ) * saturate( simplePerlin2D169 ) ) );
			float2 temp_output_202_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult210 = dot( temp_output_202_0 , temp_output_202_0 );
			float4 CirrostratLightTransport235 = ( CirrostratPattern220 * saturate( (0.4 + (dotResult210 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) * ( CZY_CirrostratusMultiplier * 1.0 ) );
			float Clipping282 = CZY_ClippingThreshold;
			float4 CSCustomLightsClipping315 = ( CirrostratLightTransport235 * ( SimpleRadiance280.r > Clipping282 ? 0.0 : 1.0 ) );
			float4 CustomRadiance348 = saturate( ( ACCustomLightsClipping318 + CSCustomLightsClipping315 ) );
			float4 lerpResult306 = lerp( ( lerpResult277 + SunThroughClouds271 ) , CirrusCustomLightColor362 , CustomRadiance348);
			float4 lerpResult276 = lerp( CZY_CloudTextureColor , CZY_LightColor , float4( 0.5,0.5,0.5,0 ));
			float4 lerpResult302 = lerp( lerpResult306 , ( lerpResult276 * lerpResult306 ) , CloudTextureFinal196);
			float4 FinalCloudColor339 = lerpResult302;
			o.Emission = FinalCloudColor339.rgb;
			float temp_output_207_0 = saturate( ( CloudThicknessDetails347 + BorderLightTransport163 + NimbusLightTransport175 ) );
			float4 FinalAlpha245 = saturate( ( saturate( ( temp_output_207_0 + ( (-1.0 + (CloudTextureFinal196 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * CZY_TextureAmount * sin( ( temp_output_207_0 * UNITY_PI ) ) ) ) ) + AltoCumulusLightTransport234 + ChemtrailsFinal236 + CirrostratLightTransport235 + CirrusAlpha436 ) );
			o.Alpha = saturate( ( FinalAlpha245.r + ( FinalAlpha245.r * 2.0 * CZY_CloudThickness ) ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;1;-4288,-4736;Inherit;False;2254.259;1199.93;;45;402;377;373;372;371;370;369;368;367;366;361;360;359;358;357;356;355;352;350;344;337;335;333;322;321;312;308;301;298;293;292;290;288;287;285;284;283;281;272;48;10;6;5;4;2;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-3216,-4352;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;3;-288,-1536;Inherit;False;2974.933;2000.862;;5;255;253;37;11;7;Cumulus Cloud Block;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-3072,-4352;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-3120,-4528;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-2912,-4352;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;7;-240,-896;Inherit;False;1226.633;651.0015;Simple Density;19;375;52;47;36;35;33;26;25;24;23;22;20;18;17;15;13;12;9;8;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.Vector2Node;8;-208,-528;Inherit;False;Constant;_CloudWind2;Cloud Wind 2;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;9;-192,-592;Inherit;False;6;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-2912,-4528;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;11;-224,-96;Inherit;False;1980.736;453.4427;Final Detailing;17;381;380;167;153;126;117;80;75;60;49;32;29;27;21;19;16;14;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;48,-528;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;16,-816;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-192,80;Inherit;False;6;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;256,-384;Inherit;False;2;0;FLOAT;500;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-192,192;Inherit;False;Constant;_DetailWind;Detail Wind;17;0;Create;True;0;0;0;False;0;False;0.3,0.2;0.3,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;256,-480;Inherit;False;2;0;FLOAT;140;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;240,-608;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;16,112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;20;448,-560;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;21;-16,0;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;22;-192,-720;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VoronoiNode;23;432,-416;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;24;-192,-784;Inherit;False;6;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;624,-464;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;48,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;176,64;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;28;-3616,0;Inherit;False;2654.838;1705.478;;2;112;40;Cloud Texture Block;0.345098,0.8386047,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;176,160;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;5728,-880;Inherit;False;2713.637;1035.553;;30;388;387;386;385;175;161;133;122;110;107;102;95;92;91;87;86;76;74;70;67;62;58;57;53;46;43;42;39;38;31;Nimbus Block;0.5,0.5,0.5,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;31;5760,-640;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VoronoiNode;32;320,64;Inherit;True;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;768,-480;Inherit;False;VoroDetails;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;34;3376,-864;Inherit;False;2111.501;762.0129;;21;384;383;382;163;148;127;115;109;106;99;97;94;85;83;77;71;64;63;59;56;50;Cloud Border Block;1,0.5882353,0.685091,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;35;240,-704;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;240,-816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;37;1040,-736;Inherit;False;1154;500;Complex Density;9;379;105;101;84;78;68;65;54;41;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;38;5824,-784;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;5936,-368;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;40;-3568,64;Inherit;False;2197.287;953.2202;Pattern;13;399;135;114;108;104;100;88;79;73;72;66;61;45;;0.345098,0.8386047,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;1040,-592;Inherit;False;33;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;6048,-720;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;6640,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;6096,-2928;Inherit;False;2297.557;1709.783;;2;113;51;Cirrus Block;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-3520,560;Inherit;False;Constant;_CloudTextureChangeSpeed;Cloud Texture Change Speed;28;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;46;6160,-384;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;47;432,-800;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-2320,-4592;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;496,64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;3520,-592;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;51;6128,-2880;Inherit;False;2197.287;953.2202;Pattern;25;441;440;439;438;428;425;424;422;420;419;418;417;416;415;414;413;412;411;410;409;408;407;406;405;404;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;656,-816;Inherit;False;SimpleCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;53;6224,-592;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;54;1232,-576;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;55;-272,752;Inherit;False;3128.028;1619.676;;3;252;121;69;Altocumulus Cloud Block;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;56;3728,-352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;57;6768,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;58;6176,-720;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;59;3728,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;60;656,64;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;61;-3248,576;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;62;6352,-368;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;3888,-352;Inherit;False;BorderHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;3904,-272;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;1344,-592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-3008,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.004;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;67;6400,-704;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;1264,-672;Inherit;False;52;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;69;-208,848;Inherit;False;2021.115;830.0204;Placement Noise;14;197;192;168;158;152;134;125;124;120;111;103;96;82;81;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;70;6864,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;3744,-592;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-3008,608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3008,432;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;6928,-32;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;848,80;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;6608,-464;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;77;3936,-592;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;1600,-416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;79;-2832,592;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;1008,-32;Inherit;False;CloudDetail;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;81;-80,1536;Inherit;False;1;0;FLOAT;0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;82;-80,1280;Inherit;False;Constant;_ACMoveSpeed;ACMoveSpeed;14;0;Create;True;0;0;0;False;0;False;1,-2;5,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;4096,-368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;84;1536,-624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;4096,-272;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;6784,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;7088,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;88;-2832,432;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,-0.4;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;89;3136,704;Inherit;False;2654.838;1705.478;;3;254;178;98;Cirrostratus Block;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;90;3472,-2928;Inherit;False;2340.552;1688.827;;2;180;93;Chemtrails Block;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;7088,-32;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;92;7280,-192;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;93;3520,-2880;Inherit;False;2197.287;953.2202;Pattern;24;400;389;217;212;200;198;193;191;186;173;172;170;165;160;154;150;147;140;139;132;129;128;123;119;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;4304,-608;Inherit;False;52;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;7344,-400;Inherit;False;80;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;112,1424;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;97;4288,-512;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;-2;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;98;3184,752;Inherit;False;2197.287;953.2202;Pattern;25;401;395;220;205;199;195;188;184;181;177;171;169;166;156;151;149;145;144;143;142;141;138;131;130;116;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;4352,-688;Inherit;False;80;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;100;-2640,432;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;101;1776,-640;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;7296,-304;Inherit;False;52;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;128,1280;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-2640,592;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;1952,-640;Inherit;False;ComplexCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;106;4560,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;7552,-192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;4528,-656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;7536,-352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;111;304,1328;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;112;-3552,1072;Inherit;False;1600.229;583.7008;Final;7;196;190;179;162;146;136;118;;0.345098,0.8386047,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;113;6144,-1872;Inherit;False;1735.998;586.5895;Final;13;437;436;435;434;433;432;431;430;429;427;426;423;421;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.SimpleMinOpNode;114;-2048,592;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;4688,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;116;3456,1248;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;736,-32;Inherit;False;105;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3152,1488;Inherit;False;Constant;_CloudTextureMultiplier;Cloud Texture Multiplier;25;0;Create;True;1;Cirrostratus Clouds;0;0;False;0;False;2;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;119;3792,-2384;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;120;480,1328;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.CommentaryNode;121;-192,1712;Inherit;False;2200.287;555.4289;Main Noise;16;393;392;391;234;232;229;216;208;206;203;182;174;164;157;155;137;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;7696,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;4080,-2512;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;124;832,1056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;125;704,1296;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;1184,64;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;4896,-528;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;4128,-2736;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;4112,-2144;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;3808,912;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;3776,1504;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;4016,-2416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;7840,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;768,1520;Inherit;False;2;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-1888,496;Inherit;True;CloudTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-2864,1488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;48,2048;Inherit;False;6;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;138;3776,1584;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;139;4144,-2656;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;140;4112,-2064;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;3744,1120;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;3696,1312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;3680,1216;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;144;3808,992;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;145;3920,1280;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-2816,1184;Inherit;False;135;CloudTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;147;4384,-2720;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;148;5040,-512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;149;4048,928;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;150;4256,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;151;3920,1136;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;152;976,1056;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;153;1392,48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;154;4368,-2128;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;240,1984;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;156;4032,1520;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;208,1856;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;158;1024,1296;Inherit;False;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;12.27;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.CommentaryNode;159;-512,-4448;Inherit;False;3038.917;2502.995;;4;251;250;249;176;Finalization Block;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;4032,-2320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;161;7984,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;162;-2720,1488;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;5264,-544;Inherit;False;BorderLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;164;432,2032;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;165;4352,-2352;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;166;4128,1296;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;1552,48;Inherit;False;DetailedClouds;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;168;1136,1056;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;169;4256,1520;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;170;4608,-2704;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;171;4272,928;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;172;4464,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;173;4592,-2112;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;174;384,1856;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;8160,-240;Inherit;True;NimbusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;-464,-4336;Inherit;False;2843.676;639.4145;Final Alpha;22;397;245;244;243;242;241;240;239;238;237;231;225;222;219;218;213;209;207;204;194;187;185;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;177;4112,1120;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;178;3200,1776;Inherit;False;1600.229;583.7008;Final;10;394;235;230;224;223;221;214;210;202;189;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-2512,1280;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;180;3536,-1872;Inherit;False;1600.229;583.7008;Final;10;390;236;233;228;227;226;215;211;201;183;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.SaturateNode;181;4464,1520;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;182;576,1920;Inherit;True;0;0;1;0;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;51.2;False;2;FLOAT;3;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;183;3600,-1648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;184;4464,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-400,-4288;Inherit;False;347;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;186;4784,-2704;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-384,-4208;Inherit;False;163;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;189;3280,1984;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;190;-2368,1280;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;192;1296,1056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;4800,-2112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-384,-4112;Inherit;False;175;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;4688,1072;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-2192,1280;Inherit;False;CloudTextureFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;1472,1056;Inherit;False;AltoCumulusPlacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;5024,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;4688,1296;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;5024,-2336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;201;3840,-1648;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;202;3504,1984;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;203;768,2016;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.15;False;3;FLOAT;0.5;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;204;-80,-4256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;4864,1184;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;960,1824;Inherit;False;197;AltoCumulusPlacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;207;48,-4272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;208;960,1904;Inherit;True;2;4;0;FLOAT;0.1;False;1;FLOAT;0.3;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;288,-3984;Inherit;False;196;CloudTextureFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;210;3680,1984;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;211;4016,-1648;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;212;5200,-2448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PiNode;213;-32,-4128;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;214;3824,1984;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;215;4160,-1664;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;1200,1856;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;5408,-2464;Inherit;False;ChemtrailsPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;160,-4176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;219;544,-3984;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;5088,1184;Inherit;False;CirrostratPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;3936,1872;Inherit;False;220;CirrostratPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;222;304,-4176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;3984,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;224;4000,1984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;225;736,-3984;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;4320,-1472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;227;4336,-1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;4272,-1760;Inherit;False;217;ChemtrailsPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;229;1344,1856;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;4176,1920;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;960,-3904;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;232;1600,1872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;4496,-1728;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;234;1744,1872;Inherit;False;AltoCumulusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;4544,2016;Inherit;False;CirrostratLightTransport;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;4896,-1632;Inherit;False;ChemtrailsFinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;1424,-4256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;238;1568,-3952;Inherit;False;236;ChemtrailsFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;1504,-4048;Inherit;False;234;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;1584,-3792;Inherit;False;436;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;1520,-3872;Inherit;False;235;CirrostratLightTransport;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;242;1568,-4256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;1824,-4080;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;244;1952,-4080;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;2144,-4080;Inherit;False;FinalAlpha;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-1488,-576;Inherit;False;245;FinalAlpha;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;247;-1312,-576;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;-1168,-512;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;249;-448,-2960;Inherit;False;2881.345;950.1069;Final Coloring;39;398;376;349;345;340;339;338;334;329;328;327;326;325;319;317;316;313;309;307;306;305;303;302;282;277;276;275;274;273;270;269;268;267;265;262;261;260;259;257;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;250;-448,-3616;Inherit;False;1393.195;555.0131;Simple Radiance;8;343;341;314;294;291;289;280;278;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;251;1008,-3632;Inherit;False;1393.195;555.0131;Custom Radiance;5;348;324;300;266;264;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;252;1872,848;Inherit;False;939.7803;621.1177;Lighting & Clipping;8;374;365;364;363;362;342;318;258;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;253;-256,-1344;Inherit;False;1283.597;293.2691;Thickness Details;7;378;347;330;311;310;299;286;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;254;4832,1776;Inherit;False;916.8853;383.8425;Lighting & Clipping;6;354;346;331;315;297;296;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;255;1056,-1328;Inherit;False;1576.124;399.0991;Highlights;10;353;351;336;332;323;320;295;279;271;263;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;256;-1040,-576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;16,-2496;Inherit;False;357;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;2032,1184;Inherit;False;234;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;256,-2512;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;260;816,-2432;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;32,-2224;Inherit;False;359;MoonlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;784,-2688;Inherit;False;358;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;263;2032,-1072;Inherit;False;Constant;_2;2;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;264;1680,-3376;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;272,-2240;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;266;1536,-3376;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;432,-2464;Inherit;False;358;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;992,-2432;Inherit;False;271;SunThroughClouds;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;269;768,-2592;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;270;240,-2768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;271;2400,-1200;Inherit;False;SunThroughClouds;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;272;-3984,-4208;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;273;1344,-2736;Inherit;False;Global;CZY_LightColor;CZY_LightColor;40;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4983044,0.5918599,1.669757,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;274;1264,-2336;Inherit;False;348;CustomRadiance;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;275;1232,-2528;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;276;1568,-2768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0.5,0.5,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;277;992,-2560;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;278;256,-3424;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;279;2032,-1200;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;400,-3424;Inherit;False;SimpleRadiance;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;281;-4160,-3952;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;848,-2144;Inherit;False;Clipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;283;-3216,-3888;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;284;-3184,-4080;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;285;-3344,-4208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;256,-1312;Inherit;False;33;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;287;-3568,-4208;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;288;-3856,-4208;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;289;112,-3424;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;290;-3856,-3888;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;291;-112,-3216;Inherit;False;436;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;292;-3984,-3888;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;293;-3712,-3872;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-128,-3536;Inherit;False;347;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;1792,-1168;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;4880,1968;Inherit;False;280;SimpleRadiance;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;4896,2048;Inherit;False;282;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;298;-3216,-4208;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;299;304,-1184;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;1248,-3328;Inherit;False;315;CSCustomLightsClipping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;301;-3056,-4208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;302;1872,-2544;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;303;1232,-2416;Inherit;False;362;CirrusCustomLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;304;-912,-576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;305;16,-2784;Inherit;False;358;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;306;1536,-2544;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;307;-144,-2400;Inherit;False;347;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;308;-2912,-3888;Half;False;MoonlightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;1552,-2384;Inherit;False;196;CloudTextureFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;464,-1184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;311;464,-1328;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;-2896,-4080;Inherit;False;CloudLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;512,-2384;Inherit;False;347;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-160,-3456;Inherit;False;163;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;5440,1888;Inherit;False;CSCustomLightsClipping;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;316;64,-2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;317;96,-2400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;2496,1216;Inherit;False;ACCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;48,-2304;Inherit;False;308;MoonlightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;1520,-1120;Inherit;False;196;CloudTextureFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;321;-3712,-4208;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;322;-3344,-3872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;2240,-1184;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;1248,-3408;Inherit;False;318;ACCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-32,-2864;Inherit;False;357;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;326;560,-2288;Inherit;False;280;SimpleRadiance;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;608,-2480;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5660378,0.5660378,0.5660378,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;432,-2608;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;-128,-2128;Inherit;False;347;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;608,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;331;5104,1968;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;1792,-1248;Inherit;False;357;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;333;-4224,-4128;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;334;64,-2592;Inherit;False;355;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;335;-3568,-3888;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;336;1568,-1024;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;337;-4224,-3792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;1728,-2656;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;339;2144,-2576;Inherit;False;FinalCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;340;112,-2128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-144,-3296;Inherit;False;236;ChemtrailsFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;342;2160,1280;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-176,-3376;Inherit;False;175;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;344;-3056,-3888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-368,-2688;Inherit;False;105;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;4976,1872;Inherit;False;235;CirrostratLightTransport;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;347;752,-1280;Inherit;True;CloudThicknessDetails;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;348;1840,-3392;Inherit;False;CustomRadiance;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;349;-128,-2688;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;350;-3024,-4064;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;1088,-1120;Inherit;False;48;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;352;-4160,-4272;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;353;1600,-1200;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;5280,1904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-2912,-4208;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;356;-3904,-4464;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;-3712,-4464;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-3696,-4640;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;359;-3024,-4640;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;360;-3888,-4640;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;361;-3216,-4640;Inherit;False;Filter Color;-1;;4;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;2560,960;Inherit;False;CirrusCustomLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;2416,960;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.7159576,0.8624095,0.8773585,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;364;2192,896;Inherit;False;358;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;365;2192,992;Inherit;False;Filter Color;-1;;5;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;366;-3904,-4080;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.423889,-0.9055932,0.01480246;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;367;-3920,-3760;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.3015023,0.9437417,0.1358237;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;368;-2624,-4592;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;12;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-3360,-4336;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;11;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;370;-4144,-4640;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;False;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;0.04943931,0.07984611,0.1037736,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;371;-4144,-4464;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;2;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.0752492,0.1315804,0.1792453,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;372;-3408,-4096;Half;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;7;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-3408,-4000;Half;False;Global;CZY_CloudFlareFalloff;CZY_CloudFlareFalloff;8;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;374;1984,992;Inherit;False;Global;CZY_AltoCloudColor;CZY_AltoCloudColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.675705,1.909993,2.279378,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;375;0,-736;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;10;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;528,-2144;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-3408,-3760;Half;False;Global;CZY_MoonFlareFalloff;CZY_MoonFlareFalloff;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.752;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-208,-1152;Inherit;False;48;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;1360,-416;Inherit;False;48;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;0,224;Inherit;False;Global;CZY_DetailScale;CZY_DetailScale;0;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;656,240;Inherit;False;Global;CZY_DetailAmount;CZY_DetailAmount;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;3456,-352;Inherit;False;Global;CZY_BorderHeight;CZY_BorderHeight;2;2;[HideInInspector];[Header];Create;False;1;Border Clouds;0;0;False;0;False;1;0.553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;3456,-240;Inherit;False;Global;CZY_BorderVariation;CZY_BorderVariation;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;4576,-400;Inherit;False;Global;CZY_BorderEffect;CZY_BorderEffect;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;385;6032,-576;Inherit;False;Global;CZY_StormDirection;CZY_StormDirection;8;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;-0.9854507,0,-0.1699612;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;386;6496,-112;Inherit;False;Global;CZY_NimbusMultiplier;CZY_NimbusMultiplier;5;2;[HideInInspector];[Header];Create;False;1;Nimbus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;6336,-480;Inherit;False;Global;CZY_NimbusHeight;CZY_NimbusHeight;7;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;6368,0;Inherit;False;Global;CZY_NimbusVariation;CZY_NimbusVariation;6;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.945;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;3552,-2384;Inherit;False;Global;CZY_ChemtrailsMoveSpeed;CZY_ChemtrailsMoveSpeed;21;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.289;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;390;4032,-1472;Inherit;False;Global;CZY_ChemtrailsMultiplier;CZY_ChemtrailsMultiplier;19;1;[HideInInspector];Create;False;1;Chemtrails;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;391;960,2128;Inherit;False;Global;CZY_AltocumulusMultiplier;CZY_AltocumulusMultiplier;9;2;[HideInInspector];[Header];Create;False;1;Altocumulus Clouds;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;192,2160;Inherit;False;Global;CZY_AltocumulusScale;CZY_AltocumulusScale;10;1;[HideInInspector];Create;False;0;0;0;False;0;False;3;0.371;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;393;-32,1920;Inherit;False;Global;CZY_AltocumulusWindSpeed;CZY_AltocumulusWindSpeed;11;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,-2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;394;3712,2176;Inherit;False;Global;CZY_CirrostratusMultiplier;CZY_CirrostratusMultiplier;12;2;[HideInInspector];[Header];Create;False;1;Cirrostratus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;395;3216,1248;Inherit;False;Global;CZY_CirrostratusMoveSpeed;CZY_CirrostratusMoveSpeed;13;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.281;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;-1456,-432;Inherit;False;Global;CZY_CloudThickness;CZY_CloudThickness;20;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;397;656,-3824;Inherit;False;Global;CZY_TextureAmount;CZY_TextureAmount;23;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.556;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;398;1328,-2912;Inherit;False;Global;CZY_CloudTextureColor;CZY_CloudTextureColor;24;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;2.670157,2.670157,2.670157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;399;-2432,384;Inherit;True;Global;CZY_CloudTexture;CZY_CloudTexture;1;0;Create;False;0;0;0;False;0;False;-1;27248a215d4e5fe449733cb0631f0785;27248a215d4e5fe449733cb0631f0785;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;400;4656,-2544;Inherit;True;Global;CZY_ChemtrailsTexture;CZY_ChemtrailsTexture;3;0;Create;False;0;0;0;False;0;False;-1;9b3476b4df9abf8479476bae1bcd8a84;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;401;4320,1088;Inherit;True;Global;CZY_CirrostratusTexture;CZY_CirrostratusTexture;0;0;Create;False;0;0;0;False;0;False;-1;None;bf43c8d7b74e204469465f36dfff7d6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;402;-3424,-4640;Inherit;False;Global;CZY_CloudMoonColor;CZY_CloudMoonColor;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.0517088,0.07180047,0.1320755,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;403;-1312,-752;Inherit;False;339;FinalCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;404;6400,-2384;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;6720,-2144;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;6640,-2320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;407;6752,-2736;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;408;6752,-2656;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;6624,-2416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;410;6736,-2064;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;411;6688,-2512;Inherit;False;10;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;412;6992,-2704;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;413;6976,-2112;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;414;6864,-2352;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;415;6864,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;416;7072,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;417;7200,-2112;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;418;7072,-2336;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;419;7408,-2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;420;7408,-2112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;421;6192,-1648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;7632,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;423;6400,-1648;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;424;7632,-2336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;425;7808,-2448;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;426;6560,-1664;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;427;6704,-1664;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;428;8032,-2448;Inherit;False;CirrusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;429;6960,-1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;430;6864,-1776;Inherit;False;428;CirrusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;431;7120,-1600;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;432;7120,-1712;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;7280,-1632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;434;7408,-1632;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;7520,-1632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;436;7648,-1632;Inherit;False;CirrusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;6752,-1424;Inherit;False;Global;CZY_CirrusMultiplier;CZY_CirrusMultiplier;16;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;6160,-2384;Inherit;False;Global;CZY_CirrusMoveSpeed;CZY_CirrusMoveSpeed;17;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.297;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;439;7216,-2704;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;441;7264,-2544;Inherit;True;Global;CZY_CirrusTexture;CZY_CirrusTexture;2;0;Create;False;0;0;0;False;0;False;-1;302629ebb64a0e345948779662fc2cf3;302629ebb64a0e345948779662fc2cf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-704,-816;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Painted;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;-50;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;108;-2432,592;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;399;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;188;4321.292,1296;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;401;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;440;7264,-2336;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;441;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;191;4656,-2336;Inherit;True;Property;_ChemtrailsTex2;Chemtrails Tex 2;3;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;400;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;2;1;369;0
WireConnection;4;0;2;0
WireConnection;6;0;4;0
WireConnection;10;0;5;0
WireConnection;12;0;9;0
WireConnection;12;1;8;0
WireConnection;15;1;375;0
WireConnection;17;1;375;0
WireConnection;18;0;13;0
WireConnection;18;1;12;0
WireConnection;19;0;14;0
WireConnection;19;1;16;0
WireConnection;20;0;18;0
WireConnection;20;2;17;0
WireConnection;23;0;18;0
WireConnection;23;2;15;0
WireConnection;25;0;20;0
WireConnection;25;1;23;0
WireConnection;26;0;24;0
WireConnection;26;1;22;0
WireConnection;27;0;21;0
WireConnection;27;1;19;0
WireConnection;29;1;380;0
WireConnection;32;0;27;0
WireConnection;32;2;29;0
WireConnection;33;0;25;0
WireConnection;35;1;375;0
WireConnection;36;0;13;0
WireConnection;36;1;26;0
WireConnection;42;0;38;0
WireConnection;42;1;31;0
WireConnection;43;0;388;0
WireConnection;46;0;39;0
WireConnection;47;0;36;0
WireConnection;47;1;35;0
WireConnection;48;0;368;0
WireConnection;49;0;32;0
WireConnection;52;0;47;0
WireConnection;53;0;385;0
WireConnection;54;0;41;0
WireConnection;56;0;382;0
WireConnection;57;0;43;0
WireConnection;58;0;42;0
WireConnection;59;0;383;0
WireConnection;60;0;49;0
WireConnection;61;0;45;0
WireConnection;62;0;46;0
WireConnection;62;1;46;0
WireConnection;63;0;56;0
WireConnection;64;1;59;0
WireConnection;65;0;54;0
WireConnection;66;0;61;0
WireConnection;67;0;58;0
WireConnection;67;1;53;0
WireConnection;70;0;386;0
WireConnection;71;0;50;0
WireConnection;72;0;61;0
WireConnection;74;1;57;0
WireConnection;75;0;60;0
WireConnection;75;2;381;0
WireConnection;76;0;387;0
WireConnection;76;2;62;0
WireConnection;77;0;71;0
WireConnection;77;1;71;0
WireConnection;78;0;379;0
WireConnection;79;0;73;0
WireConnection;79;2;72;0
WireConnection;80;0;75;0
WireConnection;83;0;63;0
WireConnection;83;1;64;0
WireConnection;84;0;68;0
WireConnection;84;1;65;0
WireConnection;85;0;64;0
WireConnection;86;0;67;0
WireConnection;86;1;76;0
WireConnection;87;0;70;0
WireConnection;87;1;74;0
WireConnection;88;0;73;0
WireConnection;88;1;66;0
WireConnection;91;0;74;0
WireConnection;92;0;86;0
WireConnection;92;3;87;0
WireConnection;92;4;91;0
WireConnection;96;0;82;0
WireConnection;96;1;81;0
WireConnection;97;0;77;0
WireConnection;97;3;83;0
WireConnection;97;4;85;0
WireConnection;100;0;88;0
WireConnection;101;0;84;0
WireConnection;101;1;78;0
WireConnection;104;0;79;0
WireConnection;105;0;101;0
WireConnection;106;0;97;0
WireConnection;107;0;92;0
WireConnection;109;0;99;0
WireConnection;109;1;94;0
WireConnection;110;0;95;0
WireConnection;110;1;102;0
WireConnection;111;0;103;0
WireConnection;111;2;96;0
WireConnection;114;0;399;0
WireConnection;114;1;108;0
WireConnection;115;0;109;0
WireConnection;115;1;106;0
WireConnection;116;0;395;0
WireConnection;119;0;389;0
WireConnection;120;0;111;0
WireConnection;122;0;110;0
WireConnection;122;1;107;0
WireConnection;125;0;120;0
WireConnection;126;0;117;0
WireConnection;126;1;75;0
WireConnection;127;0;115;0
WireConnection;127;2;384;0
WireConnection;132;0;119;0
WireConnection;133;0;122;0
WireConnection;134;1;81;0
WireConnection;135;0;114;0
WireConnection;136;0;118;0
WireConnection;142;0;116;0
WireConnection;143;0;116;0
WireConnection;145;0;141;0
WireConnection;145;2;142;0
WireConnection;147;0;128;0
WireConnection;147;2;139;0
WireConnection;148;0;127;0
WireConnection;149;0;130;0
WireConnection;149;2;144;0
WireConnection;150;0;123;0
WireConnection;150;2;132;0
WireConnection;151;0;141;0
WireConnection;151;2;143;0
WireConnection;152;0;124;0
WireConnection;152;1;125;0
WireConnection;153;0;126;0
WireConnection;154;0;129;0
WireConnection;154;2;140;0
WireConnection;155;0;393;0
WireConnection;155;1;137;0
WireConnection;156;0;131;0
WireConnection;156;2;138;0
WireConnection;158;1;134;0
WireConnection;160;0;119;0
WireConnection;161;0;133;0
WireConnection;162;0;136;0
WireConnection;163;0;148;0
WireConnection;164;1;392;0
WireConnection;165;0;123;0
WireConnection;165;2;160;0
WireConnection;166;0;145;0
WireConnection;167;0;153;0
WireConnection;168;0;152;0
WireConnection;168;1;158;0
WireConnection;169;0;156;0
WireConnection;170;0;147;0
WireConnection;171;0;149;0
WireConnection;172;0;150;0
WireConnection;173;0;154;0
WireConnection;174;0;157;0
WireConnection;174;2;155;0
WireConnection;175;0;161;0
WireConnection;177;0;151;0
WireConnection;179;0;146;0
WireConnection;179;1;162;0
WireConnection;181;0;169;0
WireConnection;182;0;174;0
WireConnection;182;2;164;0
WireConnection;184;0;171;0
WireConnection;186;0;170;0
WireConnection;190;0;179;0
WireConnection;192;0;168;0
WireConnection;193;0;173;0
WireConnection;195;0;184;0
WireConnection;195;1;401;0
WireConnection;196;0;190;0
WireConnection;197;0;192;0
WireConnection;198;0;186;0
WireConnection;198;1;400;0
WireConnection;199;0;188;0
WireConnection;199;1;181;0
WireConnection;200;0;191;0
WireConnection;200;1;193;0
WireConnection;201;0;183;0
WireConnection;202;0;189;0
WireConnection;203;0;182;0
WireConnection;204;0;185;0
WireConnection;204;1;187;0
WireConnection;204;2;194;0
WireConnection;205;0;195;0
WireConnection;205;1;199;0
WireConnection;207;0;204;0
WireConnection;208;1;182;0
WireConnection;208;2;203;0
WireConnection;210;0;202;0
WireConnection;210;1;202;0
WireConnection;211;0;201;0
WireConnection;211;1;201;0
WireConnection;212;0;198;0
WireConnection;212;1;200;0
WireConnection;214;0;210;0
WireConnection;215;0;211;0
WireConnection;216;0;206;0
WireConnection;216;1;208;0
WireConnection;216;2;391;0
WireConnection;217;0;212;0
WireConnection;218;0;207;0
WireConnection;218;1;213;0
WireConnection;219;0;209;0
WireConnection;220;0;205;0
WireConnection;222;0;218;0
WireConnection;223;0;394;0
WireConnection;224;0;214;0
WireConnection;225;0;219;0
WireConnection;226;0;390;0
WireConnection;227;0;215;0
WireConnection;229;0;216;0
WireConnection;230;0;221;0
WireConnection;230;1;224;0
WireConnection;230;2;223;0
WireConnection;231;0;225;0
WireConnection;231;1;397;0
WireConnection;231;2;222;0
WireConnection;232;0;229;0
WireConnection;233;0;228;0
WireConnection;233;1;227;0
WireConnection;233;2;226;0
WireConnection;234;0;232;0
WireConnection;235;0;230;0
WireConnection;236;0;233;0
WireConnection;237;0;207;0
WireConnection;237;1;231;0
WireConnection;242;0;237;0
WireConnection;243;0;242;0
WireConnection;243;1;239;0
WireConnection;243;2;238;0
WireConnection;243;3;241;0
WireConnection;243;4;240;0
WireConnection;244;0;243;0
WireConnection;245;0;244;0
WireConnection;247;0;246;0
WireConnection;248;0;247;0
WireConnection;248;2;396;0
WireConnection;256;0;247;0
WireConnection;256;1;248;0
WireConnection;259;0;334;0
WireConnection;259;1;257;0
WireConnection;259;2;317;0
WireConnection;260;0;326;0
WireConnection;264;0;266;0
WireConnection;265;0;319;0
WireConnection;265;1;261;0
WireConnection;265;2;340;0
WireConnection;266;0;324;0
WireConnection;266;1;300;0
WireConnection;269;0;328;0
WireConnection;269;1;327;0
WireConnection;269;2;313;0
WireConnection;270;0;325;0
WireConnection;270;1;305;0
WireConnection;270;2;316;0
WireConnection;271;0;323;0
WireConnection;272;0;352;0
WireConnection;272;1;333;0
WireConnection;275;0;277;0
WireConnection;275;1;268;0
WireConnection;276;0;398;0
WireConnection;276;1;273;0
WireConnection;277;0;262;0
WireConnection;277;1;269;0
WireConnection;277;2;260;0
WireConnection;278;0;289;0
WireConnection;279;1;332;0
WireConnection;279;2;295;0
WireConnection;280;0;278;0
WireConnection;282;0;376;0
WireConnection;283;0;322;0
WireConnection;283;1;377;0
WireConnection;284;0;285;0
WireConnection;284;1;373;0
WireConnection;285;0;287;0
WireConnection;287;0;321;0
WireConnection;288;0;272;0
WireConnection;289;0;294;0
WireConnection;289;1;314;0
WireConnection;289;2;343;0
WireConnection;289;3;341;0
WireConnection;289;4;291;0
WireConnection;290;0;292;0
WireConnection;292;0;281;0
WireConnection;292;1;337;0
WireConnection;293;0;290;0
WireConnection;293;1;367;0
WireConnection;295;0;353;0
WireConnection;295;1;320;0
WireConnection;295;2;336;0
WireConnection;298;0;285;0
WireConnection;298;1;372;0
WireConnection;299;0;378;0
WireConnection;301;0;298;0
WireConnection;302;0;306;0
WireConnection;302;1;338;0
WireConnection;302;2;309;0
WireConnection;304;0;256;0
WireConnection;306;0;275;0
WireConnection;306;1;303;0
WireConnection;306;2;274;0
WireConnection;308;0;344;0
WireConnection;310;0;299;0
WireConnection;311;0;286;0
WireConnection;312;0;350;0
WireConnection;315;0;354;0
WireConnection;316;0;349;0
WireConnection;317;0;307;0
WireConnection;318;0;258;0
WireConnection;321;0;288;0
WireConnection;321;1;366;0
WireConnection;322;0;335;0
WireConnection;323;0;279;0
WireConnection;323;1;263;0
WireConnection;327;0;267;0
WireConnection;328;0;270;0
WireConnection;328;1;259;0
WireConnection;328;2;265;0
WireConnection;330;0;311;0
WireConnection;330;1;310;0
WireConnection;331;0;296;0
WireConnection;331;1;297;0
WireConnection;335;0;293;0
WireConnection;338;0;276;0
WireConnection;338;1;306;0
WireConnection;339;0;302;0
WireConnection;340;0;329;0
WireConnection;344;0;283;0
WireConnection;347;0;330;0
WireConnection;348;0;264;0
WireConnection;349;0;345;0
WireConnection;350;0;284;0
WireConnection;353;0;351;0
WireConnection;354;0;346;0
WireConnection;354;1;331;0
WireConnection;355;0;301;0
WireConnection;356;1;371;0
WireConnection;357;0;356;0
WireConnection;358;0;360;0
WireConnection;359;0;361;0
WireConnection;360;1;370;0
WireConnection;361;1;402;0
WireConnection;362;0;363;0
WireConnection;363;0;364;0
WireConnection;363;1;365;0
WireConnection;365;1;374;0
WireConnection;399;1;100;0
WireConnection;400;1;172;0
WireConnection;401;1;177;0
WireConnection;404;0;438;0
WireConnection;406;0;404;0
WireConnection;409;0;404;0
WireConnection;412;0;407;0
WireConnection;412;2;408;0
WireConnection;413;0;405;0
WireConnection;413;2;410;0
WireConnection;414;0;411;0
WireConnection;414;2;406;0
WireConnection;415;0;411;0
WireConnection;415;2;409;0
WireConnection;416;0;415;0
WireConnection;417;0;413;0
WireConnection;418;0;414;0
WireConnection;419;0;439;0
WireConnection;420;0;417;0
WireConnection;422;0;419;0
WireConnection;422;1;441;0
WireConnection;423;0;421;0
WireConnection;424;0;440;0
WireConnection;424;1;420;0
WireConnection;425;0;422;0
WireConnection;425;1;424;0
WireConnection;426;0;423;0
WireConnection;426;1;423;0
WireConnection;427;0;426;0
WireConnection;428;0;425;0
WireConnection;429;0;427;0
WireConnection;431;0;437;0
WireConnection;432;0;430;0
WireConnection;432;1;429;0
WireConnection;433;0;432;0
WireConnection;433;1;431;0
WireConnection;434;0;433;0
WireConnection;435;0;434;0
WireConnection;436;0;435;0
WireConnection;439;0;412;0
WireConnection;441;1;416;0
WireConnection;0;2;403;0
WireConnection;0;9;304;0
WireConnection;108;1;104;0
WireConnection;188;1;166;0
WireConnection;440;1;418;0
WireConnection;191;1;165;0
ASEEND*/
//CHKSM=CFD5877C60BEBC7E473FAA822359C9D8953434C3