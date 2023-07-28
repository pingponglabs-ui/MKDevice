//
//  Retouch.metal
//  FaceBodyTools
//
//  Created by Demian Nezhdanov on 15/06/2023.
//

#include <metal_stdlib>
#import "Common.h"
using namespace metal;















fragment float4 erase_draw_frag(VertexOut fragmentIn [[stage_in]],
                            texture2d<float, access::sample> v [[texture(4)]],
                        
                             constant BufferData &values [[buffer(0)]],
                                constant bool &debug [[buffer(3)]]){
  
    
    float2 uv = fragmentIn.textureCoorinates;
    float4 vap = v.sample(sam,uv);
    float2 pm = values.pmouse;
    float2 m = values.position;
    
    float opc = values.intensity/4.;
    float dd = line(uv,pm,m,values.res);
    
    float d = smoothstep(values.scale.x/12. + 0.001,.0,dd)*opc;
    
   
    
       float4 c = float4(((d)));
  
    vap = mix(c,vap,(1.0 - d));
 
    return float4(float3( c.rgb),1.0);
}



fragment float4 first_draw_frag(VertexOut fragmentIn [[stage_in]],
                            texture2d<float, access::sample> v [[texture(4)]],
                                texture2d<float, access::sample> erase [[texture(5)]],
                             constant BufferData &values [[buffer(0)]],
                                constant bool &debug [[buffer(3)]]){
  
    
    float2 uv = fragmentIn.textureCoorinates;
    float4 vap = v.sample(sam,uv);
    float4 eraser = erase.sample(sam,uv);
    float2 pm = values.pmouse;
    float2 m = values.position;
    
    pm.y = 1.0 - pm.y;
    m.y = 1.0 - m.y;
    float opc = values.intensity;
    float dd = line(uv,pm,m,values.res);
    
    float d = smoothstep(values.scale.x/12. + 0.001,.0,dd)*opc;
    if(debug){
        d = smoothstep(values.scale.x/12. + 0.001,values.scale.x/24.,dd);
    }
   
    
       float4 c = float4(((d)));
    float3 finalColor = float3(0);
    
    vap.r = mix(c,vap,(1.0 - d)).r;
    
   
   
    return float4(float3( vap.rgb),1.0);
}



fragment float4 second_draw_frag(VertexOut fragmentIn [[stage_in]],
                          texture2d<float, access::sample> v [[texture(6)]],
                          constant BufferData &values [[buffer(0)]],
                          texture2d<float, access::sample> draw [[texture(5)]],
                                 constant bool &debug [[buffer(3)]]) {
     
        
     float2 uv = fragmentIn.textureCoorinates;
   

  
        float4 vap = v.sample(sam,uv);
    float4 d = draw.sample(sam,uv);
        float4 c = float4(0.0);
       
    float2 pm = values.pmouse;
    float2 m = values.position;
//    pm.y = 1.0 - pm.y;
//    m.y = 1.0 - m.y;
   
    
    c = float4(float3(1.0),1.0);
   float4 da = float4(0.0);
      
    if(debug){
        vap = mix(da, vap,1.0 - d);
    }else{
        vap = mix(c, vap,1.0 - d);
//        vap.g = 0.0;
    }
//     if(debug){
//      
//     }else{
//     
//         vap.g = 0.0;
//     }
    
    return float4(float3(vap.rgb),1.0);
        }










fragment float4 spot(VertexOut fragmentIn [[stage_in]],
                     constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]],
                     texture2d<float, access::sample> drw [[texture(2)]]) {

     float2 uv = fragmentIn.textureCoorinates;
     //    uv.x = 1.0 - uv.x;
//     uv.y = 1.0 - uv.y;
     float2 m = buffer.position; //m.y = 1.0 - m.y;
//     //m.x = 1.0 - m.x;
//     float intensity = abs(1.0 + buffer.intensity*2);
     float3 color = float3(0.0);
     float2 res = buffer.res;//float2(img.get_width(),img.get_height());
     float2 po = uv - m;
//     float2 scale = buffer.intensity + 0.1;

    float2 scale = buffer.scale/2. + 0.0001;


     color = img.sample(sam, uv ).rgb;
     float PatternRadius = scale.x  ;
     po.y *= res.y / res.x;
    float FadeFactor = clamp(length(po) / PatternRadius, 0.0, 1.0);
    // Код для отладки - вывод рамки, и центра
    if(buffer.selected){
    // Код для отладки - вывод рамки
        color = mix(float3(1.0, 0.0, 0.0), color, step(0.022, abs(FadeFactor - 0.95)));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, step(2.0, distance(uv*res, m * res.xy)));
    }
    //    color += float3(area);
return float4(color, 1.0);
}

fragment float4 retouch(VertexOut fragmentIn [[stage_in]],
                     constant BufferData &buffer [[buffer(0)]],
                       texture2d<float, access::sample> img [[texture(1)]],
                       texture2d<float, access::sample> drw [[texture(2)]]) {

     float2 uv = fragmentIn.textureCoorinates;
     //    uv.x = 1.0 - uv.x;
//     uv.y = 1.0 - uv.y;
     float2 m = buffer.position; //m.y = 1.0 - m.y;
//     //m.x = 1.0 - m.x;
//     float intensity = abs(1.0 + buffer.intensity*2);
     float3 color = float3(0.0);
     float2 res = buffer.res;//float2(img.get_width(),img.get_height());
     float2 po = uv - m;
//     float2 scale = buffer.intensity + 0.1;

    float2 scale = buffer.scale/2. + 0.0001;


     color = img.sample(sam, uv ).rgb;
     float PatternRadius = scale.x  ;
     po.y *= res.y / res.x;
    float FadeFactor = clamp(length(po) / PatternRadius, 0.0, 1.0);
    // Код для отладки - вывод рамки, и центра
    if(buffer.selected){
    // Код для отладки - вывод рамки
        color = mix(float3(1.0, 0.0, 0.0), color, step(0.022, abs(FadeFactor - 0.95)));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, step(2.0, distance(uv*res, m * res.xy)));
    }
    //    color += float3(area);
return float4(color, 1.0);
}
