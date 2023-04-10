//
//  Helpers.metal
//  MeshTools
//
//  Created by Demian on 02.11.21.
//

#include <metal_stdlib>
using namespace metal;


float3 blr(texture2d<float> tex, float2 uv, float rad){
     constexpr sampler sam(filter::linear);
     float3 blur = float3(0.0);
    float2 res = float2( (tex.get_width()) , (tex.get_height()) );
         float sum = 0.0;
 
         for(float u = -rad; u<=rad; u+=5){
             for(float v = -rad; v<=rad; v+=5){
 
                 float weight = rad*10. - sqrt(u * u + v * v);
                // uv + (float2(u, v)/res)
                 blur += weight * tex.sample(sam,uv + (float2(u, v)/res)).rgb;
                 sum += weight;
             }
         }
         blur /= sum;
     
    return blur;
}
float2 Distort(float2 p,  float2 d, float rad)
{
     p-=d;
    float theta  = atan2(p.y, p.x);
    float radius = length(p);
    radius = pow(radius,1.0 + rad);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    p = (p/1.0 + d);
    return  (p);
}
float line(float2 p, float2 a, float2 b,float2 res){
    float2 pa = p-a;
    float2 ba = b-a;

    float t = clamp(dot(pa, ba)/dot(ba,ba),0.,1.0);
    float2 cv = pa - ba*t;
    cv.y *= res.y/res.x;
    float d = length(cv);
    if(distance(a, b)>2.){return 2.;}else{
    return ( d);
    }
}

float2 distort(float2 p,  float2 d)
{
     p-=d;
    float theta  = atan2(p.y, p.x);
    float radius = length(p);
    radius = pow(radius,1.2);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    p = (p/1.0 + d);
    return  (p);
}


float2 dist(float2 p,  float2 d,float r)
{
     p-=d;
    float theta  = atan2(p.y, p.x);
    float radius = length(p);
    radius = pow(radius,r + 1.0);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    p = (p/1.0 + d);
    return  (p);
}
