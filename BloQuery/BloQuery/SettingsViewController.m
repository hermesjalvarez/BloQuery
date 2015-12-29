#import "SettingsViewController.h"
#import <Parse/Parse.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:currentUser.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            self.username.text = [NSString stringWithFormat:@"%@",object[@"username"]];
            self.userPhoto.image = [UIImage imageNamed:object[@"avatarImage"]];
        }
        
    }];
    
}

- (IBAction)SignOut:(id)sender {
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"showSignIn" sender:self];
}

- (IBAction)backToBlocquery:(id)sender {
    [self performSegueWithIdentifier:@"backToBloquery" sender:self];
}

- (IBAction)showImageActions:(id)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Profile Avatar" message:@"Select an avatar style for your profile" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Happy (default)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *avatarName = @"Happy.png";
        [self updateAvatar:avatarName];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Funny" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *avatarName = @"Funny.png";
        [self updateAvatar:avatarName];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Amazing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *avatarName = @"Amazing.png";
        [self updateAvatar:avatarName];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Angry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *avatarName = @"Angry.png";
        [self updateAvatar:avatarName];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Sad" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *avatarName = @"Sad.png";
        [self updateAvatar:avatarName];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (void) updateAvatar:(NSString *)avatarName {
    
    PFUser *currentUser = [PFUser currentUser];
    
    //update database
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:currentUser.objectId block:^(PFObject *user, NSError *error) {
        user[@"avatarImage"] = avatarName;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                return;
            }
            
            //update count label UI
            self.userPhoto.image = [UIImage imageNamed:avatarName];
            
        }];
    }];
    
}

@end
