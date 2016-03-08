//
//  IMUStreamViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 04/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "IMUStreamViewController.h"
#import "ViewController.h"
//#import "neblina.h"
//#import "FusionEngineDataTypes.h"
//#import "Pro_Motion_App-Swift.h"
//#import "DataSimulator.h"

@implementation IMUStreamViewController
{
    NSUInteger count;
    DataSimulator* dataSimulator;
    
}
#define PKTS_TO_SHOW_INGRAPH 25

-(void) handleDataAndParse:(NSData *)pktData
{
    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    
    int nCmd=0;
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(4,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);
    NSLog(@"IMUhandleData&Parse Timestamp is %d",tmstamp);
    
    
    // checking for MAG packet
    if(nCmd == 12)
    {
        
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
        
        NSLog(@"%d IMU Accel is = %d, %d, %d", tmstamp,mag_accel_x,mag_accel_y,mag_accel_z);
        NSLog(@"%d IMU Mag is = %d, %d, %d", tmstamp,mag_orient_x,mag_orient_y,mag_orient_z);
        
        int scalefactor = 1;
        mag_orient_x = mag_orient_x/scalefactor;
        mag_orient_y = mag_orient_y/scalefactor;
        mag_orient_z = mag_orient_z/scalefactor;
        
        mag_accel_x = mag_accel_x/scalefactor;
        mag_accel_y = mag_accel_y/scalefactor;
        mag_accel_z = mag_accel_z/scalefactor;
        
        
        //NSLog(@"Scaled down Accel is = %d, %d, %d", accel_x,accel_y,accel_z);
        //NSLog(@"Scaled down Mag is = %d, %d, %d", orient_x,orient_y,orient_z);
        
        // update the graphs
        [self updateGraphswithAccel_x:mag_accel_x accel_y:mag_accel_y accel_z:mag_accel_z gryro_x:mag_orient_x gyro_y:mag_orient_y gyro_z:mag_orient_z ts:tmstamp];
        count++;
    }
    else
    {
        NSLog(@"Not a MAG packet");
    }
    
}


-(void)handleDataAndParsefortype:(UInt32)type data:(NSData*) pktData
{
    int nCmd = type;
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    

    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(0,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);
    NSLog(@"IMUhandleData&Parse Timestamp is %d",tmstamp);


    // checking for MAG packet
    if(nCmd == MAG_Data)
    {
        
        [pktData getBytes:&mag_orient_x range:NSMakeRange(4,2)];
        [pktData getBytes:&mag_orient_y range:NSMakeRange(6,2)];
        [pktData getBytes:&mag_orient_z range:NSMakeRange(8,2)];
        [pktData getBytes:&mag_accel_x range:NSMakeRange(10,2)];
        [pktData getBytes:&mag_accel_y range:NSMakeRange(12,2)];
        [pktData getBytes:&mag_accel_z range:NSMakeRange(14,2)];
        
        
        mag_orient_x = (int16_t)CFSwapInt16HostToLittle(mag_orient_x);
        mag_orient_y = (int16_t)CFSwapInt16HostToLittle(mag_orient_y);
        mag_orient_z = (int16_t)CFSwapInt16HostToLittle(mag_orient_z);
        
        mag_accel_x = (int16_t)CFSwapInt16HostToLittle(mag_accel_x);
        mag_accel_y = (int16_t)CFSwapInt16HostToLittle(mag_accel_y);
        mag_accel_z = (int16_t)CFSwapInt16HostToLittle(mag_accel_z);
        
        NSLog(@"%d IMU Accel is = %d, %d, %d", tmstamp,mag_accel_x,mag_accel_y,mag_accel_z);
        NSLog(@"%d IMU Mag is = %d, %d, %d", tmstamp,mag_orient_x,mag_orient_y,mag_orient_z);
        
        int scalefactor = 1;
        mag_orient_x = mag_orient_x/scalefactor;
        mag_orient_y = mag_orient_y/scalefactor;
        mag_orient_z = mag_orient_z/scalefactor;
        
        mag_accel_x = mag_accel_x/scalefactor;
        mag_accel_y = mag_accel_y/scalefactor;
        mag_accel_z = mag_accel_z/scalefactor;
        
        
        //NSLog(@"Scaled down Accel is = %d, %d, %d", accel_x,accel_y,accel_z);
        //NSLog(@"Scaled down Mag is = %d, %d, %d", orient_x,orient_y,orient_z);
        
        // update the graphs
        [self updateGraphswithAccel_x:mag_accel_x accel_y:mag_accel_y accel_z:mag_accel_z gryro_x:mag_orient_x gyro_y:mag_orient_y gyro_z:mag_orient_z ts:tmstamp];
        count++;
    }
    else
    {
        NSLog(@"Not a MAG packet");
    }
    
}


