// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Ghibli Mobile"
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
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 CZY_CloudHighlightColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_CloudFilterColor;
		uniform float4 CZY_CloudColor;
		uniform float4 CZY_CloudTextureColor;
		uniform float CZY_Spherize;
		uniform float CZY_WindSpeed;
		uniform float CZY_CloudCohesion;
		uniform float CZY_CumulusCoverageMultiplier;
		uniform float CZY_MainCloudScale;
		uniform float CZY_ShadowingDistance;
		uniform float CZY_ClippingThreshold;


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


		float2 voronoihash35_g48( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g48( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g48( n + g );
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


		float2 voronoihash13_g48( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g48( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g48( n + g );
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


		float2 voronoihash11_g48( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g48( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g48( n + g );
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


		float2 voronoihash35_g51( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g51( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g51( n + g );
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


		float2 voronoihash13_g51( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g51( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g51( n + g );
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


		float2 voronoihash11_g51( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g51( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g51( n + g );
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


		float2 voronoihash35_g47( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g47( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g47( n + g );
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


		float2 voronoihash13_g47( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g47( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g47( n + g );
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


		float2 voronoihash11_g47( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g47( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g47( n + g );
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
			float3 hsvTorgb2_g50 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g50 = HSVToRGB( float3(hsvTorgb2_g50.x,saturate( ( hsvTorgb2_g50.y + CZY_FilterSaturation ) ),( hsvTorgb2_g50.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g50 = ( float4( hsvTorgb3_g50 , 0.0 ) * CZY_FilterColor );
			float4 CloudHighlightColor1332 = ( temp_output_10_0_g50 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g49 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g49 = HSVToRGB( float3(hsvTorgb2_g49.x,saturate( ( hsvTorgb2_g49.y + CZY_FilterSaturation ) ),( hsvTorgb2_g49.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g49 = ( float4( hsvTorgb3_g49 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor1314 = ( temp_output_10_0_g49 * CZY_CloudFilterColor );
			Gradient gradient1309 = NewGradient( 0, 2, 2, float4( 0, 0, 0, 0.8676432 ), float4( 1, 1, 1, 0.9294118 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float2 temp_output_1295_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1264 = dot( temp_output_1295_0 , temp_output_1295_0 );
			float Dot1269 = saturate( (0.85 + (dotResult1264 - 0.0) * (3.0 - 0.85) / (1.0 - 0.0)) );
			float time35_g48 = 0.0;
			float2 voronoiSmoothId35_g48 = 0;
			float2 CentralUV1258 = ( i.uv_texcoord + float2( -0.5,-0.5 ) );
			float2 temp_output_21_0_g48 = (CentralUV1258*1.58 + 0.0);
			float2 break2_g48 = abs( temp_output_21_0_g48 );
			float saferPower4_g48 = abs( break2_g48.x );
			float saferPower3_g48 = abs( break2_g48.y );
			float saferPower6_g48 = abs( ( pow( saferPower4_g48 , 2.0 ) + pow( saferPower3_g48 , 2.0 ) ) );
			float Spherize1270 = CZY_Spherize;
			float Flatness1271 = ( 20.0 * CZY_Spherize );
			float mulTime1255 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float Time1249 = mulTime1255;
			float2 Wind1292 = ( Time1249 * float2( 0.1,0.2 ) );
			float2 temp_output_10_0_g48 = (( ( temp_output_21_0_g48 * ( pow( saferPower6_g48 , Spherize1270 ) * Flatness1271 ) ) + float2( 0.5,0.5 ) )*( 2.0 / 5.0 ) + Wind1292);
			float2 coords35_g48 = temp_output_10_0_g48 * 60.0;
			float2 id35_g48 = 0;
			float2 uv35_g48 = 0;
			float fade35_g48 = 0.5;
			float voroi35_g48 = 0;
			float rest35_g48 = 0;
			for( int it35_g48 = 0; it35_g48 <2; it35_g48++ ){
			voroi35_g48 += fade35_g48 * voronoi35_g48( coords35_g48, time35_g48, id35_g48, uv35_g48, 0,voronoiSmoothId35_g48 );
			rest35_g48 += fade35_g48;
			coords35_g48 *= 2;
			fade35_g48 *= 0.5;
			}//Voronoi35_g48
			voroi35_g48 /= rest35_g48;
			float time13_g48 = 0.0;
			float2 voronoiSmoothId13_g48 = 0;
			float2 coords13_g48 = temp_output_10_0_g48 * 25.0;
			float2 id13_g48 = 0;
			float2 uv13_g48 = 0;
			float fade13_g48 = 0.5;
			float voroi13_g48 = 0;
			float rest13_g48 = 0;
			for( int it13_g48 = 0; it13_g48 <2; it13_g48++ ){
			voroi13_g48 += fade13_g48 * voronoi13_g48( coords13_g48, time13_g48, id13_g48, uv13_g48, 0,voronoiSmoothId13_g48 );
			rest13_g48 += fade13_g48;
			coords13_g48 *= 2;
			fade13_g48 *= 0.5;
			}//Voronoi13_g48
			voroi13_g48 /= rest13_g48;
			float time11_g48 = 17.23;
			float2 voronoiSmoothId11_g48 = 0;
			float2 coords11_g48 = temp_output_10_0_g48 * 9.0;
			float2 id11_g48 = 0;
			float2 uv11_g48 = 0;
			float fade11_g48 = 0.5;
			float voroi11_g48 = 0;
			float rest11_g48 = 0;
			for( int it11_g48 = 0; it11_g48 <2; it11_g48++ ){
			voroi11_g48 += fade11_g48 * voronoi11_g48( coords11_g48, time11_g48, id11_g48, uv11_g48, 0,voronoiSmoothId11_g48 );
			rest11_g48 += fade11_g48;
			coords11_g48 *= 2;
			fade11_g48 *= 0.5;
			}//Voronoi11_g48
			voroi11_g48 /= rest11_g48;
			float2 temp_output_1256_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1248 = dot( temp_output_1256_0 , temp_output_1256_0 );
			float ModifiedCohesion1263 = ( CZY_CloudCohesion * 1.0 * ( 1.0 - dotResult1248 ) );
			float lerpResult15_g48 = lerp( saturate( ( voroi35_g48 + voroi13_g48 ) ) , voroi11_g48 , ModifiedCohesion1263);
			float CumulusCoverage1355 = CZY_CumulusCoverageMultiplier;
			float lerpResult16_g48 = lerp( lerpResult15_g48 , 1.0 , ( ( 1.0 - CumulusCoverage1355 ) + -0.7 ));
			float time35_g51 = 0.0;
			float2 voronoiSmoothId35_g51 = 0;
			float2 temp_output_21_0_g51 = CentralUV1258;
			float2 break2_g51 = abs( temp_output_21_0_g51 );
			float saferPower4_g51 = abs( break2_g51.x );
			float saferPower3_g51 = abs( break2_g51.y );
			float saferPower6_g51 = abs( ( pow( saferPower4_g51 , 2.0 ) + pow( saferPower3_g51 , 2.0 ) ) );
			float Scale1265 = ( CZY_MainCloudScale * 0.1 );
			float2 temp_output_10_0_g51 = (( ( temp_output_21_0_g51 * ( pow( saferPower6_g51 , Spherize1270 ) * Flatness1271 ) ) + float2( 0.5,0.5 ) )*( 2.0 / ( Scale1265 * 1.5 ) ) + ( Wind1292 * float2( 0.5,0.5 ) ));
			float2 coords35_g51 = temp_output_10_0_g51 * 60.0;
			float2 id35_g51 = 0;
			float2 uv35_g51 = 0;
			float fade35_g51 = 0.5;
			float voroi35_g51 = 0;
			float rest35_g51 = 0;
			for( int it35_g51 = 0; it35_g51 <2; it35_g51++ ){
			voroi35_g51 += fade35_g51 * voronoi35_g51( coords35_g51, time35_g51, id35_g51, uv35_g51, 0,voronoiSmoothId35_g51 );
			rest35_g51 += fade35_g51;
			coords35_g51 *= 2;
			fade35_g51 *= 0.5;
			}//Voronoi35_g51
			voroi35_g51 /= rest35_g51;
			float time13_g51 = 0.0;
			float2 voronoiSmoothId13_g51 = 0;
			float2 coords13_g51 = temp_output_10_0_g51 * 25.0;
			float2 id13_g51 = 0;
			float2 uv13_g51 = 0;
			float fade13_g51 = 0.5;
			float voroi13_g51 = 0;
			float rest13_g51 = 0;
			for( int it13_g51 = 0; it13_g51 <2; it13_g51++ ){
			voroi13_g51 += fade13_g51 * voronoi13_g51( coords13_g51, time13_g51, id13_g51, uv13_g51, 0,voronoiSmoothId13_g51 );
			rest13_g51 += fade13_g51;
			coords13_g51 *= 2;
			fade13_g51 *= 0.5;
			}//Voronoi13_g51
			voroi13_g51 /= rest13_g51;
			float time11_g51 = 17.23;
			float2 voronoiSmoothId11_g51 = 0;
			float2 coords11_g51 = temp_output_10_0_g51 * 9.0;
			float2 id11_g51 = 0;
			float2 uv11_g51 = 0;
			float fade11_g51 = 0.5;
			float voroi11_g51 = 0;
			float rest11_g51 = 0;
			for( int it11_g51 = 0; it11_g51 <2; it11_g51++ ){
			voroi11_g51 += fade11_g51 * voronoi11_g51( coords11_g51, time11_g51, id11_g51, uv11_g51, 0,voronoiSmoothId11_g51 );
			rest11_g51 += fade11_g51;
			coords11_g51 *= 2;
			fade11_g51 *= 0.5;
			}//Voronoi11_g51
			voroi11_g51 /= rest11_g51;
			float lerpResult15_g51 = lerp( saturate( ( voroi35_g51 + voroi13_g51 ) ) , voroi11_g51 , ( ModifiedCohesion1263 * 1.1 ));
			float lerpResult16_g51 = lerp( lerpResult15_g51 , 1.0 , ( ( 1.0 - CumulusCoverage1355 ) + -0.7 ));
			float temp_output_1266_0 = saturate( (0.0 + (( Dot1269 * ( 1.0 - lerpResult16_g51 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) );
			float IT2PreAlpha1321 = temp_output_1266_0;
			float temp_output_1318_0 = (0.0 + (( Dot1269 * ( 1.0 - lerpResult16_g48 ) ) - 0.6) * (IT2PreAlpha1321 - 0.0) / (1.5 - 0.6));
			float clampResult1312 = clamp( temp_output_1318_0 , 0.0 , 0.9 );
			float AdditionalLayer1307 = SampleGradient( gradient1309, clampResult1312 ).r;
			float4 lerpResult1329 = lerp( CloudColor1314 , ( CloudColor1314 * CZY_CloudTextureColor ) , AdditionalLayer1307);
			float4 ModifiedCloudColor1339 = lerpResult1329;
			Gradient gradient1328 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4411841 ), float4( 1, 1, 1, 0.5794156 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float time35_g47 = 0.0;
			float2 voronoiSmoothId35_g47 = 0;
			float2 ShadowUV1300 = ( CentralUV1258 + ( CentralUV1258 * float2( -1,-1 ) * CZY_ShadowingDistance * Dot1269 ) );
			float2 temp_output_21_0_g47 = ShadowUV1300;
			float2 break2_g47 = abs( temp_output_21_0_g47 );
			float saferPower4_g47 = abs( break2_g47.x );
			float saferPower3_g47 = abs( break2_g47.y );
			float saferPower6_g47 = abs( ( pow( saferPower4_g47 , 2.0 ) + pow( saferPower3_g47 , 2.0 ) ) );
			float2 temp_output_10_0_g47 = (( ( temp_output_21_0_g47 * ( pow( saferPower6_g47 , Spherize1270 ) * Flatness1271 ) ) + float2( 0.5,0.5 ) )*( 2.0 / ( Scale1265 * 1.5 ) ) + ( Wind1292 * float2( 0.5,0.5 ) ));
			float2 coords35_g47 = temp_output_10_0_g47 * 60.0;
			float2 id35_g47 = 0;
			float2 uv35_g47 = 0;
			float fade35_g47 = 0.5;
			float voroi35_g47 = 0;
			float rest35_g47 = 0;
			for( int it35_g47 = 0; it35_g47 <2; it35_g47++ ){
			voroi35_g47 += fade35_g47 * voronoi35_g47( coords35_g47, time35_g47, id35_g47, uv35_g47, 0,voronoiSmoothId35_g47 );
			rest35_g47 += fade35_g47;
			coords35_g47 *= 2;
			fade35_g47 *= 0.5;
			}//Voronoi35_g47
			voroi35_g47 /= rest35_g47;
			float time13_g47 = 0.0;
			float2 voronoiSmoothId13_g47 = 0;
			float2 coords13_g47 = temp_output_10_0_g47 * 25.0;
			float2 id13_g47 = 0;
			float2 uv13_g47 = 0;
			float fade13_g47 = 0.5;
			float voroi13_g47 = 0;
			float rest13_g47 = 0;
			for( int it13_g47 = 0; it13_g47 <2; it13_g47++ ){
			voroi13_g47 += fade13_g47 * voronoi13_g47( coords13_g47, time13_g47, id13_g47, uv13_g47, 0,voronoiSmoothId13_g47 );
			rest13_g47 += fade13_g47;
			coords13_g47 *= 2;
			fade13_g47 *= 0.5;
			}//Voronoi13_g47
			voroi13_g47 /= rest13_g47;
			float time11_g47 = 17.23;
			float2 voronoiSmoothId11_g47 = 0;
			float2 coords11_g47 = temp_output_10_0_g47 * 9.0;
			float2 id11_g47 = 0;
			float2 uv11_g47 = 0;
			float fade11_g47 = 0.5;
			float voroi11_g47 = 0;
			float rest11_g47 = 0;
			for( int it11_g47 = 0; it11_g47 <2; it11_g47++ ){
			voroi11_g47 += fade11_g47 * voronoi11_g47( coords11_g47, time11_g47, id11_g47, uv11_g47, 0,voronoiSmoothId11_g47 );
			rest11_g47 += fade11_g47;
			coords11_g47 *= 2;
			fade11_g47 *= 0.5;
			}//Voronoi11_g47
			voroi11_g47 /= rest11_g47;
			float lerpResult15_g47 = lerp( saturate( ( voroi35_g47 + voroi13_g47 ) ) , voroi11_g47 , ( ModifiedCohesion1263 * 1.1 ));
			float lerpResult16_g47 = lerp( lerpResult15_g47 , 1.0 , ( ( 1.0 - CumulusCoverage1355 ) + -0.7 ));
			float4 lerpResult1346 = lerp( CloudHighlightColor1332 , ModifiedCloudColor1339 , saturate( SampleGradient( gradient1328, saturate( (0.0 + (( Dot1269 * ( 1.0 - lerpResult16_g47 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) ) ).r ));
			float4 IT2Color1342 = lerpResult1346;
			Gradient gradient1334 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4617685 ), float4( 1, 1, 1, 0.5117723 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float IT2Alpha1343 = SampleGradient( gradient1334, temp_output_1266_0 ).r;
			clip( IT2Alpha1343 - CZY_ClippingThreshold);
			o.Emission = IT2Color1342.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;1242;-1328,-2560;Inherit;False;2636.823;1492.163;;2;1246;1243;Iteration 2;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1243;-1264,-2496;Inherit;False;2070.976;624.3994;Alpha;20;1357;1344;1343;1334;1321;1293;1290;1283;1282;1281;1280;1279;1278;1277;1276;1274;1273;1268;1266;1254;;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1244;1456,-2272;Inherit;False;2326.557;1124.512;;25;1361;1339;1338;1337;1330;1329;1326;1325;1322;1318;1316;1313;1312;1309;1307;1304;1299;1294;1291;1289;1287;1286;1285;1284;1267;Additional Layer;0.7721605,0.4669811,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1245;-4512,-2752;Inherit;False;2555.466;1283.535;;44;1360;1358;1356;1355;1354;1353;1352;1351;1350;1349;1348;1347;1332;1320;1317;1314;1300;1297;1295;1292;1288;1275;1272;1271;1270;1269;1265;1264;1263;1262;1261;1260;1259;1258;1257;1256;1255;1253;1252;1251;1250;1249;1248;1247;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1246;-1248,-1840;Inherit;False;2506.716;730.6439;Color;23;1359;1346;1345;1342;1340;1336;1331;1328;1327;1324;1323;1319;1315;1311;1310;1308;1306;1305;1303;1302;1301;1298;1296;;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1247;-2752,-2432;Inherit;False;1249;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1248;-3120,-1728;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1249;-3120,-2384;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1250;-3424,-2384;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1251;-2992,-1728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1252;-4368,-2096;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1253;-3472,-1728;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1254;-1232,-2448;Inherit;False;1292;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1255;-3296,-2384;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1256;-3248,-1728;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1257;-3040,-2112;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1258;-2896,-2112;Inherit;False;CentralUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1259;-2528,-2400;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1260;-4304,-1840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1261;-2848,-1776;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1262;-3264,-2112;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1263;-2720,-1776;Inherit;False;ModifiedCohesion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1264;-4016,-2096;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1265;-4192,-1840;Inherit;False;Scale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1266;96,-2336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1267;1680,-1344;Inherit;False;1263;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1268;-1232,-2128;Inherit;False;1265;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1269;-3536,-2096;Inherit;False;Dot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1270;-3728,-1840;Inherit;False;Spherize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1271;-3376,-1856;Inherit;False;Flatness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1272;-3888,-2096;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.85;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1273;-1024,-2064;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1274;-1232,-2288;Inherit;False;1271;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1275;-3712,-2096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1276;-224,-2336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1277;-1040,-2448;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1278;-1040,-2160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1279;-1232,-1968;Inherit;False;1355;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1280;-1232,-2208;Inherit;False;1270;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1281;-416,-2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1282;-1232,-2048;Inherit;False;1263;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1283;-416,-2384;Inherit;False;1269;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1284;1520,-1728;Inherit;False;1258;CentralUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1285;1680,-1712;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.58;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1286;1680,-1264;Inherit;False;1355;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1287;1680,-1792;Inherit;False;1292;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1288;-2864,-1936;Inherit;False;1269;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1289;1680,-1584;Inherit;False;1271;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1290;-80,-2336;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1291;1680,-1504;Inherit;False;1270;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1292;-2352,-2416;Inherit;False;Wind;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1293;-1232,-2368;Inherit;False;1258;CentralUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1294;2368,-1744;Inherit;False;1269;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1295;-4144,-2096;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1296;-1184,-1728;Inherit;False;1292;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1297;-3632,-1936;Inherit;False;2;2;0;FLOAT;20;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1298;-1184,-1328;Inherit;False;1263;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1299;2480,-1552;Inherit;False;1321;IT2PreAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1300;-2256,-2112;Inherit;False;ShadowUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1301;-944,-1328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1302;-1184,-1648;Inherit;False;1300;ShadowUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1303;-960,-1696;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1304;1984,-2176;Inherit;False;1314;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1305;-1184,-1568;Inherit;False;1270;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1306;-192,-1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1307;3472,-1744;Inherit;False;AdditionalLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1308;-368,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1309;2928,-1776;Inherit;False;0;2;2;0,0,0,0.8676432;1,1,1,0.9294118;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.FunctionNode;1310;-720,-1552;Inherit;True;Ghibli Clouds;-1;;47;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1311;-368,-1632;Inherit;False;1269;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1312;2944,-1632;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1313;2368,-1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1314;-3856,-2640;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1315;-1184,-1488;Inherit;False;1271;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;1316;3152,-1760;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1317;-2368,-2112;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1318;2752,-1712;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1319;-1184,-1248;Inherit;False;1355;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1320;-2624,-2048;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1321;256,-2208;Inherit;False;IT2PreAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1322;2560,-1712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1323;-944,-1424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1324;-48,-1568;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1325;2128,-2096;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1326;2032,-1888;Inherit;False;1307;AdditionalLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1327;128,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1328;64,-1648;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4411841;1,1,1,0.5794156;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.LerpOp;1329;2320,-2112;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1330;1968,-1680;Inherit;True;Ghibli Clouds;-1;;48;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;5;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;1331;272,-1616;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1332;-3856,-2464;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1333;-992,-352;Inherit;False;1343;IT2Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1334;32,-2416;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4617685;1,1,1,0.5117723;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.ClipNode;1335;-768,-416;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1336;592,-1664;Inherit;False;1339;ModifiedCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1337;1680,-1424;Inherit;False;1265;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1338;2960,-1712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1339;2592,-2112;Inherit;False;ModifiedCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1340;592,-1744;Inherit;False;1332;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1341;-992,-464;Inherit;False;1342;IT2Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1342;1040,-1616;Inherit;False;IT2Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1343;576,-2384;Inherit;False;IT2Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;1344;256,-2400;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;1345;672,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1346;880,-1616;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1347;-4048,-2640;Inherit;False;Filter Color;-1;;49;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1348;-4048,-2464;Inherit;False;Filter Color;-1;;50;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1349;-4256,-2448;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;4.919352,4.204114,3.550287,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1350;-4272,-2640;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;False;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;1.01994,0.8557577,0.7989255,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1351;-3168,-1856;Inherit;False;Global;CZY_CloudCohesion;CZY_CloudCohesion;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.887;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1352;-4000,-1840;Inherit;False;Global;CZY_Spherize;CZY_Spherize;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.36;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1353;-2976,-2016;Inherit;False;Global;CZY_ShadowingDistance;CZY_ShadowingDistance;8;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.07;0.03;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1354;-2784,-2320;Inherit;False;Constant;_MainCloudWindDir;Main Cloud Wind Dir;11;0;Create;True;0;0;0;False;0;False;0.1,0.2;0.3,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;1355;-2368,-2608;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1356;-3664,-2368;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1357;-816,-2304;Inherit;True;Ghibli Clouds;-1;;51;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1358;-2848,-2608;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;3;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1359;-1184,-1408;Inherit;False;1265;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1360;-4512,-1840;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;5;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.8;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1361;1904,-2064;Inherit;False;Global;CZY_CloudTextureColor;CZY_CloudTextureColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6320754,0.6320754,0.6320754,0;2.670157,2.670157,2.670157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1362;-1088,-256;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-544,-416;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Ghibli Mobile;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;True;-50;False;Opaque;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1248;0;1256;0
WireConnection;1248;1;1256;0
WireConnection;1249;0;1255;0
WireConnection;1250;1;1356;0
WireConnection;1251;0;1248;0
WireConnection;1255;0;1250;0
WireConnection;1256;0;1253;0
WireConnection;1257;0;1262;0
WireConnection;1258;0;1257;0
WireConnection;1259;0;1247;0
WireConnection;1259;1;1354;0
WireConnection;1260;0;1360;0
WireConnection;1261;0;1351;0
WireConnection;1261;2;1251;0
WireConnection;1263;0;1261;0
WireConnection;1264;0;1295;0
WireConnection;1264;1;1295;0
WireConnection;1265;0;1260;0
WireConnection;1266;0;1290;0
WireConnection;1269;0;1275;0
WireConnection;1270;0;1352;0
WireConnection;1271;0;1297;0
WireConnection;1272;0;1264;0
WireConnection;1273;0;1282;0
WireConnection;1275;0;1272;0
WireConnection;1276;0;1283;0
WireConnection;1276;1;1281;0
WireConnection;1277;0;1254;0
WireConnection;1278;0;1268;0
WireConnection;1281;0;1357;33
WireConnection;1285;0;1284;0
WireConnection;1290;0;1276;0
WireConnection;1292;0;1259;0
WireConnection;1295;0;1252;0
WireConnection;1297;1;1352;0
WireConnection;1300;0;1317;0
WireConnection;1301;0;1298;0
WireConnection;1303;0;1296;0
WireConnection;1306;0;1311;0
WireConnection;1306;1;1308;0
WireConnection;1307;0;1316;1
WireConnection;1308;0;1310;33
WireConnection;1310;37;1303;0
WireConnection;1310;21;1302;0
WireConnection;1310;19;1305;0
WireConnection;1310;20;1315;0
WireConnection;1310;23;1323;0
WireConnection;1310;24;1301;0
WireConnection;1310;27;1319;0
WireConnection;1312;0;1318;0
WireConnection;1313;0;1330;33
WireConnection;1314;0;1347;0
WireConnection;1316;0;1309;0
WireConnection;1316;1;1312;0
WireConnection;1317;0;1258;0
WireConnection;1317;1;1320;0
WireConnection;1318;0;1322;0
WireConnection;1318;4;1299;0
WireConnection;1320;0;1258;0
WireConnection;1320;2;1353;0
WireConnection;1320;3;1288;0
WireConnection;1321;0;1266;0
WireConnection;1322;0;1294;0
WireConnection;1322;1;1313;0
WireConnection;1323;0;1359;0
WireConnection;1324;0;1306;0
WireConnection;1325;0;1304;0
WireConnection;1325;1;1361;0
WireConnection;1327;0;1324;0
WireConnection;1329;0;1304;0
WireConnection;1329;1;1325;0
WireConnection;1329;2;1326;0
WireConnection;1330;37;1287;0
WireConnection;1330;21;1285;0
WireConnection;1330;19;1291;0
WireConnection;1330;20;1289;0
WireConnection;1330;24;1267;0
WireConnection;1330;27;1286;0
WireConnection;1331;0;1328;0
WireConnection;1331;1;1327;0
WireConnection;1332;0;1348;0
WireConnection;1335;0;1341;0
WireConnection;1335;1;1333;0
WireConnection;1335;2;1362;0
WireConnection;1338;0;1318;0
WireConnection;1339;0;1329;0
WireConnection;1342;0;1346;0
WireConnection;1343;0;1344;1
WireConnection;1344;0;1334;0
WireConnection;1344;1;1266;0
WireConnection;1345;0;1331;1
WireConnection;1346;0;1340;0
WireConnection;1346;1;1336;0
WireConnection;1346;2;1345;0
WireConnection;1347;1;1350;0
WireConnection;1348;1;1349;0
WireConnection;1355;0;1358;0
WireConnection;1357;37;1277;0
WireConnection;1357;21;1293;0
WireConnection;1357;19;1280;0
WireConnection;1357;20;1274;0
WireConnection;1357;23;1278;0
WireConnection;1357;24;1273;0
WireConnection;1357;27;1279;0
WireConnection;0;2;1335;0
ASEEND*/
//CHKSM=02641065C87B091C8FEC783F03AF9B620E668091