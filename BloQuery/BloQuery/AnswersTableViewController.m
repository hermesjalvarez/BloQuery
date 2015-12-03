#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewCell.h"
#import "TopQuestionTableViewCell.h"


@interface AnswersTableViewController ()
@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.answers = [[NSMutableArray alloc] init];
    self.answersID = [[NSMutableArray alloc] init];
    self.answersUpvotes = [[NSMutableArray alloc] init];
    self.upvotersArray = [[NSMutableArray alloc] init];
    
    //create empty space in first cell
    [self.answers addObject:@""];
    [self.answersID addObject:@""];
    [self.answersUpvotes addObject:@""];
    [self.upvotersArray addObject:@""];
    
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
            [self.upvotersArray addObject:object[@"upvoters"]];
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
    
    if (indexPath.row==0) {
        //create top question cell
        static NSString *topIdentifier = @"TopCell";
        TopQuestionTableViewCell *topCell = [tableView dequeueReusableCellWithIdentifier:topIdentifier forIndexPath:indexPath];
        
        topCell.topQuestionLabel.text = self.questionAsked;
        
        [topCell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
        
        return topCell;
    
    } else {
        //create answers cells
        static NSString *identifier = @"Cell";
        AnswersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
        NSString *currentAnswersValue = [self.answers objectAtIndex:[indexPath row]];
        NSString *currentAnswersUpvotesValue = [NSString stringWithFormat:@"%@",[self.answersUpvotes objectAtIndex:[indexPath row]]];
        
        cell.answerLabel.text = currentAnswersValue;
        
        if ([currentAnswersUpvotesValue isEqual:@"1"]) {
        cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ vote",currentAnswersUpvotesValue];
        } else {
            cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ votes",currentAnswersUpvotesValue];
        }
        
        //create upvote button
        cell.voteButton = (UIButton *)[cell viewWithTag:102];
        cell.voteButton.tag = indexPath.row;
        [cell.voteButton addTarget:self action:@selector(upvoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //set button state
        PFUser *currentUser = [PFUser currentUser];
        NSArray *currentUpvotersArray = [NSArray arrayWithArray:[self.upvotersArray objectAtIndex:[indexPath row]]];
        BOOL didUpvoterVoteAlready = [currentUpvotersArray containsObject:currentUser.username]; //check if user already upvoted
        if (didUpvoterVoteAlready) {
            [cell.voteButton setTitle: @"Downvote" forState: UIControlStateNormal];
        } else {
            [cell.voteButton setTitle: @"Upvote" forState: UIControlStateNormal];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
        
        return cell;
    }
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
            [upvotesQuery addObject:object[@"upvotes"]]; //not an array, a single element
            upvotersQuery = object[@"upvoters"]; //is an array of upvoters
        }
        
        PFUser *currentUser = [PFUser currentUser];
        BOOL didUpvoterVoteAlready = [upvotersQuery containsObject:currentUser.username]; //check if user already upvoted
            
        if (didUpvoterVoteAlready) {
            //update button
            [sender setTitle:@"Upvote" forState:UIControlStateNormal];
            
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
                    //update label
                    [self refreshUpvoteLabel];
                }];
            }];
        
        } else {
            //update button
            [sender setTitle:@"Downvote" forState:UIControlStateNormal];
            
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
                    //update label
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
    self.upvotersArray = [[NSMutableArray alloc] init];

    //create empty cell for top cell
    [self.answersUpvotes addObject:@""];
    [self.upvotersArray addObject:@""];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"questionAskedID" equalTo:self.questionAskedID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            [self.answersUpvotes addObject:object[@"upvotes"]];
            [self.upvotersArray addObject:object[@"upvoters"]];
        }
        
        [self.tableView reloadData];
    }];
}

@end