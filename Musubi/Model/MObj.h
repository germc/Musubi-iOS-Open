/*
 * Copyright 2012 The Stanford MobiSocial Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


//
//  MObj.h
//  musubi
//
//  Created by MokaFive User on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MApp, MDevice, MEncodedMessage, MFeed, MIdentity, MLike, MObj;

@interface MObj : NSManagedObject

@property (nonatomic) BOOL deleted;
@property (nonatomic, retain) NSString * json;
@property (nonatomic, retain) NSDate* lastModified;
@property (nonatomic) BOOL processed;
@property (nonatomic, retain) NSData * raw;
@property (nonatomic) BOOL renderable;
@property (nonatomic) int64_t shortUniversalHash;
@property (nonatomic, retain) NSDate* timestamp;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSData * universalHash;
@property (nonatomic, retain) MApp *app;
@property (nonatomic, retain) MDevice *device;
@property (nonatomic, retain) MEncodedMessage *encoded;
@property (nonatomic, retain) MFeed *feed;
@property (nonatomic, retain) MIdentity *identity;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) MObj *parent;
@end

@interface MObj (CoreDataGeneratedAccessors)

- (void)addLikesObject:(MLike *)value;
- (void)removeLikesObject:(MLike *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

@end
