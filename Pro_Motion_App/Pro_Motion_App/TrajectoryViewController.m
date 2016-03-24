//
//  TrajectoryViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "TrajectoryViewController.h"
#import "UIBezierPath+Interpolation.h"
#import "CGPointExtension.h"
#import "CRVINTERGraphicsView.h"
#import "ViewController.h"

@import GLKit;

@interface TrajectoryViewController ()

@end

@implementation TrajectoryViewController
{
    DataSimulator* dataSim;
    __weak IBOutlet CRVINTERGraphicsView *graphicsView;
    SCNScene* scene;
    SCNScene* scene2;
    NSData* lastPacket;
    BOOL bTrajtrackingon;
    int32_t tmLastQuat, tmLastTraj;
    NSMutableArray* positions,*positions1;
    NSMutableArray* indices;
    SCNGeometrySource *vertexSource;
    SCNGeometryElement *element;
    NSUInteger pointCount,pointCount1;
    SCNNode *lastlineNode1;
    SCNNode *box;
    SCNNode* _cameraNode1;
    SCNCamera* camera1;
    int lastrepetition;
    int nDrawRecorded;
    CGPoint oldpoint;
    //CAShapeLayer* shapeLayer;
    CAShapeLayer* lastLayer,*lastrepLayer;
    CAShapeLayer* drawingrepLayer;
    CAShapeLayer* shapeLayer2;
    //UIBezierPath* path;
    //CGPoint interpolationPoints[];
    //GLKVector3 v3, v3_old;
    //SCNMaterial * material;
    //GLKVector3 prod_vec1;
    
    //SCNVector3 positions2[5000];
    //int indices2[5000];
    
    //SCNVector3 positions2_rep[5000];
    //int indices2_rep[5000];
    //SCNNode *lastlineNode1_rep;
    //float g_x,g_y;
    
    NSMutableArray* interpolation_points,* interpolation_points1;
    SCNNode* currentDrawingNode;
    
    BOOL bRecordStarted, bStartDrawing;
    UIColor* currentColor;
    float f_xrot, f_yrot, f_zrot;
    int16_t repetition;
    CAGradientLayer* bkLayer;
}

+ (CAGradientLayer*) blueGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(120/255.0) green:(135/255.0) blue:(150/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(57/255.0)  green:(79/255.0)  blue:(96/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.view.bounds;
    [[self.view layer] insertSublayer:bkLayer atIndex:0];
    
   
    interpolation_points = [NSMutableArray new];
    interpolation_points1 = [NSMutableArray new];
    bTrajtrackingon = false;
    pointCount = 0;
    pointCount1 = 0;
    nDrawRecorded = 0;
    bRecordStarted = NO;
    repetition = 0;
    lastrepetition = -1;
    f_xrot = f_yrot = f_zrot = 0.0;
    bStartDrawing = NO;
    
    
    scene = [SCNScene sceneNamed:@"C-3PO.dae"];
    _viewpoint1.allowsCameraControl = NO;
    _viewpoint1.autoenablesDefaultLighting = YES;
    _viewpoint1.backgroundColor = [UIColor blackColor];
    _viewpoint1.scene = scene;
    _viewpoint1.scene.rootNode.position = SCNVector3Make(0, 0, 0);
    
    
    camera1 = [SCNCamera camera];
    camera1.zFar = 50;
    
    _cameraNode1 = [SCNNode node];
    _cameraNode1.camera = camera1;
    //_cameraNode1.position = SCNVector3Make(0, 12,0);
    _cameraNode1.position = SCNVector3Make(0, 0,8);
    
    SCNNode* lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0,10,10);
    [_viewpoint1.scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode* ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [_viewpoint1.scene.rootNode addChildNode:ambientLightNode];
    
    //_cameraNode1.rotation = SCNVector4Make(-1, 0, 0,M_PI_2);
    SCNNode* arm = [_viewpoint1.scene.rootNode childNodeWithName:@"CP30" recursively:true];
    arm.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180));
    
    _viewpoint1.pointOfView = _cameraNode1;
    
    box = [SCNNode node];
    box.geometry = [SCNBox boxWithWidth:.0 height:.0 length:.0 chamferRadius:.0];
    box.physicsBody = [SCNPhysicsBody staticBody];
    // position the box to the end of the ship
    box.position = SCNVector3Make(box.position.x, box.position.y, box.position.z +5.6);
    box.geometry.firstMaterial.specular.contents = [UIColor whiteColor];
    [_viewpoint1.scene.rootNode addChildNode:box];
   
    positions = [[NSMutableArray alloc] init];
    positions1 = [[NSMutableArray alloc] init];

    indices = [[NSMutableArray alloc] init];
    [self clearDataPoints];
    [self updateGraphicsView];
    
    
    [self initLayers];
    
    
    _recorder_btn.tag = 1;
    

}

