//
//  DOViewController.m
//  DocOpener
//
//  Created by Danis Tazetdinov on 17.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "DOViewController.h"
#import <QuickLook/QuickLook.h>


@interface DOViewController () <UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIButton *buttonShowOptions;

@property (weak, nonatomic) IBOutlet UIButton *buttonOpenDocument;
@property (weak, nonatomic) IBOutlet UIButton *buttonPreview;
@property (weak, nonatomic) IBOutlet UIButton *buttonQuickLook;

@property (weak, nonatomic) IBOutlet UILabel *labelDocumentURL;

@property (strong, nonatomic) UIDocumentInteractionController *docVC;

- (IBAction)openDocument;
- (IBAction)showOptions;
- (IBAction)previewDocument;
- (IBAction)quickLook;

@end

@implementation DOViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.documentURL)
    {
        self.documentURL = [[NSBundle mainBundle] URLForResource:@"DocTest" withExtension:@"rtf"];
    }
}

-(void)setDocumentURL:(NSURL *)documentURL
{
    if (_documentURL != documentURL)
    {
        _documentURL = [documentURL copy];
    }
    
    if (documentURL)
    {
        self.docVC = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
        self.docVC.delegate = self;
        self.docVC.annotation = @{ @"DocOpenerKey" : @"DocOpener application sample." };
        self.buttonShowOptions.enabled = YES;
        self.buttonOpenDocument.enabled = YES;
        self.buttonPreview.enabled = YES;
        self.buttonQuickLook.enabled = YES;
        self.labelDocumentURL.text = documentURL.absoluteString;
    }
}

#pragma mark - Acitons

- (IBAction)openDocument
{
    [self.docVC presentOpenInMenuFromRect:self.buttonOpenDocument.frame inView:self.view animated:YES];
}

- (IBAction)showOptions
{
    [self.docVC presentOptionsMenuFromRect:self.buttonOpenDocument.frame inView:self.view animated:YES];
}

- (IBAction)previewDocument
{
    [self.docVC presentPreviewAnimated:YES];
}

- (IBAction)quickLook
{
    QLPreviewController *vc = [[QLPreviewController alloc] init];
    vc.dataSource = self;
    [self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods


-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.navigationController;
}

#pragma mark - QLPreviewControllerDataSource methods


-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.documentURL;
}

@end
