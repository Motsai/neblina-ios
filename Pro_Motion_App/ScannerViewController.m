//
//  ScannerViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "ScannerViewController.h"
#import "DebugConsoleViewController.h"
#import "ScannedPeripheral.h"
//#import "Utility.h"
#import "SWRevealViewController.h"
#import "Pro_Motion_App-Bridging-Header.h"
//#import "pro_motion_App-Swift.h"
#import "PeripheralTableViewCell.h"
#import "AdvTableViewCell.h"
#import "MBProgressHUD.h"
#import "PeripheralMetadata.h"
#import "ViewController.h"


@implementation ScannerViewController
{
    BOOL b_filter9axis,b_filterquaternion,b_filtereuler,b_filterexternal,b_filterheading,b_filtermagnetometer,b_filterpedometer,b_filtertrajectory,b_filtertrajdistance,b_filtermotion,b_filterrecord;
    
    DataSimulator* dm;
    NSIndexPath* lastIndexPath;
    
  
}

static int8_t flagData;

@synthesize devicesTable;
@synthesize filterUUID;
@synthesize peripherals;
@synthesize timer;
NSMutableArray *arForTable;


static CBCentralManager *bluetoothManager;
static ScannedPeripheral* lastConnectedperi;
static NSDictionary* lastadvData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.devicesTable.bounds;
    UIView* backView = [[UIView alloc] initWithFrame:self.devicesTable.bounds];
    //let backgroundView = UIView(frame: sender.tableView.bounds)
    [[backView layer] insertSublayer:bkLayer atIndex:0];
    self.devicesTable.backgroundView = backView;
    
    self.title = @"Select Device";
    ServiceUUIDString = @"0df9f021-1532-11e5-8960-0002a5d5c51b";
    
    
    self.devicesTable.layer.borderColor = [[UIColor blackColor] CGColor];
    self.devicesTable.layer.borderWidth = 1.0;
    
    SWRevealViewController *revealController = [self revealViewController];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    // Do any additional setup after loading the view.
    //peripherals = [NSMutableArray array];
    // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
    static dispatch_once_t oncePredicate;
    
    
    // 3
    dispatch_once(&oncePredicate, ^{
        dispatch_queue_t centralQueue = dispatch_queue_create("motsai.toolbox", DISPATCH_QUEUE_SERIAL);
        bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];

        
    });

    
    dm = [DataSimulator sharedInstance];
    dm.scanner = self;
    
    
    [self didloadedview];
    
    //[self readFilterSettings];
}

- (IBAction)doneClicked {
    // pop a view
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self saveFilterSettings];
   // [self scanForPeripherals:NO];
    [bluetoothManager stopScan];
   // [arForTable removeAllObjects];
  //[devicesTable reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getConnectedPeripherals];
    [self scanForPeripherals:YES];
    
    [self.devicesTable reloadData];
   // [self readFilterSettings];
    [self syncupbuttons];
    
}


-(void)backaction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didCancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)start_stop_Scanning_btn:(UIButton *)btn
{
    if (btn.tag == 1)
    {
        btn.tag = 2;
        [self.start_stop_scanning_lbl setTitle:@"Stop Scanning" forState:UIControlStateNormal];
        //[self getConnectedPeripherals];
        [self scanForPeripherals:YES];
     }
    else if (btn.tag == 2)
    {
        btn.tag = 1;
        [self.start_stop_scanning_lbl setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self scanForPeripherals:NO];
    }
}
- (void)getConnectedPeripherals
{
    NSLog(@"getConnectedPeripherals");
  
    CBUUID *dfuServiceUUID = [CBUUID UUIDWithString:ServiceUUIDString];

    NSArray *connectedPeripherals = [bluetoothManager retrieveConnectedPeripheralsWithServices:@[dfuServiceUUID]];
    NSLog(@"Connected Peripherals without filter: %lu",(unsigned long)connectedPeripherals.count);
    for (CBPeripheral *connectedPeripheral in connectedPeripherals)
    {
        NSLog(@"Connected Peripheral: %@",connectedPeripheral.name);
        [self addConnectedPeripheral:connectedPeripheral];
    }
   
}

- (void)addConnectedPeripheral:(CBPeripheral *)peripheral
{
    BOOL bConnected = FALSE;
     NSLog(@"Connected Peripheral: %@",peripheral.name);
     NSLog(@"Last Connected Peripheral: %@",lastConnectedperi.peripheral.name);
    
    if([peripheral.name isEqualToString:lastConnectedperi.peripheral.name])
        bConnected = TRUE;
        
    ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:0 isPeripheralConnected:bConnected];
    if(bConnected == TRUE)
    {
        
        UInt64 id;
        [lastadvData[CBAdvertisementDataManufacturerDataKey] getBytes:&id range:NSMakeRange(2, 8)];
        sensor.id = id;
        [sensor setDict:lastadvData];
    }
    [arForTable addObject:sensor];
    NSLog(@"addConnectedPeripheral ADDED connected peripheral : %@",peripheral.name);
}

