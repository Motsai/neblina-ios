//
//  9AxisViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "9AxisViewController.h"
#import "neblina.h"
#import "FusionEngineDataTypes.h"
#import "Pro_Motion_App-Swift.h"

@import GLKit;

@interface _AxisViewController ()

@end

@implementation _AxisViewController
DataSimulator* dataSim1;
SCNScene* scene;
SCNScene* scene2;
int16_t max_count = 15;
int16_t cnt = 15;
int16_t xf = 0;
int16_t yf = 0;
int16_t zf = 0;
NSData* lastPacket;



- (void) viewWillAppear:(BOOL)animated
{
    
  
}

-(void) viewDidAppear:(BOOL)animated
{
    
    
    dataSim1 = [DataSimulator sharedInstance];
    dataSim1.delegate = self;
    [self updateLoggingBtnStatus];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    scene = [SCNScene sceneNamed:@"ship.scn"];
    _viewpoint1.allowsCameraControl = NO;
    _viewpoint1.autoenablesDefaultLighting = YES;
    _viewpoint1.backgroundColor = [UIColor blackColor];
    _viewpoint1.scene = scene;
   
    scene2 = [SCNScene sceneNamed:@"ship.scn"];
    _viewpoint2.allowsCameraControl = NO;
    _viewpoint2.autoenablesDefaultLighting = YES;
    _viewpoint2.backgroundColor = [UIColor blackColor];
    _viewpoint2.scene = scene2;
    
    // Top View of the head
    //NSLog(@"Point of view: %f %f %f",_viewpoint1.pointOfView.position.x,_viewpoint1.pointOfView.position.y,_viewpoint1.pointOfView.position.z);
   // NSLog(@"Point of view euler angles: %f %f %f",_viewpoint1.pointOfView.eulerAngles.x,_viewpoint1.pointOfView.eulerAngles.y,_viewpoint1.pointOfView.eulerAngles.z);
    _viewpoint1.pointOfView.position = SCNVector3Make(0, 0, 17);
    _viewpoint2.pointOfView.position = SCNVector3Make(0, 17, 0);
    _viewpoint2.pointOfView.eulerAngles = SCNVector3Make(-M_PI_2,0,0);
    
    // to switch to Side view - uncomment the below 2 lines
    //_viewpoint2.pointOfView.position = SCNVector3Make(17, 0, 0);
    //_viewpoint2.pointOfView.eulerAngles = SCNVector3Make(0,M_PI_2,0);
    //[dataSim start];
    
    if([dataSim1 isLoggingStopped])
    {
        lastPacket = [dataSim1 getPacketAt:[dataSim1 getTotalPackets]-1];
        [self handleDataAndParse:lastPacket];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    dataSim1.delegate = nil;
}

// This is called on the delegate to handle the data packet
-(void) handleDataAndParse:(NSData *)pktData
{
    
    int nCmd=0;
    lastPacket = pktData;
    
    [pktData getBytes:&nCmd range:NSMakeRange(3,1)];
    
    int16_t mag_orient_x,mag_orient_y,mag_orient_z,mag_accel_x,mag_accel_y,mag_accel_z;
    int16_t q0, q1,q2,q3;
    int16_t yaw,pitch,roll;
    int16_t fext_x,fext_y,fext_z;
    SCNNode* rootNode = [scene rootNode];
    
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
            
            NSLog(@"Accel is = %d, %d, %d", mag_accel_x,mag_accel_y,mag_accel_z);
            NSLog(@"Mag is = %d, %d, %d", mag_orient_x,mag_orient_y,mag_orient_z);
            
            // move it approp - no action is there in the reference code
            
           // [SCNTransaction begin];
           // [SCNTransaction setDisableActions:YES];
           // [_viewpoint1.scene.rootNode runAction:[SCNAction rotateByX:(float)mag_orient_x/32767 y:(float)mag_orient_y/32767 z:(float)mag_orient_z/32767 duration:0]];
           // [_viewpoint2.scene.rootNode runAction:[SCNAction rotateByX:(float)mag_orient_x/32767 y:(float)mag_orient_y/32767 z:(float)mag_orient_z/32767 duration:0]];
           
          //  [SCNTransaction commit];
            
            // update the labels
            //[self updateQuatLabelswithX:mag_orient_x withY:mag_orient_y withZ:mag_orient_z withA:0];
            
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
            NSLog(@"Quaternion data is = %d, %d, %d %d", q0,q1,q2,q3);
            
            //int a = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8);
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            
            [SCNTransaction setAnimationDuration:0];
            float f_q0 = (float)q0/32768.0;
            float f_q1 = (float)q1/32768.0;
            float f_q2 = (float)q2/32768.0;
            float f_q3 = (float)q3/32768.0;
            
            // divide by 32768.0 to get it into the [-1,1] range..mentioned in Metal documentation
        
            _viewpoint1.scene.rootNode.orientation = SCNVector4Make(f_q0, f_q1, f_q2, f_q3);
            _viewpoint2.scene.rootNode.orientation = SCNVector4Make(f_q0, f_q1, f_q2, f_q3);
            
          [SCNTransaction commit];
            // update the labels
            [self updateQuatLabelswithX:f_q0 withY:f_q1 withZ:f_q2 withA:f_q3];
            
            break;
            
        case EulerAngle: // Euler
            [pktData getBytes:&yaw range:NSMakeRange(8,2)];
            [pktData getBytes:&pitch range:NSMakeRange(10,2)];
            [pktData getBytes:&roll range:NSMakeRange(12,2)];
            
            yaw = (int16_t)CFSwapInt16HostToLittle(yaw);
            pitch = (int16_t)CFSwapInt16HostToLittle(pitch);
            roll = (int16_t)CFSwapInt16HostToLittle(roll);
            
            float f_xrot = (float)yaw / 10.0;
            float f_yrot = (float)pitch / 10.0;
            float f_zrot = (float)roll / 10.0;
            
            
            NSLog(@"Euler data Yaw = %f, pitch = %f, Roll = %f", f_xrot,f_yrot,f_zrot);
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            
            _viewpoint1.scene.rootNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(f_yrot), GLKMathDegreesToRadians(f_xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(f_zrot));
            
            _viewpoint2.scene.rootNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(f_yrot), GLKMathDegreesToRadians(f_xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(f_zrot));
            
            [SCNTransaction commit];
            
            // update the labels
            _Pitch_lbl.text = [NSString stringWithFormat:@"%f",f_xrot];
            _Yaw_lbl.text = [NSString stringWithFormat:@"%f",f_yrot];
            _Roll_lbl.text = [NSString stringWithFormat:@"%f",f_zrot];;
            
            
            break;
            
        case ExtForce: // Ext Force
            [pktData getBytes:&fext_x range:NSMakeRange(8,2)];
            [pktData getBytes:&fext_y range:NSMakeRange(10,2)];
            [pktData getBytes:&fext_z range:NSMakeRange(12,2)];
            
            fext_x = (int16_t)CFSwapInt16HostToLittle(fext_x);
            fext_y = (int16_t)CFSwapInt16HostToLittle(fext_y);
            fext_z = (int16_t)CFSwapInt16HostToLittle(fext_z);
            
            NSLog(@"External Force vector x = %d, y = %d, z = %d", fext_x,fext_y,fext_z);
            
            int16_t f_fext_x = fext_x / 1600;
            int16_t f_fext_y = fext_y / 1600;
            int16_t f_fext_z = fext_z / 1600;
            
            cnt -= 1;
            if (cnt <= 0) {
                cnt = max_count;
                //if (xf != xq || yf != yq || zf != zq) {
                SCNVector3 pos = SCNVector3Make((float)f_fext_x/cnt, (float)f_fext_y/cnt, (float)f_fext_z/cnt);
                
                //let pos = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
                //SCNTransaction.flush()
                //SCNTransaction.begin()
                //SCNTransaction.setAnimationDuration(0.1)
                //let action = SCNAction.moveTo(pos, duration: 0.1)
                _viewpoint1.scene.rootNode.position = pos;
                _viewpoint2.scene.rootNode.position = pos;
                //SCNTransaction.commit()
                //ship.runAction(action)
                
                xf = f_fext_x;
                yf = f_fext_y;
                zf = f_fext_z;
                //}
            }
            else {
                //if (abs(xf) <= abs(xq)) {
                xf += f_fext_x;
                //}
                //if (abs(yf) <= abs(yq)) {
                yf += f_fext_y;
                //}
                //if (abs(xf) <= abs(xq)) {
                zf += f_fext_z;
                //}
                /*	if (xq == 0 && yq == 0 && zq == 0) {
                 //cnt = 1
                 xf = 0
                 yf = 0
                 zf = 0
                 //if (cnt <= 1) {
                 //ship.removeAllActions()
                 //	ship.position = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
                 //}
                 
                 }*/
            }
            
            
            // update the labels
            _GravityX_lbl.text = [NSString stringWithFormat:@"%d",f_fext_x];
            _GravityY_lbl.text = [NSString stringWithFormat:@"%d",f_fext_y];
            _GravityZ_lbl.text = [NSString stringWithFormat:@"%d",f_fext_z];
            break;
            
        default:
            break;
            
    }
}

- (void)updateQuatLabelswithX:(float)x withY:(float)y withZ:(float)z withA:(float)a
{
    // update the labels
    _QuaternionA_lbl.text = [NSString stringWithFormat:@"%f",x];
    _QuaternionB_lbl.text = [NSString stringWithFormat:@"%f",y];
    _QuaternionC_lbl.text = [NSString stringWithFormat:@"%f",z];
    _QuaternionD_lbl.text = [NSString stringWithFormat:@"%f",a];
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

-(void) updateLoggingBtnStatus
{
    if([dataSim1 isLoggingStopped])
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
        [dataSim1 start];
    }
    else if (button.tag == 2)
    {
        button.tag = 1;
        [button setTitle:@"Start Logging" forState:UIControlStateNormal];
        [dataSim1 pause];
    }

}
@end
