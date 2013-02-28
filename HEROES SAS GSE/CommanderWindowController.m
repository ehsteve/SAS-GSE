//
//  CommanderWindowController.m
//  HEROES SAS GSE
//
//  Created by Steven Christe on 2/27/13.
//  Copyright (c) 2013 GSFC. All rights reserved.
//

#import "CommanderWindowController.h"
#import "Commander.h"

@interface CommanderWindowController ()
@property (nonatomic,retain) NSDictionary *plistDict;
@property (nonatomic, strong) Commander *commander;
@end

@implementation CommanderWindowController

@synthesize commandListcomboBox;
@synthesize commandKey_textField;
@synthesize Variables_Form;
@synthesize plistDict = _plistDict;
@synthesize commander = _commander;

- (id)init{
    return [super initWithWindowNibName:@"CommanderWindowController"];
}

- (Commander *)commander
{
    if (_commander == nil) {
        _commander = [[Commander alloc] init];
    }
    return _commander;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSDictionary *)plistDict{
    if (_plistDict == nil) {
        // read command list dictionary from the CommandList.plist resource file
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CommandList" ofType:@"plist"];
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        
        _plistDict = (NSDictionary *)[NSPropertyListSerialization
                                                   propertyListFromData:plistXML
                                                   mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                   format:&format
                                                   errorDescription:&errorDesc];
        if (!_plistDict) {
            NSLog(@"Error reading CommandList.plist");
        }
    }
    return _plistDict;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.commandListcomboBox addItemsWithObjectValues:[self.plistDict allKeys]];
    [self.commandListcomboBox setCompletes:YES];
    [self.Variables_Form setHidden:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

- (IBAction)commandList_action:(NSComboBox *)sender {
    NSString *user_choice = [self.commandListcomboBox stringValue];
    [self.commandKey_textField setStringValue: [[self.plistDict valueForKey:user_choice] valueForKey:@"key"]];
    
    NSArray *variable_names = [[self.plistDict valueForKey:user_choice] valueForKey:@"var_names"];
    NSInteger numberOfVariablesNeeded = [variable_names count];
    NSInteger numberOfVariablesCurrentlyDisplayed = (long)[self.Variables_Form numberOfRows];

    // clear the form of all elements
    for (int i = 0; i < numberOfVariablesCurrentlyDisplayed; i++) {
        [self.Variables_Form removeEntryAtIndex:0];
    }

    if (numberOfVariablesNeeded == 0) {
        [self.Variables_Form setHidden:YES];
    } else {
        for (NSString *name in variable_names) {
            [self.Variables_Form addEntry:name];
        }
        [self.Variables_Form setHidden:NO];
    }
    
    NSString *toolTip = (NSString *)[[self.plistDict valueForKey:user_choice] valueForKey:@"description"];
    [self.commandListcomboBox setToolTip:toolTip];
    
}

- (IBAction)send_Button:(NSButton *)sender {
    uint16_t command_sequence_number = 0;
    
    command_sequence_number = [self.commander send:[self.commandKey_textField stringValue] :command_var: [CommandIPTextField stringValue]];
    
    [self.commandCount_textField setIntegerValue:command_sequence_number];
}
@end
