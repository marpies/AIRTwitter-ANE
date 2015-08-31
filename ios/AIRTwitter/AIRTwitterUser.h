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

#import <Foundation/Foundation.h>

@interface AIRTwitterUser : NSObject

@property (nonatomic) NSString* id;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* screenName;
@property (nonatomic) NSString* createdAt;
@property (nonatomic) NSString* description;
@property (nonatomic) NSNumber* tweetsCount;
@property (nonatomic) NSNumber* favoritesCount;
@property (nonatomic) NSNumber* followersCount;
@property (nonatomic) NSNumber* friendsCount;
@property (nonatomic) NSString* profileImageURL;
@property (nonatomic) BOOL isProtected;
@property (nonatomic) BOOL isVerified;
@property (nonatomic) NSString* location;

@end