//
//  Vertecies.h
//  ScnWraper
//
//  Created by Demian Nezhdanov on 04.09.2021.
//

#ifndef Vertecies_h
#define Vertecies_h




struct VertexIn {
    float2 position [[attribute(0)]];
    float2 textureCoorinates [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoorinates;
};
vertex VertexOut vertex_shader(constant VertexIn* vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]);

#endif /* Vertecies_h */
