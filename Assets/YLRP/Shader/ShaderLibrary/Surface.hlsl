#ifndef YLRP_SURFACE_INCLUDE
#define YLRP_SURFACE_INCLUDE

struct Surface
{
    float3 position;
    float3 normal;
    float3 color;
    float alpha;
    float smoothness;
    float metallic;
    float3 viewDirection;

    float depth;

    float dither;
};
#endif