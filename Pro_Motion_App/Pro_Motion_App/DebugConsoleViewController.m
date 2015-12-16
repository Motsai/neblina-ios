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

@implementation DebugConsoleViewController

@synthesize logging_btn, connect_btn;
@synthesize switch_9axis, switch_euler, switch_external, switch_heading, switch_magnetometer, switch_motindata, switch_pedometer,switch_quaternion, switch_record, switch_traj_distance, switch_traj_record;
@synthesize QuaternionA_lbl, QuaternionB_lbl, QuaternionC_lbl, QuaternionD_lbl;
@synthesize timer;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self readBinaryFile:@"wheel_test2fixed"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)readBinaryFile:(NSString *)filename
{
    // Delete/Remove already created file & write a fresh data into it every time.
    appFile_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DataLogger.bin"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:appFile_path])
    {
        [[NSFileManager defaultManager] createFileAtPath:appFile_path contents:[NSData data] attributes:nil];
    }

    logging_btn.tag = 2;
    [logging_btn setTitle:@"Stop Logging" forState:UIControlStateNormal];

    /* Test Files 
     1. QuaternionStream.bin
     2. EulerAngleStream.bin
     3. ForceStream.bin
     4. IMUStream.bin
    */
    
    count = 0;
    length = 0;
    deactivate_var = 0;
    mutable_packet_Data = [[NSMutableData alloc]init];
    [timer invalidate];
    [self.logger_tbl reloadData];
    
    // Read Data File
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"bin"];//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    length = [fileData length];
    NSLog(@"Length = %lu", (unsigned long)length);
    
    deactivate_var = length/20;
    float timeInterval = 0.04;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
}

-(void)timerFireMethod
{
    NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
    if (count == deactivate_var)
    {
        [timer invalidate];
        
        logging_btn.tag = 1;
        [logging_btn setTitle:@"Start Logging" forState:UIControlStateNormal];
        return;
    }

    Byte single_packet1[20];
    [fileData getBytes:single_packet1 range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];

    // Appending new packets to mutable data
    [mutable_packet_Data appendData:[NSData dataWithBytes:single_packet1 length:20]];
    
    // Writing data to DataLogger File
    uint8_t *fileBytes = (uint8_t *)[single_packet bytes];
    NSData *data = [[NSData alloc] initWithBytes:fileBytes length:[single_packet length]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:appFile_path])
    {
        [[NSFileManager defaultManager] createFileAtPath:appFile_path contents:nil attributes:nil];
        [data writeToFile:appFile_path atomically:YES];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:appFile_path];
        [myHandle seekToEndOfFile];
        [myHandle writeData:data];
    }

    start_flag = true;
    [self.logger_tbl reloadData];
    
    
    count ++;
}

#pragma mark - action method

