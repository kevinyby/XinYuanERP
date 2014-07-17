#import "AppDropboxExporter.h"
#import "AppInterface.h"

@implementation AppDropboxExporter

/** Export data from network
    @prama object , which contains id or orderNO, send to get all the object values from server*/
+(void) exportDb: (NSString*)model department:(NSString*)department object:(NSDictionary*)object {
    if (! [DropboxSyncAPIManager getLinkedAccount]) {
        [DropboxSyncAPIManager authorize: VIEW.navigator.topViewController];
        [ACTION alertMessage:@"Contact Administrator . Authorize DropBox on you device . Then do export again . "];
    } else {
        // Then send request to get all model informations
        
        RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
        requestModel.path = PATH_LOGIC_READ(department);
        [requestModel addModels: model, nil];
        [requestModel addObjects: object, nil];
        
        [DATA.requester startPostRequest: requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            
            if (error) {
                [self alertResult: NO];
            } else {
                
                BOOL success = YES;
                NSArray* outterModels = (NSArray*)data.results;   // all types models you need
                for (int i = 0; i < outterModels.count; i++) {
                    NSArray* specifiedModels = [outterModels objectAtIndex: i];     // the specified model you need
                    for (int j = 0; j < specifiedModels.count; j++) {
                        NSDictionary* resultModel = [specifiedModels objectAtIndex:j];  // the keys-values need to export
                        BOOL exportSuccess = [self exportDb:model department:department dictionary:resultModel];
                        success = success && exportSuccess;
                    }
                }
                [self alertResult: success];
            }
            
        }];
    }
}

/** dictionary is the keys-values need to export */
+(BOOL) exportDb: (NSString*)model department:(NSString*)department dictionary:(NSDictionary*)dictionary {
    // write to sanbox
    [AppCSVFileWriter writeModel: dictionary model:model department:department];
    
    // get csv path
    NSString* orderNO = [dictionary objectForKey: PROPERTY_ORDERNO];
    NSString* csvFullPath = [AppCSVFileWriter getCSVSaveFullPath: model department:department orderNO:orderNO];
    NSString* csvRelativePath = [AppCSVFileWriter getCSVSaveRelativePath:model department:department orderNO:orderNO];
    
    // upload to dropbox
    BOOL successfully = [DropboxSyncUploader upload: csvRelativePath localPath:csvFullPath];
    
    // delete the origin csv file in sanbox
    [FileManager deleteFile: csvFullPath];
    
    return successfully;
}


+(void) alertResult: (BOOL)success {
    NSString* title = !success ? @"Export To Dropbox Failed" : @"Export To Dropbox Success";
    NSString* message = !success ? @"Please checkout connection and export again." : @"Please check file in Dropbox and download it.";
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
