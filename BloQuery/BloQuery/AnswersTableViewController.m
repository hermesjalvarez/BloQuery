#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewCell.h"
#import "TopQuestionTableViewCell.h"
#import "Answer.h"
#import "User.h"

@interface AnswersTableViewController ()

@property (nonatomic, strong) NSArray <Answer *> *PFAnswers;
@property (nonatomic, strong) NSArray <User *> *PFUsers;

@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ asks...", self.userWhoAskedQuestion];
    
    //find image for top question
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.userWhoAskedQuestion];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            self.avatarForUserWhoAskedQuestion = object[@"avatarImage"];
        }
        
        [self loadTableviewData];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answers.count;
    //return self.PFAnswers.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0) {
        //create top question cell
        static NSString *topIdentifier = @"TopCell";
        TopQuestionTableViewCell *topCell = [tableView dequeueReusableCellWithIdentifier:topIdentifier forIndexPath:indexPath];
        
        topCell.topQuestionLabel.text = self.questionAsked;
        topCell.topQuestionAvatarLabel.text = self.userWhoAskedQuestion;
        topCell.topQuestionAvatar.image = [UIImage imageNamed:self.avatarForUserWhoAskedQuestion];
        
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
        
        cell.answerLikeCountLabel.tag = 1234; //create tag for use in button click selector method

        //create upvote button
        cell.voteButton = (UIButton *)[cell viewWithTag:102];
        cell.voteButton.tag = [indexPath row];
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
        
        //set avatar
        cell.AnswererLabel.text = [self.answerers objectAtIndex:[indexPath row]];
        cell.AnswererAvatar.image = [UIImage imageNamed:[self.answerersImage objectAtIndex:[indexPath row]]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
        
        return cell;
    }
}

- (IBAction)upvoteButtonPressed:(id)sender {
    
    //find count label
    UILabel *answerLikeCountButton = [[sender superview] viewWithTag:1234];
    
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
            //update count button UI
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
                    
                    //update count label UI
                    NSString *count = [[NSNumber numberWithInt:[upvotesQuery[0] intValue] - 1] stringValue];
                    if ([count isEqual:@"1"]) {
                        answerLikeCountButton.text = [NSString stringWithFormat:@"%@ vote",count];
                    } else {
                        answerLikeCountButton.text = [NSString stringWithFormat:@"%@ votes",count];
                    }
                }];
            }];
        
        } else {
            //update count button UI
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
                    
                    //update count label UI
                    NSString *count = [[NSNumber numberWithInt:[upvotesQuery[0] intValue] + 1] stringValue];
                    if ([count isEqual:@"1"]) {
                        answerLikeCountButton.text = [NSString stringWithFormat:@"%@ vote",count];
                    } else {
                        answerLikeCountButton.text = [NSString stringWithFormat:@"%@ votes",count];
                    }
                }];
            }];
        }
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 100;
    }
    else {
        return 100;
    }
}

- (IBAction)AnswerQuestion:(id)sender {
    [self performSegueWithIdentifier:@"showAnswerQuestion" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAnswerQuestion"]) {
        AnswerQuestionViewController *destViewController = segue.destinationViewController;
        destViewController.questionAsked = self.questionAsked;
        destViewController.questionAskedID = self.questionAskedID;
        destViewController.userWhoAskedQuestion = self.userWhoAskedQuestion;
        destViewController.avatarForUserWhoAskedQuestion = self.avatarForUserWhoAskedQuestion;
    }
}

- (void) loadTableviewData {
    self.answers = [[NSMutableArray alloc] init];
    self.answersID = [[NSMutableArray alloc] init];
    self.answersUpvotes = [[NSMutableArray alloc] init];
    self.upvotersArray = [[NSMutableArray alloc] init];
    self.answerers = [[NSMutableArray alloc] init];
    self.answerersImage = [[NSMutableArray alloc] init];
    
    //create empty space in slot 0 of every array
    [self.answers addObject:@""];
    [self.answersID addObject:@""];
    [self.answersUpvotes addObject:@""];
    [self.upvotersArray addObject:@""];
    [self.answerers addObject:@""];
    //[self.answerersImage addObject:@""]; //not needed due to code below
    
    //new query for PFobject
    PFQuery *query1 = [PFQuery queryWithClassName:@"Answer"];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        self.PFAnswers = objects; //set PFObjects
        self.PFAnswers = [self sortedAnswers]; //sort by descending upvotes
        
        for (Answer *PFAnswer in self.PFAnswers) {//cycles through PFAnswer object
            
            //find all answers & data for question tapped
            if ([self.questionAskedID isEqualToString:PFAnswer.questionAskedID]) {
                [self.answers addObject:PFAnswer.answer];
                [self.answersID addObject:PFAnswer.objectId];
                [self.answersUpvotes addObject:PFAnswer.upvotes];
                [self.upvotersArray addObject:PFAnswer.upvoters];
                [self.answerers addObject:PFAnswer.username];
            }
        }
        
        //find images for answerers
        PFQuery *query2 = [PFQuery queryWithClassName:@"_User"];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *things, NSError *error2) {
            if (error2) {
                NSLog(@"Error: %@ %@", error2, [error2 userInfo]);
                return;
            }
            
            self.PFUsers = things;
            NSLog(@"%@",self.PFUsers);
            
            for (User *user in self.PFUsers) {
                NSLog(@"%@",user.username);
                NSLog(@"%@",user.email);
                NSLog(@"%@",user.avatar);
            }
            
            NSMutableArray *keys = [NSMutableArray new];
            NSMutableArray *values = [NSMutableArray new];
            NSMutableDictionary *dictionary = [NSMutableDictionary new];
            
            for (PFObject *thing in things) {
                [keys addObject:thing[@"username"]];
                [values addObject:thing[@"avatarImage"]];
            }
            
            for (int i = 0 ; i != keys.count ; i++) {
                [dictionary setObject:values[i] forKey:keys[i]];
            }
            
            for (NSString *answerer in self.answerers) {
                [self.answerersImage addObject:[NSString stringWithFormat:@"%@",dictionary[answerer]]];
            }
            
            //reload data
            [self.tableView reloadData];
            
        }];
        
    }];
    
}

- (NSArray *)sortedAnswers {
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"upvotes" ascending:NO];
    return [self.PFAnswers sortedArrayUsingDescriptors:@[sd]];
}

@end