-(IBAction)switchAction:(UISegmentedControl *)segment
{
//    Neblina *neblina_obj = [[Neblina alloc]init];
//    NSLog(@"Selected Segment = %ld", segment.selectedSegmentIndex);
    
    last_selected_segment_controller.selectedSegmentIndex = 0;
    if (segment.tag == 1)
    {
        [self readBinaryFile:@"wheel_test2fixed"];
        last_selected_segment_controller = segment;
        
//        [neblina_obj SixAxisIMU_Stream:switch_9axis.selectedSegmentIndex];
    }
    else if (segment.tag == 2)
    {
        [self readBinaryFile:@"QuaternionStream"];
        last_selected_segment_controller = segment;
        
//        [neblina_obj QuaternionStream:switch_quaternion.selectedSegmentIndex];
    }
    else if (segment.tag == 3)
    {
        [self readBinaryFile:@"EulerAngleStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj EulerAngleStream:switch_euler.selectedSegmentIndex];
    }
    else if (segment.tag == 4)
    {
        [self readBinaryFile:@"ForceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj ExternalForceStream:switch_external.selectedSegmentIndex];
    }
    else if (segment.tag == 5)
    {
        [self readBinaryFile:@"PedometerStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj PedometerStream:switch_pedometer.selectedSegmentIndex];
    }
    else if (segment.tag == 6)
    {
//        [self readBinaryFile:@"ForceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj TrajectoryRecord:switch_traj_record.selectedSegmentIndex];
    }
    else if (segment.tag == 7)
    {
        [self readBinaryFile:@"TrajectoryDistanceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj TrajectoryDistanceData:switch_traj_distance.selectedSegmentIndex];
    }
    else if (segment.tag == 8)
    {
        [self readBinaryFile:@"MAGStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj MagStream:switch_magnetometer.selectedSegmentIndex];
    }
    else if (segment.tag == 9)
    {
        [self readBinaryFile:@"MotionStateStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj MotionStream:switch_motindata.selectedSegmentIndex];
    }
    else if (segment.tag == 10)
    {
        [self readBinaryFile:@"ForceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj RecorderErase:switch_record.selectedSegmentIndex];
    }
    else if (segment.tag == 11)
    {
        [self readBinaryFile:@"ForceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj Recorder:switch_heading.selectedSegmentIndex];
    }
    else if (segment.tag == 12)
    {
        [self readBinaryFile:@"ForceStream"];
        last_selected_segment_controller = segment;

//        [neblina_obj SixAxisIMU_Stream:switch_record.selectedSegmentIndex];
    }
}

-(IBAction)Start_Stop_Logging:(UIButton *)button
{
    // To Start & Stop Logging Data.
    
    if (button.tag == 1)
    {
        button.tag = 2;
        [button setTitle:@"Stop Logging" forState:UIControlStateNormal];
        
        deactivate_var = length/20;
        
        if (count >= deactivate_var)
        {
            count = 0;
        }

        float timeInterval = 0.04;
        timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    }
    else if (button.tag == 2)
    {
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [timer invalidate];
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
    return [mutable_packet_Data length]/20;
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
        if( [mutable_packet_Data length]/20 < count)
        {
            NSLog(@"Returning empty cell");
            return cell;
        }
        
        Byte single_packet2[20];
        [mutable_packet_Data getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
        //NSLog(@"%@", [NSData dataWithBytes:single_packet2 length:20]);
        NSData* pktData = [NSData dataWithBytes:single_packet2 length:20];
        // parse data and diplay on labels
        [self handleDataAndParse:pktData];
        NSString *myString1 = [NSString stringWithFormat:@"%@",[NSData dataWithBytes:single_packet2 length:20]];
        cell.textLabel.text = myString1;
        [cell.textLabel setFont:[UIFont systemFontOfSize:17]];
        
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([mutable_packet_Data length]/20)-1 inSection:0] atScrollPosition:NULL animated:YES];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Byte single_packet2[20];
    [mutable_packet_Data getBytes:single_packet2 range:NSMakeRange(indexPath.row*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
    
    NSData* pktData = [NSData dataWithBytes:single_packet2 length:20];
    // parse data and diplay on labels
    [self handleDataAndParse:pktData];
    
}

-(void) handleDataAndParse:(NSData *)pktData
{
    
    int nCmd=0;
   
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    int16_t q0, q1,q2,q3;
    int16_t yaw,pitch,roll;
    int16_t fext_x,fext_y,fext_z;
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
            
            NSLog(@"Accel is = %d, %d, %d", mag_accel_x,mag_accel_y,mag_accel_z);
            NSLog(@"Mag is = %d, %d, %d", mag_orient_x,mag_orient_y,mag_orient_z);
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
            NSLog(@"Quaternion data is = %d, %d, %d %d", q0,q1,q2,q3);
            
            QuaternionA_lbl.text = [NSString stringWithFormat:@"%d",q0];
            QuaternionB_lbl.text = [NSString stringWithFormat:@"%d",q1];
            QuaternionC_lbl.text = [NSString stringWithFormat:@"%d",q2];
            QuaternionD_lbl.text = [NSString stringWithFormat:@"%d",q3];
            
            break;
            
        case 5: // Euler
            [pktData getBytes:&yaw range:NSMakeRange(8,2)];
            [pktData getBytes:&pitch range:NSMakeRange(10,2)];
            [pktData getBytes:&roll range:NSMakeRange(12,2)];
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            
            NSLog(@"Euler data Yaw = %d, pitch = %d, Roll = %d", yaw,pitch,roll);
            
            _Pitch_lbl.text = [NSString stringWithFormat:@"%d",pitch];
            _Yaw_lbl.text = [NSString stringWithFormat:@"%d",yaw];
            _Roll_lbl.text = [NSString stringWithFormat:@"%d",roll];
            break;
            
        case 6: // Ext Force
            [pktData getBytes:&fext_x range:NSMakeRange(8,2)];
            [pktData getBytes:&fext_y range:NSMakeRange(10,2)];
            [pktData getBytes:&fext_z range:NSMakeRange(12,2)];
            
            fext_x = (int16_t)CFSwapInt16HostToLittle(fext_x);
            fext_y = (int16_t)CFSwapInt16HostToLittle(fext_y);
            fext_z = (int16_t)CFSwapInt16HostToLittle(fext_z);
            
            NSLog(@"External Force vector x = %d, y = %d, z = %d", fext_x,fext_y,fext_z);
            
            _GravityX_lbl.text = [NSString stringWithFormat:@"%d",fext_x];
            _GravityY_lbl.text = [NSString stringWithFormat:@"%d",fext_y];
            _GravityZ_lbl.text = [NSString stringWithFormat:@"%d",fext_z];
            
            break;
            
        default:
            break;
            
    }
}


@end
