//
//  LocationViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "LocationViewController.h"
#import "GeoPointCompass.h"
#import "ViewController.h"
//#import "neblina.h"
//#import "FusionEngineDataTypes.h"
//#import "Pro_Motion_App-Swift.h"

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)


@interface LocationViewController ()


@end

@implementation LocationViewController

DataSimulator* dataSim2;
GeoPointCompass *geoPointCompass;
int16_t nLastCadence;
CGPoint startpoint;
int16_t nLastSteps;
CPTGraph* graph;
NSMutableArray* graphPoints;
int16_t xmin, xmax, ymin, ymax;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.view.bounds;
    [[self.view layer] insertSublayer:bkLayer atIndex:0];
    
    
    geoPointCompass = [[GeoPointCompass alloc] init];
    
    
    // Add the image to be used as the compass on the GUI
    [geoPointCompass setArrowImageView:_imgCompass];
    
    startpoint = CGPointMake(0, 0);
    nLastSteps = 0;
    
    graphPoints = [[NSMutableArray alloc] init];
    [self initPlot];
   
    // default cadence 60
    nLastCadence = 60;
    [self startAnimationwithcadence:60];
    
}

-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureAxes];
    [self configureChart];
    
}

-(void)configureHost {
    
    _hostView.allowPinchScaling = NO;
    
}

-(void)configureGraph {
    
    CGRect parentRect = _hostView.bounds;
    
    parentRect = CGRectMake(parentRect.origin.x,
                            parentRect.origin.y,
                            parentRect.size.width,
                            parentRect.size.height);
    // 1 - Create graph
    graph = [[CPTXYGraph alloc] initWithFrame:_hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    [graph.plotAreaFrame setPaddingTop:30.0f];
     [graph.plotAreaFrame setPaddingBottom:20.0f];
    
    
    _hostView.hostedGraph = graph;
    
    
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    
    // 3 - Configure title
    NSString *title = @"Walking/Running Path";
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    //graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    // 4 - Set theme
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    
    

}

-(void)configureChart {
    
    // 1 - Get reference to graph
    CPTGraph *graph = _hostView.hostedGraph;
    
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace*) graph.defaultPlotSpace;
    
    [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:-20] length:(NSNumber *)[NSNumber numberWithFloat:40]]];
    ymin = -20;
    ymax = 40;
    
    [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:-20] length:(NSNumber *)[NSNumber numberWithFloat:40]]];
    xmin = -20;
    xmax = 40;
    //
    // 2 - Create plot
    
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.dataSource = self;
    plot.delegate = self;
    plot.identifier = graph.title;
    
    CPTMutableLineStyle *lineStyle = plot.dataLineStyle;
    lineStyle.lineColor = [CPTColor greenColor];
    lineStyle.lineWidth = 3.0;
    plot.dataLineStyle = lineStyle;
    
    [graph addPlot:plot];
    

}

-(void) configureAxes
{
    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    CPTAxis *y = axisSet.yAxis;
    
    x.preferredNumberOfMajorTicks = 10;
    y.preferredNumberOfMajorTicks = 10;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;/*CPTAxisLabelingPolicyEqualDivisions*/;
    
}

-(void) configureLegend
{
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}






-(void) viewWillAppear:(BOOL)animated
{

}
-(void) viewDidAppear:(BOOL)animated
{
    dataSim2 = [DataSimulator sharedInstance];
    dataSim2.delegate = self;
    
    //[self selectDatastream];
    
    
    [self updateLoggingBtnStatus];
    
    
}


-(void) selectDatastream
{
    [dataSim2.neblina_dev SendCmdQuaternionStream:FALSE];
    [dataSim2.neblina_dev SendCmdEulerAngleStream:FALSE];
    [dataSim2.neblina_dev SendCmdPedometerStream:TRUE];
}


-(void) viewWillDisappear:(BOOL)animated
{
    dataSim2.delegate = nil;
    [self stopAnimation];
    
}

