#import "QuestionsViewTableViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewController.h"
#import "QuestionsTableViewCell.h"
#import "Question.h"


@interface QuestionsViewTableViewController ()

@property (nonatomic, strong) NSArray <Question *> *PFQuestions;

@end

@implementation QuestionsViewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questions = [[NSMutableArray alloc] init];
    self.questionsID = [[NSMutableArray alloc] init];
    self.questionsAnswerCount = [[NSMutableArray alloc] init];
    self.userWhoAskedQuestion = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        self.PFQuestions = objects;
        
        for (Question *PFQuestion in self.PFQuestions) {
            [self.questions addObject:PFQuestion.question];
            [self.questionsID addObject:PFQuestion.objectId];
            [self.questionsAnswerCount addObject:PFQuestion.answers];
            [self.userWhoAskedQuestion addObject:PFQuestion.username];
        }
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    QuestionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    NSString *currentValue = [self.questions objectAtIndex:[indexPath row]];
    int currentAnswers = [[self.questionsAnswerCount objectAtIndex:[indexPath row]] intValue];
    
    cell.questionLabel.text = currentValue;
    if (currentAnswers==1) {
        cell.questionCountLabel.text = [NSString stringWithFormat:@"%d answer",currentAnswers];
    } else {
        cell.questionCountLabel.text = [NSString stringWithFormat:@"%d answers",currentAnswers];
    }
    
    if (currentAnswers<5) {
        cell.questionPopularitySlotOne.image = [UIImage imageNamed:@"bolt.png"];
    } else if (currentAnswers>4 && currentAnswers<10) {
        cell.questionPopularitySlotOne.image = [UIImage imageNamed:@"bolt.png"];
        cell.questionPopularitySlotTwo.image = [UIImage imageNamed:@"bolt.png"];
    } else {
        cell.questionPopularitySlotOne.image = [UIImage imageNamed:@"bolt.png"];
        cell.questionPopularitySlotTwo.image = [UIImage imageNamed:@"bolt.png"];
        cell.questionPopularitySlotThree.image = [UIImage imageNamed:@"bolt.png"];
    }
    
    cell.username.text = [NSString stringWithFormat:@"%@",[self.userWhoAskedQuestion objectAtIndex:[indexPath row]]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:[self.userWhoAskedQuestion objectAtIndex:[indexPath row]]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        for (PFObject *object in objects) {
            cell.avatar.image = [UIImage imageNamed:object[@"avatar"]];
        }
        
    }];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showAnswers" sender:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)Settings:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (IBAction)AskQuestion:(id)sender {
    [self performSegueWithIdentifier:@"AskQuestion" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAnswers"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        AnswersTableViewController *destViewController = segue.destinationViewController;
        destViewController.questionAsked = [self.questions objectAtIndex:[indexPath row]];
        destViewController.questionAskedID = [self.questionsID objectAtIndex:[indexPath row]];
        destViewController.userWhoAskedQuestion = [self.userWhoAskedQuestion objectAtIndex:[indexPath row]];
    }
}

@end