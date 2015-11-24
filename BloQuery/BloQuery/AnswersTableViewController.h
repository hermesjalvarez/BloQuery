#import <UIKit/UIKit.h>

@interface AnswersTableViewController : UITableViewController

@property(nonatomic,strong) NSString *questionAsked;
@property(nonatomic,strong) NSString *questionAskedID;
@property(nonatomic,strong) NSMutableArray *answers;
@property(nonatomic,strong) NSMutableArray *answersID;
@property(nonatomic,strong) NSMutableArray *answersUpvotes;

- (IBAction)AnswerQuestion:(id)sender;

@end
