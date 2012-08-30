//
//  pgePerlinTexture.m
//  perlin
//
//  Created by Lars Birkemose on 28/08/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ------------------------------------------------------------

#import "pgePerlinTexture.h"

// ------------------------------------------------------------

@implementation pgePerlinTexture {
    CGPoint                     m_vertexCoordinate[ 4 ];
    CGPoint                     m_textureCoordinate[ 4 ];
    pgeTexture3D*               m_noiseTexture;
    CCTexture2D*                m_colorTexture;
    double                      m_animationDepth;
    // control data
    double                      m_animationSpeed;
    double                      m_textureScale;
    CGPoint                     m_offset;
    
    CCSprite*                   m_sprite;
}

// ------------------------------------------------------------

@synthesize animationSpeed = m_animationSpeed;
@synthesize textureScale = m_textureScale;
@synthesize offset = m_offset;

// ------------------------------------------------------------

+( pgePerlinTexture* )perlinTextureWithWidth:( int )width height:( int )height texture:( pgeTexture3D* )texture shader:( NSString* )shader {
    return( [ [ [ self alloc ] initWithWidth:width height:height texture:texture shader:shader ] autorelease ] );
}

// ------------------------------------------------------------

-( pgePerlinTexture* )initWithWidth:( int )width height:( int )height texture:( pgeTexture3D* )texture shader:( NSString* )shader {
    self = [ super init ];
    // initialize
    
    // set texture
    m_noiseTexture = [ texture retain ];
    m_animationDepth = 0;
    m_textureScale = 1.0;
    m_offset = CGPointZero;
    
    // coordinates
    m_vertexCoordinate[ 0 ] = ccp( 0, 0 );
    m_vertexCoordinate[ 1 ] = ccp( 0, height );
    m_vertexCoordinate[ 2 ] = ccp( width, height );
    m_vertexCoordinate[ 3 ] = ccp( width, 0 );
    
    // texture coordinates 
    m_textureCoordinate[ 0 ] = ccp( 0, 1 );
    m_textureCoordinate[ 1 ] = ccp( 0, 0 );
    m_textureCoordinate[ 2 ] = ccp( width / height, 0 );
    m_textureCoordinate[ 3 ] = ccp( width / height, 1 );
    
    // texture
    m_colorTexture = [ [ [ CCTextureCache sharedTextureCache ] addImage:@"perlin.png" ] retain ];
    
    // enable buffers
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
    // load shader
    shaderProgram_ = [ [ CCGLProgram alloc ] initWithVertexShaderFilename:@"pgePerlinShader.vsh" fragmentShaderFilename:shader ];
    [ shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position ];
    [ shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords ];
    [ shaderProgram_ link];

    // schedule update
    [ self schedule:@selector( animate: ) ];
    
    m_sprite = [ [ CCSprite spriteWithFile:@"test.png" ] retain ];
    
    // done
    return( self );
}

// ------------------------------------------------------------

-( void )dealloc {
    // clean up
    
    [ self unschedule:@selector( animate: ) ];
    
    [ m_colorTexture release ];
    [ m_noiseTexture release ];
    
    // done
    [ super dealloc ];
}

// ------------------------------------------------------------

-( void )animate:( ccTime )dt {
    m_animationDepth += ( dt * m_animationSpeed );
    while ( m_animationDepth >= 1.0 ) m_animationDepth -= 1.0;
}

// ------------------------------------------------------------

-( void )draw {
    float animationProgress;
    
    // use shader
    [ shaderProgram_ use ];
    [ shaderProgram_ updateUniforms ];
	[ shaderProgram_ setUniformForModelViewProjectionMatrix ];
   
    glDisable( GL_BLEND );

	glActiveTexture( GL_TEXTURE1 );
    glBindTexture( GL_TEXTURE_2D, [ m_noiseTexture texture2D:m_animationDepth upper:NO ] );

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

    glUniform1i( glGetUniformLocation( shaderProgram_->program_, "u_textureLower" ), 1 );

	glActiveTexture( GL_TEXTURE2 );
    glBindTexture( GL_TEXTURE_2D, [ m_noiseTexture texture2D:m_animationDepth upper:YES ] );

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

    glUniform1i( glGetUniformLocation( shaderProgram_->program_, "u_textureUpper" ), 2 );

	glActiveTexture( GL_TEXTURE3 );
    glBindTexture( GL_TEXTURE_2D, m_colorTexture.name );

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

    glUniform1i( glGetUniformLocation( shaderProgram_->program_, "u_textureColor" ), 3 );    
        
    // animationProgress
    animationProgress = ( float )( m_animationDepth * TEXTURE_3D_SIZE ) - ( int )( m_animationDepth * TEXTURE_3D_SIZE );
    glUniform1f( glGetUniformLocation( shaderProgram_->program_, "u_animationProgress"), animationProgress );
    // over all scale and offset
    glUniform1f( glGetUniformLocation( shaderProgram_->program_, "u_scale"), m_textureScale );
    glUniform2f( glGetUniformLocation( shaderProgram_->program_, "u_offset" ), m_offset.x, m_offset.y );
    
    glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, m_vertexCoordinate );
    glVertexAttribPointer( kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_textureCoordinate );
    
    // draw quad
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );

    // make Riq happy
	glActiveTexture( GL_TEXTURE0 );

}

// ------------------------------------------------------------

@end






















































