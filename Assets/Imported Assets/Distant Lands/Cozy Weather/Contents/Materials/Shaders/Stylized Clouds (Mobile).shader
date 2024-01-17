// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Mobile"
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
		uniform float CZY_DetailScale;
		uniform float CZY_DetailAmount;
		uniform half CZY_CloudFlareFalloff;
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


		float2 voronoihash357( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi357( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash357( n + g );
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


		float2 voronoihash327( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi327( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
			 		float2 o = voronoihash327( n + g );
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
			float3 hsvTorgb2_g1 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
			float4 temp_output_406_0 = ( temp_output_10_0_g1 * CZY_CloudFilterColor );
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_CloudHighlightColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 temp_output_407_0 = ( temp_output_10_0_g2 * CZY_SunFilterColor );
			float2 Pos351 = i.uv_texcoord;
			float mulTime342 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float TIme345 = mulTime342;
			float simplePerlin2D360 = snoise( ( Pos351 + ( TIme345 * float2( 0.2,-0.4 ) ) )*( 100.0 / CZY_MainCloudScale ) );
			simplePerlin2D360 = simplePerlin2D360*0.5 + 0.5;
			float2 temp_output_323_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult321 = dot( temp_output_323_0 , temp_output_323_0 );
			float CurrentCloudCover362 = CZY_CumulusCoverageMultiplier;
			float temp_output_330_0 = (0.0 + (dotResult321 - 0.0) * (CurrentCloudCover362 - 0.0) / (0.27 - 0.0));
			float time357 = 0.0;
			float2 voronoiSmoothId357 = 0;
			float2 coords357 = ( Pos351 + ( TIme345 * float2( 0.3,0.2 ) ) ) * ( 140.0 / CZY_MainCloudScale );
			float2 id357 = 0;
			float2 uv357 = 0;
			float voroi357 = voronoi357( coords357, time357, id357, uv357, 0, voronoiSmoothId357 );
			float temp_output_381_0 = (0.0 + (min( ( simplePerlin2D360 + temp_output_330_0 ) , ( ( 1.0 - voroi357 ) + temp_output_330_0 ) ) - ( 1.0 - CurrentCloudCover362 )) * (1.0 - 0.0) / (1.0 - ( 1.0 - CurrentCloudCover362 )));
			float4 lerpResult392 = lerp( temp_output_407_0 , temp_output_406_0 , saturate( (2.0 + (temp_output_381_0 - 0.0) * (0.7 - 2.0) / (1.0 - 0.0)) ));
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult348 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult353 = dot( normalizeResult348 , CZY_SunDirection );
			float temp_output_365_0 = abs( (dotResult353*0.5 + 0.5) );
			half LightMask382 = saturate( pow( temp_output_365_0 , CZY_SunFlareFalloff ) );
			float temp_output_387_0 = ( voroi357 * saturate( ( CurrentCloudCover362 - 0.8 ) ) );
			float4 lerpResult403 = lerp( ( lerpResult392 + ( LightMask382 * temp_output_407_0 * ( 1.0 - temp_output_387_0 ) ) ) , ( temp_output_406_0 * float4( 0.5660378,0.5660378,0.5660378,0 ) ) , temp_output_387_0);
			float time327 = 0.0;
			float2 voronoiSmoothId327 = 0;
			float2 coords327 = ( Pos351 + ( TIme345 * float2( 0.3,0.2 ) ) ) * ( 100.0 / CZY_DetailScale );
			float2 id327 = 0;
			float2 uv327 = 0;
			float fade327 = 0.5;
			float voroi327 = 0;
			float rest327 = 0;
			for( int it327 = 0; it327 <3; it327++ ){
			voroi327 += fade327 * voronoi327( coords327, time327, id327, uv327, 0,voronoiSmoothId327 );
			rest327 += fade327;
			coords327 *= 2;
			fade327 *= 0.5;
			}//Voronoi327
			voroi327 /= rest327;
			float temp_output_331_0 = ( (0.0 + (( 1.0 - voroi327 ) - 0.3) * (0.5 - 0.0) / (1.0 - 0.3)) * 0.1 * CZY_DetailAmount );
			float temp_output_337_0 = saturate( ( temp_output_381_0 + temp_output_331_0 ) );
			float4 lerpResult400 = lerp( temp_output_406_0 , lerpResult403 , (1.0 + (temp_output_337_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
			float CloudDetail332 = temp_output_331_0;
			float CloudLight379 = saturate( pow( temp_output_365_0 , CZY_CloudFlareFalloff ) );
			float4 lerpResult397 = lerp( float4( 0,0,0,0 ) , temp_output_407_0 , ( saturate( ( CurrentCloudCover362 - 1.0 ) ) * CloudDetail332 * CloudLight379 ));
			float4 SunThroughCLouds402 = ( lerpResult397 * 1.3 );
			clip( temp_output_337_0 - CZY_ClippingThreshold);
			o.Emission = ( lerpResult400 + SunThroughCLouds402 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;139.7081,-38.95319;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Clouds Mobile;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;True;-50;False;Opaque;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-2295.901,615.5029;Inherit;False;345;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;319;-2071.901,647.5029;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;320;-1447.901,583.5029;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;321;-3175.901,295.503;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;322;-1911.901,679.5029;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;323;-3383.901,279.503;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;324;-1911.901,583.5029;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;325;-3607.901,279.503;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;326;-2967.901,375.503;Inherit;False;362;CurrentCloudCover;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;327;-1783.901,583.5029;Inherit;False;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;328;-2119.901,535.5029;Inherit;False;351;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;329;-1591.901,583.5029;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;330;-2743.901,295.503;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.27;False;3;FLOAT;0;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;-1255.901,599.5029;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;332;-1095.901,487.503;Inherit;False;CloudDetail;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;333;-1735.901,407.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;334;-1191.901,487.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;335;-1095.901,567.5029;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;336;-823.9006,391.503;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;337;-823.9006,567.5029;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-1431.901,759.5029;Inherit;False;Global;CZY_DetailAmount;CZY_DetailAmount;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;339;-2295.901,711.5029;Inherit;False;Constant;_DetailWind;Detail Wind;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.3,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;340;-2103.901,743.5029;Inherit;False;Global;CZY_DetailScale;CZY_DetailScale;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;-2151.901,-1992.497;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;342;-2023.901,-1976.497;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;343;-3095.901,-1896.497;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;344;-2055.901,-2152.497;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;345;-1847.901,-1992.497;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;346;-3175.901,-1752.497;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;347;-3495.901,-24.49704;Inherit;False;345;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;348;-2791.901,-1832.497;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;-3287.901,-264.497;Inherit;False;351;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-3255.901,39.50296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;351;-1863.901,-2168.497;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;352;-3495.901,-232.497;Inherit;False;345;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;353;-2647.901,-1832.497;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-3255.901,-72.49704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;355;-3063.901,-152.497;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;356;-3047.901,71.50295;Inherit;False;2;0;FLOAT;140;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;357;-2855.901,7.50296;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleAddOpNode;358;-3063.901,-40.49704;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;-2439.901,-8.497041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;360;-2791.901,-232.497;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;-3063.901,-248.497;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-2727.901,-568.4971;Inherit;False;CurrentCloudCover;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;363;-2503.901,-1832.497;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;364;-2663.901,-8.497041;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;365;-2279.901,-1832.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;-2455.901,263.503;Inherit;False;362;CurrentCloudCover;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;367;-2087.901,263.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;368;-2919.901,-1832.497;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;-1175.901,-184.497;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;370;-1783.901,-1144.497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;371;-2231.901,263.503;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;372;-2263.901,-136.497;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-2007.901,-1144.497;Inherit;False;362;CurrentCloudCover;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;374;-2215.901,-248.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;375;-2151.901,-1832.497;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;376;-1943.901,-1608.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;377;-2455.901,-200.497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;378;-1751.901,119.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;-1799.901,-1608.497;Inherit;False;CloudLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;380;-2007.901,-1832.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;381;-2007.901,-88.49704;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;382;-1863.901,-1848.497;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;383;-1527.901,-328.497;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-1655.901,-984.4971;Inherit;False;379;CloudLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-1655.901,-1064.497;Inherit;False;332;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;386;-1623.901,-1144.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;-1927.901,167.503;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;-2455.901,-344.497;Inherit;False;362;CurrentCloudCover;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;389;-2103.901,-1608.497;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;-1431.901,-1112.497;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;391;-1351.901,-216.497;Inherit;False;382;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;392;-1191.901,-424.497;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-1191.901,-1032.497;Inherit;False;Constant;_2;2;15;0;Create;True;0;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;-999.9006,-1144.497;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;396;-1319.901,-328.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;397;-1207.901,-1144.497;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;398;-391.9006,-72.49704;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;399;-983.9006,-264.497;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;400;-615.9006,-136.497;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-1143.901,-40.49704;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5660378,0.5660378,0.5660378,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;-839.9006,-1144.497;Inherit;False;SunThroughCLouds;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;403;-871.9006,-104.497;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;404;-1047.901,119.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;-679.9006,-8.497041;Inherit;False;402;SunThroughCLouds;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;406;-1815.901,-616.4971;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;407;-1783.901,-440.497;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;408;-1623.901,-120.497;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;409;-1591.901,-184.497;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-3303.901,-168.497;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;3;1;[HideInInspector];Create;True;0;0;0;False;0;False;10;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;411;-3495.901,-152.497;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;412;-3511.901,39.50296;Inherit;False;Constant;_CloudWind2;Cloud Wind 2;11;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector3Node;413;-2855.901,-1720.497;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.8699608,0.4921842,0.03037969;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;414;-2375.901,-1976.497;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;10;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;415;-2343.901,-1720.497;Half;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;-2311.901,-1560.497;Half;False;Global;CZY_CloudFlareFalloff;CZY_CloudFlareFalloff;9;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;417;-2039.901,-440.497;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;2;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;4.919352,4.204114,3.550287,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;418;-2039.901,-616.4971;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;1.01994,0.8557577,0.7989255,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;-3015.901,-552.4971;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;7;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;420;-439.9006,119.503;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;15;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;393;-167.9006,-40.49704;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
WireConnection;0;2;393;0
WireConnection;319;0;318;0
WireConnection;319;1;339;0
WireConnection;320;0;329;0
WireConnection;321;0;323;0
WireConnection;321;1;323;0
WireConnection;322;1;340;0
WireConnection;323;0;325;0
WireConnection;324;0;328;0
WireConnection;324;1;319;0
WireConnection;327;0;324;0
WireConnection;327;2;322;0
WireConnection;329;0;327;0
WireConnection;330;0;321;0
WireConnection;330;4;326;0
WireConnection;331;0;320;0
WireConnection;331;2;338;0
WireConnection;332;0;331;0
WireConnection;333;0;381;0
WireConnection;334;0;333;0
WireConnection;335;0;334;0
WireConnection;335;1;331;0
WireConnection;336;0;337;0
WireConnection;337;0;335;0
WireConnection;341;1;414;0
WireConnection;342;0;341;0
WireConnection;345;0;342;0
WireConnection;348;0;368;0
WireConnection;350;0;347;0
WireConnection;350;1;412;0
WireConnection;351;0;344;0
WireConnection;353;0;348;0
WireConnection;353;1;413;0
WireConnection;354;0;352;0
WireConnection;354;1;411;0
WireConnection;355;1;410;0
WireConnection;356;1;410;0
WireConnection;357;0;358;0
WireConnection;357;2;356;0
WireConnection;358;0;349;0
WireConnection;358;1;350;0
WireConnection;359;0;364;0
WireConnection;359;1;330;0
WireConnection;360;0;361;0
WireConnection;360;1;355;0
WireConnection;361;0;349;0
WireConnection;361;1;354;0
WireConnection;362;0;419;0
WireConnection;363;0;353;0
WireConnection;364;0;357;0
WireConnection;365;0;363;0
WireConnection;367;0;371;0
WireConnection;368;0;343;0
WireConnection;368;1;346;0
WireConnection;369;0;391;0
WireConnection;369;1;409;0
WireConnection;369;2;378;0
WireConnection;370;0;373;0
WireConnection;371;0;366;0
WireConnection;372;0;377;0
WireConnection;372;1;359;0
WireConnection;374;0;388;0
WireConnection;375;0;365;0
WireConnection;375;1;415;0
WireConnection;376;0;389;0
WireConnection;377;0;360;0
WireConnection;377;1;330;0
WireConnection;378;0;387;0
WireConnection;379;0;376;0
WireConnection;380;0;375;0
WireConnection;381;0;372;0
WireConnection;381;1;374;0
WireConnection;382;0;380;0
WireConnection;383;0;381;0
WireConnection;386;0;370;0
WireConnection;387;0;357;0
WireConnection;387;1;367;0
WireConnection;389;0;365;0
WireConnection;389;1;416;0
WireConnection;390;0;386;0
WireConnection;390;1;385;0
WireConnection;390;2;384;0
WireConnection;392;0;407;0
WireConnection;392;1;406;0
WireConnection;392;2;396;0
WireConnection;395;0;397;0
WireConnection;395;1;394;0
WireConnection;396;0;383;0
WireConnection;397;1;407;0
WireConnection;397;2;390;0
WireConnection;398;0;400;0
WireConnection;398;1;405;0
WireConnection;399;0;392;0
WireConnection;399;1;369;0
WireConnection;400;0;406;0
WireConnection;400;1;403;0
WireConnection;400;2;336;0
WireConnection;401;0;408;0
WireConnection;402;0;395;0
WireConnection;403;0;399;0
WireConnection;403;1;401;0
WireConnection;403;2;404;0
WireConnection;404;0;387;0
WireConnection;406;1;418;0
WireConnection;407;1;417;0
WireConnection;408;0;406;0
WireConnection;409;0;407;0
WireConnection;393;0;398;0
WireConnection;393;1;337;0
WireConnection;393;2;420;0
ASEEND*/
//CHKSM=DD423E7FEB5A4DAD82A71CC5AE5651C833A526C6