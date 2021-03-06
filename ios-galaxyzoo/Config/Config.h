//
//  Config.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (void)initialize;

- (instancetype) init NS_DESIGNATED_INITIALIZER;

+ (NSDictionary *)subjectGroups; //Of Group ID to ConfigSubjectGroup.

+ (NSString *)baseUrl;

+ (NSString *)userAgent;

+ (NSString *)fullExampleUri;

+ (NSString *)forgotPasswordUri;
+ (NSString *)registerUri;

+ (NSString *)examineUri;
+ (NSString *)talkUri;

@end
