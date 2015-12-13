//
//  Answer.h
//  BloQuery
//
//  Created by Hermes on 12/10/15.
//  Copyright © 2015 Hermes Alvarez. All rights reserved.
//

#import <Parse/Parse.h>

@interface Answer : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSNumber *upvotes;

@property (nonatomic, copy) NSArray *upvoters;

@end
