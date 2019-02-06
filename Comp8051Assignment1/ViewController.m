//
//  ViewController.m
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "ViewController.h"
#import "Class1.h"

@interface ViewController() {
    Renderer *glesRenderer; // ###
    UILabel *label;
    UILabel *label2;
    Class1 *class1;
}
@end


@implementation ViewController

- (IBAction)theButton:(id)sender {
    NSLog(@"You pressed the Button!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // ### <<<
    glesRenderer = [[Renderer alloc] init];
    GLKView *view = (GLKView *)self.view;
    [glesRenderer setup:view];
    [glesRenderer loadModels];
    // ### >>>
    
    [super viewDidLoad];
    
    //Initialise GLKView. Set Context, depth format etc.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 10);
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchDown];
    [button setEnabled:YES];
    [self.view addSubview:button];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 1000)];
    //label.text = @"test";
    label.textColor = UIColor.whiteColor;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(200, 100, 100, 10);
    [button2 setTitle:@"Button2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(onClick2:) forControlEvents:UIControlEventTouchDown];
    [button2 setEnabled:YES];
    [self.view addSubview:button2];
    
    label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 1000)];
    label2.textColor = UIColor.whiteColor;
    [self.view addSubview:label];
}

-(void)onClick:(id)sender
{
    //Do onClick stuff here
    [glesRenderer onClick:sender];
    [self resignFirstResponder];
}

-(void)onClick2:(id)sender
{
    label2.text = [NSString stringWithFormat:@"%d",[class1 getInteger]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    label.text = [NSString stringWithFormat:@"%s%f%s%f%s%f%s%f%s%f%s%f",
                  "X rotation: " ,[glesRenderer getRotAngleX],
                  "\nY rotation: ", [glesRenderer getRotAngleY],
                  "\nZ rotation: ",[glesRenderer getRotAngleZ],
                  "\nX position: ", [glesRenderer getTranslationX],
                  "\nY position: ",[glesRenderer getTranslationY],
                  "\nZ position: ",[glesRenderer getTranslationZ]];
    [glesRenderer update]; // ###
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [glesRenderer draw:rect]; // ###
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [glesRenderer touchesMoved:touches withEvent:event]; // ###
}

@end
