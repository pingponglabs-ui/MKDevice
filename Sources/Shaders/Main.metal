//
//  Main.metal
//  FaceBodyTools
//
//  Created by Demian Nezhdanov on 16/06/2023.
//

#include <metal_stdlib>

#import "Common.h"

using namespace metal;





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

vertex float4 faceVert(const device packed_float3 *vertexArray [[buffer(0)]], uint vid [[vertex_id]]) {

    return float4(vertexArray[vid],1.);
}


fragment float4 faceFrag() {
  
 float3 col = float3(1.0,1.0,1.0);
     float4 color = float4(col,1.0);
     return color;
  
}
struct VertexPointOut {
    float4 position [[position]];
  
    float2 textureCoorinates;
    float pointsize[[point_size]];
};

vertex VertexPointOut vertex_points(constant VertexIn* vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]],
                                    constant float2 &img_res [[buffer(1)]],
                                    constant float &eyesSize [[buffer(2)]]) {

    VertexIn vertexData = vertexArray[vid];
    VertexPointOut vertexDataOut;
    vertexDataOut.pointsize = 42.0 *eyesSize;
    vertexDataOut.position = float4(vertexData.position.x, vertexData.position.y, 0.0, 1.0);
    return vertexDataOut;
}
fragment float4 pupils_fragment(VertexPointOut fragmentIn [[stage_in]]) {
    
    float d = length((fragmentIn.textureCoorinates ));
    float4 color = float4(1.0,d,1.0,1.0);
    
    return color;
}

fragment float4 visualizeyes(VertexOut fragmentIn [[stage_in]],
                                       texture2d<float, access::sample> img [[texture(1)]],
                                       texture2d<float, access::sample> faceImg [[texture(2)]]){
    
    
    float2 uv = fragmentIn.textureCoorinates;
    float2 faceUv = uv;
  
    
    faceUv.y = 1.0 - faceUv.y;
    faceUv /= 2.;
    
    
//    float3 color =  img.sample(sam, uv ).rgb;
    float3 color =  imageEdges(uv, img, float2(img.get_width(),img.get_height()),5).rgb;
    color *= faceImg.sample(sam, faceUv ).rgb;
//    float4 color = float4(1.0);
//    color = (brightnessMatrix(0.1)*float4(color,1.0)).rgb;
//    color = (contrastMatrix(2.0)*float4(color,1.0)).rgb;
    
    return  float4(color,1.0);
}



fragment float4 final_reshape_fragment(VertexOut fragmentIn [[stage_in]],
                                       texture2d<float, access::sample> img [[texture(1)]],
                                       texture2d<float, access::sample> filteredImage [[texture(2)]],
                                       constant BufferData &bufferHead [[buffer(0)]],
                                       constant BufferData &bufferHips [[buffer(1)]],
                                       constant BufferData &bufferWaist [[buffer(2)]]) {
        float2 uv = fragmentIn.textureCoorinates;
        float2 res = float2(img.get_width(),img.get_height());

//        uv.y = 1.0 - uv.y;

   
        float debugCol = 0.0;
        float3 headVal = 0.0;
        headVal = head(uv,bufferHead);
        uv = headVal.xy;
        debugCol += headVal.z;
        float3 hipsVal = 0.0;
        hipsVal = hips(uv,bufferHips);
        uv = hipsVal.xy;
        debugCol += hipsVal.z;
        float3 waistVal = 0.0;
        waistVal = waist(uv,bufferWaist);
        uv = waistVal.xy;
        debugCol += waistVal.z;
 
    float3 color = img.sample(sam, uv ).rgb;
    float3 colorF = filteredImage.sample(sam, uv ).rgb;
    
    
        color.r += debugCol;
    
   
//    color += col;
        return float4(color, 1.0);
   
}





