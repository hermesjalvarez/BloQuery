#import <Parse/Parse.h>

@interface User : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *email;

@end
