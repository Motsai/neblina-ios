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
#import "pro_motion_App-Swift.h"
#import "PeripheralTableViewCell.h"

@implementation ScannerViewController
@synthesize bluetoothManager;
@synthesize devicesTable;
@synthesize filterUUID;
@synthesize peripherals;
@synthesize timer;

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
    
    self.title = @"Select Device";
    ServiceUUIDString = @"0df9f021-1532-11e5-8960-0002a5d5c51b";
    
    devicesTable.layer.borderColor = [[UIColor blackColor] CGColor];
    devicesTable.layer.borderWidth = 1.0;
    
    SWRevealViewController *revealController = [self revealViewController];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    // We want the scanner to scan with dupliate keys (to refresh RRSI every second) so it has to be done using non-main queue
    dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
    
    // Do any additional setup after loading the view.
    //peripherals = [NSMutableArray arrayWithArray:@[@"BLE Device 1", @"BLE Device 2", @"BLE Device 3",]];
    
    [self didloadedview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self scanForPeripherals:NO];
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
        [self getConnectedPeripherals];
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
    if (filterUUID != nil)
    {
        NSLog(@"Retrieving Connected Peripherals ...");
        NSArray *connectedPeripherals = [bluetoothManager retrieveConnectedPeripheralsWithServices:@[filterUUID]];
        NSLog(@"Connected Peripherals with filter: %lu",(unsigned long)connectedPeripherals.count);
        for (CBPeripheral *connectedPeripheral in connectedPeripherals)
        {
            NSLog(@"Connected Peripheral: %@",connectedPeripheral.name);
            [self addConnectedPeripheral:connectedPeripheral];
        }
    }
    else
    {
        CBUUID *dfuServiceUUID = [CBUUID UUIDWithString:ServiceUUIDString];
//        CBUUID *ancsServiceUUID = [CBUUID UUIDWithString:ANCSServiceUUIDString];
//        NSArray *connectedPeripherals = [bluetoothManager retrieveConnectedPeripheralsWithServices:@[dfuServiceUUID, ancsServiceUUID]];
        NSArray *connectedPeripherals = [bluetoothManager retrieveConnectedPeripheralsWithServices:@[dfuServiceUUID]];
        NSLog(@"Connected Peripherals without filter: %lu",(unsigned long)connectedPeripherals.count);
        for (CBPeripheral *connectedPeripheral in connectedPeripherals)
        {
            NSLog(@"Connected Peripheral: %@",connectedPeripheral.name);
            [self addConnectedPeripheral:connectedPeripheral];
        }
    }
}

- (void)addConnectedPeripheral:(CBPeripheral *)peripheral
{
    ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:0 isPeripheralConnected:YES];
    [peripherals addObject:sensor];
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
            if (filterUUID != nil)
            {
                [bluetoothManager scanForPeripheralsWithServices:@[ filterUUID ] options:options];
            }
            else
            {
                [bluetoothManager scanForPeripheralsWithServices:nil options:options];
            }
            
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
    [devicesTable reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
   // NSLog(@"scanned peripheral : %@",peripheral.name);
       
    dispatch_async(dispatch_get_main_queue(),
    ^{
        // Add the sensor to the list and reload deta set
        ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue isPeripheralConnected:NO];
        if (![peripherals containsObject:sensor])
        {
            [peripherals addObject:sensor];
        }
        else
        {
            sensor = [peripherals objectAtIndex:[peripherals indexOfObject:sensor]];
            sensor.RSSI = RSSI.intValue;
        }
    });
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

-(void)didloadedview
{
    NSDictionary *dTmp = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    self.arrayOriginal = [dTmp valueForKey:@"Objects"];
    
    self.arForTable = [[NSMutableArray alloc] init];
    [self.arForTable addObjectsFromArray:self.arrayOriginal];
}

-(IBAction)showmore:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [devicesTable indexPathForCell:clickedCell];

    NSDictionary *d=[self.arForTable objectAtIndex:indexPath.row];
    if([d valueForKey:@"Objects"])
    {
        NSArray *ar=[d valueForKey:@"Objects"];
        
        BOOL isAlreadyInserted=NO;
        
        for(NSDictionary *dInner in ar )
        {
            NSInteger index=[self.arForTable indexOfObjectIdenticalTo:dInner];
            isAlreadyInserted=(index>0 && index!=NSIntegerMax);
            if(isAlreadyInserted) break;
        }
        
        if(isAlreadyInserted)
        {
            [self miniMizeThisRows:ar];
        }
        else
        {
            NSUInteger count=indexPath.row+1;
            NSMutableArray *arCells=[NSMutableArray array];
            for(NSDictionary *dInner in ar )
            {
                [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [self.arForTable insertObject:dInner atIndex:count++];
            }
            [devicesTable insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}
#pragma mark Table View Data Source delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arForTable count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"peripheral_cell";
    PeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil)
    {
        cell = [[PeripheralTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.connect_btn.layer.borderColor = [[UIColor blackColor]CGColor];
    cell.connect_btn.layer.borderWidth = 2.0;
    cell.connect_btn.layer.cornerRadius = 10.0;
    cell.connect_btn.clipsToBounds = YES;
   
    cell.devicename_lbl.text=[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"name"];
    [cell setIndentationLevel:[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]];
    
    if ([[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 1 || [[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 2 || [[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 3)
    {
        cell.connect_btn.hidden = YES;
    }
    else
    {
        cell.connect_btn.hidden = NO;
    }

    if ([[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 3)
    {
        cell.showmore_btn.hidden = YES;
    }
    else
    {
        cell.showmore_btn.hidden = NO;
    }
    return cell;
}

#pragma mark Table View delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   /* [bluetoothManager stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Call delegate method
    [self.delegate centralManager:bluetoothManager didPeripheralSelected:[[peripherals objectAtIndex:indexPath.row] peripheral]];
    
    Neblina *neblina_obj = [[Neblina alloc]init];
    [neblina_obj setPeripheral:[[peripherals objectAtIndex:indexPath.row] peripheral]];
    */
}
-(void)miniMizeThisRows:(NSArray*)ar
{
    for(NSDictionary *dInner in ar )
    {
        NSUInteger indexToRemove=[self.arForTable indexOfObjectIdenticalTo:dInner];
        NSArray *arInner=[dInner valueForKey:@"Objects"];
        if(arInner && [arInner count]>0)
        {
            [self miniMizeThisRows:arInner];
        }
        
        if([self.arForTable indexOfObjectIdenticalTo:dInner]!=NSNotFound)
        {
            [self.arForTable removeObjectIdenticalTo:dInner];
            [devicesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject: [NSIndexPath indexPathForRow:indexToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}

@end
