//
//  ShaderMain.metal
//  MeshTools
//
//  Created by Demian Nezhdanov on 01.10.2021.
//

#include <metal_stdlib>
#import "Common.h"
using namespace metal;


//MARK:
float4x4 brightnessMatrix( float brightness )
{
    return float4x4( 1, 0, 0, 0,
                 0, 1, 0, 0,
                 0, 0, 1, 0,
                 brightness, brightness, brightness, 1 );
}

float4x4 contrastMatrix( float contrast )
{
    float t = ( 1.0 - contrast ) / 2.0;
    
    return float4x4( contrast, 0, 0, 0,
                 0, contrast, 0, 0,
                 0, 0, contrast, 0,
                 t, t, t, 1 );

}

float4x4 saturationMatrix( float saturation )
{
    float3 luminance = float3( 0.3086, 0.6094, 0.0820 );
    
    float oneMinusSat = 1.0 - saturation;
    
    float3 red = float3( luminance.x * oneMinusSat );
    red+= float3( saturation, 0, 0 );
    
    float3 green = float3( luminance.y * oneMinusSat );
    green += float3( 0, saturation, 0 );
    
    float3 blue = float3( luminance.z * oneMinusSat );
    blue += float3( 0, 0, saturation );
    
    return float4x4( red.r, red.g, red.b,     0,
                    green.r, green.g, green.b,     0,
                    blue.r, blue.g, blue.b,     0,
                 0, 0, 0, 1 );
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





float3 smoothskin(texture2d<float> tex, float2 uv, float r ){
     const float Y = 78.0;
     float2 res = float2(tex.get_width(),tex.get_height());
        float2 offset = float(1.0) / res.xy;
      
    float3 center_c = tex.sample(sam, uv).rgb;
    float3 sum_c = float3(0.0);
    for(int i = 0; i < 3; i++){
         float sum_i = 0.0;
        float norm = 0.0;
        for(float x = -r; x <= r; x+=1){
            
                for(float y = -r; y <= r; y+=1){
                    float2 uv2 = uv + float2(x * offset.x, y * offset.y);
                    float3 cur_c = tex.sample(sam, uv2).rgb;
//                    cur_c = highlight(cur_c, -0.5);
                float para = 1.0 - abs(center_c[i] - cur_c[i]) * 255.0 / (2.5 * Y);
                    sum_i += para * cur_c[i] * 255.0;
                norm += para;
                }
        }
        sum_c[i] = sum_i / norm;
    }
    
     return sum_c / 255.0;
}


//kernel float4 do_nothing(sampler tex, float intensityy) {
//    float2 uvD = destCoord();
//    float2 uv = samplerTransform(tex, uvD)
//    
//    
//    
//    float4 col = sample(image,uv);
//    return float4(col.r,0.0,0.0,1.0);
//}



//
//kernel float4 do_nothing(sampler tex, float r, float width,float height) {
//    float2 uvD = destCoord();
//    float2 uv = samplerTransform(tex, uvD);
//     const float Y = 78.0;
//    float2 res = float2(width, height);
//        float2 offset = float(1.0) / res.xy;
//
//    float3 center_c = sample(tex, uv).rgb;
//    float3 sum_c = float3(0.0);
//    for(int i = 0; i < 3; i++){
//         float sum_i = 0.0;
//        float norm = 0.0;
//        for(float x = -r; x <= r; x+=1){
//
//                for(float y = -r; y <= r; y+=1){
//                    float2 uv2 = uv + float2(x * offset.x, y * offset.y);
//                    float3 cur_c = sample(tex, uv2).rgb;
//                float para = 1.0 - abs(center_c[i] - cur_c[i]) * 255.0 / (2.5 * Y);
//                    sum_i += para * cur_c[i] * 255.0;
//                norm += para;
//                }
//        }
//        sum_c[i] = sum_i / norm;
//    }
//
//     return float4(sum_c / 255.0,1.0);
//}
//




float3 blur(texture2d<float> tex, float2 uv, float r){
    
     float3 blur = float3(0.0);
     float2 res = float2(tex.get_width(),tex.get_height());
         float sum = 0.0;
        //float r = rad;
         for(float u = -r; u<=r; u+=2.){
             for(float v = -r; v<=r; v+=2.){
 
                 float weight = r*10. - sqrt(u * u + v * v);
                // uv + (float2(u, v)/res)
                 blur += weight * tex.sample(sam,uv + (float2(u, v)/res)).rgb;
                 sum += weight;
             }
         }
         blur /= sum;
     
    return blur;
}




















//MARK: RESHAPE














float3 tall(float2 uv, BufferData buffer){
    
    float2 m = buffer.position; m.y = 1.0 - m.y;
    float intensity = 1.0 - buffer.intensity/3.;
     
     float2 uvSlim = uv;
     float center = m.x;
     float width =  buffer.scale.x/10.;
     uvSlim.x -= m.x;
     uvSlim.x *= intensity;
     float ScaleFactor = width > 0.0 ? abs(uvSlim.x) / width : 0.0;
     if(abs(uvSlim.x) >= width){
         uvSlim.x = uvSlim.x + sign(uvSlim.x) * width * (intensity - 1.0);
     }else{
         uvSlim.x = uvSlim.x * intensity;
     }
     uvSlim.x /= intensity;
     uvSlim.x += m.x;
    
    float debugColor = 0.0;
    if(buffer.selected){
        debugColor =  0.5 + 0.5 * step(0.005, abs(width - abs(uvSlim.x - center)));
    }
    
    return float3(uvSlim,debugColor);
}





//MARK: head
 float3 head(float2 uvs, BufferData buffer){
    
   
   float2 m = buffer.position; m.y = 1.0 - m.y;
    //m.x = 1.0 - m.x;
   float intensity = abs(1.0 + buffer.intensity*2);
   float color = float(0.0);
    float2 res = buffer.res;//float2(img.get_width(),img.get_height());
    float2 po = uvs - m;
     float2 newUV = uvs ;
    float2 scale = buffer.scale/2. + 0.0001;
    
    
    float aspect = res.y / res.x;
//    uv.x *=aspect;
    float area = length(float2(newUV.x,newUV.y*aspect) - float2(m.x,m.y * aspect));
    float smooth =  buffer.smoothness;
    area = smoothstep(scale.x ,scale.x *(1.0 - smooth) , (area));
    
  
     newUV-=m;
    
    float2 dis = newUV;
    float2 dismin = newUV;//Distort(uv, po, intensity/112. );
    dis /= 1. + intensity/1.;
    dismin *= 1. + intensity/1.;
    if(buffer.intensity>=0.0){
        newUV = mix(newUV,dis,area*abs(buffer.intensity*2.));
    }else{
        newUV = mix(newUV,dismin,area*abs(buffer.intensity*2.));
    }
//    uv.x *=aspect;
     newUV+=m;
    
    
    
   
    float PatternRadius = scale.x  ;
    po.y *= res.y / res.x;
    float FadeFactor = clamp(length(po) / PatternRadius, 0.0, 1.0);
    // Код для отладки - вывод рамки, и центра
    if(buffer.selected){
        // Код для отладки - вывод рамки
        color =  step(0.022, abs(FadeFactor - 0.95));
     
    }
//    color += float3(area);
    return float3(newUV,color);
}



//Отладочная информация
//#define DEBUG_DRAW_FRAME

//Temp code (make it uniform)
//float HalfWidth = 0.1;
//float HalfHeight = 0.1;
//float RotateAngle = 0.0;
//float StretchFactor = 1.0;
//float2 PatternCenter = float2(0.5, 0.5);
//MARK: hips
float3 hips(float2 uv, BufferData buffer){
    
    

   float2 m = buffer.position; m.y = 1.0 - m.y;
//    //m.x = 1.0 - m.x;
   float intensity = 1.0 + buffer.intensity*2;
   float color = float(0.0);
    float2 res = buffer.res;//float2(img.get_width(),img.get_height());
    float2 po = uv - m;
    po.y *= res.y / res.x;
    
    float HalfWidth = buffer.scale.x/2.;
    float HalfHeight = buffer.scale.y/2.;
    float rotation = buffer.rotation;

    //Координаты, которые будем вращать
    float2 poRotate = po;
    
    //Вращаем изображение под нужный угол
    poRotate.x = po.x * cos(-rotation) - po.y * sin(-rotation);
    poRotate.y = po.x * sin(-rotation) + po.y * cos(-rotation);
    
    //w - фактор затухания по Ширине, h - фактор затухания по высоте
    float w = clamp(abs(poRotate.x) / HalfWidth, 0.0, 1.0);
    float h = clamp(abs(poRotate.y) / HalfHeight, 0.0, 1.0);
    
    //Расчет формы, t - Фактор искажения
    float t = mix(1.0 - pow(h, HIPS_POWER), 1.0, HIPS_FORM);
    t = 1.0 - mix(clamp((t - w), 0.0, 1.0), 0.0, h);
    t =  mix(mix(0.0, 1.0, w), 1.0, t);
    //Искажение по ширине, t - Фактор искажения, StretchFactor - сила искажения
    poRotate.x /= mix(intensity, 1.0, t);
    
    //Возвращаем изначальный поворот
    po.x = poRotate.x * cos(rotation) - poRotate.y * sin(rotation);
    po.y = poRotate.x * sin(rotation) + poRotate.y * cos(rotation);
    
    //Возвращаем изначальный масштаб
    po.y *= res.x / res.y;
    
    //Прибавляем цент обратно
    po += m;

    // Выборка текстуры, на которую используется фильтр
   
    // Код для отладки - вывод рамки, и центра

    if(buffer.selected){
        // Код для отладки - вывод рамки
        color = step(0.01, abs(t - 0.98));
        // Код для отладки - вывод центра
       
    }

    
    // Вывод конечного изображения
    return float3(po,color);
}




//MARK: waist
 float3 waist(float2 uv, BufferData buffer){
    
    
  
   float2 m = buffer.position; m.y = 1.0 - m.y;
//    //m.x = 1.0 - m.x;
   float intensity = 1.0 + buffer.intensity;
   float color = float(0.0);
    float2 res = buffer.res;//float2(img.get_width(),img.get_height());
  
    float2 po = uv - m;
    
    
    float HalfWidth = buffer.scale.x/2.;
    float HalfHeight = buffer.scale.y/2.;
    float rotation = buffer.rotation;
    float CompressFactor = intensity;
    
    po.y *= res.y / res.x;
    
    //Координаты, которые будем вращать
    float2 poRotate = po;
    
    //Вращаем изображение под нужный угол
    poRotate.x = po.x * cos(-rotation) - po.y * sin(-rotation);
    poRotate.y = po.x * sin(-rotation) + po.y * cos(-rotation);
    
    //w - фактор затухания по Ширине, h - фактор затухания по высоте
    float w = clamp(abs(poRotate.x) / HalfWidth, 0.0, 1.0);
    float h = clamp(abs(poRotate.y) / HalfHeight, 0.0, 1.0);
    
    //Расчет формы, t - Фактор искажения
    float t = mix(pow(h, WAIST_POWER), 1.0, WAIST_FORM);
    t = 1.0 - mix(clamp((t - w), 0.0, 1.0), 0.0, h);
    
    //Искажение по ширине, t - Фактор искажения, CompressFactor - сила искажения
    poRotate.x *= mix(CompressFactor, 1.0, t);
    
    //Возвращаем изначальный поворот
    po.x = poRotate.x * cos(rotation) - poRotate.y * sin(rotation);
    po.y = poRotate.x * sin(rotation) + poRotate.y * cos(rotation);
    
    //Возвращаем изначальный масштаб
    po.y *= res.x / res.y;
    
    //Прибавляем цент обратно
    po += m;

  
    
    if(buffer.selected){
        color = step(0.01, abs(t - 0.98));
      
    }

    // Вывод конечного изображения
    return float3(po,color);
}






float4 sharpenFilt( texture2d<float> tex, float2 uv, float2 res, float r) {
     constexpr sampler sam(filter::linear);
  float dx = r / res.x;
  float dy = r / res.y;
  float4 sum = float4(0.0);
  sum += -1. * tex.sample(sam,uv +  float2( -1.0 * dx , 0.0 * dy));
  sum += -1. * tex.sample(sam,uv +  float2( 0.0 * dx , -1.0 * dy));
  sum += 5. * tex.sample(sam,uv + float2( 0.0 * dx , 0.0 * dy));
  sum += -1. * tex.sample(sam,uv + float2( 0.0 * dx , 1.0 * dy));
  sum += -1. * tex.sample(sam,uv +  float2( 1.0 * dx , 0.0 * dy));
  return sum;
}





float3 lookupT(float3 texColor,texture2d<float> lut, float2 uv, float intensity){
     float3 color = float3(0);
     constexpr sampler sam(filter::linear);
//     float2 uvLut = uv * 0.5 + 0.5;
    // float3 texColor = tex.sample(sam, uv).rgb;
//     float3 lutColor = lut.sample(sam, uvLut).rgb;
     float yColor = texColor.b * 63.0;
     float2 quad1 = float2(0);
     quad1.y = floor(floor(yColor) / 8.0);
     quad1.x = floor(yColor) - (quad1.y * 8.0);
     float2 quad2 = float2(0);
     quad2.y = floor(ceil(yColor) / 8.0);
     quad2.x = ceil(yColor) - (quad2.y * 8.0);
     float2 texPos1 = float2(0);
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texColor.g);
     float2 texPos2 = float2(0);
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texColor.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * texColor.g);
     float3 newColor1 = float3(0);
     float3 newColor2 = float3(0);
     newColor1 = lut.sample(sam, texPos1).rgb;
     newColor2 = lut.sample(sam, texPos2).rgb;
     float3 newColor = mix(newColor1, newColor2, fract(yColor));
    newColor =( brightnessMatrix(0.1) * float4(newColor, 1.0)).rgb;
     color = mix(texColor, newColor, intensity);
    return color;
}


