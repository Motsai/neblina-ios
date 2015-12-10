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
@synthesize switch_9axis, switch_euler, switch_external, switch_heading, switch_magnetometer, switch_motindata, switch_pedometer,switch_quaternion, switch_record,switch_test1,switch_traj_distance,switch_traj_record;
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
    
    mutable_packet_Data = [[NSMutableData alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self readBinaryFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)readBinaryFile
{
    logging_btn.tag = 2;
    [logging_btn setTitle:@"Stop Logging" forState:UIControlStateNormal];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"QuaternionStream" ofType:@"bin"];//put the path to your file here
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

    uint8_t *bytePtr = (uint8_t  * )[fileData bytes];
    single_packet= (__bridge NSData *)((__bridge void *)([NSData dataWithBytes:(void *)(bytePtr+(count*sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))) length:20]));

    // Appending new packets to mutable data
    [mutable_packet_Data appendData:single_packet];
    
    // Writing data to DataLogger File
    uint8_t *fileBytes = (uint8_t *)[single_packet bytes];
    NSData *data = [[NSData alloc] initWithBytes:fileBytes length:[single_packet length]];
    NSString *appFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DataLogger.bin"];

    if(![[NSFileManager defaultManager] fileExistsAtPath:appFile])
    {
        [[NSFileManager defaultManager] createFileAtPath:appFile contents:nil attributes:nil];
        [data writeToFile:appFile atomically:YES];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:appFile];
        [myHandle seekToEndOfFile];
        [myHandle writeData:data];
    }

//    // Delete data to DataLogger File
//    NSError *error = nil;
//    [[NSFileManager defaultManager] removeItemAtPath:appFile error:&error];

//    // Reading data to DataLogger File
//    logger_file_Data = [NSData dataWithContentsOfFile:appFile];
   
    start_flag = true;
    [self.logger_tbl reloadData];
    
    if (count == deactivate_var)
    {
        [timer invalidate];
        
        logging_btn.tag = 1;
        [logging_btn setTitle:@"Start Logging" forState:UIControlStateNormal];
    }
    
    count ++;
}

#pragma mark - action method

-(IBAction)switchAction:(UISegmentedControl *)segment
{
    Neblina *neblina_obj = [[Neblina alloc]init];
    NSLog(@"Selected Segment = %ld", segment.selectedSegmentIndex);
    
    if (segment.tag == 1)
    {
        [neblina_obj SixAxisIMU_Stream:switch_9axis.selectedSegmentIndex];
    }
    else if (segment.tag == 2)
    {
        [neblina_obj QuaternionStream:switch_quaternion.selectedSegmentIndex];
    }
    else if (segment.tag == 3)
    {
        [neblina_obj EulerAngleStream:switch_euler.selectedSegmentIndex];
    }
    else if (segment.tag == 4)
    {
        [neblina_obj ExternalForceStream:switch_external.selectedSegmentIndex];
    }
    else if (segment.tag == 5)
    {
        [neblina_obj PedometerStream:switch_pedometer.selectedSegmentIndex];
    }
    else if (segment.tag == 6)
    {
        [neblina_obj TrajectoryRecord:switch_traj_record.selectedSegmentIndex];
    }
    else if (segment.tag == 7)
    {
        [neblina_obj TrajectoryDistanceData:switch_traj_distance.selectedSegmentIndex];
    }
    else if (segment.tag == 8)
    {
        [neblina_obj MagStream:switch_magnetometer.selectedSegmentIndex];
    }
    else if (segment.tag == 9)
    {
        [neblina_obj MotionStream:switch_motindata.selectedSegmentIndex];
    }
    else if (segment.tag == 10)
    {
        [neblina_obj RecorderErase:switch_record.selectedSegmentIndex];
    }
    else if (segment.tag == 11)
    {
        [neblina_obj Recorder:switch_heading.selectedSegmentIndex];
    }
    else if (segment.tag == 12)
    {
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
//    return [pckt_data count];;
    return deactivate_var;
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
        void *bytePtr = (__bridge void *)([NSData dataWithData:mutable_packet_Data]);
        
        Quaternion_t* t= (__bridge Quaternion_t *)([NSData dataWithBytes:(void *)(bytePtr+(indexPath.row*sizeof(Fusion_DataPacket_t))+sizeof(uint32_t)+sizeof(NEB_PKTHDR)) length:MAX_NB_BYTES]);
        
        NSLog(@"q0 = %x", (int16_t)t->q[0]);
        NSLog(@"q1 = %x", (int16_t)t->q[1]);
        NSLog(@"q2 = %x", (int16_t)t->q[2]);
        NSLog(@"q3 = %x", (int16_t)t->q[3]);
        
        NSString *myString = [NSString stringWithFormat:@" %x %x %x %x", (int16_t)t->q[0], (int16_t)t->q[1],(int16_t)t->q[2],(int16_t)t->q[3]];
        cell.textLabel.text = myString;
        
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:deactivate_var-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    uint8_t * bytePtr = (uint8_t  * )[mutable_packet_Data bytes];

    Quaternion_t *t= (__bridge Quaternion_t *)([NSData dataWithBytes:(void *)(bytePtr+(indexPath.row*sizeof(Fusion_DataPacket_t))+sizeof(uint32_t)+sizeof(NEB_PKTHDR)) length:MAX_NB_BYTES]);
    
    NSLog(@"q0 = %x", (int16_t)t->q[0]);
    NSLog(@"q1 = %x", (int16_t)t->q[1]);
    NSLog(@"q2 = %x", (int16_t)t->q[2]);
    NSLog(@"q3 = %x", (int16_t)t->q[3]);

    QuaternionA_lbl.text = [NSString stringWithFormat:@"%x", (int16_t)t->q[0]];
    QuaternionB_lbl.text = [NSString stringWithFormat:@"%x", (int16_t)t->q[1]];
    QuaternionC_lbl.text = [NSString stringWithFormat:@"%x", (int16_t)t->q[2]];
    QuaternionD_lbl.text = [NSString stringWithFormat:@"%x", (int16_t)t->q[3]];
}


@end
