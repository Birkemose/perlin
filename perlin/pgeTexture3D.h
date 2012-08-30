//
//  pgeTexture3D.h
//  perlin
//
//  Created by Lars Birkemose on 29/08/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// -----------------------------------------------------------------    

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------    

// must be pow 
// eats 4 * TEXTURE_3D_SIZE^3 bytes of memory
#define TEXTURE_3D_SIZE                 64             
#define TEXTURE_FLOAT                   float

// -----------------------------------------------------------------    

@interface pgeTexture3D : NSObject {

}

// -----------------------------------------------------------------    

+( pgeTexture3D* )texture3D;
-( pgeTexture3D* )init;

// returns a texture 
-( GLuint )texture2D:( TEXTURE_FLOAT )z upper:( BOOL )upper;

// -----------------------------------------------------------------    

@end





































