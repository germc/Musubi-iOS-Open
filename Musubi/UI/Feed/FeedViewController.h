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
//  Created by Willem Bult on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"
#import "FriendPickerTableViewController.h"
#import "ProfileViewController.h"

@class MFeed;

@protocol FeedViewControllerDelegate
    - (void) friendsSelected:(NSArray*)selection;
@end

@interface FeedViewController : TTTableViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, FriendPickerDelegate, ProfileViewControllerDelegate> {
    MFeed* _feed;
    
    IBOutlet UIView* mainView;
    IBOutlet UIView* postView;
    IBOutlet UIButton* actionButton;
    IBOutlet TTButton* sendButton;
    IBOutlet UITextView* statusField;
    
    int lastRow;
}

- (IBAction)addPeople:(id)sender;
- (IBAction)sendMessage:(id)sender;

@property (nonatomic, retain) MFeed* feed;
@property (nonatomic, weak) id<FeedViewControllerDelegate> delegate;

@end

// FeedViewTableDelegate

@interface FeedViewTableDelegate : TTTableViewVarHeightDelegate {
    int lastRow;
}

- (void) likedAtIndexPath: (NSIndexPath*) indexPath;
- (void) profilePictureButtonPressedAtIndexPath: (NSIndexPath*) indexPath;

@end