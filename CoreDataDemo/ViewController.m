//
//  ViewController.m
//  CoreDataDemo
//
//  Created by ZJQ on 2017/2/7.
//  Copyright © 2017年 ZJQ. All rights reserved.
//

#import "ViewController.h"
#import "Person+CoreDataClass.h"
#import "AppDelegate.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AppDelegate *appdelegate;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (NSMutableArray *)dataArray {

    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    
    self.appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age = 21", ];
    //    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.appdelegate.persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"数据查询错误%@",error);
    }else{
        //将查询到的数据添加到数据源中
        [self.dataArray addObjectsFromArray:fetchedObjects];
    }
    
}

- (IBAction)addDataClicked:(id)sender {
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    Person *person = [[Person alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    
    person.name = [NSString stringWithFormat:@"JACK%d",arc4random()%100];
    person.age = arc4random()%60+1;
    person.sex = arc4random()%2==0?@"man":@"woman";
    
    [self.dataArray insertObject:person atIndex:0];
    
    [self.appdelegate saveContext];
    
    [self.tableView reloadData];
}

- (IBAction)searchDataClicked:(id)sender {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.appdelegate.persistentContainer.viewContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //谓词搜索
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age = 21", ];
    //    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //排序方法（这里为按照年龄升序排列）
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.appdelegate.persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"数据查询错误%@",error);
    }else{
        
        //查询到之后要你的操作代码
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:fetchedObjects];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    Person *person = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"name:%@,age:%lld",person.name,person.age];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"sex:%@",person.sex];
    return cell;
}
//滑动后红色删除按钮上显示的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除情况下
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Person *person = self.dataArray[indexPath.row];
        [self.dataArray removeObject:person];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //删除CoreData中的数据
        [self.appdelegate.persistentContainer.viewContext deleteObject:person];
        
        //持久化一下
        [self.appdelegate saveContext];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
