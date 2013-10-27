//
//  hmac.c
//  OAuthConsumer
//
//  Created by Jonathan Wight on 4/8/8.
//  Copyright 2008 Jonathan Wight. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

// Implementation of HMAC-SHA1. Adapted from example at http://tools.ietf.org/html/rfc2104

#include "sha1.h"

#include <stdlib.h>
#include <string.h>

void hmac_sha1(const u_int8_t *inText, size_t inTextLength, u_int8_t* inKey, size_t inKeyLength, u_int8_t *outDigest)
{
    #define B 64
    #define L 20

    SHA1_CTX theSHA1Context;
    u_int8_t k_ipad[B + 1]; // Inner padding - key XOR'd with ipad
    u_int8_t k_opad[B + 1]; // Outer padding - key XOR'd with opad

    // If the key is longer than 64 bytes, reset it to key=SHA1(key)
    if (inKeyLength > B)
	{
        SHA1Init(&theSHA1Context);
        SHA1Update(&theSHA1Context, inKey, (u_int32_t)inKeyLength);
        SHA1Final(inKey, &theSHA1Context);
        inKeyLength = L;
	}

    // Start out by storing the key in pads
    memset(k_ipad, 0, sizeof k_ipad);
    memset(k_opad, 0, sizeof k_opad);
    memcpy(k_ipad, inKey, inKeyLength);
    memcpy(k_opad, inKey, inKeyLength);

    // XOR the key with ipad and opad values
    int i;
    for (i = 0; i < B; i++)
    {
        k_ipad[i] ^= 0x36;
        k_opad[i] ^= 0x5c;
    }

    // Perform inner SHA1
    SHA1Init(&theSHA1Context);                              // Initialize context for 1st pass
    SHA1Update(&theSHA1Context, k_ipad, B);                 // Start with inner pad
    SHA1Update(&theSHA1Context, (u_int8_t *)inText, (u_int32_t)inTextLength); // Then text of datagram
    SHA1Final((u_int8_t *)outDigest, &theSHA1Context);      // Finish up 1st pass

    // Perform outer SHA1
    SHA1Init(&theSHA1Context);                              // Initialize context for 2nd pass
    SHA1Update(&theSHA1Context, k_opad, B);                 // Start with outer pad
    SHA1Update(&theSHA1Context, (u_int8_t *)outDigest, L);  // Then results of 1st hash
    SHA1Final((u_int8_t *)outDigest, &theSHA1Context);      // Finish up 2nd pass
}
