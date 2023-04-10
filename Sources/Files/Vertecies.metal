//
//  Vertecies.metal
//  ScnWraper
//
//  Created by Demian Nezhdanov on 04.09.2021.
//

#include <metal_stdlib>
using namespace metal;
#import "Helpers.h"
constexpr sampler sam( filter::linear );


struct VertIn {
     float2 position [[attribute(0)]];
     float2 textureCoorinates [[attribute(1)]];
};

struct VertexOut {
     float4 position [[position]];
     float2 textureCoorinates;
};
struct VertexIn {
     float3 position [[attribute(0)]];
    
     float2 textureCoorinates [[attribute(1)]];
};

struct VertOut {
     float4 position [[position]];
    float2 textureCoorinates;
     float3 color;
};

vertex VertexOut model_vertex(VertexIn vertexBuffer [[stage_in]],
                           constant BufferData &buffer_slim [[buffer(3)]],
                              constant BufferData &buffer_tall [[buffer(4)]]) {


    VertexOut vertexDataOut;
    float4 pos = float4(vertexBuffer.position.x, vertexBuffer.position.y, 0.0, 1.0);
    float2 texCoord = vertexBuffer.textureCoorinates;
    texCoord.y = 1.0 - texCoord.y;
    float aspect = buffer_slim.res.x / buffer_slim.res.y;
    float aE = buffer_slim.viewRes.x/buffer_slim.viewRes.y;
    float2 offset = float2(0.0);
    
    if(aspect < 1.0){
        pos.x *= aspect;
    }else{
        pos.y /= aspect;
    }
    pos.x /= aE;
//    if(aE < 1.0){
//        pos.x *= aE;
//    }else{
//        pos.y /= aE;
//    }
    
    
    
    //___________________________________________________________________________________________________________________
    
    
  
   float2 m = buffer_slim.position;
   float slimIntensity = 1.0 + buffer_slim.intensity/3.;
   float center = m.x;
   float width =  buffer_slim.scale.x/5.;
    
    m.y = 1.0 - buffer_tall.position.y*2.;
    float intensity = 1.0 + buffer_tall.intensity/2.;
    float height =  buffer_tall.scale.y/5.;
    
    
    // Перевод в локальные координаты
    pos.x+=0.5;
    pos.x -= m.x;
    pos.x *= slimIntensity;
    
    if(abs(pos.x) >= width){
        pos.x = pos.x + sign(pos.x) * width * (slimIntensity - 1.0);
    }else{
        pos.x = pos.x * slimIntensity;
    }
    
    pos.x /= slimIntensity;
    pos.x += m.x;
    pos.x-=0.5;
    
   
    pos.x+=0.5;
    pos.y -=  m.y;
    pos.y *= intensity;
    pos.y = abs(pos.y) >= height ? pos.y + sign(pos.y) * height * (intensity - 1.0): pos.y * intensity;
    
    pos.x /=  1.0 + (buffer_tall.intensity/3. * height/2 );
    pos.y /= intensity;
    pos.y +=  m.y;
    pos.x-=0.5;
    
    pos.x += (buffer_tall.intensity/3. * height/2 )/2;
    pos.xy /=  1.0 + (buffer_tall.intensity/2. * height/1.5 );
//    pos.xy /= 1.0 + buffer_tall.intensity/2.;
    //___________________________________________________________________________________________________________________
    
//    float intensity =  buffer_tall.intensity;
//    float3 color = float3(0.0);
//    float FirstPlane = 0.5 + buffer_tall.scale.y/3;
//    float SecondPlane = 0.5 - buffer_tall.scale.y/3;
//    float ScalePower = 1.0 - intensity/3.;
//
//    float ScaleCenter = m.y;
//    float HalfSize = abs(FirstPlane - SecondPlane) * 0.5;
//    pos.y -= ScaleCenter;
//    pos.y *= ScalePower;
//    float ScaleFactor = HalfSize > 0.0 ? abs(pos.y) / HalfSize : 0.0;
//    pos.y = abs(pos.y) >= HalfSize ? pos.y + sign(pos.y) * HalfSize * (ScalePower - 1.0): pos.y * ScalePower;
//    pos.y /= ScalePower;
//    pos.y += ScaleCenter;
//
    
    //___________________________________________________________________________________________________________________
    
    
    
    
    
    vertexDataOut.position = pos;
    vertexDataOut.textureCoorinates = texCoord;
     return vertexDataOut;
}



vertex VertexOut vertex_shader(constant VertIn* vertexArray [[buffer(0)]],
                               texture2d<float, access::sample> drQW [[texture(17)]],
                               constant BufferData &buffer [[buffer(1)]],
                               unsigned int vid [[vertex_id]]) {
     
     VertIn vertexData = vertexArray[vid];
     VertexOut vertexDataOut;
    float4 pos = float4(vertexData.position.x, vertexData.position.y, 0.0, 1.0);
    float2 texcoord = vertexData.textureCoorinates.xy;
//
//    texcoord.y -= 0.5;
//    texcoord.y *= 1.0 + buffer.intensity;
//
//    texcoord.y += 0.5;
    float2 m = buffer.position;
    float intensity =  buffer.intensity;
//    float3 color = float3(0.0);
//     float FirstPlane = 0.55;
//     float SecondPlane = 0.45;
//     float ScalePower = 1.0 - intensity/3.;
//     float2 po = pos.xy;
//     float ScaleCenter = m.y;
//     float HalfSize = abs(FirstPlane - SecondPlane) * 0.5;
//     po.y -= ScaleCenter;
//     po.y *= ScalePower;
//     float ScaleFactor = HalfSize > 0.0 ? abs(po.y) / HalfSize : 0.0;
//     po.y = abs(po.y) >= HalfSize ? po.y + sign(po.y) * HalfSize * (ScalePower - 1.0): po.y * ScalePower;
//     po.y /= ScalePower;
//     po.y += ScaleCenter;
//     po.y *= 1.0 + intensity/12;
//    
    
//    pos.xy = po;
    vertexDataOut.position = pos;
     vertexDataOut.textureCoorinates = texcoord;
    
    
    	
     return vertexDataOut;
}


vertex VertexOut vertex_final_shader(constant VertexIn* vertexArray [[buffer(0)]],
                               texture2d<float, access::sample> drQW [[texture(17)]],
                               unsigned int vid [[vertex_id]]) {
     
     VertexIn vertexData = vertexArray[vid];
     VertexOut vertexDataOut;
    float4 pos = float4(vertexData.position.x, vertexData.position.y, 0.0, 1.0);
    float2 texcoord = vertexData.textureCoorinates.xy;

//    pos.xy += dcol;
    
    vertexDataOut.position = pos;
     vertexDataOut.textureCoorinates = texcoord;
    
    
        
     return vertexDataOut;
}

