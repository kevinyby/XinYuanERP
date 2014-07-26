//
//  Store.m
//  Photolib
//
//  Created by bravo on 14-6-11.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "Store.h"
#import "Card.h"
#import "SDWebImageManager.h"
#import "exifTagger.h"

#import "_HTTP.h"

#define test_ip @"http://61.143.227.60:8051/service/"

@interface Store()
@property (nonatomic,strong) NSDictionary* rawData;
@property (nonatomic, strong) NSArray* albums;
@property (nonatomic, strong) NSArray* photos;

@end

@implementation Store{
    NSString* _curlevelPath;
    NSMutableDictionary* _curlevelDic;
    NSMutableDictionary* _mutableData;
    
    NSMutableArray* _curAlbums;
    NSMutableArray* _curPhotos;
}

-(id) init{
    self = [super init];
    if (self){
    }
    return self;
}

-(void)initiateWithComplete:(void(^)(NSError* error))callback{
    //start request
    HTTPPostRequest* request = [[HTTPPostRequest alloc] initWithURLString:[self rest_api_with:@"struct"] parameters:@{@"PATH":@"BusinessCards"}];
    [request startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError){
            self.rawData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            _mutableData = [self deepMutableCopy:self.rawData];
            self.albums = [self allAlbumsInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
            self.photos = [self allPhotosInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
            _curlevelDic = [[NSMutableDictionary alloc] init];
            _curAlbums = [[NSMutableArray alloc] init];
            _curPhotos = [[NSMutableArray alloc] init];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(connectionError);
        });
    }];
}

-(NSArray*) allPhotosInDic:(NSDictionary*)data atPath:(NSString*)path{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    if (data[@"content"]){
        for (NSString* key in data[@"content"]){
            [result addObjectsFromArray:[self allPhotosInDic:data[@"content"][key] atPath:[path stringByAppendingPathComponent:key]]];
        }
    }else{
        id pwd = [NSNull null];
        if (data[@"pwd"])
            pwd = [NSString stringWithFormat:@"%@",data[@"pwd"]];
        [result addObject:@[path,pwd]];
    }
    return result;
}

-(NSArray*) allAlbumsInDic:(NSDictionary*)data atPath:(NSString*)path{
    if (!data[@"content"])return nil;
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [result addObject:@[path,data[@"pwd"]?data[@"pwd"]:[NSNull null]]];
    for (NSString* key in data[@"content"]){
        [result addObjectsFromArray:[self allAlbumsInDic:data[@"content"][key] atPath:[path stringByAppendingPathComponent:key]]];
    }
    return result;
}

