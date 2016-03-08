//
//  DebugConsoleViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 24/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "DebugConsoleViewController.h"
#import "IMUStreamViewController.h"
#import "ViewController.h"

#import "MBProgressHUD.h"

@implementation DebugConsoleViewController
{
   NSMutableData* filtered_packet_Data;
    NSMutableSet* _filterSet;
    float offset;
    DataSimulator* dataSimulator;
    BOOL b_filter9axis,b_filterquaternion,b_filtereuler,b_filterexternal,b_filterheading,b_filtermagnetometer,b_filterpedometer,b_filtertrajectory,b_filtertrajdistance,b_filtermotion,b_filterrecord;
    

}

@synthesize logging_btn, connect_btn;
@synthesize switch_9axis, switch_euler, switch_external, switch_heading, switch_magnetometer, switch_motindata, switch_pedometer,switch_quaternion, switch_record, switch_traj_distance, switch_traj_record;
@synthesize QuaternionA_lbl, QuaternionB_lbl, QuaternionC_lbl, QuaternionD_lbl;




#pragma mark View's defaults methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.view.bounds;
    [[self.view layer] insertSublayer:bkLayer atIndex:0];

     
    filtered_packet_Data = [[NSMutableData alloc] init];
    _filterSet = [[NSMutableSet alloc] init];
   

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
    

 }

-(void) initDebugflags
{
    b_filter9axis = false;
    b_filterexternal = false;
    b_filterheading = false;
    b_filtermagnetometer = false;
    b_filtermotion = false;
    b_filterpedometer = false;
    b_filterquaternion = false;
    b_filtereuler = false;
    b_filtertrajectory = false;
    b_filtertrajdistance = false;
    b_filterrecord = false;
    b_filterheading = false;
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
    
    //[self selectDatastream];
    
    [self updateLoggingBtnStatus];
    [self readFilterSettings];
}

-(void) selectDatastream
{
    [dataSimulator.neblina_dev SendCmdQuaternionStream:TRUE];
    [dataSimulator.neblina_dev SendCmdPedometerStream:TRUE];
    [dataSimulator.neblina_dev SendCmdEulerAngleStream:TRUE];
    [dataSimulator.neblina_dev SendCmdExternalForceStream:TRUE];
    [dataSimulator.neblina_dev SendCmdMagStream:TRUE];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    // get the shared instance of the data simulator
    
    start_flag = TRUE;

    // if logging stopped, lets display the saved pkts. we use the datasimulator for saving the state
    if([dataSimulator isLoggingStopped])
    {
        [self.logger_tbl setContentOffset:CGPointMake(0, offset)];
        
       // if([self.logger_tbl numberOfRowsInSection:0] == 0)
        {
            long nTotalPackets = [dataSimulator getTotalPackets];
            for (long j=nTotalPackets-50; j<nTotalPackets;j++)
            {
                if(j < 0) break;
                NSData* pkt = [dataSimulator getPacketAt:j];
                if(pkt)
                {
                    [self handleDataAndParse:pkt];
                }
            }

        }
        if([self.logger_tbl numberOfRowsInSection:0] > 0)
        {
            [self.logger_tbl scrollToRowAtIndexPath:[self lastIndexPath1] atScrollPosition:UITableViewScrollPositionBottom animated:true];
        }
        
    }
    dataSimulator.delegate = self;
    //[dataSimulator start];
  
    
}

