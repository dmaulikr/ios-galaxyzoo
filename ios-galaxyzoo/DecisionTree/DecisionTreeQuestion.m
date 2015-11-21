//
//  DecisionTreeQuestion.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestion.h"

@implementation DecisionTreeQuestion

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithDetails:(NSString *)questionId
                         title:(NSString *)title
                          text:(NSString *)text
                          help:(NSString *)help
                       answers:(NSArray *)answers
                    checkboxes:(NSArray *)checkboxes {
    self = [self init];
    self.questionId = questionId;
    self.title = title;
    self.text = text;
    self.help = help;
    self.answers = answers;
    self.checkboxes = checkboxes;
    return self;
}

@end
