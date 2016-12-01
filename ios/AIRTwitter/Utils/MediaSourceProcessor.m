/**
 * Copyright 2015-2016 Marcel Piestansky (http://marpies.com)
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

#import "AIRTwitter.h"
#import <AIRExtHelpers/MPMediaSource.h>
#import "MediaSourceProcessor.h"

@implementation MediaSourceProcessor

+ (void) process:(NSArray*) mediaSources completionHandler:(void (^)(NSArray* mediaIDs, NSString* errorMessage)) completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [AIRTwitter log:[NSString stringWithFormat:@"Writing %lu media sources to files", (unsigned long) mediaSources.count]];

        /* Create NSData array from media sources */
        NSArray* mediaData = [self createDataFromMediaSources:mediaSources];
        if( !mediaData ) {
            completionHandler( nil, @"Error creating data for upload." );
            return;
        }
        /* Upload data to Twitter */
        [self uploadData:mediaData completionHandler:completionHandler];
    });
}

+ (NSArray*) createDataFromMediaSources:(NSArray*) mediaSources {
    NSMutableArray* mediaNSDataArray = [[NSMutableArray alloc] init];
    for( uint32_t i = 0; i < mediaSources.count; i++ ) {
        MPMediaSource* media = mediaSources[i];
        NSData* data = nil;
        if( media.isImage ) {
            [AIRTwitter log:@"Creating NSData from UIImage"];
            data = UIImagePNGRepresentation(media.image);
        } else {
            [AIRTwitter log:[NSString stringWithFormat:@"Creating NSData from URL %@", media.url]];
            NSURL* imageURL = [NSURL URLWithString:media.url];
            data = [NSData dataWithContentsOfURL:imageURL];
        }
        if( data ) {
            [AIRTwitter log:@"Success creating NSData"];
            [mediaNSDataArray addObject:data];
        } else {
            [AIRTwitter log:@"Error creating NSData"];
            return nil;
        }
    }
    return [NSArray arrayWithArray:mediaNSDataArray];
}

+ (void) uploadData:(const NSArray*) mediaFiles completionHandler:(void (^)(NSArray* mediaIDs, NSString* errorMessage)) completionHandler {
    [AIRTwitter log:@"Uploading to twitter"];
    __block uint8_t mediaCounter = 0;
    __block NSMutableArray* mediaIDs = [[NSMutableArray alloc] init];
    __block NSString* uploadErrorMessage = nil;
    NSUInteger totalFiles = mediaFiles.count;
    for( uint32_t i = 0; i < totalFiles; i++ ) {
        [[[AIRTwitter sharedInstance] api] postMediaUploadData:mediaFiles[i] fileName:@"media.png" uploadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            // progress
        } successBlock:^(NSDictionary* imageDictionary, NSString* mediaID, NSInteger size) {
            [AIRTwitter log:[NSString stringWithFormat:@"Media upload success: %@", mediaID]];
            mediaCounter++;
            [mediaIDs addObject:mediaID];
            /* If finished uploading all the files */
            if( mediaCounter >= totalFiles ) {
                [AIRTwitter log:[NSString stringWithFormat:@"Finished upload (in success) of %d media files", mediaCounter]];
                /* Even though this file was uploaded successfully, there may have been an error with previous files */
                if( !uploadErrorMessage ) {
                    /* Call the completion handler with the mediaIDs array and no error message */
                    completionHandler( [NSArray arrayWithArray:mediaIDs], nil );
                } else {
                    /* Call the completion handler with error message and no mediaIDs array */
                    completionHandler( nil, uploadErrorMessage );
                }
            }
        } errorBlock:^(NSError* error) {
            uploadErrorMessage = [NSString stringWithFormat:@"Error uploading media: %@", error.localizedDescription];
            [AIRTwitter log:uploadErrorMessage];
            mediaCounter++;
            /* If finished uploading all the files */
            if( mediaCounter >= totalFiles ) {
                [AIRTwitter log:[NSString stringWithFormat:@"Finished upload (with errors) of %d media files", mediaCounter]];
                /* Call the completion handler with error message and no mediaIDs array */
                completionHandler( nil, uploadErrorMessage );
            }
        }];
    }
}

@end
