Shader "YLRP/Unlit"
{
	Properties
	{
		//_BaseColor ("Color",Color) = (1,1,1,1)
		_BaseMap ("Texture",2D) = "white"{}
		_Cutoff ("Alpha Cutoff",Range(0.0,1.0)) = 0.5
		[Toggle(_CLIPPING)] _Clipping ("Alpha Clipping",Float) = 0


		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend",Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend",Float) = 1
		[Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1

		[HDR] _BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		HLSLINCLUDE
		#include "./ShaderLibrary/Common.hlsl"
		#include "LitInput.hlsl"
		ENDHLSL
		Pass
		{
			Blend[_SrcBlend][_DstBlend]
			Zwrite[_ZWrite]
			HLSLPROGRAM
			#pragma shader_feature _CLIPPING
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			#include "UnitPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Tags
			{
				"LightMode" = "Meta"
			}

			Cull Off

			HLSLPROGRAM
			#pragma target 3.5
			#pragma vertex MetaPassVertex
			#pragma fragment MetaPassFragment
			#include "MetaPass.hlsl"
			ENDHLSL
		}
	}
}