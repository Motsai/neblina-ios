//
//  9AxisViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "9AxisViewController.h"

@interface _AxisViewController ()

@end

@implementation _AxisViewController
DataSimulator* dataSim;
SCNScene* scene;
SCNScene* scene2;


- (void) viewWillAppear:(BOOL)animated
{
    dataSim = [[DataSimulator alloc] init];
    dataSim.delegate = self;
  
}

-(void) viewDidAppear:(BOOL)animated
{
     [dataSim readBinaryFile:@"QuatRotationRandom"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    scene = [SCNScene sceneNamed:@"head.dae"];
    _viewpoint1.allowsCameraControl = YES;
    _viewpoint1.autoenablesDefaultLighting = YES;
    _viewpoint1.backgroundColor = [UIColor blackColor];
    _viewpoint1.scene = scene;
   
    scene2 = [SCNScene sceneNamed:@"head.dae"];
    _viewpoint2.allowsCameraControl = YES;
    _viewpoint2.autoenablesDefaultLighting = YES;
    _viewpoint2.backgroundColor = [UIColor blackColor];
    _viewpoint2.scene = scene2;
    
    // to switch to Side view of the head - uncomment the below 2 lines
    //_viewpoint2.pointOfView.position = SCNVector3Make(500, 0, 50);
    //_viewpoint2.pointOfView.eulerAngles = SCNVector3Make(M_PI_2,0,M_PI_2);
    
    // Top View of the head
    _viewpoint2.pointOfView.position = SCNVector3Make(0, 25, 525);
    _viewpoint2.pointOfView.eulerAngles = SCNVector3Make(0,0,-M_PI);
    
    // to switch to Bottom view of the head - uncomment the below 2 lines
    //_viewpoint2.pointOfView.position = SCNVector3Make(0, 25, -500);
    //_viewpoint2.pointOfView.eulerAngles = SCNVector3Make(M_PI,0,0);

}

-(void) viewWillDisappear:(BOOL)animated
{
    [dataSim reset];
}

// This is called on the delegate to handle the data packet
-(void) handleDataAndParse:(NSData *)pktData
{
    
    int nCmd=0;
    
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    int16_t q0, q1,q2,q3;
    int16_t yaw,pitch,roll;
    int16_t fext_x,fext_y,fext_z;
    SCNNode* rootNode = [scene rootNode];
    
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
            
            // move it approp
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            [rootNode runAction:[SCNAction rotateByX:(float)mag_orient_x/32767 y:(float)mag_orient_y/32767 z:(float)mag_orient_z/32767 duration:0]];
            
            
            
            [SCNTransaction commit];
            
            
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
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            
            [SCNTransaction setAnimationDuration:0];
            // divide by 32767 to get it into the [-1,1] range..mentioned in Metal documentation
            _viewpoint1.scene.rootNode.rotation = SCNVector4Make( (float)q0/32767, (float)q1/32767, (float)q2/32767, (float)q3/32767);
            
            _viewpoint2.scene.rootNode.rotation = SCNVector4Make( (float)q0/32767, (float)q1/32767, (float)q2/32767, (float)q3/32767);
            
            
            [SCNTransaction commit];
            // update the labels
            _QuaternionA_lbl.text = [NSString stringWithFormat:@"%d",q0];
            _QuaternionB_lbl.text = [NSString stringWithFormat:@"%d",q1];
            _QuaternionC_lbl.text = [NSString stringWithFormat:@"%d",q2];
            _QuaternionD_lbl.text = [NSString stringWithFormat:@"%d",q3];
            
            break;
            
        case 5: // Euler
            [pktData getBytes:&yaw range:NSMakeRange(8,2)];
            [pktData getBytes:&pitch range:NSMakeRange(10,2)];
            [pktData getBytes:&roll range:NSMakeRange(12,2)];
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            
            NSLog(@"Euler data Yaw = %d, pitch = %d, Roll = %d", yaw,pitch,roll);
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            
            rootNode.eulerAngles = SCNVector3Make(yaw, pitch, roll);
            [SCNTransaction commit];
            
            // update the labels
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
            
            // update the labels
            _GravityX_lbl.text = [NSString stringWithFormat:@"%d",fext_x];
            _GravityY_lbl.text = [NSString stringWithFormat:@"%d",fext_y];
            _GravityZ_lbl.text = [NSString stringWithFormat:@"%d",fext_z];
            break;
            
        default:
            break;
            
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (SCNQuaternion)orientationFromCMQuaternion:(CMQuaternion)q
//{
//    GLKQuaternion gq1 =  GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(90), 0, 0, 1); // add a rotation of the pitch 90 degrees
//    GLKQuaternion gq2 =  GLKQuaternionMake(q.x, q.y, q.z, q.w); // the current orientation
//    GLKQuaternion qp  =  GLKQuaternionMultiply(gq1, gq2); // get the "new" orientation
//    CMQuaternion rq =   {.x = qp.x, .y = qp.y, .z = qp.z, .w = qp.w};
//    
//    return SCNVector4Make(rq.x, rq.y, rq.z, rq.w);
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
