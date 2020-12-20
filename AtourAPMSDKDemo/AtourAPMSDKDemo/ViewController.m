//
//  ViewController.m
//  AtourAPMSDKDemo
//
//  Created by sue on 2020/12/8.
//

#import "ViewController.h"
#import <AtourAPMSDK/AAFPSMonitor.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,AAFPSMonitorDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

-(void)didUpdateFPS:(float)fps timestamp:(NSString *)timestamp {
    self.navigationItem.title = [NSString stringWithFormat:@"%0.1f--%@",fps,timestamp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AtourAPMDemo";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
    [[AAFPSMonitor sharedInstance] addDelegate:self];
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row+1];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            sleep(1);
        }
            break;
            
        default:
            break;
    }
}
@end
