//
//  Answer.m
//  BloQuery
//
//  Created by Hermes on 12/10/15.
//  Copyright © 2015 Hermes Alvarez. All rights reserved.
//

#import "Answer.h"
#import <Parse/PFObject+Subclass.h>

@implementation Answer

@dynamic answer;
@dynamic upvotes;
@dynamic  upvoters;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
