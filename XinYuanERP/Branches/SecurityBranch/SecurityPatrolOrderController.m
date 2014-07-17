//
//  SecurityPatrolOrderViewController.m
//  XinYuanERP
//
//  Created by bravo on 13-12-16.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//
#define prefix @"SecurityPatrolBill"
#define LOCALIZE(value) LOCALIZE_CONNECT_KEYS(prefix,value)
#define AuthorityLevel 4


#import "SecurityPatrolOrderController.h"

static const int buttonWidth = 120;
static const int buttonHeight = 40;
static const int buttonMargin = 20;
static const int buttonOffset = buttonWidth + buttonMargin;

@interface SecurityPatrolOrderController () <UITableViewDelegate,UIImagePickerControllerDelegate,HTTPRequesterDelegate, UINavigationControllerDelegate>{
    NSMutableArray *content;
    JRHeaderTableView *table;
    NSString *uploadPath;
    BOOL editEnable;
    EditMode editMode;
    int authorityLevel;
    int currentPhotoIndex;
    NSString *currentPatrolID;
    NSString *lastPID;
    NSString* currentDate;
    NSString* orderDate;
    
    NSArray* cellButtons;
    NSArray* cellButtonsActions;
}

@end

@implementation SecurityPatrolOrderController


- (void)viewDidLoad
{
    [super viewDidLoad];
    editEnable = NO;
    authorityLevel = 4;
    currentDate = [DateHelper stringFromDate:[DateHelper truncateTime:[NSDate date]] pattern:DATE_PATTERN];
    uploadPath = @"Security/Patrol";
    [self setupTable];

    UIButton *editButton = (UIButton*)[self.jsonView getView:@"editButton"];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.jsonView.contentView addSubview:editButton];
    NSLog(@"%@",self.identification);
}

- (void)requestServer
{
    //request config file
    //uploadPath + config.txt
    [AppServerRequester readModel:@"SecurityPatrolOrder" department:DEPARTMENT_SECURITY objects:@{PROPERTY_IDENTIFIER:self.identification} fields:@[@"createDate"] completeHandler:^(ResponseJsonModel *data, NSError *error) {
        NSArray* dataArr = [NSArray arrayWithArray:data.results];
        orderDate = dataArr[0][0];

        NSString *configPath = [NSString stringWithFormat:@"%@.txt",[orderDate componentsSeparatedByString:@" "][0]];

        [HTTPBatchRequester startBatchDownloadRequest:@[@{@"PATH":configPath}]  url:IMAGE_URL(@"getpatrolconfig")  identifications:@[@"1"] delegate:self completeHandler:nil];
    }];
}