-(void) initLayers
{
    shapeLayer2 = [[CAShapeLayer alloc] init];
    shapeLayer2.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer2.fillColor = nil;
    shapeLayer2.lineWidth = 3;
    shapeLayer2.lineJoin = kCALineJoinRound;
    shapeLayer2.lineCap = kCALineCapRound;
   // shapeLayer2.opaque = FALSE;
    
    
    // set the drawing color
    currentColor = [UIColor colorWithRed:0.0 green:253.0/255.0 blue:0.0 alpha:0.5];
    

    drawingrepLayer = [[CAShapeLayer alloc] init];
    drawingrepLayer.strokeColor = currentColor.CGColor;
    drawingrepLayer.fillColor = nil;
    drawingrepLayer.lineWidth = 3;
    drawingrepLayer.lineJoin = kCALineJoinRound;
    drawingrepLayer.lineCap = kCALineCapRound;
    drawingrepLayer.opaque = FALSE;
    
    [graphicsView layer].masksToBounds = YES;
    
     bkLayer = [TrajectoryViewController blueGradient];
    bkLayer.frame = graphicsView.bounds;
    //bkLayer.opaque = FALSE;
    [[graphicsView layer] insertSublayer:bkLayer atIndex:0];
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    
    dataSim = [DataSimulator sharedInstance];
    dataSim.delegate = self;
    
    // Stop receiving both the commands
    //[dataSim.neblina_dev SendCmdTrajectoryRecord:0];
    //[dataSim.neblina_dev SendCmdTrajectoryInfo:0];
    //[dataSim start];
    [self updateLoggingBtnStatus];
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    dataSim.delegate = nil;
}

// using this to get fewer points to check out the smoothness of the curve..ideally I should be changing the frequency of packets that Neblina sends, but the protocol doesn't give that function yet
static int ii = 0;

