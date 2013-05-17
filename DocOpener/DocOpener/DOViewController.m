//
//  DOViewController.m
//  DocOpener
//
//  Created by Danis Tazetdinov on 17.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "DOViewController.h"

@interface DOViewController () <UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonShowOptions;

@property (weak, nonatomic) IBOutlet UIButton *buttonOpenDocument;
@property (weak, nonatomic) IBOutlet UIButton *buttonPreview;

@property (weak, nonatomic) IBOutlet UILabel *labelDocumentURL;

- (IBAction)openDocument;
- (IBAction)showOptions;
- (IBAction)previewDocument;

@end

@implementation DOViewController

-(void)setDocumentURL:(NSURL *)documentURL
{
    if (_documentURL != documentURL)
    {
        _documentURL = [documentURL copy];
    }
    
    if (documentURL)
    {
        self.buttonShowOptions.enabled = YES;
        self.buttonOpenDocument.enabled = YES;
        self.buttonPreview.enabled = YES;
        self.labelDocumentURL.text = documentURL.absoluteString;
    }
}

- (IBAction)openDocument
{
    UIDocumentInteractionController *vc = [UIDocumentInteractionController interactionControllerWithURL:self.documentURL];
    vc.delegate = self;
    [vc presentOpenInMenuFromRect:self.buttonOpenDocument.frame inView:self.view animated:YES];
}

- (IBAction)showOptions
{
    UIDocumentInteractionController *vc = [UIDocumentInteractionController interactionControllerWithURL:self.documentURL];
    vc.delegate = self;
    [vc presentOptionsMenuFromRect:self.buttonOpenDocument.frame inView:self.view animated:YES];
}

- (IBAction)previewDocument
{
    UIDocumentInteractionController *vc = [UIDocumentInteractionController interactionControllerWithURL:self.documentURL];
    vc.delegate = self;
    [vc presentPreviewAnimated:YES];
}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

@end
