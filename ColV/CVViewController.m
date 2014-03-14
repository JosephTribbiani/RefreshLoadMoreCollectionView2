//
//  CVViewController.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/5/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "CVViewController.h"
#import "CVCollectionViewCell.h"
#import "CVDataSource.h"
#import "CVActivityView.h"

#define REFRESH_THRESHOLD 60

#define ACTIVITY_VIEW_WIDTH 60
#define INDICATOR_SIDE_WIDTH 30

@interface CVViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, CVDataSourceDelegate>
{
    CVDataSource* _dataSource;
    CVActivityView* _leftActivityView;
    CVActivityView* _rightActivityView;
}

@property (nonatomic, strong, readonly) CVDataSource* dataSource;
@property (nonatomic, strong) CVActivityView* leftActivityView;
@property (nonatomic, strong) CVActivityView* rightActivityView;

@property BOOL isCollectionViewBusy;
@property CGFloat contentOffset;

@end

@implementation CVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLayout];
    self.isCollectionViewBusy = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupLayout
{
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(129, 188);
	layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	[self.collectionView setCollectionViewLayout:layout animated:YES];
}

- (CVDataSource*)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [CVDataSource new];
        _dataSource.delegate = self;
    }
    return _dataSource;
}

- (CVActivityView*)leftActivityView
{
    if (_leftActivityView == nil)
    {
        _leftActivityView = [[CVActivityView alloc]initWithFrame:CGRectMake(-ACTIVITY_VIEW_WIDTH, 0, ACTIVITY_VIEW_WIDTH, self.collectionView.frame.size.height) image:[UIImage imageNamed:@"flipped_arrow.png"]];
        [self.collectionView addSubview:_leftActivityView];
    }
    return _leftActivityView;
}

- (CVActivityView*)rightActivityView
{
    if (_rightActivityView == nil)
    {
        _rightActivityView = [[CVActivityView alloc] initWithFrame:CGRectMake(self.collectionView.contentSize.width, 0, ACTIVITY_VIEW_WIDTH, self.collectionView.frame.size.height)];
        [self.collectionView addSubview:_rightActivityView];
    }
    return _rightActivityView;
}

#pragma mark - CollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    [cell.photoImageView setImage:[self.dataSource itemAtIndexPath:indexPath]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfItems];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x < - REFRESH_THRESHOLD && self.isCollectionViewBusy == NO)
    {
        self.isCollectionViewBusy = YES;
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                                        [scrollView setContentInset:UIEdgeInsetsMake(0, self.leftActivityView.bounds.size.width, 0, 0)];
                                    }
                         completion:^(BOOL finished) {
                             [self.leftActivityView startAnimating];
                             [self.dataSource refresh];
                         }];
    }
    else if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width + REFRESH_THRESHOLD && self.isCollectionViewBusy == NO)
    {
        self.contentOffset = scrollView.contentSize.width - scrollView.frame.size.width;
        self.isCollectionViewBusy = YES;
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, self.rightActivityView.bounds.size.width)];
                         }
                         completion:^(BOOL finished) {
                             [self.rightActivityView startAnimating];
                             [self.dataSource loadMore];
                         }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width + REFRESH_THRESHOLD)
    {
        [self.rightActivityView turnArrowLeft];
    }
    else if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width + REFRESH_THRESHOLD)
    {
        [self.rightActivityView turnArrowRight];
    }
    
    if (scrollView.contentOffset.x <= 0 && scrollView.contentOffset.x > - REFRESH_THRESHOLD)
    {
        [self.leftActivityView turnArrowLeft];
    }
    else if (scrollView.contentOffset.x < - REFRESH_THRESHOLD)
    {
        [self.leftActivityView turnArrowRight];
    }
}

#pragma mark - DataSourceDelegate

- (void)dataSourceDidRefresh:(CVDataSource *)datasource
{
    NSLog(@"Did Refresh");
    [self.leftActivityView setHidden:YES];
    [self.leftActivityView stopAnimating];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^(BOOL finished) {
                         [self.collectionView reloadData];
                         self.isCollectionViewBusy = NO;
                         [self.leftActivityView setHidden:NO];
                         NSLog(@"new number of items: %d",[self.dataSource numberOfItems]);
                     }];
}

- (void)dataSourceDidLoadData:(CVDataSource *)datasource
{
    NSLog(@"Did Load More");
    [self.rightActivityView removeFromSuperview];
    self.rightActivityView = nil;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^(BOOL finished) {
                         [self.collectionView reloadData];
                         
                         CGPoint offset = self.collectionView.contentOffset;
                         offset.x = offset.x + 20;
                         [self.collectionView setContentOffset:offset animated:YES];
                         
                         self.isCollectionViewBusy = NO;
                         NSLog(@"new number of items: %d",[self.dataSource numberOfItems]);
                     }];
    
}

@end
