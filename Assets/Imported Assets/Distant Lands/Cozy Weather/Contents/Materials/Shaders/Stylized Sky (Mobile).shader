// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Sky Mobile"
{
	Properties
	{
		_StarMap("Star Map", 2D) = "white" {}
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
			Ref 221
			Comp Always
			Pass Replace
		}
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float4 CZY_HorizonColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_ZenithColor;
		uniform float3 CZY_SunDirection;
		uniform float CZY_SunFlareFalloff;
		uniform float4 CZY_SunFlareColor;
		uniform float CZY_Power;
		uniform float4 CZY_SunColor;
		uniform float CZY_SunSize;
		uniform float3 CZY_MoonDirection;
		uniform half CZY_MoonFlareFalloff;
		uniform float4 CZY_MoonFlareColor;
		uniform sampler2D _StarMap;
		uniform sampler2D CZY_StarMap;
		uniform float4 CZY_StarColor;


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


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 hsvTorgb2_g1 = RGBToHSV( CZY_HorizonColor.rgb );
			float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
			float4 HorizonColor125 = temp_output_10_0_g1;
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_ZenithColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 ZenithColor127 = temp_output_10_0_g2;
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult77 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult88 = dot( normalizeResult77 , CZY_SunDirection );
			float SunDot118 = dotResult88;
			float3 hsvTorgb2_g4 = RGBToHSV( CZY_SunFlareColor.rgb );
			float3 hsvTorgb3_g4 = HSVToRGB( float3(hsvTorgb2_g4.x,saturate( ( hsvTorgb2_g4.y + CZY_FilterSaturation ) ),( hsvTorgb2_g4.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g4 = ( float4( hsvTorgb3_g4 , 0.0 ) * CZY_FilterColor );
			half4 SunFlare170 = abs( ( saturate( pow( abs( (SunDot118*0.5 + 0.5) ) , CZY_SunFlareFalloff ) ) * temp_output_10_0_g4 ) );
			float4 temp_cast_6 = (CZY_Power).xxxx;
			float4 GradientPos93 = ( 1.0 - saturate( pow( saturate( (float4( 0,0,0,0 ) + (SunFlare170 - float4( 0,0,0,0 )) * (float4( 2,1,1,1 ) - float4( 0,0,0,0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) ) , temp_cast_6 ) ) );
			float4 lerpResult114 = lerp( HorizonColor125 , ZenithColor127 , saturate( GradientPos93 ));
			float4 SimpleSkyGradient163 = lerpResult114;
			float4 SunRender90 = ( CZY_SunColor * ( ( 1.0 - SunDot118 ) > ( pow( CZY_SunSize , 3.0 ) * 0.0007 ) ? 0.0 : 1.0 ) );
			float3 normalizeResult64 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult59 = dot( normalizeResult64 , CZY_MoonDirection );
			float MoonDot65 = dotResult59;
			float3 hsvTorgb2_g3 = RGBToHSV( CZY_MoonFlareColor.rgb );
			float3 hsvTorgb3_g3 = HSVToRGB( float3(hsvTorgb2_g3.x,saturate( ( hsvTorgb2_g3.y + CZY_FilterSaturation ) ),( hsvTorgb2_g3.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g3 = ( float4( hsvTorgb3_g3 , 0.0 ) * CZY_FilterColor );
			half4 MoonFlare167 = abs( ( saturate( pow( abs( (MoonDot65*0.5 + 0.5) ) , CZY_MoonFlareFalloff ) ) * temp_output_10_0_g3 ) );
			float2 Pos57 = i.uv_texcoord;
			float mulTime134 = _Time.y * 0.005;
			float cos131 = cos( mulTime134 );
			float sin131 = sin( mulTime134 );
			float2 rotator131 = mul( Pos57 - float2( 0.5,0.5 ) , float2x2( cos131 , -sin131 , sin131 , cos131 )) + float2( 0.5,0.5 );
			float mulTime130 = _Time.y * -0.02;
			float simplePerlin2D146 = snoise( (Pos57*5.0 + mulTime130) );
			simplePerlin2D146 = simplePerlin2D146*0.5 + 0.5;
			float4 StarPlacementPattern157 = saturate( ( min( tex2D( _StarMap, (Pos57*5.0 + mulTime134) ).r , tex2D( _StarMap, (rotator131*2.0 + 0.0) ).r ) * simplePerlin2D146 * (float4( 0.2,0,0,0 ) + (SunFlare170 - float4( 0,0,0,0 )) * (float4( 0,1,1,1 ) - float4( 0.2,0,0,0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) ) );
			float2 panner153 = ( 1.0 * _Time.y * float2( 0.0007,0 ) + Pos57);
			float mulTime143 = _Time.y * 0.001;
			float cos141 = cos( 0.01 * _Time.y );
			float sin141 = sin( 0.01 * _Time.y );
			float2 rotator141 = mul( Pos57 - float2( 0.5,0.5 ) , float2x2( cos141 , -sin141 , sin141 , cos141 )) + float2( 0.5,0.5 );
			float4 StarPattern150 = saturate( ( ( ( StarPlacementPattern157 * min( tex2D( CZY_StarMap, (panner153*4.0 + mulTime143) ).r , tex2D( CZY_StarMap, (rotator141*0.1 + 0.0) ).r ) ) * ( 1.0 - MoonFlare167.r ) ) * CZY_StarColor ) );
			o.Emission = ( SimpleSkyGradient163 + SunFlare170 + SunRender90 + MoonFlare167 + StarPattern150 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Sky Mobile;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Front;0;False;;7;False;;False;0;False;;0;False;;True;0;Translucent;0.5;True;True;-100;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;True;221;False;;255;False;;255;False;;7;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;50;-4128,-384;Inherit;False;2040.225;680.2032;;18;179;178;167;166;165;164;74;71;68;67;65;64;63;61;60;59;56;55;Moon Block;0.514151,0.9898598,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-4160,464;Inherit;False;2156.234;658.7953;;16;182;181;180;119;117;115;109;103;102;100;99;97;96;92;91;84;Rainbow Block;1,0.9770144,0.5137255,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-4144,-1216;Inherit;False;2040.225;680.2032;;27;183;174;173;172;171;170;169;168;120;118;111;110;108;107;104;98;94;90;88;86;85;83;78;77;73;72;70;Sun Block;0.514151,0.9898598,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;53;-4112,-2320;Inherit;False;1998.663;845.3734;;22;185;184;175;128;127;126;125;123;122;95;93;89;87;82;79;76;75;69;66;62;58;57;Variable Declaration;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1904,-2304;Inherit;False;2476.533;565.0383;;19;176;162;161;160;159;156;155;154;153;150;149;148;147;144;143;141;140;138;135;Stars;1,0.7345774,0.5254902,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-4080,-288;Inherit;False;65;MoonDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;56;-3712,-272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-3808,-2160;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;58;-2560,-2224;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;59;-3504,16;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;60;-3920,-272;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;61;-3728,112;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;12;0;Create;True;0;0;0;False;0;False;0,0,0;0.3015023,0.9437417,0.1358237;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-2960,-2224;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-3792,0;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;64;-3664,0;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-3344,0;Inherit;False;MoonDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-2752,-2224;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;67;-4048,96;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;68;-3984,-64;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-4016,-2144;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;70;-4016,-928;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;71;-3424,-288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;72;-4080,-784;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;73;-3760,-752;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;12;0;Create;True;0;0;0;False;0;False;0,0,0;0.423889,-0.9055932,0.01480246;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;74;-3584,-272;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-3680,-1824;Inherit;False;170;SunFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;76;-3200,-1824;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;77;-3712,-864;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-3840,-864;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;79;-3472,-1824;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;2,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-512,208;Inherit;False;150;StarPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-512,128;Inherit;False;167;MoonFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2368,-2224;Inherit;False;SimpleGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2512,-816;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;84;-3008,560;Inherit;False;0;8;4;1,0,0,0.1205921;1,0.3135593,0,0.2441138;1,0.8774895,0.2216981,0.3529412;0.3030533,1,0.2877358,0.4529488;0.3726415,1,0.9559749,0.5529412;0.4669811,0.7253776,1,0.6470588;0.1561944,0.3586135,0.735849,0.802945;0.2576377,0.08721964,0.5283019,0.9264668;0,0;0,0.08235294;0.6039216,0.8264744;0,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-4064,-1136;Inherit;False;118;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;86;-3552,-1120;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;87;-2896,-1824;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;88;-3536,-864;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;89;-3040,-1824;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2368,-816;Inherit;False;SunRender;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2432,784;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-3840,944;Inherit;False;118;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2592,-1824;Inherit;False;GradientPos;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;94;-3696,-1120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-2752,-1824;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-3872,832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;97;-3648,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;98;-3888,-1120;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3872,720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-3728,800;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-528,-112;Inherit;False;163;SimpleSkyGradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-3216,800;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;103;-3424,880;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;104;-2720,-784;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-704,-1024;Inherit;False;125;HorizonColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-704,-944;Inherit;False;127;ZenithColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;107;-3408,-1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;108;-3072,-784;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-2256,784;Inherit;False;RainbowClipping;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-2912,-800;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0007;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;111;-2960,-688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;-608,-816;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-496,-32;Inherit;False;170;SunFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;114;-432,-944;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;115;-2768,640;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;116;-496,48;Inherit;False;90;SunRender;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;117;-3424,720;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-3392,-864;Inherit;False;SunDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;119;-2976,688;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-3152,-688;Inherit;False;118;SunDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-288,32;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-3856,-2000;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;123;-4032,-2000;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-800,-816;Inherit;False;93;GradientPos;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-3184,-2224;Inherit;False;HorizonColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;126;-3392,-2224;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-3184,-2048;Inherit;False;ZenithColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;128;-3392,-2048;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;1440,-2064;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;130;1328,-1792;Inherit;False;1;0;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;131;1264,-2064;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;1360,-1888;Inherit;False;57;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;1072,-2192;Inherit;False;57;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;134;1072,-2112;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;136;1376,-2256;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;139;1920,-2176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-688,-1936;Inherit;False;167;MoonFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;141;-1632,-1968;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.01;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;142;1536,-1872;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;143;-1840,-2016;Inherit;False;1;0;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;144;-1456,-1968;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;145;2208,-2080;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;146;1728,-1888;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-224,-2112;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;0,-2096;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;149;128,-2096;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;256,-2096;Inherit;False;StarPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;151;1792,-1744;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0.2,0,0,0;False;4;COLOR;0,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;2080,-2080;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;153;-1648,-2176;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.0007,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1824,-2096;Inherit;False;57;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;155;-1472,-2176;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-928,-2240;Inherit;False;157;StarPlacementPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;2352,-2080;Inherit;False;StarPlacementPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;1600,-1744;Inherit;False;170;SunFlare;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;159;-416,-1936;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;160;-960,-2096;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;161;-528,-1936;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-688,-2144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-288,-944;Inherit;False;SimpleSkyGradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;164;-3328,-176;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-3088,-288;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;166;-2960,-288;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-2832,-288;Half;False;MoonFlare;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;168;-2784,-1120;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-2928,-1120;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-2656,-1120;Half;False;SunFlare;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;171;-3184,-1040;Inherit;False;Filter Color;-1;;4;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;172;-3408,-1040;Inherit;False;Global;CZY_SunFlareColor;CZY_SunFlareColor;5;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.355693,0.4595688,0.4802988,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;173;-3760,-992;Float;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;3;0;Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;174;-2816,-960;Inherit;False;Global;CZY_SunColor;CZY_SunColor;10;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;10.43295,10.43295,10.43295,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;175;-3600,-2224;Inherit;False;Global;CZY_HorizonColor;CZY_HorizonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.6399965,0.9474089,0.9622642,0;0.02745098,0.09176471,0.1215686,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;176;-224,-2016;Inherit;False;Global;CZY_StarColor;CZY_StarColor;13;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;16,16,16,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;178;-3536,-176;Inherit;False;Global;CZY_MoonFlareColor;CZY_MoonFlareColor;6;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.355693,0.4595688,0.4802988,1;0.02352941,0.08627451,0.1490196,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;179;-3808,-144;Half;False;Global;CZY_MoonFlareFalloff;CZY_MoonFlareFalloff;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.752;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-4064,720;Inherit;False;Global;CZY_RainbowSize;CZY_RainbowSize;9;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-4064,816;Inherit;False;Global;CZY_RainbowWidth;CZY_RainbowWidth;8;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-2752,864;Inherit;False;Global;CZY_RainbowIntensity;CZY_RainbowIntensity;14;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-3280,-784;Inherit;False;Global;CZY_SunSize;CZY_SunSize;7;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-3200,-1744;Inherit;False;Global;CZY_Power;CZY_Power;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.574;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;185;-3600,-2048;Inherit;False;Global;CZY_ZenithColor;CZY_ZenithColor;1;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;0.4000979,0.6638572,0.764151,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;135;-1280,-2000;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;138;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;177;1616,-2288;Inherit;True;Property;_StarMap;Star Map;1;0;Create;True;0;0;0;False;0;False;-1;59cb97507f14c1d468e967d73ca67a9b;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;137;1616,-2096;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;0;False;0;False;-1;None;59cb97507f14c1d468e967d73ca67a9b;True;0;False;white;Auto;False;Instance;177;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;138;-1280,-2192;Inherit;True;Global;CZY_StarMap;CZY_StarMap;0;0;Create;True;0;0;0;False;0;False;-1;None;610adfdc91abe6e49a06f9b16aaeed7e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;0;2;121;0
WireConnection;56;0;60;0
WireConnection;57;0;69;0
WireConnection;58;0;66;0
WireConnection;58;1;66;0
WireConnection;59;0;64;0
WireConnection;59;1;61;0
WireConnection;60;0;55;0
WireConnection;63;0;68;0
WireConnection;63;1;67;0
WireConnection;64;0;63;0
WireConnection;65;0;59;0
WireConnection;66;0;62;0
WireConnection;71;0;74;0
WireConnection;74;0;56;0
WireConnection;74;1;179;0
WireConnection;76;0;79;0
WireConnection;77;0;78;0
WireConnection;78;0;70;0
WireConnection;78;1;72;0
WireConnection;79;0;75;0
WireConnection;82;0;58;0
WireConnection;83;0;174;0
WireConnection;83;1;104;0
WireConnection;86;0;94;0
WireConnection;86;1;173;0
WireConnection;87;0;89;0
WireConnection;88;0;77;0
WireConnection;88;1;73;0
WireConnection;89;0;76;0
WireConnection;89;1;184;0
WireConnection;90;0;83;0
WireConnection;91;0;115;0
WireConnection;91;1;102;0
WireConnection;91;2;115;4
WireConnection;91;3;182;0
WireConnection;93;0;95;0
WireConnection;94;0;98;0
WireConnection;95;0;87;0
WireConnection;96;0;181;0
WireConnection;97;0;92;0
WireConnection;98;0;85;0
WireConnection;99;0;180;0
WireConnection;100;0;99;0
WireConnection;100;1;96;0
WireConnection;102;0;117;0
WireConnection;102;1;103;0
WireConnection;103;0;97;0
WireConnection;103;1;100;0
WireConnection;104;0;111;0
WireConnection;104;1;110;0
WireConnection;107;0;86;0
WireConnection;108;0;183;0
WireConnection;109;0;91;0
WireConnection;110;0;108;0
WireConnection;111;0;120;0
WireConnection;112;0;124;0
WireConnection;114;0;105;0
WireConnection;114;1;106;0
WireConnection;114;2;112;0
WireConnection;115;0;84;0
WireConnection;115;1;119;0
WireConnection;117;0;97;0
WireConnection;117;1;99;0
WireConnection;118;0;88;0
WireConnection;119;0;97;0
WireConnection;119;1;99;0
WireConnection;119;2;100;0
WireConnection;121;0;101;0
WireConnection;121;1;113;0
WireConnection;121;2;116;0
WireConnection;121;3;81;0
WireConnection;121;4;80;0
WireConnection;122;0;123;0
WireConnection;125;0;126;0
WireConnection;126;1;175;0
WireConnection;127;0;128;0
WireConnection;128;1;185;0
WireConnection;129;0;131;0
WireConnection;131;0;133;0
WireConnection;131;2;134;0
WireConnection;136;0;133;0
WireConnection;136;2;134;0
WireConnection;139;0;177;1
WireConnection;139;1;137;1
WireConnection;141;0;154;0
WireConnection;142;0;132;0
WireConnection;142;2;130;0
WireConnection;144;0;141;0
WireConnection;145;0;152;0
WireConnection;146;0;142;0
WireConnection;147;0;162;0
WireConnection;147;1;159;0
WireConnection;148;0;147;0
WireConnection;148;1;176;0
WireConnection;149;0;148;0
WireConnection;150;0;149;0
WireConnection;151;0;158;0
WireConnection;152;0;139;0
WireConnection;152;1;146;0
WireConnection;152;2;151;0
WireConnection;153;0;154;0
WireConnection;155;0;153;0
WireConnection;155;2;143;0
WireConnection;157;0;145;0
WireConnection;159;0;161;0
WireConnection;160;0;138;1
WireConnection;160;1;135;1
WireConnection;161;0;140;0
WireConnection;162;0;156;0
WireConnection;162;1;160;0
WireConnection;163;0;114;0
WireConnection;164;1;178;0
WireConnection;165;0;71;0
WireConnection;165;1;164;0
WireConnection;166;0;165;0
WireConnection;167;0;166;0
WireConnection;168;0;169;0
WireConnection;169;0;107;0
WireConnection;169;1;171;0
WireConnection;170;0;168;0
WireConnection;171;1;172;0
WireConnection;135;1;144;0
WireConnection;177;1;136;0
WireConnection;137;1;129;0
WireConnection;138;1;155;0
ASEEND*/
//CHKSM=52A830B88F3E7F02ED70B7E56C33303E123CD65A