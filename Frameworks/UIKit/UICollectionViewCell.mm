//******************************************************************************
//
// UICollectionViewCell.m
// PSPDFKit
//
// Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#import <UIKit/UIKit.h>
#import "NSLogging.h"

static const wchar_t* TAG = L"UICollectionViewCell";

@implementation UICollectionViewCell {
    UIView* _contentView;
    UIView* _backgroundView;
    UIView* _selectedBackgroundView;
    // TODO: this not implemented yet.
    // UILongPressGestureRecognizer *_menuGesture;
    id _selectionSegueTemplate;
    id _highlightingSupport;
    struct {
        unsigned int selected : 1;
        unsigned int highlighted : 1;
        unsigned int showingMenu : 1;
        unsigned int clearSelectionWhenMenuDisappears : 1;
        unsigned int waitingForSelectionAnimationHalfwayPoint : 1;
    } _collectionCellFlags;
    BOOL _selected;
    BOOL _highlighted;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

/**
   @Status Interoperable
*/
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];

        //_menuGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menuGesture:)];
    }
    return self;
}

/**
   @Status Interoperable
*/
- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _contentView = [aDecoder decodeObjectForKey:@"UIContentView"];
        if (_contentView) {
            [self addSubview:_contentView];
        } else {
            if (self.subviews.count > 0) {
                _contentView = self.subviews[0];
            } else {
                _contentView = [[UIView alloc] initWithFrame:self.bounds];
                _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self addSubview:_contentView];
            }
        }

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundView belowSubview:_contentView];

        //_menuGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menuGesture:)];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

/**
   @Status Interoperable
*/
- (void)prepareForReuse {
    self.layoutAttributes = nil;
    self.selected = NO;
    self.highlighted = NO;
    //    self.accessibilityTraits = UIAccessibilityTraitNone;
}

/**
   @Status Interoperable
*/
// Selection highlights underlying contents
- (void)setSelected:(BOOL)selected {
    _collectionCellFlags.selected = (unsigned int)selected;
    //    self.accessibilityTraits = selected ? UIAccessibilityTraitSelected : UIAccessibilityTraitNone;
    [self updateBackgroundView:selected];
}

/**
   @Status Interoperable
*/
// Cell highlighting only highlights the cell itself
- (void)setHighlighted:(BOOL)highlighted {
    _collectionCellFlags.highlighted = (unsigned int)highlighted;
    [self updateBackgroundView:highlighted];
}

- (void)updateBackgroundView:(BOOL)highlight {
    _selectedBackgroundView.alpha = highlight ? 1.0f : 0.0f;
    [self setHighlighted:highlight forViews:self.contentView.subviews];
}

- (void)setHighlighted:(BOOL)highlighted forViews:(id)subviews {
    for (id view in subviews) {
        // Ignore the events if view wants to
        if (!((UIView*)view).isUserInteractionEnabled && [view respondsToSelector:@selector(setHighlighted:)] &&
            ![view isKindOfClass:UIControl.class]) {
            [view setHighlighted:highlighted];

            [self setHighlighted:highlighted forViews:[view subviews]];
        }
    }
}

- (void)menuGesture:(UILongPressGestureRecognizer*)recognizer {
    NSTraceWarning(TAG, @"Not yet implemented: %@", NSStringFromSelector(_cmd));
}

/**
   @Status Interoperable
*/
- (void)setBackgroundView:(UIView*)backgroundView {
    if (_backgroundView != backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        _backgroundView.frame = self.bounds;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_backgroundView atIndex:0];
    }
}

/**
   @Status Interoperable
*/
- (void)setSelectedBackgroundView:(UIView*)selectedBackgroundView {
    if (_selectedBackgroundView != selectedBackgroundView) {
        [_selectedBackgroundView removeFromSuperview];
        _selectedBackgroundView = selectedBackgroundView;
        _selectedBackgroundView.frame = self.bounds;
        _selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _selectedBackgroundView.alpha = self.selected ? 1.0f : 0.0f;
        if (_backgroundView) {
            [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
        } else {
            [self insertSubview:_selectedBackgroundView atIndex:0];
        }
    }
}

- (BOOL)isSelected {
    return _collectionCellFlags.selected;
}

- (BOOL)isHighlighted {
    return _collectionCellFlags.highlighted;
}

- (void)performSelectionSegue {
    /*
        Currently there's no "official" way to trigger a storyboard segue
        using UIStoryboardSegueTemplate, so we're doing it in a semi-legal way.
     */
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"per%@", @"form:"]);
    if ([self->_selectionSegueTemplate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self->_selectionSegueTemplate performSelector:selector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