-(NSIndexPath *)lastIndexPath1
{
    NSInteger lastSectionIndex = MAX(0, [self.logger_tbl numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.logger_tbl numberOfRowsInSection:lastSectionIndex] - 1);
  
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

-(NSIndexPath *)nextIndexPath1
{
    NSInteger lastSectionIndex = MAX(0, [self.logger_tbl numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.logger_tbl numberOfRowsInSection:lastSectionIndex]);
    
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
    
    [self saveFilterSettings];
    [dataSimulator saveFilterdData:filtered_packet_Data];
    
    offset  = self.logger_tbl.contentOffset.y;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



-(void)handleDataAndParsefortype:(UInt8)type data:(NSData*) data
{
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
    int nCmd = type;
    Byte single_header[sizeof(NEB_PKTHDR)];
    single_header[0] = 0;
    single_header[1] = 0;
    single_header[2] = 0;
    single_header[3] = type;
    
    if(![_filterSet containsObject:[NSNumber numberWithInt:nCmd]])
    {
        if([self getTotalPackets] > 1000)
        {
            NSRange range = NSMakeRange(0, 10000);
            [filtered_packet_Data replaceBytesInRange:range withBytes:NULL length:0];
            [self.logger_tbl reloadData];
            
        }
        [filtered_packet_Data appendBytes:single_header length:sizeof(NEB_PKTHDR)];
        [filtered_packet_Data appendData:data];
        
       
                           //[self.logger_tbl beginUpdates];
                           NSMutableArray *arCells=[NSMutableArray array];
                           [arCells addObject:[self nextIndexPath1]];
                           
                           [self.logger_tbl insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewScrollPositionNone];
        
        [self.logger_tbl scrollToRowAtIndexPath:[self lastIndexPath1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                           //[self.logger_tbl endUpdates];
                           
                           
        
        
       //[self performSelectorOnMainThread:@selector(reloadData1) withObject:nil waitUntilDone:NO];

        
    }
                         });
}

-(void) reloadData1
{
    [self.logger_tbl reloadData];
}


-(void)handleDataAndParse:(NSData *)pktData
{
    int nCmd=0;
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    
    if(![_filterSet containsObject:[NSNumber numberWithInt:nCmd]])
    {
        [filtered_packet_Data appendData:pktData];
        [self.logger_tbl reloadData];
        
        
    }
    
    //NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)
    //[self handleDataAndParsefortype:nCmd data:]
   
        
   

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

-(long) getTotalPackets
{
    return [filtered_packet_Data length]/(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t));
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self getTotalPackets];
    
}


-(NSMutableData*) getReceivedPackets
{
    return filtered_packet_Data;
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

        
        Byte single_packet2[(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))];

        [[self getReceivedPackets] getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)))];
       
        NSData* pktData = [NSData dataWithBytes:single_packet2 length:(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))];
        // parse data and diplay on labels
        NSString* debugstr = [self showData:pktData];
        NSString *myString1 = [NSString stringWithFormat:@"%@", [NSData dataWithBytes:single_packet2 length:(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))]];
        
        cell.textLabel.text = myString1;
        cell.detailTextLabel.text = debugstr;
        [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:10]];
        
        if(![dataSimulator isLoggingStopped])
        {
            [self.logger_tbl scrollToRowAtIndexPath:[self lastIndexPath1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    
    Byte single_packet2[(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))];
    [[self getReceivedPackets] getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)))];
    
    NSData* pktData = [NSData dataWithBytes:single_packet2 length:(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))];
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
    int16_t traj_repeat;
    NSString* retString;
    
    int16_t nStepCount, nDirAngle;
    int8_t nCadence, traj_progress;
    float f_DirAngle;
    
    switch(nCmd)
    {
        case MAG_Data: // MAG Data
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
            
        case Quaternion: // Quaternion data
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
            
        case EulerAngle: // Euler
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
            
        case ExtForce: // Ext Force
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
            
        case Pedometer: // Pedometer packets
            [pktData getBytes:&nStepCount range:NSMakeRange(8,2)];
            [pktData getBytes:&nCadence range:NSMakeRange(10,1)];
            [pktData getBytes:&nDirAngle range:NSMakeRange(11,2)];
            
            
            
            nStepCount = (int16_t)CFSwapInt16HostToLittle(nStepCount);
            
            nDirAngle = (int16_t)CFSwapInt16HostToLittle(nDirAngle);
            f_DirAngle = nDirAngle/10.0;
            
            // NSLog(@"Timestamp: %d StepCount: %d, Cadence: %d, DirectionAngle: %f", tmstamp,nStepCount,nCadence,f_DirAngle);
            retString = [NSString stringWithFormat:@"Timestamp: %d StepCount = %d, Cadence = %d, DirectionAngle = %f", tmstamp,nStepCount,nCadence,f_DirAngle];
            break;

            
        case 9: // Trajectory Distance
            [pktData getBytes:&yaw range:NSMakeRange(8,2)];
            [pktData getBytes:&pitch range:NSMakeRange(10,2)];
            [pktData getBytes:&roll range:NSMakeRange(12,2)];
            
            [pktData getBytes:&traj_repeat range:NSMakeRange(14,2)];
            [pktData getBytes:&traj_progress range:NSMakeRange(16,1)];
            
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            traj_repeat = (int16_t)CFSwapInt16HostToLittle(traj_repeat);
            
            
            NSLog(@"Timestamp: %d Trajectory Delta Angles Yaw = %f, pitch = %f, Roll = %f ,Repetition = %d, Progress = %d", tmstamp,(float)yaw/10.0,(float)pitch/10.0,(float)roll/10.0, traj_repeat,traj_progress);
            
            _Pitch_lbl.text = [NSString stringWithFormat:@"%f",(float)pitch/10.0];
            _Yaw_lbl.text = [NSString stringWithFormat:@"%f",(float)yaw/10.0];
            _Roll_lbl.text = [NSString stringWithFormat:@"%f",(float)roll/10.0];
            retString = [NSString stringWithFormat:@"Timestamp: %d Trajectory Delta Angles Yaw = %f, pitch = %f, Roll = %f ,Repetition = %d, Progress = %d", tmstamp,(float)yaw/10.0,(float)pitch/10.0,(float)roll/10.0, traj_repeat,traj_progress];
            break;
            
        default:
            break;
            
    }
    return retString;
}

