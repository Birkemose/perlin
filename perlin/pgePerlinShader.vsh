//
//  pgePerlinShader.vsh
//  Tankimals
//
//  Created by Lars Birkemose on 13/06/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// -----------------------------------------------------------------    

precision highp float;
precision highp int;
precision highp sampler2D;

// -----------------------------------------------------------------    

attribute vec4          a_position;
attribute vec2          a_texCoord;

uniform mat4            u_MVPMatrix;
uniform float           u_scale;                
uniform vec2            u_offset;

varying vec2            v_texCoord;

// -----------------------------------------------------------------    

void main( ) {
    
    gl_Position = u_MVPMatrix * a_position;
    v_texCoord = ( vec2( a_texCoord ) * ( 1.0 / u_scale ) ) + u_offset;

}

// -----------------------------------------------------------------    














