#import "DriveModel.h"
#import "GTLDrive.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const PathName = @"_keyboard";
static NSString *const SketchName = @"_sketch.txt";

@interface DriveModel()
@property (nonatomic, strong) NSString* rst;
//@property (nonatomic, strong) ;
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

- (void) Commit:(NSString*) codes{
    NSLog(@"Commit: %@", codes);
    UIAlertView *alert = [DriveModel showLoadingMessageWithTitle:@"Commiting the code to cloud..."
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
            //NSLog(@"File %@", updatedFile);
        } else {
            NSLog(@"An error occurred: %@", error);
        }
        [alert dismissWithClickedButtonIndex:0 animated:YES];

    }];
}

- (void) QueryFile:(NSString*) name
          callback:(void (^)(GTLDriveFileList* fileList)) completionHandler
    failedCallback:(void (^)(NSError *error)) failHandler{
    NSLog(@"QueryFile: %@", name);
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"name = '%@'", name];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFileList *fileList,
                                                         NSError *error) {
        if (error == nil) {
            completionHandler(fileList);
        } else {
            NSLog(@"An error occurred when querying file: %@ with %@", name, error);
            if(failHandler) failHandler(error);
        }
    }];
}

- (void) Readfile:(NSString* ) identifier
         Callback:(void (^)(NSString* data)) completionHandler{
    NSLog(@"Readfile: %@", identifier);
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",
                     identifier];
    GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:url];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        NSString* newStr = nil;
        if (error == nil) {
            // Do something with data
            
            newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Retrieved file content: %@",newStr);

            completionHandler(newStr);

        } else {
            NSLog(@"An error occurred: %@", error);
        }
       
    }];
}

- (void) CreateFile:(NSString *) name
           parentId:(NSString *) parentIdentifier
          withValue:(NSString *) content
           callback:(void (^)(GTLDriveFile *createdFile)) completionHandler{
    NSLog(@"To Created file %@", name);
    NSString *mimeType = @"text/plain";
    GTLDriveFile *metadata = [GTLDriveFile object];
    metadata.name = name;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
    if(parentIdentifier!=nil) metadata.parents = @[parentIdentifier];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesCreateWithObject:metadata
                                                       uploadParameters:uploadParameters];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFile *file,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"Created file %@", file);
            completionHandler(file);
            //self.SketchID = updatedFile.identifier;
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
}

- (void) CreateFolder:(NSString *) name
           parentId:(NSString *) parentIdentifier
           callback:(void (^)(GTLDriveFile *createdFolder)) completionHandler{
    NSLog(@"To Created Folder %@", name);
    GTLDriveFile *folder = [GTLDriveFile object];
    folder.name = PathName;
    folder.mimeType = @"application/vnd.google-apps.folder";
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesCreateWithObject:folder
                                                       uploadParameters:nil];
    if(parentIdentifier!=nil) folder.parents = @[parentIdentifier];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFile *folder,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"Created Folder %@", name);
            completionHandler(folder);
        }else{
            NSLog(@"An error occurred when creating the file: %@ with %@", name, error);
        }
    }];
}


- (void) SetupSketch{
    NSLog(@"to SetupSketch");
    UIAlertView *alert = [DriveModel showLoadingMessageWithTitle:@"Setting up sketch board on cloud..."
                                                delegate:self];
    [self QueryFile:PathName callback:^(GTLDriveFileList* fileList){
        
        if([fileList.files count]>0){
            GTLDriveFile *workingFolder = (fileList.files[0]);
            self.WorkSpaceID = workingFolder.identifier;
            [self QueryFile:SketchName
            callback:^(GTLDriveFileList* sketchList){
                
                GTLDriveFile *updatedFile = (sketchList.files[0]);
                self.SketchID = updatedFile.identifier;
                [self Readfile:self.SketchID
                Callback:^(NSString* newStr){
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [self.delegate populateTextField:newStr];
                }];
            } failedCallback:nil];
            return;
        }
        //create the folder:
        [self CreateFolder:PathName
                  parentId:nil
        callback:^(GTLDriveFile *createdFolder){
            
            self.WorkSpaceID = createdFolder.identifier;
            [self CreateFile:SketchName
                    parentId:createdFolder.identifier
                   withValue:@"Start typing your code here..."
            callback:^(GTLDriveFile *createdFile){
                
                self.SketchID = createdFile.identifier;
                [self Readfile:self.SketchID
                Callback:^(NSString* newStr){
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [self.delegate populateTextField:newStr];
                }];
            }];
        }];
    }
     failedCallback:nil];
    
}

- (void) SetupCompletion:(NSString *) language{
    NSLog(@"to SetupCompletion");

    NSString* filename = [NSString stringWithFormat:@"_Schema_%@", language];
    NSString* fullFilename = [NSString stringWithFormat:@"%@.txt", filename];

    UIAlertView *alert = [DriveModel showLoadingMessageWithTitle:@"Reading completion from cloud..."
                                                delegate:self];
    [self QueryFile:fullFilename
    callback:^(GTLDriveFileList* fileList){
        GTLDriveFile *file = (fileList.files[0]);
        if(file){
            NSLog(@"successfully loaded schema from cloud");
            [self Readfile:file.identifier Callback:^(NSString* data){
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [self.delegate populateCompletion:language withCompletion:data];
            }];
        }else{
            NSLog(@"cannot find cloud schema, loading default");
            NSString* filename = [NSString stringWithFormat:@"_Schema_%@", language];
            NSString* filePath =
            [[NSBundle mainBundle] pathForResource:filename
                                            ofType:@"txt"
                                       inDirectory:nil];
            NSLog(@"%@", [NSBundle mainBundle]);
            NSString* data = [[NSString alloc] initWithData:
                              [NSData dataWithContentsOfFile:filePath]
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"\n\nthe string %@",data);
            [self.delegate populateCompletion:language withCompletion:data];
            [self CreateFile:fullFilename parentId:nil withValue:data callback:^(GTLDriveFile *created){
                NSLog(@"remote schema created");
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            }];
        }
    } failedCallback:nil];
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
