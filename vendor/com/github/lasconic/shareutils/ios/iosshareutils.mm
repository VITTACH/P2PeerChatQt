#import "iosshareutils.h"
#import <QQuickWindow>
#import <UIKit/UIKit.h>
#import <QGuiApplication>

IosShareUtils::IosShareUtils(QQuickItem *parent):
    PlatformShareUtils(parent) {}

void IosShareUtils::share(const QString &text, const QUrl &url) {

      NSMutableArray *sharingItems = [NSMutableArray new];

      if (!text.isEmpty()) [sharingItems addObject:text.toNSString()];

      if (url.isValid()) [sharingItems addObject:url.toNSURL()];

      // get the main window rootViewController
      UIViewController *qtController = [[UIApplication sharedApplication].keyWindow rootViewController];

      UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
      if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) { // iOS8
            activityController.popoverPresentationController.sourceView=qtController.view;
      }
      [qtController presentViewController:activityController animated:YES completion:nil];
}


