#import "QuestionsViewTableViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewController.h"
#import "QuestionsTableViewCell.h"
#import "Question.h"


@interface QuestionsViewTableViewController ()

@property (nonatomic, strong) NSArray <Question *> *questions;

@end

@implementation QuestionsViewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        self.questions = objects;
        
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

	NSString *identifier = [QuestionsTableViewCell reuseIdentifier];
    QuestionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

	Question *q = self.questions[indexPath.row];
	NSString *currentValue = q.question;
    NSInteger currentAnswers = [q.answers integerValue];
    
    cell.questionLabel.text = currentValue;
    if (currentAnswers==1) {
        cell.questionCountLabel.text = [NSString stringWithFormat:@"%@ answer", @(currentAnswers)];
    } else {
        cell.questionCountLabel.text = [NSString stringWithFormat:@"%@ answers", @(currentAnswers)];
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
    
    cell.username.text = [NSString stringWithFormat:@"%@", q.username];

	/**
	 *	reading this like this is very inefficient. lots of possible ways I can think of to optimize
	 *	best to discuss the options, as most would require a deeper knowledge of Parse backend than I currently have
	 */
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:q.username];
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
		Question *q = self.questions[indexPath.row];

        AnswersTableViewController *destViewController = segue.destinationViewController;
        destViewController.qst = q;
    }
}

@end