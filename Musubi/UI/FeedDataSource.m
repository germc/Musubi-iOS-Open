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
//  FeedDataSource.m
//  musubi
//
//  Created by Willem Bult on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedDataSource.h"
#import "ObjManager.h"
#import "Musubi.h"
#import "StatusObj.h"
#import "StatusObjItem.h"
#import "StatusObjItemCell.h"
#import "UnknownObjItemCell.h"
#import "ObjFactory.h"
#import "MObj.h"
#import "MIdentity.h"

#define kFeedDataSourceLoadMargin 20

@implementation FeedDataSource

- (id)initWithFeed:(MFeed *)feed {
    self = [super init];
    
    if (self) {
        dataModel = [[FeedDataModel alloc] initWithFeed:feed];
        [dataModel load:TTURLRequestCachePolicyDefault more:FALSE];
    }
    
    return self;
}

- (id<TTModel>)model {
    return dataModel;
}

- (void)tableViewDidLoadModel:(UITableView *)tableView {
    self.items = [NSMutableArray arrayWithArray:[dataModel modelItems]];
    _lastLoadedRow = self.items.count;
    return;
    
    NSArray *modelItems = [dataModel modelItems];
    NSMutableArray *updatedItems = [NSMutableArray arrayWithCapacity:modelItems.count];
    
    for (MObj* mObj in modelItems) {
        Obj* obj = [ObjFactory objFromManagedObj:mObj];
        
        id item = nil;
        if ([obj isMemberOfClass:[StatusObj class]]) {
            item = [[StatusObjItem alloc] init];
            
            [item setTitle: [mObj senderDisplay]];
            [item setTimestamp: mObj.timestamp];
            [item setText: ((StatusObj*) obj).text];
        }

        if (item != nil)
            [updatedItems addObject:item];
    }
    
    _lastLoadedRow = updatedItems.count;
    self.items = updatedItems;
}

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath {
    if ([dataModel hasMore] && indexPath.row > _lastLoadedRow - kFeedDataSourceLoadMargin) {
        [self performSelectorInBackground:@selector(loadMoreForTableView:) withObject:tableView];
    }
}
         
- (void) loadMoreForTableView: (UITableView*) tableView {
    [dataModel load:TTURLRequestCachePolicyDefault more:YES];
    [((TTTableViewVarHeightDelegate*)tableView.delegate).controller performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];     
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    
    Class cls = nil;

    if ([object isKindOfClass:[StatusObjItem class]]) {  
        cls = [StatusObjItemCell class];  
    } else {
        cls = [super tableView:tableView cellClassForObject:object];
    }
    
    return cls;
}

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {  
    cell.accessoryType = UITableViewCellAccessoryNone;  
}

@end