- (void)setupTable
{
    table = (JRHeaderTableView*)[self.jsonView getView:@"table"];
    [table setEditing:NO animated:YES];
    table.tableView.delegate = self;
    
    if(self.identification){
        [self requestServer];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    table.headers = @[LOCALIZE_KEY(LOCALIZE(@"routine")),LOCALIZE_KEY(LOCALIZE(@"checkEmployeeNO")),LOCALIZE_KEY(LOCALIZE(@"repairOrderNO"))];
    
    cellButtons = @[LOCALIZE_KEY(LOCALIZE(@"repair")),@"patrol_button1.png",LOCALIZE_KEY(LOCALIZE(@"checker")),@"patrol_button2.png",LOCALIZE_KEY(LOCALIZE(@"photo")),@"pass_cam.png"];
    
    void(^clickAction)(id sender) = ^(NormalButton* sender){
        NSIndexPath* indexPath = [TableViewHelper getIndexPath: table.tableView cellSubView:sender];
        NSLog(@"%d:%d",indexPath.row,sender.tag);
        switch (sender.tag) {
            case 1:
                //repair
                break;
            case 3:
                //checker
                [self checkerActionOnButton:sender atIndex:indexPath.row];
                break;
            case 5:
                //photo
                [self photoAction];
                currentPhotoIndex = indexPath.row;
                sender.enabled = NO;
                break;
        }
        
    };
    cellButtonsActions = @[[clickAction copy],clickAction,clickAction];
    
    table.headersXcoordinates = @[@20,@720,@880];
    table.valuesXcoordinates = @[@0];
}

#pragma mark - tableView dataSource




#pragma mark - button events
-(void) photoAction {
    PhotoPickerViewController *imagePicker = [[PhotoPickerViewController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];
}

-(void) checkerActionOnButton:(NormalButton*)button atIndex:(int)index{
    //get current user name
    NSString *currentName = @"User1";
    //check validation
    NSMutableArray *data = table.innerContent;
    NSDictionary *selectedData = data[index];
    
    if (selectedData[@"Image"] != [NSNull null]){
        //valid
        table.innerContent[index][@"Checker"] = currentName;
        [button setTitle:currentName forState:UIControlStateNormal];
        //start request to update data to remote
        RequestJsonModel *checkerModel = [RequestJsonModel getJsonModel];
        [checkerModel addModels:@"SecurityPatrolBill", nil];
        checkerModel.path = PATH_LOGIC_MODIFY(DEPARTMENT_SECURITY);
        [checkerModel.objects addObject:@{@"employeeNO":currentName}];
        [checkerModel.identities addObject:@{@"id":[table.innerContent[index][@"billID"] stringValue]}];
        
        [DATA.requester startPostRequest:checkerModel completeHandler:^(HTTPRequester*requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            NSLog(@"hero");
        }];
    }else{
        //photo not exists? boot the cam
        [self photoAction];
        currentPhotoIndex = index;
    }
}

#pragma mark - image picker controller
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* image = info[@"UIImagePickerControllerOriginalImage"];
    NSString *date = info[@"UIImagePickerControllerMediaMetadata"][@"{TIFF}"][@"DateTime"];
//    [table.contents insertObject:date atIndex:0];
    //start request to upload image
    NSString *imagePath = [[uploadPath stringByAppendingPathComponent:date] stringByAppendingPathExtension:@"jpg"];
    //compress upload then store the path
    NSData* compressedImageData = [ImageHelper resizeWithImage:image scale:0.5f compression:0.5f];
    NSDictionary *imageModel = @{UPLOAD_Data:compressedImageData,UPLOAD_FileName:imagePath};
    [HTTPBatchRequester startBatchUploadRequest:@[imageModel] url:IMAGE_URL(UPLOAD) identifications:@[@"uploaded"] delegate:self completeHandler:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    table.innerContent[currentPhotoIndex][@"Image"] = image;
    [self dismissViewControllerAnimated:YES completion:^{
        [table.tableView reloadData];
    }];
    [table.tableView reloadData];
}

#pragma mark - httpBatch uploader
-(void) didFinishReceiveData:(HTTPRequester *)request data:(ResponseJsonModel *)data{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([request.identification isEqualToString:@"uploaded"]){
        //update uploaded path to database

        NSString *uploadedPath = [NSString stringWithString:data.action];
        if (uploadedPath){
            RequestJsonModel* updatePathModel = [RequestJsonModel getJsonModel];
            [updatePathModel addModels:@"SecurityPatrolBill", nil];
            updatePathModel.path = PATH_LOGIC_MODIFY(DEPARTMENT_SECURITY);
            [updatePathModel.objects addObject:@{@"photoURL":uploadedPath}];
            [updatePathModel.identities addObject:@{@"id":[table.innerContent[currentPhotoIndex][@"billID"] stringValue]}];
            
            [DATA.requester startPostRequest:updatePathModel completeHandler:^(HTTPRequester*requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                NSLog(@"update path");
            }];
        }
    }
    else if ([request.identification isEqualToString:@"1"]){
        NSString *str = [[NSString alloc] initWithData:data.binaryData encoding:NSUTF8StringEncoding];
        NSArray *rows =  [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (NSString *unit in rows){
            if ([unit isEqualToString:@""]){[table.flatContent addObject:@""]; break;}
            NSArray *IDandName = [unit componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *projectID = IDandName[0];
            NSString *projectName = IDandName[1];
            lastPID = [NSString stringWithString:projectID];
            //add to contents
            [table.flatContent addObject:projectName];
            
            //compose real contents
            NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:@{@"Image":[NSNull null],@"Checker":[NSNull null],@"RepairNO":[NSNull null], @"PID":projectID, @"billID":[NSNull null]}];
            //add to real contents
            [table.innerContent addObject:new];
        }

        //Get present day patrol order id
        RequestJsonModel *orderModel = [RequestJsonModel getJsonModel];
        [orderModel addModels:@"SecurityPatrolOrder", nil];
        orderModel.path = PATH_LOGIC_READ(DEPARTMENT_SECURITY);
        [orderModel.objects addObject:@{PROPERTY_CREATEDATE:orderDate}];
        
        [DATA.requester startPostRequest:orderModel completeHandler:^(HTTPRequester* requester,ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            if (!error && ((NSArray*)data.results[0]).count > 0){
                //set current ID
                NSDictionary *realData = data.results[0][0];
                NSArray *bills = realData[@"bills"];
                currentPatrolID = [realData[@"id"] stringValue];
                
                //refresh realContents for tabel
                for (NSDictionary* bill in bills){
                    NSString *checker = Nil;
                    NSString *repair = Nil;
                    NSString *photo = Nil;
                    NSString *confiID = Nil;
                    NSString *billID = Nil;
                    
                    checker = bill[@"employeeNO"];
                    repair = bill[@"repairOrderNO"];
                    photo = bill[@"photoURL"];
                    confiID = bill[@"configID"];
                    billID = bill[@"id"];
                    
                    if (confiID){
                        //search for item in realContents
                        NSMutableDictionary* choosen = Nil;
                        for (NSMutableDictionary* c in table.innerContent){
                            if ([c[@"PID"] isEqualToString:confiID]){
                                choosen = c;
                                break;
                            }
                        }
                        if (billID) choosen[@"billID"] = billID;
                        if (repair) choosen[@"RepairNO"] = repair;
                        if (photo) choosen[@"Image"] = photo;
                        if (photo && checker) choosen[@"Checker"] = checker;
                    }
                    
                }
            }
        }];
        
        [table.tableView reloadData];

    }
    else if ([request.identification isEqualToString:@"config"]){
        NSLog(@"config success");
    }
    
}

-(void) didFailRequestWithError:(HTTPRequester *)request error:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - button events
-(void) editAction{
    editEnable = !editEnable;
    if (editEnable){
        if (authorityLevel >= AuthorityLevel){
            [PopupViewHelper popSheet:@"选择" inView:self.view actionBlock:^(UIView *popView, NSInteger index){
                if (index == 0){
                    editMode = Insertion;
                }
                else if (index == 1){
                    editMode = Remove;
                }
                else{
                    editEnable = NO;
                    return;
                }
                [table setEditing: YES animated:YES];
            } buttons:@"添加",@"删除",@"取消",nil];
        }
        else
        {
            editMode = Reorder;
            [table setEditing: YES animated:YES];
        }
    }else{
        [table setEditing:NO animated:YES];
        //construct config.txt

        NSMutableArray *composeArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < table.innerContent.count; i++){
            NSMutableDictionary* project = table.innerContent[i];
            if (project[@"PID"] == [NSNull null])
                project[@"PID"] = [NSString stringWithFormat:@"%d",i+1];
            
            NSString* compoItem = [NSString stringWithFormat:@"%@ %@",project[@"PID"],table.flatContent[i]];
            [composeArr addObject:compoItem];
        }
        [composeArr addObject:table.flatContent.lastObject];

        
        NSString *dataStr =[NSString stringWithFormat:@"%@ \n",[composeArr componentsJoinedByString:@"\n"]] ;
        NSData *fileData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *uploadModel = @{UPLOAD_Data:fileData, UPLOAD_FileName:[[[uploadPath stringByAppendingPathComponent:@"config"] stringByAppendingPathComponent:currentDate] stringByAppendingPathExtension:@"txt"]};
        
        [HTTPBatchRequester startBatchUploadRequest:@[uploadModel] url:IMAGE_URL(UPLOAD) identifications:@[@"config"] delegate:self completeHandler:nil];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click click click");
    UIImage* image = table.innerContent[indexPath.row][@"Image"];
    if ([image isKindOfClass:[UIImage class]]){
        UIImageView* imageView = [[UIImageView alloc]initWithImage:image];
        [BrowseImageView browseImage:imageView adjustSize:0];
    }
}
    
-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableViewObj willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell.contentView removeSubview:1];
    [cell.contentView removeSubview:3];
    [cell.contentView removeSubview:5];
    if (!table.tableView.editing && indexPath.row != table.flatContent.count - 1 && cellButtons.count > 0){
        int xIncrement = cell.bounds.size.width - buttonOffset;
        //title,image,title,image...
        for (int i = 0; i < cellButtons.count; i+=2) {
            NSString* title = cellButtons[i];
            NormalButton *button = [[NormalButton alloc] init];
            button.frame = CGRectMake(xIncrement,
                                      (cell.bounds.size.height - buttonHeight)/2,
                                      buttonWidth, buttonHeight);
            
            [button setBackgroundImage:[UIImage imageNamed:cellButtons[i+1]] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (i==2 && table.innerContent[indexPath.row][@"Checker"] != [NSNull null]){
                title = table.innerContent[indexPath.row][@"Checker"];
            }
            [button setTitle:title forState:UIControlStateNormal];
            if (i == 4){
                button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y-5, 53, 50);
                [button setTitle:@"" forState:UIControlStateNormal];
            }
            button.didClikcButtonAction = cellButtonsActions[indexPath.row % 3];
            [cell.contentView addSubview:button];
            xIncrement -= buttonOffset;
            button.tag = i+1;
        }
    }
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editMode == Remove){
        if (indexPath.row == table.flatContent.count - 1)
            return UITableViewCellEditingStyleNone;
        return UITableViewCellEditingStyleDelete;
    }
    else if (editMode == Insertion){
        if (indexPath.row != table.flatContent.count - 1)
            return UITableViewCellEditingStyleNone;
        return UITableViewCellEditingStyleInsert;
    }
    else {
        return UITableViewCellEditingStyleInsert & UITableViewCellEditingStyleDelete;
    }
}



@end

#undef prefix
#undef LOCALIZE
#undef AuthorityLevel