

#ifndef DRIVEMODEL_H
#define DRIVEMODEL_H

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@protocol FileSyncDelegate <NSObject>
- (void) populateTextField:(NSString*) data;
@end

@interface DriveModel : NSObject
@property (nonatomic, weak) GTLServiceDrive *service;
@property (nonatomic, weak) id<FileSyncDelegate> delegate;

- (void) SetupSketch;

- (void) commit:(NSString*) codes;

@end

#endif