-(void)updateBtn:(UIButton*)sender withSpinner:(BOOL) bWithSpinner
{
    Neblina *neblina_obj = [[Neblina alloc]init];
    
    if([sender.titleLabel.text isEqualToString:@"Quaternion"])
    {
        (sender.tag ==1) ? (b_filterquaternion = true):(b_filterquaternion = false);
        [self applyFilter:Quaternion enable:b_filterquaternion];
    }
    else if ([sender.titleLabel.text isEqualToString:@"9 Axis IMU"])
    {
        (sender.tag ==1) ? (b_filter9axis = true):(b_filter9axis = false);
        [self applyFilter:IMU_Data enable:b_filter9axis];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Euler Angles"])
    {
        (sender.tag ==1) ? (b_filtereuler = true):(b_filtereuler = false);
        [self applyFilter:EulerAngle enable:b_filtereuler];
    }
    else if ([sender.titleLabel.text isEqualToString:@"External Force"])
    {
        (sender.tag ==1) ? (b_filterexternal = true):(b_filterexternal = false);
        [self applyFilter:ExtForce enable:b_filterexternal];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Pedometer"])
    {
        (sender.tag ==1) ? (b_filterpedometer = true):(b_filterpedometer = false);
        [self applyFilter:Pedometer enable:b_filterpedometer];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory"])
    {
        (sender.tag ==1) ? (b_filtertrajectory = true):(b_filtertrajectory = false);
        [self applyFilter:TrajectoryRecStartStop enable:b_filtertrajectory];
       // [self applyFilter:TrajectoryRecStart enable:b_filtertrajectory];
       // [self applyFilter:TrajectoryRecStop enable:b_filtertrajectory];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory Distance"])
    {
        (sender.tag ==1) ? (b_filtertrajdistance = true):(b_filtertrajdistance = false);
        [self applyFilter:TrajectoryDistance enable:b_filtertrajdistance];
    }
    
    else if ([sender.titleLabel.text isEqualToString:@"Magnetometer"])
    {
        (sender.tag ==1) ? (b_filtermagnetometer = true):(b_filtermagnetometer = false);
        [self applyFilter:MAG_Data enable:b_filtermagnetometer];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Motion"])
    {
        (sender.tag ==1) ? (b_filtermotion = true):(b_filtermotion = false);
        [self applyFilter:MotionState enable:b_filtermotion];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Record"])
    {
        (sender.tag ==1) ? (b_filterrecord = true):(b_filterrecord = false);
//        [self applyFilter:Erase_Recorder enable:b_filterrecord];
//        [self applyFilter:Start_Recorder enable:b_filterrecord];
//        [self applyFilter:Stop_Recorder enable:b_filterrecord];
       
    }
    else if ([sender.titleLabel.text isEqualToString:@"Heading"])
    {
        (sender.tag ==1) ? (b_filterheading = true):(b_filterheading = false);
        
        
    }
    
    if(sender.tag == 1)
    {
        sender.tag = 2;
//        [sender setBackgroundColor:[UIColor whiteColor]];
//        [sender setTitleColor:[UIColor grayColor] forState:normal];
        [sender setBackgroundColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
        NSLog(@"%@",sender.titleLabel.text);
        
    }
    else{
        sender.tag = 1;
        //[sender setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:25.0/255.0 alpha:1]];
        [sender setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1]];
        
        //[sender setTitleColor:[UIColor whiteColor] forState:normal];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
    }
    if(bWithSpinner)
        [self displaySpinner:@"Applying filter changes..." time:1.5];
}



-(IBAction)OptionSwitched:(UIButton*)sender
{
    [self updateBtn:sender withSpinner:true];
    
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

// append to the filters array and return
-(void) applyFilter:(int) nFilterType enable:(int) nEnable
{
    if(nEnable)
    {
        [_filterSet addObject:[NSNumber numberWithInt:nFilterType]];
    
    }
    else
    {
        [_filterSet removeObject:[NSNumber numberWithInt:nFilterType]];
    }
}

// remove all the filters
-(void) clearAllFilters
{
    [_filterSet removeAllObjects];
}

-(void) saveFilterSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:b_filter9axis forKey:@"filter9axis"];
    [defaults setBool:b_filtereuler forKey:@"filtereuler"];
    [defaults setBool:b_filterexternal forKey:@"filterexternal"];
    [defaults setBool:b_filtermagnetometer forKey:@"filtermagnetometer"];
    [defaults setBool:b_filtermotion forKey:@"filtermotion"];
    [defaults setBool:b_filterpedometer forKey:@"filterpedometer"];
    [defaults setBool:b_filterquaternion forKey:@"filterquaternion"];
    [defaults setBool:b_filterrecord forKey:@"filterrecord"];
    [defaults setBool:b_filtertrajdistance forKey:@"filtertrajdistance"];
    [defaults setBool:b_filtertrajectory forKey:@"filtertrajectory"];
    
    
    [defaults synchronize];
    
}

-(void) readFilterSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL bWithSpinner = false;
    
    _btn_9_Axis.tag = 1;
    b_filter9axis = [defaults boolForKey:@"filter9axis"];
    if(![defaults boolForKey:@"g_filter9axis"])
    {
       _btn_9_Axis.tag = 2;
    }
    else if(b_filter9axis )
    {
        _btn_9_Axis.tag = 1;
    }
    [self updateBtn:_btn_9_Axis withSpinner:bWithSpinner];
    
    
    _btn_EulerAngles.tag = 1;
    b_filtereuler = [defaults boolForKey:@"filtereuler"];
    if(![defaults boolForKey:@"g_filtereuler"])
    {
       _btn_EulerAngles.tag = 2;
    }
    else if(b_filtereuler)
    {
        _btn_EulerAngles.tag = 1;
       
    }
    [self updateBtn:_btn_EulerAngles withSpinner:bWithSpinner];
    
    
    _btn_external_force.tag = 1;
    b_filterexternal = [defaults boolForKey:@"filterexternal"];
    
    if(![defaults boolForKey:@"g_filterexternal"])
    {
       _btn_external_force.tag = 2;
    }
    else if(b_filterexternal)
    {
        _btn_external_force.tag = 1;
    }
    [self updateBtn:_btn_external_force withSpinner:bWithSpinner];
    
    _btn_Magnetometer.tag = 1;
    b_filtermagnetometer = [defaults boolForKey:@"filtermagnetometer"];
   
    if(![defaults boolForKey:@"g_filtermagnetometer"])
    {
        _btn_Magnetometer.tag = 2;
    }
        
    else if(b_filtermagnetometer)
    {
        _btn_Magnetometer.tag = 1;
    }
    
    [self updateBtn:_btn_Magnetometer withSpinner:bWithSpinner];
    
    
    
    _btn_Motion.tag = 1;
    b_filtermotion = [defaults boolForKey:@"filtermotion"];
    if(![defaults boolForKey:@"g_filtermotion"])
    {
        _btn_Motion.tag = 2;
    }
    else if(b_filtermotion )
    {
        _btn_Motion.tag = 1;
    }
    [self updateBtn:_btn_Motion withSpinner:bWithSpinner];
    
    
    _btn_Pedometer.tag = 1;
    b_filterpedometer = [defaults boolForKey:@"filterpedometer"];
    if(![defaults boolForKey:@"g_filterpedometer"])
    {
        _btn_Pedometer.tag = 2;
    }
    else if(b_filterpedometer)
    {
        _btn_Pedometer.tag = 1;
    }
    [self updateBtn:_btn_Pedometer withSpinner:bWithSpinner];
    
    _btn_Quaternion.tag = 1;
    b_filterquaternion = [defaults boolForKey:@"filterquaternion"];
    if(![defaults boolForKey:@"g_filterquaternion"])
    {
        _btn_Quaternion.tag = 2;
    }
    else if(b_filterquaternion)
    {
        _btn_Quaternion.tag = 1;
        
    }
    [self updateBtn:_btn_Quaternion withSpinner:bWithSpinner];
    
    _btn_Record.tag = 1;
    b_filterrecord = [defaults boolForKey:@"filterrecord"];
    if(![defaults boolForKey:@"g_filterrecord"])
    {
        _btn_Record.tag = 2;
    }
    else if(b_filterrecord)
    {
        _btn_Record.tag = 1;
        
    }
    [self updateBtn:_btn_Record withSpinner:bWithSpinner];
    
    _btn_Traj_distance.tag = 1;
    b_filtertrajdistance = [defaults boolForKey:@"filtertrajdistance"];
    if(![defaults boolForKey:@"g_filtertrajdistance"])
    {
        _btn_Traj_distance.tag = 2;
    }
    else if(b_filtertrajdistance)
    {
        _btn_Traj_distance.tag = 1;
    }
    [self updateBtn:_btn_Traj_distance withSpinner:bWithSpinner];
    
    
    _btn_Trajectory.tag = 1;
    b_filtertrajectory = [defaults boolForKey:@"filtertrajectory"];
    if(![defaults boolForKey:@"g_filtertrajectory"])
    {
        _btn_Trajectory.tag = 2;
    }
    else if(b_filtertrajectory)
    {
        _btn_Trajectory.tag = 1;
    }
    [self updateBtn:_btn_Trajectory withSpinner:bWithSpinner];
    
   _btn_Heading.tag = 1;
    b_filterheading = [defaults boolForKey:@"filterheading"];
    if(![defaults boolForKey:@"g_filterheading"])
    {
        _btn_Heading.tag = 2;
    }
    else if(b_filterheading)
    {
        _btn_Heading.tag = 1;
    }
    [self updateBtn:_btn_Heading withSpinner:bWithSpinner];
    
    
}


@end
