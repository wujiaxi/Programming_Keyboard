#import "DriveModel.h"
#import "GTLDrive.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const PathName = @"_keyboard";
static NSString *const SketchName = @"_sketch.txt";

@interface DriveModel()
@property (nonatomic, strong) NSString* rst;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) NSString* SketchID;
@property (nonatomic, strong) NSString* WorkSpaceID;

@end

@implementation DriveModel

- (instancetype) init{
    if(self = [super init]){
        
    }
    return self;
}

- (NSString*) GetSketchPath{
    return [NSString stringWithFormat:@"/%@/%@", PathName, SketchName];
}

- (void) commit:(NSString*) codes{
    self.alert = [DriveModel showLoadingMessageWithTitle:@"Commiting the code to cloud..."
                                                delegate:self];
    NSString *name = SketchName;
    NSString *content = codes;
    NSString *mimeType = @"text/plain";
    GTLDriveFile *metadata = [GTLDriveFile object];
    metadata.name = name;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data
                                                                                 MIMEType:mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesUpdateWithObject:metadata
                                                                 fileId:self.SketchID
                                                       uploadParameters:uploadParameters];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFile *updatedFile,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"File %@", updatedFile);
        } else {
            NSLog(@"An error occurred: %@", error);
        }
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];

    }];
}

- (void) SetupSketch{
    self.alert = [DriveModel showLoadingMessageWithTitle:@"Setting up sketch board on cloud..."
                                                delegate:self];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"name = '%@'", PathName];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFileList *fileList,
                                                  NSError *error) {
        if (error == nil) {
            if([fileList.files count] > 0){
                //fetch the file identifier
                GTLDriveFile *workingFolder = (fileList.files[0]);
                self.WorkSpaceID = workingFolder.identifier;
                GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
                query.q = [NSString stringWithFormat:@"name = '%@'", SketchName];
                [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                     GTLDriveFileList *fileList,
                                                                     NSError *error) {
                    if (error == nil) {
                        GTLDriveFile *updatedFile = (fileList.files[0]);
                        self.SketchID = updatedFile.identifier;
                        [self fetchData];
                    }
                    
                }];
                    //get the sketch identifier
                return;
            }
            
            //folder created, try to create new sketch file
            GTLDriveFile *folder = [GTLDriveFile object];
            folder.name = PathName;
            folder.mimeType = @"application/vnd.google-apps.folder";
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesCreateWithObject:folder
                                                               uploadParameters:nil];
            [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                 GTLDriveFile *updatedFile,
                                                                  NSError *error) {
                //create the sketch file here
                if (error == nil) {
                    //create the sketch file here
                    self.WorkSpaceID = updatedFile.identifier;
                    NSString *name = SketchName;
                    NSString *content = @"Start typing your code here...";
                    NSString *mimeType = @"text/plain";
                    GTLDriveFile *metadata = [GTLDriveFile object];
                    metadata.name = name;
                    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
                    metadata.parents = @[updatedFile.identifier];
                    GTLQueryDrive *query = [GTLQueryDrive queryForFilesCreateWithObject:metadata
                                                                       uploadParameters:uploadParameters];
                    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                         GTLDriveFile *updatedFile,
                                                                         NSError *error) {
                        if (error == nil) {
                            NSLog(@"File %@", updatedFile);
                            self.SketchID = updatedFile.identifier;
                        } else {
                            NSLog(@"An error occurred: %@", error);
                        }
                        [self fetchData];
                    }];
                } else {
                    NSLog(@"An error occurred: %@", error);
                }
            }];
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
}

- (void)fetchData{
    
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",
                     self.SketchID];
    GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:url];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSLog(@"Retrieved file content");
            // Do something with data
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.delegate populateTextField:newStr];

        } else {
            NSLog(@"An error occurred: %@", error);
        }
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }];
}


+ (UIAlertView *)showLoadingMessageWithTitle:(NSString *)title
                                    delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    UIActivityIndicatorView *progress=
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert addSubview:progress];
    [progress startAnimating];
    [alert show];
    return alert;
}

+ (void)showErrorMessageWithTitle:(NSString *)title
                          message:(NSString*)message
                         delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
