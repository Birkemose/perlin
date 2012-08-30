//
//  pgePerlinTexture.h
//  perlin
//
//  Created by Lars Birkemose on 28/08/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "pgeTexture3D.h"

// ------------------------------------------------------------

#define PERLIN_SIZE                 64
#define PERLIN_TEXTURE_2D_SIZE      ( PERLIN_SIZE * PERLIN_SIZE * 4 )
#define PERLIN_TEXTURE_3D_SIZE      ( PERLIN_TEXTURE_2D_SIZE * PERLIN_SIZE )

// ------------------------------------------------------------

@interface pgePerlinTexture : CCNode {
    
}

// ------------------------------------------------------------

@property double animationSpeed;
@property double textureScale;
@property CGPoint offset;

// ------------------------------------------------------------

+( pgePerlinTexture* )perlinTextureWithWidth:( int )width height:( int )height texture:( pgeTexture3D* )texture shader:( NSString* )shader;
-( pgePerlinTexture* )initWithWidth:( int )width height:( int )height texture:( pgeTexture3D* )texture shader:( NSString* )shader;

-( void )animate:( ccTime )dt;

// ------------------------------------------------------------

@end

















































