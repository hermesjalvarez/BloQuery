#import <Parse/Parse.h>

@interface Answer : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSString *questionAsked;
@property (nonatomic, copy) NSString *questionAskedID;
@property (nonatomic, copy) NSArray *upvoters;
@property (nonatomic, copy) NSNumber *upvotes;
@property (nonatomic, copy) NSString *username;

@end