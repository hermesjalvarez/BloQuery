#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>

@interface AnswersTableViewController ()

@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questionAndAnswers = [[NSMutableArray alloc] init];
    
    [self.questionAndAnswers addObject:self.questionAsked];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Answer"];
    [query whereKey:@"questionAskedID" equalTo:self.questionAskedID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.questionAndAnswers addObject:object[@"answer"]];
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
    return self.questionAndAnswers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *currentValue = [self.questionAndAnswers objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:currentValue];
    
    return cell;
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

@end
