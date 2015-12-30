#import <Parse/Parse.h>

@interface Question : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSNumber *answers;

@end