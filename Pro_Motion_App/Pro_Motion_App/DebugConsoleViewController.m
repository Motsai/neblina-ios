//
//  DebugConsoleViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 24/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "DebugConsoleViewController.h"
#import "IMUStreamViewController.h"
#import "neblina.h"
#import "FusionEngineDataTypes.h"
#import "Pro_Motion_App-Swift.h"
#import "DataSimulator.h"
#import "MBProgressHUD.h"

@implementation DebugConsoleViewController

@synthesize logging_btn, connect_btn;
@synthesize switch_9axis, switch_euler, switch_external, switch_heading, switch_magnetometer, switch_motindata, switch_pedometer,switch_quaternion, switch_record, switch_traj_distance, switch_traj_record;
@synthesize QuaternionA_lbl, QuaternionB_lbl, QuaternionC_lbl, QuaternionD_lbl;


DataSimulator* dataSimulator;
BOOL b_show9axis,b_showquaternion,b_showeuler,b_showexternal,b_showheading,b_showmagnetometer,b_showpedometer,b_showtrajectory,b_showtrajdistance,b_showmotion,b_showrecord;

#pragma mark View's defaults methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    start_flag = false;
    
    self.logger_tbl.layer.borderWidth = 2;
    self.logger_tbl.layer.borderColor = [[UIColor blackColor] CGColor];
    self.logger_tbl.layer.cornerRadius = 5;
    
    self.switch_view.layer.borderWidth = 2;
    self.switch_view.layer.borderColor = [[UIColor blackColor] CGColor];
    self.switch_view.layer.cornerRadius = 5;
    [_btnEmail setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _btnEmail.enabled = true;
    
    dataSimulator = [DataSimulator sharedInstance];
    [self initDebugflags];

 }

-(void) initDebugflags
{
    b_show9axis = true;
    b_showexternal = true;
    b_showheading = true;
    b_showmagnetometer = true;
    b_showmotion = true;
    b_showpedometer = true;
    b_showquaternion = true;
    b_showeuler = true;
    b_showtrajectory = true;
    b_showtrajdistance = true;
    b_showrecord = true;
    b_showheading = true;
}

