Shader "YLPR/Lit"
{
    Properties
    {
        _BaseColor ("Color",Color) = (1,1,1,1)
        _BaseMap ("Texture",2D) = "white"{}
        _Cutoff ("Alpha Cutoff",Range(0.0,1.0)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness",Range(0,1)) = 0.5
        
        [Toggle(_CLIPPING)] _Clipping ("Alpha Clipping",Float) = 0
        [Toggle(_PREMULTIPLY_ALPHA)] _PremulAlpha("Premultiply Alpha", Float) = 0
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend",Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend",Float) = 1
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
        
       
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LitMode" = "YLLit"
            }
            Blend[_SrcBlend][_DstBlend]
            Zwrite[_ZWrite]
            HLSLPROGRAM
            #pragma target 3.5
            #pragma shader_feature _CLIPPING
            #pragma shader_feature _PREMULTIPLY_ALPHA
            #pragma multi_compile_instancing
            #pragma vertex LitVert
            #pragma fragment LitFrag
            
            #include "LitPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "CustomShaderGUI"
}
