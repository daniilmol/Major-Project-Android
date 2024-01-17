// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Stylized Clouds (Static Texture)"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Front
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D CZY_CloudTexture;
		uniform float3 CZY_TexturePanDirection;
		uniform float CZY_WindSpeed;
		uniform float4 CZY_CloudColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_CloudFilterColor;
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

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 break49 = CZY_TexturePanDirection;
			float mulTime52 = _Time.y * ( CZY_WindSpeed * 0.005 );
			float TIme50 = mulTime52;
			float2 appendResult45 = (float2(( break49.x * 0.0025 * TIme50 ) , ( TIme50 * 0.0025 * break49.z )));
			float2 uv_TexCoord44 = i.uv_texcoord + appendResult45;
			float cos51 = cos( ( TIme50 * break49.y ) );
			float sin51 = sin( ( TIme50 * break49.y ) );
			float2 rotator51 = mul( uv_TexCoord44 - float2( 0.5,0.5 ) , float2x2( cos51 , -sin51 , sin51 , cos51 )) + float2( 0.5,0.5 );
			float4 tex2DNode59 = tex2D( CZY_CloudTexture, rotator51 );
			float4 CloudTex40 = tex2DNode59;
			float3 hsvTorgb2_g1 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor53 = ( temp_output_10_0_g1 * CZY_CloudFilterColor );
			float CloudAlpha37 = ( tex2DNode59.r * tex2DNode59.g * tex2DNode59.b * tex2DNode59.a );
			clip( CloudAlpha37 - CZY_ClippingThreshold);
			o.Emission = ( CloudTex40 * CloudColor53 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Stylized Clouds (Static Texture);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-640,48;Inherit;False;53;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1104,96;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-912,96;Inherit;True;CloudAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-432,64;Inherit;False;37;CloudAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-640,-32;Inherit;False;40;CloudTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1104,16;Inherit;False;CloudTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-432,-32;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-2128,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2368,-80;Inherit;False;50;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-1824,16;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;45;-1984,16;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1648,-96;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2128,-96;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.0025;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2128,128;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.0025;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;49;-2304,16;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1360,-96;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;51;-1584,16;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;52;-1520,-96;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1392,-288;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;54;-1600,-288;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-512,144;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;2;2;[HideInInspector];[PerRendererData];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;56;-2560,16;Inherit;False;Global;CZY_TexturePanDirection;CZY_TexturePanDirection;3;1;[PerRendererData];Create;False;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;57;-1824,-288;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;4;[HideInInspector];[HDR];[PerRendererData];[Header];Create;False;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;1.01994,0.8557577,0.7989255,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1824,-96;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;1;2;[HideInInspector];[PerRendererData];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-1392,16;Inherit;True;Global;CZY_CloudTexture;CZY_CloudTexture;0;0;Create;False;0;0;0;False;0;False;-1;404f80e8b03e57a48baef75373097c56;27248a215d4e5fe449733cb0631f0785;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClipNode;60;-224,32;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
WireConnection;0;2;60;0
WireConnection;36;0;59;1
WireConnection;36;1;59;2
WireConnection;36;2;59;3
WireConnection;36;3;59;4
WireConnection;37;0;36;0
WireConnection;40;0;59;0
WireConnection;41;0;39;0
WireConnection;41;1;35;0
WireConnection;42;0;43;0
WireConnection;42;1;49;1
WireConnection;44;1;45;0
WireConnection;45;0;47;0
WireConnection;45;1;48;0
WireConnection;46;0;58;0
WireConnection;47;0;49;0
WireConnection;47;2;43;0
WireConnection;48;0;43;0
WireConnection;48;2;49;2
WireConnection;49;0;56;0
WireConnection;50;0;52;0
WireConnection;51;0;44;0
WireConnection;51;2;42;0
WireConnection;52;0;46;0
WireConnection;53;0;54;0
WireConnection;54;1;57;0
WireConnection;59;1;51;0
WireConnection;60;0;41;0
WireConnection;60;1;38;0
WireConnection;60;2;55;0
ASEEND*/
//CHKSM=B5B0A32CB9D24C4207B8AA385FD46E5F687C9632