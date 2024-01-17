// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Fog (Physical Height)"
{
	Properties
	{
		[HDR]_FogColor1("Fog Color 1", Color) = (1,0,0.8999224,1)
		[HDR]_FogColor2("Fog Color 2", Color) = (1,0,0,1)
		[HDR]_FogColor3("Fog Color 3", Color) = (1,0,0.7469492,1)
		[HDR]_FogColor4("Fog Color 4", Color) = (0,0.8501792,1,1)
		[HDR]_FogColor5("Fog Color 5", Color) = (0.164721,0,1,1)
		_FogColorStart1("FogColorStart1", Float) = 1
		_FogColorStart2("FogColorStart2", Float) = 2
		_FogColorStart3("FogColorStart3", Float) = 3
		_FogColorStart4("FogColorStart4", Float) = 4
		_FogVariationTexture("Fog Variation Texture", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "HeightFog"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		ZWrite Off
		ZTest Always
		Stencil
		{
			Ref 222
			Comp NotEqual
			Pass Replace
		}
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
		};

		uniform float4 CZY_LightColor;
		uniform float4 _FogColor1;
		uniform float4 _FogColor2;
		uniform float CZY_FogDepthMultiplier;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform sampler2D _FogVariationTexture;
		uniform float3 CZY_VariationWindDirection;
		uniform float CZY_VariationScale;
		uniform float CZY_VariationAmount;
		uniform float CZY_VariationDistance;
		uniform float _FogColorStart1;
		uniform float4 _FogColor3;
		uniform float _FogColorStart2;
		uniform float4 _FogColor4;
		uniform float _FogColorStart3;
		uniform float4 _FogColor5;
		uniform float _FogColorStart4;
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


		float3 InvertDepthDir72_g14( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		float3 InvertDepthDir72_g11( float3 In )
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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth385 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float preDepth393 = eyeDepth385;
			float2 UV22_g15 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g15 = UnStereo( UV22_g15 );
			float2 break64_g14 = localUnStereo22_g15;
			float clampDepth69_g14 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g14 = ( 1.0 - clampDepth69_g14 );
			#else
				float staticSwitch38_g14 = clampDepth69_g14;
			#endif
			float3 appendResult39_g14 = (float3(break64_g14.x , break64_g14.y , staticSwitch38_g14));
			float4 appendResult42_g14 = (float4((appendResult39_g14*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g14 = mul( unity_CameraInvProjection, appendResult42_g14 );
			float3 temp_output_46_0_g14 = ( (temp_output_43_0_g14).xyz / (temp_output_43_0_g14).w );
			float3 In72_g14 = temp_output_46_0_g14;
			float3 localInvertDepthDir72_g14 = InvertDepthDir72_g14( In72_g14 );
			float4 appendResult49_g14 = (float4(localInvertDepthDir72_g14 , 1.0));
			float lerpResult349 = lerp( preDepth393 , ( preDepth393 * (( 1.0 - CZY_VariationAmount ) + (tex2D( _FogVariationTexture, (( (mul( unity_CameraToWorld, appendResult49_g14 )).xz + ( (CZY_VariationWindDirection).xz * _Time.y ) )*( 0.1 / CZY_VariationScale ) + 0.0) ).r - 0.0) * (1.0 - ( 1.0 - CZY_VariationAmount )) / (1.0 - 0.0)) ) , ( 1.0 - saturate( ( preDepth393 / CZY_VariationDistance ) ) ));
			float newFogDepth366 = lerpResult349;
			float temp_output_370_0 = ( CZY_FogDepthMultiplier * sqrt( newFogDepth366 ) );
			float temp_output_1_0_g21 = temp_output_370_0;
			float4 lerpResult28_g21 = lerp( _FogColor1 , _FogColor2 , saturate( ( temp_output_1_0_g21 / _FogColorStart1 ) ));
			float4 lerpResult41_g21 = lerp( saturate( lerpResult28_g21 ) , _FogColor3 , saturate( ( ( _FogColorStart1 - temp_output_1_0_g21 ) / ( _FogColorStart1 - _FogColorStart2 ) ) ));
			float4 lerpResult35_g21 = lerp( lerpResult41_g21 , _FogColor4 , saturate( ( ( _FogColorStart2 - temp_output_1_0_g21 ) / ( _FogColorStart2 - _FogColorStart3 ) ) ));
			float4 lerpResult113_g21 = lerp( lerpResult35_g21 , _FogColor5 , saturate( ( ( _FogColorStart3 - temp_output_1_0_g21 ) / ( _FogColorStart3 - _FogColorStart4 ) ) ));
			float4 temp_output_397_0 = lerpResult113_g21;
			float3 hsvTorgb379 = RGBToHSV( temp_output_397_0.rgb );
			float3 ase_worldPos = i.worldPos;
			float3 appendResult414 = (float3(1.0 , CZY_LightFlareSquish , 1.0));
			float3 normalizeResult405 = normalize( ( ( ase_worldPos * appendResult414 ) - _WorldSpaceCameraPos ) );
			float dotResult407 = dot( normalizeResult405 , CZY_SunDirection );
			half LightMask421 = saturate( pow( abs( ( (dotResult407*0.5 + 0.5) * CZY_LightIntensity ) ) , CZY_LightFalloff ) );
			float temp_output_375_0 = ( (temp_output_397_0).a * saturate( temp_output_370_0 ) );
			float3 hsvTorgb2_g19 = RGBToHSV( ( CZY_LightColor * hsvTorgb379.z * saturate( ( LightMask421 * ( 1.5 * temp_output_375_0 ) ) ) ).rgb );
			float3 hsvTorgb3_g19 = HSVToRGB( float3(hsvTorgb2_g19.x,saturate( ( hsvTorgb2_g19.y + CZY_FilterSaturation ) ),( hsvTorgb2_g19.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g19 = ( float4( hsvTorgb3_g19 , 0.0 ) * CZY_FilterColor );
			float3 normalizeResult420 = normalize( half3(0,0,0) );
			float3 normalizeResult419 = normalize( CZY_MoonDirection );
			float dotResult417 = dot( normalizeResult420 , normalizeResult419 );
			half MoonMask430 = saturate( pow( abs( ( saturate( (dotResult417*1.0 + 0.0) ) * CZY_LightIntensity ) ) , ( CZY_LightFalloff * 3.0 ) ) );
			float3 hsvTorgb2_g18 = RGBToHSV( ( temp_output_397_0 + ( hsvTorgb379.z * saturate( ( temp_output_375_0 * MoonMask430 ) ) * CZY_FogMoonFlareColor ) ).rgb );
			float3 hsvTorgb3_g18 = HSVToRGB( float3(hsvTorgb2_g18.x,saturate( ( hsvTorgb2_g18.y + CZY_FilterSaturation ) ),( hsvTorgb2_g18.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g18 = ( float4( hsvTorgb3_g18 , 0.0 ) * CZY_FilterColor );
			o.Emission = ( ( temp_output_10_0_g19 * CZY_SunFilterColor ) + temp_output_10_0_g18 ).rgb;
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float finalAlpha386 = temp_output_375_0;
			float2 UV22_g12 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g12 = UnStereo( UV22_g12 );
			float2 break64_g11 = localUnStereo22_g12;
			float clampDepth69_g11 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g11 = ( 1.0 - clampDepth69_g11 );
			#else
				float staticSwitch38_g11 = clampDepth69_g11;
			#endif
			float3 appendResult39_g11 = (float3(break64_g11.x , break64_g11.y , staticSwitch38_g11));
			float4 appendResult42_g11 = (float4((appendResult39_g11*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g11 = mul( unity_CameraInvProjection, appendResult42_g11 );
			float3 temp_output_46_0_g11 = ( (temp_output_43_0_g11).xyz / (temp_output_43_0_g11).w );
			float3 In72_g11 = temp_output_46_0_g11;
			float3 localInvertDepthDir72_g11 = InvertDepthDir72_g11( In72_g11 );
			float4 appendResult49_g11 = (float4(localInvertDepthDir72_g11 , 1.0));
			float4 temp_output_321_0 = mul( unity_CameraToWorld, appendResult49_g11 );
			float lerpResult344 = lerp( finalAlpha386 , ( saturate( ( 1.0 - ( temp_output_321_0.y * 0.001 ) ) ) * finalAlpha386 ) , ( 1.0 - saturate( ( distance( temp_output_321_0 , float4( _WorldSpaceCameraPos , 0.0 ) ) / ( _ProjectionParams.z * 1.0 ) ) ) ));
			float ModifiedFogAlpha390 = saturate( lerpResult344 );
			o.Alpha = saturate( ( ( 1.0 - saturate( ( ( ase_worldPos.y * ( 0.1 / ( ( CZY_FogSmoothness * length( ase_objectScale ) ) * 10.0 ) ) ) + ( 1.0 - CZY_FogOffset ) ) ) ) * CZY_FogIntensity * ModifiedFogAlpha390 ) );
		}

		ENDCG
	}
	CustomEditor "EmptyShaderGUI"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.FunctionNode;321;-2912,480;Inherit;False;Reconstruct World Position From Depth;-1;;11;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;322;-2608,624;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;323;-816,592;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;-624,736;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;-480,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;326;-224,624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;-96,624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;48,624;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;329;-336,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;330;-480,832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;331;192,624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;332;-2656,704;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ProjectionParams;333;-2416,800;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;334;-2576,480;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-2416,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;336;-2256,640;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-2208,800;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;338;-2064,640;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;-2288,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;340;-1952,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;341;-2144,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;342;-1840,576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;343;-2000,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;344;-1824,400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;345;-1680,400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;346;-3072,1632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;347;-2896,1552;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-2576,1504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;349;-2336,1504;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;350;-2496,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;351;-2720,1728;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;150;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;352;-2592,1728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;353;-2448,1728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;354;-4176,1344;Inherit;False;Reconstruct World Position From Depth;-1;;14;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;355;-3616,1392;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;356;-3776,1456;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;357;-4064,1584;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;358;-3600,1552;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;359;-3840,1344;Inherit;False;True;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;360;-4016,1424;Inherit;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;361;-3424,1472;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;362;-3216,1440;Inherit;True;Property;_FogVariationTexture;Fog Variation Texture;10;0;Create;True;0;0;0;False;0;False;-1;c4666b12d12d34d45b89ea8d2fe52b01;c4666b12d12d34d45b89ea8d2fe52b01;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;363;-3376,1680;Inherit;False;Global;CZY_VariationAmount;CZY_VariationAmount;11;0;Create;False;0;0;0;False;0;False;1;0.78;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;364;-2944,1824;Inherit;False;Global;CZY_VariationDistance;CZY_VariationDistance;11;0;Create;False;0;0;0;False;0;False;1;51.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-3824,1568;Inherit;False;Global;CZY_VariationScale;CZY_VariationScale;10;0;Create;False;0;0;0;False;0;False;1;12.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-2144,1504;Inherit;False;newFogDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;367;-4256,1424;Inherit;False;Global;CZY_VariationWindDirection;CZY_VariationWindDirection;12;0;Create;False;0;0;0;False;0;False;1,0,0;6,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;368;-224,704;Inherit;False;Global;CZY_FogIntensity;CZY_FogIntensity;8;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-672,832;Inherit;False;Global;CZY_FogOffset;CZY_FogOffset;9;0;Create;False;0;0;0;False;0;False;0;1.031;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-2080,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;371;-2320,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;372;-1648,-144;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;373;-1648,-64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-1264,-96;Inherit;False;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-1424,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;-1104,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;377;-960,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-784,-480;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;379;-1296,-352;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;380;-592,-240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;381;-240,-288;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;382;-464,-240;Inherit;False;Filter Color;-1;;18;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;383;-464,-320;Inherit;False;Filter Color;-1;;19;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-2432,-256;Inherit;False;Global;CZY_FogDepthMultiplier;CZY_FogDepthMultiplier;13;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;385;-2880,48;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;-736,32;Inherit;False;finalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;-1104,-16;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;388;-960,-16;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-752,-144;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;-1552,400;Inherit;False;ModifiedFogAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;391;-224,784;Inherit;False;390;ModifiedFogAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;-2192,400;Inherit;False;386;finalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;393;-2672,48;Inherit;False;preDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;394;-2592,-128;Inherit;False;366;newFogDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;395;-2896,1456;Inherit;False;393;preDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-2896,1728;Inherit;False;393;preDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;397;-1872,-240;Inherit;False;Simple Gradient;0;;21;ece53c110c682694c8953a12e134178f;0;1;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;398;-1104,-608;Inherit;False;Global;CZY_LightColor;CZY_LightColor;18;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;1.083397,1.392001,1.382235,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;399;272,1520;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;400;416,1536;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;401;-240,1504;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;80,1520;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;403;-1312,1616;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;404;576,1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;405;-752,1520;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;406;-944,1520;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;407;-512,1504;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;408;576,1872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;96,1888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;410;272,1888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;411;-48,1888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;412;416,1872;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;272,1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;414;-1328,1488;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;-1168,1408;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;416;-1520,1344;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;417;-544,1824;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;418;-304,1824;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;419;-736,1888;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;420;-704,1808;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;421;720,1520;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;422;-784,1632;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;10;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,1,0;0.8699608,0.4921842,0.03037969;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;423;-160,1680;Half;False;Global;CZY_LightIntensity;CZY_LightIntensity;16;0;Create;False;0;0;0;False;0;False;0;0.9968594;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;112,1664;Half;False;Global;CZY_LightFalloff;CZY_LightFalloff;14;0;Create;False;0;0;0;False;0;False;1;24.67793;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;425;-1584,1504;Inherit;False;Global;CZY_LightFlareSquish;CZY_LightFlareSquish;12;0;Create;False;0;0;0;False;0;False;1;2.927227;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;426;-944,1888;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;11;0;Create;False;0;0;0;False;0;False;1,0,0;0.4169701,-0.9045281,-0.08924681;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;427;-880,1792;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;-1328,48;Inherit;False;430;MoonMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-1296,-176;Inherit;False;421;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;430;720,1872;Half;False;MoonMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;431;-1040,96;Inherit;False;Global;CZY_FogMoonFlareColor;CZY_FogMoonFlareColor;19;1;[HDR];Create;True;0;0;0;False;0;False;0.03051416,0.2017157,0.3773585,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;432;-1312,816;Inherit;False;Global;CZY_FogSmoothness;CZY_FogSmoothness;20;0;Create;False;0;0;0;False;0;False;0.1;0.625;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-1072,816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;434;-1312,896;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;435;-1520,912;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;-928,816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;554.9382,-20.37528;Float;False;True;-1;2;EmptyShaderGUI;0;0;Unlit;Distant Lands/Cozy/Stylized Fog (Physical Height);False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Front;2;False;;7;False;;False;0;False;;0;False;;True;0;Custom;0.5;True;False;1;True;Custom;HeightFog;Transparent;All;12;all;True;True;True;True;0;False;;True;222;False;;255;False;;255;False;;6;False;;3;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;11;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;322;0;321;0
WireConnection;324;1;436;0
WireConnection;325;0;323;2
WireConnection;325;1;324;0
WireConnection;326;0;329;0
WireConnection;327;0;326;0
WireConnection;328;0;327;0
WireConnection;328;1;368;0
WireConnection;328;2;391;0
WireConnection;329;0;325;0
WireConnection;329;1;330;0
WireConnection;330;0;369;0
WireConnection;331;0;328;0
WireConnection;334;0;321;0
WireConnection;335;0;334;1
WireConnection;336;0;322;0
WireConnection;336;1;332;0
WireConnection;337;0;333;3
WireConnection;338;0;336;0
WireConnection;338;1;337;0
WireConnection;339;0;335;0
WireConnection;340;0;338;0
WireConnection;341;0;339;0
WireConnection;342;0;340;0
WireConnection;343;0;341;0
WireConnection;343;1;392;0
WireConnection;344;0;392;0
WireConnection;344;1;343;0
WireConnection;344;2;342;0
WireConnection;345;0;344;0
WireConnection;346;0;363;0
WireConnection;347;0;362;1
WireConnection;347;3;346;0
WireConnection;348;0;395;0
WireConnection;348;1;347;0
WireConnection;349;0;350;0
WireConnection;349;1;348;0
WireConnection;349;2;353;0
WireConnection;350;0;395;0
WireConnection;351;0;396;0
WireConnection;351;1;364;0
WireConnection;352;0;351;0
WireConnection;353;0;352;0
WireConnection;355;0;359;0
WireConnection;355;1;356;0
WireConnection;356;0;360;0
WireConnection;356;1;357;0
WireConnection;358;1;365;0
WireConnection;359;0;354;0
WireConnection;360;0;367;0
WireConnection;361;0;355;0
WireConnection;361;1;358;0
WireConnection;362;1;361;0
WireConnection;366;0;349;0
WireConnection;370;0;384;0
WireConnection;370;1;371;0
WireConnection;371;0;394;0
WireConnection;372;0;397;0
WireConnection;373;0;370;0
WireConnection;374;1;375;0
WireConnection;375;0;372;0
WireConnection;375;1;373;0
WireConnection;376;0;429;0
WireConnection;376;1;374;0
WireConnection;377;0;376;0
WireConnection;378;0;398;0
WireConnection;378;1;379;3
WireConnection;378;2;377;0
WireConnection;379;0;397;0
WireConnection;380;0;397;0
WireConnection;380;1;389;0
WireConnection;381;0;383;0
WireConnection;381;1;382;0
WireConnection;382;1;380;0
WireConnection;383;1;378;0
WireConnection;386;0;375;0
WireConnection;387;0;375;0
WireConnection;387;1;428;0
WireConnection;388;0;387;0
WireConnection;389;0;379;3
WireConnection;389;1;388;0
WireConnection;389;2;431;0
WireConnection;390;0;345;0
WireConnection;393;0;385;0
WireConnection;397;1;370;0
WireConnection;399;0;402;0
WireConnection;400;0;399;0
WireConnection;400;1;424;0
WireConnection;401;0;407;0
WireConnection;402;0;401;0
WireConnection;402;1;423;0
WireConnection;404;0;400;0
WireConnection;405;0;406;0
WireConnection;406;0;415;0
WireConnection;406;1;403;0
WireConnection;407;0;405;0
WireConnection;407;1;422;0
WireConnection;408;0;412;0
WireConnection;409;0;411;0
WireConnection;409;1;423;0
WireConnection;410;0;409;0
WireConnection;411;0;418;0
WireConnection;412;0;410;0
WireConnection;412;1;413;0
WireConnection;413;0;424;0
WireConnection;414;1;425;0
WireConnection;415;0;416;0
WireConnection;415;1;414;0
WireConnection;417;0;420;0
WireConnection;417;1;419;0
WireConnection;418;0;417;0
WireConnection;419;0;426;0
WireConnection;420;0;427;0
WireConnection;421;0;404;0
WireConnection;430;0;408;0
WireConnection;433;0;432;0
WireConnection;433;1;434;0
WireConnection;434;0;435;0
WireConnection;436;0;433;0
WireConnection;0;2;381;0
WireConnection;0;9;331;0
ASEEND*/
//CHKSM=C3814FFAD2A15C80C4A3926BAF523EFBF9DE9BEF