-(void) updateLoggingBtnStatus
{
    if([dataSimulator isLoggingStopped])
    {
        logging_btn.tag = 1;
        [logging_btn setTitle:@"Start Logging" forState:UIControlStateNormal];
        _btnEmail.enabled = true;
    }
    else
    {
        logging_btn.tag = 2;
         [logging_btn setTitle:@"Stop Logging" forState:UIControlStateNormal];
        _btnEmail.enabled = false;
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLoggingBtnStatus];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    // get the shared instance of the data simulator
    
    
    // if logging stopped, lets plot the last 200 points on the graph
    if([dataSimulator isLoggingStopped])
    {
        [self.logger_tbl reloadData];
        NSIndexPath *lastIndexPath1 = [self lastIndexPath1];
        
        
        
        [self.logger_tbl scrollToRowAtIndexPath:lastIndexPath1 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [self.logger_tbl selectRowAtIndexPath:lastIndexPath1 animated:true scrollPosition:UITableViewScrollPositionBottom];
        
    }
    
    
    dataSimulator.delegate = self;
    start_flag = TRUE;
  
    
    
}

-(NSIndexPath *)lastIndexPath1
{
    NSInteger lastSectionIndex = MAX(0, [self.logger_tbl numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.logger_tbl numberOfRowsInSection:lastSectionIndex] - 1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

-(void) viewDidDisappear:(BOOL)animated
{
    dataSimulator.delegate = nil;

}

-(void) viewWillDisappear:(BOOL)animated
{
   
    start_flag = false;
    dataSimulator.delegate = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)handleDataAndParse:(NSData *)pktData
{

    [self.logger_tbl reloadData];

}


-(IBAction)Start_Stop_Logging:(UIButton *)button
{
    // To Start & Stop Logging Data.
    
    if (button.tag == 1)
    {
        
        button.tag = 2;
        [button setTitle:@"Stop Logging" forState:UIControlStateNormal];
        
       [dataSimulator start];
    
        [self displaySpinner:@"Starting..." time:2];
        
        _btnEmail.enabled = false;
        
    }
    else if (button.tag == 2)
    {
       
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [dataSimulator pause];
        [self displaySpinner:@"Stopping..." time:2];
        _btnEmail.enabled = true;

    }
    
}

-(IBAction)ConnectDevices:(id)sender
{
    // Open Control Panel to scan devices.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"IMUIdentifire"])
    {
        // Get reference to the destination view controller
        //[dataSimulator pause];
        dataSimulator.delegate = nil;
        IMUStreamViewController *IMU_object = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        IMU_object.string_value = @"Passed_Data";
    }
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    int nCount = [dataSimulator getTotalPackets];
    return nCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellidentifire = [NSString stringWithFormat:@"cell_%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifire];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifire];
    }
    
    if (start_flag == true)
    {

        
        Byte single_packet2[20];

        [[dataSimulator getReceivedPackets] getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
        //NSLog(@"%@", [NSData dataWithBytes:single_packet2 length:20]);
        NSData* pktData = [NSData dataWithBytes:single_packet2 length:20];
        // parse data and diplay on labels
        NSString* debugstr = [self showData:pktData];
        NSString *myString1 = [NSString stringWithFormat:@"%@",[NSData dataWithBytes:single_packet2 length:20]];
        cell.textLabel.text = myString1;
        cell.detailTextLabel.text = debugstr;
        [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:10]];
        
        NSLog(@"Index path row is %d",indexPath.row);

        
        if(![dataSimulator isLoggingStopped])
        {
        
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[dataSimulator getReceivedPackets] length]/20)-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

        
    }
    
    return cell;
}

-(void)displaySpinner:(NSString*) msg time:(int) ts
{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    NSString *info = msg;
    [hud setLabelText:info];
    //[hud setDetailsLabelText:@"Please wait..."];
    [hud setDimBackground:YES];
    [hud setOpacity:0.5f];
    [hud show:YES];
    hud.color = [UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:25.0/255.0 alpha:1];
    [hud hide:YES afterDelay:ts];
    

}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Byte single_packet2[20];
    [[dataSimulator getReceivedPackets] getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
    
    NSData* pktData = [NSData dataWithBytes:single_packet2 length:20];
    // parse data and diplay on labels
    [self showData:pktData];
    
}

-(NSString*) showData:(NSData *)pktData
{
    
    int nCmd=0;
    
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    
    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(4,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);
    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    int16_t q0, q1,q2,q3;
    int16_t yaw,pitch,roll;
    int16_t fext_x,fext_y,fext_z;
    NSString* retString;
    
    int16_t nStepCount, nDirAngle;
    int8_t nCadence;
    float f_DirAngle;
    
    switch(nCmd)
    {
        case 12: // MAG Data
            [pktData getBytes:&mag_orient_x range:NSMakeRange(8,2)];
            [pktData getBytes:&mag_orient_y range:NSMakeRange(10,2)];
            [pktData getBytes:&mag_orient_z range:NSMakeRange(12,2)];
            [pktData getBytes:&mag_accel_x range:NSMakeRange(14,2)];
            [pktData getBytes:&mag_accel_y range:NSMakeRange(16,2)];
            [pktData getBytes:&mag_accel_z range:NSMakeRange(18,2)];
            
            mag_orient_x = (int16_t)CFSwapInt16HostToLittle(mag_orient_x);
            mag_orient_y = (int16_t)CFSwapInt16HostToLittle(mag_orient_y);
            mag_orient_z = (int16_t)CFSwapInt16HostToLittle(mag_orient_z);
            
            mag_accel_x = (int16_t)CFSwapInt16HostToLittle(mag_accel_x);
            mag_accel_y = (int16_t)CFSwapInt16HostToLittle(mag_accel_y);
            mag_accel_z = (int16_t)CFSwapInt16HostToLittle(mag_accel_z);
            
            NSLog(@"%d DCV Accel is = %d, %d, %d", tmstamp,mag_accel_x,mag_accel_y,mag_accel_z);
            NSLog(@"%d DCV Mag is = %d, %d, %d", tmstamp,mag_orient_x,mag_orient_y,mag_orient_z);
            retString = [NSString stringWithFormat:@"Timestamp: %d MAG Data : acc.x = %d,acc_y = %d,acc_z=%d,mag_x = %d,mag_y = %d, mag_z = %d",tmstamp,mag_accel_x,mag_accel_y,mag_accel_z,mag_orient_x,mag_orient_y,mag_orient_z];
            
            QuaternionA_lbl.text = [NSString stringWithFormat:@""];
            QuaternionB_lbl.text = [NSString stringWithFormat:@""];
            QuaternionC_lbl.text = [NSString stringWithFormat:@""];
            QuaternionD_lbl.text = [NSString stringWithFormat:@""];
            
            _Pitch_lbl.text = [NSString stringWithFormat:@""];
            _Yaw_lbl.text = [NSString stringWithFormat:@""];
            _Roll_lbl.text = [NSString stringWithFormat:@""];
            
            _GravityX_lbl.text = [NSString stringWithFormat:@""];
            _GravityY_lbl.text = [NSString stringWithFormat:@""];
            _GravityZ_lbl.text = [NSString stringWithFormat:@""];
            
            
            break;
            
        case 4: // Quaternion data
            [pktData getBytes:&q0 range:NSMakeRange(8,2)];
            [pktData getBytes:&q1 range:NSMakeRange(10,2)];
            [pktData getBytes:&q2 range:NSMakeRange(12,2)];
            [pktData getBytes:&q3 range:NSMakeRange(14,2)];
            q0 = (int16_t)CFSwapInt16HostToLittle(q0);
            q1 = (int16_t)CFSwapInt16HostToLittle(q1);
            q2 = (int16_t)CFSwapInt16HostToLittle(q2);
            q3 = (int16_t)CFSwapInt16HostToLittle(q3);
            NSLog(@"%d Quaternion data is = %d, %d, %d %d", tmstamp,q0,q1,q2,q3);
            
            QuaternionA_lbl.text = [NSString stringWithFormat:@"%f",(float)q0/32768.0];
            QuaternionB_lbl.text = [NSString stringWithFormat:@"%f",(float)q1/32768.0];
            QuaternionC_lbl.text = [NSString stringWithFormat:@"%f",(float)q2/32768.0];
            QuaternionD_lbl.text = [NSString stringWithFormat:@"%f",(float)q3/32768.0];
            retString = [NSString stringWithFormat:@"Timestamp: %d Quaternion Data is = %f, %f, %f %f", tmstamp,(float)q0/32768.0,(float)q1/32768.0,(float)q2/32768.0,(float)q3/32768.0];
            
            break;
            
        case 5: // Euler
            [pktData getBytes:&yaw range:NSMakeRange(8,2)];
            [pktData getBytes:&pitch range:NSMakeRange(10,2)];
            [pktData getBytes:&roll range:NSMakeRange(12,2)];
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            
            NSLog(@"%d Euler data Yaw = %d, pitch = %d, Roll = %d", tmstamp,yaw,pitch,roll);
            
            _Pitch_lbl.text = [NSString stringWithFormat:@"%f",(float)pitch/10.0];
            _Yaw_lbl.text = [NSString stringWithFormat:@"%f",(float)yaw/10.0];
            _Roll_lbl.text = [NSString stringWithFormat:@"%f",(float)roll/10.0];
            retString = [NSString stringWithFormat:@"Timestamp: %d Euler data Yaw = %f, pitch = %f, Roll = %f", tmstamp,(float)yaw/10.0,(float)pitch/10.0,(float)roll/10.0];
            break;
            
        case 6: // Ext Force
            [pktData getBytes:&fext_x range:NSMakeRange(8,2)];
            [pktData getBytes:&fext_y range:NSMakeRange(10,2)];
            [pktData getBytes:&fext_z range:NSMakeRange(12,2)];
            
            fext_x = (int16_t)CFSwapInt16HostToLittle(fext_x);
            fext_y = (int16_t)CFSwapInt16HostToLittle(fext_y);
            fext_z = (int16_t)CFSwapInt16HostToLittle(fext_z);
            
            NSLog(@"%d External Force vector x = %d, y = %d, z = %d", tmstamp,fext_x,fext_y,fext_z);
            
            _GravityX_lbl.text = [NSString stringWithFormat:@"%d",fext_x/1600];
            _GravityY_lbl.text = [NSString stringWithFormat:@"%d",fext_y/1600];
            _GravityZ_lbl.text = [NSString stringWithFormat:@"%d",fext_z/1600];
            retString = [NSString stringWithFormat:@"Timestamp: %d External Force vector x = %d, y = %d, z = %d", tmstamp,fext_x/1600,fext_y/1600,fext_z/1600];
            
            break;
            
        case 11: // Pedometer packets
            [pktData getBytes:&nStepCount range:NSMakeRange(8,2)];
            [pktData getBytes:&nCadence range:NSMakeRange(10,1)];
            [pktData getBytes:&nDirAngle range:NSMakeRange(11,2)];
            
            
            
            nStepCount = (int16_t)CFSwapInt16HostToLittle(nStepCount);
            
            nDirAngle = (int16_t)CFSwapInt16HostToLittle(nDirAngle);
            f_DirAngle = nDirAngle/10.0;
            
            // NSLog(@"Timestamp: %d StepCount: %d, Cadence: %d, DirectionAngle: %f", tmstamp,nStepCount,nCadence,f_DirAngle);
            retString = [NSString stringWithFormat:@"Timestamp: %d StepCount = %d, Cadence = %d, DirectionAngle = %f", tmstamp,nStepCount,nCadence,f_DirAngle];

            
        default:
            break;
            
    }
    return retString;
}

-(void)updateBtn:(UIButton*)sender
{
    Neblina *neblina_obj = [[Neblina alloc]init];
    if(sender.tag == 1)
    {
        sender.tag = 2;
        [sender setBackgroundColor:[UIColor whiteColor]];
        [sender setTitleColor:[UIColor grayColor] forState:normal];
        
        NSLog(@"%@",sender.titleLabel.text);
        
    }
    else{
        sender.tag = 1;
        [sender setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:25.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor whiteColor] forState:normal];
        
    }
    
    if([sender.titleLabel.text isEqualToString:@"Quaternion"])
    {
        (sender.tag ==1) ? (b_showquaternion = true):(b_showquaternion = false);
        //[neblina_obj QuaternionStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"9 Axis IMU"])
    {
        (sender.tag ==1) ? (b_show9axis = true):(b_show9axis = false);
        //[neblina_obj SixAxisIMU_Stream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Euler Angles"])
    {
        (sender.tag ==1) ? (b_showeuler = true):(b_showeuler = false);
        //[neblina_obj EulerAngleStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"External Force"])
    {
        (sender.tag ==1) ? (b_showexternal = true):(b_showexternal = false);
        //[neblina_obj ExternalForceStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Pedometer"])
    {
        (sender.tag ==1) ? (b_showpedometer = true):(b_showpedometer = false);
        //[neblina_obj PedometerStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory"])
    {
        (sender.tag ==1) ? (b_showtrajectory = true):(b_showtrajectory = false);
        //[neblina_obj TrajectoryRecord:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory Distance"])
    {
        (sender.tag ==1) ? (b_showtrajdistance = true):(b_showtrajdistance = false);
        //[neblina_obj TrajectoryDistanceData:(sender.tag ==1)?1:0];
    }
    
    else if ([sender.titleLabel.text isEqualToString:@"Magnetometer"])
    {
        (sender.tag ==1) ? (b_showmagnetometer = true):(b_showmagnetometer = false);
        //[neblina_obj MagStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Motion"])
    {
        (sender.tag ==1) ? (b_showmotion = true):(b_showmotion = false);
        //[neblina_obj MotionStream:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Record"])
    {
        (sender.tag ==1) ? (b_showrecord = true):(b_showrecord = false);
        //[neblina_obj RecorderErase:(sender.tag ==1)?1:0];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Heading"])
    {
        (sender.tag ==1) ? (b_showheading = true):(b_showheading = false);
       
        //[neblina_obj Recorder:(sender.tag ==1)?1:0];
        
    }
    
}


-(IBAction)OptionSwitched:(UIButton*)sender
{
    [self updateBtn:sender];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result){
        case MFMailComposeResultCancelled:NSLog(@"Mail cancelled"); break;
        case MFMailComposeResultSaved:    NSLog(@"Mail saved");     break;
        case MFMailComposeResultSent:
                NSLog(@"Mail sent");
                [self displaySpinner:@"Sending Log file..." time:1];
                
                break;
        case MFMailComposeResultFailed:
                NSLog(@"Mail sent failure: %@", [error localizedDescription]);
                [self displaySpinner:@"Error sending log file..." time:2];
                break;
        default:                                                    break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];

    
//    // Close the Mail Interface
//    if (!app) { app = (AppDelegate *)[[UIApplication sharedApplication] delegate]; }
//    if (!currentSplitViewController) {
//        currentSplitViewController  = (UISplitViewController *) app.window.rootViewController;
//    }
//    
//    navController        = [currentSplitViewController.viewControllers lastObject];
//    
//    [[navController topViewController] dismissViewControllerAnimated:YES completion:NULL];
//    
}


-(void)sendEmailInViewController:(UIViewController *)viewController {
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *emailTitle = @"Log file attached -- ";
    emailTitle = [emailTitle stringByAppendingString:dateString];
    NSArray *toRecipents = [[NSArray alloc]initWithObjects:@"sanix22@gmail.com", nil];
    NSMutableString *messageBody =[[NSMutableString alloc]init];
    
    [messageBody appendString:@"<p></p><p>Hi,&nbsp;</p><p>Please find attached the log file.</p><p><span style=\"font-size:14px;\"><span style=\"color: rgb(0, 0, 102);\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Thanks,</strong><br />Motsai Team&nbsp;&nbsp; <br /></span></span></span></p><p><span style=\"color:#000066;\"><span style=\"font-family: arial,helvetica,sans-serif;\"></span></span></p>"];
    
    
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        MFMailComposeViewController * mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        
        //Set the subject
        [mailView setSubject:emailTitle];
        
        //Set the mail body
        [mailView setMessageBody:messageBody isHTML:YES];
        [mailView setToRecipients:toRecipents];
        
        NSString* logfile = [dataSimulator getLogfilePath];
        NSLog(@"Log file is %@",logfile);
        
        NSDateFormatter *formatter;
        NSString        *dateString;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        dateString = [dateString stringByAppendingString:@".bin"];
        
        NSString* attachmentName = [[NSString stringWithString:@"DataLogger"] stringByAppendingString:dateString];
        
        NSData *logData = [dataSimulator getReceivedPackets];//[NSData dataWithContentsOfFile:logfile];
       [mailView addAttachmentData:logData mimeType:@"public.data" fileName:attachmentName];
        
        
        //Display Email Composer
        if([mailClass canSendMail]) {
            [viewController presentViewController:mailView animated:YES completion:NULL];
        }
    }
}

- (IBAction)sendLogfile:(id)sender {
    //[self sendEmailInViewController:self];
    
    NSURL *url = [NSURL fileURLWithPath:[dataSimulator getLogfilePath]];//[self fileToURL:[dataSimulator getLogfilePath]];
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    dateString = [dateString stringByAppendingString:@".bin"];
    
    NSString* attachmentName = [[NSString stringWithString:@"DataLogger"] stringByAppendingString:dateString];

    
    
    NSURL *url1 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:attachmentName]];
    
    [[dataSimulator getReceivedPackets] writeToURL:url1 atomically:NO];
    
    //url = [NSURL URLWithDataRepresentation:[dataSimulator getReceivedPackets] relativeToURL:nil ];
  
    NSArray *objectsToShare = @[url1];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    // Present the controller
    //[self.navigationController presentViewController:controller animated:YES completion:nil];
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

@end
