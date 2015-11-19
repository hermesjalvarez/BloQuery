#import "QuestionsViewTableViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewController.h"

@interface QuestionsViewTableViewController ()

@end

@implementation QuestionsViewTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.questions = [[NSMutableArray alloc] init];
    self.questionsID = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.questions addObject:object[@"question"]];
                [self.questionsID addObject:object.objectId];
            }
        
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *currentValue = [self.questions objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:currentValue];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showAnswers" sender:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)SignOut:(id)sender {
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"showSignIn" sender:self];
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
    }
}

@end