float4 imageEdges(  float2 uv , texture2d<float> cam, float2 res ,float v)
{
     constexpr sampler sam(filter::linear);
    float3 TL = cam.sample(sam, uv + float2(-v, v)/ res.xy).rgb;
    float3 TM = cam.sample(sam, uv + float2(0, v)/ res.xy).rgb;
    float3 TR = cam.sample(sam, uv + float2(v, v)/ res.xy).rgb;
    
    float3 ML = cam.sample(sam, uv + float2(-v, 0)/ res.xy).rgb;
    float3 MR = cam.sample(sam, uv + float2(v, 0)/ res.xy).rgb;
    
    float3 BL = cam.sample(sam, uv + float2(-v, -v)/ res.xy).rgb;
    float3 BM = cam.sample(sam, uv + float2(0, -v)/ res.xy).rgb;
    float3 BR = cam.sample(sam, uv + float2(v, -v)/ res.xy).rgb;
                         
    float3 GradX = -TL + TR - 2.0 * ML + 2.0 * MR - BL + BR;
    float3 GradY = TL + 2.0 * TM + TR - BL - 2.0 * BM - BR;
        
    
   /* float2 gradCombo = float2(GradX.r, GradY.r) + float2(GradX.g, GradY.g) + float2(GradX.b, GradY.b);
    
    fragColor = float4(gradCombo.r, gradCombo.g, 0, 1);*/
     float4 fragColor = float4(0);
    fragColor.r = length(float2(GradX.r, GradY.r));
    fragColor.g = length(float2(GradX.g, GradY.g));
    fragColor.b = length(float2(GradX.b, GradY.b));
     return fragColor;
}





float colorDist(float3 color){
    
    float dist = 0.0;
    dist += abs(color.r - color.g);
    dist += abs(color.g - color.b);
    dist += abs(color.b - color.r);
    return dist;
}




float3 highlight(float3 color, float intensity)
{
const float a = 1.357697966704323E-01;
const float b = 1.006045552016985E+00;
const float c = 4.674339906510876E-01;
const float d = 8.029414702292208E-01;
const float e = 1.127806558508491E-01;

    float maxx = max(color.r, max(color.g, color.b));
    float minx = min(color.r, min(color.g, color.b));
    float lum = 0.5 * (maxx + minx);
    float x1 = abs(intensity);
    float x2 = lum;
    float lum_new =  lum < 0.5 ? lum : lum + a * sign(intensity) * exp(-0.5 * (((x1-b)/c)*((x1-b)/c) + ((x2-d)/e)*((x2-d)/e)));
    return color * lum_new / lum;
}
