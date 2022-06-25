#ifndef YLPR_SURFACE_INCLUDE
#define YLPR_SURFACE_INCLUDE

struct Surface
{
    float3 normal;
    float3 color;
    float alpha;
    float smoothness;
    float metallic;
};
#endif