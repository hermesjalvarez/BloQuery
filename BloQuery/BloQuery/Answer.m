#import "Answer.h"
#import <Parse/PFObject+Subclass.h>

@implementation Answer

@dynamic answer;
@dynamic questionAsked;
@dynamic questionAskedID;
@dynamic upvotes;
@dynamic  upvoters;
@dynamic username;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end