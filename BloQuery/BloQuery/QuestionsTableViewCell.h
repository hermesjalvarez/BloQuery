#import <UIKit/UIKit.h>

@interface QuestionsTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *username;
@property(nonatomic,strong) IBOutlet UILabel *questionLabel;
@property(nonatomic,strong) IBOutlet UILabel *questionCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotOne;
@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotTwo;
@property (weak, nonatomic) IBOutlet UIImageView *questionPopularitySlotThree;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@end