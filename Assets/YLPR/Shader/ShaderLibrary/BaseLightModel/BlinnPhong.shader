Shader "YLPR/BaseLightModel/BlinnPhong"
{
    Properties
    {
         _MainTex ("Texture", 2D) = "white" {}
         _Color ("Main Color",Color) = (1,1,1,1)
         _SpecularPow ("_Gloss",Range(8,256)) = 10
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
            #pragma vertex Vert_BlinnPhong;
            #pragma fragment Frag_BlinnPhong;
            #include "UnityCG.cginc"
            #include "CommonLighting.hlsl"
            #include "BaseLightModel.hlsl"
            ENDHLSL
        }
    }
}
