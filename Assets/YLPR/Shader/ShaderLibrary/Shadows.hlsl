#ifndef YLPR_SHADOWS_INCLUDED
#define YLPR_SHADOWS_INCLUDED

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
    data.strength = FadedShadowStrength(surface.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y);
    for (int i = 0; i < _CascadeCount; i++)
    {
        float4 sphere = _CascadeCullingSpheres[i];
        float distanceSqr = DistanceSquared(surface.positon, sphere.xyz);
        if (distanceSqr < sphere.w)
        {
            if (i == _CascadeCount - 1)
            {
                data.strength *= FadedShadowStrength(distanceSqr, _CascadeData[i].x, _ShadowDistanceFade.z);
            }
            break;
        }
    }
    //data.strength =FadedShadowStrength(surface.depth,_ShadowDistanceFade.x,_ShadowDistanceFade.y);
    data.cascadeIndex = i;
    return data;
}

float SampleDirectionalShadowAtlas(float3 positionSTS)
{
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS);
}


float GetDirectionalShadowAttenuation(DirectionalShadowData data, ShadowData global, Surface surfaceWS)
{
    //  return positionSTS;
    if (data.strength <= 0.0)
    {
        return 1.0;
    }
    float3 normalBias = surfaceWS.normal * data.normalBias * _CascadeData[global.cascadeIndex].y;

    float3 positionSTS = mul(_DirectionalShadowMatrices[data.tileIndex], float4(surfaceWS.positon + normalBias, 1.0)).xyz;
    float shadow = SampleDirectionalShadowAtlas(positionSTS);
    // return shadow;
    return lerp(1.0, shadow, data.strength);
}

#endif
