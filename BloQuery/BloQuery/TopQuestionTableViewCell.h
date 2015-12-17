#import <UIKit/UIKit.h>

@interface TopQuestionTableViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *topQuestionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topQuestionAvatar;
@property (weak, nonatomic) IBOutlet UILabel *topQuestionAvatarLabel;

@end
