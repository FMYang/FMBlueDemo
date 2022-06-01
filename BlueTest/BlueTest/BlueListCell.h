//
//  BlueListCell.h
//  BlueTest
//
//  Created by yfm on 2020/10/30.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BlueListCellDelegate <NSObject>

- (void)didClickConnect:(NSIndexPath *)indexPath;

@end

@interface BlueListCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<BlueListCellDelegate> delegate;

- (void)configCell:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