-(void)handleDataAndParsefortype:(UInt8)type data:(NSData*)pktData
{
    if( ii < 3)
    {
        ii++;
        return;
    }
    ii = 0;
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
    int nCmd = type;
    
    lastPacket = pktData;
    
    
    int32_t tmstamp;
    [pktData getBytes:&tmstamp range:NSMakeRange(0,4)];
    tmstamp = (int32_t)CFSwapInt32HostToLittle(tmstamp);

    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    int16_t q0, q1,q2,q3;
    int16_t yaw,pitch,roll;
    int16_t fext_x,fext_y,fext_z;
    SCNNode* rootNode = [scene rootNode];
    
    
    switch(nCmd)
    {
            
        case Quaternion: // Quaternion data
            tmLastQuat = tmstamp;
            [pktData getBytes:&q0 range:NSMakeRange(4,2)];
            [pktData getBytes:&q1 range:NSMakeRange(6,2)];
            [pktData getBytes:&q2 range:NSMakeRange(8,2)];
            [pktData getBytes:&q3 range:NSMakeRange(10,2)];
            q0 = (int16_t)CFSwapInt16HostToLittle(q0);
            q1 = (int16_t)CFSwapInt16HostToLittle(q1);
            q2 = (int16_t)CFSwapInt16HostToLittle(q2);
            q3 = (int16_t)CFSwapInt16HostToLittle(q3);
            
            
            //int a = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8);
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            
            [SCNTransaction setAnimationDuration:0];
            float f_q0 = (float)q0/32768.0;
            float f_q1 = (float)q1/32768.0;
            float f_q2 = (float)q2/32768.0;
            float f_q3 = (float)q3/32768.0;
            
            // NSLog(@"Quaternion data is = %f, %f, %f %f", f_q0*1000,f_q1*1000,f_q2*1000,f_q3*1000);
            
            // divide by 32768.0 to get it into the [-1,1] range..mentioned in Metal documentation
           
                               
            
                //if(!bTrajtrackingon)
                //{
                
                
                    _viewpoint1.scene.rootNode.orientation = SCNVector4Make(f_q0, f_q1, f_q2, f_q3);
                     SCNVector3 pt = [box convertPosition:SCNVector3Make(box.position.x, box.position.y, box.position.z) toNode:nil];
                
                    //NSLog(@"BOX Position is = %f, %f, %f ", pt.x*10,pt.y*10,pt.z*10);
            if(bStartDrawing)
            {
                    if(bRecordStarted == YES)
                    {
                
                        CGPoint pt_1 = CGPointMake(pt.x*20+250, pt.y*20+200);
                        NSLog(@"BOX Position is = %f, %f ", pt_1.x,pt_1.y );
                        const char *encoding = @encode(CGPoint);
                        //[graphicsView.interpolationPoints addObject:[NSValue valueWithBytes:&pt_1 objCType:encoding]];
                        
                        [interpolation_points addObject:[NSValue valueWithBytes:&pt_1 objCType:encoding]];
                        

                    
                        UIBezierPath* path2 = [UIBezierPath bezierPath];
                        path2 = [UIBezierPath interpolateCGPointsWithHermite:interpolation_points closed:NO];
                    
                        shapeLayer2.path = path2.CGPath;
                        //[graphicsView layer].masksToBounds = YES;
                     
                        [[graphicsView layer] insertSublayer:shapeLayer2 above:bkLayer];
                        
                        
                    
//                        if(lastLayer)
//                        {
//                            [lastLayer removeFromSuperlayer];
//                        }
//                        lastLayer = shapeLayer2;
                    }
                    else
                    {
                
                    _viewpoint1.scene.rootNode.orientation = SCNVector4Make(f_q0, f_q1, f_q2, f_q3);
                
                    SCNVector3 pt = [box convertPosition:SCNVector3Make(box.position.x, box.position.y, box.position.z) toNode:nil];
                
                    CGPoint pt_1 = CGPointMake(pt.x*20+250, 200+pt.y*20);
                    const char *encoding = @encode(CGPoint);
                    [interpolation_points1 addObject:[NSValue valueWithBytes:&pt_1 objCType:encoding]];
               
                    drawingrepLayer.strokeColor = currentColor.CGColor;
                
                    UIBezierPath* path2 = [UIBezierPath bezierPath];
                
                    path2 = [UIBezierPath interpolateCGPointsWithHermite:interpolation_points1 closed:NO];
                
                    //[drawingrepLayer.path removeAllPoints];
                    drawingrepLayer.path = path2.CGPath;
                
                    //[graphicsView layer].masksToBounds = YES;
                    [[graphicsView layer] insertSublayer:drawingrepLayer above:shapeLayer2];
                    //[[graphicsView layer] insertSublayer:bkLayer below:shapeLayer2];
//                    if(lastrepLayer)
//                    {
//                        [lastrepLayer removeFromSuperlayer];
//                    }
//                    lastrepLayer = drawingrepLayer;
                    
                    [self updateLabelswithxdelta:f_xrot ydelta:f_yrot zdelta:f_zrot rep:repetition];

                
                    }
            }
            
         
            [SCNTransaction commit];
            
            
            break;
            
        case 9: // Trajectory Tracking
            
            bRecordStarted = NO;
            _recorder_btn.tag = 1;

            [pktData getBytes:&yaw range:NSMakeRange(4,2)];
            [pktData getBytes:&pitch range:NSMakeRange(6,2)];
            [pktData getBytes:&roll range:NSMakeRange(8,2)];
            [pktData getBytes:&repetition range:NSMakeRange(10,2)];
            
            
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            repetition = (int16_t)CFSwapInt16HostToLittle(repetition);
            if((lastrepetition != repetition) /*|| (repetition == 0)*/)
           // if(repetition >= 0)
            {
                // clear the points
                [interpolation_points1 removeAllObjects];
                
                
                /*switch(repetition)
                {
                        
                    case 0:
                        currentColor = [UIColor darkGrayColor];
                        break;
                    case 1:
                        currentColor = [UIColor redColor];
                        break;
                    case 2:
                        currentColor = [UIColor greenColor];
                        break;
                    case 3:
                        currentColor = [UIColor blueColor];
                        break;
                    case 4:
                        currentColor = [UIColor orangeColor];
                        break;
                    case 5:
                        currentColor = [UIColor yellowColor];
                        break;
                    case 6:
                        currentColor = [UIColor purpleColor];
                        break;
                    case 7:
                        currentColor = [UIColor brownColor];
                        break;
                    case 8:
                        currentColor = [UIColor magentaColor];
                        break;
                    default:
                        currentColor = [UIColor colorWithRed:0.0 green:253.0/255.0 blue:0.0 alpha:0.5];
                        break;
                }*/
                
                
            }
            lastrepetition = repetition;
            
            f_xrot = (float)yaw / 10.0;
            f_yrot = (float)pitch / 10.0;
            f_zrot = (float)roll / 10.0;
            
            
             NSLog(@"Timestamp: %d Trajectory Delta Angles Yaw = %f, pitch = %f, Roll = %f Repetition = %d", tmstamp,f_xrot,f_yrot,f_zrot, repetition);
            
            
            
           // if(tmstamp == tmLastQuat) // timestamps matched
            {
              //  [self updateLabelswithxdelta:f_xrot ydelta:f_yrot zdelta:f_zrot rep:repetition];
                
            }
            
            break;
            
            
        default:
            break;
            
    }
    });

    
}




