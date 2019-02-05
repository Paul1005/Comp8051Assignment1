//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>

@interface Renderer : NSObject

- (void)setup:(GLKView *)view;
- (void)loadModels;
- (void)update;
- (void)draw:(CGRect)drawRect;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)onClick:(id)sender;
@end

#endif /* Renderer_h */
