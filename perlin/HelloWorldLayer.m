//
//  HelloWorldLayer.m
//  perlin
//
//  Created by Lars Birkemose on 28/08/12.
//  Copyright Protec Electronics 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "pgeTexture3D.h"
#import "pgePerlinTexture.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer {
    pgePerlinTexture*       m_lava;
    pgePerlinTexture*       m_clouds;
    pgePerlinTexture*       m_steam;
    pgePerlinTexture*       m_ocean;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        // **********************************************************
        // animated procedural textures
        // **********************************************************
        // create 3d texture
        
        pgeTexture3D* texture3D = [ pgeTexture3D texture3D ];
        
		// perlin lava
        m_lava = [ pgePerlinTexture perlinTextureWithWidth:4096
                                                    height:64
                                                   texture:texture3D 
                                                    shader:@"pgePerlinLava.fsh" ];
        // m_lava.position = ccp( 75, 412 );
        m_lava.position = CGPointZero;
        m_lava.animationSpeed = 0.01;
        m_lava.textureScale = 2.0;
        [ self addChild:m_lava ];

		// perlin clouds
        m_clouds = [ pgePerlinTexture perlinTextureWithWidth:400 
                                                      height:300 
                                                     texture:texture3D 
                                                      shader:@"pgePerlinClouds.fsh" ];
        m_clouds.position = ccp( 550, 56 );
        m_clouds.animationSpeed = 0.015;
        m_clouds.textureScale = 1.50;
        m_clouds.visible = NO;
        [ self addChild:m_clouds ];
        
		// perlin steam
        m_steam = [ pgePerlinTexture perlinTextureWithWidth:400 
                                                     height:300 
                                                    texture:texture3D 
                                                     shader:@"pgePerlinSteam.fsh" ];
        m_steam.position = ccp( 75, 56 );
        m_steam.animationSpeed = 0.1;
        m_steam.textureScale = 2.0;
        m_steam.visible = NO;
        [ self addChild:m_steam ];
        
		// perlin ocean
        m_ocean = [ pgePerlinTexture perlinTextureWithWidth:400 
                                                     height:300 
                                                    texture:texture3D 
                                                     shader:@"pgePerlinOcean.fsh" ];
        m_ocean.position = ccp( 550, 412 );
        m_ocean.animationSpeed = 0.2;
        m_ocean.textureScale = 0.60;
        m_ocean.visible = NO;
        [ self addChild:m_ocean ];        
        
        // animate textures
        [ self schedule:@selector( animate: ) ];
        
        // **********************************************************

        //CCSprite* sprite = [ CCSprite spriteWithTexture:texture3D.texture ];
        //sprite.anchorPoint = CGPointZero;
        //sprite.scale = 8;
        //[ self addChild:sprite ];
                
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-( void )animate:( ccTime )dt {
    m_clouds.offset = ccp( m_clouds.offset.x - ( dt * 0.015 ), m_clouds.offset.y );
    m_steam.offset = ccp( m_steam.offset.x, m_steam.offset.y + ( dt * 0.09 ) );
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