-(void)handleDataAndParsefortype:(UInt8)type data:(NSData*)pktData
{
    int nCmd = type;
    
    
    //Byte 0	Byte 1	Byte 2	Byte 3	Byte 4-7	Byte 8-9	Byte 10     Byte 11-12          Bytes 13-19
    //0x01      0x10	CRC     0x0A	TimeStamp	step count	cadence     direction angle     Reserved
    
    //[pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(0,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);
    
    int16_t nStepCount;
    int8_t nCadence;
    int16_t nDirAngle;
    float f_DirAngle;
    
    switch(nCmd)
    {
        case Pedometer: // Pedometer data
            [pktData getBytes:&nStepCount range:NSMakeRange(4,2)];
            [pktData getBytes:&nCadence range:NSMakeRange(6,1)];
            [pktData getBytes:&nDirAngle range:NSMakeRange(7,2)];
            
            
            
            nStepCount = (int16_t)CFSwapInt16HostToLittle(nStepCount);
            
            nDirAngle = (int16_t)CFSwapInt16HostToLittle(nDirAngle);
            f_DirAngle = nDirAngle/10.0;
            
            // NSLog(@"Timestamp: %d StepCount: %d, Cadence: %d, DirectionAngle: %f", tmstamp,nStepCount,nCadence,f_DirAngle);
            
            // Ignore these packets...
            if((nCadence == 0) && (f_DirAngle == 0))
                return;
            
            
            // update the cadence and spm labels
            [self updateLabelsWithCadence:nCadence count:nStepCount headingAngle:f_DirAngle];
            // update the compass
            //[geoPointCompass updateCompasswithDegress:f_DirAngle];
            // update the running man
            [self updateAnimationwithcadence:nCadence];
            // draw on the map
            [self updateMapwithWalking:f_DirAngle steps:nStepCount ts:tmstamp];
            
            //nLastSteps = nStepCount;
            break;
            
            
            
        default:
            break;
            
    }

   
}

// This is called on the delegate to handle the data packet
-(void) handleDataAndParse:(NSData *)pktData
{
    
    int nCmd=0;
    
    //Byte 0	Byte 1	Byte 2	Byte 3	Byte 4-7	Byte 8-9	Byte 10     Byte 11-12          Bytes 13-19
    //0x01      0x10	CRC     0x0A	TimeStamp	step count	cadence     direction angle     Reserved
    
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(4,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);
    
    int16_t nStepCount;
    int8_t nCadence;
    int16_t nDirAngle;
    float f_DirAngle;
    
    switch(nCmd)
    {
        case Pedometer: // Pedometer data
            [pktData getBytes:&nStepCount range:NSMakeRange(8,2)];
            [pktData getBytes:&nCadence range:NSMakeRange(10,1)];
            [pktData getBytes:&nDirAngle range:NSMakeRange(11,2)];
            
           
            
            nStepCount = (int16_t)CFSwapInt16HostToLittle(nStepCount);
            
            nDirAngle = (int16_t)CFSwapInt16HostToLittle(nDirAngle);
            f_DirAngle = nDirAngle/10.0;
            
           // NSLog(@"Timestamp: %d StepCount: %d, Cadence: %d, DirectionAngle: %f", tmstamp,nStepCount,nCadence,f_DirAngle);
            
            
            // update the cadence and spm labels
            [self updateLabelsWithCadence:nCadence count:nStepCount headingAngle:f_DirAngle];
            // update the compass
            //[geoPointCompass updateCompasswithDegress:f_DirAngle];
            // update the running man
            [self updateAnimationwithcadence:nCadence];
            // draw on the map
            [self updateMapwithWalking:f_DirAngle steps:nStepCount ts:tmstamp];
            
            nLastSteps = nStepCount;
            break;
            
       
            
        default:
            break;
            
    }
}

-(void) startAnimationwithcadence:(int) nCadence
{
    _img_RunningMan.animationImages = @[[UIImage imageNamed:@"man_1"], [UIImage imageNamed:@"man_2"],[UIImage imageNamed:@"man_3"], [UIImage imageNamed:@"man_4"],[UIImage imageNamed:@"man_5"],[UIImage imageNamed:@"man_6"],[UIImage imageNamed:@"man_7"],[UIImage imageNamed:@"man_8"]];
    
    
    float animDuration = 60.0/nCadence;
    //NSLog(@"Animation duration is %f",animDuration);
    _img_RunningMan.animationDuration = animDuration;
    _img_RunningMan.animationRepeatCount = 0;
    [_img_RunningMan startAnimating];
    
     nLastCadence = nCadence;
    
    
}

-(void) updateAnimationwithcadence:(int) nCadence
{
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
    if(abs(nCadence - nLastCadence) > 6)
    {
        [self stopAnimation];
        float animDuration = 60.0*2/nCadence;
        //NSLog(@"Animation duration is %f",animDuration);
        _img_RunningMan.animationDuration = animDuration;
        _img_RunningMan.animationRepeatCount = 0;
        [_img_RunningMan startAnimating];
        nLastCadence = nCadence;
        
    }
                   });
    
}

