#import <UIKit/UIKit.h>

@class AnswersTableViewCell;

@interface AnswersTableViewController : UITableViewController

@property(nonatomic,strong) NSString *questionAsked;
@property(nonatomic,strong) NSString *questionAskedID;
@property(nonatomic,strong) NSMutableArray *answers;
@property(nonatomic,strong) NSMutableArray *answersID;
@property(nonatomic,strong) NSMutableArray *answersUpvotes;
@property(nonatomic,strong) NSMutableArray *upvotersArray;
@property(nonatomic,strong) NSNumber *currentAnswersUpvotesValue;

- (IBAction)AnswerQuestion:(id)sender;

@end