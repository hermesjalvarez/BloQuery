#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewCell.h"

@interface AnswersTableViewController ()

@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self dataPull];
    
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
    
    NSString *currentAnswersValue = [self.answers objectAtIndex:[indexPath row]];
    NSString *currentAnswersUpvotesValue = [self.answersUpvotes objectAtIndex:[indexPath row]];
    
    cell.answerLabel.text = currentAnswersValue;
    cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@",currentAnswersUpvotesValue];
    
    //create upvote button
    UIButton *newButton = [[UIButton alloc ] initWithFrame:CGRectMake(300, 0, 50, 25)];
    newButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [newButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    [newButton setTitle:@"Upvote" forState:UIControlStateNormal];
    newButton.tag = indexPath.row;
    [newButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:newButton];
    
    return cell;
}

-(void) buttonPressed:(id) sender{
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"objectId" equalTo:[self.answersID objectAtIndex:[sender tag]]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *upvotesQuery = [[NSMutableArray alloc] init];
        NSArray *upvotersQuery;
        if (!error) {
            for (PFObject *object in objects) {
                [upvotesQuery addObject:object[@"upvotes"]];
                upvotersQuery = object[@"upvoters"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (NSString *i in upvotersQuery) {
                NSLog(@"first:%@",i);
            }
            
            PFUser *currentUser = [PFUser currentUser];
            
            BOOL didUpvoterVoteAlready = [upvotersQuery containsObject:currentUser.username];
            NSLog(@"Bool:%d",(int)didUpvoterVoteAlready);
            
            if (didUpvoterVoteAlready) {
                
                PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
                
                [query getObjectInBackgroundWithId:[self.answersID objectAtIndex:[sender tag]] block:^(PFObject *answers, NSError *error) {
                    answers[@"upvotes"] = [NSNumber numberWithInt:[upvotesQuery[0] intValue] - 1];
                    [answers removeObject:currentUser.username forKey:@"upvoters"];
                    [answers saveInBackground];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dataPull];
                    });
                    
                }];
                
            } else {
                
                PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
                
                [query getObjectInBackgroundWithId:[self.answersID objectAtIndex:[sender tag]] block:^(PFObject *answers, NSError *error) {
                    answers[@"upvotes"] = [NSNumber numberWithInt:[upvotesQuery[0] intValue] + 1];
                    [answers addObject:currentUser.username forKey:@"upvoters"];
                    [answers saveInBackground];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dataPull];
                    });
                    
                }];
                
            }
            
        });
        
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

- (void) dataPull {
    
    self.answers = [[NSMutableArray alloc] init];
    self.answersID = [[NSMutableArray alloc] init];
    self.answersUpvotes = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"questionAskedID" equalTo:self.questionAskedID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.answers addObject:object[@"answer"]];
                [self.answersID addObject:object.objectId];
                [self.answersUpvotes addObject:object[@"upvotes"]];
            }
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
}

@end
