//
//  Distort.metal
//  FaceBodyTools
//
//  Created by Demian Nezhdanov on 15/06/2023.
//

#include <metal_stdlib>
#import "Common.h"
using namespace metal;




vertex VertexOut vrtx_shader(constant FinalVertexIn* vertexArray [[buffer(12)]],
                             constant BufferData &buffer_slim [[buffer(1)]],
                                constant BufferData &buffer_tall [[buffer(2)]],
                             
                          unsigned int vid [[vertex_id]]){
    
    FinalVertexIn vertexBuffer = vertexArray[vid];
                            VertexOut vertexDataOut;

    float aspect = buffer_slim.res.x / buffer_slim.res.y;
    float aspectView = buffer_slim.viewRes.x/buffer_slim.viewRes.y;
    float viewAspect = buffer_slim.deviceScale;
    
    
    
    
    float4 pos = float4(vertexBuffer.position.x, vertexBuffer.position.y, 0.0,  vertexBuffer.position.z );
    float2 texCoord = vertexBuffer.textureCoorinates;
    
    
    
    texCoord.y = 1.0 - texCoord.y;
    vertexDataOut.position = pos;
    vertexDataOut.textureCoorinates = texCoord;
    
    return vertexDataOut;
//
//    float aE = buffer_slim.viewRes.x/buffer_slim.viewRes.y;
//    float2 offset = float2(0.0);
//
//    if(aspect < aspectView){
//        pos.x *= aspect;
//    }else{
////        aspect = buffer_slim.res.y / buffer_slim.res.x;
//        pos.y  /= aspect;
////        pos /= aspect*3;
//    }
//    pos.x /= aE;
//
//
//
//   float2 m = buffer_slim.position;
//   float slimIntensity = 1.0 + buffer_slim.intensity/3.;
//   float center = m.x;
//   float width =  buffer_slim.scale.x/5.;
//
//    m.y = 1.0 - buffer_tall.position.y*2.;
//    float intensity = 1.0 + buffer_tall.intensity/2.;
//    float height =  buffer_tall.scale.y/5.;
//
//
//    // Перевод в локальные координаты
//    pos.x+=0.5;
//    pos.x -= m.x;
//    pos.x *= slimIntensity;
//
//    if(abs(pos.x) >= width){
//        pos.x = pos.x + sign(pos.x) * width * (slimIntensity - 1.0);
//    }else{
//        pos.x = pos.x * slimIntensity;
//    }
//
//    pos.x /= slimIntensity;
//    pos.x += m.x;
//    pos.x-=0.5;
//
//
//    pos.x+=0.5;
//    pos.y -=  m.y;
//    pos.y *= intensity;
//    pos.y = abs(pos.y) >= height ? pos.y + sign(pos.y) * height * (intensity - 1.0): pos.y * intensity;
//
//    pos.x /=  1.0 + (buffer_tall.intensity/3. * height/2 );
//    pos.y /= intensity;
//    pos.y +=  m.y;
//    pos.x-=0.5;
//
//    pos.x += (buffer_tall.intensity/3. * height/2 )/2;
//    if (vertical) {
//        pos.xy /=  1.0 + (buffer_tall.intensity/2. * height/1.5 );
//    }else{
//        pos.xy /=  1.0 + (buffer_slim.intensity/2. * height/1.5 );
//    }
////    pos /= aspect/1.5;
//
    
  
}

vertex VertexOut vertex_shader(constant VertexIn* vertexArray [[buffer(0)]],
//                               texture2d<float, access::sample> drQW [[texture(17)]],
//                               constant BufferData &buffer [[buffer(1)]],
                               unsigned int vid [[vertex_id]]) {
     
     VertexIn vertexData = vertexArray[vid];
     VertexOut vertexDataOut;
    float4 pos = float4(vertexData.position.x, vertexData.position.y, 0.0, 1.0);
    float2 texcoord = vertexData.textureCoorinates.xy;
//
//    texcoord.y -= 0.5;
//    texcoord.y *= 1.0 + buffer.intensity;
//
//    texcoord.y += 0.5;
//    float2 m = buffer.position; m.y = 1.0 - m.y;
//    float intensity =  buffer.intensity;

    vertexDataOut.position = pos;
     vertexDataOut.textureCoorinates = texcoord;
    
    
        
     return vertexDataOut;
}








