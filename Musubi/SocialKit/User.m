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
//  User.m
//  musubi
//
//  Created by Willem Bult on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize name, id, picture;

- (NSString *)description {
    return [NSString stringWithFormat:@"<User: %@, %@>", name, id];
}

- (NSDictionary *)json {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:name forKey:@"name"];
    [dict setObject:id forKey:@"id"];
    return dict;
}

@end
