#import <UIKit/UIKit.h>

@interface AnswerQuestionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *answerField;
@property(strong,nonatomic) NSString *questionAsked;
@property(strong,nonatomic) NSString *questionAskedID;
@property(strong,nonatomic) NSString *userWhoAskedQuestion;
@property(strong,nonatomic) NSString *avatarForUserWhoAskedQuestion;
@property(strong,nonatomic) NSMutableArray *answerQuery;

- (IBAction)Post:(id)sender;

@end
