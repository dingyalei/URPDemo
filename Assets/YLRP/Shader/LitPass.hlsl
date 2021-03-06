#ifndef YLRP_LIT_PASS_INCLUDE
#define YLRP_LIT_PASS_INCLUDE
//#include "./ShaderLibrary/Common.hlsl"
#include "./ShaderLibrary/Surface.hlsl"
#include "./ShaderLibrary/Shadows.hlsl"
#include "./ShaderLibrary/Light.hlsl"
#include "./ShaderLibrary/BRDF.hlsl"
#include "./ShaderLibrary/GI.hlsl"
#include "./ShaderLibrary/Lighting.hlsl"

//
// TEXTURE2D(_BaseMap);
// SAMPLER(sampler_BaseMap);
//
// UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//
//     UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
//     UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
//     UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
//     UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
//     UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
// UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct Attributes
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    float3 normalOS : NORMAL;
    GI_ATTRIBUTE_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    float2 baseUV : VAR_BASE_UV;
    float3 normalWS : VAR_NORMAL;
    float3 positionWS : VAR_POSITION;
    GI_VARYINGS_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
Varyings LitVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    TRANSFER_GI_DATA(input, output);
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    output.baseUV = TransformBaseUV(input.baseUV);
    return output;
}
    

float4 LitFrag(Varyings input):SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    Surface surface;
    // float meta = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic);
    // float smooth = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, input.baseUV);
    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseColor);
    float4 base = GetBase(input.baseUV);
    #if defined(_CLIPPING)
    clip(base.a - GetCutoff(input.baseUV));
    #endif
    surface.position = input.positionWS;
    surface.normal = normalize(input.normalWS);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    surface.depth = -TransformWorldToView(input.positionWS).z;
    surface.color = base.rgb;
    surface.alpha = base.a;
    surface.metallic =  GetMetallic(input.baseUV);
    surface.smoothness =  GetSmoothness(input.baseUV);
    surface.dither = InterleavedGradientNoise(input.positionCS.xy, 0);
#if defined (_PREMULTIPLY_ALPHA)    
    BRDF brdf = GetBRDF(surface,true);
#else
    BRDF brdf = GetBRDF(surface);
#endif
    GI gi = GetGI(GI_FRAGMENT_DATA(input),surface);
    float3 color = GetLighting(surface,brdf,gi);
    color += GetEmission(input.baseUV);
    return float4(color,1.0);
}
#endif