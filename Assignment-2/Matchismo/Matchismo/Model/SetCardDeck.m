//
//  SetCardDeck.m
//  Matchismo
//
//  Created by 孙 昱 on 13-6-9.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (id)init {
    self = [super init];
    
    if (self) {
        for (NSUInteger number = 1; number <= [SetCard maxNumber]; number++) {
            for (NSNumber *symbol in [SetCard validSymbols]) {
                for (NSNumber *shading in [SetCard validShadings]) {
                    for (NSNumber *color in [SetCard validColors]) {
                        SetCard *card = [[SetCard alloc] init];
                        card.number = number;
                        card.symbol = [symbol integerValue ];
                        card.shading = [shading integerValue];
                        card.color = [color integerValue];
                        [self addCard:card atTop:YES];
                    }
                }
            }
        }
    }
    
    return self;
}


@end