#pragma mark Central Manager delegate methods
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        //TODO Retrieve already connected/paired devices
        self.start_stop_scanning_lbl.tag = 2;
        [self.start_stop_scanning_lbl setTitle:@"Stop Scanning" forState:UIControlStateNormal];

        [self getConnectedPeripherals];
        [self scanForPeripherals:YES];
    }
    else
    {
        self.start_stop_scanning_lbl.tag = 1;
        [self.start_stop_scanning_lbl setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self scanForPeripherals:NO];

        
//        //TODO Retrieve already connected/paired devices
//        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"Blutooth Alert" message: @"Blutooth is Turn Off or not supported" preferredStyle:UIAlertControllerStyleAlert];
//        
//        //Step 2: Create a UIAlertAction that can be added to the alert
//        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
//        {
//            //Do some thing here, eg dismiss the alertwindow
//            [myAlertController dismissViewControllerAnimated:YES completion:nil];
//        }];
//        
//        //Step 3: Add the UIAlertAction ok that we just created to our AlertController
//        [myAlertController addAction: ok];
//        
//        //Step 4: Present the alert to the user
//        [self presentViewController:myAlertController animated:YES completion:nil];
    }
}

/*!
 * @brief Starts scanning for peripherals with rscServiceUUID
 * @param enable If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
 * @return 0 if success, -1 if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
 */
- (int) scanForPeripherals:(BOOL)enable
{
    if (bluetoothManager.state != CBCentralManagerStatePoweredOn)
    {
        return -1;
    }
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enable)
        {
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            
             CBUUID *dfuServiceUUID = [CBUUID UUIDWithString:ServiceUUIDString];
            [bluetoothManager scanForPeripheralsWithServices:@[dfuServiceUUID] options:options];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        }
        else
        {
            [timer invalidate];
            timer = nil;
            
            [bluetoothManager stopScan];
        }
    });
    return 0;
}

/*!
 * @brief This method is called periodically by the timer. It refreshes the devices list. Updates from Central Manager comes to fast and it's hard to select a device if refreshed from there.
 * @param timer the timer that has called the method
 */
- (void)timerFireMethod:(NSTimer *)timer
{
    [self.devicesTable reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    //NSLog(@"scanned peripheral : %@",peripheral.name);
    
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        // Add the sensor to the list and reload deta set
//        if(RSSI < -90)
//        {
//            NSLog(@"Found weak RSSI signal");
//            return;
//        }
        
        ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue isPeripheralConnected:NO];
        
        UInt64 id;
        [advertisementData[CBAdvertisementDataManufacturerDataKey] getBytes:&id range:NSMakeRange(2, 8)];
        if(id == 0)
            return;
        sensor.id = id;
        
        if (![arForTable containsObject:sensor])
        {
            NSLog(@"didDiscoverPeripheral ADDED peripheral : %@",peripheral.name);

            [arForTable addObject:sensor];
            [self.devicesTable reloadData];
            //[self performSelector:@selector(reloadTable1) withObject:nil afterDelay:0];
           
        }
        else
        {
            sensor = [arForTable objectAtIndex:[arForTable indexOfObject:sensor]];
            sensor.RSSI = RSSI.intValue;
            
            [sensor setDict:advertisementData];
//            NSLog(@"Advertisement data: %@",advertisementData);
//            NSLog(@"Advertisement data - Local Name : %@",advertisementData[CBAdvertisementDataLocalNameKey]);
//            NSLog(@"Advertisement data - dataIsConnectable : %@",advertisementData[CBAdvertisementDataIsConnectable]);
//            NSLog(@"Advertisement data - Manufacturer : %@",advertisementData[CBAdvertisementDataManufacturerDataKey]);
//            NSLog(@"Advertisement data - Service Data : %@",advertisementData[CBAdvertisementDataServiceDataKey]);
//            NSLog(@"Advertisement data - Service UUID's : %@",advertisementData[CBAdvertisementDataServiceUUIDsKey]);
//            NSLog(@"Advertisement data - Solicited Service UUID's : %@",advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey]);
//            NSLog(@"Advertisement data - PowerLevelKey: %@",advertisementData[CBAdvertisementDataTxPowerLevelKey]);
            
            //[sensor setValuesForKeysWithDictionary:advertisementData];
            
        }
        
        
    });
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to Peripheral");

    if([arForTable count] > lastIndexPath.row)
    {
    ScannedPeripheral* peri = [arForTable objectAtIndex:lastIndexPath.row];
    peri.isConnected = YES;
    
     dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self reconfigureVisibleCells];
                       
                       sleep(1);
                      
                    
                   });
    }

   
    
}


