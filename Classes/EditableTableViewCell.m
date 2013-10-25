//
//  IngredientTableViewCell.m
//  Recipe Box
//
//  Created by Jacques Fortier on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditableTableViewCell.h"

static const CGFloat kTextViewWidth = 320;

#define kFontSize ([UIFont systemFontSize])

static const CGFloat kTextViewInset = 31;
static const CGFloat kTextViewVerticalPadding = 15;
static const CGFloat kTopPadding = 6;
static const CGFloat kBottomPadding = 6;

static UIFont *textViewFont;
static UITextView *dummyTextView;

@implementation EditableTableViewCell

@synthesize delegate;
@synthesize textView;
@synthesize text;

+ (UITextView *)createTextView {
    UITextView *newTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    newTextView.font = textViewFont;
    newTextView.backgroundColor = [UIColor whiteColor];
    newTextView.opaque = YES;
    newTextView.scrollEnabled = NO;
    newTextView.showsVerticalScrollIndicator = NO;
    newTextView.showsHorizontalScrollIndicator = NO;
    newTextView.contentInset = UIEdgeInsetsZero;
    
    return newTextView;
}

+ (UITextView *)dummyTextView {
    return dummyTextView;
}


+ (CGFloat)heightForText:(NSString *)text {
    if (text == nil || text.length == 0) {
        text = @"Xy";
    }
    
    dummyTextView.text = text;
    
    CGSize textSize = dummyTextView.contentSize;
    
    CGFloat heightForText = textSize.height + kBottomPadding + kTopPadding + 1;
    return heightForText;
}


+ (void)initialize {
    textViewFont = [[UIFont systemFontOfSize:kFontSize] retain];
    dummyTextView = [EditableTableViewCell createTextView];
    dummyTextView.alpha = 0.0;
    dummyTextView.frame = CGRectMake(0, 0, kTextViewWidth, 500);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        textView = [EditableTableViewCell createTextView];
        textView.delegate = self;
        [self.contentView addSubview:textView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;

    contentRect.origin.y += kTopPadding;
    contentRect.size.height -= kTopPadding + kBottomPadding;

    textView.frame = contentRect;
    textView.contentOffset = CGPointZero;

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setText:(NSMutableString *)newText {
    if (newText != text) {
        [text release];
        text = [newText copy];
        textView.text = newText;
        [self textViewDidChange:textView];
    }
}


#pragma mark -
#pragma mark UITextView delegate


- (void) textViewDidBeginEditing:(UITextView *)theTextView {
    if ([delegate respondsToSelector:@selector(editableTableViewCellDidBeginEditing:)]) {
        [delegate editableTableViewCellDidBeginEditing:self];
    }
}


- (void)textViewDidEndEditing:(UITextView *)theTextView {
    text = [[NSMutableString alloc] initWithString:theTextView.text];

    if ([delegate respondsToSelector:@selector(editableTableViewCellDidEndEditing:)]) {
        [delegate editableTableViewCellDidEndEditing:self];
    }
}


- (void)textViewDidChange:(UITextView *)theTextView {
    CGFloat suggested = [self suggestedHeight];
    
    if (fabs(suggested - self.frame.size.height) > 0.01) {
        if ([delegate respondsToSelector:@selector(editableTableViewCell:heightChangedTo:)]) {
            [delegate editableTableViewCell:self heightChangedTo:suggested];
        }
    }
}


- (CGFloat)suggestedHeight {
    CGFloat suggestedHeight = [textView sizeThatFits:CGSizeMake(textView.contentSize.width,FLT_MAX)].height + kTopPadding + kBottomPadding + 1;
    return suggestedHeight;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [textView release], textView = nil;
    [super dealloc];
}


@end
