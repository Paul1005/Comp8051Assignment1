//
//  Class1.m
//  Comp8051Assignment1
//
//  Created by Paul on 2019-02-05.
//  Copyright © 2019 Paul. All rights reserved.
//

#import "Class1.h"

@interface Class1 () {
    int integer;
}
@end

@implementation Class1

-(void)initializeInteger
{
    integer = 0;
}

- (int)getInteger
{
    integer++;
    return integer;
}

@end

