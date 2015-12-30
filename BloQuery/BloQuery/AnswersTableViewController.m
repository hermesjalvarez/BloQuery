#import "AnswersTableViewController.h"
#import "AnswerQuestionViewController.h"
#import <Parse/Parse.h>
#import "AnswersTableViewCell.h"
#import "TopQuestionTableViewCell.h"
#import "Answer.h"
#import "Question.h"

@interface AnswersTableViewController ()

@property (nonatomic, strong) NSArray <Answer *> *answers;
@property (nonatomic, readonly, weak) NSArray <Answer *> *sortedAnswers;

@property (nonatomic, copy) NSString *avatarForUserWhoAskedQuestion;
@property (nonatomic, strong) NSMutableDictionary *answerersImage;

@end

@implementation AnswersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ asks...", self.qst.username];
    
    //find image for top question
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.qst.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }

		PFObject *object = objects.firstObject;
		self.avatarForUserWhoAskedQuestion = object[@"avatar"];

        [self loadTableviewData];
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

        topCell.topQuestionLabel.text = self.qst.question;
        topCell.topQuestionAvatarLabel.text = self.qst.username;
        topCell.topQuestionAvatar.image = [UIImage imageNamed:self.avatarForUserWhoAskedQuestion];
        
        [topCell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
        
        return topCell;
    
    } else {
        //create answers cells
        static NSString *identifier = @"Cell";
        AnswersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

		Answer *ans = self.sortedAnswers[indexPath.row];

		NSString *currentAnswersValue = ans.answer;
        NSString *currentAnswersUpvotesValue = [NSString stringWithFormat:@"%@", ans.upvotes];
        cell.answerLabel.text = currentAnswersValue;
        
        if ([currentAnswersUpvotesValue isEqual:@"1"]) {
			cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ vote", currentAnswersUpvotesValue];
        } else {
            cell.answerLikeCountLabel.text = [NSString stringWithFormat: @"%@ votes",currentAnswersUpvotesValue];
        }
        
        [cell.voteButton addTarget:self action:@selector(upvoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //set button state
        PFUser *currentUser = [PFUser currentUser];
        NSArray *currentUpvotersArray = ans.upvoters;
        BOOL didUpvoterVoteAlready = [currentUpvotersArray containsObject:currentUser.username]; //check if user already upvoted
        if (didUpvoterVoteAlready) {
            [cell.voteButton setTitle: @"Downvote" forState: UIControlStateNormal];
        } else {
            [cell.voteButton setTitle: @"Upvote" forState: UIControlStateNormal];
        }
        
        //set avatar
        cell.AnswererLabel.text = ans.username;
        cell.AnswererAvatar.image = [UIImage imageNamed:self.answerersImage[ans.username]];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //prevent cell click, only button can be clicked
        
        return cell;
    }
}

- (IBAction)upvoteButtonPressed:(UIButton *)sender {

	//	figure out in what cell we actually clicked on
	//	NOTE: there are many other ways to this, using delegates on the cell etc
	AnswersTableViewCell *cell = nil;
	UIView *v = sender.superview;
	//	go up the view hierarchy until you find the cell
	while (v) {
		if ([v isMemberOfClass:[AnswersTableViewCell class]]) {
			cell = (AnswersTableViewCell *)v;
			break;
		}
		v = v.superview;
	}
	if (!cell) return;

	//	what is indexPath of this cell?
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	//	now we know what is data source index!
	Answer *ans = self.sortedAnswers[indexPath.row];

	PFUser *currentUser = [PFUser currentUser];
	BOOL didUpvoterVoteAlready = [ans.upvoters containsObject:currentUser.username]; //check if user already upvoted
		
	if (didUpvoterVoteAlready) {
		//update count button UI
		[sender setTitle:@"Upvote" forState:UIControlStateNormal];

		NSMutableArray *mupvoters = [ans.upvoters mutableCopy];
		[mupvoters removeObject:currentUser.username];
		ans.upvoters = mupvoters;

	} else {
		//update count button UI
		[sender setTitle:@"Downvote" forState:UIControlStateNormal];
		
		NSMutableArray *mupvoters = [ans.upvoters mutableCopy];
		[mupvoters addObject:currentUser.username];
		ans.upvoters = mupvoters;
	}
        
	ans.upvotes = @( ans.upvoters.count );
	[ans saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error: %@ %@", error, [error userInfo]);
			return;
		}

		//update count label UI
		if (ans.upvotes.integerValue == 1) {
			cell.answerLikeCountLabel.text = [NSString stringWithFormat:@"%@ vote", ans.upvotes];
		} else {
			cell.answerLikeCountLabel.text = [NSString stringWithFormat:@"%@ votes", ans.upvotes];
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
        destViewController.questionAsked = self.qst.question;
        destViewController.questionAskedID = self.qst.objectId;
        destViewController.userWhoAskedQuestion = self.qst.username;
        destViewController.avatarForUserWhoAskedQuestion = self.avatarForUserWhoAskedQuestion;
    }
}

- (void) loadTableviewData {
    self.answerersImage = [NSMutableDictionary dictionary];

	PFQuery *query1 = [PFQuery queryWithClassName:@"Answer"];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        
        self.answers = objects;

        //find images for answerers
		/**
		 *	Again, this is very, very inefficient, must a better way without so many requests
		 */
        PFQuery *query2 = [PFQuery queryWithClassName:@"_User"];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *things, NSError *error2) {
            if (error2) {
                NSLog(@"Error: %@ %@", error2, [error2 userInfo]);
                return;
            }


            for (PFObject *thing in things) {
				NSString *key = thing[@"username"];
                NSString *avatar = thing[@"avatar"];
				self.answerersImage[key] = avatar;
            }

            //reload data
            [self.tableView reloadData];
        }];
    }];
}

- (NSArray *)sortedAnswers {
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"upvotes" ascending:NO];
    return [self.answers sortedArrayUsingDescriptors:@[sd]];
}

@end