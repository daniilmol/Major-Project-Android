// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Desktop"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent-50" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		Stencil
		{
			Ref 221
			Comp Always
			Pass Replace
		}
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows exclude_path:deferred nofog 
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
		uniform half CZY_CloudMoonFalloff;
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
		uniform float4 CZY_AltoCloudColor;
		uniform sampler2D CZY_AltocumulusTexture;
		uniform float2 CZY_AltocumulusWindSpeed;
		uniform float CZY_AltocumulusScale;
		uniform float CZY_AltocumulusMultiplier;
		uniform sampler2D CZY_CirrostratusTexture;
		uniform float CZY_CirrostratusMoveSpeed;
		uniform float CZY_CirrostratusMultiplier;


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


		float2 voronoihash879( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi879( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash879( n + g );
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


		float2 voronoihash886( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi886( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash886( n + g );
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


		float2 voronoihash882( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi882( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash882( n + g );
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


		float2 voronoihash998( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi998( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash998( n + g );
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


		float2 voronoihash1030( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1030( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash1030( n + g );
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
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor839 = ( temp_output_10_0_g2 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g1 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
			float4 CloudHighlightColor853 = ( temp_output_10_0_g1 * CZY_SunFilterColor );
			float2 Pos831 = i.uv_texcoord;
			float mulTime827 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float TIme828 = mulTime827;
			float simplePerlin2D1207 = snoise( ( Pos831 + ( TIme828 * float2( 0.2,-0.4 ) ) )*( 100.0 / CZY_MainCloudScale ) );
			simplePerlin2D1207 = simplePerlin2D1207*0.5 + 0.5;
			float SimpleCloudDensity951 = simplePerlin2D1207;
			float time879 = 0.0;
			float2 voronoiSmoothId879 = 0;
			float2 temp_output_892_0 = ( Pos831 + ( TIme828 * float2( 0.3,0.2 ) ) );
			float2 coords879 = temp_output_892_0 * ( 140.0 / CZY_MainCloudScale );
			float2 id879 = 0;
			float2 uv879 = 0;
			float voroi879 = voronoi879( coords879, time879, id879, uv879, 0, voronoiSmoothId879 );
			float time886 = 0.0;
			float2 voronoiSmoothId886 = 0;
			float2 coords886 = temp_output_892_0 * ( 500.0 / CZY_MainCloudScale );
			float2 id886 = 0;
			float2 uv886 = 0;
			float voroi886 = voronoi886( coords886, time886, id886, uv886, 0, voronoiSmoothId886 );
			float2 appendResult893 = (float2(voroi879 , voroi886));
			float2 VoroDetails907 = appendResult893;
			float CumulusCoverage832 = CZY_CumulusCoverageMultiplier;
			float ComplexCloudDensity939 = (0.0 + (min( SimpleCloudDensity951 , ( 1.0 - VoroDetails907.x ) ) - ( 1.0 - CumulusCoverage832 )) * (1.0 - 0.0) / (1.0 - ( 1.0 - CumulusCoverage832 )));
			float4 lerpResult1113 = lerp( CloudHighlightColor853 , CloudColor839 , saturate( (2.0 + (ComplexCloudDensity939 - 0.0) * (0.7 - 2.0) / (1.0 - 0.0)) ));
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult838 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult840 = dot( normalizeResult838 , CZY_SunDirection );
			float temp_output_847_0 = abs( (dotResult840*0.5 + 0.5) );
			half LightMask854 = saturate( pow( temp_output_847_0 , CZY_SunFlareFalloff ) );
			float CloudThicknessDetails1084 = ( VoroDetails907.y * saturate( ( CumulusCoverage832 - 0.8 ) ) );
			float3 normalizeResult841 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult844 = dot( normalizeResult841 , CZY_MoonDirection );
			half MoonlightMask855 = saturate( pow( abs( (dotResult844*0.5 + 0.5) ) , CZY_CloudMoonFalloff ) );
			float3 hsvTorgb2_g3 = RGBToHSV( CZY_CloudMoonColor.rgb );
			float3 hsvTorgb3_g3 = HSVToRGB( float3(hsvTorgb2_g3.x,saturate( ( hsvTorgb2_g3.y + CZY_FilterSaturation ) ),( hsvTorgb2_g3.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g3 = ( float4( hsvTorgb3_g3 , 0.0 ) * CZY_FilterColor );
			float4 MoonlightColor858 = ( temp_output_10_0_g3 * CZY_CloudFilterColor );
			float4 lerpResult1136 = lerp( ( lerpResult1113 + ( LightMask854 * CloudHighlightColor853 * ( 1.0 - CloudThicknessDetails1084 ) ) + ( MoonlightMask855 * MoonlightColor858 * ( 1.0 - CloudThicknessDetails1084 ) ) ) , ( CloudColor839 * float4( 0.5660378,0.5660378,0.5660378,0 ) ) , CloudThicknessDetails1084);
			float time882 = 0.0;
			float2 voronoiSmoothId882 = 0;
			float2 coords882 = ( Pos831 + ( TIme828 * float2( 0.3,0.2 ) ) ) * ( 100.0 / CZY_DetailScale );
			float2 id882 = 0;
			float2 uv882 = 0;
			float fade882 = 0.5;
			float voroi882 = 0;
			float rest882 = 0;
			for( int it882 = 0; it882 <3; it882++ ){
			voroi882 += fade882 * voronoi882( coords882, time882, id882, uv882, 0,voronoiSmoothId882 );
			rest882 += fade882;
			coords882 *= 2;
			fade882 *= 0.5;
			}//Voronoi882
			voroi882 /= rest882;
			float temp_output_971_0 = ( (0.0 + (( 1.0 - voroi882 ) - 0.3) * (0.5 - 0.0) / (1.0 - 0.3)) * 0.1 * CZY_DetailAmount );
			float DetailedClouds1050 = saturate( ( ComplexCloudDensity939 + temp_output_971_0 ) );
			float CloudDetail977 = temp_output_971_0;
			float2 temp_output_959_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1010 = dot( temp_output_959_0 , temp_output_959_0 );
			float BorderHeight952 = ( 1.0 - CZY_BorderHeight );
			float temp_output_949_0 = ( -2.0 * ( 1.0 - CZY_BorderVariation ) );
			float clampResult1045 = clamp( ( ( ( CloudDetail977 + SimpleCloudDensity951 ) * saturate( (( BorderHeight952 * temp_output_949_0 ) + (dotResult1010 - 0.0) * (( temp_output_949_0 * -4.0 ) - ( BorderHeight952 * temp_output_949_0 )) / (0.5 - 0.0)) ) ) * 10.0 * CZY_BorderEffect ) , -1.0 , 1.0 );
			float BorderLightTransport1076 = clampResult1045;
			float3 normalizeResult914 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float3 normalizeResult944 = normalize( CZY_StormDirection );
			float dotResult948 = dot( normalizeResult914 , normalizeResult944 );
			float2 temp_output_922_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult923 = dot( temp_output_922_0 , temp_output_922_0 );
			float temp_output_938_0 = ( -2.0 * ( 1.0 - ( CZY_NimbusVariation * 0.9 ) ) );
			float NimbusLightTransport1067 = saturate( ( ( ( CloudDetail977 + SimpleCloudDensity951 ) * saturate( (( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_938_0 ) + (( dotResult948 + ( CZY_NimbusHeight * 4.0 * dotResult923 ) ) - 0.5) * (( temp_output_938_0 * -4.0 ) - ( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_938_0 )) / (7.0 - 0.5)) ) ) * 10.0 ) );
			float mulTime902 = _Time.y * 0.01;
			float simplePerlin2D941 = snoise( (Pos831*1.0 + mulTime902)*2.0 );
			float mulTime891 = _Time.y * CZY_ChemtrailsMoveSpeed;
			float cos895 = cos( ( mulTime891 * 0.01 ) );
			float sin895 = sin( ( mulTime891 * 0.01 ) );
			float2 rotator895 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos895 , -sin895 , sin895 , cos895 )) + float2( 0.5,0.5 );
			float cos929 = cos( ( mulTime891 * -0.02 ) );
			float sin929 = sin( ( mulTime891 * -0.02 ) );
			float2 rotator929 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos929 , -sin929 , sin929 , cos929 )) + float2( 0.5,0.5 );
			float mulTime905 = _Time.y * 0.01;
			float simplePerlin2D945 = snoise( (Pos831*1.0 + mulTime905)*4.0 );
			float4 ChemtrailsPattern1008 = ( ( saturate( simplePerlin2D941 ) * tex2D( CZY_ChemtrailsTexture, (rotator895*0.5 + 0.0) ) ) + ( tex2D( CZY_ChemtrailsTexture, rotator929 ) * saturate( simplePerlin2D945 ) ) );
			float2 temp_output_960_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1005 = dot( temp_output_960_0 , temp_output_960_0 );
			float ChemtrailsFinal1046 = ( ( ChemtrailsPattern1008 * saturate( (0.4 + (dotResult1005 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - ( CZY_ChemtrailsMultiplier * 0.5 ) ) ? 1.0 : 0.0 );
			float mulTime878 = _Time.y * 0.01;
			float simplePerlin2D924 = snoise( (Pos831*1.0 + mulTime878)*2.0 );
			float mulTime873 = _Time.y * CZY_CirrusMoveSpeed;
			float cos899 = cos( ( mulTime873 * 0.01 ) );
			float sin899 = sin( ( mulTime873 * 0.01 ) );
			float2 rotator899 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos899 , -sin899 , sin899 , cos899 )) + float2( 0.5,0.5 );
			float cos910 = cos( ( mulTime873 * -0.02 ) );
			float sin910 = sin( ( mulTime873 * -0.02 ) );
			float2 rotator910 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos910 , -sin910 , sin910 , cos910 )) + float2( 0.5,0.5 );
			float mulTime933 = _Time.y * 0.01;
			float simplePerlin2D920 = snoise( (Pos831*1.0 + mulTime933) );
			simplePerlin2D920 = simplePerlin2D920*0.5 + 0.5;
			float4 CirrusPattern935 = ( ( saturate( simplePerlin2D924 ) * tex2D( CZY_CirrusTexture, (rotator899*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrusTexture, (rotator910*1.0 + 0.0) ) * saturate( simplePerlin2D920 ) ) );
			float2 temp_output_962_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult955 = dot( temp_output_962_0 , temp_output_962_0 );
			float4 temp_output_1015_0 = ( CirrusPattern935 * saturate( (0.0 + (dotResult955 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) );
			float Clipping1006 = CZY_ClippingThreshold;
			float CirrusAlpha1048 = ( ( temp_output_1015_0 * ( CZY_CirrusMultiplier * 10.0 ) ).r > Clipping1006 ? 1.0 : 0.0 );
			float SimpleRadiance1066 = saturate( ( DetailedClouds1050 + BorderLightTransport1076 + NimbusLightTransport1067 + ChemtrailsFinal1046 + CirrusAlpha1048 ) );
			float4 lerpResult1140 = lerp( CloudColor839 , lerpResult1136 , ( 1.0 - SimpleRadiance1066 ));
			float CloudLight850 = saturate( pow( temp_output_847_0 , CZY_SunFlareFalloff ) );
			float4 lerpResult1114 = lerp( float4( 0,0,0,0 ) , CloudHighlightColor853 , ( saturate( ( CumulusCoverage832 - 1.0 ) ) * CloudDetail977 * CloudLight850 ));
			float4 SunThroughClouds1197 = ( lerpResult1114 * 1.3 );
			float3 hsvTorgb2_g4 = RGBToHSV( CZY_AltoCloudColor.rgb );
			float3 hsvTorgb3_g4 = HSVToRGB( float3(hsvTorgb2_g4.x,saturate( ( hsvTorgb2_g4.y + CZY_FilterSaturation ) ),( hsvTorgb2_g4.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g4 = ( float4( hsvTorgb3_g4 , 0.0 ) * CZY_FilterColor );
			float4 CirrusCustomLightColor1148 = ( CloudColor839 * ( temp_output_10_0_g4 * CZY_CloudFilterColor ) );
			float time998 = 0.0;
			float2 voronoiSmoothId998 = 0;
			float mulTime961 = _Time.y * 0.003;
			float2 coords998 = (Pos831*1.0 + ( float2( 1,-2 ) * mulTime961 )) * 10.0;
			float2 id998 = 0;
			float2 uv998 = 0;
			float voroi998 = voronoi998( coords998, time998, id998, uv998, 0, voronoiSmoothId998 );
			float time1030 = ( 10.0 * mulTime961 );
			float2 voronoiSmoothId1030 = 0;
			float2 coords1030 = i.uv_texcoord * 10.0;
			float2 id1030 = 0;
			float2 uv1030 = 0;
			float voroi1030 = voronoi1030( coords1030, time1030, id1030, uv1030, 0, voronoiSmoothId1030 );
			float AltoCumulusPlacement1174 = saturate( ( ( ( 1.0 - 0.0 ) - (1.0 + (voroi998 - 0.0) * (-0.5 - 1.0) / (1.0 - 0.0)) ) - voroi1030 ) );
			float temp_output_1189_0 = ( AltoCumulusPlacement1174 * (0.0 + (tex2D( CZY_AltocumulusTexture, ((Pos831*1.0 + ( CZY_AltocumulusWindSpeed * TIme828 ))*( 1.0 / CZY_AltocumulusScale ) + 0.0) ).r - 0.0) * (1.0 - 0.0) / (0.2 - 0.0)) * CZY_AltocumulusMultiplier );
			float AltoCumulusLightTransport1191 = temp_output_1189_0;
			float ACCustomLightsClipping1185 = ( AltoCumulusLightTransport1191 * ( SimpleRadiance1066 > Clipping1006 ? 0.0 : 1.0 ) );
			float mulTime991 = _Time.y * 0.01;
			float simplePerlin2D1022 = snoise( (Pos831*1.0 + mulTime991)*2.0 );
			float mulTime976 = _Time.y * CZY_CirrostratusMoveSpeed;
			float cos936 = cos( ( mulTime976 * 0.01 ) );
			float sin936 = sin( ( mulTime976 * 0.01 ) );
			float2 rotator936 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos936 , -sin936 , sin936 , cos936 )) + float2( 0.5,0.5 );
			float cos996 = cos( ( mulTime976 * -0.02 ) );
			float sin996 = sin( ( mulTime976 * -0.02 ) );
			float2 rotator996 = mul( Pos831 - float2( 0.5,0.5 ) , float2x2( cos996 , -sin996 , sin996 , cos996 )) + float2( 0.5,0.5 );
			float mulTime982 = _Time.y * 0.01;
			float simplePerlin2D1014 = snoise( (Pos831*10.0 + mulTime982)*4.0 );
			float4 CirrostratPattern1059 = ( ( saturate( simplePerlin2D1022 ) * tex2D( CZY_CirrostratusTexture, (rotator936*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrostratusTexture, (rotator996*1.5 + 0.75) ) * saturate( simplePerlin2D1014 ) ) );
			float2 temp_output_1041_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1036 = dot( temp_output_1041_0 , temp_output_1041_0 );
			float clampResult1062 = clamp( ( CZY_CirrostratusMultiplier * 0.5 ) , 0.0 , 0.98 );
			float CirrostratLightTransport1079 = ( ( CirrostratPattern1059 * saturate( (0.4 + (dotResult1036 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - clampResult1062 ) ? 1.0 : 0.0 );
			float CSCustomLightsClipping1107 = ( CirrostratLightTransport1079 * ( SimpleRadiance1066 > Clipping1006 ? 0.0 : 1.0 ) );
			float CustomRadiance1138 = saturate( ( ACCustomLightsClipping1185 + CSCustomLightsClipping1107 ) );
			float4 lerpResult1129 = lerp( ( lerpResult1140 + SunThroughClouds1197 ) , CirrusCustomLightColor1148 , CustomRadiance1138);
			float FinalAlpha1173 = saturate( ( DetailedClouds1050 + BorderLightTransport1076 + AltoCumulusLightTransport1191 + ChemtrailsFinal1046 + CirrostratLightTransport1079 + CirrusAlpha1048 + NimbusLightTransport1067 ) );
			clip( FinalAlpha1173 - Clipping1006);
			float4 FinalCloudColor1123 = lerpResult1129;
			o.Emission = FinalCloudColor1123.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-678.2959,-671.1561;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Desktop;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;True;-50;False;Opaque;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;799;6080,-2832;Inherit;False;2340.552;1688.827;;2;822;810;Chemtrails Block;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;800;2320,-1440;Inherit;False;2974.933;2000.862;;5;819;817;813;812;809;Cumulus Cloud Block;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;801;5760,800;Inherit;False;2654.838;1705.478;;3;824;821;806;Cirrostratus Block;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;802;2096,-4336;Inherit;False;3038.917;2502.995;;4;826;820;815;814;Finalization Block;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;803;8704,-2832;Inherit;False;2297.557;1709.783;;2;825;823;Cirrus Block;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;804;2352,848;Inherit;False;3128.028;1619.676;;3;816;811;807;Altocumulus Cloud Block;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;805;-1680,-4624;Inherit;False;2254.259;1199.93;;45;1203;1202;1200;1199;867;866;865;864;863;862;861;860;859;858;857;856;855;854;853;852;851;850;849;848;847;846;845;844;843;842;841;840;839;838;837;836;835;834;833;832;831;830;829;828;827;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;806;5808,1872;Inherit;False;1600.229;583.7008;Final;13;1167;1079;1072;1063;1062;1057;1056;1054;1053;1047;1041;1036;1032;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;807;2416,960;Inherit;False;2021.115;830.0204;Placement Noise;18;1206;1205;1204;1174;1166;1049;1040;1030;1027;1025;1020;1019;1013;998;988;974;964;961;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;808;8336,-768;Inherit;False;2713.637;1035.553;;30;1201;1196;1159;1158;1067;1028;1024;1018;1007;999;997;992;984;972;968;963;950;948;944;940;938;927;926;923;922;919;914;909;900;896;Nimbus Block;0.5,0.5,0.5,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;809;2368,-784;Inherit;False;1226.633;651.0015;Simple Density;20;1207;1156;1150;1023;951;907;901;897;894;893;892;886;883;880;879;872;871;870;869;868;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;810;6128,-2784;Inherit;False;2197.287;953.2202;Pattern;24;1194;1164;1095;1071;1008;1001;966;957;954;953;946;945;941;929;925;917;913;906;905;904;903;902;895;891;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;811;4480,944;Inherit;False;939.7803;621.1177;Lighting & Clipping;11;1185;1184;1183;1165;1149;1148;1147;1146;1088;1086;1083;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;812;2384,16;Inherit;False;1813.036;453.4427;Final Detailing;17;1153;1152;1151;1050;1042;1033;1016;977;971;928;921;888;885;882;881;875;874;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;813;3680,-1216;Inherit;False;1576.124;399.0991;Highlights;11;1198;1197;1170;1134;1114;1109;1106;1103;1096;1090;1078;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;814;2160,-2848;Inherit;False;2881.345;950.1069;Final Coloring;35;1163;1144;1141;1140;1137;1136;1135;1133;1132;1131;1130;1129;1127;1126;1124;1123;1121;1117;1116;1115;1113;1110;1108;1104;1102;1101;1100;1099;1098;1097;1089;1087;1077;1038;1006;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;815;2176,-3520;Inherit;False;1393.195;555.0131;Simple Radiance;8;1068;1066;1065;1064;1061;1060;1058;1055;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;816;2416,1824;Inherit;False;2120.291;565.6142;Main Noise;15;1192;1191;1190;1189;1188;1187;1186;1182;1181;1180;1179;1178;1177;1176;1175;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;817;2368,-1248;Inherit;False;1283.597;293.2691;Thickness Details;7;1169;1084;1081;1073;1069;1052;1037;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;818;5984,-752;Inherit;False;2111.501;762.0129;;21;1157;1155;1154;1085;1076;1045;1010;1009;1004;1002;995;987;975;969;965;959;952;949;934;930;877;Cloud Border Block;1,0.5882353,0.685091,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;819;3664,-640;Inherit;False;1154;500;Complex Density;9;1172;1171;989;973;967;947;943;939;912;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;820;3632,-3520;Inherit;False;1393.195;555.0131;Custom Radiance;5;1142;1138;1120;1112;1111;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;5792,864;Inherit;False;2197.287;953.2202;Pattern;25;1193;1168;1059;1051;1044;1039;1035;1034;1029;1022;1017;1014;1003;996;994;991;990;986;983;982;981;976;970;936;931;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;822;6144,-1760;Inherit;False;1600.229;583.7008;Final;12;1161;1093;1092;1074;1046;1031;1012;1011;1005;993;960;937;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;823;8736,-2768;Inherit;False;2197.287;953.2202;Pattern;25;1195;1162;1021;1000;958;956;942;935;933;924;920;916;915;911;910;908;899;898;890;889;887;884;878;876;873;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;824;7440,1872;Inherit;False;916.8853;383.8425;Lighting & Clipping;6;1122;1107;1094;1091;1082;1080;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;825;8752,-1760;Inherit;False;1735.998;586.5895;Final;14;1160;1070;1048;1043;1026;1015;985;980;979;978;962;955;932;918;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;826;2144,-4224;Inherit;False;951.3906;629.7021;Final Alpha;10;1173;1145;1143;1139;1128;1125;1119;1118;1105;1075;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;827;-464,-4256;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;828;-304,-4256;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;829;-512,-4416;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;830;-592,-4256;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;831;-304,-4432;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;832;288,-4480;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;833;-1616,-4016;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;834;-1552,-4160;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;835;-1360,-3776;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;836;-1552,-3840;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;837;-1360,-4112;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;838;-1232,-4112;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;839;-1024,-4512;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;840;-1088,-4096;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;841;-1232,-3776;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;842;-576,-3968;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;843;-1616,-3696;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;844;-1088,-3776;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;845;-960,-4096;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;846;-960,-3776;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;847;-736,-4096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;848;-736,-3776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;849;-448,-4096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;850;-272,-3968;Inherit;False;CloudLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;851;-592,-3776;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;852;-416,-3968;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;853;-1024,-4336;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;854;-304,-4112;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;855;-304,-3792;Half;False;MoonlightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;856;-448,-3776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;857;-592,-4096;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;858;-336,-4528;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;859;-1264,-4336;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;860;-1312,-4512;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;861;-544,-4528;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;862;-1568,-4512;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;True;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;0.04943931,0.07984611,0.1037736,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;863;-1568,-4336;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;1;2;[HideInInspector];[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.0752492,0.1315804,0.1792453,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;864;-816,-4224;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;865;-832,-3968;Half;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;866;-16,-4480;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;5;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;867;-1296,-3968;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.423889,-0.9055932,0.01480246;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;868;2416,-416;Inherit;False;Constant;_CloudWind2;Cloud Wind 2;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;869;2416,-480;Inherit;False;828;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;870;2864,-384;Inherit;False;2;0;FLOAT;140;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;871;2624,-720;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;2656,-416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;873;9008,-2272;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;874;2624,224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;2416,192;Inherit;False;828;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;876;9296,-2400;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;877;6128,-480;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;878;9360,-2544;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;879;3056,-448;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;880;2416,-688;Inherit;False;828;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;881;2592,112;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;882;2928,160;Inherit;True;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;883;2864,-272;Inherit;False;2;0;FLOAT;500;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;884;9344,-2032;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;885;2800,256;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;886;3056,-320;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;887;9360,-2624;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;888;2800,160;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;889;9264,-2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;890;9248,-2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;891;6400,-2272;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;892;2864,-496;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;893;3248,-368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;894;2656,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;895;6864,-2400;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;896;8544,-272;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;897;2864,-720;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;898;9584,-2016;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;899;9488,-2400;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;900;8432,-688;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;901;2864,-608;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;902;6752,-2544;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;903;6688,-2400;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;904;6752,-2624;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;905;6736,-1952;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;906;6624,-2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;907;3376,-368;Inherit;False;VoroDetails;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;908;9616,-2608;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;909;8368,-528;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;910;9488,-2240;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;911;9680,-2240;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;912;3680,-480;Inherit;False;907;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;913;6976,-2016;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;914;8784,-608;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;916;10016,-2000;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;917;6720,-2032;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;9872,-1424;Inherit;False;1006;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;919;9248,112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;920;9808,-2000;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;921;3120,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;922;8768,-288;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;923;8960,-272;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;924;9840,-2592;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;925;7072,-2400;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;926;8656,-608;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;927;9392,96;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;928;3264,160;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;929;6976,-2240;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;930;6336,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;931;6736,1392;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;932;8816,-1552;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;933;9344,-1952;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;934;6336,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;935;10640,-2352;Inherit;False;CirrusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;936;6528,1232;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;937;6224,-1552;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;938;9536,80;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;939;4560,-544;Inherit;False;ComplexCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;940;9216,-368;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;941;7216,-2608;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;942;10016,-2592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;943;3840,-480;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;944;8832,-480;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;945;7200,-2016;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;947;3952,-480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;948;9024,-608;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;949;6512,-160;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;950;9472,-16;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;951;3280,-704;Inherit;False;SimpleCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;952;6496,-240;Inherit;False;BorderHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;953;7408,-2000;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;954;7632,-2240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;955;9168,-1552;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;956;10240,-2240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;957;7408,-2592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;958;10240,-2464;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;959;6352,-480;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;960;6448,-1552;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;961;2528,1648;Inherit;False;1;0;FLOAT;0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;962;9024,-1552;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;963;9696,-16;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;964;2736,1536;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;965;6704,-160;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;966;7632,-2464;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;967;3872,-560;Inherit;False;951;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;968;9696,80;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;969;6896,-400;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;-2;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;970;6400,1600;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;971;3456,176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;972;9392,-448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;973;4208,-304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;974;2752,1376;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;975;6704,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;976;6064,1360;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;977;3616,80;Inherit;False;CloudDetail;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;978;9488,-1648;Inherit;False;935;CirrusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;979;9568,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;980;9728,-1504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;981;6416,1008;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;982;6400,1680;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;983;6352,1232;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;984;9888,-80;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;985;9312,-1552;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;986;6304,1328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;987;6912,-496;Inherit;False;951;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;988;2912,1440;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;989;4384,-528;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;990;6320,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;991;6416,1088;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;992;9920,-192;Inherit;False;951;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;993;6768,-1552;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;994;6640,1616;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;995;7136,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;996;6544,1392;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;997;10160,-80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;998;3088,1424;Inherit;True;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;999;9968,-288;Inherit;False;977;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1000;10416,-2352;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1001;7808,-2352;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1002;6960,-576;Inherit;False;977;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1003;6672,1024;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1004;7296,-432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1005;6624,-1552;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1006;4288,-2208;Inherit;False;Clipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1007;10160,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1008;8032,-2352;Inherit;False;ChemtrailsPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1009;7168,-400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1010;6544,-480;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1011;6880,-1664;Inherit;False;1008;ChemtrailsPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1012;6944,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1013;3312,1392;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1014;6864,1632;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1015;9728,-1616;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1016;3344,80;Inherit;False;939;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1017;6736,1232;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1018;10304,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1019;3440,1168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1020;3376,1616;Inherit;False;2;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1021;9680,-2400;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1022;6896,1040;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1023;3232,-448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1024;10592,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1025;3232,1152;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1026;9888,-1520;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1027;3600,1168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1028;10448,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1029;7072,1632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1030;3648,1392;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;12.27;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.OneMinusNode;1031;7104,-1360;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1032;5888,2080;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1033;3616,160;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1034;7072,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1036;6288,2080;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1037;3088,-1200;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;1038;4304,-2368;Inherit;False;1173;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1039;7296,1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1040;3744,1168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1041;6112,2080;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1042;3824,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1043;10064,-1536;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1044;7296,1184;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;1045;7648,-400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1046;7504,-1520;Inherit;False;ChemtrailsFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1047;6992,2112;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5754717;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1048;10256,-1520;Inherit;False;CirrusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1049;3904,1168;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1050;3984,144;Inherit;False;DetailedClouds;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1051;7472,1296;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1052;2912,-1088;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1053;6816,2288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1054;6432,2080;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1055;2496,-3120;Inherit;False;1048;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1056;6544,1984;Inherit;False;1059;CirrostratPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1057;6624,2080;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1058;2448,-3344;Inherit;False;1076;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1059;7696,1280;Inherit;False;CirrostratPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1060;2448,-3264;Inherit;False;1067;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1061;2736,-3328;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1062;6672,2288;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1063;6512,2288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1064;2480,-3424;Inherit;False;1050;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1065;2480,-3200;Inherit;False;1046;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1066;3024,-3328;Inherit;False;SimpleRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1067;10768,-128;Inherit;True;NimbusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1068;2880,-3328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1069;2864,-1200;Inherit;False;907;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1070;10016,-1632;Inherit;False;CirrusLightTransport;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1071;6992,-2608;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1072;6784,2016;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1073;3072,-1088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1074;7344,-1520;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1075;2192,-4016;Inherit;False;1191;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1076;7872,-432;Inherit;False;BorderLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1077;3168,-2176;Inherit;False;1066;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1078;4064,-1088;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1079;7168,2112;Inherit;False;CirrostratLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1080;7504,2144;Inherit;False;1006;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1081;3232,-1168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1082;7488,2064;Inherit;False;1066;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1083;4560,1472;Inherit;False;1006;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1084;3360,-1184;Inherit;False;CloudThicknessDetails;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1085;7504,-416;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1086;4768,1392;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1087;2480,-2016;Inherit;False;1084;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1088;4640,1296;Inherit;False;1191;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1089;2240,-2576;Inherit;False;939;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1090;4400,-1136;Inherit;False;853;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;1091;7712,2064;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1092;6960,-1360;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1093;7120,-1616;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1094;7584,1968;Inherit;False;1079;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1095;6640,-2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1096;4176,-992;Inherit;False;977;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1097;2464,-2288;Inherit;False;1084;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1098;2480,-2576;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1099;2624,-2672;Inherit;False;839;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1100;2672,-2480;Inherit;False;854;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1101;2624,-2384;Inherit;False;853;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1102;2672,-2576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1103;4848,-1088;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1104;3424,-2336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1105;2544,-4016;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1106;4208,-1088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1107;8064,2000;Inherit;False;CSCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1108;2640,-2112;Inherit;False;858;MoonlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1109;4640,-976;Inherit;False;Constant;_2;2;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1110;2864,-2400;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1111;3856,-3216;Inherit;False;1107;CSCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1112;3856,-3312;Inherit;False;1185;ACCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1113;2848,-2656;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1114;4640,-1104;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1115;3040,-2368;Inherit;False;839;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1116;2880,-2128;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;1117;4528,-2464;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1118;2272,-3760;Inherit;False;1048;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1119;2208,-3840;Inherit;False;1079;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1120;4160,-3264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1121;3232,-2384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5660378,0.5660378,0.5660378,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1122;7904,2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1123;4752,-2464;Inherit;False;FinalCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1124;2672,-2208;Inherit;False;855;MoonlightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1125;2224,-3696;Inherit;False;1067;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1126;3040,-2496;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1127;3120,-2272;Inherit;False;1084;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1128;2256,-3920;Inherit;False;1046;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1129;4144,-2432;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1130;3888,-2240;Inherit;False;1138;CustomRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1131;2576,-2752;Inherit;False;853;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1132;2720,-2016;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1133;3840,-2432;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1134;4400,-1056;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1135;3392,-2592;Inherit;False;839;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1136;3376,-2496;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1137;3600,-2336;Inherit;False;1197;SunThroughClouds;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1138;4448,-3280;Inherit;False;CustomRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1139;2688,-4000;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1140;3600,-2464;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1141;3840,-2320;Inherit;False;1148;CirrusCustomLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1142;4288,-3280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1143;2224,-4096;Inherit;False;1076;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1144;2704,-2288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1145;2256,-4176;Inherit;False;1050;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1146;5008,1072;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.7159576,0.8624095,0.8773585,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1147;4816,1008;Inherit;False;839;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1148;5168,1072;Inherit;False;CirrusCustomLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1149;4736,1120;Inherit;False;Filter Color;-1;;4;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;1150;2416,-608;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1151;2608,336;Inherit;False;Global;CZY_DetailScale;CZY_DetailScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1152;3280,336;Inherit;False;Global;CZY_DetailAmount;CZY_DetailAmount;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1153;2416,288;Inherit;False;Constant;_DetailWind;Detail Wind;17;0;Create;True;0;0;0;False;0;False;0.3,0.2;0.3,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1154;6064,-128;Inherit;False;Global;CZY_BorderVariation;CZY_BorderVariation;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1155;6064,-240;Inherit;False;Global;CZY_BorderHeight;CZY_BorderHeight;4;2;[HideInInspector];[Header];Create;False;1;Border Clouds;0;0;False;0;False;1;0.553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1156;2608,-624;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;10;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1157;7184,-288;Inherit;False;Global;CZY_BorderEffect;CZY_BorderEffect;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1158;8640,-464;Inherit;False;Global;CZY_StormDirection;CZY_StormDirection;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;-0.9961442,0,-0.08773059;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1159;8976,112;Inherit;False;Global;CZY_NimbusVariation;CZY_NimbusVariation;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.945;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1160;9360,-1328;Inherit;False;Global;CZY_CirrusMultiplier;CZY_CirrusMultiplier;11;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1161;6672,-1360;Inherit;False;Global;CZY_ChemtrailsMultiplier;CZY_ChemtrailsMultiplier;14;1;[HideInInspector];Create;False;1;Chemtrails;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1162;8784,-2272;Inherit;False;Global;CZY_CirrusMoveSpeed;CZY_CirrusMoveSpeed;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.297;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1163;4000,-2096;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1164;6160,-2288;Inherit;False;Global;CZY_ChemtrailsMoveSpeed;CZY_ChemtrailsMoveSpeed;15;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.289;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1165;4512,1120;Inherit;False;Global;CZY_AltoCloudColor;CZY_AltoCloudColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.675705,1.909993,2.279378,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;1166;2544,1392;Inherit;False;Constant;_ACMoveSpeed;ACMoveSpeed;14;0;Create;True;0;0;0;False;0;False;1,-2;5,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1167;6240,2288;Inherit;False;Global;CZY_CirrostratusMultiplier;CZY_CirrostratusMultiplier;4;2;[HideInInspector];[Header];Create;False;1;Cirrostratus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1168;5824,1360;Inherit;False;Global;CZY_CirrostratusMoveSpeed;CZY_CirrostratusMoveSpeed;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.281;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1169;2688,-1088;Inherit;False;832;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1170;3824,-1088;Inherit;False;832;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1171;3984,-304;Inherit;False;832;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1172;4160,-528;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1173;2864,-4016;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1174;4080,1168;Inherit;False;AltoCumulusPlacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1175;2688,1888;Inherit;False;831;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1176;2864,1904;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;1177;2448,1968;Inherit;False;Global;CZY_AltocumulusWindSpeed;CZY_AltocumulusWindSpeed;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,-2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1178;3056,1936;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1179;2720,2016;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1180;2528,2096;Inherit;False;828;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1181;2768,2128;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1182;2512,2240;Inherit;False;Global;CZY_AltocumulusScale;CZY_AltocumulusScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;3;0.371;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1183;4960,1328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1184;4544,1392;Inherit;False;1066;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1185;5120,1328;Inherit;True;ACCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1186;3264,1920;Inherit;True;Global;CZY_AltocumulusTexture;CZY_AltocumulusTexture;3;0;Create;False;0;0;0;False;0;False;-1;b03bb03c5876b954ba45feffa4aaad63;b03bb03c5876b954ba45feffa4aaad63;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1187;3568,2224;Inherit;False;Global;CZY_AltocumulusMultiplier;CZY_AltocumulusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Altocumulus Clouds;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1188;3568,1920;Inherit;False;1174;AltoCumulusPlacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1189;3808,1936;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1190;3968,1936;Inherit;True;2;4;0;FLOAT;0.1;False;1;FLOAT;0.2;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1191;4240,1936;Inherit;False;AltoCumulusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1192;3616,2000;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1193;6928,1200;Inherit;True;Global;CZY_CirrostratusTexture;CZY_CirrostratusTexture;0;0;Create;False;0;0;0;False;0;False;-1;None;bf43c8d7b74e204469465f36dfff7d6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1194;7264,-2448;Inherit;True;Global;CZY_ChemtrailsTexture;CZY_ChemtrailsTexture;2;0;Create;False;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1195;9872,-2448;Inherit;True;Global;CZY_CirrusTexture;CZY_CirrusTexture;1;0;Create;False;0;0;0;False;0;False;-1;None;302629ebb64a0e345948779662fc2cf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1196;8944,-368;Inherit;False;Global;CZY_NimbusHeight;CZY_NimbusHeight;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1197;5008,-1088;Inherit;False;SunThroughClouds;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1198;4176,-912;Inherit;False;850;CloudLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1199;-832,-3888;Half;False;Global;CZY_CloudFlareFalloff;CZY_CloudFlareFalloff;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1200;-784,-4528;Inherit;False;Global;CZY_CloudMoonColor;CZY_CloudMoonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.0517088,0.07180047,0.1320755,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1201;9120,0;Inherit;False;Global;CZY_NimbusMultiplier;CZY_NimbusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Nimbus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1202;-1312,-3648;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.3015023,0.9437417,0.1358237;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1203;-848,-3648;Half;False;Global;CZY_CloudMoonFalloff;CZY_CloudMoonFalloff;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;11.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1204;2496,1072;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;1205;2912,1072;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1206;2720,1072;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1207;3040,-704;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1208;-976,-672;Inherit;False;1123;FinalCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1035;6928,1408;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1193;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;915;9872,-2240;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1195;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;946;7264,-2240;Inherit;True;Property;_ChemtrailsTex2;Chemtrails Tex 2;2;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1194;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;0;2;1208;0
WireConnection;827;0;830;0
WireConnection;828;0;827;0
WireConnection;830;1;864;0
WireConnection;831;0;829;0
WireConnection;832;0;866;0
WireConnection;835;0;836;0
WireConnection;835;1;843;0
WireConnection;837;0;834;0
WireConnection;837;1;833;0
WireConnection;838;0;837;0
WireConnection;839;0;860;0
WireConnection;840;0;838;0
WireConnection;840;1;867;0
WireConnection;841;0;835;0
WireConnection;842;0;847;0
WireConnection;842;1;865;0
WireConnection;844;0;841;0
WireConnection;844;1;1202;0
WireConnection;845;0;840;0
WireConnection;846;0;844;0
WireConnection;847;0;845;0
WireConnection;848;0;846;0
WireConnection;849;0;857;0
WireConnection;850;0;852;0
WireConnection;851;0;848;0
WireConnection;851;1;1203;0
WireConnection;852;0;842;0
WireConnection;853;0;859;0
WireConnection;854;0;849;0
WireConnection;855;0;856;0
WireConnection;856;0;851;0
WireConnection;857;0;847;0
WireConnection;857;1;865;0
WireConnection;858;0;861;0
WireConnection;859;1;863;0
WireConnection;860;1;862;0
WireConnection;861;1;1200;0
WireConnection;870;1;1156;0
WireConnection;872;0;869;0
WireConnection;872;1;868;0
WireConnection;873;0;1162;0
WireConnection;874;0;875;0
WireConnection;874;1;1153;0
WireConnection;879;0;892;0
WireConnection;879;2;870;0
WireConnection;882;0;888;0
WireConnection;882;2;885;0
WireConnection;883;1;1156;0
WireConnection;885;1;1151;0
WireConnection;886;0;892;0
WireConnection;886;2;883;0
WireConnection;888;0;881;0
WireConnection;888;1;874;0
WireConnection;889;0;873;0
WireConnection;890;0;873;0
WireConnection;891;0;1164;0
WireConnection;892;0;871;0
WireConnection;892;1;872;0
WireConnection;893;0;879;0
WireConnection;893;1;886;0
WireConnection;894;0;880;0
WireConnection;894;1;1150;0
WireConnection;895;0;903;0
WireConnection;895;2;906;0
WireConnection;897;0;871;0
WireConnection;897;1;894;0
WireConnection;898;0;884;0
WireConnection;898;2;933;0
WireConnection;899;0;876;0
WireConnection;899;2;890;0
WireConnection;901;1;1156;0
WireConnection;906;0;891;0
WireConnection;907;0;893;0
WireConnection;908;0;887;0
WireConnection;908;2;878;0
WireConnection;910;0;876;0
WireConnection;910;2;889;0
WireConnection;911;0;910;0
WireConnection;913;0;917;0
WireConnection;913;2;905;0
WireConnection;914;0;926;0
WireConnection;916;0;920;0
WireConnection;919;0;1159;0
WireConnection;920;0;898;0
WireConnection;921;0;882;0
WireConnection;922;0;896;0
WireConnection;923;0;922;0
WireConnection;923;1;922;0
WireConnection;924;0;908;0
WireConnection;925;0;895;0
WireConnection;926;0;900;0
WireConnection;926;1;909;0
WireConnection;927;0;919;0
WireConnection;928;0;921;0
WireConnection;929;0;903;0
WireConnection;929;2;1095;0
WireConnection;930;0;1154;0
WireConnection;931;0;996;0
WireConnection;934;0;1155;0
WireConnection;935;0;1000;0
WireConnection;936;0;983;0
WireConnection;936;2;986;0
WireConnection;938;1;927;0
WireConnection;939;0;989;0
WireConnection;940;0;1196;0
WireConnection;940;2;923;0
WireConnection;941;0;1071;0
WireConnection;942;0;924;0
WireConnection;943;0;912;0
WireConnection;944;0;1158;0
WireConnection;945;0;913;0
WireConnection;947;0;943;0
WireConnection;948;0;914;0
WireConnection;948;1;944;0
WireConnection;949;1;930;0
WireConnection;950;0;1201;0
WireConnection;951;0;1207;0
WireConnection;952;0;934;0
WireConnection;953;0;945;0
WireConnection;954;0;946;0
WireConnection;954;1;953;0
WireConnection;955;0;962;0
WireConnection;955;1;962;0
WireConnection;956;0;915;0
WireConnection;956;1;916;0
WireConnection;957;0;941;0
WireConnection;958;0;942;0
WireConnection;958;1;1195;0
WireConnection;959;0;877;0
WireConnection;960;0;937;0
WireConnection;962;0;932;0
WireConnection;963;0;950;0
WireConnection;963;1;938;0
WireConnection;964;0;1166;0
WireConnection;964;1;961;0
WireConnection;965;0;949;0
WireConnection;966;0;957;0
WireConnection;966;1;1194;0
WireConnection;968;0;938;0
WireConnection;969;0;1010;0
WireConnection;969;3;975;0
WireConnection;969;4;965;0
WireConnection;971;0;928;0
WireConnection;971;2;1152;0
WireConnection;972;0;948;0
WireConnection;972;1;940;0
WireConnection;973;0;1171;0
WireConnection;975;0;952;0
WireConnection;975;1;949;0
WireConnection;976;0;1168;0
WireConnection;977;0;971;0
WireConnection;979;0;985;0
WireConnection;980;0;1160;0
WireConnection;984;0;972;0
WireConnection;984;3;963;0
WireConnection;984;4;968;0
WireConnection;985;0;955;0
WireConnection;986;0;976;0
WireConnection;988;0;974;0
WireConnection;988;2;964;0
WireConnection;989;0;1172;0
WireConnection;989;1;973;0
WireConnection;990;0;976;0
WireConnection;993;0;1005;0
WireConnection;994;0;970;0
WireConnection;994;2;982;0
WireConnection;995;0;1002;0
WireConnection;995;1;987;0
WireConnection;996;0;983;0
WireConnection;996;2;990;0
WireConnection;997;0;984;0
WireConnection;998;0;988;0
WireConnection;1000;0;958;0
WireConnection;1000;1;956;0
WireConnection;1001;0;966;0
WireConnection;1001;1;954;0
WireConnection;1003;0;981;0
WireConnection;1003;2;991;0
WireConnection;1004;0;995;0
WireConnection;1004;1;1009;0
WireConnection;1005;0;960;0
WireConnection;1005;1;960;0
WireConnection;1006;0;1163;0
WireConnection;1007;0;999;0
WireConnection;1007;1;992;0
WireConnection;1008;0;1001;0
WireConnection;1009;0;969;0
WireConnection;1010;0;959;0
WireConnection;1010;1;959;0
WireConnection;1012;0;993;0
WireConnection;1013;0;998;0
WireConnection;1014;0;994;0
WireConnection;1015;0;978;0
WireConnection;1015;1;979;0
WireConnection;1017;0;936;0
WireConnection;1018;0;1007;0
WireConnection;1018;1;997;0
WireConnection;1020;1;961;0
WireConnection;1021;0;899;0
WireConnection;1022;0;1003;0
WireConnection;1023;0;879;0
WireConnection;1024;0;1028;0
WireConnection;1025;0;1205;0
WireConnection;1026;0;1015;0
WireConnection;1026;1;980;0
WireConnection;1027;0;1019;0
WireConnection;1027;1;1013;0
WireConnection;1028;0;1018;0
WireConnection;1029;0;1014;0
WireConnection;1030;1;1020;0
WireConnection;1031;0;1092;0
WireConnection;1033;0;1016;0
WireConnection;1033;1;971;0
WireConnection;1034;0;1022;0
WireConnection;1036;0;1041;0
WireConnection;1036;1;1041;0
WireConnection;1037;0;1069;0
WireConnection;1039;0;1035;0
WireConnection;1039;1;1029;0
WireConnection;1040;0;1027;0
WireConnection;1040;1;1030;0
WireConnection;1041;0;1032;0
WireConnection;1042;0;1033;0
WireConnection;1043;0;1026;0
WireConnection;1043;1;918;0
WireConnection;1044;0;1034;0
WireConnection;1044;1;1193;0
WireConnection;1045;0;1085;0
WireConnection;1046;0;1074;0
WireConnection;1047;0;1072;0
WireConnection;1047;1;1053;0
WireConnection;1048;0;1043;0
WireConnection;1049;0;1040;0
WireConnection;1050;0;1042;0
WireConnection;1051;0;1044;0
WireConnection;1051;1;1039;0
WireConnection;1052;0;1169;0
WireConnection;1053;0;1062;0
WireConnection;1054;0;1036;0
WireConnection;1057;0;1054;0
WireConnection;1059;0;1051;0
WireConnection;1061;0;1064;0
WireConnection;1061;1;1058;0
WireConnection;1061;2;1060;0
WireConnection;1061;3;1065;0
WireConnection;1061;4;1055;0
WireConnection;1062;0;1063;0
WireConnection;1063;0;1167;0
WireConnection;1066;0;1068;0
WireConnection;1067;0;1024;0
WireConnection;1068;0;1061;0
WireConnection;1070;0;1015;0
WireConnection;1071;0;904;0
WireConnection;1071;2;902;0
WireConnection;1072;0;1056;0
WireConnection;1072;1;1057;0
WireConnection;1073;0;1052;0
WireConnection;1074;0;1093;0
WireConnection;1074;1;1031;0
WireConnection;1076;0;1045;0
WireConnection;1078;0;1170;0
WireConnection;1079;0;1047;0
WireConnection;1081;0;1037;1
WireConnection;1081;1;1073;0
WireConnection;1084;0;1081;0
WireConnection;1085;0;1004;0
WireConnection;1085;2;1157;0
WireConnection;1086;0;1184;0
WireConnection;1086;1;1083;0
WireConnection;1091;0;1082;0
WireConnection;1091;1;1080;0
WireConnection;1092;0;1161;0
WireConnection;1093;0;1011;0
WireConnection;1093;1;1012;0
WireConnection;1095;0;891;0
WireConnection;1098;0;1089;0
WireConnection;1102;0;1098;0
WireConnection;1103;0;1114;0
WireConnection;1103;1;1109;0
WireConnection;1104;0;1077;0
WireConnection;1105;0;1145;0
WireConnection;1105;1;1143;0
WireConnection;1105;2;1075;0
WireConnection;1105;3;1128;0
WireConnection;1105;4;1119;0
WireConnection;1105;5;1118;0
WireConnection;1105;6;1125;0
WireConnection;1106;0;1078;0
WireConnection;1107;0;1122;0
WireConnection;1110;0;1100;0
WireConnection;1110;1;1101;0
WireConnection;1110;2;1144;0
WireConnection;1113;0;1131;0
WireConnection;1113;1;1099;0
WireConnection;1113;2;1102;0
WireConnection;1114;1;1090;0
WireConnection;1114;2;1134;0
WireConnection;1116;0;1124;0
WireConnection;1116;1;1108;0
WireConnection;1116;2;1132;0
WireConnection;1117;0;1129;0
WireConnection;1117;1;1038;0
WireConnection;1117;2;1006;0
WireConnection;1120;0;1112;0
WireConnection;1120;1;1111;0
WireConnection;1121;0;1115;0
WireConnection;1122;0;1094;0
WireConnection;1122;1;1091;0
WireConnection;1123;0;1117;0
WireConnection;1126;0;1113;0
WireConnection;1126;1;1110;0
WireConnection;1126;2;1116;0
WireConnection;1129;0;1133;0
WireConnection;1129;1;1141;0
WireConnection;1129;2;1130;0
WireConnection;1132;0;1087;0
WireConnection;1133;0;1140;0
WireConnection;1133;1;1137;0
WireConnection;1134;0;1106;0
WireConnection;1134;1;1096;0
WireConnection;1134;2;1198;0
WireConnection;1136;0;1126;0
WireConnection;1136;1;1121;0
WireConnection;1136;2;1127;0
WireConnection;1138;0;1142;0
WireConnection;1139;0;1105;0
WireConnection;1140;0;1135;0
WireConnection;1140;1;1136;0
WireConnection;1140;2;1104;0
WireConnection;1142;0;1120;0
WireConnection;1144;0;1097;0
WireConnection;1146;0;1147;0
WireConnection;1146;1;1149;0
WireConnection;1148;0;1146;0
WireConnection;1149;1;1165;0
WireConnection;1172;0;967;0
WireConnection;1172;1;947;0
WireConnection;1173;0;1139;0
WireConnection;1174;0;1049;0
WireConnection;1176;0;1175;0
WireConnection;1176;2;1179;0
WireConnection;1178;0;1176;0
WireConnection;1178;1;1181;0
WireConnection;1179;0;1177;0
WireConnection;1179;1;1180;0
WireConnection;1181;1;1182;0
WireConnection;1183;0;1088;0
WireConnection;1183;1;1086;0
WireConnection;1185;0;1183;0
WireConnection;1186;1;1178;0
WireConnection;1189;0;1188;0
WireConnection;1189;1;1192;0
WireConnection;1189;2;1187;0
WireConnection;1190;0;1189;0
WireConnection;1191;0;1189;0
WireConnection;1192;0;1186;1
WireConnection;1193;1;1017;0
WireConnection;1194;1;925;0
WireConnection;1195;1;1021;0
WireConnection;1197;0;1103;0
WireConnection;1205;0;1206;0
WireConnection;1205;1;1206;0
WireConnection;1206;0;1204;0
WireConnection;1207;0;897;0
WireConnection;1207;1;901;0
WireConnection;1035;1;931;0
WireConnection;915;1;911;0
WireConnection;946;1;929;0
ASEEND*/
//CHKSM=8C4BCA3BEFAF0ACCA90472E1A75E5BF3B2AE65D7