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
//  StoryObjItemCell.h
//  musubi
//
//  Created by Ben Dodson on 5/31/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "FeedItemCell.h"

@interface StoryObjItemCell : FeedItemCell

@property (nonatomic, strong, readonly) UIImageView* thumbnailView;
@property (nonatomic, strong, readonly) UILabel* statusView;
@property (nonatomic, strong, readonly) UILabel* subjectView;
@property (nonatomic, strong, readonly) UILabel* descriptionView;
@property (nonatomic, strong, readonly) NSString* url;

@end
