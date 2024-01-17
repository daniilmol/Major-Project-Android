// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fog Culling"
{
	Properties
	{
		_Thickness("Thickness", Float) = 500
		_FogVariationTexture("Fog Variation Texture", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+2" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		ZTest Always
		Stencil
		{
			Ref 221
			ReadMask 221
			WriteMask 221
			CompFront Always
			PassFront Replace
			CompBack Always
			PassBack Replace
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
			half ASEIsFrontFacing : VFACE;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 CZY_LightColor;
		uniform float4 CZY_FogColor1;
		uniform float4 CZY_FogColor2;
		uniform float CZY_FogDepthMultiplier;
		uniform float _Thickness;
		uniform sampler2D _FogVariationTexture;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float3 CZY_VariationWindDirection;
		uniform float CZY_VariationScale;
		uniform float CZY_VariationAmount;
		uniform float CZY_VariationDistance;
		uniform float CZY_FogColorStart1;
		uniform float4 CZY_FogColor3;
		uniform float CZY_FogColorStart2;
		uniform float4 CZY_FogColor4;
		uniform float CZY_FogColorStart3;
		uniform float4 CZY_FogColor5;
		uniform float CZY_FogColorStart4;
		uniform float CZY_LightFlareSquish;
		uniform float3 CZY_SunDirection;
		uniform half CZY_LightIntensity;
		uniform half CZY_LightFalloff;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_SunFilterColor;
		uniform float3 CZY_MoonDirection;
		uniform float4 CZY_FogMoonFlareColor;
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

		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g20( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float3 break69 = ( ase_objectScale * float3( 0.5,0.5,0.5 ) );
			float3 objToWorld77 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float isInsideBoundingBox63 = ( ( break69.x > abs( ( _WorldSpaceCameraPos.x - objToWorld77.x ) ) ? 1.0 : 0.0 ) * ( break69.y > abs( ( _WorldSpaceCameraPos.y - objToWorld77.y ) ) ? 1.0 : 0.0 ) * ( break69.z >= abs( ( _WorldSpaceCameraPos.z - objToWorld77.z ) ) ? 1.0 : 0.0 ) );
			float temp_output_67_0 = ( 1.0 - isInsideBoundingBox63 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor12 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			float3 ase_worldPos = i.worldPos;
			float temp_output_32_0 = length( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float preDepth120_g19 = ( temp_output_32_0 - _Thickness );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g21 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g21 = UnStereo( UV22_g21 );
			float2 break64_g20 = localUnStereo22_g21;
			float clampDepth69_g20 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g20 = ( 1.0 - clampDepth69_g20 );
			#else
				float staticSwitch38_g20 = clampDepth69_g20;
			#endif
			float3 appendResult39_g20 = (float3(break64_g20.x , break64_g20.y , staticSwitch38_g20));
			float4 appendResult42_g20 = (float4((appendResult39_g20*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g20 = mul( unity_CameraInvProjection, appendResult42_g20 );
			float3 temp_output_46_0_g20 = ( (temp_output_43_0_g20).xyz / (temp_output_43_0_g20).w );
			float3 In72_g20 = temp_output_46_0_g20;
			float3 localInvertDepthDir72_g20 = InvertDepthDir72_g20( In72_g20 );
			float4 appendResult49_g20 = (float4(localInvertDepthDir72_g20 , 1.0));
			float lerpResult114_g19 = lerp( preDepth120_g19 , ( preDepth120_g19 * (( 1.0 - CZY_VariationAmount ) + (tex2D( _FogVariationTexture, (( (mul( unity_CameraToWorld, appendResult49_g20 )).xz + ( (CZY_VariationWindDirection).xz * _Time.y ) )*( 0.1 / CZY_VariationScale ) + 0.0) ).r - 0.0) * (1.0 - ( 1.0 - CZY_VariationAmount )) / (1.0 - 0.0)) ) , ( 1.0 - saturate( ( preDepth120_g19 / CZY_VariationDistance ) ) ));
			float newFogDepth103_g19 = lerpResult114_g19;
			float temp_output_15_0_g19 = ( CZY_FogDepthMultiplier * sqrt( newFogDepth103_g19 ) );
			float temp_output_1_0_g24 = temp_output_15_0_g19;
			float4 lerpResult28_g24 = lerp( CZY_FogColor1 , CZY_FogColor2 , saturate( ( temp_output_1_0_g24 / CZY_FogColorStart1 ) ));
			float4 lerpResult41_g24 = lerp( saturate( lerpResult28_g24 ) , CZY_FogColor3 , saturate( ( ( CZY_FogColorStart1 - temp_output_1_0_g24 ) / ( CZY_FogColorStart1 - CZY_FogColorStart2 ) ) ));
			float4 lerpResult35_g24 = lerp( lerpResult41_g24 , CZY_FogColor4 , saturate( ( ( CZY_FogColorStart2 - temp_output_1_0_g24 ) / ( CZY_FogColorStart2 - CZY_FogColorStart3 ) ) ));
			float4 lerpResult113_g24 = lerp( lerpResult35_g24 , CZY_FogColor5 , saturate( ( ( CZY_FogColorStart3 - temp_output_1_0_g24 ) / ( CZY_FogColorStart3 - CZY_FogColorStart4 ) ) ));
			float4 temp_output_142_0_g19 = lerpResult113_g24;
			float3 hsvTorgb32_g19 = RGBToHSV( temp_output_142_0_g19.rgb );
			float3 temp_output_91_0_g19 = ase_worldPos;
			float3 appendResult73_g19 = (float3(1.0 , CZY_LightFlareSquish , 1.0));
			float3 normalizeResult5_g19 = normalize( ( ( temp_output_91_0_g19 * appendResult73_g19 ) - _WorldSpaceCameraPos ) );
			float dotResult6_g19 = dot( normalizeResult5_g19 , CZY_SunDirection );
			half LightMask27_g19 = saturate( pow( abs( ( (dotResult6_g19*0.5 + 0.5) * CZY_LightIntensity ) ) , CZY_LightFalloff ) );
			float temp_output_26_0_g19 = ( (temp_output_142_0_g19).a * saturate( temp_output_15_0_g19 ) );
			float3 hsvTorgb2_g23 = RGBToHSV( ( CZY_LightColor * hsvTorgb32_g19.z * saturate( ( LightMask27_g19 * ( 1.5 * temp_output_26_0_g19 ) ) ) ).rgb );
			float3 hsvTorgb3_g23 = HSVToRGB( float3(hsvTorgb2_g23.x,saturate( ( hsvTorgb2_g23.y + CZY_FilterSaturation ) ),( hsvTorgb2_g23.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g23 = ( float4( hsvTorgb3_g23 , 0.0 ) * CZY_FilterColor );
			float3 direction90_g19 = ( temp_output_91_0_g19 - _WorldSpaceCameraPos );
			float3 normalizeResult93_g19 = normalize( direction90_g19 );
			float3 normalizeResult88_g19 = normalize( CZY_MoonDirection );
			float dotResult49_g19 = dot( normalizeResult93_g19 , normalizeResult88_g19 );
			half MoonMask47_g19 = saturate( pow( abs( ( saturate( (dotResult49_g19*1.0 + 0.0) ) * CZY_LightIntensity ) ) , ( CZY_LightFalloff * 3.0 ) ) );
			float3 hsvTorgb2_g22 = RGBToHSV( ( temp_output_142_0_g19 + ( hsvTorgb32_g19.z * saturate( ( temp_output_26_0_g19 * MoonMask47_g19 ) ) * CZY_FogMoonFlareColor ) ).rgb );
			float3 hsvTorgb3_g22 = HSVToRGB( float3(hsvTorgb2_g22.x,saturate( ( hsvTorgb2_g22.y + CZY_FilterSaturation ) ),( hsvTorgb2_g22.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g22 = ( float4( hsvTorgb3_g22 , 0.0 ) * CZY_FilterColor );
			float finalAlpha141_g19 = temp_output_26_0_g19;
			float4 lerpResult71 = lerp( screenColor12 , ( ( temp_output_10_0_g23 * CZY_SunFilterColor ) + temp_output_10_0_g22 ) , ( finalAlpha141_g19 * saturate( ( ( 1.0 - saturate( ( ( ( direction90_g19.y * 0.1 ) * ( 1.0 / ( ( CZY_FogSmoothness * length( ase_objectScale ) ) * 10.0 ) ) ) + ( 1.0 - CZY_FogOffset ) ) ) ) * CZY_FogIntensity ) ) ));
			o.Emission = ( temp_output_67_0 == 1.0 ? lerpResult71 : screenColor12 ).rgb;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 In72_g1 = temp_output_46_0_g1;
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 appendResult27 = (float3(mul( unity_CameraToWorld, appendResult49_g1 ).xyz));
			float temp_output_30_0 = length( ( appendResult27 - _WorldSpaceCameraPos ) );
			float switchResult33 = (((i.ASEIsFrontFacing>0)?(( ( temp_output_30_0 > temp_output_32_0 ? 1.0 : 0.0 ) * temp_output_67_0 )):(( isInsideBoundingBox63 * ( temp_output_30_0 < temp_output_32_0 ? 1.0 : 0.0 ) ))));
			o.Alpha = switchResult33;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.SaturateNode;44;-128,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;16,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;45;224,176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;42;-256,352;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;49;-448,-912;Inherit;False;2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;55;-448,-768;Inherit;False;2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;61;-448,-624;Inherit;False;3;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-192,-816;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-64,-816;Inherit;False;isInsideBoundingBox;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-1152,16;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;24;-1488,16;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-976,48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-976,176;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-1184,240;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;30;-832,48;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;32;-832,176;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;34;-592,192;Inherit;False;4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;25;-1248,96;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Compare;22;-592,48;Inherit;False;2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-304,48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-192,192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-736,-48;Inherit;False;63;isInsideBoundingBox;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;67;-496,-48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-672,-960;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-800,-960;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;71;-336,-400;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;33;-48,112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;72;-176,-224;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;12;-736,-336;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;75;-736,-448;Inherit;False;Stylized Fog ASE Function;2;;19;649d2917c22fd754aa7be82b00ec0d80;0;2;151;FLOAT;0;False;91;FLOAT3;0,0,0;False;2;COLOR;0;FLOAT;56
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-896,-304;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1135.596,-305.3645;Inherit;False;Property;_Thickness;Thickness;1;0;Create;True;0;0;0;False;0;False;500;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;48;-1296,-800;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;77;-1255,-655;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-944,-800;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;54;-736,-800;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;83;-736,-704;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-944,-704;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;84;-736,-608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-944,-608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;51;-992,-976;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;86;546,-248;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fog Culling;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;7;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;2;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;True;221;False;;221;False;;221;False;;7;False;;3;False;;0;False;;0;False;;7;False;;3;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;0;42;0
WireConnection;43;0;44;0
WireConnection;45;0;33;0
WireConnection;45;1;43;0
WireConnection;42;0;32;0
WireConnection;42;1;46;0
WireConnection;49;0;69;0
WireConnection;49;1;54;0
WireConnection;55;0;69;1
WireConnection;55;1;83;0
WireConnection;61;0;69;2
WireConnection;61;1;84;0
WireConnection;62;0;49;0
WireConnection;62;1;55;0
WireConnection;62;2;61;0
WireConnection;63;0;62;0
WireConnection;27;0;24;0
WireConnection;26;0;27;0
WireConnection;26;1;25;0
WireConnection;28;0;29;0
WireConnection;28;1;25;0
WireConnection;30;0;26;0
WireConnection;32;0;28;0
WireConnection;34;0;30;0
WireConnection;34;1;32;0
WireConnection;22;0;30;0
WireConnection;22;1;32;0
WireConnection;65;0;22;0
WireConnection;65;1;67;0
WireConnection;66;0;64;0
WireConnection;66;1;34;0
WireConnection;67;0;64;0
WireConnection;69;0;68;0
WireConnection;68;0;51;0
WireConnection;71;0;12;0
WireConnection;71;1;75;0
WireConnection;71;2;75;56
WireConnection;33;0;65;0
WireConnection;33;1;66;0
WireConnection;72;0;67;0
WireConnection;72;2;71;0
WireConnection;72;3;12;0
WireConnection;75;151;76;0
WireConnection;76;0;32;0
WireConnection;76;1;46;0
WireConnection;81;0;48;1
WireConnection;81;1;77;1
WireConnection;54;0;81;0
WireConnection;83;0;82;0
WireConnection;82;0;48;2
WireConnection;82;1;77;2
WireConnection;84;0;85;0
WireConnection;85;0;48;3
WireConnection;85;1;77;3
WireConnection;86;2;72;0
WireConnection;86;9;33;0
ASEEND*/
//CHKSM=92C9E2AE285DB0238B42E0A9220000A22F7A312A