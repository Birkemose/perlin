//
//  pgeTexture3D.m
//  perlin
//
//  Created by Lars Birkemose on 29/08/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// -----------------------------------------------------------------    

#import "pgeTexture3D.h"

// -----------------------------------------------------------------    

#define MAXB 0x100

// -----------------------------------------------------------------    

@implementation pgeTexture3D {
    int                         m_textureSize;
    GLuint                      m_textureNames[ TEXTURE_3D_SIZE ];
    // noise data
    int                         m_start;
    int                         m_B;
    int                         m_BM;
    int                         m_p[ MAXB + MAXB + 2 ];
    TEXTURE_FLOAT               m_g1[ MAXB + MAXB + 2 ];
    TEXTURE_FLOAT               m_g2[ MAXB + MAXB + 2 ][ 2 ];
    TEXTURE_FLOAT               m_g3[ MAXB + MAXB + 2 ][ 3 ];
}

// -----------------------------------------------------------------    

+( pgeTexture3D* )texture3D {
    return( [ [ [ self alloc ] init ] autorelease ] );
}

// -----------------------------------------------------------------    

-( pgeTexture3D* )init {
    GLubyte* textureData;
    
    self = [ super init ];
    // initialize
    
    // calculate size of single texture
    m_textureSize = TEXTURE_3D_SIZE * TEXTURE_3D_SIZE * 4;
    
    // allocate memory
    textureData = malloc( m_textureSize * TEXTURE_3D_SIZE );
    
    // build texture noise
    [ self build3DTexture:textureData ];
    
    glGenTextures( TEXTURE_3D_SIZE, m_textureNames );
    for ( int index = 0; index < TEXTURE_3D_SIZE; index ++ ) {
        glBindTexture( GL_TEXTURE_2D, m_textureNames[ index ] );
        
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
        
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, TEXTURE_3D_SIZE, TEXTURE_3D_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, &textureData[ index * m_textureSize ] );
    }
    
    // clean up
    free( textureData );
    // done
    return( self );
}

// -----------------------------------------------------------------    

-( void )dealloc {
    // clean up

	glDeleteTextures( TEXTURE_3D_SIZE, m_textureNames );

    // done
    [ super dealloc ];
}

// -----------------------------------------------------------------    

-( GLuint )texture2D:( TEXTURE_FLOAT )z upper:( BOOL )upper {
    int index = ( int )( ( z - ( int )z ) * TEXTURE_3D_SIZE );
    if ( upper == NO ) return( m_textureNames[ index ] );
    return( m_textureNames[ ( index + 1 ) % TEXTURE_3D_SIZE ] );
}

// -----------------------------------------------------------------    
// Perlin noise stuff
// Einstein probably wrote this. Dont modify
// -----------------------------------------------------------------    

#define N 0x1000
#define NP 12   // 2^N
#define NM 0xfff

#define s_curve( t ) ( t * t * ( 3.0 - ( 2.0 * t ) ) )
#define lerp( t, a, b ) ( a + ( t * ( b - a ) ) )
#define setup( i, b0, b1, r0, r1) \
t = vec[ i ] + N; \
b0 = ( ( int )t ) & m_BM; \
b1 = ( b0 + 1 ) & m_BM; \
r0 = t - ( int )t; \
r1 = r0 - 1.0;
//#define at2( rx, ry ) ( rx * q[ 0 ] + ry * q[1] )
#define at3( rx, ry, rz ) ( rx * q[ 0 ] + ry * q[ 1 ] + rz * q[ 2 ] )

// -----------------------------------------------------------------    

-( void )normalize2:( TEXTURE_FLOAT* )v {
	TEXTURE_FLOAT s;
    
	s = sqrt( ( v[ 0 ] * v[ 0 ] ) + ( v[ 1 ] * v[ 1 ] ) );
	v[ 0 ] = v[ 0 ] / s;
	v[ 1 ] = v[ 1 ] / s;
}

// -----------------------------------------------------------------    

-( void )normalize3:( TEXTURE_FLOAT* )v {
	TEXTURE_FLOAT s;
    
	s = sqrt( ( v[ 0 ] * v[ 0 ] ) + ( v[ 1 ] * v[ 1 ] ) + ( v[ 2 ] * v[ 2 ] ) );
	v[ 0 ] = v[ 0 ] / s;
	v[ 1 ] = v[ 1 ] / s;
	v[ 2 ] = v[ 2 ] / s;
}

// -----------------------------------------------------------------    

