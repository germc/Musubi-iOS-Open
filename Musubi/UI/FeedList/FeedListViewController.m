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
//  FeedListViewController.m
//  musubi
//
//  Created by Willem Bult on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedListViewController.h"
#import "FeedManager.h"
#import "Musubi.h"
#import "MFeed.h"
#import "MIdentity.h"
#import "FeedViewController.h"
#import "FeedListDataSource.h"
#import "PersistentModelStore.h"
#import "MessageDecodeService.h"
#import "ObjPipelineService.h"
#import "MObj.h"
#import "AppDelegate.h"

@implementation FeedListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    incomingLabel = [[UILabel alloc] init];
    incomingLabel.font = [UIFont systemFontOfSize: 13.0];
    incomingLabel.text = @"";
//    incomingLabel.backgroundColor = [UIColor colorWithRed:78.0/256.0 green:137.0/256.0 blue:236.0/256.0 alpha:1];
    incomingLabel.backgroundColor = [UIColor colorWithRed:180.0/256.0 green:180.0/256.0 blue:180.0/256.0 alpha:1];
    incomingLabel.textColor = [UIColor whiteColor];
    
    waitingForTransportListener = YES;
    
    self.variableHeightRows = YES;
    
    
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(feedUpdated:) name:kMusubiNotificationUpdatedFeed object:nil];
    
    // We only need to know when a message starts getting decrypted, when it is completely processed
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(updatePending:) name:kMusubiNotificationAppOpened object:nil];
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(updatePending:) name:kMusubiNotificationTransportListenerWaitingForMessages object:nil];
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(updatePending:) name:kMusubiNotificationMessageDecodeStarted object:nil];
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(updatePending:) name:kMusubiNotificationMessageDecodeFinished object:nil];
    [[Musubi sharedInstance].notificationCenter addObserver:self selector:@selector(updatePending:) name:kMusubiNotificationUpdatedFeed object:nil];
}


- (void)createModel {
    self.dataSource = [[FeedListDataSource alloc] init];
}

- (id<UITableViewDelegate>)createDelegate {    
    return [[TTTableViewPlainVarHeightDelegate alloc]
            initWithController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [incomingLabel removeFromSuperview];
    [self.view addSubview:incomingLabel];
    [self updatePending:nil];

    // Cardinal
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:164.0/256.0 green:0 blue:29.0/256.0 alpha:1];
}

- (void)updatePending: (NSNotification*) notification {
    if ([notification.name isEqualToString:kMusubiNotificationTransportListenerWaitingForMessages] && !waitingForTransportListener)
        return;

    if (![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(updatePending:) withObject:nil waitUntilDone:NO];
        return;
    }        
    waitingForTransportListener = NO;
        
    PersistentModelStore* store = [Musubi sharedInstance].mainStore;
    NSArray* encoded = [store query:[NSPredicate predicateWithFormat:@"(processed == NO) AND (outbound == NO)"] onEntity:@"EncodedMessage"];
    NSArray* objs = [store query:[NSPredicate predicateWithFormat:@"(processed == NO) AND (encoded != nil)"] onEntity:@"Obj"];
    
    int pending = encoded.count;
    for (MObj* obj in objs) {
        if (!obj.identity.owned)
            pending += 1;
    }
    
    if (pending > 0) {
        incomingLabel.text = [NSString stringWithFormat: @"  Decrypting %@incoming message%@...", pending > 1 ? [NSString stringWithFormat:@"%d ", pending] : @"", pending > 1 ? @"s" : @""];
    } else {
        if ([notification.name isEqualToString:kMusubiNotificationAppOpened]) {
            waitingForTransportListener = YES;
            incomingLabel.text = @"  Checking for incoming messages...";   
        } else {
            incomingLabel.text = @"";
        }
    }
    
    if (incomingLabel.text.length) {
        if (incomingLabel.superview == self.view) {
            [incomingLabel setFrame:CGRectMake(0, 386, 320, 30)];
        } else {
            [incomingLabel setFrame:CGRectMake(0, 0, 320, 30)];
        }
    } else {
        [incomingLabel setFrame:CGRectZero];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) feedUpdated: (NSNotification*) notification {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(feedUpdated:) withObject:notification waitUntilDone:NO];
        return;
    }

    [self performSelector:@selector(reloadFeeds) withObject:nil afterDelay:0];
}

- (void) reloadFeeds{
    [self.dataSource load:TTURLRequestCachePolicyDefault more:NO];
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowFeedCustom"]) {
        FeedViewController *vc = [segue destinationViewController];
        [vc setFeed: (MFeed*) sender];
        [vc.view addSubview:incomingLabel];
        [self updatePending:nil];
    }
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MFeed* feed = [((FeedListDataSource*)self.dataSource) feedForIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowFeedCustom" sender:feed];
}

@end
