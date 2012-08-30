//
//  pgePerlinShader.fsh
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

uniform sampler2D       u_textureLower;         // lower texture
uniform sampler2D       u_textureUpper;         // upper texture
uniform sampler2D       u_textureColor;         // color texture
uniform float           u_animationProgress;

varying vec2            v_texCoord;

// -----------------------------------------------------------------    

void main( ) {
    vec4 noiseVector;
    vec4 noiseVector0;
    vec4 noiseVector1; 
    float intensity;
        
    // get 3D perlin data
    noiseVector0 = texture2D( u_textureLower, v_texCoord );
    noiseVector1 = texture2D( u_textureUpper, v_texCoord );
    noiseVector = mix( noiseVector0, noiseVector1, u_animationProgress );
    
    // intensity = step( 0.5000, noiseVector.r );
    // intensity = step( 0.2500, noiseVector.g );
    // intensity = step( 0.1250, noiseVector.b );
    // intensity = step( 0.0625, noiseVector.a );
    // gl_FragColor = vec4( intensity, intensity, intensity, 1.0 );
    
    intensity = noiseVector.r;
    
    intensity = clamp( intensity, 0.0, 1.0 );
    gl_FragColor = texture2D( u_textureColor, vec2( 1.0 - intensity, 0.87 ) );
}

// -----------------------------------------------------------------    














