#ifndef YLPR_LIGHT_INCLUDE
#define YLPR_LIGHT_INCLUDE
#define MAX_DIRECTIONAL_LIGHT_COUNT 4
CBUFFER_START(_CustomLight)
   // float3 _DirectionalLightColor;
   // float3 _DirectionalLigthDirection;
   int _DirectionalLightCount;
   float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
   float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END
struct Light
{
   float3 color;
   float3 direction;
};

int GetDirectionLightCount()
{
   return _DirectionalLightCount;
}

Light GetDirectionalLight(int index)
{
   Light light;
   light.color = _DirectionalLightColors[index].rgb;
   light.direction = _DirectionalLightDirections[index].rgb;
   return light;
}
#endif