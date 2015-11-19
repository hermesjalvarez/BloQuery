#import <UIKit/UIKit.h>

@interface AskQuestionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *questionField;

- (IBAction)Post:(id)sender;

@end
