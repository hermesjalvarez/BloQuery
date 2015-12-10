#import <UIKit/UIKit.h>

@interface QuestionsTableViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *questionLabel;
@property(nonatomic,strong) IBOutlet UILabel *questionCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotOne;
@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotTwo;
@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotThree;

@end