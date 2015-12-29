#import "User.h"
#import <Parse/PFObject+Subclass.h>

@implementation User

@dynamic username;
@dynamic avatar;
@dynamic email;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
