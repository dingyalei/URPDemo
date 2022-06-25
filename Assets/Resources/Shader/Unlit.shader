Shader "YLPR/Unlit"
{
    Properties
    {
        _BaseColor ("Color",Color) = (1,1,1,1)
        _BaseMap ("Texture",2D) = "white"{}
        _Cutoff ("Alpha Cutoff",Range(0.0,1.0)) = 0.5
        [Toggle(_CLIPPING)] _Clipping ("Alpha Clipping",Float) = 0
        
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend",Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend",Float) = 1
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
    }
    SubShader
    {
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
    }
}
