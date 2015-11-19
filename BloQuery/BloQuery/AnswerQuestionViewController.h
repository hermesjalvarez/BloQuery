#import <UIKit/UIKit.h>

@interface AnswerQuestionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *answerField;
@property(strong,nonatomic) NSString *questionAsked;
@property(strong,nonatomic) NSString *questionAskedID;

- (IBAction)Post:(id)sender;

@end
