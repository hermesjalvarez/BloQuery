#import <UIKit/UIKit.h>

@class AnswersTableViewCell;

@protocol AnswersTableViewCellDelegate <NSObject>

- (void) cellDidPressLikeButton:(AnswersTableViewCell *)cell;

@end

@interface AnswersTableViewCell : UITableViewCell

@property (nonatomic, weak) id <AnswersTableViewCellDelegate> delegate;

@property(nonatomic,strong) IBOutlet UILabel *answerLabel;

@property(nonatomic,strong) IBOutlet UILabel *answerLikeCountLabel;

@end