//note this method just use cached data(self.albums) to generate model objects, that means it might get out of date. use with caution.
-(NSArray*)getAlbums{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.albums.count];
    for (NSArray* part in self.albums){
        NSString* name = [[part[0] componentsSeparatedByString:@"/"] lastObject];
        if ([name isEqualToString:@"BusinessCards"]) name = @"*名片首页*";
        NSMutableArray* mutComs = [[part[0] componentsSeparatedByString:@"/"] mutableCopy];
        [mutComs insertObject:@"thumbnails" atIndex:mutComs.count-1];
        NSString* thumbPath = [[mutComs componentsJoinedByString:@"/"] stringByAppendingPathExtension:@"jpg"];
        NSString* password = nil;
        if (part[1] != [NSNull null]){
            password = [part[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        Card* newCard = [[Card alloc] initWithPath:[self nsurlWithPath:part[0]]
                                             thumb:nil
                                         thumbPath:[self thumbnailDownloadPathWithPath:thumbPath] name:name
                                          password:password
                                             album:YES];
        [result addObject:newCard];
    }
    return result;
}

// same as above
-(NSArray*)getPhotos{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.photos.count];
    for (NSArray* part in self.photos){
        NSString* name = [[part[0] componentsSeparatedByString:@"/"] lastObject];
        NSString* downloadPahth = [part[0] stringByAppendingPathExtension:@"jpg"];
        NSMutableArray* mutComs = [[downloadPahth componentsSeparatedByString:@"/"] mutableCopy];
        [mutComs insertObject:@"thumbnails" atIndex:mutComs.count-1];
        NSString* thumbPath = [mutComs componentsJoinedByString:@"/"];
        downloadPahth = [self imageDownloadPathWithPath:downloadPahth];
        
        NSString* password = nil;
        if (![part[1] isKindOfClass:[NSNull class]] && ![part[1] isEqualToString:@"<null>"]){
            password = [part[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        Card* photo = [[Card alloc] initWithPath:downloadPahth thumb:nil thumbPath:[self thumbnailDownloadPathWithPath:thumbPath] name:name password:password album:NO];
        [result addObject:photo];
    }
    return result;
}

-(BOOL) hasAlbumInPath:(NSString *)path{
    NSString* keyPath = [self path2IndexPaths:path];
    if ([self.rawData valueForKeyPath:keyPath]){
        return YES;
    }
    return NO;
}

-(NSURL*)thumbpath{
    return [NSURL URLWithString:@"http://s1.cn.bing.net/th?id=OJ.Ui1snPxx1Rsmhg&pid=MSNJVFeeds"];
}

-(UIImage*) getThumbWithPath:(NSString*)path{
    return [UIImage imageNamed:@"test.jpg"];//for test
}


-(NSDictionary*)dataWithPath:(NSString *)path{
//    if ([path isEqualToString:_curlevelPath]){
//        return [self currentLevelData];
//    }
    _curlevelPath = path;
    NSString* validPath = [self path2IndexPaths:path];
    NSDictionary* cur_level_temp = [self.rawData valueForKeyPath:validPath];
    if (!cur_level_temp) {
        [_curAlbums removeAllObjects];
        [_curPhotos removeAllObjects];
        return nil;
    }
    _curlevelDic = [self deepMutableCopy:cur_level_temp];
    if (_curlevelDic && _curlevelDic[@"content"]){
        NSDictionary* contents = _curlevelDic[@"content"];
        [_curAlbums removeAllObjects];
        [_curPhotos removeAllObjects];
        for (id key in contents) {
            NSDictionary* item = contents[key];
            if (item){
                BOOL isalbum = item[@"content"]?YES:NO;
                __weak NSMutableArray* whichToInsert = isalbum?_curAlbums:_curPhotos;

                NSString* enterPath = [path stringByAppendingPathComponent:key];
                
                NSString* thumbPath;
                //thumbnial path
                NSMutableArray* mutableThumbComps = [[enterPath componentsSeparatedByString:@"/"] mutableCopy];
                [mutableThumbComps insertObject:@"thumbnails" atIndex:mutableThumbComps.count-1];
                
                if (!isalbum){
                    enterPath = [enterPath stringByAppendingPathExtension:@"jpg"];
                    enterPath = [self imageDownloadPathWithPath:enterPath];
                }
                thumbPath = [self thumbnailDownloadPathWithPath:[[mutableThumbComps componentsJoinedByString:@"/"] stringByAppendingPathExtension:@"jpg"]];
                NSString* pwd = nil;
                if (item[@"pwd"] != [NSNull null]){
                   pwd = [item[@"pwd"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
                Card* insertone = [[Card alloc] initWithPath:enterPath thumb:nil thumbPath:thumbPath name:item[@"name"] password:pwd album:isalbum];
                
                [whichToInsert
                 addObject:insertone];
            }
        }
    }
    return @{@"AlbumCell":_curAlbums,
             @"PhotoCell":_curPhotos};
}

-(NSString*) urlWithAPI:(NSString*)api withPath:(NSString*)path{
    return [NSString stringWithFormat:@"%@?%@",[self rest_api_with:api], path];
}

-(NSString*) imageDownloadPathWithPath:(NSString*)path{
    return [self urlWithAPI:@"download" withPath:path];
}

-(NSString*) thumbnailDownloadPathWithPath:(NSString*)path{
    return [self urlWithAPI:@"getthumbnails" withPath:path];
}

-(NSString*) rest_api_with:(NSString*)api{
    return [test_ip stringByAppendingPathComponent:api];
}

-(NSDictionary*) currentLevelData{
    return @{@"AlbumCell":_curAlbums,
             @"PhotoCell":_curPhotos};
}

-(NSString*) path2IndexPaths:(NSString*)path{
    NSArray* components = [path componentsSeparatedByString:@"/"];
    NSString* indexPaths = path;
    if (components.count > 1){
        indexPaths = [components componentsJoinedByString:@".content."];
    }
    return indexPaths;
}

-(NSString*) path2IndexPathsContent:(NSString*)path{
    NSString* p = [self path2IndexPaths:path];
    return [p stringByAppendingString:@".content"];
}

-(NSURL*) nsurlWithPath:(NSString*)path{
//    return [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/75635128/SouthPark.jpg"];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:path];
}

-(NSString*) rootPath{
    return [[self.rawData allKeys] firstObject];
}




-(NSArray*) photosArray{
    NSMutableArray* p = [[NSMutableArray alloc] initWithCapacity:_curPhotos.count];
    for (Card* c in _curPhotos){
        [p addObject:c.photo];
    }
    return p;
}


-(void) createAlbumAtPath:(NSString*)path name:(NSString*)name passwd:(NSString*)passwd complete:(createAlbumCallback)callback{
    
//    NSString* encodedPath = [[path stringByAppendingPathComponent:name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedPath = [path stringByAppendingPathComponent:name];
    NSMutableDictionary* createParam = [[NSMutableDictionary alloc] init];
    [createParam setValue:encodedPath forKey:@"path"];
    if (passwd){
        [createParam setObject:passwd forKey:@"pwd"];
    }
    HTTPRequestBase* uploadRequest = [[HTTPPostRequest alloc]
                                      initWithURLString:[test_ip stringByAppendingPathComponent: @"newfolder"]
                                      parameters:createParam];
    [uploadRequest startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError){
            Card* newAlbum = [[Card alloc] initWithPath:[NSURL URLWithString:encodedPath] thumb:nil thumbPath:[self thumbpath] name:name password:passwd album:YES];
            //do some request here
            [_curAlbums addObject:newAlbum];
            NSDictionary* temp = @{@"name":newAlbum.name,
                                   @"path":encodedPath,
                                   @"date":[NSNull null],
                                   @"content":@{}};
            NSMutableDictionary* mut_new = [self deepMutableCopy:temp];
            if (passwd) [mut_new setValue:passwd forKey:@"pwd"];
            [_curlevelDic setValue:mut_new forKeyPath:[NSString stringWithFormat:@"content.%@",name]];
            
            NSString* newIndexPaths = [self path2IndexPaths:_curlevelPath];
            //    newIndexPaths = [NSString stringWithFormat:@"%@.content",newIndexPaths];
            [_mutableData setValue:_curlevelDic forKeyPath:newIndexPaths];
            self.rawData = [[NSDictionary alloc] initWithDictionary:_mutableData];
            self.albums = [self allAlbumsInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(connectionError, [self dataWithPath:_curlevelPath]);
        });
        
    }];
}

-(void) removeItemWithNames:(NSArray *)names complete:(deleteItemCallback)callback{
    
    NSMutableDictionary* deleteParams = [[NSMutableDictionary alloc] initWithCapacity:names.count];
    for (NSString* name in names){
        NSDictionary* delete = [_curlevelDic[@"content"] objectForKey:name];
        NSString* delPath = [_curlevelPath stringByAppendingPathComponent:name];
        if (!delete[@"content"])
            delPath = [delPath stringByAppendingPathExtension:@"jpg"];
        [deleteParams setObject:delPath forKey:name];
    }
    HTTPRequestBase* request = [[HTTPPostRequest alloc] initWithURLString:[self rest_api_with:@"delete"] parameters:deleteParams];
    [request startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (! connectionError){
            [_curlevelDic[@"content"] removeObjectsForKeys:names];
            [_mutableData setValue:_curlevelDic forKeyPath:[self path2IndexPaths:_curlevelPath]];
            self.rawData = [[NSDictionary alloc] initWithDictionary:_mutableData];
            self.albums = [self allAlbumsInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
            self.photos = [self allPhotosInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(connectionError, [self dataWithPath:_curlevelPath]);
        });
    }];
}


-(void) moveItemWithName:(NSArray*)names
                  toPath:(NSString*)path
                complete:(void (^)(NSError* error))callback{

    NSMutableDictionary* moveParam = [[NSMutableDictionary alloc] initWithCapacity:names.count];
    NSMutableArray* validNames = [NSMutableArray arrayWithArray:names];
    for (NSString* name in names){
        if ([path hasPrefix:[_curlevelPath stringByAppendingPathComponent:name]]){
            [validNames removeObject:name];
            continue;
        }
        NSString* srcPath = [_curlevelPath stringByAppendingPathComponent:name];
        NSString* dstPath = [path stringByAppendingPathComponent:name];
        
        NSDictionary* theOne =  _curlevelDic[@"content"][name];
        if (!theOne[@"content"]){//photo
            srcPath = [srcPath stringByAppendingPathExtension:@"jpg"];
            dstPath = [dstPath stringByAppendingPathExtension:@"jpg"];
        }
        
//        NSString* valid_srcPath = [srcPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString* valid_dstPath = [dstPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [moveParam setObject:dstPath forKey:srcPath];
    }
    if (moveParam.count == 0){
        callback(nil);
        return;
    }
    HTTPPostRequest* moveRequest = [[HTTPPostRequest alloc] initWithURLString:[self rest_api_with:@"move"] parameters:moveParam];
    [moveRequest startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError){
            for (NSString* name in validNames){
                NSMutableArray* item = [_curlevelDic[@"content"] objectForKey:name];
                [_curlevelDic[@"content"] removeObjectForKey:name];
                [_mutableData setValue:_curlevelDic forKeyPath:[self path2IndexPaths:_curlevelPath]];
                NSString* destIndexPath = [self path2IndexPathsContent:path];
                destIndexPath = [destIndexPath stringByAppendingFormat:@".%@",name];
                [_mutableData setValue:item forKeyPath:destIndexPath];
                self.rawData = [[NSDictionary alloc] initWithDictionary:_mutableData];
                //update album & photo is critical, even if we don't do any add/remove operation. because the file structure
                //might be changed, that means PATH is out of date, so we need to update it here.
                self.albums = [self allAlbumsInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
                self.photos = [self allPhotosInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil);
        });
    }];
}

-(void) replaceItemAtPath:(NSString *)path toNewPath:(NSString*)newPath withData:(NSDictionary *)newData complete:(void (^)(NSError *))callback{
    
    NSDictionary* selected = _curlevelDic[@"content"][[path lastPathComponent]];
    NSString* oldPath = path;
    NSString* oldThumb;
    NSMutableArray* mutThumb = [[oldPath componentsSeparatedByString:@"/"] mutableCopy];
    [mutThumb insertObject:@"thumbnails" atIndex:mutThumb.count-1];
    oldThumb = [mutThumb componentsJoinedByString:@"/"];
    
    NSString* aNewPath = newPath;
    NSString* newThumb;
    mutThumb = [[newPath componentsSeparatedByString:@"/"] mutableCopy];
    [mutThumb insertObject:@"thumbnails" atIndex:mutThumb.count-1];
    newThumb = [mutThumb componentsJoinedByString:@"/"];
    
    newThumb = [newThumb stringByAppendingPathExtension:@"jpg"];
    oldThumb = [oldThumb stringByAppendingPathExtension:@"jpg"];
    
    if (!selected[@"content"]){
        aNewPath = [newPath stringByAppendingPathExtension:@"jpg"];
        oldPath = [oldPath stringByAppendingPathExtension:@"jpg"];
        
    }
//    oldPath = [oldPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    aNewPath = [aNewPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    oldThumb = [oldThumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    newThumb = [newThumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* editParam = @{oldPath:aNewPath, oldThumb:newThumb};
    
    HTTPPostRequest* editRequest = [[HTTPPostRequest alloc] initWithURLString:[self rest_api_with:@"rename"] parameters:editParam];
    [editRequest startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError){
            NSString* keyPath = [self path2IndexPaths:path];
            NSMutableDictionary* selected = [self deepMutableCopy:[self.rawData valueForKeyPath:keyPath]];
            for (NSString* key in newData){
                if (selected[key]){
                    selected[key] = newData[key];
                }
            }
            NSMutableArray* sepPath = [[path componentsSeparatedByString:@"/"] mutableCopy];
            int pathLen = sepPath.count;
            NSString* tailKeyPath = [self path2IndexPathsContent:[[sepPath subarrayWithRange:(NSRange){0,pathLen-1}] componentsJoinedByString:@"/"]];
            NSMutableDictionary* tailed = [_mutableData valueForKeyPath:tailKeyPath];
            [tailed removeObjectForKey:[sepPath lastObject]];
            
            [_mutableData setValue:selected forKeyPath:[self path2IndexPaths:newPath]];
            self.rawData = [[NSDictionary alloc] initWithDictionary:_mutableData];
            self.albums = [self allAlbumsInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
            self.photos = [self allPhotosInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(connectionError);
        });
    }];
}

-(void) addPhotoAtPath:(NSString *)path
              withData:(NSData *)imageData
              complete:(void (^)(NSError *, UIImage *))callback{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //compress image
        UIImage* raw = [UIImage imageWithData:imageData];
        NSData* compressedData = UIImageJPEGRepresentation(raw, 0.3);
        UIImage* compressedImage = [UIImage imageWithData:compressedData];
        
        NSArray* sep = [path componentsSeparatedByString:@"/"];
        NSString* fileName = [path stringByAppendingPathExtension:@"jpg"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            HTTPRequestBase* request = [[HTTPUploader alloc] initWithURLString:[test_ip stringByAppendingPathComponent: @"upload"] parameters:@{UPLOAD_Data: imageData, UPLOAD_FileName: fileName,UPLOAD_MIMEType: @"image/jpeg",UPLOAD_FormParameters: @{@"key": @"1"}}];
            
            [request startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (! connectionError){
                    NSString* ownerKeyPath = [self path2IndexPaths:[[sep subarrayWithRange:(NSRange){0,sep.count - 1}] componentsJoinedByString:@"/"]];
                    NSMutableDictionary* ownerValue = [_mutableData valueForKeyPath:ownerKeyPath];
                    NSMutableDictionary* ownerContent = ownerValue[@"content"];
                    
                    
                    NSDictionary* dict = @{@"name":[sep lastObject]};
                    [ownerContent setValue:[dict mutableCopy] forKey:[sep lastObject]];
                    
                    self.rawData = [[NSDictionary alloc] initWithDictionary:_mutableData];
                    self.photos = [self allPhotosInDic:self.rawData[@"BusinessCards"] atPath:@"BusinessCards"];
                    
                    NSString* cachePath = [[[self imageDownloadPathWithPath:path] stringByAppendingPathExtension:@"jpg"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    //always cache the original file to disk, that will maintan the EXIF info
                    [[SDImageCache sharedImageCache] storeImage:compressedImage recalculateFromImage:NO imageData:imageData forKey:cachePath toDisk:YES];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(connectionError, compressedImage);
                });
            }];
        });
    });
}

-(NSMutableDictionary*) deepMutableCopy:(NSDictionary*)dict{
    //warning: this function works only if your dict is
    //a pure (nested)dictionary, not nested with other kind of imutable
    //type like: NSArray, use with caution.
    //ps: if you want a deep copy function support all mutable type
    //its better to check dictionaryhelper authored by issac
    NSMutableDictionary* cur = [dict mutableCopy];
    for (id key in dict){
        if ([cur[key] isKindOfClass:[NSDictionary class]]){
            cur[key] = [self deepMutableCopy:cur[key]];
        }
    }
    return cur;
}
@end
