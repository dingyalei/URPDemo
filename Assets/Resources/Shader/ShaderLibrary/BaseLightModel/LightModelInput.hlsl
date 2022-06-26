#ifndef YLPR_LIGHT_MODEL_INPUT_INCLUDE
#define YLPR_LIGHT_MODEL_INPUT_INCLUDE
#define MAX_DIRECTIONAL_LIGHT_COUNT 4
#define MAX_POINT_LIGHT_COUNT 4
#define MAX_SPOT_LIGHT_COUT 4
CBUFFER_START(UnityPerMaterial)
    uniform half4 _Color;
    uniform sampler2D _MainTex;
    uniform half _Specular;
    uniform half _Roughness;
    uniform half _Fresnel;

    uniform half4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    uniform half4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];

    uniform half4 _PointLightColors[MAX_POINT_LIGHT_COUNT];
    uniform half4 _PointLightDirections[MAX_POINT_LIGHT_COUNT];

    uniform half4 _SpotLightColors[MAX_SPOT_LIGHT_COUT];
    uniform half4 _SpotLightDirections[MAX_SPOT_LIGHT_COUT];
    uniform half4 _SpotLightPos[MAX_SPOT_LIGHT_COUT];
CBUFFER_END
#endif
