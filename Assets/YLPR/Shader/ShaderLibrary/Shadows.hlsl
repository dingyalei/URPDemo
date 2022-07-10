#ifndef YLPR_SHADOWS_INCLUDED
#define YLPR_SHADOWS_INCLUDED
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl"
//如果使用的是PCF 3X3
#if defined(_DIRECTIONAL_PCF3)
//需要4个滤波样本
#define DIRECTIONAL_FILTER_SAMPLES 4
#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_3x3
#elif defined(_DIRECTIONAL_PCF5)
#define DIRECTIONAL_FILTER_SAMPLES 9
#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_5x5
#elif defined(_DIRECTIONAL_PCF7)
#define DIRECTIONAL_FILTER_SAMPLES 16
#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_7x7
#endif

#define MAX_CASCADE_COUNT 4
#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
//阴影图集
TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);

CBUFFER_START(_CustomShadows)

int _CascadeCount;
float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
//阴影转换矩阵
float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];

float4 _CascadeData[MAX_CASCADE_COUNT];
float _ShadowDistance;
float4 _ShadowDistanceFade;

float4 _ShadowAtlasSize;

CBUFFER_END

struct DirectionalShadowData
{
    float strength;
    int tileIndex;
    // normal
    float normalBias;
};

struct ShadowData
{
    int cascadeIndex;

    float strength;

    float cascadeBlend;
};


float FadedShadowStrength(float distance, float scale, float fade)
{
    return saturate((1.0 - distance * scale) * fade);
}

ShadowData GetShadowData(Surface surface)
{
    ShadowData data;
    data.cascadeIndex = 0;
    int i = 0;
    data.strength = 1.0;
    data.cascadeBlend = 1.0;
    data.strength = FadedShadowStrength(surface.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y);
    for (int i = 0; i < _CascadeCount; i++)
    {
        float4 sphere = _CascadeCullingSpheres[i];
        float distanceSqr = DistanceSquared(surface.position, sphere.xyz);
        float fade =  FadedShadowStrength(distanceSqr, _CascadeData[i].x, _ShadowDistanceFade.z);
        if (distanceSqr < sphere.w)
        {
            if (i == _CascadeCount - 1)
            {
                data.strength *= fade;
            }else
            {
                data.cascadeBlend = fade;
            }
            break;
            
        }
    }
    if (i == _CascadeCount) 
    {
        data.strength = 0.0;
    }
#if defined(_CASCADE_BLEND_DITHER)
    else if (data.cascadeBlend < surface.dither) 
    {
        i += 1;
    }
#endif
#if !defined(_CASCADE_BLEND_SOFT)
    data.cascadeBlend = 1.0;
#endif
    data.cascadeIndex = i;
    return data;
}

float SampleDirectionalShadowAtlas(float3 positionSTS)
{
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS);
}

float FilterDirectionalShadow(float3 positionSTS)
{
    #if defined(DIRECTIONAL_FILTER_SETUP)
        // 权重
        float weights[DIRECTIONAL_FILTER_SAMPLES];
        //position
        float2 positions[DIRECTIONAL_FILTER_SAMPLES];
        float4 size = _ShadowAtlasSize.yyxx;
        DIRECTIONAL_FILTER_SETUP(size, positionSTS.xy, weights, positions);
        float shadow = 0;
        for (int i = 0; i < DIRECTIONAL_FILTER_SAMPLES; i++)
        {
            //遍历所有样本得到权重和
            shadow += weights[i] * SampleDirectionalShadowAtlas(float3(positions[i].xy, positionSTS.z));
        }
        return shadow;
    #else
        return SampleDirectionalShadowAtlas(positionSTS);
    #endif
}

float GetDirectionalShadowAttenuation(DirectionalShadowData data, ShadowData global, Surface surfaceWS)
{
    #if !defined(_RECEIVE_SHADOWS)
        return 1.0;
    #endif
    //  return positionSTS;
    if (data.strength <= 0.0)
    {
        return 1.0;
    }
    float3 normalBias = surfaceWS.normal * data.normalBias * _CascadeData[global.cascadeIndex].y;
    float3 positionSTS = mul(_DirectionalShadowMatrices[data.tileIndex], float4(surfaceWS.position + normalBias, 1.0)).xyz;
    float shadow = FilterDirectionalShadow(positionSTS);
    if(global.cascadeBlend<1.0)
    {
        normalBias = surfaceWS.normal * (data.normalBias * _CascadeData[global.cascadeIndex+1].y);
        positionSTS = mul(_DirectionalShadowMatrices[data.tileIndex + 1],float4(surfaceWS.position + normalBias, 1.0)).xyz;
        shadow = lerp(FilterDirectionalShadow(positionSTS), shadow, global.cascadeBlend);
    }
    // return shadow;
    return lerp(1.0, shadow, data.strength);
}

#endif
