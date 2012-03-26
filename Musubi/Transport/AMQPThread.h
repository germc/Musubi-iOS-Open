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
//  AMQPThread.h
//  Musubi
//
//  Created by Willem Bult on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMQPConnectionManager, PersistentModelStoreFactory, PersistentModelStore;

@interface AMQPThread : NSThread {
    AMQPConnectionManager* connMngr;
    
    PersistentModelStoreFactory* storeFactory;
    PersistentModelStore* threadStore;
    
    int instance;
}

@property (nonatomic,retain) AMQPConnectionManager* connMngr;
@property (nonatomic,retain) PersistentModelStoreFactory* storeFactory;
@property (nonatomic,retain) PersistentModelStore* threadStore;

- (id) initWithConnectionManager:(AMQPConnectionManager *)conn storeFactory:(PersistentModelStoreFactory *)sf;

- (void) log:(NSString*) format, ...;

- (NSString*) queueNameForKey: (NSData*) key withPrefix: (NSString*) prefix;

@end