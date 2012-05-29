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



#import "FeedItemCell.h"
// UI
#import "Three20UI/TTImageView.h"
#import "Three20UI/TTTableMessageItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSDateAdditions.h"

#import "FeedItem.h"
#import "FeedViewController.h"

static const CGFloat    kDefaultMessageImageWidth   = 34.0f;
static const CGFloat    kDefaultMessageImageHeight  = 34.0f;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FeedItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    
    if (self) {
        self.textLabel.font = TTSTYLEVAR(font);
        self.textLabel.textColor = TTSTYLEVAR(textColor);
        self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
        self.textLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
        self.textLabel.textAlignment = UITextAlignmentLeft;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.contentMode = UIViewContentModeTopLeft;
        
        self.detailTextLabel.font = TTSTYLEVAR(font);
        self.detailTextLabel.textColor = TTSTYLEVAR(tableSubTextColor);
        self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
        self.detailTextLabel.backgroundColor = TTSTYLEVAR(backgroundTextColor);
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.contentMode = UIViewContentModeTopLeft;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    int likes = ((FeedItem*) object).likes.count + ((FeedItem*) object).iLiked ? 1 : 0;
    CGFloat likeSpace = likes > 0 ? [LikeView renderHeightForItem: object] + 15 : 0;
    return [self renderHeightForItem:(FeedItem*)object] + 40 + likeSpace;
}

+ (CGFloat) renderHeightForItem: (FeedItem*) item {
    return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
    [super prepareForReuse];
    _profilePictureButton.imageView.image = nil;
    _senderLabel.text = nil;
    _timestampLabel.text = nil;
    [_likeView prepareForReuse];
    _likeButton.imageView.image = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = 0.0f;
    if (_profilePictureButton) {
        _profilePictureButton.frame = CGRectMake(kTableCellSmallMargin, kTableCellSmallMargin,
                                       kDefaultMessageImageWidth, kDefaultMessageImageHeight);        
    }
    
    left += kTableCellSmallMargin + kDefaultMessageImageHeight + kTableCellSmallMargin;
    
    CGFloat right = 20.0f;
    
    CGFloat width = self.contentView.width - left - right;
    CGFloat top = kTableCellSmallMargin;
    
    if (_senderLabel.text.length) {
        _senderLabel.frame = CGRectMake(left, top, width, _senderLabel.font.ttLineHeight);
        top += _senderLabel.height;
        
    } else {
        _senderLabel.frame = CGRectZero;
    }
    
    CGFloat contentBottom = self.frame.size.height - kTableCellMargin + 2;
    
    if (_likeView.label.text.length) {
        [_likeView layoutSubviews];
        [_likeView sizeToFit];

        contentBottom -= _likeView.height;
        _likeView.left = left;
        _likeView.width = width;
        _likeView.top = contentBottom;
    } else {
        _likeView.frame = CGRectZero;
    }
    
    self.detailTextLabel.frame = CGRectMake(left, top, width - kTableCellMargin, contentBottom - top);
    
    if (_timestampLabel.text.length) {
        _timestampLabel.alpha = !self.showingDeleteConfirmation;
        [_timestampLabel sizeToFit];
        _timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
        _timestampLabel.top = _senderLabel.top;
        _senderLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
        
    } else {
        _timestampLabel.frame = CGRectZero;
    }
    
    [_likeButton sizeToFit];
    
    _likeButton.width = 16;
    _likeButton.height = 16;
    _likeButton.left = self.contentView.width - _likeButton.width - kTableCellSmallMargin;
    _likeButton.top = _senderLabel.top + _timestampLabel.height + kTableCellSmallMargin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        _profilePictureButton.backgroundColor = self.backgroundColor;
        _senderLabel.backgroundColor = self.backgroundColor;
        _timestampLabel.backgroundColor = self.backgroundColor;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        
        FeedItem* item = object;
        if (item.sender.length) {
            self.senderLabel.text = item.sender;
        }
        if (item.timestamp) {
            self.timestampLabel.text = [item.timestamp formatShortTime];
        }
        if (item.profilePicture) {
            [self.profilePictureButton setImage:item.profilePicture forState:UIControlStateNormal];
        }
        if (item.likes.count > 0 || item.iLiked) {
            [self.likeView setObject:item];
        }
        
        [self.likeButton setImage:[UIImage imageNamed:item.iLiked ? @"heart32.png" : @"heart32_gray.png"] forState:UIControlStateNormal];
    }    
}