-(void) stopAnimation
{

    UIImage* img = [_img_RunningMan.animationImages lastObject];
    [_img_RunningMan stopAnimating];
    [_img_RunningMan setImage:img];
    
    
}

-(void) updateLabelsWithCadence:(int)nCadence count:(int)nStepCount headingAngle:(float) f_DirAngle
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
    _steps_lbl.text = [NSString stringWithFormat:@"%d",nStepCount];
    _cadense_lbl.text = [NSString stringWithFormat:@"%d",nCadence];
    _headingAngle_lbl.text = [NSString stringWithFormat:@"%.1f",f_DirAngle];
                       
        [geoPointCompass updateCompasswithDegress:f_DirAngle];
                   });
    
}



- (void)didReceiveMemoryWarning {
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
    if([dataSim2 isLoggingStopped])
    {
        _btnStartStopLog.tag = 1;
        [_btnStartStopLog setTitle:@"Start Logging" forState:UIControlStateNormal];
    }
    else
    {
        _btnStartStopLog.tag = 2;
        [_btnStartStopLog setTitle:@"Stop Logging" forState:UIControlStateNormal];
    }
}






- (IBAction)start_stop_logging:(UIButton*)button {
    
    if (button.tag == 1)
    {
        button.tag = 2;
        [button setTitle:@"Stop Logging" forState:UIControlStateNormal];
        [dataSim2 start];
        [self startAnimationwithcadence:nLastCadence];
    }
    else if (button.tag == 2)
    {
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [dataSim2 pause];
        [self stopAnimation];
        
    }
    

}

// get the endpoint given the angle and length
-(CGPoint) getEndPointforangle:(float)angle length:(int)len startpoint:(CGPoint) start
{
    float x = start.x + len * sin(angle);
    float y = start.y + len * cos(angle);
    return CGPointMake(x, y);
    
}


-(NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [graphPoints count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    CGPoint pt = [graphPoints[index] CGPointValue];
    
   NSLog(@"X[%d] Y[%d]  is (%f, %f)",index,index,pt.x,pt.y);
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithFloat:pt.x];
    }
    else
    {
        return [NSNumber numberWithFloat:pt.y];
    }
}


-(void) updateMapwithWalking:(float) angle steps:(int)nStepCount ts:(NSUInteger) ts
{
    angle = 0 - angle;
    
 
    
    dispatch_async(dispatch_get_main_queue(),
   ^{
   if((nStepCount - nLastSteps) == 0)
   {
       NSLog(@"Received the same stepCount again, not processing this...");
       return;
   }
    int nLen = nStepCount - nLastSteps;
    //calculate the endpoint
    
    
    CGPoint endPoint = [self getEndPointforangle:DegreesToRadians( angle ) length:nLen startpoint:startpoint];
    
    CPTGraph *graph = _hostView.hostedGraph;
    
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace*) graph.defaultPlotSpace;
    
    int nfactor = 3;
    
    if(endPoint.x < xmin)
    {
        xmin = xmin*nfactor;
        xmax = 0-(nfactor*xmin);
        
        [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:xmin] length:(NSNumber *)[NSNumber numberWithFloat:xmax]]];
        
        
    }
    if(endPoint.x > xmax/2)
    {
        xmin = xmin*nfactor;
        xmax = 0-(nfactor*xmin);
        [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:xmin] length:(NSNumber *)[NSNumber numberWithFloat:xmax]]];
    }
    if(endPoint.y < ymin)
    {
        ymin = ymin*nfactor;
        ymax = 0-(nfactor*ymin);
        
        [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:ymin] length:(NSNumber *)[NSNumber numberWithFloat:ymax]]];
        
    }
    if(endPoint.y > ymax/2)
    {
        ymin = ymin*nfactor;
        ymax = 0-(nfactor*ymin);
        [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:(NSNumber *)[NSNumber numberWithFloat:ymin] length:(NSNumber *)[NSNumber numberWithFloat:ymax]]];
    }
    
    [graphPoints addObject:[NSValue valueWithCGPoint:endPoint]];
                       NSLog(@"Startpoint: %f, %f Endpoint: %f, %f",startpoint.x,startpoint.y,endPoint.x,endPoint.y);
                       
                       startpoint = endPoint;
    [graph reloadData];
       
    nLastSteps = nStepCount;
    
    
   });
    
}


- (IBAction)onClear:(UIButton *)sender {
    
    [graphPoints removeAllObjects];
    [graph reloadData];
    startpoint = CGPointMake(0,0);
}
@end
