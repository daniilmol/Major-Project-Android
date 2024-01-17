// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Luxury Clouds"
{
	Properties
	{
		CZY_LuxuryVariationTexture("CZY_LuxuryVariationTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Front
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 CZY_CloudColor;
		uniform float CZY_FilterSaturation;
		uniform float CZY_FilterValue;
		uniform float4 CZY_FilterColor;
		uniform float4 CZY_CloudFilterColor;
		uniform sampler2D CZY_CirrostratusTexture;
		uniform float CZY_CirrostratusMoveSpeed;
		uniform sampler2D CZY_LuxuryVariationTexture;
		uniform float CZY_CirrostratusMultiplier;
		uniform sampler2D CZY_AltocumulusTexture;
		uniform float CZY_MainCloudScale;
		uniform float CZY_WindSpeed;
		uniform float CZY_AltocumulusMultiplier;
		uniform sampler2D CZY_CirrusTexture;
		uniform float CZY_CirrusMoveSpeed;
		uniform float CZY_CirrusMultiplier;
		uniform sampler2D CZY_ChemtrailsTexture;
		uniform float CZY_ChemtrailsMoveSpeed;
		uniform float CZY_ChemtrailsMultiplier;
		uniform sampler2D CZY_PartlyCloudyTexture;
		uniform float CZY_CumulusCoverageMultiplier;
		uniform sampler2D CZY_MostlyCloudyTexture;
		uniform sampler2D CZY_OvercastTexture;
		uniform sampler2D CZY_LowNimbusTexture;
		uniform float CZY_NimbusMultiplier;
		uniform sampler2D CZY_MidNimbusTexture;
		uniform sampler2D CZY_HighNimbusTexture;
		uniform sampler2D CZY_LowBorderTexture;
		uniform float CZY_BorderHeight;
		uniform sampler2D CZY_HighBorderTexture;
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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 hsvTorgb2_g2 = RGBToHSV( CZY_CloudColor.rgb );
			float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
			float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
			float4 CloudColor332 = ( temp_output_10_0_g2 * CZY_CloudFilterColor );
			float2 Pos159 = i.uv_texcoord;
			float mulTime1458 = _Time.y * 0.01;
			float simplePerlin2D1470 = snoise( (Pos159*1.0 + mulTime1458)*2.0 );
			float mulTime1456 = _Time.y * CZY_CirrostratusMoveSpeed;
			float cos1464 = cos( ( mulTime1456 * 0.01 ) );
			float sin1464 = sin( ( mulTime1456 * 0.01 ) );
			float2 rotator1464 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1464 , -sin1464 , sin1464 , cos1464 )) + float2( 0.5,0.5 );
			float cos1466 = cos( ( mulTime1456 * -0.02 ) );
			float sin1466 = sin( ( mulTime1456 * -0.02 ) );
			float2 rotator1466 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1466 , -sin1466 , sin1466 , cos1466 )) + float2( 0.5,0.5 );
			float mulTime1472 = _Time.y * 0.01;
			float simplePerlin2D1469 = snoise( (Pos159*1.0 + mulTime1472) );
			simplePerlin2D1469 = simplePerlin2D1469*0.5 + 0.5;
			float4 CirrostratusPattern1473 = ( ( saturate( simplePerlin2D1470 ) * tex2D( CZY_CirrostratusTexture, (rotator1464*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrostratusTexture, (rotator1466*1.0 + 0.0) ) * saturate( simplePerlin2D1469 ) ) );
			float2 temp_output_1478_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1475 = dot( temp_output_1478_0 , temp_output_1478_0 );
			float2 temp_output_4_0_g46 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g46 = dot( temp_output_4_0_g46 , temp_output_4_0_g46 );
			float temp_output_14_0_g46 = ( CZY_CirrostratusMultiplier * 0.5 );
			float3 appendResult1490 = (float3(( CirrostratusPattern1473 * saturate( (0.0 + (dotResult1475 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) * saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g46*48.2 + (-15.0 + (temp_output_14_0_g46 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g46 ) ) ).rgb));
			float temp_output_1489_0 = length( appendResult1490 );
			float CirrostratusColoring1491 = temp_output_1489_0;
			float CirrostratusAlpha1492 = temp_output_1489_0;
			float lerpResult1495 = lerp( 1.0 , CirrostratusColoring1491 , CirrostratusAlpha1492);
			float mulTime61 = _Time.y * ( 0.001 * CZY_WindSpeed );
			float TIme152 = mulTime61;
			float2 cloudPosition1619 = (Pos159*( 18.0 / CZY_MainCloudScale ) + ( TIme152 * float2( 0.2,-0.4 ) ));
			float4 tex2DNode1616 = tex2D( CZY_AltocumulusTexture, cloudPosition1619 );
			float altocumulusColor1617 = tex2DNode1616.r;
			float2 temp_output_4_0_g54 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g54 = dot( temp_output_4_0_g54 , temp_output_4_0_g54 );
			float temp_output_14_0_g54 = CZY_AltocumulusMultiplier;
			float altocumulusAlpha1618 = tex2DNode1616.a;
			float temp_output_1625_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g54*48.2 + (-15.0 + (temp_output_14_0_g54 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g54 ) ) * altocumulusAlpha1618 );
			float lerpResult1629 = lerp( 1.0 , altocumulusColor1617 , temp_output_1625_0);
			float finalAcColor1631 = lerpResult1629;
			float finalAcAlpha1635 = temp_output_1625_0;
			float lerpResult1634 = lerp( lerpResult1495 , finalAcColor1631 , finalAcAlpha1635);
			float mulTime1408 = _Time.y * 0.01;
			float simplePerlin2D1422 = snoise( (Pos159*1.0 + mulTime1408)*2.0 );
			float mulTime1406 = _Time.y * CZY_CirrusMoveSpeed;
			float cos1414 = cos( ( mulTime1406 * 0.01 ) );
			float sin1414 = sin( ( mulTime1406 * 0.01 ) );
			float2 rotator1414 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1414 , -sin1414 , sin1414 , cos1414 )) + float2( 0.5,0.5 );
			float cos1416 = cos( ( mulTime1406 * -0.02 ) );
			float sin1416 = sin( ( mulTime1406 * -0.02 ) );
			float2 rotator1416 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1416 , -sin1416 , sin1416 , cos1416 )) + float2( 0.5,0.5 );
			float mulTime1424 = _Time.y * 0.01;
			float simplePerlin2D1421 = snoise( (Pos159*1.0 + mulTime1424) );
			simplePerlin2D1421 = simplePerlin2D1421*0.5 + 0.5;
			float4 CirrusPattern1425 = ( ( saturate( simplePerlin2D1422 ) * tex2D( CZY_CirrusTexture, (rotator1414*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrusTexture, (rotator1416*1.0 + 0.0) ) * saturate( simplePerlin2D1421 ) ) );
			float2 temp_output_1430_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1427 = dot( temp_output_1430_0 , temp_output_1430_0 );
			float2 temp_output_4_0_g45 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g45 = dot( temp_output_4_0_g45 , temp_output_4_0_g45 );
			float temp_output_14_0_g45 = ( CZY_CirrusMultiplier * 0.5 );
			float3 appendResult1446 = (float3(( CirrusPattern1425 * saturate( (0.0 + (dotResult1427 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) * saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g45*48.2 + (-15.0 + (temp_output_14_0_g45 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g45 ) ) ).rgb));
			float temp_output_1447_0 = length( appendResult1446 );
			float CirrusColoring1448 = temp_output_1447_0;
			float CirrusAlpha1449 = temp_output_1447_0;
			float lerpResult1450 = lerp( lerpResult1634 , CirrusColoring1448 , CirrusAlpha1449);
			float mulTime1373 = _Time.y * 0.01;
			float simplePerlin2D1380 = snoise( (Pos159*1.0 + mulTime1373)*2.0 );
			float mulTime1371 = _Time.y * CZY_ChemtrailsMoveSpeed;
			float cos1372 = cos( ( mulTime1371 * 0.01 ) );
			float sin1372 = sin( ( mulTime1371 * 0.01 ) );
			float2 rotator1372 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1372 , -sin1372 , sin1372 , cos1372 )) + float2( 0.5,0.5 );
			float cos1379 = cos( ( mulTime1371 * -0.02 ) );
			float sin1379 = sin( ( mulTime1371 * -0.02 ) );
			float2 rotator1379 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1379 , -sin1379 , sin1379 , cos1379 )) + float2( 0.5,0.5 );
			float mulTime1369 = _Time.y * 0.01;
			float simplePerlin2D1381 = snoise( (Pos159*1.0 + mulTime1369)*4.0 );
			float4 ChemtrailsPattern1387 = ( ( saturate( simplePerlin2D1380 ) * tex2D( CZY_ChemtrailsTexture, (rotator1372*0.5 + 0.0) ) ) + ( tex2D( CZY_ChemtrailsTexture, rotator1379 ) * saturate( simplePerlin2D1381 ) ) );
			float2 temp_output_1357_0 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult1359 = dot( temp_output_1357_0 , temp_output_1357_0 );
			float2 temp_output_4_0_g44 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g44 = dot( temp_output_4_0_g44 , temp_output_4_0_g44 );
			float temp_output_14_0_g44 = ( CZY_ChemtrailsMultiplier * 0.5 );
			float3 appendResult1398 = (float3(( ChemtrailsPattern1387 * saturate( (0.4 + (dotResult1359 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) * saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g44*48.2 + (-15.0 + (temp_output_14_0_g44 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g44 ) ) ).rgb));
			float temp_output_1399_0 = length( appendResult1398 );
			float ChemtrailsColoring1363 = temp_output_1399_0;
			float ChemtrailsAlpha1402 = temp_output_1399_0;
			float lerpResult1396 = lerp( lerpResult1450 , ChemtrailsColoring1363 , ChemtrailsAlpha1402);
			float4 tex2DNode1208 = tex2D( CZY_PartlyCloudyTexture, cloudPosition1619 );
			float PartlyCloudyColor1216 = tex2DNode1208.r;
			float2 temp_output_4_0_g53 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g53 = dot( temp_output_4_0_g53 , temp_output_4_0_g53 );
			float temp_output_1603_0 = ( CZY_CumulusCoverageMultiplier * 1.0 );
			float temp_output_14_0_g53 = saturate( (0.0 + (min( temp_output_1603_0 , 0.2 ) - 0.0) * (1.0 - 0.0) / (0.2 - 0.0)) );
			float PartlyCloudyAlpha1207 = tex2DNode1208.a;
			float temp_output_1236_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g53*48.2 + (-15.0 + (temp_output_14_0_g53 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g53 ) ) * PartlyCloudyAlpha1207 );
			float lerpResult1240 = lerp( 1.0 , PartlyCloudyColor1216 , temp_output_1236_0);
			float4 tex2DNode1209 = tex2D( CZY_MostlyCloudyTexture, cloudPosition1619 );
			float MostlyCloudyColor1215 = tex2DNode1209.r;
			float2 temp_output_4_0_g51 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g51 = dot( temp_output_4_0_g51 , temp_output_4_0_g51 );
			float temp_output_14_0_g51 = saturate( (0.0 + (min( ( temp_output_1603_0 - 0.3 ) , 0.2 ) - 0.0) * (1.0 - 0.0) / (0.2 - 0.0)) );
			float MostlyCloudyAlpha1205 = tex2DNode1209.a;
			float temp_output_1217_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g51*48.2 + (-15.0 + (temp_output_14_0_g51 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g51 ) ) * MostlyCloudyAlpha1205 );
			float lerpResult1243 = lerp( lerpResult1240 , MostlyCloudyColor1215 , temp_output_1217_0);
			float4 tex2DNode1193 = tex2D( CZY_OvercastTexture, cloudPosition1619 );
			float OvercastCloudyColoring1195 = tex2DNode1193.r;
			float2 temp_output_4_0_g52 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g52 = dot( temp_output_4_0_g52 , temp_output_4_0_g52 );
			float temp_output_14_0_g52 = saturate( (0.0 + (min( ( temp_output_1603_0 - 0.7 ) , 0.35 ) - 0.0) * (1.0 - 0.0) / (0.35 - 0.0)) );
			float OvercastCloudyAlpha1196 = tex2DNode1193.a;
			float temp_output_1241_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g52*48.2 + (-15.0 + (temp_output_14_0_g52 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g52 ) ) * OvercastCloudyAlpha1196 );
			float lerpResult1244 = lerp( lerpResult1243 , OvercastCloudyColoring1195 , temp_output_1241_0);
			float cumulusCloudColor1248 = saturate( lerpResult1244 );
			float cumulusAlpha1242 = saturate( ( temp_output_1236_0 + temp_output_1217_0 + temp_output_1241_0 ) );
			float lerpResult1346 = lerp( lerpResult1396 , cumulusCloudColor1248 , cumulusAlpha1242);
			float mulTime1613 = _Time.y * 0.005;
			float cos1612 = cos( mulTime1613 );
			float sin1612 = sin( mulTime1613 );
			float2 rotator1612 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1612 , -sin1612 , sin1612 , cos1612 )) + float2( 0.5,0.5 );
			float4 tex2DNode1575 = tex2D( CZY_LowNimbusTexture, rotator1612 );
			float lowNimbusColor1576 = tex2DNode1575.r;
			float2 temp_output_4_0_g50 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g50 = dot( temp_output_4_0_g50 , temp_output_4_0_g50 );
			float temp_output_1602_0 = ( CZY_NimbusMultiplier * 0.5 );
			float temp_output_14_0_g50 = saturate( (0.0 + (min( temp_output_1602_0 , 2.0 ) - 0.0) * (1.0 - 0.0) / (2.0 - 0.0)) );
			float lowNimbusAlpha1577 = tex2DNode1575.a;
			float temp_output_1587_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g50*48.2 + (-15.0 + (temp_output_14_0_g50 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g50 ) ) * lowNimbusAlpha1577 );
			float lerpResult1593 = lerp( 1.0 , lowNimbusColor1576 , temp_output_1587_0);
			float4 tex2DNode1580 = tex2D( CZY_MidNimbusTexture, rotator1612 );
			float mediumNimbusColor1578 = tex2DNode1580.r;
			float2 temp_output_4_0_g49 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g49 = dot( temp_output_4_0_g49 , temp_output_4_0_g49 );
			float temp_output_14_0_g49 = saturate( (0.0 + (min( ( temp_output_1602_0 - 0.2 ) , 0.3 ) - 0.0) * (1.0 - 0.0) / (0.3 - 0.0)) );
			float mediumNimbusAlpha1579 = tex2DNode1580.a;
			float temp_output_1584_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g49*48.2 + (-15.0 + (temp_output_14_0_g49 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g49 ) ) * mediumNimbusAlpha1579 );
			float lerpResult1595 = lerp( lerpResult1593 , mediumNimbusColor1578 , temp_output_1584_0);
			float4 tex2DNode1583 = tex2D( CZY_HighNimbusTexture, rotator1612 );
			float highNimbusColor1581 = tex2DNode1583.r;
			float2 temp_output_4_0_g48 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g48 = dot( temp_output_4_0_g48 , temp_output_4_0_g48 );
			float temp_output_14_0_g48 = saturate( (0.0 + (min( ( temp_output_1602_0 - 0.7 ) , 0.3 ) - 0.0) * (1.0 - 0.0) / (0.3 - 0.0)) );
			float HighNimbusAlpha1582 = tex2DNode1583.a;
			float temp_output_1571_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g48*48.2 + (-15.0 + (temp_output_14_0_g48 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g48 ) ) * HighNimbusAlpha1582 );
			float lerpResult1597 = lerp( lerpResult1595 , highNimbusColor1581 , temp_output_1571_0);
			float nimbusColoring1601 = saturate( lerpResult1597 );
			float nimbusAlpha1592 = saturate( ( temp_output_1587_0 + temp_output_1584_0 + temp_output_1571_0 ) );
			float lerpResult1541 = lerp( lerpResult1346 , nimbusColoring1601 , nimbusAlpha1592);
			float mulTime1610 = _Time.y * 0.005;
			float cos1608 = cos( mulTime1610 );
			float sin1608 = sin( mulTime1610 );
			float2 rotator1608 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos1608 , -sin1608 , sin1608 , cos1608 )) + float2( 0.5,0.5 );
			float4 tex2DNode1285 = tex2D( CZY_LowBorderTexture, rotator1608 );
			float MediumBorderColor1291 = tex2DNode1285.r;
			float2 temp_output_4_0_g47 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g47 = dot( temp_output_4_0_g47 , temp_output_4_0_g47 );
			float temp_output_14_0_g47 = saturate( (0.0 + (min( CZY_BorderHeight , 0.3 ) - 0.0) * (1.0 - 0.0) / (0.3 - 0.0)) );
			float MediumBorderAlpha1281 = tex2DNode1285.a;
			float temp_output_1312_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g47*48.2 + (-15.0 + (temp_output_14_0_g47 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g47 ) ) * MediumBorderAlpha1281 );
			float lerpResult1316 = lerp( 1.0 , MediumBorderColor1291 , temp_output_1312_0);
			float4 tex2DNode1269 = tex2D( CZY_HighBorderTexture, rotator1608 );
			float HighBorderColoring1271 = tex2DNode1269.r;
			float2 temp_output_4_0_g55 = ( i.uv_texcoord - float2( 0.5,0.5 ) );
			float dotResult3_g55 = dot( temp_output_4_0_g55 , temp_output_4_0_g55 );
			float temp_output_14_0_g55 = saturate( (0.0 + (min( ( CZY_BorderHeight - 0.5 ) , 0.2 ) - 0.0) * (1.0 - 0.0) / (0.2 - 0.0)) );
			float HighBorderAlpha1272 = tex2DNode1269.a;
			float temp_output_1293_0 = ( saturate( ( ( (-1.0 + (tex2D( CZY_LuxuryVariationTexture, (i.uv_texcoord*10.0 + 0.0) ).r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + (dotResult3_g55*48.2 + (-15.0 + (temp_output_14_0_g55 - 0.0) * (1.0 - -15.0) / (1.0 - 0.0))) ) + temp_output_14_0_g55 ) ) * HighBorderAlpha1272 );
			float lerpResult1319 = lerp( lerpResult1316 , HighBorderColoring1271 , temp_output_1293_0);
			float borderCloudsColor1324 = saturate( lerpResult1319 );
			float borderAlpha1318 = saturate( ( temp_output_1312_0 + temp_output_1293_0 ) );
			float lerpResult1347 = lerp( lerpResult1541 , borderCloudsColor1324 , borderAlpha1318);
			float cloudColoring1348 = lerpResult1347;
			float4 lerpResult896 = lerp( float4( 0,0,0,0 ) , CloudColor332 , cloudColoring1348);
			o.Albedo = lerpResult896.rgb;
			float cloudAlpha1349 = ( borderAlpha1318 + nimbusAlpha1592 + cumulusAlpha1242 + ChemtrailsAlpha1402 + CirrusAlpha1449 + finalAcAlpha1635 + CirrostratusAlpha1492 );
			o.Alpha = saturate( ( cloudAlpha1349 + ( 0.0 * 2.0 * CZY_CloudThickness ) ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
Node;AmplifyShaderEditor.CommentaryNode;1614;-3202.689,991.4457;Inherit;False;993.2637;376.0277;Comment;4;1622;1618;1617;1616;;1,0,0.6569862,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1559;-1920,-48;Inherit;False;3120.703;876.5322;;31;1600;1599;1598;1597;1596;1595;1594;1593;1592;1591;1590;1589;1587;1586;1584;1573;1571;1567;1570;1569;1568;1564;1563;1566;1565;1561;1560;1562;1558;1601;1602;Nimbus;0.3450134,0.5190864,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1341;3683.782,-4640.204;Inherit;False;3783.782;581.1655;Blending;31;1349;1351;1348;1344;1347;1343;1346;1345;1342;1396;1395;1394;1450;1451;1452;1495;1497;1496;1540;1541;1542;1549;1550;1551;1552;1553;1632;1633;1634;1636;1637;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;372;-4255.697,-4622.015;Inherit;False;1721.5;661.179;;20;70;150;152;61;1619;1607;1605;1604;1606;1210;1263;332;796;36;815;814;797;159;94;1638;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;94;-3079.566,-4417.043;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-2876.129,-4422.287;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;797;-2912,-4528;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;814;-3888,-4512;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;815;-3120,-4528;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;36;-4144,-4512;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;True;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;1.01994,0.8557577,0.7989255,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;796;-3354.791,-4527.796;Inherit;False;Global;CZY_CloudMoonColor;CZY_CloudMoonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;896;2224,-4320;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;332;-3599.176,-4511.369;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1073;2960,-4080;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1074;2416,-3936;Inherit;False;Global;CZY_CloudThickness;CZY_CloudThickness;6;1;[HDR];Create;False;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1075;2704,-4016;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1076;2832,-4080;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1265;-1920,-944;Inherit;False;2786.006;796.8489;Luxury Border Mixing;21;1318;1324;1323;1308;1294;1313;1326;1315;1316;1305;1336;1338;1337;1331;1330;1329;1328;1327;1319;1312;1293;;0.3450134,1,0.3778738,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1189;-1904,-1952;Inherit;False;3624.021;965.2615;Luxury Cumulus Mixing;30;1262;1261;1251;1250;1243;1240;1239;1237;1236;1603;1260;1244;1247;1248;1253;1255;1254;1259;1258;1257;1256;1252;1245;1242;1241;1232;1229;1227;1218;1217;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1190;-3072,-1952;Inherit;False;920.8781;762.4537;Luxury Cumulus;10;1621;1193;1196;1195;1215;1209;1205;1216;1208;1207;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1266;-3264,-912;Inherit;False;1091.253;543.1126;Luxury Border;9;1269;1272;1271;1281;1291;1285;1608;1609;1610;;0.4351934,1,0.3638814,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1065;2368,-4080;Inherit;False;1349;cloudAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1100;1758.339,-4224;Inherit;False;1348;cloudColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1353;2096,-2736;Inherit;False;2340.552;1688.827;;2;1355;1354;Chemtrails Block;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1354;2144,-2688;Inherit;False;2197.287;953.2202;Pattern;24;1391;1390;1389;1388;1387;1386;1385;1384;1383;1382;1381;1380;1379;1378;1377;1376;1375;1374;1373;1372;1371;1370;1369;1368;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1355;2160,-1664;Inherit;False;1767.479;566.6924;Final;13;1363;1367;1392;1366;1360;1361;1359;1358;1357;1356;1398;1399;1402;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1356;2240,-1456;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1357;2464,-1456;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1358;2784,-1456;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1359;2640,-1456;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1361;2960,-1456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1368;2752,-2528;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1369;2736,-1856;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1370;3424,-2496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1371;2416,-2176;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;1372;2880,-2304;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1373;2768,-2448;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1374;2704,-2320;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1375;2640,-2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1376;2992,-1920;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1377;2736,-1936;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1378;3088,-2304;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1379;2976,-2144;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1380;3232,-2512;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1381;3216,-1920;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1383;3424,-1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1384;3648,-2144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1385;3648,-2368;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1386;3824,-2256;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1387;4048,-2256;Inherit;False;ChemtrailsPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1388;3008,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1389;2656,-2128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1360;2896,-1568;Inherit;False;1387;ChemtrailsPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1366;3136,-1520;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1392;2640,-1264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;960;1546.9,-4409;Inherit;False;332;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1390;2176,-2192;Inherit;False;Global;CZY_ChemtrailsMoveSpeed;CZY_ChemtrailsMoveSpeed;15;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.289;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1367;2352,-1264;Inherit;False;Global;CZY_ChemtrailsMultiplier;CZY_ChemtrailsMultiplier;15;0;Create;False;1;Chemtrails;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1403;4512,-2736;Inherit;False;2297.557;1709.783;;2;1405;1404;Cirrus Block;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1404;4560,-2688;Inherit;False;2197.287;953.2202;Pattern;25;1444;1443;1437;1435;1429;1428;1426;1425;1424;1422;1421;1419;1418;1417;1416;1415;1414;1413;1412;1411;1410;1409;1408;1407;1406;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1405;4576,-1664;Inherit;False;1735.998;586.5895;Final;13;1442;1436;1434;1433;1432;1431;1430;1427;1423;1446;1447;1448;1449;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;1398;3344,-1520;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;1399;3488,-1520;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1363;3623,-1603;Inherit;True;ChemtrailsColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1402;3627,-1375;Inherit;True;ChemtrailsAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1406;4816,-2176;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1407;5104,-2320;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1408;5168,-2448;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1409;5152,-1936;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1410;5168,-2528;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1411;5072,-2128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1412;5056,-2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1413;5392,-1920;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1414;5296,-2304;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1415;5424,-2512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1416;5296,-2160;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1417;5488,-2144;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1419;5824,-1920;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1421;5632,-1920;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1422;5648,-2512;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1423;4624,-1456;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;1424;5152,-1856;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1425;6448,-2256;Inherit;False;CirrusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1426;5824,-2496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1427;4976,-1456;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1428;6048,-2144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1429;6048,-2368;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1430;4832,-1456;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1431;5312,-1568;Inherit;False;1425;CirrusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1432;5376,-1456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1434;5120,-1456;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1435;6224,-2256;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1437;5488,-2320;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1443;4592,-2192;Inherit;False;Global;CZY_CirrusMoveSpeed;CZY_CirrusMoveSpeed;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.297;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1433;5120,-1232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1442;4816,-1232;Inherit;False;Global;CZY_CirrusMultiplier;CZY_CirrusMultiplier;11;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1436;5600,-1472;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LengthOpNode;1447;5904,-1472;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1446;5760,-1472;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1448;6032,-1552;Inherit;True;CirrusColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1449;6032,-1328;Inherit;True;CirrusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1418;5679,-2142;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1444;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1453;6848,-2767;Inherit;False;2297.557;1709.783;;2;1455;1454;Cirrostratus Block;1,0.4588236,0.5149367,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1454;6896,-2719;Inherit;False;2197.287;953.2202;Pattern;25;1494;1493;1484;1483;1482;1477;1476;1474;1473;1472;1470;1469;1468;1467;1466;1465;1464;1463;1462;1461;1460;1459;1458;1457;1456;;1,0.4696538,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1455;6912,-1695;Inherit;False;1735.998;586.5895;Final;13;1492;1491;1490;1489;1488;1487;1486;1481;1480;1479;1478;1475;1471;;1,0.4744119,0.4588236,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;1456;7152,-2207;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1457;7440,-2351;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1458;7504,-2479;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1459;7488,-1967;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1460;7504,-2559;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1461;7408,-2159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1462;7392,-2255;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1463;7728,-1951;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1464;7632,-2335;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1465;7760,-2543;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1466;7632,-2191;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1467;7824,-2175;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1468;8160,-1951;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1469;7968,-1951;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1470;7984,-2543;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1471;6960,-1487;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;1472;7488,-1887;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1474;8160,-2527;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1475;7312,-1487;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1476;8384,-2175;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1477;8384,-2399;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1478;7168,-1487;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1480;7712,-1487;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1481;7456,-1487;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1482;8560,-2287;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1483;7824,-2351;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1486;7456,-1263;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1488;7936,-1503;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LengthOpNode;1489;8240,-1503;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1490;8096,-1503;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1487;7152,-1263;Inherit;False;Global;CZY_CirrostratusMultiplier;CZY_CirrostratusMultiplier;11;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1484;6928,-2223;Inherit;False;Global;CZY_CirrostratusMoveSpeed;CZY_CirrostratusMoveSpeed;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.281;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1473;8784,-2287;Inherit;False;CirrostratusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1491;8368,-1583;Inherit;True;CirrostratusColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1492;8368,-1359;Inherit;True;CirrostratusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1493;8016,-2175;Inherit;True;Property;_TextureSample2;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1494;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1494;8016,-2383;Inherit;True;Global;CZY_CirrostratusTexture;CZY_CirrostratusTexture;3;0;Create;False;0;0;0;False;0;False;-1;None;bf43c8d7b74e204469465f36dfff7d6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1479;7648,-1599;Inherit;False;1473;CirrostratusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1312;-400,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1319;256,-576;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1316;64,-848;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1315;-176,-832;Inherit;False;1291;MediumBorderColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1326;32,-560;Inherit;False;1271;HighBorderColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1313;-640,-720;Inherit;False;1281;MediumBorderAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1327;-976,-768;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1337;-1296,-768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1338;-1168,-768;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1328;-800,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1331;-1488,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1330;-1280,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1329;-1072,-384;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1560;-1008,176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1566;-1056,400;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1563;-880,400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1568;-1056,592;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1569;-880,592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1567;-1200,592;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1293;-352,-368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1294;-592,-288;Inherit;False;1272;HighBorderAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1574;-3216,-16;Inherit;False;1026.181;776.4215;Luxury Border;12;1582;1581;1579;1578;1577;1576;1583;1580;1575;1611;1612;1613;;0.3647059,0.6001141,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1571;-464,608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1573;-704,672;Inherit;False;1582;HighNimbusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1584;-479.6414,401.4434;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1586;-720,480;Inherit;False;1579;mediumNimbusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1587;-480,192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1305;-208,-592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1308;32,-400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1318;176,-400;Inherit;False;borderAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1590;-219.1875,446.1195;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1591;-80,448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1592;80,448;Inherit;False;nimbusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1593;-16,128;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1594;-272,128;Inherit;False;1576;lowNimbusColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1595;208,288;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1596;-80,288;Inherit;False;1578;mediumNimbusColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1597;528,528;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1599;450.1603,630.6345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1600;688,528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1601;832,528;Inherit;False;nimbusColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1589;-720,272;Inherit;False;1577;lowNimbusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1598;224,544;Inherit;False;1581;highNimbusColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1561;-1328,176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1562;-1184,176;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1564;-1360,400;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1565;-1200,400;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1570;-1360,592;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1602;-1552,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1291;-2416,-816;Inherit;False;MediumBorderColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1281;-2416,-720;Inherit;False;MediumBorderAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1271;-2416,-608;Inherit;False;HighBorderColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1272;-2416,-512;Inherit;False;HighBorderAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1609;-3200,-704;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1608;-2976,-640;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;94.72;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1610;-3200,-576;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1576;-2448,96;Inherit;False;lowNimbusColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1577;-2448,192;Inherit;False;lowNimbusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1578;-2448,304;Inherit;False;mediumNimbusColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1579;-2448,400;Inherit;False;mediumNimbusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1611;-3184,272;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1612;-2960,336;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;94.72;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;1613;-3184,400;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1615;-1888,976;Inherit;False;1339.236;421.4817;Comment;7;1631;1635;1624;1626;1625;1629;1630;;1,0,0.6569862,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1581;-2432,512;Inherit;False;highNimbusColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1582;-2432,608;Inherit;False;HighNimbusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1263;-3648,-4304;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1606;-3920,-4176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1604;-4160,-4208;Inherit;False;152;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1605;-4160,-4128;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;1607;-3872,-4400;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1619;-3456,-4304;Inherit;False;cloudPosition;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;61;-3296,-4160;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-3120,-4160;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-3424,-4160;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3648,-4128;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;2.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1617;-2528,1104;Inherit;False;altocumulusColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1618;-2528,1200;Inherit;False;altocumulusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1622;-3136,1120;Inherit;False;1619;cloudPosition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1207;-2448,-1760;Inherit;False;PartlyCloudyAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1216;-2448,-1872;Inherit;False;PartlyCloudyColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1205;-2448,-1568;Inherit;False;MostlyCloudyAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1215;-2448,-1664;Inherit;False;MostlyCloudyColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1195;-2448,-1424;Inherit;False;OvercastCloudyColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1196;-2448,-1328;Inherit;False;OvercastCloudyAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1621;-3040,-1600;Inherit;False;1619;cloudPosition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1217;-16,-1616;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1218;-256,-1536;Inherit;False;1205;MostlyCloudyAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1227;-256,-1184;Inherit;False;1196;OvercastCloudyAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1229;496,-1440;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1232;704,-1440;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1241;-16,-1264;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1242;848,-1440;Inherit;False;cumulusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1245;816,-1360;Inherit;False;1195;OvercastCloudyColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1252;-496,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1256;-512,-1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1253;-672,-1568;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1248;1456,-1568;Inherit;False;cumulusCloudColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1247;1312,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1244;1136,-1568;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1260;-1824,-1424;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;5;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1239;208,-1856;Inherit;False;1216;PartlyCloudyColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1240;448,-1856;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1243;672,-1648;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1250;400,-1648;Inherit;False;1215;MostlyCloudyColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1251;-560,-1840;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1261;-880,-1840;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1262;-752,-1840;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1558;-1824,432;Inherit;False;Global;CZY_NimbusMultiplier;CZY_NimbusMultiplier;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1236;16,-1840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1237;-224,-1792;Inherit;False;1207;PartlyCloudyAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1630;-1344,1088;Inherit;False;1617;altocumulusColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1629;-1088,1088;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1625;-1264,1184;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1626;-1520,1248;Inherit;False;1618;altocumulusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1624;-1808,1168;Inherit;False;Global;CZY_AltocumulusMultiplier;CZY_AltocumulusMultiplier;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1323;432,-576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1324;592,-576;Inherit;False;borderCloudsColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1496;3728,-4528;Inherit;False;1491;CirrostratusColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1497;3728,-4432;Inherit;False;1492;CirrostratusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1495;4000,-4544;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1394;5200,-4496;Inherit;False;1363;ChemtrailsColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1395;5200,-4416;Inherit;False;1402;ChemtrailsAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1550;5376,-4256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1549;4880,-4240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1396;5440,-4544;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1351;7088,-4304;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1342;5680,-4480;Inherit;False;1248;cumulusCloudColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1345;5680,-4400;Inherit;False;1242;cumulusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1346;5920,-4544;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1348;7168,-4560;Inherit;False;cloudColoring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1343;6640,-4480;Inherit;False;1324;borderCloudsColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1347;6896,-4544;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1344;6640,-4400;Inherit;False;1318;borderAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1541;6400,-4544;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1551;5840,-4272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1552;6384,-4272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1553;6832,-4304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1349;7216,-4304;Inherit;False;cloudAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1540;6176,-4480;Inherit;False;1601;nimbusColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1542;6176,-4400;Inherit;False;1592;nimbusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1452;4720,-4480;Inherit;False;1448;CirrusColoring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1451;4720,-4400;Inherit;False;1449;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1450;4960,-4544;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1634;4480,-4544;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1632;4240,-4480;Inherit;False;1631;finalAcColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1635;-1088,1216;Inherit;False;finalAcAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1633;4240,-4400;Inherit;False;1635;finalAcAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1631;-912,1088;Inherit;False;finalAcColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1636;3974.467,-4214.068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1637;4445.334,-4232.807;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1210;-4160,-4304;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;18;0;Create;True;0;0;0;False;0;False;1;22.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1254;-800,-1568;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1255;-992,-1568;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1603;-1488,-1424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1639;2768,-1264;Inherit;False;Blend With Variation;6;;44;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1640;5264,-1232;Inherit;False;Blend With Variation;6;;45;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1641;7600,-1263;Inherit;False;Blend With Variation;6;;46;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1642;-640,-800;Inherit;False;Blend With Variation;6;;47;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1643;-704,592;Inherit;False;Blend With Variation;6;;48;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1644;-720,400;Inherit;False;Blend With Variation;6;;49;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1645;-720,192;Inherit;False;Blend With Variation;6;;50;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1646;-256,-1632;Inherit;False;Blend With Variation;6;;51;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1647;-256,-1280;Inherit;False;Blend With Variation;6;;52;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1648;-224,-1872;Inherit;False;Blend With Variation;6;;53;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1649;-1520,1168;Inherit;False;Blend With Variation;6;;54;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1650;-592,-384;Inherit;False;Blend With Variation;6;;55;1861c05031b4c6d4cadcfb9c5f8700d8;0;1;14;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1336;-1809.3,-576;Inherit;True;Global;CZY_BorderHeight;CZY_BorderHeight;5;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;0.7;0.553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1209;-2752,-1648;Inherit;True;Global;CZY_MostlyCloudyTexture;CZY_MostlyCloudyTexture;11;0;Create;False;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;0134c7641e0c9d74a9f6f685c2896bb9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1193;-2752,-1424;Inherit;True;Global;CZY_OvercastTexture;CZY_OvercastTexture;0;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;46d8a16f4016e1f4a8ac3708aee5235d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1269;-2720,-608;Inherit;True;Global;CZY_HighBorderTexture;CZY_HighBorderTexture;8;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;5054a748d0ecd72408e17cbdc92f07cb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1285;-2720,-816;Inherit;True;Global;CZY_LowBorderTexture;CZY_LowBorderTexture;12;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;9a76ce8f2c182c247834c19603ff2068;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1575;-2752,96;Inherit;True;Global;CZY_LowNimbusTexture;CZY_LowNimbusTexture;13;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;8b7b5fa7d0504eb4084b8d451bdb4dac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1580;-2752,304;Inherit;True;Global;CZY_MidNimbusTexture;CZY_MidNimbusTexture;9;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;aafa15e7fb9760b4d93ef145502eab4b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1583;-2736,512;Inherit;True;Global;CZY_HighNimbusTexture;CZY_HighNimbusTexture;4;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;cf1e011d4126f5b45af1e0c5c8162509;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1616;-2832,1088;Inherit;True;Global;CZY_AltocumulusTexture;CZY_AltocumulusTexture;1;0;Create;False;0;0;0;False;0;False;-1;f33b9a1f2410c8d429fc3d8e4bde2874;b03bb03c5876b954ba45feffa4aaad63;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1382;3280,-2144;Inherit;True;Property;_ChemtrailsTex2;Chemtrails Tex 2;2;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;1391;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1391;3280,-2352;Inherit;True;Global;CZY_ChemtrailsTexture;CZY_ChemtrailsTexture;2;0;Create;False;0;0;0;False;0;False;-1;9b3476b4df9abf8479476bae1bcd8a84;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1444;5680,-2352;Inherit;True;Global;CZY_CirrusTexture;CZY_CirrusTexture;5;0;Create;False;0;0;0;False;0;False;-1;None;302629ebb64a0e345948779662fc2cf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1208;-2752,-1872;Inherit;True;Global;CZY_PartlyCloudyTexture;CZY_PartlyCloudyTexture;10;0;Create;True;0;0;0;False;0;False;-1;4aedeee388f3b8549b4483841794e33d;4aedeee388f3b8549b4483841794e33d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1259;-1008,-1280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1258;-816,-1280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.35;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1257;-688,-1280;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.35;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1638;-3920,-4288;Inherit;False;2;0;FLOAT;18;False;1;FLOAT;18;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1651;3152,-4208;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Distant Lands/Cozy/Luxury Clouds;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Front;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;1072;2393.984,-4204.238;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;22;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
WireConnection;159;0;94;0
WireConnection;797;0;815;0
WireConnection;814;1;36;0
WireConnection;815;1;796;0
WireConnection;896;1;960;0
WireConnection;896;2;1100;0
WireConnection;332;0;814;0
WireConnection;1073;0;1076;0
WireConnection;1075;2;1074;0
WireConnection;1076;0;1065;0
WireConnection;1076;1;1075;0
WireConnection;1357;0;1356;0
WireConnection;1358;0;1359;0
WireConnection;1359;0;1357;0
WireConnection;1359;1;1357;0
WireConnection;1361;0;1358;0
WireConnection;1370;0;1380;0
WireConnection;1371;0;1390;0
WireConnection;1372;0;1374;0
WireConnection;1372;2;1375;0
WireConnection;1375;0;1371;0
WireConnection;1376;0;1377;0
WireConnection;1376;2;1369;0
WireConnection;1378;0;1372;0
WireConnection;1379;0;1374;0
WireConnection;1379;2;1389;0
WireConnection;1380;0;1388;0
WireConnection;1381;0;1376;0
WireConnection;1383;0;1381;0
WireConnection;1384;0;1382;0
WireConnection;1384;1;1383;0
WireConnection;1385;0;1370;0
WireConnection;1385;1;1391;0
WireConnection;1386;0;1385;0
WireConnection;1386;1;1384;0
WireConnection;1387;0;1386;0
WireConnection;1388;0;1368;0
WireConnection;1388;2;1373;0
WireConnection;1389;0;1371;0
WireConnection;1366;0;1360;0
WireConnection;1366;1;1361;0
WireConnection;1366;2;1639;0
WireConnection;1392;0;1367;0
WireConnection;1398;0;1366;0
WireConnection;1399;0;1398;0
WireConnection;1363;0;1399;0
WireConnection;1402;0;1399;0
WireConnection;1406;0;1443;0
WireConnection;1411;0;1406;0
WireConnection;1412;0;1406;0
WireConnection;1413;0;1409;0
WireConnection;1413;2;1424;0
WireConnection;1414;0;1407;0
WireConnection;1414;2;1412;0
WireConnection;1415;0;1410;0
WireConnection;1415;2;1408;0
WireConnection;1416;0;1407;0
WireConnection;1416;2;1411;0
WireConnection;1417;0;1416;0
WireConnection;1419;0;1421;0
WireConnection;1421;0;1413;0
WireConnection;1422;0;1415;0
WireConnection;1425;0;1435;0
WireConnection;1426;0;1422;0
WireConnection;1427;0;1430;0
WireConnection;1427;1;1430;0
WireConnection;1428;0;1418;0
WireConnection;1428;1;1419;0
WireConnection;1429;0;1426;0
WireConnection;1429;1;1444;0
WireConnection;1430;0;1423;0
WireConnection;1432;0;1434;0
WireConnection;1434;0;1427;0
WireConnection;1435;0;1429;0
WireConnection;1435;1;1428;0
WireConnection;1437;0;1414;0
WireConnection;1433;0;1442;0
WireConnection;1436;0;1431;0
WireConnection;1436;1;1432;0
WireConnection;1436;2;1640;0
WireConnection;1447;0;1446;0
WireConnection;1446;0;1436;0
WireConnection;1448;0;1447;0
WireConnection;1449;0;1447;0
WireConnection;1418;1;1417;0
WireConnection;1456;0;1484;0
WireConnection;1461;0;1456;0
WireConnection;1462;0;1456;0
WireConnection;1463;0;1459;0
WireConnection;1463;2;1472;0
WireConnection;1464;0;1457;0
WireConnection;1464;2;1462;0
WireConnection;1465;0;1460;0
WireConnection;1465;2;1458;0
WireConnection;1466;0;1457;0
WireConnection;1466;2;1461;0
WireConnection;1467;0;1466;0
WireConnection;1468;0;1469;0
WireConnection;1469;0;1463;0
WireConnection;1470;0;1465;0
WireConnection;1474;0;1470;0
WireConnection;1475;0;1478;0
WireConnection;1475;1;1478;0
WireConnection;1476;0;1493;0
WireConnection;1476;1;1468;0
WireConnection;1477;0;1474;0
WireConnection;1477;1;1494;0
WireConnection;1478;0;1471;0
WireConnection;1480;0;1481;0
WireConnection;1481;0;1475;0
WireConnection;1482;0;1477;0
WireConnection;1482;1;1476;0
WireConnection;1483;0;1464;0
WireConnection;1486;0;1487;0
WireConnection;1488;0;1479;0
WireConnection;1488;1;1480;0
WireConnection;1488;2;1641;0
WireConnection;1489;0;1490;0
WireConnection;1490;0;1488;0
WireConnection;1473;0;1482;0
WireConnection;1491;0;1489;0
WireConnection;1492;0;1489;0
WireConnection;1493;1;1467;0
WireConnection;1494;1;1483;0
WireConnection;1312;0;1642;0
WireConnection;1312;1;1313;0
WireConnection;1319;0;1316;0
WireConnection;1319;1;1326;0
WireConnection;1319;2;1293;0
WireConnection;1316;1;1315;0
WireConnection;1316;2;1312;0
WireConnection;1327;0;1338;0
WireConnection;1337;0;1336;0
WireConnection;1338;0;1337;0
WireConnection;1328;0;1329;0
WireConnection;1331;0;1336;0
WireConnection;1330;0;1331;0
WireConnection;1329;0;1330;0
WireConnection;1560;0;1562;0
WireConnection;1566;0;1565;0
WireConnection;1563;0;1566;0
WireConnection;1568;0;1567;0
WireConnection;1569;0;1568;0
WireConnection;1567;0;1570;0
WireConnection;1293;0;1650;0
WireConnection;1293;1;1294;0
WireConnection;1571;0;1643;0
WireConnection;1571;1;1573;0
WireConnection;1584;0;1644;0
WireConnection;1584;1;1586;0
WireConnection;1587;0;1645;0
WireConnection;1587;1;1589;0
WireConnection;1305;0;1312;0
WireConnection;1305;1;1293;0
WireConnection;1308;0;1305;0
WireConnection;1318;0;1308;0
WireConnection;1590;0;1587;0
WireConnection;1590;1;1584;0
WireConnection;1590;2;1571;0
WireConnection;1591;0;1590;0
WireConnection;1592;0;1591;0
WireConnection;1593;1;1594;0
WireConnection;1593;2;1587;0
WireConnection;1595;0;1593;0
WireConnection;1595;1;1596;0
WireConnection;1595;2;1584;0
WireConnection;1597;0;1595;0
WireConnection;1597;1;1598;0
WireConnection;1597;2;1599;0
WireConnection;1599;0;1571;0
WireConnection;1600;0;1597;0
WireConnection;1601;0;1600;0
WireConnection;1561;0;1602;0
WireConnection;1562;0;1561;0
WireConnection;1564;0;1602;0
WireConnection;1565;0;1564;0
WireConnection;1570;0;1602;0
WireConnection;1602;0;1558;0
WireConnection;1291;0;1285;1
WireConnection;1281;0;1285;4
WireConnection;1271;0;1269;1
WireConnection;1272;0;1269;4
WireConnection;1608;0;1609;0
WireConnection;1608;2;1610;0
WireConnection;1576;0;1575;1
WireConnection;1577;0;1575;4
WireConnection;1578;0;1580;1
WireConnection;1579;0;1580;4
WireConnection;1612;0;1611;0
WireConnection;1612;2;1613;0
WireConnection;1581;0;1583;1
WireConnection;1582;0;1583;4
WireConnection;1263;0;1607;0
WireConnection;1263;1;1638;0
WireConnection;1263;2;1606;0
WireConnection;1606;0;1604;0
WireConnection;1606;1;1605;0
WireConnection;1619;0;1263;0
WireConnection;61;0;150;0
WireConnection;152;0;61;0
WireConnection;150;1;70;0
WireConnection;1617;0;1616;1
WireConnection;1618;0;1616;4
WireConnection;1207;0;1208;4
WireConnection;1216;0;1208;1
WireConnection;1205;0;1209;4
WireConnection;1215;0;1209;1
WireConnection;1195;0;1193;1
WireConnection;1196;0;1193;4
WireConnection;1217;0;1646;0
WireConnection;1217;1;1218;0
WireConnection;1229;0;1236;0
WireConnection;1229;1;1217;0
WireConnection;1229;2;1241;0
WireConnection;1232;0;1229;0
WireConnection;1241;0;1647;0
WireConnection;1241;1;1227;0
WireConnection;1242;0;1232;0
WireConnection;1252;0;1253;0
WireConnection;1256;0;1257;0
WireConnection;1253;0;1254;0
WireConnection;1248;0;1247;0
WireConnection;1247;0;1244;0
WireConnection;1244;0;1243;0
WireConnection;1244;1;1245;0
WireConnection;1244;2;1241;0
WireConnection;1240;1;1239;0
WireConnection;1240;2;1236;0
WireConnection;1243;0;1240;0
WireConnection;1243;1;1250;0
WireConnection;1243;2;1217;0
WireConnection;1251;0;1262;0
WireConnection;1261;0;1603;0
WireConnection;1262;0;1261;0
WireConnection;1236;0;1648;0
WireConnection;1236;1;1237;0
WireConnection;1629;1;1630;0
WireConnection;1629;2;1625;0
WireConnection;1625;0;1649;0
WireConnection;1625;1;1626;0
WireConnection;1323;0;1319;0
WireConnection;1324;0;1323;0
WireConnection;1495;1;1496;0
WireConnection;1495;2;1497;0
WireConnection;1550;0;1395;0
WireConnection;1549;0;1451;0
WireConnection;1396;0;1450;0
WireConnection;1396;1;1394;0
WireConnection;1396;2;1395;0
WireConnection;1351;0;1553;0
WireConnection;1351;1;1552;0
WireConnection;1351;2;1551;0
WireConnection;1351;3;1550;0
WireConnection;1351;4;1549;0
WireConnection;1351;5;1637;0
WireConnection;1351;6;1636;0
WireConnection;1346;0;1396;0
WireConnection;1346;1;1342;0
WireConnection;1346;2;1345;0
WireConnection;1348;0;1347;0
WireConnection;1347;0;1541;0
WireConnection;1347;1;1343;0
WireConnection;1347;2;1344;0
WireConnection;1541;0;1346;0
WireConnection;1541;1;1540;0
WireConnection;1541;2;1542;0
WireConnection;1551;0;1345;0
WireConnection;1552;0;1542;0
WireConnection;1553;0;1344;0
WireConnection;1349;0;1351;0
WireConnection;1450;0;1634;0
WireConnection;1450;1;1452;0
WireConnection;1450;2;1451;0
WireConnection;1634;0;1495;0
WireConnection;1634;1;1632;0
WireConnection;1634;2;1633;0
WireConnection;1635;0;1625;0
WireConnection;1631;0;1629;0
WireConnection;1636;0;1497;0
WireConnection;1637;0;1633;0
WireConnection;1254;0;1255;0
WireConnection;1255;0;1603;0
WireConnection;1603;0;1260;0
WireConnection;1639;14;1392;0
WireConnection;1640;14;1433;0
WireConnection;1641;14;1486;0
WireConnection;1642;14;1327;0
WireConnection;1643;14;1569;0
WireConnection;1644;14;1563;0
WireConnection;1645;14;1560;0
WireConnection;1646;14;1252;0
WireConnection;1647;14;1256;0
WireConnection;1648;14;1251;0
WireConnection;1649;14;1624;0
WireConnection;1650;14;1328;0
WireConnection;1209;1;1621;0
WireConnection;1193;1;1621;0
WireConnection;1269;1;1608;0
WireConnection;1285;1;1608;0
WireConnection;1575;1;1612;0
WireConnection;1580;1;1612;0
WireConnection;1583;1;1612;0
WireConnection;1616;1;1622;0
WireConnection;1382;1;1379;0
WireConnection;1391;1;1378;0
WireConnection;1444;1;1437;0
WireConnection;1208;1;1621;0
WireConnection;1259;0;1603;0
WireConnection;1258;0;1259;0
WireConnection;1257;0;1258;0
WireConnection;1638;1;1210;0
WireConnection;1651;0;896;0
WireConnection;1651;9;1073;0
ASEEND*/
//CHKSM=6B23190F9213F25E7C7786B283FCBBDF0BBEC256