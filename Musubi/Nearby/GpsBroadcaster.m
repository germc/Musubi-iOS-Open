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
//  GpsBroadcaster.h
//  musubi
//
//  Created by T.J. Purtell on 6/17/12.
//  Copyright (c) 2012 Stanford MobiSocial Labratory. All rights reserved.
//


#import "GpsBroadcaster.h"
#import "NearbyFeed.h"
#import "NSData+Crypto.h"
#import "NSData+Base64.h"
#import "GridHandler.h"


@implementation GpsBroadcaster
@synthesize feed;
- (void)broadcastNearby:(NearbyFeed*)feedData withPassword:(NSString*)password onSuccess:(void(^)())success onFail:(void(^)(NSError*))fail {
    feed = feedData;
    [self lookupAndCall:^(CLLocation *location) {
        NSMutableDictionary* descriptor = [NSMutableDictionary dictionary];
        [descriptor setObject:feedData.groupName forKey:@"group_name"];
        [descriptor setObject:feedData.groupCapability forKey:@"group_capability"];
        [descriptor setObject:feedData.sharerName forKey:@"sharer_name"];
        [descriptor setObject:[NSNumber numberWithInt:feedData.sharerType] forKey:@"sharer_type"];
        [descriptor setObject:feedData.sharerHash forKey:@"sharer_hash"];
        if(feedData.thumbnail) 
            [descriptor setObject:feedData.thumbnail forKey:@"thumbnail"];
        [descriptor setObject:[NSNumber numberWithInt:feedData.memberCount] forKey:@"member_count"];
        
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:descriptor options:0 error:&error];
        if(!data) {
            NSLog(@"Failed to serialize group descriptor %@", error);
            fail(error);
            return;
        }
        NSData* key = [[[@"happysalt621" stringByAppendingString:password] dataUsingEncoding:NSUnicodeStringEncoding] sha256Digest];
        NSData* iv = [NSData generateSecureRandomKeyOf:16];
        NSData* partial_enc_data = [data encryptWithAES128CBCPKCS7WithKey:key andIV:iv];
        NSMutableData* enc_data = [NSMutableData dataWithData:iv];
        [enc_data appendData:partial_enc_data];

        NSAssert(enc_data, @"somehow failed to encrypt group descriptor");
        
        double lat = location.coordinate.latitude;
        double lng = location.coordinate.longitude;
        
        NSArray* coords = [GridHandler hexTilesForSizeInFeet:5280 / 2 atLatitude:lat andLongitude:lng];
        NSMutableArray* enc_coords = [NSMutableArray array];
        for(NSNumber* coord in coords) {
            NSData* partial_coord = [[@"sadsalt193s" stringByAppendingString:password] dataUsingEncoding:NSUnicodeStringEncoding];
            NSMutableData* raw_coord = [NSMutableData dataWithData:partial_coord];
            long long local_coord = coord.longLongValue;
            [raw_coord appendBytes:&local_coord length:8];
            [enc_coords addObject:[[raw_coord sha256Digest] encodeBase64]];
        }
        
        NSMutableDictionary* enc_descriptor = [NSMutableDictionary dictionary];\
        [enc_descriptor setValue:enc_coords forKey:@"buckets"];
        [enc_descriptor setValue:[enc_data encodeBase64] forKey:@"data"];
        [enc_descriptor setValue:[NSNumber numberWithLongLong:(((NSDate*)[NSDate date]).timeIntervalSince1970 * 1000 + 1000 * 60 * 60)] forKey:@"expiration"];
        
        NSData* enc_ser_descriptor = [NSJSONSerialization dataWithJSONObject:enc_descriptor options:0 error:&error];
        if(!enc_descriptor) {
            NSLog(@"FAiled to encode encrypted nearby feed descriptor %@", error);
            fail(error);
            return;
        }
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://bumblebee.musubi.us:6253/nearbyapi/0/sharegroup"]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = enc_ser_descriptor;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) 
        {
            NSHTTPURLResponse* response = (NSHTTPURLResponse*)resp;
            if(error) {
                fail(error);
                return;
            }
            if(response.statusCode < 200 || response.statusCode >= 300) {
                error = [NSError errorWithDomain:@"Failed to publish gps, bad status code" code:-1 userInfo:nil];
                fail(error);
                return;
            }
            if(![[@"ok" dataUsingEncoding:NSUnicodeStringEncoding] isEqualToData:data]) {
                error = [NSError errorWithDomain:@"Failed to publish gps, non ok response" code:-1 userInfo:nil];
                fail(error);
                return;
            }
            success();
        }];
    
    } orFail:^(NSError *error) {
        fail(error);
    }];
}

@end
