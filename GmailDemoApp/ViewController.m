//
//  ViewController.m
//  GmailDemoApp
//
//  Created by Yatheesan Chandreswaran on 4/28/17.
//  Copyright © 2017 Yatheesan. All rights reserved.
//

#import "ViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "GTLRGmail.h"
#import "GTLRBase64.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kKeychainItemName = @"kohls kpis app iOS";
static NSString *const kClientID = @"733673414650-28c45s2mif8qs9c8j47bam9htk36r0k0.apps.googleusercontent.com";

@interface ViewController ()

@end

@implementation ViewController

@synthesize service = _service;
@synthesize output = _output;

// When the view loads, create necessary subviews, and initialize the Gmail API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *aDict=[NSMutableDictionary new];
    [aDict setObject:@"Mozilla/5.0 (iPad; CPU OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0 Mobile/14C92 Safari/602.1" forKey:@"UserAgent"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:aDict];
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //[self.view addSubview:self.output];
    
    // Initialize the Gmail API service & load existing credentials from the keychain if available.
    self.service = [[GTLRGmailService alloc] init];
}

// When the view appears, ensure that the Gmail API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
        self.service.authorizer =
        [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:kClientID
                                                          clientSecret:nil];
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
    } else {
        
    }
}

// Construct a query and get a list of labels from the user's gmail. Display the
// label name in the UITextView
- (void)fetchLabels {
    self.output.text = @"Getting labels...";
    
    GTLRGmailQuery_UsersLabelsList *query = [GTLRGmailQuery_UsersLabelsList queryWithUserId:@"me"];
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRGmail_ListLabelsResponse *)labelsResponse
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *labelString = [[NSMutableString alloc] init];
        if (labelsResponse.labels.count > 0) {
            [labelString appendString:@"Labels:\n"];
            for (GTLRGmail_Label *label in labelsResponse.labels) {
                [labelString appendFormat:@"%@\n", label.name];
            }
        } else {
            [labelString appendString:@"No labels found."];
        }
        self.output.text = labelString;
        
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}

// Creates the auth controller for authorizing access to Gmail API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLRAuthScopeGmailCompose,kGTLRAuthScopeGmailMailGoogleCom,kGTLRAuthScopeGmailModify,kGTLRAuthScopeGmailSend, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Gmail API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void) sendMail {
    
    NSMutableArray *mailsData = [[NSMutableArray alloc]init];
    [mailsData addObject:@"screenshoot"];
    GTLRUploadParameters * paraam = [[GTLRUploadParameters alloc]init];
    paraam.MIMEType = @"message/rfc822";
    paraam.data = [self getFormattedRawMessageForMail:mailsData];
    
    GTLRGmail_Message * sampleMsg = [[GTLRGmail_Message alloc]init];
    
    NSData *model = [self getFormattedRawMessageForMail:mailsData];
    
    sampleMsg.raw = GTLREncodeWebSafeBase64(model);
    
    GTLRGmailQuery *querys = [GTLRGmailQuery_UsersMessagesSend queryWithObject:sampleMsg userId:@"me" uploadParameters:nil];
    [self.service executeQuery:querys completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        [self showAlert:@"Alert" message:@"Messages have been sent successfully"];
        NSLog(@"%@",callbackTicket);
        NSLog(@"%@",object);
        NSLog(@"%@",callbackError);
    }];
}

- (NSData *)getFormattedRawMessageForMail:(NSMutableArray *)arrFilenames{
    
    // Date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *finalDate = [NSString stringWithFormat:@"Date: %@\r\n", strDate];
    
    // From string
    NSString *from = @"From: \r\n";
    
    // To string - sampath.wickramasinghe@kohls.com,sarnab.poddar@kohls.com,natasha.chakerwarti@kohls.com
    NSString *to = @"To:\r\n";
    
    // CC string
    NSString *cc = @"";
    //    if(mail.cc.length > 0) {
    //        cc = [self getFormattedStringForFieldName:SEND_MAIL_CC ForAllReceivers:mail.cc];
    //    }
    //
    //    // BCC string
    //    NSString *bcc = @"";
    //    if(mail.bcc.length > 0) {
    //        bcc = [self getFormattedStringForFieldName:SEND_MAIL_BCC ForAllReceivers:mail.bcc];
    //    }
    
    // Subject string
    NSString *subject = @"Subject: Sample Subject\r\n\r\n";
    
    // Body string
    NSString *body = @"Feedback with image\r\n";
    
    // Final string to be returned
    NSString *rawMessage = @"";
    
    // Depending on whether the email has attachments, the email can either be sent as "text/plain" or "multipart/mixed"
    if (arrFilenames.count > 0) {
        
        // Send as "multipart/mixed"
        NSString *contentTypeMain = @"Content-Type: multipart/mixed; boundary=\"project\"\r\n";
        
        // Reusable Boundary string
        NSString *boundary = @"\r\n--project\r\n";
        
        // Body string
        NSString *contentTypePlain = @"Content-Type: text/plain; charset=\"UTF-8\"\r\n";
        
        // Combine strings from "finalDate" to "body"
        rawMessage = [[[[[[[[[contentTypeMain stringByAppendingString:finalDate] stringByAppendingString:from]stringByAppendingString:to]stringByAppendingString:cc]stringByAppendingString:cc]stringByAppendingString:subject]stringByAppendingString:boundary]stringByAppendingString:contentTypePlain]stringByAppendingString:body];
        
        // Attachments strings
        for (NSString *filename in arrFilenames) {
            
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
            } else {
                UIGraphicsBeginImageContext(self.view.bounds.size);
            }
            
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // NSData *imageData = UIImagePNGRepresentation(image);
            
            // Image Content Type string
            NSString *contentTypePNG = boundary;
            contentTypePNG = [contentTypePNG stringByAppendingString:[NSString stringWithFormat:@"Content-Type: image/png; name=\"%@\"\r\n",filename]];
            contentTypePNG = [contentTypePNG stringByAppendingString:@"Content-Transfer-Encoding: base64\r\n"];
            
            // PNG image data
             NSData *pngData = UIImagePNGRepresentation(image);
            
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
            } else {
                UIGraphicsBeginImageContext(self.view.bounds.size);
            }
            
            
            //            if (imageData) {
            //                [imageData writeToFile:@"screenshot.png" atomically:YES];
            //            } else {
            //                NSLog(@"error while taking screenshot");
            //            }
            //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            
            
            NSString *pngString = [NSString stringWithFormat:@"%@\r\n",GTLREncodeBase64(pngData)];
            // NSString *pngString = [NSString stringWithFormat:@"%d\r\n",GTLEncodeBase64(pngData)];
            contentTypePNG = [contentTypePNG stringByAppendingString:pngString];
            
            // Add to raw message
            rawMessage = [rawMessage stringByAppendingString:contentTypePNG];
        }
        
        // End string
        rawMessage = [rawMessage stringByAppendingString:@"\r\n--project--"];
        
    }else{
        
        // Send as "text/plain"
        rawMessage = [[[[[[finalDate stringByAppendingString:from]stringByAppendingString:to]stringByAppendingString:cc]stringByAppendingString:cc]stringByAppendingString:subject]stringByAppendingString:body];
        
    }
    
    return [rawMessage dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)sendFeedbackBtnAction:(id)sender {
    [self sendMail];
}

@end
