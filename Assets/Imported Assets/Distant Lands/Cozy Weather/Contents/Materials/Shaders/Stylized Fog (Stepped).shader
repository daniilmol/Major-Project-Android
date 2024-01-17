// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stepped Fog"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		ZTest Always
		Stencil
		{
			Ref 222
			Comp NotEqual
			Pass Replace
		}
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float CZY_FogDepthMultiplier;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float CZY_FogColorStart4;
		uniform float4 CZY_FogColor5;
		uniform float CZY_FogColorStart3;
		uniform float4 CZY_FogColor4;
		uniform float CZY_FogColorStart2;
		uniform float4 CZY_FogColor3;
		uniform float CZY_FogColorStart1;
		uniform float4 CZY_FogColor2;
		uniform float4 CZY_FogColor1;
		uniform float4 CZY_LightColor;
		uniform float CZY_FlareSquish;
		uniform float3 CZy_SunDirection;
		uniform half CZY_LightIntensity;
		uniform half CZY_LightFalloff;
		uniform float CZY_FogSmoothness;
		uniform float CZY_FogOffset;
		uniform float CZY_FogIntensity;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g5( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor386 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			float2 appendResult349 = (float2(_WorldSpaceCameraPos.x , _WorldSpaceCameraPos.z));
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g6 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g6 = UnStereo( UV22_g6 );
			float2 break64_g5 = localUnStereo22_g6;
			float clampDepth69_g5 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g5 = ( 1.0 - clampDepth69_g5 );
			#else
				float staticSwitch38_g5 = clampDepth69_g5;
			#endif
			float3 appendResult39_g5 = (float3(break64_g5.x , break64_g5.y , staticSwitch38_g5));
			float4 appendResult42_g5 = (float4((appendResult39_g5*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g5 = mul( unity_CameraInvProjection, appendResult42_g5 );
			float3 temp_output_46_0_g5 = ( (temp_output_43_0_g5).xyz / (temp_output_43_0_g5).w );
			float3 In72_g5 = temp_output_46_0_g5;
			float3 localInvertDepthDir72_g5 = InvertDepthDir72_g5( In72_g5 );
			float4 appendResult49_g5 = (float4(localInvertDepthDir72_g5 , 1.0));
			float4 break347 = mul( unity_CameraToWorld, appendResult49_g5 );
			float2 appendResult348 = (float2(break347.x , break347.z));
			float Distance353 = ( CZY_FogDepthMultiplier * sqrt( distance( appendResult349 , appendResult348 ) ) );
			float4 break370 = ( Distance353 > CZY_FogColorStart4 ? CZY_FogColor5 : ( Distance353 > CZY_FogColorStart3 ? CZY_FogColor4 : ( Distance353 > CZY_FogColorStart2 ? CZY_FogColor3 : ( Distance353 > CZY_FogColorStart1 ? CZY_FogColor2 : CZY_FogColor1 ) ) ) );
			float temp_output_1_0_g7 = Distance353;
			float4 appendResult366 = (float4(CZY_FogColorStart1 , CZY_FogColorStart2 , CZY_FogColorStart3 , CZY_FogColorStart4));
			float4 break116_g7 = appendResult366;
			float lerpResult28_g7 = lerp( CZY_FogColor1.a , CZY_FogColor2.a , saturate( ( temp_output_1_0_g7 / break116_g7.x ) ));
			float lerpResult41_g7 = lerp( saturate( lerpResult28_g7 ) , CZY_FogColor3.a , saturate( ( ( break116_g7.x - temp_output_1_0_g7 ) / ( 0.0 - break116_g7.y ) ) ));
			float lerpResult35_g7 = lerp( lerpResult41_g7 , CZY_FogColor4.a , saturate( ( ( break116_g7.y - temp_output_1_0_g7 ) / ( break116_g7.y - break116_g7.z ) ) ));
			float lerpResult113_g7 = lerp( lerpResult35_g7 , CZY_FogColor5.a , saturate( ( ( break116_g7.z - temp_output_1_0_g7 ) / ( break116_g7.z - break116_g7.w ) ) ));
			float4 appendResult371 = (float4(break370.r , break370.g , break370.b , lerpResult113_g7));
			float4 FogColors372 = appendResult371;
			float3 hsvTorgb379 = RGBToHSV( CZY_LightColor.rgb );
			float3 hsvTorgb378 = RGBToHSV( FogColors372.xyz );
			float3 hsvTorgb384 = HSVToRGB( float3(hsvTorgb379.x,hsvTorgb379.y,( hsvTorgb379.z * hsvTorgb378.z )) );
			float3 ase_worldPos = i.worldPos;
			float3 appendResult399 = (float3(1.0 , CZY_FlareSquish , 1.0));
			float3 normalizeResult404 = normalize( ( ( ase_worldPos * appendResult399 ) - _WorldSpaceCameraPos ) );
			float dotResult405 = dot( normalizeResult404 , CZy_SunDirection );
			half LightMask411 = saturate( pow( abs( ( (dotResult405*0.5 + 0.5) * CZY_LightIntensity ) ) , CZY_LightFalloff ) );
			float temp_output_376_0 = ( FogColors372.w * saturate( Distance353 ) );
			float4 lerpResult385 = lerp( FogColors372 , float4( hsvTorgb384 , 0.0 ) , saturate( ( LightMask411 * ( 1.5 * temp_output_376_0 ) ) ));
			float4 lerpResult387 = lerp( screenColor386 , lerpResult385 , temp_output_376_0);
			o.Emission = lerpResult387.xyz;
			float3 direction431 = ( ase_worldPos - _WorldSpaceCameraPos );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			o.Alpha = ( FogColors372.w * saturate( ( ( 1.0 - saturate( ( ( ( direction431.y * 0.1 ) * ( 1.0 / ( ( CZY_FogSmoothness * length( ase_objectScale ) ) * 10.0 ) ) ) + ( 1.0 - CZY_FogOffset ) ) ) ) * CZY_FogIntensity ) ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 

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
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
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
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stepped Fog;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Front;0;False;;7;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;1;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;True;222;False;;255;False;;255;False;;6;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.FunctionNode;345;-3344,176;Inherit;False;Reconstruct World Position From Depth;-1;;5;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;346;-3120,-16;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;347;-3024,176;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;348;-2848,176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;349;-2848,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;350;-2704,112;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;351;-2400,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-2256,-80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;353;-2128,-80;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-1440,-1072;Inherit;False;353;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;355;-976,-976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;356;-1136,-944;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;357;-880,-944;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;358;-656,-960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;359;-448,-976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;360;-576,-944;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;361;-528,-544;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;362;-1152,-560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;363;-640,-544;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;364;-752,-528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;365;-496,-480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;366;-224,-672;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Compare;367;-336,-944;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;368;-192,-448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;369;-48,-592;Inherit;False;Simple Alpha Gradient;-1;;7;56cd1a9a3eb3fb94db3fd3227a7bec18;0;7;115;FLOAT4;0,0,0,0;False;117;FLOAT;0;False;118;FLOAT;0;False;119;FLOAT;0;False;120;FLOAT;0;False;121;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;370;48,-928;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;371;256,-928;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;372;384,-928;Inherit;False;FogColors;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-1632,288;Inherit;False;353;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;374;-1424,80;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;375;-1456,304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;-1280,240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;-1152,160;Inherit;False;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;378;-1456,-256;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;379;-1472,-464;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;380;-1264,-16;Inherit;False;411;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;-1040,64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;382;-1232,-304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;383;-880,32;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;384;-1072,-384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;385;-784,-192;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;386;-576,-304;Inherit;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;387;-336,-128;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;388;-576,-720;Inherit;False;Global;CZY_FogColor5;CZY_FogColor5;4;1;[HDR];Create;False;0;0;0;False;0;False;0.164721,0,1,1;0.3727097,0.6769533,0.8678513,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;389;-864,-720;Inherit;False;Global;CZY_FogColor4;CZY_FogColor4;3;1;[HDR];Create;False;0;0;0;False;0;False;0,0.8501792,1,1;0.01237765,0.2645998,0.5078521,0.7568628;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;390;-1136,-720;Inherit;False;Global;CZY_FogColor3;CZY_FogColor3;2;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0.7469492,1;0.07289401,0.3011266,0.4882576,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;391;-1440,-736;Inherit;False;Global;CZY_FogColor1;CZY_FogColor1;0;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0.8999224,1;0,0,0,0.007843138;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;392;-1440,-912;Inherit;False;Global;CZY_FogColor2;CZY_FogColor2;1;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0,1;0.03087696,0.2418273,0.3851145,0.1372549;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;393;-1440,-992;Inherit;False;Global;CZY_FogColorStart1;CZY_FogColorStart1;5;0;Create;False;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-1136,-800;Inherit;False;Global;CZY_FogColorStart2;CZY_FogColorStart2;6;0;Create;False;0;0;0;False;0;False;2;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;395;-880,-800;Inherit;False;Global;CZY_FogColorStart3;CZY_FogColorStart3;7;0;Create;False;0;0;0;False;0;False;3;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;-576,-800;Inherit;False;Global;CZY_FogColorStart4;CZY_FogColorStart4;8;0;Create;False;0;0;0;False;0;False;4;31.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;397;-1824,-560;Inherit;False;Global;CZY_LightColor;CZY_LightColor;15;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;1.083397,1.392001,1.382235,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;398;-2576,-80;Inherit;False;Global;CZY_FogDepthMultiplier;CZY_FogDepthMultiplier;12;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;399;-2112,1904;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;400;-2176,1680;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-1856,1824;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;402;-1968,1984;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;403;-1616,1904;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;404;-1424,1904;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;405;-1104,1904;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;406;-896,1888;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;407;-592,1904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;408;-400,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;409;-240,1904;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;410;-96,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;411;64,1904;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;412;-256,2176;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;413;-96,2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;414;-400,2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;-576,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;48,2176;Half;False;MoonMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;417;-1104,2240;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;418;-912,2192;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2400,1904;Inherit;False;Global;CZY_FlareSquish;CZY_FlareSquish;11;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;420;-1440,2016;Inherit;False;Global;CZy_SunDirection;CZy_SunDirection;9;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;421;-1424,2192;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;10;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;0.4169701,-0.9045281,-0.08924681;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;422;-816,2064;Half;False;Global;CZY_LightIntensity;CZY_LightIntensity;14;0;Create;False;0;0;0;False;0;False;0;0.9968594;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;423;-480,2048;Half;False;Global;CZY_LightFalloff;CZY_LightFalloff;13;0;Create;False;0;0;0;False;0;False;1;24.67793;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;424;-912,512;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;425;-704,512;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;426;-1344,512;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;427;-1520,672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;428;-1088,512;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;-1872,448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;430;-2368,432;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;-2224,432;Inherit;False;direction;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;432;-416,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;433;-1728,576;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;-2032,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;435;-2272,656;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;436;-2480,672;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;437;-1888,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-1600,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;440;-2032,432;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WorldPosInputsNode;441;-2672,336;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;442;-2672,480;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;443;-2272,576;Inherit;False;Global;CZY_FogSmoothness;CZY_FogSmoothness;20;0;Create;False;0;0;0;False;0;False;0.1;0.625;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;-912,800;Inherit;False;Global;CZY_FogIntensity;CZY_FogIntensity;21;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;445;-1760,720;Inherit;False;Global;CZY_FogOffset;CZY_FogOffset;22;0;Create;False;0;0;0;False;0;False;1;1.031;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;446;-1824,-80;Inherit;False;372;FogColors;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-170.0959,328.1393;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;0;2;387;0
WireConnection;0;9;438;0
WireConnection;347;0;345;0
WireConnection;348;0;347;0
WireConnection;348;1;347;2
WireConnection;349;0;346;1
WireConnection;349;1;346;3
WireConnection;350;0;349;0
WireConnection;350;1;348;0
WireConnection;351;0;350;0
WireConnection;352;0;398;0
WireConnection;352;1;351;0
WireConnection;353;0;352;0
WireConnection;355;0;354;0
WireConnection;356;0;354;0
WireConnection;356;1;393;0
WireConnection;356;2;392;0
WireConnection;356;3;391;0
WireConnection;357;0;355;0
WireConnection;357;1;394;0
WireConnection;357;2;390;0
WireConnection;357;3;356;0
WireConnection;358;0;354;0
WireConnection;359;0;354;0
WireConnection;360;0;358;0
WireConnection;360;1;395;0
WireConnection;360;2;389;0
WireConnection;360;3;357;0
WireConnection;361;0;391;4
WireConnection;362;0;354;0
WireConnection;363;0;392;4
WireConnection;364;0;390;4
WireConnection;365;0;389;4
WireConnection;366;0;393;0
WireConnection;366;1;394;0
WireConnection;366;2;395;0
WireConnection;366;3;396;0
WireConnection;367;0;359;0
WireConnection;367;1;396;0
WireConnection;367;2;388;0
WireConnection;367;3;360;0
WireConnection;368;0;388;4
WireConnection;369;115;366;0
WireConnection;369;117;361;0
WireConnection;369;118;363;0
WireConnection;369;119;364;0
WireConnection;369;120;365;0
WireConnection;369;121;368;0
WireConnection;369;1;362;0
WireConnection;370;0;367;0
WireConnection;371;0;370;0
WireConnection;371;1;370;1
WireConnection;371;2;370;2
WireConnection;371;3;369;0
WireConnection;372;0;371;0
WireConnection;374;0;446;0
WireConnection;375;0;373;0
WireConnection;376;0;374;3
WireConnection;376;1;375;0
WireConnection;377;1;376;0
WireConnection;378;0;446;0
WireConnection;379;0;397;0
WireConnection;381;0;380;0
WireConnection;381;1;377;0
WireConnection;382;0;379;3
WireConnection;382;1;378;3
WireConnection;383;0;381;0
WireConnection;384;0;379;1
WireConnection;384;1;379;2
WireConnection;384;2;382;0
WireConnection;385;0;446;0
WireConnection;385;1;384;0
WireConnection;385;2;383;0
WireConnection;387;0;386;0
WireConnection;387;1;385;0
WireConnection;387;2;376;0
WireConnection;399;1;419;0
WireConnection;401;0;400;0
WireConnection;401;1;399;0
WireConnection;403;0;401;0
WireConnection;403;1;402;0
WireConnection;404;0;403;0
WireConnection;405;0;404;0
WireConnection;405;1;420;0
WireConnection;406;0;405;0
WireConnection;407;0;406;0
WireConnection;407;1;422;0
WireConnection;408;0;407;0
WireConnection;409;0;408;0
WireConnection;409;1;423;0
WireConnection;410;0;409;0
WireConnection;411;0;410;0
WireConnection;412;0;414;0
WireConnection;412;1;423;0
WireConnection;413;0;412;0
WireConnection;414;0;415;0
WireConnection;415;0;418;0
WireConnection;415;1;422;0
WireConnection;416;0;413;0
WireConnection;417;0;404;0
WireConnection;417;1;421;0
WireConnection;418;0;417;0
WireConnection;424;0;428;0
WireConnection;425;0;424;0
WireConnection;425;1;444;0
WireConnection;426;0;439;0
WireConnection;426;1;427;0
WireConnection;427;0;445;0
WireConnection;428;0;426;0
WireConnection;429;0;440;1
WireConnection;430;0;441;0
WireConnection;430;1;442;0
WireConnection;431;0;430;0
WireConnection;432;0;425;0
WireConnection;433;1;437;0
WireConnection;434;0;443;0
WireConnection;434;1;435;0
WireConnection;435;0;436;0
WireConnection;437;0;434;0
WireConnection;439;0;429;0
WireConnection;439;1;433;0
WireConnection;440;0;431;0
WireConnection;438;0;374;3
WireConnection;438;1;432;0
ASEEND*/
//CHKSM=B8A1B94B799A577A372EE443DEF5D0B952857B1C