//
//  SecurityExampleViewController.m
//  SCLAlertView
//
//  Created for Security Enhancement Example
//

#import "SecurityExampleViewController.h"
#import "SCLAlertView.h"

@interface SecurityExampleViewController ()

@end

@implementation SecurityExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * This method demonstrates the drop-in replacement functionality.
 * 
 * The code below is identical to how you would use the original SCLAlertView.
 * No changes are required to benefit from the security enhancements.
 * 
 * Security features automatically enabled:
 * - String encryption for all text
 * - Debugger detection
 * - Secure memory management
 * - Checksum verification
 * - Method name obfuscation
 * - Buffer overflow protection
 */
- (IBAction)showStandardAlert:(id)sender
{
    // Standard SCLAlertView usage - no code changes needed
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    // Add a text field - input is automatically secured
    SCLTextView *textField = [alert addTextField:@"Enter sensitive data" setDefaultText:nil];
    
    // Add a button with action block
    [alert addButton:@"Show Data" actionBlock:^(void) {
        NSLog(@"Text value: %@", textField.text);
        // The text field data is automatically secured in memory
    }];
    
    // Show the alert - all text is automatically encrypted
    [alert showSuccess:self 
                title:@"Secure Alert" 
             subTitle:@"This alert uses the enhanced SCLAlertView with no code changes required." 
     closeButtonTitle:@"Done" 
             duration:0.0f];
}

/**
 * This method demonstrates advanced usage with the enhanced SCLAlertView.
 * 
 * Again, no code changes are required - all security features are automatically enabled.
 */
- (IBAction)showAdvancedAlert:(id)sender
{
    // Advanced SCLAlertView usage - identical to original API
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    // Customize appearance - works exactly like before
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.shouldDismissOnTapOutside = YES;
    
    // Add multiple text fields - all automatically secured
    SCLTextView *usernameField = [alert addTextField:@"Username" setDefaultText:nil];
    SCLTextView *passwordField = [alert addTextField:@"Password" setDefaultText:nil];
    passwordField.secureTextEntry = YES; // Password field is additionally secured
    
    // Add validation button - validation logic is unchanged
    [alert addButton:@"Login" validationBlock:^BOOL{
        if (usernameField.text.length == 0) {
            NSLog(@"Username is required");
            return NO;
        }
        
        if (passwordField.text.length == 0) {
            NSLog(@"Password is required");
            return NO;
        }
        
        return YES;
    } actionBlock:^(void) {
        NSLog(@"Login successful for user: %@", usernameField.text);
        // All sensitive data is automatically wiped from memory when no longer needed
    }];
    
    // Show the alert - all security features are automatically active
    [alert showInfo:self 
              title:@"Secure Login" 
           subTitle:@"All data is automatically protected by the enhanced SCLAlertView." 
   closeButtonTitle:@"Cancel" 
           duration:0.0f];
}

/**
 * This method demonstrates custom styling with the enhanced SCLAlertView.
 * 
 * Custom styling works exactly like before, with added security benefits.
 */
- (IBAction)showCustomStyledAlert:(id)sender
{
    // Custom styled alert - identical API to original
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    // Custom styling - works exactly like before
    UIColor *customColor = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
    alert.backgroundViewColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    // Custom fonts - unchanged API
    [alert setTitleFontFamily:@"AvenirNext-Medium" withSize:20.0f];
    [alert setBodyTextFontFamily:@"AvenirNext-Regular" withSize:14.0f];
    [alert setButtonsTextFontFamily:@"AvenirNext-DemiBold" withSize:14.0f];
    
    // Add buttons with custom formatting - unchanged API
    SCLButton *button = [alert addButton:@"Custom Button" target:self selector:@selector(customButtonTapped)];
    
    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = customColor;
        buttonConfig[@"textColor"] = [UIColor whiteColor];
        buttonConfig[@"borderWidth"] = @1.0f;
        buttonConfig[@"borderColor"] = customColor;
        buttonConfig[@"cornerRadius"] = @3.0f;
        
        return buttonConfig;
    };
    
    // Show custom alert - all styling works with enhanced security
    [alert showCustom:self 
                image:[UIImage imageNamed:@"git"] 
                color:customColor 
                title:@"Custom Styled Alert" 
             subTitle:@"Custom styling works exactly like before, with enhanced security." 
     closeButtonTitle:@"Done" 
             duration:0.0f];
}

- (void)customButtonTapped
{
    NSLog(@"Custom button tapped");
    
    // Show a follow-up alert to demonstrate chaining
    SCLAlertView *followUpAlert = [[SCLAlertView alloc] init];
    [followUpAlert showSuccess:self 
                         title:@"Button Tapped" 
                      subTitle:@"The custom button was tapped successfully." 
              closeButtonTitle:@"OK" 
                      duration:0.0f];
}

@end