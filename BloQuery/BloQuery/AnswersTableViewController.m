#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewCell.h"

@interface AnswersTableViewController ()
@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.answers = [[NSMutableArray alloc] init];
    self.answersID = [[NSMutableArray alloc] init];
    self.answersUpvotes = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"questionAskedID" equalTo:self.questionAskedID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            [self.answers addObject:object[@"answer"]];
            [self.answersID addObject:object.objectId];
            [self.answersUpvotes addObject:object[@"upvotes"]];
        }
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    AnswersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
    
    NSString *currentAnswersValue = [self.answers objectAtIndex:[indexPath row]];
    NSString *currentAnswersUpvotesValue = [NSString stringWithFormat:@"%@",[self.answersUpvotes objectAtIndex:[indexPath row]]];
    
    cell.answerLabel.text = currentAnswersValue;
    if ([currentAnswersUpvotesValue isEqual:@"1"]) {
        cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ vote",currentAnswersUpvotesValue];
    } else {
        cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ votes",currentAnswersUpvotesValue];

    }
    
    //create upvote button
    UIButton *newButton = (UIButton *)[cell viewWithTag:102];
    newButton.tag = indexPath.row;
    [newButton addTarget:self action:@selector(upvoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)upvoteButtonPressed:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"objectId" equalTo:[self.answersID objectAtIndex:[sender tag]]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        NSMutableArray *upvotesQuery = [[NSMutableArray alloc] init];
        NSArray *upvotersQuery;
        
        for (PFObject *object in objects) {
            [upvotesQuery addObject:object[@"upvotes"]];
            upvotersQuery = object[@"upvoters"];
        }
        
        PFUser *currentUser = [PFUser currentUser];
        BOOL didUpvoterVoteAlready = [upvotersQuery containsObject:currentUser.username];
            
        if (didUpvoterVoteAlready) {
            //update database
            PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
            [query getObjectInBackgroundWithId:[self.answersID objectAtIndex:[sender tag]] block:^(PFObject *answers, NSError *error) {
                answers[@"upvotes"] = [NSNumber numberWithInt:[upvotesQuery[0] intValue] - 1];
                [answers removeObject:currentUser.username forKey:@"upvoters"];
                [answers saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        return;
                    }
                    //update UI
                    [self refreshUpvoteLabel];
                }];
            }];
        
        } else {
            //update database
            PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
            [query getObjectInBackgroundWithId:[self.answersID objectAtIndex:[sender tag]] block:^(PFObject *answers, NSError *error) {
                answers[@"upvotes"] = [NSNumber numberWithInt:[upvotesQuery[0] intValue] + 1];
                [answers addObject:currentUser.username forKey:@"upvoters"];
                [answers saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        return;
                    }
                    //update UI
                    [self refreshUpvoteLabel];
                }];
            }];
        }
        
    }];
}

- (IBAction)AnswerQuestion:(id)sender {
    [self performSegueWithIdentifier:@"showAnswerQuestion" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAnswerQuestion"]) {
        AnswerQuestionViewController *destViewController = segue.destinationViewController;
        destViewController.questionAsked = self.questionAsked;
        destViewController.questionAskedID = self.questionAskedID;
    }
}

- (void) refreshUpvoteLabel {
    self.answersUpvotes = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"questionAskedID" equalTo:self.questionAskedID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            [self.answersUpvotes addObject:object[@"upvotes"]];
        }
        
        [self.tableView reloadData];
    }];
}

@end