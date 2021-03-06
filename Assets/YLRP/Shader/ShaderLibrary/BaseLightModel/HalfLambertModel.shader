Shader "YLRP/BaseLightModel/HalfLambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" }
        LOD 100

        Pass
        {
            Tags{
                "LightMode" = "YLLit"
            }
            HLSLPROGRAM
            #pragma vertex Vert_HalfLambert;
            #pragma fragment Frag_HalfLambert;
            #include "UnityCG.cginc"
            #include "CommonLighting.hlsl"
            #include "BaseLightModel.hlsl"
            ENDHLSL
        }
    }
}
