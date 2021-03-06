//
//  JBCountdownLabel.m
//  Meets
//
//  Created by Javier Berlana on 18/06/14.
//  Copyright (c) 2014 Meetsapp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JBCountdownLabel.h"

@interface JBCountdownLabel()

@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JBCountdownLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self updateLabel];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self updateLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame format:(NSString *)string time:(int)seconds delegate:(id <CountdownDelegate>)delegate
{
    NSAssert(seconds > 0, @"You must provide a positive amount of time.");

    self = [super initWithFrame:frame];
    if (self)
    {
        self.numSeconds     = seconds;
        self.stringFormat   = string ?: @"%@";
        self.delegate       = delegate;

        [self defaultLabel];
        [self restartCountdown];
        [self updateLabel];
    }
    return self;
}

#pragma mark - Public methods

- (void)setTime:(int)seconds
{
    self.numSeconds = seconds;
    self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.numSeconds];
}

- (void)startCountdown
{
    NSAssert(self.numSeconds > 0, @"You must provide a positive amount of time.");

    [self restartCountdown];
}

- (void)restartCountdown
{
    [self.timer invalidate];

    self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.numSeconds];
    self.text  = [NSString stringWithFormat:self.stringFormat, [self currentTimeString]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
}

- (void)cancelCountdown
{
    [self.timer invalidate];
    self.expirationDate = [NSDate date];
    self.text = [NSString stringWithFormat:self.stringFormat, [self currentTimeString]];
}

#pragma mark - Private methods

- (void)defaultLabel
{
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment   = NSTextAlignmentCenter;
    self.font            = [UIFont boldSystemFontOfSize:17];
    self.textColor       = [UIColor darkTextColor];
    self.shadowColor     = [UIColor clearColor];
}

- (void)updateLabel
{
    NSString *currentTime = [self currentTimeString];
    NSString *stringFormat = self.stringFormat ?: @"%@";
    self.text = [NSString stringWithFormat:stringFormat, currentTime];

    if (self.expirationDate)
    {
        if ([[NSDate date] timeIntervalSinceDate:self.expirationDate] >= 0)
        {
            [self cancelCountdown];
            if ([self.delegate respondsToSelector:@selector(countdownFinishIn:)]) {
                [self.delegate countdownFinishIn:self];
            }
        }
    }
}

- (NSString *)currentTimeString
{
    NSDate *expirationDate = self.expirationDate ?: [NSDate dateWithTimeIntervalSinceNow:30.0];
    NSDateComponents *countdown = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                  fromDate:[NSDate date]
                                                                    toDate:expirationDate
                                                                   options:0];
    NSString *timeRemaining;
    
    if ([countdown hour] > 0) {
        timeRemaining = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)[countdown hour],(long)[countdown minute], (long)[countdown second]];
    }
    else {
        timeRemaining = [NSString stringWithFormat:@"%02ld:%02ld",(long)[countdown minute], (long)[countdown second]];
    }
    
    return timeRemaining;
}

@end
