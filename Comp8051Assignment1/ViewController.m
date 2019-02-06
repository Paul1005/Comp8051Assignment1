//
//  ViewController.m
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController() {
    Renderer *glesRenderer; // ###
    UILabel *label;
    bool isCPP;
}
@end


@implementation ViewController

@synthesize theLabel;

- (IBAction)theButton:(id)sender {
    NSLog(@"You pressed the Button!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // ### <<<
    [theLabel setText:@"Initialized"];
    theObject = [[MixTest alloc] init];
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
    
    isCPP = false;
    label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 1000)];
    label.textColor = UIColor.whiteColor;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(200, 100, 100, 10);
    [button2 setTitle:@"Button2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(onClick2:) forControlEvents:UIControlEventTouchDown];
    [button2 setEnabled:YES];
    [self.view addSubview:button2];
    
    theLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    theLabel.textColor = UIColor.whiteColor;
    [theLabel setText:[NSString stringWithFormat:@"Obj C value: %d", [theObject val]]];
    [self.view addSubview:theLabel];
}

-(void)onClick:(id)sender
{
    //Do onClick stuff here
    [glesRenderer onClick:sender];
    [self resignFirstResponder];
}

- (IBAction)onClick2:(id)sender
{
    isCPP = !isCPP;
    if(!isCPP){
        [theObject setUseObjC:YES];
        [theObject IncrementValue];
        [theLabel setText:[NSString stringWithFormat:@"Obj C value: %d", [theObject val]]];
    } else if(isCPP){
        [theObject setUseObjC:NO];
        [theObject IncrementValue];
        [theLabel setText:[NSString stringWithFormat:@"C++ value: %d", [theObject val]]];
    }
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
