// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Ghibli"
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
		};

		uniform float4 CZY_AltoCloudColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_CloudFilterColor;
		uniform float4 CZY_CloudHighlightColor;
		uniform float4 CZY_CloudColor;
		uniform float CZY_Spherize;
		uniform float CZY_MainCloudScale;
		uniform float CZY_WindSpeed;
		uniform float CZY_CloudCohesion;
		uniform float CZY_CumulusCoverageMultiplier;
		uniform float CZY_ShadowingDistance;
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


		float2 voronoihash35_g55( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g55( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g55( n + g );
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


		float2 voronoihash13_g55( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g55( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g55( n + g );
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


		float2 voronoihash11_g55( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g55( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g55( n + g );
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


		float2 voronoihash35_g50( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g50( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g50( n + g );
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


		float2 voronoihash13_g50( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g50( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g50( n + g );
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


		float2 voronoihash11_g50( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g50( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g50( n + g );
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


		float2 voronoihash35_g54( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g54( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g54( n + g );
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


		float2 voronoihash13_g54( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g54( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g54( n + g );
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


		float2 voronoihash11_g54( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g54( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g54( n + g );
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


		float2 voronoihash35_g53( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi35_g53( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash35_g53( n + g );
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


		float2 voronoihash13_g53( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi13_g53( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash13_g53( n + g );
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


		float2 voronoihash11_g53( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi11_g53( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash11_g53( n + g );
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
			float3 hsvTorgb2_g56 = RGBToHSV( CZY_AltoCloudColor.rgb );
			float3 hsvTorgb3_g56 = HSVToRGB( float3(hsvTorgb2_g56.x,saturate( ( hsvTorgb2_g56.y + CZY_FilterSaturation ) ),( hsvTorgb2_g56.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g56 = ( float4( hsvTorgb3_g56 , 0.0 ) * CZY_FilterColor );
			float3 hsvTorgb2_g58 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g58 = HSVToRGB( float3(hsvTorgb2_g58.x,saturate( ( hsvTorgb2_g58.y + CZY_FilterSaturation ) ),( hsvTorgb2_g58.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g58 = ( float4( hsvTorgb3_g58 , 0.0 ) * CZY_FilterColor );
			float4 CloudHighlightColor1373 = ( temp_output_10_0_g58 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g57 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g57 = HSVToRGB( float3(hsvTorgb2_g57.x,saturate( ( hsvTorgb2_g57.y + CZY_FilterSaturation ) ),( hsvTorgb2_g57.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g57 = ( float4( hsvTorgb3_g57 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor1360 = ( temp_output_10_0_g57 * CZY_CloudFilterColor );
			float4 color1400 = IsGammaSpace() ? float4(0.8396226,0.8396226,0.8396226,0) : float4(0.673178,0.673178,0.673178,0);
			Gradient gradient1349 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.5411765 ), float4( 1, 1, 1, 0.6441138 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float2 temp_output_1244_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1254 = dot( temp_output_1244_0 , temp_output_1244_0 );
			float Dot1280 = saturate( (0.85 + (dotResult1254 - 0.0) * (3.0 - 0.85) / (1.0 - 0.0)) );
			float time35_g55 = 0.0;
			float2 voronoiSmoothId35_g55 = 0;
			float2 CentralUV1258 = ( i.uv_texcoord + float2( -0.5,-0.5 ) );
			float2 temp_output_21_0_g55 = (CentralUV1258*1.58 + 0.0);
			float2 break2_g55 = abs( temp_output_21_0_g55 );
			float saferPower4_g55 = abs( break2_g55.x );
			float saferPower3_g55 = abs( break2_g55.y );
			float saferPower6_g55 = abs( ( pow( saferPower4_g55 , 2.0 ) + pow( saferPower3_g55 , 2.0 ) ) );
			float Spherize1257 = CZY_Spherize;
			float Flatness1263 = ( 20.0 * CZY_Spherize );
			float Scale1395 = ( CZY_MainCloudScale * 0.1 );
			float mulTime1236 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float Time1237 = mulTime1236;
			float2 Wind1249 = ( Time1237 * float2( 0.1,0.2 ) );
			float2 temp_output_10_0_g55 = (( ( temp_output_21_0_g55 * ( pow( saferPower6_g55 , Spherize1257 ) * Flatness1263 ) ) + float2( 0.5,0.5 ) )*( 2.0 / Scale1395 ) + Wind1249);
			float2 coords35_g55 = temp_output_10_0_g55 * 60.0;
			float2 id35_g55 = 0;
			float2 uv35_g55 = 0;
			float fade35_g55 = 0.5;
			float voroi35_g55 = 0;
			float rest35_g55 = 0;
			for( int it35_g55 = 0; it35_g55 <2; it35_g55++ ){
			voroi35_g55 += fade35_g55 * voronoi35_g55( coords35_g55, time35_g55, id35_g55, uv35_g55, 0,voronoiSmoothId35_g55 );
			rest35_g55 += fade35_g55;
			coords35_g55 *= 2;
			fade35_g55 *= 0.5;
			}//Voronoi35_g55
			voroi35_g55 /= rest35_g55;
			float time13_g55 = 0.0;
			float2 voronoiSmoothId13_g55 = 0;
			float2 coords13_g55 = temp_output_10_0_g55 * 25.0;
			float2 id13_g55 = 0;
			float2 uv13_g55 = 0;
			float fade13_g55 = 0.5;
			float voroi13_g55 = 0;
			float rest13_g55 = 0;
			for( int it13_g55 = 0; it13_g55 <2; it13_g55++ ){
			voroi13_g55 += fade13_g55 * voronoi13_g55( coords13_g55, time13_g55, id13_g55, uv13_g55, 0,voronoiSmoothId13_g55 );
			rest13_g55 += fade13_g55;
			coords13_g55 *= 2;
			fade13_g55 *= 0.5;
			}//Voronoi13_g55
			voroi13_g55 /= rest13_g55;
			float time11_g55 = 17.23;
			float2 voronoiSmoothId11_g55 = 0;
			float2 coords11_g55 = temp_output_10_0_g55 * 9.0;
			float2 id11_g55 = 0;
			float2 uv11_g55 = 0;
			float fade11_g55 = 0.5;
			float voroi11_g55 = 0;
			float rest11_g55 = 0;
			for( int it11_g55 = 0; it11_g55 <2; it11_g55++ ){
			voroi11_g55 += fade11_g55 * voronoi11_g55( coords11_g55, time11_g55, id11_g55, uv11_g55, 0,voronoiSmoothId11_g55 );
			rest11_g55 += fade11_g55;
			coords11_g55 *= 2;
			fade11_g55 *= 0.5;
			}//Voronoi11_g55
			voroi11_g55 /= rest11_g55;
			float2 temp_output_1235_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1238 = dot( temp_output_1235_0 , temp_output_1235_0 );
			float ModifiedCohesion1248 = ( CZY_CloudCohesion * 1.0 * ( 1.0 - dotResult1238 ) );
			float lerpResult15_g55 = lerp( saturate( ( voroi35_g55 + voroi13_g55 ) ) , voroi11_g55 , ModifiedCohesion1248);
			float CumulusCoverage1260 = CZY_CumulusCoverageMultiplier;
			float lerpResult16_g55 = lerp( lerpResult15_g55 , 1.0 , ( ( 1.0 - CumulusCoverage1260 ) + -0.7 ));
			float time35_g51 = 0.0;
			float2 voronoiSmoothId35_g51 = 0;
			float2 temp_output_21_0_g51 = CentralUV1258;
			float2 break2_g51 = abs( temp_output_21_0_g51 );
			float saferPower4_g51 = abs( break2_g51.x );
			float saferPower3_g51 = abs( break2_g51.y );
			float saferPower6_g51 = abs( ( pow( saferPower4_g51 , 2.0 ) + pow( saferPower3_g51 , 2.0 ) ) );
			float2 temp_output_10_0_g51 = (( ( temp_output_21_0_g51 * ( pow( saferPower6_g51 , Spherize1257 ) * Flatness1263 ) ) + float2( 0.5,0.5 ) )*( 2.0 / Scale1395 ) + Wind1249);
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
			float lerpResult15_g51 = lerp( saturate( ( voroi35_g51 + voroi13_g51 ) ) , voroi11_g51 , ModifiedCohesion1248);
			float lerpResult16_g51 = lerp( lerpResult15_g51 , 1.0 , ( ( 1.0 - CumulusCoverage1260 ) + -0.7 ));
			float temp_output_1291_0 = saturate( (0.0 + (( Dot1280 * ( 1.0 - lerpResult16_g51 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) );
			float IT1PreAlpha1350 = temp_output_1291_0;
			float time35_g50 = 0.0;
			float2 voronoiSmoothId35_g50 = 0;
			float2 temp_output_21_0_g50 = CentralUV1258;
			float2 break2_g50 = abs( temp_output_21_0_g50 );
			float saferPower4_g50 = abs( break2_g50.x );
			float saferPower3_g50 = abs( break2_g50.y );
			float saferPower6_g50 = abs( ( pow( saferPower4_g50 , 2.0 ) + pow( saferPower3_g50 , 2.0 ) ) );
			float2 temp_output_10_0_g50 = (( ( temp_output_21_0_g50 * ( pow( saferPower6_g50 , Spherize1257 ) * Flatness1263 ) ) + float2( 0.5,0.5 ) )*( 2.0 / ( Scale1395 * 1.5 ) ) + ( Wind1249 * float2( 0.5,0.5 ) ));
			float2 coords35_g50 = temp_output_10_0_g50 * 60.0;
			float2 id35_g50 = 0;
			float2 uv35_g50 = 0;
			float fade35_g50 = 0.5;
			float voroi35_g50 = 0;
			float rest35_g50 = 0;
			for( int it35_g50 = 0; it35_g50 <2; it35_g50++ ){
			voroi35_g50 += fade35_g50 * voronoi35_g50( coords35_g50, time35_g50, id35_g50, uv35_g50, 0,voronoiSmoothId35_g50 );
			rest35_g50 += fade35_g50;
			coords35_g50 *= 2;
			fade35_g50 *= 0.5;
			}//Voronoi35_g50
			voroi35_g50 /= rest35_g50;
			float time13_g50 = 0.0;
			float2 voronoiSmoothId13_g50 = 0;
			float2 coords13_g50 = temp_output_10_0_g50 * 25.0;
			float2 id13_g50 = 0;
			float2 uv13_g50 = 0;
			float fade13_g50 = 0.5;
			float voroi13_g50 = 0;
			float rest13_g50 = 0;
			for( int it13_g50 = 0; it13_g50 <2; it13_g50++ ){
			voroi13_g50 += fade13_g50 * voronoi13_g50( coords13_g50, time13_g50, id13_g50, uv13_g50, 0,voronoiSmoothId13_g50 );
			rest13_g50 += fade13_g50;
			coords13_g50 *= 2;
			fade13_g50 *= 0.5;
			}//Voronoi13_g50
			voroi13_g50 /= rest13_g50;
			float time11_g50 = 17.23;
			float2 voronoiSmoothId11_g50 = 0;
			float2 coords11_g50 = temp_output_10_0_g50 * 9.0;
			float2 id11_g50 = 0;
			float2 uv11_g50 = 0;
			float fade11_g50 = 0.5;
			float voroi11_g50 = 0;
			float rest11_g50 = 0;
			for( int it11_g50 = 0; it11_g50 <2; it11_g50++ ){
			voroi11_g50 += fade11_g50 * voronoi11_g50( coords11_g50, time11_g50, id11_g50, uv11_g50, 0,voronoiSmoothId11_g50 );
			rest11_g50 += fade11_g50;
			coords11_g50 *= 2;
			fade11_g50 *= 0.5;
			}//Voronoi11_g50
			voroi11_g50 /= rest11_g50;
			float lerpResult15_g50 = lerp( saturate( ( voroi35_g50 + voroi13_g50 ) ) , voroi11_g50 , ( ModifiedCohesion1248 * 1.1 ));
			float lerpResult16_g50 = lerp( lerpResult15_g50 , 1.0 , ( ( 1.0 - CumulusCoverage1260 ) + -0.7 ));
			float temp_output_1292_0 = saturate( (0.0 + (( Dot1280 * ( 1.0 - lerpResult16_g50 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) );
			float IT2PreAlpha1345 = temp_output_1292_0;
			float temp_output_1382_0 = (0.0 + (( Dot1280 * ( 1.0 - lerpResult16_g55 ) ) - 0.6) * (max( IT1PreAlpha1350 , IT2PreAlpha1345 ) - 0.0) / (1.5 - 0.6));
			float clampResult1304 = clamp( temp_output_1382_0 , 0.0 , 0.9 );
			float AdditionalLayer1369 = SampleGradient( gradient1349, clampResult1304 ).r;
			float4 lerpResult1306 = lerp( CloudColor1360 , ( CloudColor1360 * color1400 ) , AdditionalLayer1369);
			float4 ModifiedCloudColor1331 = lerpResult1306;
			Gradient gradient1367 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4411841 ), float4( 1, 1, 1, 0.5794156 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float time35_g54 = 0.0;
			float2 voronoiSmoothId35_g54 = 0;
			float2 ShadowUV1346 = ( CentralUV1258 + ( CentralUV1258 * float2( -1,-1 ) * CZY_ShadowingDistance * Dot1280 ) );
			float2 temp_output_21_0_g54 = ShadowUV1346;
			float2 break2_g54 = abs( temp_output_21_0_g54 );
			float saferPower4_g54 = abs( break2_g54.x );
			float saferPower3_g54 = abs( break2_g54.y );
			float saferPower6_g54 = abs( ( pow( saferPower4_g54 , 2.0 ) + pow( saferPower3_g54 , 2.0 ) ) );
			float2 temp_output_10_0_g54 = (( ( temp_output_21_0_g54 * ( pow( saferPower6_g54 , Spherize1257 ) * Flatness1263 ) ) + float2( 0.5,0.5 ) )*( 2.0 / Scale1395 ) + Wind1249);
			float2 coords35_g54 = temp_output_10_0_g54 * 60.0;
			float2 id35_g54 = 0;
			float2 uv35_g54 = 0;
			float fade35_g54 = 0.5;
			float voroi35_g54 = 0;
			float rest35_g54 = 0;
			for( int it35_g54 = 0; it35_g54 <2; it35_g54++ ){
			voroi35_g54 += fade35_g54 * voronoi35_g54( coords35_g54, time35_g54, id35_g54, uv35_g54, 0,voronoiSmoothId35_g54 );
			rest35_g54 += fade35_g54;
			coords35_g54 *= 2;
			fade35_g54 *= 0.5;
			}//Voronoi35_g54
			voroi35_g54 /= rest35_g54;
			float time13_g54 = 0.0;
			float2 voronoiSmoothId13_g54 = 0;
			float2 coords13_g54 = temp_output_10_0_g54 * 25.0;
			float2 id13_g54 = 0;
			float2 uv13_g54 = 0;
			float fade13_g54 = 0.5;
			float voroi13_g54 = 0;
			float rest13_g54 = 0;
			for( int it13_g54 = 0; it13_g54 <2; it13_g54++ ){
			voroi13_g54 += fade13_g54 * voronoi13_g54( coords13_g54, time13_g54, id13_g54, uv13_g54, 0,voronoiSmoothId13_g54 );
			rest13_g54 += fade13_g54;
			coords13_g54 *= 2;
			fade13_g54 *= 0.5;
			}//Voronoi13_g54
			voroi13_g54 /= rest13_g54;
			float time11_g54 = 17.23;
			float2 voronoiSmoothId11_g54 = 0;
			float2 coords11_g54 = temp_output_10_0_g54 * 9.0;
			float2 id11_g54 = 0;
			float2 uv11_g54 = 0;
			float fade11_g54 = 0.5;
			float voroi11_g54 = 0;
			float rest11_g54 = 0;
			for( int it11_g54 = 0; it11_g54 <2; it11_g54++ ){
			voroi11_g54 += fade11_g54 * voronoi11_g54( coords11_g54, time11_g54, id11_g54, uv11_g54, 0,voronoiSmoothId11_g54 );
			rest11_g54 += fade11_g54;
			coords11_g54 *= 2;
			fade11_g54 *= 0.5;
			}//Voronoi11_g54
			voroi11_g54 /= rest11_g54;
			float lerpResult15_g54 = lerp( saturate( ( voroi35_g54 + voroi13_g54 ) ) , voroi11_g54 , ModifiedCohesion1248);
			float lerpResult16_g54 = lerp( lerpResult15_g54 , 1.0 , ( ( 1.0 - CumulusCoverage1260 ) + -0.7 ));
			float4 lerpResult1314 = lerp( CloudHighlightColor1373 , ModifiedCloudColor1331 , saturate( SampleGradient( gradient1367, saturate( (0.0 + (( Dot1280 * ( 1.0 - lerpResult16_g54 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) ) ).r ));
			float4 IT1Color1311 = lerpResult1314;
			Gradient gradient1340 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4411841 ), float4( 1, 1, 1, 0.5794156 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float time35_g53 = 0.0;
			float2 voronoiSmoothId35_g53 = 0;
			float2 temp_output_21_0_g53 = ShadowUV1346;
			float2 break2_g53 = abs( temp_output_21_0_g53 );
			float saferPower4_g53 = abs( break2_g53.x );
			float saferPower3_g53 = abs( break2_g53.y );
			float saferPower6_g53 = abs( ( pow( saferPower4_g53 , 2.0 ) + pow( saferPower3_g53 , 2.0 ) ) );
			float2 temp_output_10_0_g53 = (( ( temp_output_21_0_g53 * ( pow( saferPower6_g53 , Spherize1257 ) * Flatness1263 ) ) + float2( 0.5,0.5 ) )*( 2.0 / ( Scale1395 * 1.5 ) ) + ( Wind1249 * float2( 0.5,0.5 ) ));
			float2 coords35_g53 = temp_output_10_0_g53 * 60.0;
			float2 id35_g53 = 0;
			float2 uv35_g53 = 0;
			float fade35_g53 = 0.5;
			float voroi35_g53 = 0;
			float rest35_g53 = 0;
			for( int it35_g53 = 0; it35_g53 <2; it35_g53++ ){
			voroi35_g53 += fade35_g53 * voronoi35_g53( coords35_g53, time35_g53, id35_g53, uv35_g53, 0,voronoiSmoothId35_g53 );
			rest35_g53 += fade35_g53;
			coords35_g53 *= 2;
			fade35_g53 *= 0.5;
			}//Voronoi35_g53
			voroi35_g53 /= rest35_g53;
			float time13_g53 = 0.0;
			float2 voronoiSmoothId13_g53 = 0;
			float2 coords13_g53 = temp_output_10_0_g53 * 25.0;
			float2 id13_g53 = 0;
			float2 uv13_g53 = 0;
			float fade13_g53 = 0.5;
			float voroi13_g53 = 0;
			float rest13_g53 = 0;
			for( int it13_g53 = 0; it13_g53 <2; it13_g53++ ){
			voroi13_g53 += fade13_g53 * voronoi13_g53( coords13_g53, time13_g53, id13_g53, uv13_g53, 0,voronoiSmoothId13_g53 );
			rest13_g53 += fade13_g53;
			coords13_g53 *= 2;
			fade13_g53 *= 0.5;
			}//Voronoi13_g53
			voroi13_g53 /= rest13_g53;
			float time11_g53 = 17.23;
			float2 voronoiSmoothId11_g53 = 0;
			float2 coords11_g53 = temp_output_10_0_g53 * 9.0;
			float2 id11_g53 = 0;
			float2 uv11_g53 = 0;
			float fade11_g53 = 0.5;
			float voroi11_g53 = 0;
			float rest11_g53 = 0;
			for( int it11_g53 = 0; it11_g53 <2; it11_g53++ ){
			voroi11_g53 += fade11_g53 * voronoi11_g53( coords11_g53, time11_g53, id11_g53, uv11_g53, 0,voronoiSmoothId11_g53 );
			rest11_g53 += fade11_g53;
			coords11_g53 *= 2;
			fade11_g53 *= 0.5;
			}//Voronoi11_g53
			voroi11_g53 /= rest11_g53;
			float lerpResult15_g53 = lerp( saturate( ( voroi35_g53 + voroi13_g53 ) ) , voroi11_g53 , ( ModifiedCohesion1248 * 1.1 ));
			float lerpResult16_g53 = lerp( lerpResult15_g53 , 1.0 , ( ( 1.0 - CumulusCoverage1260 ) + -0.7 ));
			float4 lerpResult1319 = lerp( CloudHighlightColor1373 , ModifiedCloudColor1331 , saturate( SampleGradient( gradient1340, saturate( (0.0 + (( Dot1280 * ( 1.0 - lerpResult16_g53 ) ) - 0.6) * (1.0 - 0.0) / (1.0 - 0.6)) ) ).r ));
			float4 IT2Color1337 = lerpResult1319;
			Gradient gradient1293 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4617685 ), float4( 1, 1, 1, 0.5117723 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float IT2Alpha1296 = SampleGradient( gradient1293, temp_output_1292_0 ).r;
			float4 lerpResult1310 = lerp( ( ( temp_output_10_0_g56 * CZY_CloudFilterColor ) * IT1Color1311 ) , IT2Color1337 , IT2Alpha1296);
			o.Emission = lerpResult1310.rgb;
			Gradient gradient1290 = NewGradient( 0, 2, 2, float4( 0.06119964, 0.06119964, 0.06119964, 0.4617685 ), float4( 1, 1, 1, 0.5117723 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float IT1Alpha1297 = SampleGradient( gradient1290, temp_output_1291_0 ).r;
			float temp_output_1404_0 = max( IT1Alpha1297 , IT2Alpha1296 );
			o.Alpha = saturate( ( temp_output_1404_0 + ( temp_output_1404_0 * 2.0 * CZY_CloudThickness ) ) );
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
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-670.0242,-403.7039;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Ghibli;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;-50;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;1232;-4464,-2656;Inherit;False;2555.466;1283.535;;48;1401;1397;1396;1395;1394;1393;1392;1391;1390;1389;1388;1387;1386;1385;1376;1373;1360;1358;1346;1323;1316;1305;1280;1277;1263;1260;1259;1258;1257;1254;1251;1250;1249;1248;1246;1245;1244;1243;1242;1241;1240;1239;1238;1237;1236;1235;1234;1233;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1233;-3408,-1632;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1234;-3376,-2272;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1235;-3184,-1632;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1236;-3248,-2272;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1237;-3072,-2272;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1238;-3056,-1632;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1239;-2928,-1632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1240;-2688,-2336;Inherit;False;1237;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1241;-4304,-2000;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1242;-4304,-1744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1243;-3200,-2016;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1244;-4080,-2000;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1245;-2464,-2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1246;-2784,-1680;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1247;-1280,-2464;Inherit;False;2636.823;1492.163;;2;1298;1252;Iteration 2;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1248;-2656,-1680;Inherit;False;ModifiedCohesion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1249;-2288,-2320;Inherit;False;Wind;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1250;-2976,-2016;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1251;-3632,-1824;Inherit;False;2;2;0;FLOAT;20;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1252;-1216,-2400;Inherit;False;2070.976;624.3994;Alpha;20;1345;1296;1295;1293;1292;1289;1286;1284;1282;1279;1276;1274;1273;1270;1269;1268;1264;1262;1261;1255;;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1253;-1296,-4272;Inherit;False;2487.393;1546.128;;2;1300;1256;Iteration 1;0.6466299,1,0.5707547,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;1254;-3952,-2000;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1255;-1184,-2352;Inherit;False;1249;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1256;-1232,-4240;Inherit;False;1970.693;633.926;IT1 Alpha;17;1350;1297;1294;1291;1290;1288;1287;1285;1283;1281;1278;1275;1272;1271;1267;1266;1265;;0.6466299,1,0.5707547,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1257;-3664,-1744;Inherit;False;Spherize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1258;-2832,-2016;Inherit;False;CentralUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1259;-3824,-2000;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.85;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1260;-2288,-2512;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1261;-1184,-2032;Inherit;False;1395;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1262;-1184,-1952;Inherit;False;1248;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1263;-3312,-1760;Inherit;False;Flatness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1264;-1184,-2112;Inherit;False;1257;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1265;-1200,-4112;Inherit;False;1258;CentralUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1266;-1200,-3952;Inherit;False;1257;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1267;-1200,-3712;Inherit;False;1260;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1268;-1184,-2192;Inherit;False;1263;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1269;-976,-1952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1270;-1184,-1872;Inherit;False;1260;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1271;-1200,-4192;Inherit;False;1249;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1272;-1200,-3872;Inherit;False;1395;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1273;-976,-2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1274;-992,-2336;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1275;-1200,-4032;Inherit;False;1263;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1276;-1184,-2272;Inherit;False;1258;CentralUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1277;-3648,-2000;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1278;-1200,-3792;Inherit;False;1248;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1279;-768,-2208;Inherit;True;Ghibli Clouds;-1;;50;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1280;-3472,-2000;Inherit;False;Dot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1281;-880,-4064;Inherit;True;Ghibli Clouds;-1;;51;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1282;-368,-2208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1283;-480,-4144;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1284;-368,-2288;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1285;-480,-4064;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1286;-176,-2240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1287;-288,-4096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1288;-144,-4096;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1289;-32,-2240;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1290;-32,-4176;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4617685;1,1,1,0.5117723;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SaturateNode;1291;32,-4096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1292;144,-2240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1293;80,-2320;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4617685;1,1,1,0.5117723;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;1294;192,-4160;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;1295;304,-2304;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1296;624,-2288;Inherit;False;IT2Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1297;512,-4144;Inherit;False;IT1Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1298;-1200,-1744;Inherit;False;2506.716;730.6439;Color;23;1381;1380;1379;1374;1356;1354;1352;1343;1341;1340;1337;1336;1334;1333;1329;1320;1319;1318;1315;1313;1309;1302;1301;;1,0.8737146,0.572549,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1299;1520,-2160;Inherit;False;2326.557;1124.512;;27;1400;1382;1377;1375;1371;1370;1369;1364;1362;1357;1355;1353;1351;1349;1347;1342;1332;1331;1327;1326;1321;1317;1312;1307;1306;1304;1303;Additional Layer;0.7721605,0.4669811,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1300;-1216,-3584;Inherit;False;2346.81;781.6527;IT1 Color;20;1383;1378;1372;1368;1367;1365;1363;1361;1359;1348;1344;1339;1338;1335;1328;1325;1324;1322;1314;1311;;0.6466299,1,0.5707547,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1301;640,-1568;Inherit;False;1331;ModifiedCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1302;640,-1648;Inherit;False;1373;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1303;1728,-1616;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.58;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;1304;2992,-1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1305;-2304,-2016;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;1306;2368,-2016;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1307;2032,-2080;Inherit;False;1360;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1308;-1248,-336;Inherit;False;1337;IT2Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1309;-320,-1456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1310;-1040,-400;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1311;912,-3360;Inherit;False;IT1Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1312;3008,-1616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1313;-912,-1600;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;1314;752,-3360;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1315;-1136,-1232;Inherit;False;1248;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1316;-2800,-1840;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;1317;3200,-1664;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;1318;320,-1520;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1319;928,-1520;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1320;-144,-1472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1321;2640,-1472;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1322;-320,-3312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1323;-3072,-2448;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1324;464,-3488;Inherit;False;1373;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1325;544,-3296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1326;1728,-1696;Inherit;False;1249;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1327;2448,-1392;Inherit;False;1345;IT2PreAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1328;464,-3408;Inherit;False;1331;ModifiedCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1329;-1136,-1312;Inherit;False;1395;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1330;-1216,-448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1331;2640,-2016;Inherit;False;ModifiedCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1332;1728,-1488;Inherit;False;1263;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1333;-1136,-1472;Inherit;False;1257;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1334;-320,-1536;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1335;-1152,-2992;Inherit;False;1260;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1336;-1136,-1632;Inherit;False;1249;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1337;1088,-1520;Inherit;False;IT2Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1338;-1152,-3072;Inherit;False;1248;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1339;-1152,-3312;Inherit;False;1257;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;1340;112,-1552;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4411841;1,1,1,0.5794156;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1341;-1136,-1392;Inherit;False;1263;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1342;1728,-1408;Inherit;False;1257;Spherize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1343;-672,-1456;Inherit;True;Ghibli Clouds;-1;;53;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1344;-1152,-3392;Inherit;False;1346;ShadowUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1345;304,-2112;Inherit;False;IT2PreAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1346;-2192,-2016;Inherit;False;ShadowUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1347;2416,-1648;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1348;-1152,-3472;Inherit;False;1249;Wind;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GradientNode;1349;2976,-1680;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.5411765;1,1,1,0.6441138;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1350;192,-3968;Inherit;False;IT1PreAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1351;1568,-1632;Inherit;False;1258;CentralUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1352;720,-1456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1353;1728,-1328;Inherit;False;1395;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1354;-1136,-1552;Inherit;False;1346;ShadowUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1355;2608,-1616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1356;0,-1472;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1357;2448,-1472;Inherit;False;1350;IT1PreAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1358;-3280,-2448;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1359;-496,-3376;Inherit;False;1280;Dot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1360;-3808,-2544;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1361;-848,-3296;Inherit;True;Ghibli Clouds;-1;;54;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1362;2080,-1792;Inherit;False;1369;AdditionalLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1363;-1152,-3232;Inherit;False;1263;Flatness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1364;2416,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1365;-176,-3312;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1366;-1424,-432;Inherit;False;1311;IT1Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;1367;-64,-3392;Inherit;False;0;2;2;0.06119964,0.06119964,0.06119964,0.4411841;1,1,1,0.5794156;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SaturateNode;1368;0,-3312;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1369;3520,-1648;Inherit;False;AdditionalLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1370;2176,-2000;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1371;1728,-1248;Inherit;False;1248;ModifiedCohesion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1372;-1152,-3152;Inherit;False;1395;Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1373;-3808,-2352;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1374;176,-1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1375;1728,-1168;Inherit;False;1260;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1376;-2560,-1952;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;1377;2016,-1584;Inherit;True;Ghibli Clouds;-1;;55;bce7362c867d47d49a15818b7e6650d4;0;7;37;FLOAT2;0,0;False;21;FLOAT2;0,0;False;19;FLOAT;1;False;20;FLOAT;1;False;23;FLOAT;1;False;24;FLOAT;0;False;27;FLOAT;0.5;False;2;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1378;-496,-3296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1379;-896,-1232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1380;-896,-1328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1381;-1136,-1152;Inherit;False;1260;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1382;2800,-1616;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;1383;144,-3360;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1384;-1376,-544;Inherit;False;Filter Color;-1;;56;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1385;-4016,-2528;Inherit;False;Filter Color;-1;;57;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1386;-4000,-2352;Inherit;False;Filter Color;-1;;58;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1387;-3344,-2560;Inherit;False;Filter Color;-1;;59;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1388;-3136,-2560;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1389;-3520,-2256;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1390;-4256,-2352;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;2;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;4.919352,4.204114,3.550287,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1391;-4256,-2528;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;False;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;1.01994,0.8557577,0.7989255,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1392;-3552,-2560;Inherit;False;Global;CZY_MoonColor;CZY_MoonColor;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;1.840437,1.862886,2.066246,0.2458436;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1393;-2800,-2544;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;4;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1394;-2720,-2224;Inherit;False;Constant;_MainCloudWindDir;Main Cloud Wind Dir;11;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.1,0.2;0.3,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;1395;-4160,-1744;Inherit;False;Scale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1396;-2912,-1920;Inherit;False;Global;CZY_ShadowingDistance;CZY_ShadowingDistance;9;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.07;0.03;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1397;-3104,-1760;Inherit;False;Global;CZY_CloudCohesion;CZY_CloudCohesion;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.887;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1398;-4496,-1744;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.8;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1399;-1616,-608;Inherit;False;Global;CZY_AltoCloudColor;CZY_AltoCloudColor;11;1;[HDR];Create;False;0;0;0;False;0;False;0.8160377,0.9787034,1,0;1.083397,1.392001,1.382235,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1400;1952,-1968;Inherit;False;Constant;_SecondLayer;Second Layer;10;2;[HideInInspector];[HDR];Create;True;0;0;0;False;0;False;0.8396226,0.8396226,0.8396226,0;0.9056604,0.9056604,0.9056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1401;-3936,-1744;Inherit;False;Global;CZY_Spherize;CZY_Spherize;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.36;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1402;-1648,-320;Inherit;False;1297;IT1Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1403;-1664,-192;Inherit;False;1296;IT2Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1404;-1440,-240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1405;-1248,-176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1406;-1120,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1407;-992,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1408;-1536,-96;Inherit;False;Global;CZY_CloudThickness;CZY_CloudThickness;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
WireConnection;0;2;1310;0
WireConnection;0;9;1407;0
WireConnection;1234;1;1389;0
WireConnection;1235;0;1233;0
WireConnection;1236;0;1234;0
WireConnection;1237;0;1236;0
WireConnection;1238;0;1235;0
WireConnection;1238;1;1235;0
WireConnection;1239;0;1238;0
WireConnection;1242;0;1398;0
WireConnection;1244;0;1241;0
WireConnection;1245;0;1240;0
WireConnection;1245;1;1394;0
WireConnection;1246;0;1397;0
WireConnection;1246;2;1239;0
WireConnection;1248;0;1246;0
WireConnection;1249;0;1245;0
WireConnection;1250;0;1243;0
WireConnection;1251;1;1401;0
WireConnection;1254;0;1244;0
WireConnection;1254;1;1244;0
WireConnection;1257;0;1401;0
WireConnection;1258;0;1250;0
WireConnection;1259;0;1254;0
WireConnection;1260;0;1393;0
WireConnection;1263;0;1251;0
WireConnection;1269;0;1262;0
WireConnection;1273;0;1261;0
WireConnection;1274;0;1255;0
WireConnection;1277;0;1259;0
WireConnection;1279;37;1274;0
WireConnection;1279;21;1276;0
WireConnection;1279;19;1264;0
WireConnection;1279;20;1268;0
WireConnection;1279;23;1273;0
WireConnection;1279;24;1269;0
WireConnection;1279;27;1270;0
WireConnection;1280;0;1277;0
WireConnection;1281;37;1271;0
WireConnection;1281;21;1265;0
WireConnection;1281;19;1266;0
WireConnection;1281;20;1275;0
WireConnection;1281;23;1272;0
WireConnection;1281;24;1278;0
WireConnection;1281;27;1267;0
WireConnection;1282;0;1279;33
WireConnection;1285;0;1281;33
WireConnection;1286;0;1284;0
WireConnection;1286;1;1282;0
WireConnection;1287;0;1283;0
WireConnection;1287;1;1285;0
WireConnection;1288;0;1287;0
WireConnection;1289;0;1286;0
WireConnection;1291;0;1288;0
WireConnection;1292;0;1289;0
WireConnection;1294;0;1290;0
WireConnection;1294;1;1291;0
WireConnection;1295;0;1293;0
WireConnection;1295;1;1292;0
WireConnection;1296;0;1295;1
WireConnection;1297;0;1294;1
WireConnection;1303;0;1351;0
WireConnection;1304;0;1382;0
WireConnection;1305;0;1258;0
WireConnection;1305;1;1376;0
WireConnection;1306;0;1307;0
WireConnection;1306;1;1370;0
WireConnection;1306;2;1362;0
WireConnection;1309;0;1343;33
WireConnection;1310;0;1330;0
WireConnection;1310;1;1308;0
WireConnection;1310;2;1403;0
WireConnection;1311;0;1314;0
WireConnection;1312;0;1382;0
WireConnection;1313;0;1336;0
WireConnection;1314;0;1324;0
WireConnection;1314;1;1328;0
WireConnection;1314;2;1325;0
WireConnection;1317;0;1349;0
WireConnection;1317;1;1304;0
WireConnection;1318;0;1340;0
WireConnection;1318;1;1374;0
WireConnection;1319;0;1302;0
WireConnection;1319;1;1301;0
WireConnection;1319;2;1352;0
WireConnection;1320;0;1334;0
WireConnection;1320;1;1309;0
WireConnection;1321;0;1357;0
WireConnection;1321;1;1327;0
WireConnection;1322;0;1359;0
WireConnection;1322;1;1378;0
WireConnection;1323;0;1358;0
WireConnection;1325;0;1383;1
WireConnection;1330;0;1384;0
WireConnection;1330;1;1366;0
WireConnection;1331;0;1306;0
WireConnection;1337;0;1319;0
WireConnection;1343;37;1313;0
WireConnection;1343;21;1354;0
WireConnection;1343;19;1333;0
WireConnection;1343;20;1341;0
WireConnection;1343;23;1380;0
WireConnection;1343;24;1379;0
WireConnection;1343;27;1381;0
WireConnection;1345;0;1292;0
WireConnection;1346;0;1305;0
WireConnection;1350;0;1291;0
WireConnection;1352;0;1318;1
WireConnection;1355;0;1347;0
WireConnection;1355;1;1364;0
WireConnection;1356;0;1320;0
WireConnection;1360;0;1385;0
WireConnection;1361;37;1348;0
WireConnection;1361;21;1344;0
WireConnection;1361;19;1339;0
WireConnection;1361;20;1363;0
WireConnection;1361;23;1372;0
WireConnection;1361;24;1338;0
WireConnection;1361;27;1335;0
WireConnection;1364;0;1377;33
WireConnection;1365;0;1322;0
WireConnection;1368;0;1365;0
WireConnection;1369;0;1317;1
WireConnection;1370;0;1307;0
WireConnection;1370;1;1400;0
WireConnection;1373;0;1386;0
WireConnection;1374;0;1356;0
WireConnection;1376;0;1258;0
WireConnection;1376;2;1396;0
WireConnection;1376;3;1316;0
WireConnection;1377;37;1326;0
WireConnection;1377;21;1303;0
WireConnection;1377;19;1342;0
WireConnection;1377;20;1332;0
WireConnection;1377;23;1353;0
WireConnection;1377;24;1371;0
WireConnection;1377;27;1375;0
WireConnection;1378;0;1361;33
WireConnection;1379;0;1315;0
WireConnection;1380;0;1329;0
WireConnection;1382;0;1355;0
WireConnection;1382;4;1321;0
WireConnection;1383;0;1367;0
WireConnection;1383;1;1368;0
WireConnection;1384;1;1399;0
WireConnection;1385;1;1391;0
WireConnection;1386;1;1390;0
WireConnection;1387;1;1392;0
WireConnection;1388;0;1387;0
WireConnection;1395;0;1242;0
WireConnection;1404;0;1402;0
WireConnection;1404;1;1403;0
WireConnection;1405;0;1404;0
WireConnection;1405;2;1408;0
WireConnection;1406;0;1404;0
WireConnection;1406;1;1405;0
WireConnection;1407;0;1406;0
ASEEND*/
//CHKSM=B080CC00E8716FA503DD5EC943F134F64DA5F915