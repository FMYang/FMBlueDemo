//
//  AppDelegate.m
//  FMBlueCentralDemo
//
//  Created by yfm on 2021/10/29.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
//    CFByteOrder order = CFByteOrderGetCurrent();
//    if(order == CFByteOrderLittleEndian) {
//        NSLog(@"小端");
//    } else if (order == CFByteOrderBigEndian) {
//        NSLog(@"大端");
//    }
    
//    UInt64 x = 0x243c0b00243c;
//    UInt64 nx = CFSwapInt64HostToBig(x);
//    NSLog(@"fm %llx", nx);
    
    return YES;
}

@end
