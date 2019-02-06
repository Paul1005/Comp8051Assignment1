//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "Renderer.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASSTHROUGH,
    UNIFORM_SHADEINFRAG,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface Renderer () {
    GLKView *theView;
    GLESRenderer glesRenderer;
    GLuint programObject;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;

    GLKMatrix4 mvp;
    GLKMatrix3 normalMatrix;
    GLKMatrix4 originalmvp;
    float rotAngleX;
    float rotAngleY;
    float rotAngleZ;
    float scale;
    float translationX;
    float translationY;
    float translationZ;
    bool isRotating;

    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
    
    GLKView * currentView;
}

@end

@implementation Renderer

- (void)dealloc
{
    glDeleteProgram(programObject);
}

- (void)loadModels
{
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices);
}

- (void)setup:(GLKView *)view
{
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!view.context) {
        NSLog(@"Failed to create ES context");
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    theView = view;
    [EAGLContext setCurrentContext:view.context];
    if (![self setupShaders])
        return;
    rotAngleX = 0.0f;
    rotAngleY = 0.0f;
    isRotating = 1;
    scale = 1;
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    glEnable(GL_DEPTH_TEST);
    lastTime = std::chrono::steady_clock::now();
    
    UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTapRecognizer];
    
    UIPinchGestureRecognizer * pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
    [view addGestureRecognizer:pinchRecognizer];
    
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
        action:@selector(twoFingerPan:)];
    panRecognizer.minimumNumberOfTouches = 2;
    panRecognizer.maximumNumberOfTouches = 2;
    [view addGestureRecognizer:panRecognizer];
    
    currentView = view;
}

- (float)getRotAngleX
{
    return rotAngleX;
}

- (float)getRotAngleY
{
    return rotAngleY;
}

- (float)getRotAngleZ
{
    return rotAngleZ;
}

- (float)getTranslationX
{
    return translationX;
}

- (float)getTranslationY
{
    return translationY;
}

- (float)getTranslationZ
{
    return translationZ;
}

-(void)onClick:(id)sender{
    rotAngleX = 0.0f;
    rotAngleY = 0.0f;
    scale = 1;
    translationX = 0;
    translationY = 0;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    isRotating = !isRotating;
}

- (void)pinchZoom:(UIPinchGestureRecognizer *)pinch {
    if(!isRotating){
        scale = pinch.scale;
    }
}

- (void)twoFingerPan:(UIPanGestureRecognizer *)pan {
    if(!isRotating){
        CGPoint touchLocation = [pan locationInView:currentView];
        translationX = touchLocation.x;
        translationY = touchLocation.y;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!isRotating){
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:currentView];
        CGPoint lastLoc = [touch previousLocationInView:currentView];
        CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
        
        rotAngleX = -1 * GLKMathDegreesToRadians(diff.y / 2.0)*10;
        rotAngleY = -1 * GLKMathDegreesToRadians(diff.x / 2.0)*10;
        }
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto elapsedTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    
    if (isRotating)
    {
        rotAngleY += 0.001f * elapsedTime;
        if (rotAngleY >= 2 * M_PI)
            rotAngleY = 0.0f;
    }

    // Perspective
    mvp = GLKMatrix4Translate(GLKMatrix4Identity, translationX*0.005, translationY*-0.005, -5.0);
    bool isInvertible;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(mvp, &isInvertible),
                                                 GLKVector3Make(1, 0, 0));
    mvp = GLKMatrix4Rotate(mvp, rotAngleX, xAxis.x, xAxis.y, xAxis.z );
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(mvp, &isInvertible),
                                                 GLKVector3Make(0, 1, 0));
    mvp = GLKMatrix4Rotate(mvp, rotAngleY, yAxis.x, yAxis.y, yAxis.z );
    mvp = GLKMatrix4Scale(mvp, scale, scale, scale );
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvp), NULL);

    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    GLKMatrix4 perspective = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspect, 1.0f, 20.0f);

    mvp = GLKMatrix4Multiply(perspective, mvp);
}

- (void)draw:(CGRect)drawRect;
{
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);

    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glUseProgram ( programObject );

    glVertexAttribPointer ( 0, 3, GL_FLOAT,
                           GL_FALSE, 3 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray ( 0 );
    glVertexAttrib4f ( 1, 1.0f, 0.0f, 0.0f, 1.0f );
    glVertexAttribPointer ( 2, 3, GL_FLOAT,
                           GL_FALSE, 3 * sizeof ( GLfloat ), normals );
    glEnableVertexAttribArray ( 2 );
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
}


- (bool)setupShaders
{
    // Load shaders
    char *vShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    char *fShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
    programObject = glesRenderer.LoadProgram(vShaderStr, fShaderStr);
    if (programObject == 0)
        return false;
    
    // Set up uniform variables
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");

    return true;
}

@end

