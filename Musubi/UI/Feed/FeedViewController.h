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
//  FeedViewController.h
//  musubi
//
//  Created by Willem Bult on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@class MFeed, FeedManager, ObjManager, ObjRenderer;

@interface FeedViewController : TTTableViewController<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate, UIActionSheetDelegate> {
    
    MFeed* feed;
    FeedManager* feedManager;
    ObjManager* objManager;
    
    NSArray* objs;
    NSMutableDictionary* objViews;
    NSMutableDictionary* cellHeights;
    ObjRenderer* objRenderer;
    
    IBOutlet UITextField* updateField;
    IBOutlet UIView* postView;
    IBOutlet UIView* mainView;
//    IBOutlet UITableView* tableView;
}

@property (nonatomic) MFeed* feed;
@property (nonatomic) FeedManager* feedManager;
@property (nonatomic) ObjManager* objManager;
@property (nonatomic) ObjRenderer* objRenderer;
@property (nonatomic) NSArray* objs;
@property (nonatomic) NSMutableDictionary* objViews;
@property (nonatomic) NSMutableDictionary* cellHeights;

- (IBAction)commandButtonPushed: (id) sender;

@end