- (void)updateGraphicsView {
  
}



- (void)clearDataPoints {

}


-(void) updateLoggingBtnStatus
{
    if([dataSim isLoggingStopped])
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
        [dataSim start];
    }
    else if (button.tag == 2)
    {
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [dataSim pause];
    }
    
}

- (IBAction)startRecord:(id)sender {
    if(_recorder_btn.tag == 1)
    {
        _recorder_btn.tag = 2;
        // clean the earlier data
        [interpolation_points removeAllObjects];
        [interpolation_points1 removeAllObjects];
        [drawingrepLayer removeFromSuperlayer];
        [shapeLayer2 removeFromSuperlayer];
        [bkLayer removeFromSuperlayer];
        
        [self initLayers];
        
        [self updateLabelswithxdelta:0.0 ydelta:0.0 zdelta:0.0 rep:0];
        
        //[dataSim.neblina_dev SendCmdTrajectoryInfo:1];
        [dataSim.neblina_dev SendCmdTrajectoryRecord:1];
        
        bRecordStarted = YES;
        bStartDrawing = YES;
        
       
    }
    else{
        _recorder_btn.tag = 1;
        //[dataSim.neblina_dev SendCmdTrajectoryInfo:0];
        [dataSim.neblina_dev SendCmdTrajectoryRecord:0];
        
        bRecordStarted = NO;
        bTrajtrackingon = YES;
        f_xrot = f_yrot = f_zrot = 0.0;
        repetition = 0;
        lastrepetition = -1;
       
        
    }
    
    
}

-(void) updateLabelswithxdelta:(float)f_xrot ydelta:(float)f_yrot zdelta:(float)f_zrot rep:(int)repetition
{
    
 
    _lbl_X.text = [NSString stringWithFormat:@"%f",f_xrot];
    _lbl_Y.text = [NSString stringWithFormat:@"%f",f_yrot];
    _lbl_Z.text = [NSString stringWithFormat:@"%f",f_zrot];
    _lbl_repetition.text = [NSString stringWithFormat:@"%d",repetition];
    
    
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


@end
