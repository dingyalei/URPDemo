#ifndef YLRP_UNLIT_PASS_INCLUDE
#define YLRP_UNLIT_PASS-INCLUDE
#include "./ShaderLibrary/Common.hlsl"

// TEXTURE2D(_BaseMap);
// SAMPLER(sampler_BaseMap);
//
// UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//
//     UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
//     UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
//     UNITY_DEFINE_INSTANCED_PROP(float,_Cutoff)
//
// UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// float3 GetEmission (float2 baseUV) 
// {
//     return GetBase(baseUV).rgb;
// }

// float2 TransformBaseUV(float2 baseUV) 
// {
//     float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
//     return baseUV * baseST.xy + baseST.zw;
// }

struct Attributes
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    float2 baseUV : VAR_BASE_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
Varyings vert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(positionWS);
    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    output.baseUV = input.baseUV * baseST.xy + baseST.zw;
    return output;
}


float4 frag(Varyings input):SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, input.baseUV);
    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseColor);
    float4 base = baseMap * baseColor;
#if defined(_CLIPPING)
    clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
#endif    
    return base;
}
#endif