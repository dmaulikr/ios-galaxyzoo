//
//  ExamplesCollectionViewCell.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExamplesCollectionViewCellButton.h"

@interface ExamplesCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ExamplesCollectionViewCellButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
