//
//  ShaderMain.metal
//  MeshTools
//
//  Created by Demian Nezhdanov on 01.10.2021.
//

#include <metal_stdlib>
using namespace metal;
#import "Helpers.h"
#import "Vertecies.h"
constexpr sampler sam( filter::linear, address::clamp_to_edge  );


//let tools = ["slim", "tall","head", "hips",  "waist"]



fragment float4 slim(VertexOut fragmentIn [[stage_in]],
                               constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]]) {

    float2 uv = fragmentIn.textureCoorinates;
    float2 res = float2(img.get_width(),img.get_height());

    uv.x = 1.0 - uv.x;
   float2 m = buffer.position;
   float intensity = 1.0 - buffer.intensity/3.;
    float2 po = uv;

    float center = m.x;
    
    float width =  buffer.scale.x/10.;
//    float f =
    // Перевод в локальные координаты
    po.x -= m.x;
    po.x *= intensity;
    
    float ScaleFactor = width > 0.0 ? abs(po.x) / width : 0.0;
    
//    po.x = po.x + sign(po.x) * width * (intensity - 1.0);
//    po.x *=intensity;
    if(abs(po.x) >= width){
        po.x = po.x + sign(po.x) * width * (intensity - 1.0);
    }else{
        po.x = po.x * intensity;
    }
//    po.x = abs(po.x) >= width ? po.x + sign(po.x) * width * (intensity - 1.0): po.x * intensity;
  
    
    po.x /= intensity;
    po.x += m.x;
   

   float3 color = img.sample(sam, uv ).rgb;

   
    
    // Код для отладки - вывод рамки, и центра
    if(buffer.selected){
        color = mix(float3(1.0, 0.0, 0.0), color, 0.5 + 0.5 * step(0.005, abs(width - abs(po.x - center))));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, 0.5 + 0.5 * step(0.045, abs(ScaleFactor)));
    }
//    color += col;
    return float4(color, 1.0);
   
}




fragment float4 tall(VertexOut fragmentIn [[stage_in]],
                               constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]]) {
    float2 uv = fragmentIn.textureCoorinates;
    uv.x = 1.0 - uv.x;
    float2 m = buffer.position;
//    m.y = 1.0 - buffer.position.y;

    float3 color = float3(0.0);
    
    
    
    float2 po = uv;
//    float intensity = 1.0 - buffer.intensity/3.;
    float height =  buffer.scale.y/6.;
  
//    po.y -=  m.y;
//    po.y *= intensity;
//    po.y = abs(po.y) >= height ? po.y + sign(po.y) * height * (intensity - 1.0): po.y * intensity;
//    po.y /= intensity;
//    po.y +=  m.y;
    
    color = img.sample(sam, uv ).rgb;
    
    
    if( buffer.selected){
        // Код для отладки - вывод рамки
       color = mix(float3(1.0, 0.0, 0.0), color, 0.5 + 0.5 * step(0.01, abs(height - abs(po.y - m.y))));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, 0.5 + 0.5 * step(0.08, abs(height > 0.0 ? abs(po.y) / height : 0.0)));
    }
    
    

    return float4(color, 1.0);
}





fragment float4 head(VertexOut fragmentIn [[stage_in]],
                               constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]]) {
    
    float2 uv = fragmentIn.textureCoorinates;
    uv.x = 1.0 - uv.x;
   float2 m = buffer.position;
   float intensity = abs(1.0 + buffer.intensity*2);
   float3 color = float3(0.0);
    float2 res = float2(img.get_width(),img.get_height());
    float2 po = uv - m;
    float2 scale = buffer.scale/2. + 0.0001;
    
    
    float aspect = res.y / res.x;
    
    float area = length(float2(uv.x,uv.y*aspect) - float2(m.x,m.y * aspect));
    float smooth =  buffer.smoothness;
    area = smoothstep(scale.x ,scale.x *(1.0 - smooth) , (area));
    
  
    uv-=m;
    float2 dis = uv;
    float2 dismin = uv;//Distort(uv, po, intensity/112. );
    dis /= 1. + intensity/12.;
    dismin *= 1. + intensity/12.;
    if(buffer.intensity>=0.0){
        uv = mix(uv,dis,area*abs(buffer.intensity*2.));
    }else{
        uv = mix(uv,dismin,area*abs(buffer.intensity*2.));
    }
    uv+=m;
    
    
    
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

#define M_PI 3.14159

//Настройка Фигуры - Степень
#define HIPS_POWER 2.0
//Настройка Фигуры - Форма (0.0 - волчёк, 1.0 - квадрат)
#define HIPS_FORM 0.3

//Отладочная информация
//#define DEBUG_DRAW_FRAME

//Temp code (make it uniform)
//float HalfWidth = 0.1;
//float HalfHeight = 0.1;
//float RotateAngle = 0.0;
//float StretchFactor = 1.0;
//vec2 PatternCenter = vec2(0.5, 0.5);

fragment float4 hips(VertexOut fragmentIn [[stage_in]],
                               constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]]) {
    
    float2 uv = fragmentIn.textureCoorinates;
    uv.x = 1.0 - uv.x;
   float2 m = buffer.position;
    m.x = 1.0 - m.x;
   float intensity = 1.0 + buffer.intensity*2;
   float3 color = float3(0.0);
    float2 res = float2(img.get_width(),img.get_height());
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
    color = img.sample(sam, po ).rgb;
    // Код для отладки - вывод рамки, и центра

    if(buffer.selected){
        // Код для отладки - вывод рамки
        color = mix(float3(1.0, 0.0, 0.0), color, step(0.01, abs(t - 0.98)));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, step(2.0, distance(fragmentIn.textureCoorinates*res, m * res.xy)));
    }

    
    // Вывод конечного изображения
    return float4(color, 1.0);
}




//Настройка Фигуры - Степень
#define WAIST_POWER 2.0
//Настройка Фигуры - Форма (0.0 - песочные часы, 1.0 - квадрат)
#define WAIST_FORM 0.6



fragment float4 waist(VertexOut fragmentIn [[stage_in]],
                               constant BufferData &buffer [[buffer(0)]],
                     texture2d<float, access::sample> img [[texture(1)]]) {
    
    
    
    float2 uv = fragmentIn.textureCoorinates;
    uv.x = 1.0 - uv.x;
   float2 m = buffer.position;
   float intensity = 1.0 + buffer.intensity;
   float3 color = float3(0.0);
    float2 res = float2(img.get_width(),img.get_height());
  
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

    color = img.sample(sam, po ).rgb;
    
    if(buffer.selected){
        color = mix(float3(1.0, 0.0, 0.0), color, step(0.01, abs(t - 0.98)));
        // Код для отладки - вывод центра
        color = mix(float3(0.0, 1.0, 0.0), color, step(2.0, distance(fragmentIn.textureCoorinates*res, m * res.xy)));
    }

    // Вывод конечного изображения
    return float4(color, 1.0);
}




fragment float4 final_fragment(VertexOut fragmentIn [[stage_in]],
                            
                     texture2d<float, access::sample> img [[texture(1)]]) {
    float2 uv = fragmentIn.textureCoorinates;
    uv.x = 1.0 - uv.x;

    float3 color = img.sample(sam, uv ).rgb;
    return float4(color, 1.0);
}
