#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewController.h"

@interface AnswerQuestionViewController ()

@end

@implementation AnswerQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)Post:(id)sender {
    
    NSString *answer = [self.answerField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([answer length]==0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!"
                                                                       message:@"Make sure you enter an answer"
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
        
        PFObject *Answer = [PFObject objectWithClassName:@"Answer"];
        Answer[@"answer"] = answer;
        Answer[@"username"] = currentUser.username;
        Answer[@"questionAskedID"] = self.questionAskedID;
        Answer[@"questionAsked"] = self.questionAsked; //not needed in DB, can use ID to find it
        Answer[@"upvotes"] = @0;
        Answer[@"upvoters"] = [[NSMutableArray alloc] init];
        
        [Answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
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
                
                //test
                
//                PFQuery *query = [PFQuery queryWithClassName:@"Question"];
//                [query whereKey:@"objectId" equalTo:self.questionAskedID];
//                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                    if (!error) {
//                        for (PFObject *object in objects) {
//                            [self.questions addObject:object[@"question"]];
//                        }
//                    } else {
//                        NSLog(@"Error: %@ %@", error, [error userInfo]);
//                    }
//                    
//                    }];
                
                
                
                // test
                
                
                [self performSegueWithIdentifier:@"backtoAnswersTableView" sender:self];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"backtoAnswersTableView"]) {
        AnswersTableViewController *destViewController = segue.destinationViewController;
        destViewController.questionAsked = self.questionAsked;
        destViewController.questionAskedID = self.questionAskedID;
    }
}

@end
