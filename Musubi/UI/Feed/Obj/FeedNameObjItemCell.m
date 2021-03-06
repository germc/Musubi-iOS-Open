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
//  FeedNameObjCell.m
//  musubi
//
//  Created by Ian Vo on 6/4/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FeedNameObjItemCell.h"
#import "ManagedObjFeedItem.h"
#import "ObjHelper.h"

@implementation FeedNameObjItemCell

+ (NSString*) textForItem: (ManagedObjFeedItem*) item {
    NSString* text = @"I changed the chat details.";
    return text;
}

+ (CGFloat)renderHeightForItem:(FeedItem *)item {
    CGSize size = [[FeedNameObjItemCell textForItem: (ManagedObjFeedItem*)item] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(244, 1024) lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

- (void)setObject:(id)object {
    [super setObject:object];
    NSString* text = [FeedNameObjItemCell textForItem:(ManagedObjFeedItem*)object];
    self.detailTextLabel.text = text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
