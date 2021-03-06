

#ifndef DRIVEMODEL_H
#define DRIVEMODEL_H

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLRDrive.h"

@protocol FileSyncDelegate <NSObject>
- (void) populateTextField:(NSString* ) data;
- (void) populateCompletion:(NSString *) name
             withCompletion:(NSString *) data;
@end

@interface DriveModel : NSObject
@property (nonatomic, weak) GTLRDriveService *service;
@property (nonatomic, weak) id<FileSyncDelegate> delegate;

- (void) SetupSketch;

- (void) Commit:(NSString*) codes;

- (void) SetupCompletion:(NSString *) language;


@end

#endif
