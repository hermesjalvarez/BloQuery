#import <UIKit/UIKit.h>

@interface AnswersTableViewController : UITableViewController

@property(nonatomic,strong) NSMutableArray *questionAndAnswers;
@property(nonatomic,strong) NSString *questionAsked;
@property(nonatomic,strong) NSString *questionAskedID;

- (IBAction)AnswerQuestion:(id)sender;

@end
