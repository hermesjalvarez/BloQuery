#import "Question.h"
#import <Parse/PFObject+Subclass.h>

@implementation Question

@dynamic question;
@dynamic username;
@dynamic answers;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end