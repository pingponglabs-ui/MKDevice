//
//  Helpers.h
//  MeshTools
//
//  Created by Demian on 02.11.21.
//

#ifndef Helpers_h
#define Helpers_h
struct BufferData {

    float2 position;
    float2 scale;
    float rotation;
    float intensity;
    float topPos;
    float bottomPos;
    float leftPos;
    float rightPos;
    float2 res;
    float2 viewRes;
    float smoothness;
    bool selected;
 
};
float3 blr(metal::texture2d<float> tex, float2 uv, float rad);
float line(float2 p, float2 a, float2 b,float2 res);

float2 distort(float2 p,  float2 d);


float2 dist(float2 p,  float2 d,float r);
float2 Distort(float2 p,  float2 d, float rad);

#define pi 3.14159265359

#endif /* Helpers_h */
