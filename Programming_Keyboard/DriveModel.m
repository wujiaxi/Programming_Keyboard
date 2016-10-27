#import "DriveModel.h"
#import "GTLDrive.h"
#import <Foundation/Foundation.h>
static NSString *const PathName = @"_keyboard";
static NSString *const SketchName = @"_sketch.txt";

@implementation DriveModel

- (void)fetchFiles {
    NSLog(@"Getting files...");
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.pageSize = 10;
    query.fields = @"nextPageToken, files(id, name)";
    [self.service executeQuery:query
                      delegate:self.delegate
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

- (NSString*) GetSketchPath{
    return [NSString stringWithFormat:@"/%@/%@", PathName, SketchName];
}


- (void) SetupSketch{
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"name = 'sketch.txt'"];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFileList *fileList,
                                                  NSError *error) {
        if (error == nil) {
            NSLog(@"Have results");
            // Iterate over fileList.files array
            if([fileList ] > 0) return;
            GTLDriveFile *folder = [GTLDriveFile object];
            folder.name = PathName;
            folder.mimeType = @"application/vnd.google-apps.folder";
            
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesCreateWithObject:folder
                                                               uploadParameters:nil];
            [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                 GTLDriveFile *updatedFile,
                                                                 NSError *error) {
                if (error == nil) {
                    NSLog(@"Created folder");
                } else {
                    NSLog(@"An error occurred: %@", error);
                }
            }];
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
    
}
@end
