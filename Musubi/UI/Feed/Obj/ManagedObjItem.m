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
//  IntroductionObjItem.m
//  musubi
//
//  Created by Ben Dodson on 5/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ManagedObjItem.h"
#import "MObj.h"

@implementation ManagedObjItem {
    NSDictionary* parsedJson;
}

@synthesize managedObj, cellClass, parsedJson;

- (id)initWithManagedObj:(MObj*)mObj cellClass:(Class)cellClassArg
{
    self = [super init];
    if (self) {
        self.managedObj = mObj;
        self.cellClass = cellClassArg;
    }
    return self;
}

- (NSDictionary *)parsedJson {
    if (parsedJson || !managedObj.json) {
        return parsedJson;
    }

    NSError* error;
    parsedJson = [NSJSONSerialization JSONObjectWithData:[managedObj.json dataUsingEncoding:NSUnicodeStringEncoding] options:0 error:&error];
    if (!parsedJson) {
        NSLog(@"Failed to parse json %@", error);
    }
    return parsedJson;
}

@end
