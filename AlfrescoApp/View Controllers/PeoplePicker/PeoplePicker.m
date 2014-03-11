//
//  PeoplePicker.m
//  AlfrescoApp
//
//  Created by Mohamad Saeedi on 05/03/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "PeoplePicker.h"
#import "PeoplePickerViewController.h"

@interface PeoplePicker()

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, strong) MultiSelectActionsToolbar *multiSelectToolbar;
@property (nonatomic, strong) NSMutableArray *peopleAlreadySelected;
@property (nonatomic, strong) PeoplePickerViewController *peoplePickerViewController;
@property (nonatomic, assign) BOOL isMultiSelectToolBarVisible;

@end

@implementation PeoplePicker

- (instancetype)initWithSession:(id<AlfrescoSession>)session navigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self)
    {
        _session = session;
        _navigationController = navigationController;
    }
    return self;
}

- (void)startPeoplePickerWithPeople:(NSMutableArray *)people peoplePickerMode:(PeoplePickerMode)peoplePickerMode
{
    self.peoplePickerMode = peoplePickerMode;
    self.peopleAlreadySelected = people;
    
    if (!self.multiSelectToolbar)
    {
        self.multiSelectToolbar = [[MultiSelectActionsToolbar alloc] initWithFrame:CGRectZero];
        self.multiSelectToolbar.multiSelectDelegate = self;
    }
    
    [self.multiSelectToolbar enterMultiSelectMode:nil];
    [self replaceSelectedPeopleWithPeople:self.peopleAlreadySelected];
    
    self.peoplePickerViewController = [[PeoplePickerViewController alloc] initWithSession:self.session peoplePicker:self];
    [self.navigationController pushViewController:self.peoplePickerViewController animated:YES];
}

- (void)cancelPeoplePicker
{
    if (self.navigationController.viewControllers.firstObject == self.peoplePickerViewController)
    {
        [self.peoplePickerViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)isPersonSelected:(AlfrescoPerson *)person
{
    __block BOOL isSelected = NO;
    [self.multiSelectToolbar.selectedItems enumerateObjectsUsingBlock:^(AlfrescoPerson *selectedPerson, NSUInteger index, BOOL *stop) {
        
        if ([person.identifier isEqualToString:selectedPerson.identifier])
        {
            isSelected = YES;
            *stop = YES;
        }
    }];
    return isSelected;
}

- (void)deselectPerson:(AlfrescoPerson *)person
{
    __block id existingPerson = nil;
    [self.multiSelectToolbar.selectedItems enumerateObjectsUsingBlock:^(AlfrescoPerson *selectedPerson, NSUInteger index, BOOL *stop) {
        
        if ([person.identifier isEqualToString:selectedPerson.identifier])
        {
            existingPerson = person;
            *stop = YES;
        }
    }];
    [self.multiSelectToolbar userDidDeselectItem:existingPerson];
    
    if (self.peoplePickerMode == PeoplePickerModeMultiSelect && [self.delegate respondsToSelector:@selector(peoplePickerUserRemovedPerson:peoplePickerMode:)])
    {
        [self.delegate peoplePickerUserRemovedPerson:existingPerson peoplePickerMode:self.peoplePickerMode];
    }
}

- (void)deselectAllPeople
{
    [self.multiSelectToolbar userDidDeselectAllItems];
}

- (void)selectPerson:(AlfrescoPerson *)person
{
    __block BOOL personExists = NO;
    [self.multiSelectToolbar.selectedItems enumerateObjectsUsingBlock:^(AlfrescoPerson *selectedPerson, NSUInteger index, BOOL *stop) {
        
        if ([person.identifier isEqualToString:selectedPerson.identifier])
        {
            personExists = YES;
            *stop = YES;
        }
    }];
    
    if (!personExists)
    {
        [self.multiSelectToolbar userDidSelectItem:person];
    }
}

- (void)replaceSelectedPeopleWithPeople:(NSArray *)people
{
    [self.multiSelectToolbar replaceSelectedItemsWithItems:people];
}

- (NSArray *)selectedPeople
{
    return self.multiSelectToolbar.selectedItems;
}

- (void)showMultiSelectToolBar
{
    if (!self.isMultiSelectToolBarVisible)
    {
        [self.navigationController.view addSubview:self.multiSelectToolbar];
        self.isMultiSelectToolBarVisible = YES;
    }
}

- (void)hideMultiSelectToolBar
{
    if (self.isMultiSelectToolBarVisible)
    {
        [self.multiSelectToolbar removeFromSuperview];
        self.isMultiSelectToolBarVisible = NO;
    }
}

- (void)pickingPeopleComplete
{
    [self cancelPeoplePicker];
    
    if ([self.delegate respondsToSelector:@selector(peoplePickerUserDidSelectPeople:peoplePickerMode:)])
    {
        [self.delegate peoplePickerUserDidSelectPeople:self.multiSelectToolbar.selectedItems peoplePickerMode:self.peoplePickerMode];
    }
}

@end
