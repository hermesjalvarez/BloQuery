#import "AskQuestionViewController.h"
#import <Parse/Parse.h>

@interface AskQuestionViewController ()

@end

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)Post:(id)sender {
    
    NSString *question = [self.questionField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([question length]==0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"Make sure you enter a question"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        PFUser *currentUser = [PFUser currentUser];
        
        PFObject *Question = [PFObject objectWithClassName:@"Question"];
        Question[@"username"] = currentUser.username;
        Question[@"question"] = question;
        Question[@"answers"] = @0;
        
        [Question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (error) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry!"
                                                                               message:[error.userInfo objectForKey:@"error"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action)
                                           {
                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                           }];
                
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
            
            } else {
                [self performSegueWithIdentifier:@"backToQuestions" sender:self];
            }
        }];
    }
}

@end