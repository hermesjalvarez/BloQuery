#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;

- (IBAction)SignOut:(id)sender;
- (IBAction)backToBlocquery:(id)sender;
- (IBAction)showImageActions:(id)sender;

@end