- (void)reconfigureVisibleCells
{
    NSInteger sectionCount = [self.devicesTable numberOfSections];
    
    for (NSInteger section = 0; section < sectionCount; ++section) {
        NSInteger rowCount = [self.devicesTable numberOfRowsInSection:section];
        for (NSInteger row = 0; row < rowCount; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.devicesTable cellForRowAtIndexPath:indexPath];
            if (cell != nil) {
                [self configureCell:cell forRowAtIndexPath:indexPath];
            }
        }
    }
}

// Cell configuration code, shared by -tableView:cellForRowAtIndexPath: and reconfigureVisibleCells
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ...
    PeripheralTableViewCell* cell1 = (PeripheralTableViewCell*)cell;
    ScannedPeripheral* peri = [arForTable objectAtIndex:indexPath.row];
    NSLog(@"%@ - %lX",[peri valueForKey:@"name"],peri.id);
  
    
    
    if ( peri.isConnected == YES )
    {
        cell1.image.image = [UIImage imageNamed:@"Connected"];
        
        NSLog(@"cellForRowat: Peripheral is %@ YES",[peri valueForKey:@"name"]);
        
    }
    else
    {
        cell1.image.image = [self getRSSIImage:peri.RSSI];
        
        NSLog(@"cellForRowat: Peripheral is %@ NO",[peri valueForKey:@"name"]);
    }
}

- (void)reloadTable1 {
    
    //[_devicesTable reloadData];
    [self.devicesTable beginUpdates];
    [self.devicesTable reloadData];
    [self.devicesTable endUpdates];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral disconnected");
    if([arForTable count] > lastIndexPath.row)
    {
        ScannedPeripheral* peri = [arForTable objectAtIndex:lastIndexPath.row];
        peri.isConnected = NO;
        NSLog(@"%@", self.devicesTable);
        NSLog(@"%@", devicesTable);
        
        dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // the reload for some reason did not work, hence directly changing the image
                       
                       [self reconfigureVisibleCells];
                      // [self reloadTable1];
                    //[self performSelector:@selector(reloadTable1) withObject:nil afterDelay:0];
                    //  [_devicesTable reloadData];
                       
                   });
    }
}

-(void)didloadedview
{
    //NSDictionary *dTmp = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
  //  self.arrayOriginal = [dTmp valueForKey:@"Objects"];
    
    arForTable = [[NSMutableArray alloc] init];
    //self.arForTable = [dm getSensorsArray];
   // [self.arForTable addObjectsFromArray:self.arrayOriginal];
}