-( void )initNoise {
    int i, j, k;
    
    srand( 22145 );
    for ( i = 0; i < m_B; i ++ ) {
        m_p[ i ] = i;
        m_g1[ i ] = ( TEXTURE_FLOAT )( ( rand( ) % ( m_B + m_B ) ) - m_B ) / m_B;
        
        for ( j = 0; j < 2; j ++ ) m_g2[ i ][ j ] = ( TEXTURE_FLOAT )( ( rand( ) % ( m_B + m_B ) ) - m_B ) / m_B;
        [ self normalize2:m_g2[ i ] ];
        
        for ( j = 0; j < 3; j ++ ) m_g3[ i ][ j ] = ( TEXTURE_FLOAT )( ( rand( ) % ( m_B + m_B ) ) - m_B ) / m_B;
        [ self normalize3:m_g3[i] ];
    }
    
    while ( --i ) {
        k = m_p[ i ];
        m_p[ i ] = m_p[ j = rand( ) % m_B ];
        m_p[ j ] = k;
    }
    
    for ( i = 0; i < ( m_B + 2 ); i ++ ) {
        m_p[ m_B + i ] = m_p[ i ];
        m_g1[ m_B + i ] = m_g1[ i ];
        for ( j = 0; j < 2; j ++ ) m_g2[ m_B + i ][ j ] = m_g2[ i ][ j ];
        for ( j = 0; j < 3; j ++ ) m_g3[ m_B + i ][ j ] = m_g3[ i ][ j ];
    }
}

// -----------------------------------------------------------------    

-( void )setNoiseFrequency:( int )frequency {
    m_start = 1;
    m_B = frequency;
    m_BM = m_B - 1;
}

// -----------------------------------------------------------------    

-( TEXTURE_FLOAT )noise3:( TEXTURE_FLOAT* )vec {
	int bx0, bx1, by0, by1, bz0, bz1, b00, b10, b01, b11;
	TEXTURE_FLOAT rx0, rx1, ry0, ry1, rz0, rz1, *q, sy, sz, a, b, c, d, t, u, v;
	int i, j;
    
	if ( m_start != 0 ) {
		m_start = 0;
		[ self initNoise ];
	}
    
	setup(0, bx0, bx1, rx0, rx1);
	setup(1, by0, by1, ry0, ry1);
	setup(2, bz0, bz1, rz0, rz1);
    
	i = m_p[ bx0 ];
	j = m_p[ bx1 ];
    
	b00 = m_p[ i + by0 ];
	b10 = m_p[ j + by0 ];
	b01 = m_p[ i + by1 ];
	b11 = m_p[ j + by1 ];
    
	t  = s_curve( rx0 );
	sy = s_curve( ry0 );
	sz = s_curve( rz0 );
    
	q = m_g3[ b00 + bz0 ]; u = at3( rx0, ry0, rz0 );
	q = m_g3[ b10 + bz0 ]; v = at3( rx1, ry0, rz0 );
	a = lerp( t, u, v );
    
	q = m_g3[ b01 + bz0 ]; u = at3( rx0, ry1, rz0 );
	q = m_g3[ b11 + bz0 ]; v = at3( rx1, ry1, rz0 );
	b = lerp( t, u, v );
	c = lerp( sy, a, b );
    
	q = m_g3[ b00 + bz1 ]; u = at3( rx0, ry0, rz1 );
	q = m_g3[ b10 + bz1 ]; v = at3( rx1, ry0, rz1 );
	a = lerp( t, u, v );
    
	q = m_g3[ b01 + bz1 ]; u = at3( rx0, ry1, rz1 );
	q = m_g3[ b11 + bz1 ]; v = at3( rx1, ry1, rz1 );
	b = lerp( t, u, v );
	d = lerp( sy, a, b );
    
	return( lerp( sz, c, d ) );
}

// -----------------------------------------------------------------    

#define AMP 0.5 // was 0.5

-( void )build3DTexture:( GLubyte* )data {
	int f, i, j, k, inc;
	int startFrequency = 4;
	int numOctaves = 4;
	TEXTURE_FLOAT ni[ 3 ];
	TEXTURE_FLOAT inci, incj, inck;
	int frequency = startFrequency;
	TEXTURE_FLOAT amp = AMP;
    int ptr;
    
	for ( f = 0, inc = 0; f < numOctaves; f ++, frequency *= 2, inc ++, amp *= AMP ) {
		[ self setNoiseFrequency:frequency ];
        ptr = 0;
		ni[ 0 ] = ni[ 1 ] = ni[ 2 ] = 0;
        
		inci = 1.0 / ( TEXTURE_3D_SIZE / frequency );
		for ( i = 0; i < TEXTURE_3D_SIZE; i ++, ni[ 0 ] += inci ) {
			incj = 1.0 / ( TEXTURE_3D_SIZE / frequency );
			for ( j = 0; j < TEXTURE_3D_SIZE; j ++, ni[ 1 ] += incj ) {
				inck = 1.0 / ( TEXTURE_3D_SIZE / frequency );
				for ( k = 0; k < TEXTURE_3D_SIZE; k ++, ni[ 2 ] += inck, ptr += 4 ) 
					data[ ptr + inc ] = ( GLubyte )( ( ( [ self noise3:ni ] + 1.0 ) * amp ) * 255.0 );
            }
		}
	}
    
    for ( i = 0; i < ( TEXTURE_3D_SIZE * TEXTURE_3D_SIZE * TEXTURE_3D_SIZE * 4 ); i += 4 ) {
        // data[ i ] = data[ i ]  + data[ i +1 ] + data[ i + 2 ] + data[ i + 3 ];
        // data[ i + 2 ] = data[ i + 2 ] + data[ i + 3 ];
        // data[ i + 3 ] = 255;
    }
}

// -----------------------------------------------------------------    

@end









































