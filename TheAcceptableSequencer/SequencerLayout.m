//
//  SequencerLayout.m
//  SequencerExperiment
//
//  Created by Alejandro Santander on 7/21/15.
//  Copyright (c) 2015 Humane Engineering. All rights reserved.
//

#import "SequencerLayout.h"

@implementation SequencerLayout {
    NSDictionary *_layoutInfo;
    CGSize _collectionViewSize;
    CGSize _contentSize;
    CGSize _cellSize;
    int _numPulses;
    int _numKeys;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithNumberOfKeys:(int)keys numberOfPulses:(int)pulses collectionViewSize:(CGSize)size {
    self = [super init];
    if(self) {
        _collectionViewSize = size;
        _numPulses = pulses;
        _numKeys = keys;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
//    NSLog(@"SequencerLayout - initialize()");
 
    // Pre-calculate layout.
    // Associates CGRect frames to indexPath's.
    [self collectionViewContentSize]; // Calculates content and cell sizes.
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    int numSections = _numKeys;
//    NSLog(@"  numSections: %d", numSections);
    for(int sectionIndex = 0; sectionIndex < numSections; sectionIndex++) { // Sweep sections.
        
        int numItems = _numPulses;
//        NSLog(@"  numItems: %d", numItems);
        for(int itemIndex = 0; itemIndex < numItems; itemIndex++) { // Sweep items.
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat x = itemIndex * _cellSize.width;
            CGFloat y = _contentSize.height - (sectionIndex + 1) * _cellSize.height;
            CGFloat w = _cellSize.width;
            CGFloat h = _cellSize.height;
//            NSLog(@"  frame %d, %d: [%f, %f, %f, %f]", sectionIndex, itemIndex, x, y, w, h);
            
            attributes.frame = CGRectMake(x, y, w, h);
            info[indexPath] = attributes;
        }
    }
    _layoutInfo = info;
//    NSLog(@"  layoutInfo: %@", _layoutInfo);
}

// -------------------------------------------------------------------------------------------
#pragma mark - UICollectionViewLayout
// -------------------------------------------------------------------------------------------

#define MIN_CELL_WIDTH 30
#define MIN_CELL_HEIGHT 30

- (CGSize)collectionViewContentSize {
    
//    NSLog(@"SequencerLayout - collectionViewContentSize()");
    
    // Calculate cell dimensions.
    CGFloat calculatedCellWidth = _collectionViewSize.width / _numPulses;
    CGFloat calculatedCellHeight = _collectionViewSize.height / _numKeys;
    CGFloat cellWidth = MAX(calculatedCellWidth, MIN_CELL_WIDTH);
    CGFloat cellHeight = MAX(calculatedCellHeight, MIN_CELL_HEIGHT);
    _cellSize = CGSizeMake(cellWidth, cellHeight);
//    NSLog(@"  cellSize: %@", NSStringFromCGSize(_cellSize));
    
    // width x height, no spaces.
    CGFloat contentHeight = _numKeys * _cellSize.height;
    CGFloat contentWidth = _numPulses * _cellSize.width;
    _contentSize = CGSizeMake(contentWidth, contentHeight);
//    NSLog(@"  content: %@", NSStringFromCGSize(_contentSize));
    
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
//    NSLog(@"SequencerLayout - layoutAttributesForElementsInRect()");
    
    // Return all layout attributes whose frames collide with the specified rect.
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_layoutInfo.count];
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        if(CGRectIntersectsRect(rect, attributes.frame)) {
//            NSLog(@"  collision");
            [allAttributes addObject:attributes];
        }
    }];
//    NSLog(@"  cells in rect: %d", allAttributes.count);
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"SequencerLayout - layoutAttributesForItemAtIndexPath()");
    return _layoutInfo[indexPath];
}

@end

















