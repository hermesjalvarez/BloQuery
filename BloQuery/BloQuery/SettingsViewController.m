#import "SettingsViewController.h"
#import <Parse/Parse.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    self.username.text = [NSString stringWithFormat:@"%@",currentUser.username];
    
    self.userPhoto.image = [UIImage imageNamed:@"funny.png"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SignOut:(id)sender {
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"showSignIn" sender:self];
}

- (IBAction)backToBlocquery:(id)sender {
    [self performSegueWithIdentifier:@"backToBloquery" sender:self];
}

- (IBAction)showImageActions:(id)sender {
}

@end