-(IBAction)showmore:(id)sender
{
    [bluetoothManager stopScan];
    
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.devicesTable indexPathForCell:clickedCell];
    NSUInteger count=indexPath.row+1;
    ScannedPeripheral* peri = [arForTable objectAtIndex:indexPath.row];
    PeripheralTableViewCell* cell = [self.devicesTable cellForRowAtIndexPath:indexPath];

    if(count < [arForTable count])
    {
       // If below is true, we need to collapse
        if([[arForTable objectAtIndex:count] isKindOfClass:[PeripheralMetadata class]])
        {
            NSMutableArray *arCells1=[NSMutableArray array];
            while((count < [arForTable count]) && [[arForTable objectAtIndex:count] isKindOfClass:[PeripheralMetadata class]])
            {
                [arCells1 addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [arForTable removeObjectAtIndex:count];
                [self.devicesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject: [NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                //count++;
            }
            
            [cell.showmore_btn setImage:[UIImage imageNamed:@"less.png"] forState:UIControlStateNormal];
            return;
            
        }
    }
    
    [cell.showmore_btn setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    NSDictionary *advDict= [peri getDict];
 
    NSArray *keys = [advDict allKeys];
    NSMutableArray *arCells=[NSMutableArray array];
    
    for (int i = 0; i < [keys count]; ++i) {
        
        id key = [keys objectAtIndex: i];
        NSString *keyName = (NSString *) key;
        NSObject *value = [advDict objectForKey: key];
        if ([value isKindOfClass: [NSArray class]]) {
            
            if ([keyName isEqualToString: @"kCBAdvDataServiceUUIDs"]  ){
                
                NSArray *values = (NSArray *) value;
                for (int j = 0; j < [values count]; ++j) {
                    if ([[values objectAtIndex: j] isKindOfClass: [CBUUID class]]) {
                        CBUUID *uuid = [values objectAtIndex: j];
                        
                        NSString *uuidString = [uuid UUIDString];
                        PeripheralMetadata* obj = [[PeripheralMetadata alloc] init];
                        obj.type = 1;
                        obj.keyname = [NSString stringWithFormat:@"%@",@"Service UUID"];
                        obj.keyvalue = [NSString stringWithFormat:@"%@",uuidString];
                        [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                        [arForTable insertObject:obj atIndex:count];
                        count++;
                        
                        NSLog(@"FOUND SERVICE UUID %@", uuidString);
                        
                        
                    } else {
                        const char *valueString = [[value description] cStringUsingEncoding: NSUTF8StringEncoding];
                        printf("      value(%d): %s\n", j, valueString);
                    }
                }
                
            }
        }
        else if([value isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* value1 = value;
            NSArray *keys1 = [value1 allKeys];
            for (int j = 0; j < [keys1 count]; ++j) {
                
                id key1 = [keys1 objectAtIndex: j];
                NSString *keyName_inner = (NSString *) key1;
                NSObject *value_inner = [value1 objectForKey: key1];
                
                PeripheralMetadata* obj = [[PeripheralMetadata alloc] init];
                obj.type = 1;
                obj.keyname = [NSString stringWithFormat:@"%@: %@",keyName,keyName_inner];
                obj.keyvalue = [NSString stringWithFormat:@"%@",value_inner];

                [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [arForTable insertObject:obj atIndex:count];
                count++;
                
                NSLog(@"FOUND SERVICE UUID %@ %@", obj.keyname,obj.keyvalue);
                
            }
            
            
            
        }
            else {
            
            PeripheralMetadata* obj = [[PeripheralMetadata alloc] init];
            obj.type = 1;
            obj.keyname = [NSString stringWithFormat:@"%@",keyName];
            obj.keyvalue = [NSString stringWithFormat:@"%@",value];
            [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
            [arForTable insertObject:obj atIndex:count];
            count++;
        }
    }
    [self.devicesTable insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationLeft];
    
}



#pragma mark Table View Data Source delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arForTable count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[arForTable objectAtIndex:indexPath.row] isKindOfClass:[PeripheralMetadata class]])
    {
        static NSString *CellIdentifier1 = @"advert_cell";
        AdvTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if(cell == nil)
        {
            cell = [[AdvTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        }
        PeripheralMetadata* perimeta = [arForTable objectAtIndex:indexPath.row];
        NSString* display = [NSString stringWithFormat:@"%@ : %@",perimeta.keyname,perimeta.keyvalue];
        cell.lblAdvert.text = display;
        return cell;
        
    }

    static NSString *CellIdentifier = @"peripheral_cell";
    PeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    

    if(cell == nil)
    {
        PeripheralTableViewCell *cell = [[PeripheralTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    cell.connect_btn.layer.borderColor = [[UIColor blackColor]CGColor];
    cell.connect_btn.layer.borderWidth = 2.0;
    cell.connect_btn.layer.cornerRadius = 10.0;
    cell.connect_btn.clipsToBounds = YES;
    cell.backgroundColor = [UIColor clearColor];
    
    
    ScannedPeripheral* peri = [arForTable objectAtIndex:indexPath.row];
    NSLog(@"%@ - %lX",[peri valueForKey:@"name"],peri.id);
    cell.devicename_lbl.text=[NSString stringWithFormat:@"%@ - %lX",[peri valueForKey:@"name"],peri.id];
    
    
    if ( peri.isConnected == YES )
    {
        cell.image.image = [UIImage imageNamed:@"Connected"];
        cell.connect_btn.titleLabel.text = @"Disconnect";
        NSLog(@"cellForRowat: Peripheral is %@ YES",[peri valueForKey:@"name"]);
    
    }
    else
    {
        cell.image.image = [self getRSSIImage:peri.RSSI];
        cell.connect_btn.titleLabel.text = @"Connect";
        NSLog(@"cellForRowat: Peripheral is %@ NO",[peri valueForKey:@"name"]);
    }

//    [cell setIndentationLevel:[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]];
//    
//    if ([[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 1 || [[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 2 || [[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 3)
//    {
//        cell.connect_btn.hidden = YES;
//    }
//    else
//    {
//        cell.connect_btn.hidden = NO;
//    }
//
//    if ([[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 3)
//    {
//        cell.showmore_btn.hidden = YES;
//    }
//    else
//    {
//        cell.showmore_btn.hidden = NO;
//    }
    return cell;
}


-(UIImage *) getRSSIImage:(int)rssi {
    // Update RSSI indicator
    UIImage* image;
    if (rssi < -90)
    {
        image = [UIImage imageNamed: @"Signal_0"];
    }
    else if (rssi < -70)
    {
        image = [UIImage imageNamed: @"Signal_1"];
    }
    else if (rssi < -50)
    {
        image = [UIImage imageNamed: @"Signal_2"];
    }
    else
    {
        image = [UIImage imageNamed: @"Signal_3"];
    }
    return image;
}

- (void) disConnectPeripheral:(ScannedPeripheral *)peri
{
   if (peri.isConnected)
   {
        [bluetoothManager cancelPeripheralConnection:dm.neblina_dev.device];
       [self displaySpinner:@"Disconnecting..." time:1];
        peri.isConnected = NO;
        lastConnectedperi = nil;
        lastadvData = nil;
       //[self.devicesTable reloadData];
//       dispatch_async(dispatch_get_main_queue(), ^{
//        [devicesTable reloadData];
//       });
   }
}
#pragma mark Table View delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [bluetoothManager stopScan];
    
    
    PeripheralTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Call delegate method
    //[self.delegate centralManager:bluetoothManager didPeripheralSelected:[[peripherals objectAtIndex:indexPath.row] peripheral]];
    //bleCentralManager.connectPeripheral(object.peripheral, options: nil)
    NSLog(@"Index path is %d",indexPath.row);
    ScannedPeripheral* peri = [arForTable objectAtIndex:indexPath.row];
    dm = [DataSimulator sharedInstance];
    
    if (peri.isConnected)
    {
        [self disConnectPeripheral:peri];
//        [bluetoothManager cancelPeripheralConnection:dm.neblina_dev.device];
//        [self displaySpinner:@"Disconnecting..." time:1];
//        peri.isConnected = NO;
//        lastConnectedperi = nil;
//        lastadvData = nil;
//        [devicesTable reloadData];
    }
    else
    {
        // Disconnect the last connected peripheral
        [self disConnectPeripheral:[arForTable objectAtIndex:lastIndexPath.row]];
        
        // connect to the new peripheral
        peri.isConnected = YES;
        [bluetoothManager connectPeripheral:[peri peripheral] options:nil];
        [self displaySpinner:@"Connecting to Peripheral..." time:1];
        
        [dm setNeblinaperipheral:[peri peripheral]];
        lastConnectedperi = peri;
        lastadvData = [peri getDict];


    }
    lastIndexPath = indexPath;
    
    if ( peri.isConnected == YES )
    {
        cell.image.image = [UIImage imageNamed:@"Connected"];
        //cell.connect_btn.titleLabel.text = @"Disconnect";
        //NSLog(@"cellForRowat: Peripheral is %@ YES",[peri valueForKey:@"name"]);
        
    }
    else
    {
        cell.image.image = [self getRSSIImage:peri.RSSI];
        //cell.connect_btn.titleLabel.text = @"Connect";
        //NSLog(@"cellForRowat: Peripheral is %@ NO",[peri valueForKey:@"name"]);
    }

    
}

// Tag = 1 means disabled
-(void)updateBtn:(UIButton*)sender withSpinner:(BOOL) bWithSpinner
{
    Neblina *neblina_obj = dm.neblina_dev;
    NSLog(@"%@",neblina_obj);
    if(!neblina_obj)
    {
        // we are not connected to any neblina, so show a message
        UIAlertView *loginalert = [[UIAlertView alloc] initWithTitle:@"Not connected to any Neblina!" message:@"Please connect to a neblina device and then use these settings." delegate:self
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loginalert show];
        
        return;
    }
    NSLog(@"Sender tag is %d",sender.tag);
    
    
    if([sender.titleLabel.text isEqualToString:@"Quaternion"])
    {
        (sender.tag ==1) ? (b_filterquaternion = true):(b_filterquaternion = false);
        [neblina_obj SendCmdQuaternionStream:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filterquaternion" value:b_filterquaternion];

    }
    else if ([sender.titleLabel.text isEqualToString:@"9 Axis IMU"])
    {
        (sender.tag ==1) ? (b_filter9axis = true):(b_filter9axis = false);
        
        [neblina_obj SendCmdSixAxisIMUStream:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filter9axis" value:b_filter9axis];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Euler Angles"])
    {
        (sender.tag ==1) ? (b_filtereuler = true):(b_filtereuler = false);
       
        [neblina_obj SendCmdEulerAngleStream:(sender.tag ==1)?FALSE:TRUE];
        [self saveFilterSetting:@"g_filtereuler" value:b_filtereuler];
    }
    else if ([sender.titleLabel.text isEqualToString:@"External Force"])
    {
        (sender.tag ==1) ? (b_filterexternal = true):(b_filterexternal = false);
       
        [neblina_obj SendCmdExternalForceStream:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filterexternal" value:b_filterexternal];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Pedometer"])
    {
        (sender.tag ==1) ? (b_filterpedometer = true):(b_filterpedometer = false);
        [neblina_obj SendCmdPedometerStream:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filterpedometer" value:b_filterpedometer];
        
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory"])
    {
        (sender.tag ==1) ? (b_filtertrajectory = true):(b_filtertrajectory = false);
       
        [neblina_obj SendCmdTrajectoryRecord:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filtertrajectory" value:b_filtertrajectory];
        
    }
    else if ([sender.titleLabel.text isEqualToString:@"Trajectory Distance"])
    {
        (sender.tag ==1) ? (b_filtertrajdistance = true):(b_filtertrajdistance = false);
        [neblina_obj SendCmdTrajectoryInfo:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filtertrajdistance" value:b_filtertrajdistance];
       
    }
    
    else if ([sender.titleLabel.text isEqualToString:@"Magnetometer"])
    {
        (sender.tag ==1) ? (b_filtermagnetometer = true):(b_filtermagnetometer = false);
        [neblina_obj SendCmdMagStream:(sender.tag ==1)?0:1];
         [self saveFilterSetting:@"g_filtermagnetometer" value:b_filtermagnetometer];
       
    }
    else if ([sender.titleLabel.text isEqualToString:@"Motion"])
    {
        (sender.tag ==1) ? (b_filtermotion = true):(b_filtermotion = false);
        [neblina_obj SendCmdMotionStream:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filtermotion" value:b_filtermotion];
        
    }
    else if ([sender.titleLabel.text isEqualToString:@"Record"])
    {
        (sender.tag ==1) ? (b_filterrecord = true):(b_filterrecord = false);
       
        [neblina_obj SendCmdFlashRecord:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filterrecord" value:b_filterrecord];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Heading"])
    {
        (sender.tag ==1) ? (b_filterheading = true):(b_filterheading = false);
        
        [neblina_obj SendCmdLockHeading:(sender.tag ==1)?0:1];
        [self saveFilterSetting:@"g_filterheading" value:b_filterheading];
        
    }
    
    if(sender.tag == 1)
    {
        sender.tag = 2;
        //[sender setBackgroundColor:[UIColor whiteColor]];
        [sender setBackgroundColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
        NSLog(@"%@",sender.titleLabel.text);
        
    }
    else{
        sender.tag = 1;
        //[sender setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:25.0/255.0 alpha:1]];
        
        [sender setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
    }
    if(bWithSpinner)
        [self displaySpinner:@"Sending packet to Neblina device..." time:1.0];
    
    
    
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
    hud.color = [UIColor colorWithRed:0.0/255.0 green:85.0/255.0 blue:141.0/255.0 alpha:1];
    [hud hide:YES afterDelay:ts];
    
    
}

-(IBAction)OptionSwitched:(UIButton*)sender
{
    [self updateBtn:sender withSpinner:true];
   // [self saveFilterSettings];
    
    
}


-(void) saveFilterSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:b_filter9axis forKey:@"g_filter9axis"];
    [defaults setBool:b_filtereuler forKey:@"g_filtereuler"];
    [defaults setBool:b_filterexternal forKey:@"g_filterexternal"];
    [defaults setBool:b_filtermagnetometer forKey:@"g_filtermagnetometer"];
    [defaults setBool:b_filtermotion forKey:@"g_filtermotion"];
    [defaults setBool:b_filterpedometer forKey:@"g_filterpedometer"];
    [defaults setBool:b_filterquaternion forKey:@"g_filterquaternion"];
    [defaults setBool:b_filterrecord forKey:@"g_filterrecord"];
    [defaults setBool:b_filtertrajdistance forKey:@"g_filtertrajdistance"];
    [defaults setBool:b_filtertrajectory forKey:@"g_filtertrajectory"];
    [defaults setBool:b_filterheading forKey:@"g_filterheading"];
    [defaults setBool:1 forKey:@"g_settingssaved"];
    
    [defaults synchronize];
    
}

-(void) saveFilterSetting:(NSString *)settingName value:(BOOL) bValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:bValue forKey:settingName];
    [defaults synchronize];
    
    // lets ask the status again
    [dm.neblina_dev SendCmdEngineStatus];
    
}

- (IBAction)refreshSettings:(id)sender {
    //[self readFilterSettings];
}


-(void)updateBtn:(UIButton*)sender withState:(BOOL) bEnable
{
    NSLog(@"Sender tag is %d",sender.tag);
    
    if(sender.tag == 1)
    {
        sender.tag = 2;
        [sender setBackgroundColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
        NSLog(@"%@",sender.titleLabel.text);
        
    }
    else{
        sender.tag = 1;
        //[sender setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:25.0/255.0 alpha:1]];
        
        [sender setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1]];
        [sender setTitleColor:[UIColor darkGrayColor] forState:normal];
        
    }
   
    
}

-(void) setBLEwithQueryStreamStatus
{
    
    // Query the stream status
    [dm.neblina_dev SendCmdControlInterface:0];
    [dm.neblina_dev SendCmdEngineStatus];
    
}


- (void)didReceiveDebugData:(int32_t)type data:(const uint8_t *)data errFlag:(BOOL)errFlag
{
    
//    //all fusion engine commands
//#define Downsample 				0x01
//#define MotionState 			0x02
//#define IMU_Data 				0x03
//#define Quaternion 				0x04
//#define EulerAngle 				0x05
//#define ExtForce 				0x06
//#define SetFusionType 			0x07
//#define TrajectoryRecStartStop 	0x08
//    //#define TrajectoryRecStop 0x09
//#define TrajectoryInfo 			0x09
//#define Pedometer 				0x0A
//#define MAG_Data 				0x0B
//#define SittingStanding			0x0C
//#define LockHeadingRef			0x0D
//#define SetAccRange				0x0E
//#define DisableAllStreaming		0x0F
//#define ResetTimeStamp 			0x10
//    ///////////////////////////////////////////////
//    

    
    flagData = data[4];
    [self syncupbuttons];
    
    
    
    
    
    
    
}

-(void) syncupbuttons
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int8_t n_streamImu = (flagData & 16) >> 4;
        NSLog(@"Imu Stream is %d",n_streamImu);
        (n_streamImu == 1)?(_btn_9_Axis.tag = 2) : (_btn_9_Axis.tag = 1);
        [self updateBtn:_btn_9_Axis withState:n_streamImu];
        
        int8_t n_streamQuat = (flagData & 8) >> 3;
        NSLog(@"Quat Stream is %d",n_streamQuat);
        (n_streamQuat == 1)?(_btn_Quaternion.tag = 2) : (_btn_Quaternion.tag = 1);
        [self updateBtn:_btn_Quaternion withState:n_streamQuat];
        
        
        
        int8_t n_streamEuler = (flagData & 4) >> 2;
        NSLog(@"Euler Stream is %d",n_streamEuler);
        (n_streamEuler == 1)?(_btn_EulerAngles.tag = 2) : (_btn_EulerAngles.tag = 1);
        [self updateBtn:_btn_EulerAngles withState:n_streamEuler];
        
        
        int8_t n_streamExtforce = (flagData & 2) >> 1;
        NSLog(@"ExtForce Stream is %d",n_streamExtforce);
        (n_streamExtforce == 1)?(_btn_external_force.tag = 2) : (_btn_external_force.tag = 1);
        [self updateBtn:_btn_external_force withState:n_streamExtforce];
        
        int8_t n_streamMagData = (flagData & 128) >> 7;
        NSLog(@"MagData stream is %d",n_streamMagData);
        (n_streamMagData == 1)?(_btn_Magnetometer.tag = 2) : (_btn_Magnetometer.tag = 1);
        [self updateBtn:_btn_Magnetometer withState:n_streamMagData];
        
        
        int8_t n_streamMotion = (flagData & 32) >> 5;
        NSLog(@"Motion Stream is %d",n_streamMotion);
        (n_streamMotion == 1)?(_btn_Motion.tag = 2) : (_btn_Motion.tag = 1);
        [self updateBtn:_btn_Motion withState:n_streamMotion];
        
        
        
        int8_t n_streamPedometer = (flagData & 64) >> 6;
        NSLog(@"Pedometer stream is %d",n_streamPedometer);
        (n_streamPedometer == 1)?(_btn_Pedometer.tag = 2) : (_btn_Pedometer.tag = 1);
        [self updateBtn:_btn_Pedometer withState:n_streamPedometer];
        
        //    i =[dm.neblina_dev getCmdIdx:NEB_CTRL_SUBSYS_MOTION_ENG cmdId:ExtForce];
        //    int n_streamExtforce = (flagData & 8) >> 1;
        //    NSLog(@"Imu ExtForce is %d",n_streamExtforce);
        _btn_Record.tag = 1;
        [self updateBtn:_btn_Record withState:0];
        
        
        
        int8_t n_streamTrajDistance = (flagData & 1);
        NSLog(@"Traj Distance stream is %d",n_streamTrajDistance);
        (n_streamTrajDistance == 1)?(_btn_Traj_distance.tag = 2) : (_btn_Traj_distance.tag = 1);
        (n_streamTrajDistance == 1)?(_btn_Trajectory.tag = 2) : (_btn_Trajectory.tag = 1);
        [self updateBtn:_btn_Traj_distance withState:n_streamTrajDistance];
        [self updateBtn:_btn_Trajectory withState:n_streamTrajDistance];
        
        
        
        //    i =[dm.neblina_dev getCmdIdx:NEB_CTRL_SUBSYS_MOTION_ENG cmdId:ExtForce];
        //    int n_streamExtforce = (flagData & 8) >> 1;
        //    NSLog(@"Imu ExtForce is %d",n_streamExtforce);
        _btn_Heading.tag = 1;
        [self updateBtn:_btn_Heading withState:0];
    });
    

}

-(void) readFilterSettings
{
    if(!dm.neblina_dev)
        return;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL bWithSpinner = false;
    
    NSNumber *n_filter9axis = [defaults objectForKey:@"g_filter9axis"];
    if(([n_filter9axis intValue] == 1) || (n_filter9axis == nil))
    {
        _btn_9_Axis.tag = 1;
    }else
    {
        _btn_9_Axis.tag = 2;
    }
    
    [self updateBtn:_btn_9_Axis withState:(([n_filter9axis intValue] == 1) || (n_filter9axis == nil))? 0:1];
    

    
    NSNumber *n_filtereuler = [defaults objectForKey:@"g_filtereuler"];
    if(([n_filtereuler intValue] == 1) || (n_filtereuler == nil))
    {
        _btn_EulerAngles.tag = 1;
    }
    else
    {
        _btn_EulerAngles.tag = 2;
    }
    [self updateBtn:_btn_EulerAngles withState:(([n_filtereuler intValue] == 1) || (n_filtereuler == nil))?0:1];
    
    
    NSNumber *n_filterexternal = [defaults objectForKey:@"g_filterexternal"];
    if(([n_filterexternal intValue] == 1) || (n_filterexternal == nil))
    {
        _btn_external_force.tag = 1;
    }
    else
    {
        _btn_external_force.tag = 2;
    }
    [self updateBtn:_btn_external_force withState:(([n_filterexternal intValue] == 1) || (n_filterexternal == nil))?0:1];
    
    
    NSNumber *n_filtermagnetometer = [defaults objectForKey:@"g_filtermagnetometer"];
    if(([n_filtermagnetometer intValue] == 1) || (n_filtermagnetometer == nil))
    {
        _btn_Magnetometer.tag = 1;
    }
    else
    {
        _btn_Magnetometer.tag = 2;

    }
    [self updateBtn:_btn_Magnetometer withState:(([n_filtermagnetometer intValue] == 1) || (n_filtermagnetometer == nil))?0:1];
    
    
    NSNumber *n_filtermotion = [defaults objectForKey:@"g_filtermotion"];
    if(([n_filtermotion intValue] == 1) || (n_filtermotion == nil))
    {
        _btn_Motion.tag = 1;
    }
    else
    {
        _btn_Motion.tag = 2;
    }
    [self updateBtn:_btn_Motion withState:(([n_filtermotion intValue] == 1) || (n_filtermotion == nil))?0:1];
  
    
    NSNumber *n_filterpedometer = [defaults objectForKey:@"g_filterpedometer"];
    if(([n_filterpedometer intValue] == 1) || (n_filterpedometer == nil))
    {
        _btn_Pedometer.tag = 1;
    }
    else
    {
        _btn_Pedometer.tag = 2;
    }
    [self updateBtn:_btn_Pedometer withState:(([n_filterpedometer intValue] == 1) || (n_filterpedometer == nil))?0:1];
    
    NSNumber *n_filterquaternion = [defaults objectForKey:@"g_filterquaternion"];
    if(([n_filterquaternion intValue] == 1) || (n_filterquaternion == nil))
    {
        _btn_Quaternion.tag = 1;
    }
    else
    {
        _btn_Quaternion.tag = 2;
    }
    [self updateBtn:_btn_Quaternion withState:(([n_filterquaternion intValue] == 1) || (n_filterquaternion == nil))?0:1];
    
    
    NSNumber *n_filterrecord = [defaults objectForKey:@"g_filterrecord"];
    if(([n_filterrecord intValue] == 1) || (n_filterrecord == nil))
    {
        _btn_Record.tag = 1;
    }
    else
    {
        _btn_Record.tag = 2;
       
    }
    [self updateBtn:_btn_Record withState:(([n_filterrecord intValue] == 1) || (n_filterrecord == nil))?0:1];
    
    NSNumber *n_filtertrajdistance = [defaults objectForKey:@"g_filtertrajdistance"];
    if(([n_filtertrajdistance intValue] == 1) || (n_filtertrajdistance == nil))
    {
        _btn_Traj_distance.tag = 1;
       
    }
    else
    {
        _btn_Traj_distance.tag = 2;
    }
    [self updateBtn:_btn_Traj_distance withState:(([n_filtertrajdistance intValue] == 1) || (n_filtertrajdistance == nil))?0:1];
    
    NSNumber *n_filtertrajectory = [defaults objectForKey:@"g_filtertrajectory"];
    if(([n_filtertrajectory intValue] == 1) || (n_filtertrajectory == nil))
    {
        _btn_Trajectory.tag = 1;
        
    }
    else
    {
       _btn_Trajectory.tag = 2;
    }
    [self updateBtn:_btn_Trajectory withState:(([n_filtertrajectory intValue] == 1) || (n_filtertrajectory == nil))?0:1];
    
    
    NSNumber *n_filterheading = [defaults objectForKey:@"g_filterheading"];
    if(([n_filterheading intValue] == 1) || (n_filterheading == nil))
    {
        _btn_Heading.tag = 1;
        
    }
    else
    {
        _btn_Heading.tag = 2;
    }
    [self updateBtn:_btn_Heading withState:(([n_filterheading intValue] == 1) || (n_filterheading == nil))?0:1];
    
}



@end
