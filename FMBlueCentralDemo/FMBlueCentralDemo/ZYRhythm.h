//
//  ZYRhythm.h


#import <Foundation/Foundation.h>


@interface ZYRhythm : NSObject


typedef void (^ZYBeatsBreakBlock)(ZYRhythm *bry);
typedef void (^ZYBeatsOverBlock)(ZYRhythm *bry);

//timer for beats
@property (nonatomic, strong) NSTimer *beatsTimer;

//beat interval
@property NSInteger beatsInterval;



#pragma mark beats
//心跳
- (void)beats;
//主动中断心跳
- (void)beatsBreak;
//结束心跳，结束后会进入BlockOnBeatOver，并且结束后再不会在触发BlockOnBeatBreak
- (void)beatsOver;
//恢复心跳，beatsOver操作后可以使用beatsRestart恢复心跳，恢复后又可以进入BlockOnBeatBreak方法
- (void)beatsRestart;

//心跳中断的委托
- (void)setBlockOnBeatsBreak:(void(^)(ZYRhythm *bry))block;
//心跳结束的委托
- (void)setBlockOnBeatsOver:(void(^)(ZYRhythm *bry))block;

@end
