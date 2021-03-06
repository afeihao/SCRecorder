//
//  SCCIImageView.m
//  SCRecorder
//
//  Created by Simon CORSIN on 14/05/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import "SCImageView.h"
#import "CIImageRendererUtils.h"
#import "SCSampleBufferHolder.h"
#import "SCContext.h"

@interface SCImageView() {
    CIContext *_CIContext;
    SCSampleBufferHolder *_sampleBufferHolder;
}

@end

@implementation SCImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.preferredCIImageTransform = CGAffineTransformIdentity;
    
    SCContext *context = [SCContext new];
    _CIContext = context.CIContext;
    self.context = context.EAGLContext;
    
    _sampleBufferHolder = [SCSampleBufferHolder new];
}

- (void)drawRect:(CGRect)rect {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CIImage *newImage = [CIImageRendererUtils generateImageFromSampleBufferHolder:_sampleBufferHolder];
    
    if (newImage != nil) {
        _CIImage = newImage;
    }
    
    CIImage *image = _CIImage;
    if (image != nil) {
        image = [image imageByApplyingTransform:self.preferredCIImageTransform];
        
        CGRect extent = [image extent];
        
        if (_filter != nil) {
            image = [_filter imageByProcessingImage:image atTime:_CIImageTime];
        }
        
        CGRect outputRect = [CIImageRendererUtils processRect:rect withImageSize:extent.size contentScale:self.contentScaleFactor contentMode:self.contentMode];
        
        [_CIContext drawImage:image inRect:outputRect fromRect:extent];
    }
}

- (void)setImageBySampleBuffer:(CMSampleBufferRef)sampleBuffer {
    _sampleBufferHolder.sampleBuffer = sampleBuffer;
    [self setNeedsDisplay];
}

- (void)setImageByUIImage:(UIImage *)image {
    [CIImageRendererUtils putUIImage:image toRenderer:self];
}

- (void)setCIImage:(CIImage *)CIImage {
    _CIImage = CIImage;
    
    [self setNeedsDisplay];
}

- (void)setFilter:(SCFilter *)filter {
    _filter = filter;
    
    [self setNeedsDisplay];
}

@end