fragment float4 final_fragment(VertexOut fragmentIn [[stage_in]],
                              texture2d<float, access::sample> img [[texture(1)]],
                              constant BufferData &bufferHead [[buffer(0)]],
                              constant BufferData &bufferHips [[buffer(1)]],
                              constant BufferData &bufferWaist [[buffer(2)]],
                              constant bool &debug [[buffer(13)]] ) {
    float2 uv = fragmentIn.textureCoorinates;
    float2 uvS = uv;
    uvS.y = 1.0 - uvS.y;
    
         float debugCol = 0.0;
         float3 headVal = 0.0;
         headVal = head(uv,bufferHead);
         uv = headVal.xy;
         debugCol += headVal.z;
         float3 hipsVal = 0.0;
         hipsVal = hips(uv,bufferHips);
         uv = hipsVal.xy;
         debugCol += hipsVal.z;
         float3 waistVal = 0.0;
         waistVal = waist(uv,bufferWaist);
         uv = waistVal.xy;
         debugCol += waistVal.z;
  
     float3 color = img.sample(sam, uv ).rgb;
   

    if (debug){
        color.r += debugCol;
    }
    
//    }else{
//        color.r -= drawing.g;
//    }
//
    return float4(color,1.0);
}



fragment float4 draw_fragment(VertexOut fragmentIn [[stage_in]],
//                              array<texture2d<float, access::sample>, 15> brush [[texture(12)]],
                              texture2d<float, access::sample> img [[texture(1)]],
                              texture2d<float, access::sample> smooth [[texture(2)]],
                              texture2d<float, access::sample> spot [[texture(3)]],
                              texture2d<float, access::sample> darkeye [[texture(4)]],
                              texture2d<float, access::sample> sharpen [[texture(5)]],
                              texture2d<float, access::sample> eye [[texture(6)]],
                              texture2d<float, access::sample> whitener [[texture(7)]],
                              
                              texture2d<float, access::sample> filteredImage [[texture(8)]],
                              
                              texture2d<float, access::sample> lutTex [[texture(9)]],
                              
                              
                              
                              texture2d<float, access::sample> faceWhitenerTex [[texture(10)]],
                              
                              texture2d<float, access::sample> eyesTex [[texture(11)]],
                              
                              texture2d<float, access::sample> bgTex [[texture(12)]],
                              texture2d<float, access::sample> bgMaskTex [[texture(13)]],
//
//                              texture2d<float, access::sample> eyesTexWide [[texture(12)]],
//
//                              texture2d<float, access::sample> pupilsTex [[texture(14)]],
//
//                              texture2d<float, access::sample> eyesColorTex [[texture(13)]],
//
                              
                              constant BufferData &bufferHead [[buffer(0)]],
                              constant BufferData &bufferHips [[buffer(1)]],
                              constant BufferData &bufferWaist [[buffer(2)]],
                              
                              constant BufferData &bufferSmooth [[buffer(3)]],
                              constant BufferData &bufferSpot [[buffer(4)]],
                              constant BufferData &bufferDarkeye [[buffer(5)]],
                              constant BufferData &bufferSharpen [[buffer(6)]],
                              constant BufferData &bufferEyesColor [[buffer(7)]],
                              constant BufferData &bufferWhitener [[buffer(8)]],
                              
                              constant BufferData &brightnessBuffer [[buffer(9)]],
                              constant BufferData &contrastBuffer [[buffer(10)]],
                              constant BufferData &saturationBuffer [[buffer(11)]],
                              constant BufferData &shadowsBuffer [[buffer(12)]],
                              constant BufferData &highlightsBuffer [[buffer(13)]],
                              
                              
                              
                              
                              
//                              constant BufferData &values [[buffer(14)]],
                              constant int &retouchId [[buffer(14)]],
                              constant float &lutIntensity [[buffer(15)]],
                              constant bool &debug [[buffer(16)]],
                              constant bool &faceDetected [[buffer(17)]],
                              constant int &eye_color_id [[buffer(18)]],
                              constant int &bgId [[buffer(19)]]) {
    float2 uv = fragmentIn.textureCoorinates;
    
    float2 leyeUv = uv;
    float2 reyeUv = uv;
    float2 uvS = uv;
    float2 res = float2(img.get_width(),img.get_height());
    float2 bgRes = float2(bgTex.get_width(),bgTex.get_height());
    float2 bgUv = float2(uv.x * (res.x/bgRes.x),uv.y * (res.y/bgRes.y));
    
    float bgScale = 2.0;
    if(bgRes.x < bgRes.y){
        bgScale = 1.5;
    }
    
    uvS.y = 1.0 - uvS.y;
    

         float debugCol = 0.0;
         float3 headVal = 0.0;
         headVal = head(uv,bufferHead);
         uv = headVal.xy;
         debugCol += headVal.z;
         float3 hipsVal = 0.0;
         hipsVal = hips(uv,bufferHips);
         uv = hipsVal.xy;
         debugCol += hipsVal.z;
         float3 waistVal = 0.0;
         waistVal = waist(uv,bufferWaist);
         uv = waistVal.xy;
         debugCol += waistVal.z;
    
    
     float3 color = img.sample(sam, uv ).rgb;
    
    float3 bgMask = bgTex.sample(sam,bgUv/bgScale ).rgb;
    if(bgId != 0){
        
        float3 bgC = float3(1.0,0.0,0.0);
        if(bgId == 2){
            bgC = float3(0.0,1.0,0.0);
        }else if(bgId == 3){
            bgC = float3(0.0,0.0,1.0);
        }
        
        color = mix(color, bgC,1.0-bgMask);
        
    }
     float3 colorF = filteredImage.sample(sam, uv ).rgb;
    float3 colorSh = sharpenFilt(img, uv,  bufferSharpen.res, bufferSharpen.scale.y).rgb;
     
    float smoothColor = smooth.sample(sam, uv).r;
    float spotColor = spot.sample(sam, uv).r;
    float darkeyeColor = darkeye.sample(sam, uv).r;
    float sharpenColor = sharpen.sample(sam, uv).r;
    float eyeColor = eye.sample(sam, uv).r;
    float whitenerColor = whitener.sample(sam, uv).r;
    
//    float4 drawing = float4(0);
        float3 drawing = float3(0);
    if(retouchId == 0){
        drawing.r = smoothColor;
    }else if(retouchId == 1){
        drawing.r = spotColor;
    }else if(retouchId == 2){
            drawing.r = darkeyeColor;
    }else if(retouchId == 3){
            drawing.r = sharpenColor;
    }else if(retouchId == 4){
            drawing = eyeColor;
    }else if(retouchId == 5){
            drawing = whitenerColor;
    }

    float i = img.get_width() / 1000;
    float dark = (((color.r + color.g + color.b)/3));
    float dsark = (1. - ((color.r + color.g + color.b)))/3;

//MARK: FACE Text Color
    float2 faceUv = uv;
  
    
    faceUv.y = 1.0 - faceUv.y;
    faceUv /= 2.;
    float faceWhitenerMask = blur(faceWhitenerTex, faceUv, 3).r;
//    float eyesMask = blur(eyesTex, faceUv, 2).r;
//    float eyesMaskWide = blur(eyesTexWide, faceUv, 2).r;
//    float pupils = eyesMask*eyesMaskWide;
//MARK: FACE Text Color
    
    color.rgb = mix(color.rgb, colorF  ,smoothColor * bufferSmooth.intensity/1.5) ;
    color.rgb = mix(color.rgb, colorF      ,spotColor * bufferSpot.intensity);
    color.rgb = mix(color.rgb, colorF   - dsark/12.    ,darkeyeColor * bufferDarkeye.intensity);
    color.rgb = mix(color.rgb, colorSh      ,sharpenColor * bufferSharpen.intensity);
    if (!faceDetected){
        color.rgb = mix(color.rgb, float4(highlight(color, 0.8), 1.0f).rgb * 2.0 -dsark* 2.0 ,whitenerColor * bufferWhitener.intensity );
    }else{
        color.rgb = mix(color.rgb, float4(highlight(color, 0.8), 1.0f).rgb * 2.0 -dsark* 2.0,whitenerColor * bufferWhitener.intensity * faceWhitenerMask);
    }

    
    if (debug){
        color.r += drawing.r;
    }
    
    color =  lookupT( color, lutTex,  uv, lutIntensity);
//    color += eyesMask
    if (faceDetected && (eye_color_id != 0)){
       
       
    }
    
//    float3 hlColor = color;
  
    float a = (color.r + color.g + color.b)/3;
    float sa = (color.r + color.g + color.b)/3;
    color =  ( brightnessMatrix(brightnessBuffer.intensity) * float4(color, 1.0)).rgb;
    color = ( contrastMatrix(contrastBuffer.intensity + 1) * float4(color, 1.0)).rgb;
    color = ( saturationMatrix(saturationBuffer.intensity + 1) * float4(color, 1.0)).rgb;
    if(a < pow(a+1,2)){
        color = ( brightnessMatrix(shadowsBuffer.intensity/10) * float4(color, 1.0)).rgb;
    }
    color = float4(highlight(color, highlightsBuffer.intensity*1.5), 1.0f).rgb;
    
    

    
    return float4(color,1.0);
}