-(void) setup_accel_graph
{
    
    NSMutableArray *yVals3, *yVals2, *yVals;
    NSMutableArray *dataSets;
    LineChartData *data;
    NSMutableArray *xVals;
    LineChartDataSet *set1, *set2, *set3;
    
    _accel_view.delegate = self;
    
    yVals = [[NSMutableArray alloc] init];
    yVals2 = [[NSMutableArray alloc] init];
    yVals3 = [[NSMutableArray alloc] init];
    
    _accel_view.descriptionText = @"";
    _accel_view.noDataTextDescription = @"You need to provide data for the chart.";
    
    _accel_view.dragEnabled = true;
    [_accel_view setScaleEnabled:false];
    _accel_view.pinchZoomEnabled = true;
    _accel_view.drawGridBackgroundEnabled = false;
    _accel_view.drawBordersEnabled = true;
    _accel_view.drawMarkers = true;
    
    BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.minimumSize = CGSizeMake(40.f, 40.f);
    _accel_view.marker = marker;

    
    ChartYAxis *leftAxis = _accel_view.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = 25000.0;
    leftAxis.customAxisMin = -25000.0;
    leftAxis.startAtZeroEnabled = false;
    
    leftAxis.drawGridLinesEnabled=false;
    _accel_view.xAxis.drawGridLinesEnabled = false;
    [_accel_view.xAxis setAvoidFirstLastClippingEnabled:true];
    [_accel_view.xAxis setLabelsToSkip:4];
    

    _accel_view.rightAxis.enabled = false;
    _accel_view.autoScaleMinMaxEnabled = true;
    _accel_view.legend.form = ChartLegendFormLine;
    [_accel_view legend].font = [UIFont systemFontOfSize:12.0f];
    
    
    set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"X"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor redColor]];
    [set1 setCircleColor:UIColor.whiteColor];
    set1.lineWidth = 2.0;
    set1.circleRadius = 0.0;
    set1.fillAlpha = 65/255.0;
    set1.fillColor = [UIColor redColor];
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set1.drawCirclesEnabled = true;
    set1.drawCircleHoleEnabled = false;
    
    set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"Y"];
    set2.axisDependency = AxisDependencyLeft;
    [set2 setColor:[UIColor greenColor]];
    [set2 setCircleColor:UIColor.whiteColor];
    set2.lineWidth = 2.0;
    set2.circleRadius = 0.0;
    set2.fillAlpha = 65/255.0;
    set2.fillColor = [UIColor greenColor];
    set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set2.drawCircleHoleEnabled = false;
    set2.drawCirclesEnabled = true;
    set2.highlightEnabled = true;
    
    
    set3 = [[LineChartDataSet alloc] initWithYVals:yVals3 label:@"Z"];
    set3.axisDependency = AxisDependencyLeft;
    [set3 setColor:[UIColor blueColor]];
    set3.lineWidth = 2.0;
    set3.fillAlpha = 65/255.0;
    set3.fillColor = [UIColor blueColor];
    set3.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set3.highlightEnabled = true;
    set3.drawCircleHoleEnabled = false;
    set3.drawCirclesEnabled = true;
    set3.circleRadius = 0.0;
    [set3 setCircleColor:UIColor.whiteColor];
    
    
    dataSets = [[NSMutableArray alloc] init];
    xVals = [[NSMutableArray alloc] init];
    
    // add empty datasets
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    
    data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont systemFontOfSize:0.f]];
    
    _accel_view.backgroundColor = [UIColor whiteColor];
    _accel_view.data = data;
    
}



