#import <UIKit/UIKit.h>

@class AnswersTableViewCell;

@interface AnswersTableViewController : UITableViewController

@property(nonatomic,strong) NSString *questionAsked;
@property(nonatomic,strong) NSString *questionAskedID;
@property(nonatomic,strong) NSString *userWhoAskedQuestion;
@property(nonatomic,strong) NSString *avatarForUserWhoAskedQuestion;
@property(nonatomic,strong) NSMutableArray *answers;
@property(nonatomic,strong) NSMutableArray *answersID;
@property(nonatomic,strong) NSMutableArray *answersUpvotes;
@property(nonatomic,strong) NSMutableArray *upvotersArray;
@property(nonatomic,strong) NSNumber *currentAnswersUpvotesValue;
@property(nonatomic,strong) NSMutableArray *answerers;
@property(nonatomic,strong) NSMutableArray *answerersImage;

- (IBAction)AnswerQuestion:(id)sender;

@end