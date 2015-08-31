/**
 * Copyright 2015 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AIR.h"
#import "AIRTwitter.h"
#import "MediaSource.h"
#import "FREObjectUtils.h"
#import "BitmapDataUtils.h"

@implementation FREObjectUtils

/**
* From FREObject to Objective C
*/

+ (NSString*) getNSString:(FREObject) object {
    uint32_t length;
    const uint8_t* string;
    FREGetObjectAsUTF8( object, &length, &string );
    return [NSString stringWithUTF8String:(char*) string];
}

+ (BOOL) getBOOL:(FREObject) object {
    uint32_t result;
    FREGetObjectAsBool( object, &result );
    return result;
}

+ (int) getInt:(FREObject) object {
    int result;
    FREGetObjectAsInt32( object, &result );
    return result;
}

+ (NSArray*) getNSArray:(FREObject) object {
    uint32_t arrayLength;
    FREGetArrayLength( object, &arrayLength );

    uint32_t stringLength;
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:arrayLength];
    for( uint32_t i = 0; i < arrayLength; i++ ) {
        FREObject itemRaw;
        FREGetArrayElementAt( object, i, &itemRaw );

        /* Convert item to string. Skip with warning if not possible. */
        const uint8_t* itemString;
        if( FREGetObjectAsUTF8( itemRaw, &stringLength, &itemString ) != FRE_OK ) {
            NSLog( @"[FREObjectUtils] Could not convert FREObject to NSString at index %i", i );
            continue;
        }

        NSString* item = [NSString stringWithUTF8String:(char*) itemString];
        [mutableArray addObject:item];
    }

    return [NSArray arrayWithArray:mutableArray];
}

+ (NSDictionary*) getNSDictionary:(FREObject) object {
    uint32_t arrayLength;
    FREGetArrayLength( object, &arrayLength );

    NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];

    uint32_t stringLength;
    for( uint32_t i = 0; i < arrayLength; ) {
        FREObject keyRaw;
        FREGetArrayElementAt( object, i++, &keyRaw );
        FREObject valueRaw;
        FREGetArrayElementAt( object, i++, &valueRaw );

        const uint8_t* key;
        const uint8_t* value;
        /* Check if key conversion to NSString succeeded */
        if( FREGetObjectAsUTF8( keyRaw, &stringLength, &key ) != FRE_OK ) {
            NSLog( @"[FREObjectUtils] Could not convert object-key to NSString." );
        }
        /* If so then continue with the value */
        else if( FREGetObjectAsUTF8( valueRaw, &stringLength, &value ) != FRE_OK ) {
            NSLog( @"[FREObjectUtils] Could not convert object-value to NSString." );
        }
        /* Both conversion were successful, add to result */
        else {
            [AIR log:[NSString stringWithFormat:@"Adding object w/ %@ -> %@",
                            [NSString stringWithUTF8String:(const char*) key],
                            [NSString stringWithUTF8String:(const char*) value]
            ]];
            properties[[NSString stringWithUTF8String:(const char*) key]] = [NSString stringWithUTF8String:(const char*) value];
        }
    }

    return [NSDictionary dictionaryWithDictionary:properties];
}

+ (NSArray*) getMediaSourcesArray:(FREObject) object {
    uint32_t arrayLength;
    FREGetArrayLength( object, &arrayLength );
    
    NSMutableArray* mutableArray = [[NSMutableArray alloc] init];
    
    for( uint32_t i = 0; i < arrayLength; i++ ) {
        FREObject rawMedia;
        FREGetArrayElementAt( object, i, &rawMedia );
        MediaSource* mediaSource = [[MediaSource alloc] init];
        
        FREBitmapData2 bitmapData;
        /* Check if raw media is BitmapData or String */
        if( FREAcquireBitmapData2( rawMedia, &bitmapData ) == FRE_OK ) {
            mediaSource.image = [BitmapDataUtils getUIImageFromFREBitmapData:bitmapData];
            FREReleaseBitmapData( rawMedia );
        } else {
            mediaSource.url = [FREObjectUtils getNSString:rawMedia];
        }
        [mutableArray addObject:mediaSource];
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

+ (double) getDouble:(FREObject) object {
    double result;
    FREGetObjectAsDouble( object, &result );
    return result;
}

/**
* From Objective C to FREObject
*/

+ (FREObject) getFREObjectFromBOOL:(BOOL) value {
    FREObject result;
    FRENewObjectFromBool( (uint32_t) value, &result );
    return result;
}

+ (FREObject) getFREObjectFromNSString:(NSString*) value {
    FREObject result;
    FRENewObjectFromUTF8( [value length], (const uint8_t*) [value UTF8String], &result );
    return result;
}

+ (FREObject) getFREObjectFromNSSet:(NSSet*) set {
    FREObject result;
    if( FRE_OK != FRENewObject( (const uint8_t*) "Vector.<String>\0", 0, NULL, &result, NULL ) ) {
        [AIR log:@"Failed to init Vector.<String>"];
    }
    uint32_t index = 0;
    for( NSString* element in set ) {
        if( FRE_OK != FRESetArrayElementAt( result, index++, [self getFREObjectFromNSString:element] ) ) {
            [AIR log:[NSString stringWithFormat:@"Failed to set Vector element %@", element]];
        }
    }
    return result;
}

+ (FREObject) getFREObjectFromDouble:(double) value {
    FREObject result;
    FRENewObjectFromDouble( value, &result );
    return result;
}

@end
