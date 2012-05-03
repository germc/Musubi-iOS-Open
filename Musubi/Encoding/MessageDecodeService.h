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
//  MessageDecodeService.h
//  Musubi
//
//  Created by Willem Bult on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "IdentityProvider.h"

@class PersistentModelStoreFactory, PersistentModelStore;
@class FeedManager, MusubiDeviceManager, TransportManager, AccountManager, AppManager, IdentityManager;
@class MessageDecoder;

@interface MessageDecodeService : NSObject {
    PersistentModelStoreFactory* _storeFactory;
    id<IdentityProvider> _identityProvider;
    
    NSOperationQueue* _queue;
    
    NSMutableArray* _pending;
}

@property (nonatomic) PersistentModelStoreFactory* storeFactory;
@property (nonatomic) id<IdentityProvider> identityProvider;

// List of operation threads
@property (nonatomic) NSOperationQueue* queue;

// List of objs that are pending processing
@property (atomic) NSMutableArray* pending;

- (id) initWithStoreFactory: (PersistentModelStoreFactory*) sf andIdentityProvider: (id<IdentityProvider>) ip;

@end


@interface MessageDecodeOperation : NSOperation {
    // ManagedObject is not thread-safe, ObjectID is
    NSManagedObjectID* _messageId;
    MessageDecodeService* _service;
    NSMutableArray* _dirtyFeeds;
    BOOL _success;
    
    PersistentModelStore* _store;
    MusubiDeviceManager* _deviceManager;
    IdentityManager* _identityManager;
    TransportManager* _transportManager;
    FeedManager* _feedManager;
    AccountManager* _accountManager;
    AppManager* _appManager;
    MessageDecoder* _decoder;
}

@property (nonatomic) NSManagedObjectID* messageId;
@property (nonatomic) MessageDecodeService* service;
@property (nonatomic) NSMutableArray* dirtyFeeds;
@property (nonatomic, assign) BOOL shouldRunProfilePush;
@property (nonatomic, assign) BOOL success;

@property (nonatomic) MessageDecoder* decoder;
@property (nonatomic) PersistentModelStore* store;
@property (nonatomic) MusubiDeviceManager* deviceManager;
@property (nonatomic) IdentityManager* identityManager;
@property (nonatomic) TransportManager* transportManager;
@property (nonatomic) FeedManager* feedManager;
@property (nonatomic) AccountManager* accountManager;
@property (nonatomic) AppManager* appManager;

- (id) initWithMessageId: (NSManagedObjectID*) msgId andService: (MessageDecodeService*) service;

@end


@interface MessageDecodedNotifyOperation : NSOperation
@end

