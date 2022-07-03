#ifndef YLPR_LIGHT_INCLUDE
#define YLPR_LIGHT_INCLUDE
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

DirectionalShadowData GetDirectionalShadowData(int lightIndex)
{
   DirectionalShadowData data;
   data.strength = _DirectionalLightShadowData[lightIndex].x;
   data.tileIndex = _DirectionalLightShadowData[lightIndex].y;
   return data;
}

Light GetDirectionalLight(int index,Surface surface)
{
   Light light;
   light.color = _DirectionalLightColors[index].rgb;
   light.direction = _DirectionalLightDirections[index].rgb;
   DirectionalShadowData data = GetDirectionalShadowData(index);
   light.attenuation = GetDirectionalShadowAttenuation(data,surface);
   return light;
}


#endif