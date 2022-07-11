#ifndef YLRP_LIGHT_INCLUDE
#define YLRP_LIGHT_INCLUDE
#define MAX_DIRECTIONAL_LIGHT_COUNT 4
CBUFFER_START(_CustomLight)
   int _DirectionalLightCount;
   float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
   float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
   float4 _DirectionalLightShadowData[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END


struct Light
{
   float3 color;
   float3 direction;
   float attenuation;
};

int GetDirectionLightCount()
{
   return _DirectionalLightCount;
}

DirectionalShadowData GetDirectionalShadowData(int lightIndex,ShadowData shadowdata)
{
   DirectionalShadowData data;
   data.strength = _DirectionalLightShadowData[lightIndex].x * shadowdata.strength;
   data.tileIndex = _DirectionalLightShadowData[lightIndex].y + shadowdata.cascadeIndex;
   data.normalBias =  _DirectionalLightShadowData[lightIndex].z;
   return data;
}

Light GetDirectionalLight(int index,Surface surface,ShadowData shadowData)
{
   Light light;
   light.color = _DirectionalLightColors[index].rgb;
   light.direction = _DirectionalLightDirections[index].rgb;
   DirectionalShadowData data = GetDirectionalShadowData(index,shadowData);
   light.attenuation = GetDirectionalShadowAttenuation(data,shadowData,surface);
   return light;
}


#endif