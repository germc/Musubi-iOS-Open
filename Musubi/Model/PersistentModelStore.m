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
//  PersistentModelStore.m
//  Musubi
//
//  Created by Willem Bult on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersistentModelStore.h"

@implementation PersistentModelStoreFactory

@synthesize coordinator;

+ (NSURL*) pathForStoreWithName: (NSString*) name {
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    return [NSURL fileURLWithPath: [[documentsPath objectAtIndex:0] 
                                    stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.sqlite", name]]];
}

+ (void) deleteStoreWithName: (NSString*) name {
    NSURL* storePath = [PersistentModelStoreFactory pathForStoreWithName:name];
    [[NSFileManager defaultManager] removeItemAtPath:storePath.path error:NULL];
}

- (id) initWithName: (NSString*) name {
    NSURL *path = [PersistentModelStoreFactory pathForStoreWithName:name];
    return [self initWithPath: path];
}

- (id) initWithPath: (NSURL*) path {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] autorelease];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *c = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    [c addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:path options:nil error:&error];
    
    return [self initWithCoordinator:c];
}

- (id)initWithCoordinator:(NSPersistentStoreCoordinator *)c {
    self = [super init];
    if (self) {
        [self setCoordinator: c];
    }
    return self;
}

- (PersistentModelStore *) newStore {
    return [[[PersistentModelStore alloc] initWithCoordinator: coordinator] autorelease];
}

@end

@implementation PersistentModelStore

@synthesize context;

- (id) initWithCoordinator: (NSPersistentStoreCoordinator*) coordinator {
    self = [super init];
    if (self != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator: coordinator];
    }
    
    return self;
}

- (NSArray*) query: (NSPredicate*) predicate onEntity: (NSString*) entityName {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

- (NSManagedObject*) queryFirst: (NSPredicate*) predicate onEntity: (NSString*) entityName {
    NSArray* results = [self query:predicate onEntity:entityName];
    if (results.count > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSManagedObject *)createEntity: (NSString*) entityName {
    NSManagedObject* entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext: context];
    return entity;
}

- (void)save {
    NSError* err = nil;
    [context save:&err];
    
    if (err != nil) {
        @throw err;
    }
}

@end