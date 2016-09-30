//
//  JLMediaTableViewCell.m
//  lingerMedia
//
//  Created by eall_linger on 16/9/30.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "JLMediaTableViewCell.h"

@implementation JLMediaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(10);
            make.height.mas_equalTo(self.contentView.mas_height).offset(-20);
            make.width.mas_equalTo(self.contentView.mas_height).offset(-20).multipliedBy(1.2);
        }];
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.numberOfLines = 0;
        self.nameLabel.textColor = MainColor;
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
            make.right.mas_equalTo(self.contentView);
            make.top.bottom.mas_equalTo(self.contentView);
        }];
    }
    return self;
}
@end
