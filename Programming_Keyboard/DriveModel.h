

#ifndef DRIVEMODEL_H
#define DRIVEMODEL_H

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@protocol FileSyncDelegate <NSObject>
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLDriveFileList *)response
                          error:(NSError *)error;
@end

@interface DriveModel : NSObject
@property (nonatomic, weak) GTLServiceDrive *service;
@property (nonatomic, weak) id<FileSyncDelegate> delegate;

- (void)fetchFiles;

- (void) SetupSketch;

@end

#endif
