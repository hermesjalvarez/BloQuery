#import <UIKit/UIKit.h>

@interface QuestionsViewTableViewController : UITableViewController

@property(nonatomic,strong) NSMutableArray *questions;
@property(nonatomic,strong) NSMutableArray *questionsID;
@property(nonatomic,strong) NSMutableArray *questionsAnswerCount;

- (IBAction)SignOut:(id)sender;

- (IBAction)AskQuestion:(id)sender;

@end