-(void) setup_gyros_graph
{
    
    NSMutableArray *yVals3, *yVals2, *yVals;
    NSMutableArray *dataSets;
    LineChartData *data;
    NSMutableArray *xVals;
    LineChartDataSet *set1, *set2, *set3;
    _gyros_view.delegate = self;
    
    yVals = [[NSMutableArray alloc] init];
    yVals2 = [[NSMutableArray alloc] init];
    yVals3 = [[NSMutableArray alloc] init];
    
    _gyros_view.descriptionText = @"";
    _gyros_view.noDataTextDescription = @"You need to provide data for the chart.";
    
    _gyros_view.dragEnabled = true;
    [_gyros_view setScaleEnabled:false];
    _gyros_view.pinchZoomEnabled = true;
    _gyros_view.drawGridBackgroundEnabled = false;
    _gyros_view.drawBordersEnabled = true;
    _gyros_view.drawMarkers = true;
    
    BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _gyros_view.marker = marker;

    
    ChartYAxis *leftAxis = _gyros_view.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = 5000.0;
    leftAxis.customAxisMin = -5000.0;
    leftAxis.startAtZeroEnabled = false;
    
    leftAxis.drawGridLinesEnabled=false;
    _gyros_view.xAxis.drawGridLinesEnabled = false;
    [_gyros_view.xAxis setAvoidFirstLastClippingEnabled:true];
    [_gyros_view.xAxis setLabelsToSkip:4];
    
    _gyros_view.rightAxis.enabled = false;
    _gyros_view.autoScaleMinMaxEnabled = true;
    _gyros_view.legend.form = ChartLegendFormLine;
    [_gyros_view legend].font = [UIFont systemFontOfSize:12.0f];
    
    set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"X"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor redColor]];
    [set1 setCircleColor:UIColor.whiteColor];
    set1.lineWidth = 2.0;
    set1.circleRadius = 0.0;
    set1.fillAlpha = 65/255.0;
    set1.fillColor = [UIColor redColor];
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set1.drawCirclesEnabled = false;
    set1.drawCircleHoleEnabled = false;
    
    set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"Y"];
    set2.axisDependency = AxisDependencyLeft;
    [set2 setColor:[UIColor greenColor]];
    [set2 setCircleColor:UIColor.whiteColor];
    set2.lineWidth = 2.0;
    set2.circleRadius = 0.0;
    set2.fillAlpha = 65/255.0;
    set2.fillColor = [UIColor greenColor];
    set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set2.drawCircleHoleEnabled = false;
    set2.drawCirclesEnabled = false;
    
    
    set3 = [[LineChartDataSet alloc] initWithYVals:yVals3 label:@"Z"];
    set3.axisDependency = AxisDependencyLeft;
    [set3 setColor:[UIColor blueColor]];
    set3.lineWidth = 2.0;
    set3.fillAlpha = 65/255.0;
    set3.fillColor = [UIColor blueColor];
    set3.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set3.drawCircleHoleEnabled = false;
    set3.drawCirclesEnabled = false;
    set3.circleRadius = 0.0;
    [set3 setCircleColor:UIColor.whiteColor];
    
    dataSets = [[NSMutableArray alloc] init];
    xVals = [[NSMutableArray alloc] init];
    
    // add empty datasets
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    
    data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont systemFontOfSize:0.f]];
    
    _gyros_view.backgroundColor = [UIColor whiteColor];
    _gyros_view.data = data;
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.view.bounds;
    [[self.view layer] insertSublayer:bkLayer atIndex:0];
    // Do any additional setup after loading the view.
    count = 0;
    self.title = @"IMU Streaming";
    [self setup_gyros_graph];
    [self setup_accel_graph];
    
    //[self updateLoggingBtnStatus];
    
   
}

-(void) viewDidAppear:(BOOL)animated
{
    dataSimulator = [DataSimulator sharedInstance];
    dataSimulator.delegate = self;
    //[dataSimulator start];
    [self updateLoggingBtnStatus];
    //[self selectDatastream];
    
    // if logging stopped, lets plot the last 200 points on the graph
    if([dataSimulator isLoggingStopped])
    {
        long nTotalPackets = [dataSimulator getTotalPackets];
        for (long j=nTotalPackets-2*PKTS_TO_SHOW_INGRAPH; j<nTotalPackets;j++)
        {
            if(j < 0) break;
            NSData* pkt = [dataSimulator getPacketAt:j];
            if(pkt)
            {
                [self handleDataAndParse:pkt];
            }
        }
    }
}