- (void) likeButtonPressed: (UIView*) source {
    TTTableViewCell* cell = (TTTableViewCell*)source.superview.superview;
    TTTableView* tableView = (TTTableView*)cell.superview;
    
    FeedViewTableDelegate* tableDelegate = (FeedViewTableDelegate*) tableView.delegate;
    [tableDelegate likedAtIndexPath:[tableView indexPathForCell: cell]];
}

- (void) profilePictureButtonPressed: (UIView*) source {
    TTTableViewCell* cell = (TTTableViewCell*)source.superview.superview;
    TTTableView* tableView = (TTTableView*)cell.superview;
    
    FeedViewTableDelegate* tableDelegate = (FeedViewTableDelegate*) tableView.delegate;
    [tableDelegate profilePictureButtonPressedAtIndexPath:[tableView indexPathForCell: cell]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)senderLabel {
    if (!_senderLabel) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.textColor = [UIColor blackColor];
        _senderLabel.highlightedTextColor = [UIColor whiteColor];
        _senderLabel.font = TTSTYLEVAR(tableFont);
        _senderLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_senderLabel];
    }
    return _senderLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.font = TTSTYLEVAR(tableTimestampFont);
        _timestampLabel.textColor = TTSTYLEVAR(timestampTextColor);
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        _timestampLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_timestampLabel];
    }
    return _timestampLabel;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIButton*)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.imageView.image = [UIImage imageNamed:@"heart32_gray.png"];
        _likeButton.width = 16;
        _likeButton.height = 16;
        _likeButton.userInteractionEnabled = YES;
        [_likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self.contentView addSubview:_likeButton];
    }
    return _likeButton;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (LikeView*)likeView {
    if (!_likeView) {
        _likeView = [[LikeView alloc] init];
        [self.contentView addSubview:_likeView];
    }
    return _likeView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIButton*)profilePictureButton {
    if (!_profilePictureButton) {
        _profilePictureButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        //    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
        //    _imageView2.style = TTSTYLE(threadActorIcon);
        _profilePictureButton.userInteractionEnabled = YES;
        [_profilePictureButton addTarget:self action:@selector(profilePictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_profilePictureButton];
    }
    return _profilePictureButton;
}


@end

@implementation LikeView

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)sizeToFit {
    [_label sizeToFit];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _label.width, _label.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _icon.left = 0;
    _icon.width = 16;
    _icon.height = 16;
    _icon.top = 0;
    
    _label.left = 20;
}

///////////////////////////////////////////////////////////////////////////////////
- (UILabel*)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = TTSTYLEVAR(tableTimestampFont);
        _label.textColor = TTSTYLEVAR(timestampTextColor);
        _label.highlightedTextColor = [UIColor whiteColor];
        _label.contentMode = UIViewContentModeLeft;
        [self addSubview:_label];
    }
    return _label;
}

- (UIImageView*)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
    }
    return _icon;
}

- (void)prepareForReuse {
    _label.text = nil;
    _icon.image = nil;
    
    _label.frame = CGRectZero;
    _icon.frame = CGRectZero;
}

- (void) setObject: (FeedItem*) item {
    NSMutableString* likers = [NSMutableString string];
    [likers appendString: [item.likes.allKeys componentsJoinedByString:@", "]];
    if (item.iLiked) {
        if (item.likes.count > 0) {
            [likers appendString:@" and you like this"];
        } else {
            [likers appendString:@"You like this"];
        }
    } else if (item.likes.count > 1) {
        [likers appendString:@" like this"];
    } else if (item.likes.count == 1) {
        [likers appendString:@" likes this"];
    }
    
    self.label.text = likers;
    self.icon.image = [UIImage imageNamed:@"heart32.png"];
}

+ (CGFloat)renderHeightForItem:(FeedItem *)item {
    // worst case string length
    NSString* likers = [NSString stringWithFormat:@"%@ and you like this", [item.likes.allKeys componentsJoinedByString:@", "]];
    
    CGSize size = [likers sizeWithFont:TTSTYLEVAR(tableTimestampFont) constrainedToSize:CGSizeMake(260, 1024) lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}



@end
