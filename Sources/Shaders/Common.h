//
//  Common.h
//  FaceBodyTools
//
//  Created by Demian Nezhdanov on 15/06/2023.
//

#ifndef Common_h
#define Common_h
using namespace metal;



constexpr metal::sampler sam( metal::filter::linear, metal::address::clamp_to_edge  );


struct BufferData {

    float2 position;
    float2 pmouse;
    float2 scale;
    float rotation;
    float intensity;
    float2 res;
    float2 viewRes;
    float smoothness;
    bool selected;
    float deviceScale;
    bool isHorisontal;
};




struct FinalVertexIn {
     float3 position [[attribute(0)]];
     float2 textureCoorinates [[attribute(1)]];
};


struct VertexIn {
     float2 position [[attribute(0)]];
     float2 textureCoorinates [[attribute(1)]];
};

struct VertexOut {
     float4 position [[position]];
     float2 textureCoorinates;
};


float line(float2 p, float2 a, float2 b,float2 res);
float4x4 contrastMatrix( float contrast );
float4x4 saturationMatrix( float saturation );
float4x4 brightnessMatrix( float brightness );
//float3 smoothskin(texture2d<float> tex, float2 uv, float r  , float steps);
float3 smoothskin(texture2d<float> tex, float2 uv, float r );
float4 sharpenFilt(texture2d<float> tex, float2 uv, float2 res, float r);
//Настройка Фигуры - Степень
#define WAIST_POWER 2.0
//Настройка Фигуры - Форма (0.0 - песочные часы, 1.0 - квадрат)
#define WAIST_FORM 0.6
#define M_PI 3.14159

//Настройка Фигуры - Степень
#define HIPS_POWER 2.0
//Настройка Фигуры - Форма (0.0 - волчёк, 1.0 - квадрат)
#define HIPS_FORM 0.3







float3 waist(float2 uv, BufferData buffer);
float3 hips(float2 uv, BufferData buffer);
float3 head(float2 uvs, BufferData buffer);
float3 tall(float2 uv, BufferData buffer);
float3 blur(texture2d<float> tex, float2 uv, float r);
float3 lookupT(float3 texColor,texture2d<float> lut, float2 uv, float intensity);
float4 imageEdges(  float2 uv , texture2d<float> cam, float2 res, float v);
float colorDist(float3 color);

float3 highlight(float3 color, float intensity);
#endif /* Common_h */
