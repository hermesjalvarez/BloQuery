#import <UIKit/UIKit.h>

@interface QuestionsViewTableViewController : UITableViewController

@property(nonatomic,strong) NSMutableArray *questions;
@property(nonatomic,strong) NSMutableArray *questionsID;
@property(nonatomic,strong) NSMutableArray *questionsAnswerCount;
@property(nonatomic,strong) NSMutableArray *userWhoAskedQuestion;

- (IBAction)Settings:(id)sender;

- (IBAction)AskQuestion:(id)sender;

@end