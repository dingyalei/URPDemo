#ifndef YLPR_SHADOWS_INCLUDED
#define YLPR_SHADOWS_INCLUDED
 
#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
//阴影图集
TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);
 
CBUFFER_START(_CustomShadows)
//阴影转换矩阵
float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

struct DirectionalShadowData
{
    float strength;
    int tileIndex;
};

float SampleDirectionalShadowAtlas(float3 positionSTS) 
{
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS);
}

float GetDirectionalShadowAttenuation(DirectionalShadowData data, Surface surfaceWS) 
{
    float3 positionSTS = mul(_DirectionalShadowMatrices[data.tileIndex],float4(surfaceWS.positon, 1.0)).xyz;
    float shadow = SampleDirectionalShadowAtlas(positionSTS);
  //  return positionSTS;
     if (data.strength <= 0.0) 
     {
         return 1.0;
     }
   // return shadow;
    return lerp(1.0, shadow, data.strength);
}


#endif