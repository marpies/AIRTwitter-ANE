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

#import "BitmapDataUtils.h"


@implementation BitmapDataUtils

+ (UIImage*) getUIImageFromFREBitmapData:(FREBitmapData2) bitmapData {
    size_t width = bitmapData.width;
    size_t height = bitmapData.height;

    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, bitmapData.bits32, (width * height * 4), NULL );

    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo;

    if( bitmapData.hasAlpha ) {
        if( bitmapData.isPremultiplied ) {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        } else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
    } else {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    }

    CGImageRef imageRef = CGImageCreate( width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault );

    return [UIImage imageWithCGImage:imageRef];
}

@end