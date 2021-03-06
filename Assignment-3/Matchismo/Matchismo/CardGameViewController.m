//
//  CardGameViewController.m
//  Matchismo
//
//  Created by 孙 昱 on 13-9-8.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "GameResult.h"

@interface CardGameViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) int flipCount;


@property (strong, nonatomic) GameResult *gameResult;

@end

@implementation CardGameViewController

#pragma mark - Properties

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:self.startingCardCount
                                                  usingDeck:[self createDeck]
                                                 matchCount:self.numberOfCardsToMatch
                                                 matchBonus:self.matchBonus
                                            mismatchPenalty:self.mismatchPenalty
                                                   flipCost:self.flipCost];
    }
    return _game;
}

- (GameResult *)gameResult
{
    if (!_gameResult) _gameResult = [[GameResult alloc] init];
    return _gameResult;
}

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

// abstract
- (Deck *)createDeck
{
    return nil;
}

// abstract
- (NSUInteger)numberOfCardsToMatch
{
    return 0;
}

- (NSUInteger)matchBonus
{
    return 0;
}

- (NSUInteger)mismatchPenalty
{
    return 0;
}

- (NSString *)cellIdentifier
{
    return nil;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.game currentlyCardCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    Card *card = [self.game cardAtIndex:indexPath.item];
    [self updateCell:cell usingCard:card];
    return cell;
}

// abstract
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card
{
  
}

#pragma mark - Updating the UI

- (void)updateUI
{    
    for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) {
        NSIndexPath *indexPath = [self.cardCollectionView indexPathForCell:cell];
        Card *card = [self.game cardAtIndex:indexPath.item];
        [self updateCell:cell usingCard:card];
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

#define pragma mark - Target/Action/Gestures
- (IBAction)deal:(UIButton *)sender
{
    self.game = nil;
    self.gameResult = nil;
    self.flipCount = 0;
    [self.cardCollectionView reloadData];
    
    [self updateUI];
}

- (IBAction)flipCard:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.cardCollectionView];
    NSIndexPath *indexPath = [self.cardCollectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath) {        
        [self.game flipCardAtIndex:indexPath.item];
        
        if (self.shouldRemoveUnplayableCards) {
            NSMutableIndexSet *unplayableCards = [[NSMutableIndexSet alloc] init];
            NSMutableArray *unplayableIndexPaths = [[NSMutableArray alloc] init];
        
            for (int i = 0; i < self.game.currentlyCardCount; i++) {
                Card *card = [self.game cardAtIndex:i];
                if (card.isUnplayable) {
                    [unplayableCards addIndex:i];
                    [unplayableIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                }
            }
        
            [self.game removeCardsAtIndexes:[self unplayableCards]];
            [self.cardCollectionView deleteItemsAtIndexPaths:unplayableIndexPaths];
        }
        
        self.flipCount++;
        self.gameResult.score = self.game.score;
        [self updateUI];
    }
}

- (NSIndexSet *)unplayableCards
{
    NSMutableIndexSet *unplayableCards = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < self.game.currentlyCardCount; i++) {
        Card *card = [self.game cardAtIndex:i];
        if (card.isUnplayable) {
            [unplayableCards addIndex:i];
        }
    }
    
    return unplayableCards;
}

@end
