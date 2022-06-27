#ifndef YLPR_BASE_LIGHT_MODEL_INCLUDE
#define YLPR_BASE_LIGHT_MODEL_INCLUDE

struct VertexInput_Lambert
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct VertexOutput_Lambert
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float3 positionWS : TEXCOORD1;
};

VertexOutput_Lambert Vert_Lambert(VertexInput_Lambert v)
{
    VertexOutput_Lambert o = (VertexOutput_Lambert)0;
    o.position = UnityObjectToClipPos(v.position);
    o.positionWS = mul(unity_ObjectToWorld,v.position);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}

half4 Frag_Lambert(VertexOutput_Lambert i) :SV_Target
{
    half3 viewDirection = _WorldSpaceCameraPos.xyz - i.positionWS;
    half3 dirLightColor = GetDirectionLightLambert(_DirectionalLightCount,normalize(viewDirection),normalize(i.normal),_DirectionalLightDirections,_DirectionalLightColors);
    half4 color = half4 (_Color.rgb,1.0) * tex2D(_MainTex,i.uv);
    color.rgb *= dirLightColor;
    return color;
}

struct VertexInput_HalfLambert
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct VertexOutput_HalfLambert
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float3 positionWS : TEXCOORD1;
};

VertexOutput_HalfLambert Vert_HalfLambert(VertexInput_HalfLambert v)
{
    VertexOutput_HalfLambert o = (VertexOutput_HalfLambert)0;
    o.position = UnityObjectToClipPos(v.position);
    o.positionWS = mul(unity_ObjectToWorld,v.position);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}

half4 Frag_HalfLambert(VertexOutput_HalfLambert i) :SV_Target
{
    half3 viewDirection = _WorldSpaceCameraPos.xyz - i.positionWS;
    half3 dirLightColor = GetDirectLightHalfLambert(_DirectionalLightCount,normalize(viewDirection),normalize(i.normal),_DirectionalLightDirections,_DirectionalLightColors);
    half4 color = half4 (_Color.rgb,1.0) * tex2D(_MainTex,i.uv);
    color.rgb *= dirLightColor;
    return color;
}

struct VertexInput_Phong
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct VertexOutput_Phong
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float3 positionWS : TEXCOORD1;
};

VertexOutput_Phong Vert_Phong(VertexInput_Phong v)
{
    VertexOutput_Phong o = (VertexOutput_Phong)0;
    o.position = UnityObjectToClipPos(v.position);
    o.positionWS = mul(unity_ObjectToWorld,v.position);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}
half4 Frag_Phong(VertexOutput_Phong i) : SV_Target
{
    half3 viewDirection = _WorldSpaceCameraPos.xyz - i.positionWS;
    half3 dirLightColor = GetDirectLightPhong(_DirectionalLightCount,normalize(viewDirection),normalize(i.normal),_DirectionalLightDirections,_DirectionalLightColors);
    half4 color = half4 (_Color.rgb,1.0) * tex2D(_MainTex,i.uv);
    color.rgb *= dirLightColor;
    return color;
}

struct VertexInput_BlinnPhong
{
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct VertexOutput_BlinnPhong
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float3 positionWS : TEXCOORD1;
};

VertexOutput_BlinnPhong Vert_BlinnPhong(VertexInput_BlinnPhong v)
{
    VertexOutput_BlinnPhong o = (VertexOutput_BlinnPhong)0;
    o.position = UnityObjectToClipPos(v.position);
    o.positionWS = mul(unity_ObjectToWorld,v.position);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}
half4 Frag_BlinnPhong(VertexOutput_BlinnPhong i) : SV_Target
{
    half3 viewDirection = _WorldSpaceCameraPos.xyz - i.positionWS;
    half3 dirLightColor = GetDirectLightBlinnPhong(_DirectionalLightCount,normalize(viewDirection),normalize(i.normal),_DirectionalLightDirections,_DirectionalLightColors);
    half4 color = half4 (_Color.rgb,1.0) * tex2D(_MainTex,i.uv);
    color.rgb *= dirLightColor;
    return color;
}
#endif