-(void) selectDatastream
{
    [dataSimulator.neblina_dev SendCmdQuaternionStream:FALSE];
    [dataSimulator.neblina_dev SendCmdPedometerStream:FALSE];
    [dataSimulator.neblina_dev SendCmdEulerAngleStream:FALSE];
     [dataSimulator.neblina_dev SendCmdExternalForceStream:FALSE];
    [dataSimulator.neblina_dev SendCmdMotionStream:FALSE];
    [dataSimulator.neblina_dev SendCmdSixAxisIMUStream:FALSE];
    [dataSimulator.neblina_dev SendCmdMagStream:TRUE];
}

-(void) viewWillDisappear:(BOOL)animated
{
    //[dataSimulator pause];
    dataSimulator.delegate = nil;
}


-(void)updateGraphswithAccel_x:(float)a_x accel_y:(float)a_y accel_z:(float)a_z gryro_x:(float)g_x gyro_y:(float)g_y gyro_z:(float)g_z ts:(NSUInteger) ts
{
    dispatch_async(dispatch_get_main_queue(),^
                   {
    
    // update the accel graph data sets
    LineChartData* data_accel = [_accel_view data];
    LineChartDataSet* set_accel_x = [[data_accel dataSets] objectAtIndex:0];
    LineChartDataSet* set_accel_y = [[data_accel dataSets] objectAtIndex:1];
    LineChartDataSet* set_accel_z = [[data_accel dataSets] objectAtIndex:2];
    
    [data_accel addXValue:[@(ts) stringValue]];
    [set_accel_x addEntry:[[ChartDataEntry alloc] initWithValue:a_x xIndex:data_accel.xValCount]];
    [set_accel_y addEntry:[[ChartDataEntry alloc] initWithValue:a_y xIndex:data_accel.xValCount]];
    [set_accel_z addEntry:[[ChartDataEntry alloc] initWithValue:a_z xIndex:data_accel.xValCount]];

    // update the gyros graph data sets
    LineChartData* data_gyros = [_gyros_view data];
    LineChartDataSet* set_gyros_x = [[data_gyros dataSets] objectAtIndex:0];
    LineChartDataSet* set_gyros_y = [[data_gyros dataSets] objectAtIndex:1];
    LineChartDataSet* set_gyros_z = [[data_gyros dataSets] objectAtIndex:2];
    
    
    [data_gyros addXValue:[@(ts) stringValue]];
    [set_gyros_x addEntry:[[ChartDataEntry alloc] initWithValue:g_x xIndex:data_gyros.xValCount]];
    [set_gyros_y addEntry:[[ChartDataEntry alloc] initWithValue:g_y xIndex:data_gyros.xValCount]];
    [set_gyros_z addEntry:[[ChartDataEntry alloc] initWithValue:g_z xIndex:data_gyros.xValCount]];
    
    
    [_gyros_view notifyDataSetChanged];
    [_accel_view notifyDataSetChanged];
    
    // we will only show the last 30 when it exceeds 30
    //int nShowhowmany = 30;
    if(count > PKTS_TO_SHOW_INGRAPH)
    {
        
        [_accel_view setVisibleXRangeMaximum:PKTS_TO_SHOW_INGRAPH];
        [_accel_view moveViewToX:data_accel.xValCount-PKTS_TO_SHOW_INGRAPH];
        
        [_gyros_view setVisibleXRangeMaximum:PKTS_TO_SHOW_INGRAPH];
        [_gyros_view moveViewToX:data_gyros.xValCount-PKTS_TO_SHOW_INGRAPH];

        
    }
                   });
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) updateLoggingBtnStatus
{
    if([dataSimulator isLoggingStopped])
    {
        _logging_btn.tag = 1;
        [_logging_btn setTitle:@"Start Logging" forState:UIControlStateNormal];
    }
    else
    {
        _logging_btn.tag = 2;
        [_logging_btn setTitle:@"Stop Logging" forState:UIControlStateNormal];
    }
}



- (IBAction)startstopLogging:(UIButton*)button {
    if (button.tag == 1)
    {
        button.tag = 2;
        [button setTitle:@"Stop Logging" forState:UIControlStateNormal];
        [dataSimulator start];
    }
    else if (button.tag == 2)
    {
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [dataSimulator pause];
    }

    
}
@end
