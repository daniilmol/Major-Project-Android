// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Soft"
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
		uniform float CZY_ClippingThreshold;
		uniform half CZY_CloudFlareFalloff;
		uniform float4 CZY_AltoCloudColor;
		uniform float CZY_AltocumulusScale;
		uniform float2 CZY_AltocumulusWindSpeed;
		uniform float CZY_AltocumulusMultiplier;
		uniform sampler2D CZY_CirrostratusTexture;
		uniform float CZY_CirrostratusMoveSpeed;
		uniform float CZY_CirrostratusMultiplier;
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


		float2 voronoihash892( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi892( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash892( n + g );
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


		float2 voronoihash899( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi899( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash899( n + g );
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


		float2 voronoihash895( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi895( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash895( n + g );
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


		float2 voronoihash1009( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1009( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash1009( n + g );
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


		float2 voronoihash1042( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1042( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash1042( n + g );
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


		float2 voronoihash1095( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1095( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash1095( n + g );
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
			float3 hsvTorgb2_g6 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g6 = HSVToRGB( float3(hsvTorgb2_g6.x,saturate( ( hsvTorgb2_g6.y + CZY_FilterSaturation ) ),( hsvTorgb2_g6.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g6 = ( float4( hsvTorgb3_g6 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor849 = ( temp_output_10_0_g6 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g5 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g5 = HSVToRGB( float3(hsvTorgb2_g5.x,saturate( ( hsvTorgb2_g5.y + CZY_FilterSaturation ) ),( hsvTorgb2_g5.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g5 = ( float4( hsvTorgb3_g5 , 0.0 ) * CZY_FilterColor );
			float4 CloudHighlightColor864 = ( temp_output_10_0_g5 * CZY_SunFilterColor );
			float2 Pos841 = i.uv_texcoord;
			float simplePerlin2D931 = snoise( ( float4( Pos841, 0.0 , 0.0 ) + ( CloudColor849 * float4( float2( 0.2,-0.4 ), 0.0 , 0.0 ) ) ).rg*( 100.0 / CZY_MainCloudScale ) );
			simplePerlin2D931 = simplePerlin2D931*0.5 + 0.5;
			float SimpleCloudDensity963 = simplePerlin2D931;
			float time892 = 0.0;
			float2 voronoiSmoothId892 = 0;
			float4 temp_output_905_0 = ( float4( Pos841, 0.0 , 0.0 ) + ( CloudColor849 * float4( float2( 0.3,0.2 ), 0.0 , 0.0 ) ) );
			float2 coords892 = temp_output_905_0.rg * ( 140.0 / CZY_MainCloudScale );
			float2 id892 = 0;
			float2 uv892 = 0;
			float voroi892 = voronoi892( coords892, time892, id892, uv892, 0, voronoiSmoothId892 );
			float time899 = 0.0;
			float2 voronoiSmoothId899 = 0;
			float2 coords899 = temp_output_905_0.rg * ( 500.0 / CZY_MainCloudScale );
			float2 id899 = 0;
			float2 uv899 = 0;
			float voroi899 = voronoi899( coords899, time899, id899, uv899, 0, voronoiSmoothId899 );
			float2 appendResult906 = (float2(voroi892 , voroi899));
			float2 VoroDetails920 = appendResult906;
			float CumulusCoverage842 = CZY_CumulusCoverageMultiplier;
			float ComplexCloudDensity952 = (0.0 + (min( SimpleCloudDensity963 , ( 1.0 - VoroDetails920.x ) ) - ( 1.0 - CumulusCoverage842 )) * (1.0 - 0.0) / (1.0 - ( 1.0 - CumulusCoverage842 )));
			float4 lerpResult1142 = lerp( CloudHighlightColor864 , CloudColor849 , saturate( (2.0 + (ComplexCloudDensity952 - 0.0) * (0.7 - 2.0) / (1.0 - 0.0)) ));
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult848 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult850 = dot( normalizeResult848 , CZY_SunDirection );
			float temp_output_858_0 = abs( (dotResult850*0.5 + 0.5) );
			half LightMask865 = saturate( pow( temp_output_858_0 , CZY_SunFlareFalloff ) );
			float CloudThicknessDetails1109 = ( VoroDetails920.y * saturate( ( CumulusCoverage842 - 0.8 ) ) );
			float3 normalizeResult851 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult855 = dot( normalizeResult851 , CZY_MoonDirection );
			half MoonlightMask866 = saturate( pow( abs( (dotResult855*0.5 + 0.5) ) , CZY_MoonFlareFalloff ) );
			float3 hsvTorgb2_g7 = RGBToHSV( CZY_CloudMoonColor.rgb );
			float3 hsvTorgb3_g7 = HSVToRGB( float3(hsvTorgb2_g7.x,saturate( ( hsvTorgb2_g7.y + CZY_FilterSaturation ) ),( hsvTorgb2_g7.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g7 = ( float4( hsvTorgb3_g7 , 0.0 ) * CZY_FilterColor );
			float4 MoonlightColor869 = ( temp_output_10_0_g7 * CZY_CloudFilterColor );
			float4 lerpResult1165 = lerp( ( lerpResult1142 + ( LightMask865 * CloudHighlightColor864 * ( 1.0 - CloudThicknessDetails1109 ) ) + ( MoonlightMask866 * MoonlightColor869 * ( 1.0 - CloudThicknessDetails1109 ) ) ) , ( CloudColor849 * float4( 0.5660378,0.5660378,0.5660378,0 ) ) , CloudThicknessDetails1109);
			float time895 = 0.0;
			float2 voronoiSmoothId895 = 0;
			float2 coords895 = ( float4( Pos841, 0.0 , 0.0 ) + ( CloudColor849 * float4( float2( 0.3,0.2 ), 0.0 , 0.0 ) ) ).rg * ( 100.0 / CZY_DetailScale );
			float2 id895 = 0;
			float2 uv895 = 0;
			float fade895 = 0.5;
			float voroi895 = 0;
			float rest895 = 0;
			for( int it895 = 0; it895 <3; it895++ ){
			voroi895 += fade895 * voronoi895( coords895, time895, id895, uv895, 0,voronoiSmoothId895 );
			rest895 += fade895;
			coords895 *= 2;
			fade895 *= 0.5;
			}//Voronoi895
			voroi895 /= rest895;
			float temp_output_982_0 = ( (0.0 + (( 1.0 - voroi895 ) - 0.3) * (0.5 - 0.0) / (1.0 - 0.3)) * 0.1 * CZY_DetailAmount );
			float DetailedClouds1066 = saturate( ( ComplexCloudDensity952 + temp_output_982_0 ) );
			float CloudDetail988 = temp_output_982_0;
			float2 temp_output_971_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1022 = dot( temp_output_971_0 , temp_output_971_0 );
			float BorderHeight964 = ( 1.0 - CZY_BorderHeight );
			float temp_output_961_0 = ( -2.0 * ( 1.0 - CZY_BorderVariation ) );
			float clampResult1061 = clamp( ( ( ( CloudDetail988 + SimpleCloudDensity963 ) * saturate( (( BorderHeight964 * temp_output_961_0 ) + (dotResult1022 - 0.0) * (( temp_output_961_0 * -4.0 ) - ( BorderHeight964 * temp_output_961_0 )) / (1.0 - 0.0)) ) ) * 10.0 * CZY_BorderEffect ) , -1.0 , 1.0 );
			float BorderLightTransport1211 = clampResult1061;
			float3 normalizeResult927 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float3 normalizeResult957 = normalize( CZY_StormDirection );
			float dotResult960 = dot( normalizeResult927 , normalizeResult957 );
			float2 temp_output_935_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult936 = dot( temp_output_935_0 , temp_output_935_0 );
			float temp_output_951_0 = ( -2.0 * ( 1.0 - ( CZY_NimbusVariation * 0.9 ) ) );
			float NimbusLightTransport1088 = saturate( ( ( ( CloudDetail988 + SimpleCloudDensity963 ) * saturate( (( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_951_0 ) + (( dotResult960 + ( CZY_NimbusHeight * 4.0 * dotResult936 ) ) - 0.5) * (( temp_output_951_0 * -4.0 ) - ( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_951_0 )) / (7.0 - 0.5)) ) ) * 10.0 ) );
			float mulTime915 = _Time.y * 0.01;
			float simplePerlin2D954 = snoise( (Pos841*1.0 + mulTime915)*2.0 );
			float mulTime904 = _Time.y * CZY_ChemtrailsMoveSpeed;
			float cos908 = cos( ( mulTime904 * 0.01 ) );
			float sin908 = sin( ( mulTime904 * 0.01 ) );
			float2 rotator908 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos908 , -sin908 , sin908 , cos908 )) + float2( 0.5,0.5 );
			float cos942 = cos( ( mulTime904 * -0.02 ) );
			float sin942 = sin( ( mulTime904 * -0.02 ) );
			float2 rotator942 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos942 , -sin942 , sin942 , cos942 )) + float2( 0.5,0.5 );
			float mulTime918 = _Time.y * 0.01;
			float simplePerlin2D958 = snoise( (Pos841*1.0 + mulTime918)*4.0 );
			float4 ChemtrailsPattern1020 = ( ( saturate( simplePerlin2D954 ) * tex2D( CZY_ChemtrailsTexture, (rotator908*0.5 + 0.0) ) ) + ( tex2D( CZY_ChemtrailsTexture, rotator942 ) * saturate( simplePerlin2D958 ) ) );
			float2 temp_output_972_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1017 = dot( temp_output_972_0 , temp_output_972_0 );
			float ChemtrailsFinal1062 = ( ( ChemtrailsPattern1020 * saturate( (0.4 + (dotResult1017 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - ( CZY_ChemtrailsMultiplier * 0.5 ) ) ? 1.0 : 0.0 );
			float mulTime891 = _Time.y * 0.01;
			float simplePerlin2D937 = snoise( (Pos841*1.0 + mulTime891)*2.0 );
			float mulTime886 = _Time.y * CZY_CirrusMoveSpeed;
			float cos912 = cos( ( mulTime886 * 0.01 ) );
			float sin912 = sin( ( mulTime886 * 0.01 ) );
			float2 rotator912 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos912 , -sin912 , sin912 , cos912 )) + float2( 0.5,0.5 );
			float cos923 = cos( ( mulTime886 * -0.02 ) );
			float sin923 = sin( ( mulTime886 * -0.02 ) );
			float2 rotator923 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos923 , -sin923 , sin923 , cos923 )) + float2( 0.5,0.5 );
			float mulTime946 = _Time.y * 0.01;
			float simplePerlin2D933 = snoise( (Pos841*1.0 + mulTime946) );
			simplePerlin2D933 = simplePerlin2D933*0.5 + 0.5;
			float4 CirrusPattern948 = ( ( saturate( simplePerlin2D937 ) * tex2D( CZY_CirrusTexture, (rotator912*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrusTexture, (rotator923*1.0 + 0.0) ) * saturate( simplePerlin2D933 ) ) );
			float2 temp_output_974_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult967 = dot( temp_output_974_0 , temp_output_974_0 );
			float4 temp_output_1027_0 = ( CirrusPattern948 * saturate( (0.0 + (dotResult967 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) );
			float Clipping1018 = CZY_ClippingThreshold;
			float CirrusAlpha1064 = ( ( temp_output_1027_0 * ( CZY_CirrusMultiplier * 10.0 ) ).r > Clipping1018 ? 1.0 : 0.0 );
			float SimpleRadiance1087 = saturate( ( DetailedClouds1066 + BorderLightTransport1211 + NimbusLightTransport1088 + ChemtrailsFinal1062 + CirrusAlpha1064 ) );
			float4 lerpResult1169 = lerp( CloudColor849 , lerpResult1165 , ( 1.0 - SimpleRadiance1087 ));
			float CloudLight861 = saturate( pow( temp_output_858_0 , CZY_CloudFlareFalloff ) );
			float4 lerpResult1143 = lerp( float4( 0,0,0,0 ) , CloudHighlightColor864 , ( saturate( ( CumulusCoverage842 - 1.0 ) ) * CloudDetail988 * CloudLight861 ));
			float4 SunThroughClouds1134 = ( lerpResult1143 * 1.3 );
			float3 hsvTorgb2_g8 = RGBToHSV( CZY_AltoCloudColor.rgb );
			float3 hsvTorgb3_g8 = HSVToRGB( float3(hsvTorgb2_g8.x,saturate( ( hsvTorgb2_g8.y + CZY_FilterSaturation ) ),( hsvTorgb2_g8.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g8 = ( float4( hsvTorgb3_g8 , 0.0 ) * CZY_FilterColor );
			float4 CirrusCustomLightColor1177 = ( CloudColor849 * ( temp_output_10_0_g8 * CZY_CloudFilterColor ) );
			float time1009 = 0.0;
			float2 voronoiSmoothId1009 = 0;
			float mulTime973 = _Time.y * 0.003;
			float2 coords1009 = (Pos841*1.0 + ( float2( 1,-2 ) * mulTime973 )) * 10.0;
			float2 id1009 = 0;
			float2 uv1009 = 0;
			float voroi1009 = voronoi1009( coords1009, time1009, id1009, uv1009, 0, voronoiSmoothId1009 );
			float time1042 = ( 10.0 * mulTime973 );
			float2 voronoiSmoothId1042 = 0;
			float2 coords1042 = i.uv_texcoord * 10.0;
			float2 id1042 = 0;
			float2 uv1042 = 0;
			float voroi1042 = voronoi1042( coords1042, time1042, id1042, uv1042, 0, voronoiSmoothId1042 );
			float AltoCumulusPlacement1079 = saturate( ( ( ( 1.0 - 0.0 ) - (1.0 + (voroi1009 - 0.0) * (-0.5 - 1.0) / (1.0 - 0.0)) ) - voroi1042 ) );
			float time1095 = 51.2;
			float2 voronoiSmoothId1095 = 0;
			float2 coords1095 = (Pos841*1.0 + ( float4( CZY_AltocumulusWindSpeed, 0.0 , 0.0 ) * CloudColor849 ).rg) * ( 100.0 / CZY_AltocumulusScale );
			float2 id1095 = 0;
			float2 uv1095 = 0;
			float fade1095 = 0.5;
			float voroi1095 = 0;
			float rest1095 = 0;
			for( int it1095 = 0; it1095 <2; it1095++ ){
			voroi1095 += fade1095 * voronoi1095( coords1095, time1095, id1095, uv1095, 0,voronoiSmoothId1095 );
			rest1095 += fade1095;
			coords1095 *= 2;
			fade1095 *= 0.5;
			}//Voronoi1095
			voroi1095 /= rest1095;
			float AltoCumulusLightTransport1108 = ( ( AltoCumulusPlacement1079 * ( 0.1 > voroi1095 ? (0.5 + (voroi1095 - 0.0) * (0.0 - 0.5) / (0.15 - 0.0)) : 0.0 ) * CZY_AltocumulusMultiplier ) > 0.2 ? 1.0 : 0.0 );
			float ACCustomLightsClipping1151 = ( AltoCumulusLightTransport1108 * ( SimpleRadiance1087 > Clipping1018 ? 0.0 : 1.0 ) );
			float mulTime1002 = _Time.y * 0.01;
			float simplePerlin2D1034 = snoise( (Pos841*1.0 + mulTime1002)*2.0 );
			float mulTime987 = _Time.y * CZY_CirrostratusMoveSpeed;
			float cos949 = cos( ( mulTime987 * 0.01 ) );
			float sin949 = sin( ( mulTime987 * 0.01 ) );
			float2 rotator949 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos949 , -sin949 , sin949 , cos949 )) + float2( 0.5,0.5 );
			float cos1007 = cos( ( mulTime987 * -0.02 ) );
			float sin1007 = sin( ( mulTime987 * -0.02 ) );
			float2 rotator1007 = mul( Pos841 - float2( 0.5,0.5 ) , float2x2( cos1007 , -sin1007 , sin1007 , cos1007 )) + float2( 0.5,0.5 );
			float mulTime993 = _Time.y * 0.01;
			float simplePerlin2D1026 = snoise( (Pos841*10.0 + mulTime993)*4.0 );
			float4 CirrostratPattern1078 = ( ( saturate( simplePerlin2D1034 ) * tex2D( CZY_CirrostratusTexture, (rotator949*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrostratusTexture, (rotator1007*1.5 + 0.75) ) * saturate( simplePerlin2D1026 ) ) );
			float2 temp_output_1057_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1051 = dot( temp_output_1057_0 , temp_output_1057_0 );
			float clampResult1082 = clamp( ( CZY_CirrostratusMultiplier * 0.5 ) , 0.0 , 0.98 );
			float CirrostratLightTransport1103 = ( ( CirrostratPattern1078 * saturate( (0.4 + (dotResult1051 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - clampResult1082 ) ? 1.0 : 0.0 );
			float CSCustomLightsClipping1136 = ( CirrostratLightTransport1103 * ( SimpleRadiance1087 > Clipping1018 ? 0.0 : 1.0 ) );
			float CustomRadiance1167 = saturate( ( ACCustomLightsClipping1151 + CSCustomLightsClipping1136 ) );
			float4 lerpResult1158 = lerp( ( lerpResult1169 + SunThroughClouds1134 ) , CirrusCustomLightColor1177 , CustomRadiance1167);
			float4 FinalCloudColor1210 = lerpResult1158;
			o.Emission = FinalCloudColor1210.rgb;
			float FinalAlpha1207 = saturate( ( DetailedClouds1066 + BorderLightTransport1211 + AltoCumulusLightTransport1108 + ChemtrailsFinal1062 + CirrostratLightTransport1103 + CirrusAlpha1064 + NimbusLightTransport1088 ) );
			o.Alpha = saturate( ( FinalAlpha1207 + ( FinalAlpha1207 * 2.0 * CZY_CloudThickness ) ) );
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
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-678.2959,-671.1561;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Soft;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;-50;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;806;-1175.1,-420.7001;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;807;-1047.1,-484.7001;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;808;-919.1001,-484.7001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;809;3736.9,-1844.7;Inherit;False;2340.552;1688.827;;2;832;820;Chemtrails Block;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;810;-23.10001,-452.7001;Inherit;False;2974.933;2000.862;;5;829;827;823;822;819;Cumulus Cloud Block;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;811;3416.9,1803.3;Inherit;False;2654.838;1705.478;;3;834;831;816;Cirrostratus Block;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;812;-247.1,-3348.7;Inherit;False;3038.917;2502.995;;4;836;830;825;824;Finalization Block;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;813;6360.9,-1844.7;Inherit;False;2297.557;1709.783;;2;835;833;Cirrus Block;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;814;-7.099998,1851.3;Inherit;False;3128.028;1619.676;;3;826;821;817;Altocumulus Cloud Block;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;815;-4023.1,-3636.7;Inherit;False;2254.259;1199.93;;45;1220;880;879;878;877;876;875;874;873;872;871;870;869;868;867;866;865;864;863;862;861;860;859;858;857;856;855;854;853;852;851;850;849;848;847;846;845;844;843;842;841;840;839;838;837;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;816;3464.9,2859.3;Inherit;False;1600.229;583.7008;Final;13;1201;1103;1093;1083;1082;1074;1073;1071;1069;1063;1057;1051;1046;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;817;72.90001,1947.3;Inherit;False;2021.115;830.0204;Placement Noise;18;1197;1121;1079;1065;1056;1050;1045;1042;1039;1037;1032;1031;1025;1009;999;985;976;973;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;818;5992.9,219.3;Inherit;False;2713.637;1035.553;;30;1190;1189;1188;1187;1088;1040;1036;1030;1019;1010;1008;1003;995;983;980;975;962;960;957;953;951;940;939;936;935;932;927;922;913;909;Nimbus Block;0.5,0.5,0.5,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;819;24.90001,203.3;Inherit;False;1226.633;651.0015;Simple Density;20;1185;1179;1035;963;931;920;914;910;907;906;905;899;896;893;892;885;884;883;882;881;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;820;3784.9,-1780.7;Inherit;False;2197.287;953.2202;Pattern;24;1218;1217;1195;1123;1092;1020;1013;978;969;966;965;958;954;942;938;929;926;919;918;917;916;915;908;904;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;2136.9,1931.3;Inherit;False;939.7803;621.1177;Lighting & Clipping;11;1196;1178;1177;1176;1175;1151;1114;1112;1110;1107;1054;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;822;40.90001,1003.3;Inherit;False;1813.036;453.4427;Final Detailing;17;1182;1181;1180;1066;1058;1048;1028;988;982;941;934;901;898;895;894;888;887;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;823;1320.9,-228.7;Inherit;False;1576.124;399.0991;Highlights;11;1204;1163;1143;1138;1135;1134;1131;1124;1122;1116;1102;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;824;-183.1,-1860.7;Inherit;False;2881.345;950.1069;Final Coloring;35;1210;1194;1173;1170;1169;1166;1165;1164;1162;1161;1160;1159;1158;1156;1155;1153;1150;1146;1145;1144;1142;1139;1137;1132;1130;1129;1128;1127;1126;1125;1115;1113;1101;1053;1018;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;825;-167.1,-2532.7;Inherit;False;1393.195;555.0131;Simple Radiance;8;1089;1087;1086;1084;1081;1080;1077;1072;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;826;72.90001,2811.3;Inherit;False;2200.287;555.4289;Main Noise;15;1200;1199;1198;1108;1097;1096;1095;1094;1085;1076;1075;1070;1047;1043;1012;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;827;8.90001,-260.7001;Inherit;False;1283.597;293.2691;Thickness Details;7;1203;1109;1105;1098;1090;1068;1052;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;828;3640.9,235.3;Inherit;False;2111.501;762.0129;;21;1212;1211;1186;1184;1183;1111;1061;1022;1021;1016;1014;1006;998;986;977;971;964;961;947;943;890;Cloud Border Block;1,0.5882353,0.685091,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;829;1304.9,347.2999;Inherit;False;1154;500;Complex Density;9;1206;1205;1000;984;979;959;956;952;925;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;830;1272.9,-2532.7;Inherit;False;1393.195;555.0131;Custom Radiance;5;1171;1167;1149;1141;1140;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;831;3448.9,1851.3;Inherit;False;2197.287;953.2202;Pattern;25;1216;1215;1202;1078;1067;1060;1055;1049;1041;1034;1029;1026;1015;1007;1005;1002;1001;997;994;993;992;987;981;949;944;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;832;3800.9,-772.7001;Inherit;False;1600.229;583.7008;Final;12;1192;1119;1118;1099;1062;1044;1024;1023;1017;1004;972;950;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;833;6392.9,-1780.7;Inherit;False;2197.287;953.2202;Pattern;25;1219;1214;1193;1033;1011;970;968;955;948;946;937;933;928;924;923;921;912;911;903;902;900;897;891;889;886;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;834;5096.9,2859.3;Inherit;False;916.8853;383.8425;Lighting & Clipping;6;1152;1136;1120;1117;1106;1104;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;835;6408.9,-772.7001;Inherit;False;1735.998;586.5895;Final;14;1191;1091;1064;1059;1038;1027;996;991;990;989;974;967;945;930;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;836;-199.1,-3236.7;Inherit;False;951.3906;629.7021;Final Alpha;10;1207;1174;1172;1168;1157;1154;1148;1147;1133;1100;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;837;-2807.1,-3252.7;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;838;-2647.1,-3268.7;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;839;-2855.1,-3428.7;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;840;-2951.1,-3268.7;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;841;-2647.1,-3444.7;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;842;-2055.1,-3492.7;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;843;-3959.1,-3028.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;844;-3895.1,-3172.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;845;-3703.1,-2788.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;846;-3895.1,-2852.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;847;-3703.1,-3108.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;848;-3591.1,-3108.7;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;849;-3367.1,-3524.7;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;850;-3431.1,-3108.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;851;-3591.1,-2788.7;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;852;-3655.1,-2660.7;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.3015023,0.9437417,0.1358237;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;853;-2919.1,-2980.7;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;854;-3959.1,-2708.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;855;-3431.1,-2788.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;856;-3303.1,-3108.7;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;857;-3303.1,-2788.7;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;858;-3079.1,-3108.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;859;-3079.1,-2788.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;860;-2791.1,-3108.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;861;-2615.1,-2980.7;Inherit;False;CloudLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;862;-2935.1,-2788.7;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;863;-2759.1,-2964.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;864;-3367.1,-3348.7;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;865;-2647.1,-3124.7;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;866;-2647.1,-2788.7;Half;False;MoonlightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;867;-2791.1,-2788.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;868;-2935.1,-3108.7;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;-2679.1,-3540.7;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;870;-3607.1,-3348.7;Inherit;False;Filter Color;-1;;5;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;871;-3655.1,-3524.7;Inherit;False;Filter Color;-1;;6;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;872;-2887.1,-3540.7;Inherit;False;Filter Color;-1;;7;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;873;-3911.1,-3524.7;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;True;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;0.04943931,0.07984611,0.1037736,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;874;-3911.1,-3348.7;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;1;2;[HideInInspector];[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.0752492,0.1315804,0.1792453,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;875;-3175.1,-2900.7;Half;False;Global;CZY_CloudFlareFalloff;CZY_CloudFlareFalloff;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;876;-3191.1,-2660.7;Half;False;Global;CZY_MoonFlareFalloff;CZY_MoonFlareFalloff;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.752;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;877;-3159.1,-3236.7;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;878;-3175.1,-2980.7;Half;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;879;-2359.1,-3492.7;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;5;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;880;-3639.1,-2980.7;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.423889,-0.9055932,0.01480246;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;881;72.90001,571.2999;Inherit;False;Constant;_CloudWind2;Cloud Wind 2;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;882;72.90001,507.2999;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;883;520.9,603.2999;Inherit;False;2;0;FLOAT;140;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;884;280.9,267.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;885;312.9,571.2999;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;886;6664.9,-1284.7;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;887;280.9,1211.3;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;888;72.90001,1179.3;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;889;6952.9,-1412.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;890;3784.9,507.2999;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;891;7016.9,-1556.7;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;892;712.9,539.2999;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;893;72.90001,299.2999;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;894;248.9,1099.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;895;584.9,1163.3;Inherit;True;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;896;520.9,715.2999;Inherit;False;2;0;FLOAT;500;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;897;7000.9,-1044.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;898;440.9,1259.3;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;899;712.9,683.2999;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;900;7016.9,-1636.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;901;440.9,1163.3;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;902;6920.9,-1236.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;903;6904.9,-1316.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;904;4056.899,-1284.7;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;905;520.9,491.2999;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;906;888.9,619.2999;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;907;312.9,443.2999;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;908;4520.9,-1412.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;909;6200.9,731.2999;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;910;504.9,283.3;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;911;7240.9,-1028.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;912;7128.9,-1412.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;913;6088.9,299.2999;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;914;504.9,379.2999;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;915;4408.9,-1556.7;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;916;4344.9,-1412.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;917;4408.9,-1636.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;918;4376.9,-964.7001;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;919;4280.9,-1316.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;920;1032.9,619.2999;Inherit;False;VoroDetails;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;921;7272.9,-1620.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;922;6024.9,459.2999;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;923;7144.9,-1252.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;924;7336.9,-1252.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;925;1320.9,507.2999;Inherit;False;920;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;926;4632.9,-1028.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;927;6440.9,379.2999;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;928;7672.9,-1012.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;929;4376.9,-1044.7;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;930;7528.9,-436.7001;Inherit;False;1018;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;931;696.9,283.3;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;932;6904.9,1099.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;933;7464.9,-1012.7;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;934;760.9,1147.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;935;6424.9,715.2999;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;936;6616.9,731.2999;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;937;7496.9,-1604.7;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;938;4728.9,-1412.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;939;6312.9,379.2999;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;940;7032.9,1099.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;941;920.9,1163.3;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;942;4616.9,-1252.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;943;3992.9,859.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;944;4392.9,2395.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;945;6472.9,-564.7001;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;946;7000.9,-964.7001;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;947;3992.9,747.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;948;8296.899,-1364.7;Inherit;False;CirrusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;949;4184.9,2219.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;950;3880.9,-564.7001;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;951;7192.9,1067.3;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;952;2216.9,443.2999;Inherit;False;ComplexCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;953;6872.9,619.2999;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;954;4872.9,-1604.7;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;955;7672.9,-1604.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;956;1496.9,507.2999;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;957;6488.9,507.2999;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;958;4856.9,-1012.7;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;959;1608.9,507.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;960;6664.9,379.2999;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;961;4168.9,827.2999;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;962;7128.9,971.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;963;920.9,283.3;Inherit;False;SimpleCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;964;4152.9,747.2999;Inherit;False;BorderHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;965;5064.9,-1012.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;966;5288.9,-1252.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;967;6824.9,-564.7001;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;968;7896.9,-1236.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;969;5064.9,-1604.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;970;7896.9,-1460.7;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;971;4008.9,507.2999;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;972;4104.9,-564.7001;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;973;184.9,2635.3;Inherit;False;1;0;FLOAT;0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;974;6664.9,-564.7001;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;975;7352.9,971.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;976;392.9,2523.3;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;977;4360.9,827.2999;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;978;5288.9,-1476.7;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;979;1528.9,427.2999;Inherit;False;963;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;980;7352.9,1067.3;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;981;4040.9,2587.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;982;1112.9,1163.3;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;983;7048.9,539.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;984;1864.9,683.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;985;408.9,2379.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;986;4360.9,731.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;987;3720.9,2347.3;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;988;1272.9,1067.3;Inherit;False;CloudDetail;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;989;7144.9,-660.7001;Inherit;False;948;CirrusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;990;7224.9,-564.7001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;991;7384.9,-500.7001;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;992;4072.899,1995.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;993;4056.899,2667.3;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;994;4008.9,2219.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;995;7544.9,907.2999;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;996;6968.9,-564.7001;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;997;3944.9,2315.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;998;4568.9,491.2999;Inherit;False;963;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;999;568.9,2427.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1000;2040.9,459.2999;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1001;3960.9,2411.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1002;4072.899,2075.3;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1003;7576.9,795.2999;Inherit;False;963;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1004;4424.9,-564.7001;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1005;4296.9,2619.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1006;4792.9,443.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;1007;4184.9,2379.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1008;7816.9,907.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1009;744.9,2427.3;Inherit;True;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;1010;7624.9,699.2999;Inherit;False;988;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1011;8072.9,-1348.7;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1012;312.9,3147.3;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1013;5464.9,-1364.7;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1014;4616.9,411.2999;Inherit;False;988;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1015;4312.9,2027.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1016;4952.9,555.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1017;4280.9,-564.7001;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1018;1944.9,-1220.7;Inherit;False;Clipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1019;7800.9,747.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1020;5688.9,-1364.7;Inherit;False;ChemtrailsPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1021;4824.9,587.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1022;4200.9,507.2999;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1023;4536.9,-660.7001;Inherit;False;1020;ChemtrailsPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1024;4600.9,-564.7001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1025;968.9001,2379.3;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1026;4520.9,2619.3;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1027;7384.9,-628.7001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1028;1000.9,1067.3;Inherit;False;952;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1029;4376.9,2219.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1030;7960.9,843.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1031;1096.9,2155.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1032;1032.9,2603.3;Inherit;False;2;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1033;7336.9,-1412.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1034;4536.9,2027.3;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1035;888.9,539.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1036;8248.899,859.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1037;888.9,2139.3;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1038;7544.9,-532.7001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1039;1240.9,2155.3;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1040;8104.9,843.2999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1041;4728.9,2619.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1042;1304.9,2379.3;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;12.27;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;1043;472.9,2939.3;Inherit;False;841;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;1044;4760.9,-356.7001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1045;152.9,2059.3;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1046;3544.9,3083.3;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1047;504.9,3067.3;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1048;1272.9,1147.3;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1049;4728.9,2027.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1050;568.9,2075.3;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1051;3944.9,3083.3;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1052;744.9,-212.7;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;1053;1960.9,-1364.7;Inherit;False;1207;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1054;2616.9,2315.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1055;4952.9,2395.3;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1056;1400.9,2155.3;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1057;3768.9,3083.3;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1058;1480.9,1147.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1059;7720.9,-532.7001;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1060;4952.9,2171.3;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;1061;5304.9,587.2999;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1062;5160.9,-532.7001;Inherit;False;ChemtrailsFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1063;4648.9,3099.3;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5754717;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1064;7896.9,-532.7001;Inherit;False;CirrusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1065;1560.9,2155.3;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1066;1640.9,1131.3;Inherit;False;DetailedClouds;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1067;5128.9,2283.3;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1068;568.9,-100.7;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1069;4472.9,3275.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1070;712.9,3131.3;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1071;4088.9,3083.3;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1072;152.9,-2132.7;Inherit;False;1064;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1073;4200.9,2971.3;Inherit;False;1078;CirrostratPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1074;4280.9,3083.3;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1075;1224.9,3003.3;Inherit;True;2;4;0;FLOAT;0.1;False;1;FLOAT;0.3;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1076;1048.9,3115.3;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.15;False;3;FLOAT;0.5;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1077;104.9,-2356.7;Inherit;False;1211;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1078;5352.9,2283.3;Inherit;False;CirrostratPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1079;1736.9,2155.3;Inherit;False;AltoCumulusPlacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1080;104.9,-2276.7;Inherit;False;1088;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1081;376.9,-2340.7;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1082;4328.9,3275.3;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1083;4168.9,3275.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1084;136.9,-2436.7;Inherit;False;1066;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1085;1224.9,2923.3;Inherit;False;1079;AltoCumulusPlacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1086;136.9,-2196.7;Inherit;False;1062;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1087;680.9,-2340.7;Inherit;False;SimpleRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1088;8424.899,859.2999;Inherit;True;NimbusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1089;536.9,-2324.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1090;520.9,-212.7;Inherit;False;920;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1091;7672.9,-644.7001;Inherit;False;CirrusLightTransport;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1092;4648.9,-1620.7;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1093;4440.9,3003.3;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1094;648.9,2955.3;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;1095;840.9,3019.3;Inherit;True;0;0;1;0;2;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;51.2;False;2;FLOAT;3;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1096;1464.9,2939.3;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1097;1624.9,2939.3;Inherit;True;2;4;0;FLOAT;0.1;False;1;FLOAT;0.2;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1098;728.9,-100.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1099;5000.9,-532.7001;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1100;-151.1,-3012.7;Inherit;False;1108;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1101;824.9,-1188.7;Inherit;False;1087;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1102;1720.9,-100.7;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1103;4824.9,3099.3;Inherit;False;CirrostratLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1104;5160.9,3147.3;Inherit;False;1018;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1105;888.9,-180.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1106;5144.9,3051.3;Inherit;False;1087;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1107;2216.9,2459.3;Inherit;False;1018;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1108;1896.9,2955.3;Inherit;False;AltoCumulusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1109;1016.9,-196.7;Inherit;False;CloudThicknessDetails;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1110;2200.9,2379.3;Inherit;False;1087;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1111;5160.9,571.2999;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1112;2424.9,2379.3;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1113;136.9,-1028.7;Inherit;False;1109;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1114;2296.9,2283.3;Inherit;False;1108;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1115;-103.1,-1588.7;Inherit;False;952;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1116;2056.9,-148.7;Inherit;False;864;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;1117;5368.9,3051.3;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1118;4616.9,-356.7001;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1119;4776.9,-628.7001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1120;5240.9,2971.3;Inherit;False;1103;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1121;376.9,2059.3;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1122;1832.9,75.30001;Inherit;False;861;CloudLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1123;4296.9,-1236.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1124;1832.9,-4.700002;Inherit;False;988;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1125;120.9,-1300.7;Inherit;False;1109;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1126;136.9,-1588.7;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1127;280.9,-1684.7;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1128;328.9,-1492.7;Inherit;False;865;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1129;280.9,-1396.7;Inherit;False;864;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1130;328.9,-1588.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1131;2504.9,-100.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1132;1080.9,-1348.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1133;200.9,-3028.7;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1134;2664.9,-100.7;Inherit;False;SunThroughClouds;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1135;1864.9,-100.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1136;5704.9,2987.3;Inherit;False;CSCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1137;296.9,-1124.7;Inherit;False;869;MoonlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1138;2296.9,27.3;Inherit;False;Constant;_2;2;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1139;520.9,-1412.7;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1140;1512.9,-2228.7;Inherit;False;1136;CSCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1141;1512.9,-2324.7;Inherit;False;1151;ACCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1142;504.9,-1668.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1143;2296.9,-116.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1144;696.9,-1364.7;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1145;536.9,-1140.7;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;1146;2184.9,-1460.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1147;-71.10001,-2772.7;Inherit;False;1064;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1148;-135.1,-2852.7;Inherit;False;1103;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1149;1800.9,-2276.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1150;872.9,-1380.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5660378,0.5660378,0.5660378,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1151;2760.9,2315.3;Inherit;False;ACCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1152;5560.9,2987.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1153;312.9,-1204.7;Inherit;False;866;MoonlightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1154;-119.1,-2692.7;Inherit;False;1088;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1155;696.9,-1508.7;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1156;776.9,-1284.7;Inherit;False;1109;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1157;-87.10001,-2932.7;Inherit;False;1062;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1158;1784.9,-1444.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1159;1528.9,-1252.7;Inherit;False;1167;CustomRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1160;232.9,-1764.7;Inherit;False;864;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1161;376.9,-1028.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1162;1496.9,-1444.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1163;2056.9,-68.69998;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1164;1048.9,-1604.7;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1165;1032.9,-1492.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1166;1256.9,-1348.7;Inherit;False;1134;SunThroughClouds;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1167;2104.9,-2292.7;Inherit;False;CustomRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1168;344.9,-3012.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1169;1256.9,-1476.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1170;1496.9,-1316.7;Inherit;False;1177;CirrusCustomLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1171;1944.9,-2276.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1172;-119.1,-3108.7;Inherit;False;1211;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1173;360.9,-1300.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1174;-87.10001,-3188.7;Inherit;False;1066;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1175;2664.9,2059.3;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.7159576,0.8624095,0.8773585,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1176;2472.9,1995.3;Inherit;False;849;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1177;2824.9,2059.3;Inherit;False;CirrusCustomLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1178;2392.9,2107.3;Inherit;False;Filter Color;-1;;8;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;1179;72.90001,379.2999;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1180;264.9,1323.3;Inherit;False;Global;CZY_DetailScale;CZY_DetailScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1181;920.9,1323.3;Inherit;False;Global;CZY_DetailAmount;CZY_DetailAmount;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1182;72.90001,1291.3;Inherit;False;Constant;_DetailWind;Detail Wind;17;0;Create;True;0;0;0;False;0;False;0.3,0.2;0.3,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1183;3720.9,859.2999;Inherit;False;Global;CZY_BorderVariation;CZY_BorderVariation;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1184;3720.9,747.2999;Inherit;False;Global;CZY_BorderHeight;CZY_BorderHeight;4;2;[HideInInspector];[Header];Create;False;1;Border Clouds;0;0;False;0;False;1;0.553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1185;264.9,363.2999;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;10;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1186;4840.9,699.2999;Inherit;False;Global;CZY_BorderEffect;CZY_BorderEffect;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1187;6600.9,619.2999;Inherit;False;Global;CZY_NimbusHeight;CZY_NimbusHeight;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1188;6296.9,523.2999;Inherit;False;Global;CZY_StormDirection;CZY_StormDirection;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;-0.9819781,0,-0.1889948;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1189;6760.9,987.2999;Inherit;False;Global;CZY_NimbusMultiplier;CZY_NimbusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Nimbus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1190;6632.9,1099.3;Inherit;False;Global;CZY_NimbusVariation;CZY_NimbusVariation;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.945;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1191;7016.9,-324.7001;Inherit;False;Global;CZY_CirrusMultiplier;CZY_CirrusMultiplier;11;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1192;4328.9,-356.7001;Inherit;False;Global;CZY_ChemtrailsMultiplier;CZY_ChemtrailsMultiplier;14;1;[HideInInspector];Create;False;1;Chemtrails;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1193;6424.9,-1284.7;Inherit;False;Global;CZY_CirrusMoveSpeed;CZY_CirrusMoveSpeed;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.297;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1194;1640.9,-1108.7;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1195;3816.9,-1284.7;Inherit;False;Global;CZY_ChemtrailsMoveSpeed;CZY_ChemtrailsMoveSpeed;15;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.289;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1196;2168.9,2107.3;Inherit;False;Global;CZY_AltoCloudColor;CZY_AltoCloudColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.675705,1.909993,2.279378,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;1197;184.9,2379.3;Inherit;False;Constant;_ACMoveSpeed;ACMoveSpeed;14;0;Create;True;0;0;0;False;0;False;1,-2;5,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;1198;232.9,3019.3;Inherit;False;Global;CZY_AltocumulusWindSpeed;CZY_AltocumulusWindSpeed;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,-2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1199;456.9,3243.3;Inherit;False;Global;CZY_AltocumulusScale;CZY_AltocumulusScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;3;0.371;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1200;1224.9,3227.3;Inherit;False;Global;CZY_AltocumulusMultiplier;CZY_AltocumulusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Altocumulus Clouds;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1201;3896.9,3275.3;Inherit;False;Global;CZY_CirrostratusMultiplier;CZY_CirrostratusMultiplier;4;2;[HideInInspector];[Header];Create;False;1;Cirrostratus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1202;3480.9,2347.3;Inherit;False;Global;CZY_CirrostratusMoveSpeed;CZY_CirrostratusMoveSpeed;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.281;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1203;344.9,-100.7;Inherit;False;842;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1204;1480.9,-100.7;Inherit;False;842;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1205;1640.9,683.2999;Inherit;False;842;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1206;1816.9,459.2999;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1207;520.9,-3028.7;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1208;-1495.1,-484.7001;Inherit;False;1207;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1209;-983.1,-612.7001;Inherit;False;1210;FinalCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1210;2408.9,-1460.7;Inherit;False;FinalCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1211;5448.9,587.2999;Inherit;False;BorderLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1212;4552.9,587.2999;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1213;-1463.1,-340.7001;Inherit;False;Global;CZY_CloudThickness;CZY_CloudThickness;6;1;[HDR];Create;False;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1216;4584.9,2187.3;Inherit;True;Global;CZY_CirrostratusTexture;CirrostratusTexture;1;0;Create;False;0;0;0;False;0;False;-1;bf43c8d7b74e204469465f36dfff7d6a;bf43c8d7b74e204469465f36dfff7d6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1217;4920.9,-1460.7;Inherit;True;Global;CZY_ChemtrailsTexture;CZY_ChemtrailsTexture;2;0;Create;False;0;0;0;False;0;False;-1;9b3476b4df9abf8479476bae1bcd8a84;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1219;7528.9,-1444.7;Inherit;True;Global;CZY_CirrusTexture;CZY_CirrusTexture;0;0;Create;True;0;0;0;False;0;False;-1;None;302629ebb64a0e345948779662fc2cf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1220;-3127.1,-3540.7;Inherit;False;Global;CZY_CloudMoonColor;CZY_CloudMoonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.0517088,0.07180047,0.1320755,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1218;4920.9,-1252.7;Inherit;True;Property;_ChemtrailsTex2;Chemtrails Tex 2;2;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1217;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1214;7528.9,-1236.7;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1219;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1215;4584.9,2395.3;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1216;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;0;2;1209;0
WireConnection;0;9;808;0
WireConnection;806;0;1208;0
WireConnection;806;2;1213;0
WireConnection;807;0;1208;0
WireConnection;807;1;806;0
WireConnection;808;0;807;0
WireConnection;837;0;840;0
WireConnection;838;0;837;0
WireConnection;840;1;877;0
WireConnection;841;0;839;0
WireConnection;842;0;879;0
WireConnection;845;0;846;0
WireConnection;845;1;854;0
WireConnection;847;0;844;0
WireConnection;847;1;843;0
WireConnection;848;0;847;0
WireConnection;849;0;871;0
WireConnection;850;0;848;0
WireConnection;850;1;880;0
WireConnection;851;0;845;0
WireConnection;853;0;858;0
WireConnection;853;1;875;0
WireConnection;855;0;851;0
WireConnection;855;1;852;0
WireConnection;856;0;850;0
WireConnection;857;0;855;0
WireConnection;858;0;856;0
WireConnection;859;0;857;0
WireConnection;860;0;868;0
WireConnection;861;0;863;0
WireConnection;862;0;859;0
WireConnection;862;1;876;0
WireConnection;863;0;853;0
WireConnection;864;0;870;0
WireConnection;865;0;860;0
WireConnection;866;0;867;0
WireConnection;867;0;862;0
WireConnection;868;0;858;0
WireConnection;868;1;878;0
WireConnection;869;0;872;0
WireConnection;870;1;874;0
WireConnection;871;1;873;0
WireConnection;872;1;1220;0
WireConnection;883;1;1185;0
WireConnection;885;0;882;0
WireConnection;885;1;881;0
WireConnection;886;0;1193;0
WireConnection;887;0;888;0
WireConnection;887;1;1182;0
WireConnection;892;0;905;0
WireConnection;892;2;883;0
WireConnection;895;0;901;0
WireConnection;895;2;898;0
WireConnection;896;1;1185;0
WireConnection;898;1;1180;0
WireConnection;899;0;905;0
WireConnection;899;2;896;0
WireConnection;901;0;894;0
WireConnection;901;1;887;0
WireConnection;902;0;886;0
WireConnection;903;0;886;0
WireConnection;904;0;1195;0
WireConnection;905;0;884;0
WireConnection;905;1;885;0
WireConnection;906;0;892;0
WireConnection;906;1;899;0
WireConnection;907;0;893;0
WireConnection;907;1;1179;0
WireConnection;908;0;916;0
WireConnection;908;2;919;0
WireConnection;910;0;884;0
WireConnection;910;1;907;0
WireConnection;911;0;897;0
WireConnection;911;2;946;0
WireConnection;912;0;889;0
WireConnection;912;2;903;0
WireConnection;914;1;1185;0
WireConnection;919;0;904;0
WireConnection;920;0;906;0
WireConnection;921;0;900;0
WireConnection;921;2;891;0
WireConnection;923;0;889;0
WireConnection;923;2;902;0
WireConnection;924;0;923;0
WireConnection;926;0;929;0
WireConnection;926;2;918;0
WireConnection;927;0;939;0
WireConnection;928;0;933;0
WireConnection;931;0;910;0
WireConnection;931;1;914;0
WireConnection;932;0;1190;0
WireConnection;933;0;911;0
WireConnection;934;0;895;0
WireConnection;935;0;909;0
WireConnection;936;0;935;0
WireConnection;936;1;935;0
WireConnection;937;0;921;0
WireConnection;938;0;908;0
WireConnection;939;0;913;0
WireConnection;939;1;922;0
WireConnection;940;0;932;0
WireConnection;941;0;934;0
WireConnection;942;0;916;0
WireConnection;942;2;1123;0
WireConnection;943;0;1183;0
WireConnection;944;0;1007;0
WireConnection;947;0;1184;0
WireConnection;948;0;1011;0
WireConnection;949;0;994;0
WireConnection;949;2;997;0
WireConnection;951;1;940;0
WireConnection;952;0;1000;0
WireConnection;953;0;1187;0
WireConnection;953;2;936;0
WireConnection;954;0;1092;0
WireConnection;955;0;937;0
WireConnection;956;0;925;0
WireConnection;957;0;1188;0
WireConnection;958;0;926;0
WireConnection;959;0;956;0
WireConnection;960;0;927;0
WireConnection;960;1;957;0
WireConnection;961;1;943;0
WireConnection;962;0;1189;0
WireConnection;963;0;931;0
WireConnection;964;0;947;0
WireConnection;965;0;958;0
WireConnection;966;0;1218;0
WireConnection;966;1;965;0
WireConnection;967;0;974;0
WireConnection;967;1;974;0
WireConnection;968;0;1214;0
WireConnection;968;1;928;0
WireConnection;969;0;954;0
WireConnection;970;0;955;0
WireConnection;970;1;1219;0
WireConnection;971;0;890;0
WireConnection;972;0;950;0
WireConnection;974;0;945;0
WireConnection;975;0;962;0
WireConnection;975;1;951;0
WireConnection;976;0;1197;0
WireConnection;976;1;973;0
WireConnection;977;0;961;0
WireConnection;978;0;969;0
WireConnection;978;1;1217;0
WireConnection;980;0;951;0
WireConnection;982;0;941;0
WireConnection;982;2;1181;0
WireConnection;983;0;960;0
WireConnection;983;1;953;0
WireConnection;984;0;1205;0
WireConnection;986;0;964;0
WireConnection;986;1;961;0
WireConnection;987;0;1202;0
WireConnection;988;0;982;0
WireConnection;990;0;996;0
WireConnection;991;0;1191;0
WireConnection;995;0;983;0
WireConnection;995;3;975;0
WireConnection;995;4;980;0
WireConnection;996;0;967;0
WireConnection;997;0;987;0
WireConnection;999;0;985;0
WireConnection;999;2;976;0
WireConnection;1000;0;1206;0
WireConnection;1000;1;984;0
WireConnection;1001;0;987;0
WireConnection;1004;0;1017;0
WireConnection;1005;0;981;0
WireConnection;1005;2;993;0
WireConnection;1006;0;1014;0
WireConnection;1006;1;998;0
WireConnection;1007;0;994;0
WireConnection;1007;2;1001;0
WireConnection;1008;0;995;0
WireConnection;1009;0;999;0
WireConnection;1011;0;970;0
WireConnection;1011;1;968;0
WireConnection;1013;0;978;0
WireConnection;1013;1;966;0
WireConnection;1015;0;992;0
WireConnection;1015;2;1002;0
WireConnection;1016;0;1006;0
WireConnection;1016;1;1021;0
WireConnection;1017;0;972;0
WireConnection;1017;1;972;0
WireConnection;1018;0;1194;0
WireConnection;1019;0;1010;0
WireConnection;1019;1;1003;0
WireConnection;1020;0;1013;0
WireConnection;1021;0;1212;0
WireConnection;1022;0;971;0
WireConnection;1022;1;971;0
WireConnection;1024;0;1004;0
WireConnection;1025;0;1009;0
WireConnection;1026;0;1005;0
WireConnection;1027;0;989;0
WireConnection;1027;1;990;0
WireConnection;1029;0;949;0
WireConnection;1030;0;1019;0
WireConnection;1030;1;1008;0
WireConnection;1032;1;973;0
WireConnection;1033;0;912;0
WireConnection;1034;0;1015;0
WireConnection;1035;0;892;0
WireConnection;1036;0;1040;0
WireConnection;1037;0;1050;0
WireConnection;1038;0;1027;0
WireConnection;1038;1;991;0
WireConnection;1039;0;1031;0
WireConnection;1039;1;1025;0
WireConnection;1040;0;1030;0
WireConnection;1041;0;1026;0
WireConnection;1042;1;1032;0
WireConnection;1044;0;1118;0
WireConnection;1047;0;1198;0
WireConnection;1047;1;1012;0
WireConnection;1048;0;1028;0
WireConnection;1048;1;982;0
WireConnection;1049;0;1034;0
WireConnection;1050;0;1121;0
WireConnection;1050;1;1121;0
WireConnection;1051;0;1057;0
WireConnection;1051;1;1057;0
WireConnection;1052;0;1090;0
WireConnection;1054;0;1114;0
WireConnection;1054;1;1112;0
WireConnection;1055;0;1215;0
WireConnection;1055;1;1041;0
WireConnection;1056;0;1039;0
WireConnection;1056;1;1042;0
WireConnection;1057;0;1046;0
WireConnection;1058;0;1048;0
WireConnection;1059;0;1038;0
WireConnection;1059;1;930;0
WireConnection;1060;0;1049;0
WireConnection;1060;1;1216;0
WireConnection;1061;0;1111;0
WireConnection;1062;0;1099;0
WireConnection;1063;0;1093;0
WireConnection;1063;1;1069;0
WireConnection;1064;0;1059;0
WireConnection;1065;0;1056;0
WireConnection;1066;0;1058;0
WireConnection;1067;0;1060;0
WireConnection;1067;1;1055;0
WireConnection;1068;0;1203;0
WireConnection;1069;0;1082;0
WireConnection;1070;1;1199;0
WireConnection;1071;0;1051;0
WireConnection;1074;0;1071;0
WireConnection;1075;1;1095;0
WireConnection;1075;2;1076;0
WireConnection;1076;0;1095;0
WireConnection;1078;0;1067;0
WireConnection;1079;0;1065;0
WireConnection;1081;0;1084;0
WireConnection;1081;1;1077;0
WireConnection;1081;2;1080;0
WireConnection;1081;3;1086;0
WireConnection;1081;4;1072;0
WireConnection;1082;0;1083;0
WireConnection;1083;0;1201;0
WireConnection;1087;0;1089;0
WireConnection;1088;0;1036;0
WireConnection;1089;0;1081;0
WireConnection;1091;0;1027;0
WireConnection;1092;0;917;0
WireConnection;1092;2;915;0
WireConnection;1093;0;1073;0
WireConnection;1093;1;1074;0
WireConnection;1094;0;1043;0
WireConnection;1094;2;1047;0
WireConnection;1095;0;1094;0
WireConnection;1095;2;1070;0
WireConnection;1096;0;1085;0
WireConnection;1096;1;1075;0
WireConnection;1096;2;1200;0
WireConnection;1097;0;1096;0
WireConnection;1098;0;1068;0
WireConnection;1099;0;1119;0
WireConnection;1099;1;1044;0
WireConnection;1102;0;1204;0
WireConnection;1103;0;1063;0
WireConnection;1105;0;1052;1
WireConnection;1105;1;1098;0
WireConnection;1108;0;1097;0
WireConnection;1109;0;1105;0
WireConnection;1111;0;1016;0
WireConnection;1111;2;1186;0
WireConnection;1112;0;1110;0
WireConnection;1112;1;1107;0
WireConnection;1117;0;1106;0
WireConnection;1117;1;1104;0
WireConnection;1118;0;1192;0
WireConnection;1119;0;1023;0
WireConnection;1119;1;1024;0
WireConnection;1121;0;1045;0
WireConnection;1123;0;904;0
WireConnection;1126;0;1115;0
WireConnection;1130;0;1126;0
WireConnection;1131;0;1143;0
WireConnection;1131;1;1138;0
WireConnection;1132;0;1101;0
WireConnection;1133;0;1174;0
WireConnection;1133;1;1172;0
WireConnection;1133;2;1100;0
WireConnection;1133;3;1157;0
WireConnection;1133;4;1148;0
WireConnection;1133;5;1147;0
WireConnection;1133;6;1154;0
WireConnection;1134;0;1131;0
WireConnection;1135;0;1102;0
WireConnection;1136;0;1152;0
WireConnection;1139;0;1128;0
WireConnection;1139;1;1129;0
WireConnection;1139;2;1173;0
WireConnection;1142;0;1160;0
WireConnection;1142;1;1127;0
WireConnection;1142;2;1130;0
WireConnection;1143;1;1116;0
WireConnection;1143;2;1163;0
WireConnection;1145;0;1153;0
WireConnection;1145;1;1137;0
WireConnection;1145;2;1161;0
WireConnection;1146;0;1158;0
WireConnection;1146;1;1053;0
WireConnection;1146;2;1018;0
WireConnection;1149;0;1141;0
WireConnection;1149;1;1140;0
WireConnection;1150;0;1144;0
WireConnection;1151;0;1054;0
WireConnection;1152;0;1120;0
WireConnection;1152;1;1117;0
WireConnection;1155;0;1142;0
WireConnection;1155;1;1139;0
WireConnection;1155;2;1145;0
WireConnection;1158;0;1162;0
WireConnection;1158;1;1170;0
WireConnection;1158;2;1159;0
WireConnection;1161;0;1113;0
WireConnection;1162;0;1169;0
WireConnection;1162;1;1166;0
WireConnection;1163;0;1135;0
WireConnection;1163;1;1124;0
WireConnection;1163;2;1122;0
WireConnection;1165;0;1155;0
WireConnection;1165;1;1150;0
WireConnection;1165;2;1156;0
WireConnection;1167;0;1171;0
WireConnection;1168;0;1133;0
WireConnection;1169;0;1164;0
WireConnection;1169;1;1165;0
WireConnection;1169;2;1132;0
WireConnection;1171;0;1149;0
WireConnection;1173;0;1125;0
WireConnection;1175;0;1176;0
WireConnection;1175;1;1178;0
WireConnection;1177;0;1175;0
WireConnection;1178;1;1196;0
WireConnection;1206;0;979;0
WireConnection;1206;1;959;0
WireConnection;1207;0;1168;0
WireConnection;1210;0;1158;0
WireConnection;1211;0;1061;0
WireConnection;1212;0;1022;0
WireConnection;1212;3;986;0
WireConnection;1212;4;977;0
WireConnection;1216;1;1029;0
WireConnection;1217;1;938;0
WireConnection;1219;1;1033;0
WireConnection;1218;1;942;0
WireConnection;1214;1;924;0
WireConnection;1215;1;944;0
ASEEND*/
//CHKSM=CB7624296934720F30177D2D3C7310912EF0241A