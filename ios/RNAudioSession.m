//
//  RNAudioSession.m
//  RNAudioSession
//
//  Created by Johan Kasperi (DN) on 2018-03-02.
//

#import "RNAudioSession.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <AVFoundation/AVFoundation.h>

@implementation RNAudioSession

@synthesize bridge = _bridge;

static NSDictionary *_categories;
static NSDictionary *_options;
static NSDictionary *_modes;
static NSDictionary *_portOverrides;

+ (void)initialize {
    _categories = @{
                    @"Ambient": AVAudioSessionCategoryAmbient,
                    @"SoloAmbient": AVAudioSessionCategorySoloAmbient,
                    @"Playback": AVAudioSessionCategoryPlayback,
                    @"Record": AVAudioSessionCategoryRecord,
                    @"PlayAndRecord": AVAudioSessionCategoryPlayAndRecord,
                    @"MultiRoute": AVAudioSessionCategoryMultiRoute
                    };
    _options = @{
                 @"MixWithOthers": @(AVAudioSessionCategoryOptionMixWithOthers),
                 @"DuckOthers": @(AVAudioSessionCategoryOptionDuckOthers),
                 @"InterruptSpokenAudioAndMixWithOthers": @(AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers),
                 @"AllowBluetooth": @(AVAudioSessionCategoryOptionAllowBluetooth),
                 @"AllowBluetoothA2DP": @(AVAudioSessionCategoryOptionAllowBluetoothA2DP),
                 @"AllowAirPlay": @(AVAudioSessionCategoryOptionAllowAirPlay),
                 @"DefaultToSpeaker": @(AVAudioSessionCategoryOptionDefaultToSpeaker)
                 };
    _modes = @{
               @"Default": AVAudioSessionModeDefault,
               @"VoiceChat": AVAudioSessionModeVoiceChat,
               @"VideoChat": AVAudioSessionModeVideoChat,
               @"GameChat": AVAudioSessionModeGameChat,
               @"VideoRecording": AVAudioSessionModeVideoRecording,
               @"Measurement": AVAudioSessionModeMeasurement,
               @"MoviePlayback": AVAudioSessionModeMoviePlayback,
               @"SpokenAudio": AVAudioSessionModeSpokenAudio
               };
    _portOverrides = @{
                       @"None": @(AVAudioSessionPortOverrideNone),
                       @"Speaker": @(AVAudioSessionPortOverrideSpeaker)
                       };
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(init:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    
    NSLog(@"[RNAUdioSession] Initialize (2)");
    //check audio routes
    [AVAudioSession sharedInstance];
    // Register for Route Change notifications
    @try {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleRouteChange:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleInterruption:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        NSString* message = [NSString stringWithFormat:@"[RNAudioSession] Failed to initialize, reason: %@", exception.reason];
        reject(@"rnaudiosession_fail_initialize", message, exception);
    }
    
    
    NSLog(@"[RNAudioSession] Initialized");
    
    resolve(@"Done!");
}

RCT_EXPORT_METHOD(category:(RCTResponseSenderBlock)callback)
{
    callback(@[[AVAudioSession sharedInstance].category]);
}

RCT_EXPORT_METHOD(options:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSUInteger options = [AVAudioSession sharedInstance].categoryOptions;
    NSLog(@"Current audio session options bitmask %lu", options);
    NSArray *optionsArray = [self convertOptionsBitmaskToArray: options];
    resolve(optionsArray);
}

RCT_EXPORT_METHOD(mode:(RCTResponseSenderBlock)callback)
{
    callback(@[[AVAudioSession sharedInstance].mode]);
}

RCT_EXPORT_METHOD(setActive:(BOOL)active resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:active withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        reject(@"setActive", @"Could not set active.", error);
    } else {
        resolve(@[]);
    }
}

RCT_EXPORT_METHOD(setCategory:(NSString *)category options:(NSArray *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString* cat = _categories[category];
    
    if (cat != nil && [[AVAudioSession sharedInstance].availableCategories containsObject:cat]) {
        NSError *error = nil;
        if (options != nil) {
            [[AVAudioSession sharedInstance] setCategory:cat withOptions: [self convertOptionsToBitmask: options] error:&error];
        } else {
            [[AVAudioSession sharedInstance] setCategory:cat error:&error];
        }
        if (error) {
            reject(@"setCategory", @"Could not set category.", error);
        } else {
            resolve(@[]);
        }
    } else {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession category.",
                                   NSLocalizedFailureReasonErrorKey: @"The given category is not supported on this device.",
                                   NSLocalizedRecoverySuggestionErrorKey: @"Try another category."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setCategory", @"Could not set category.", error);
    }
}

RCT_EXPORT_METHOD(setMode:(NSString *)mode resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString* mod = _modes[mode];
    if (mod != nil && [[AVAudioSession sharedInstance].availableModes containsObject:mod]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setMode:mod error:&error];
        if (error) {
            reject(@"setMode", @"Could not set mode.", error);
        } else {
            resolve(@[]);
        }
    } else {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession mode.",
                                   NSLocalizedFailureReasonErrorKey: @"The given mode is not supported on this device.",
                                   NSLocalizedRecoverySuggestionErrorKey: @"Try another mode."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setMode", @"Could not set mode.", error);
    }
}

RCT_EXPORT_METHOD(setCategoryAndMode:(NSString *)category mode:(NSString *)mode options:(NSArray *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString* cat = _categories[category];
    NSString* mod = _modes[mode];
    if (cat != nil && mod != nil && options != nil && [[AVAudioSession sharedInstance].availableCategories containsObject:cat] && [[AVAudioSession sharedInstance].availableModes containsObject:mod]) {
        NSError *error = nil;
        NSUInteger optionsArg = [self convertOptionsToBitmask: options];
        [[AVAudioSession sharedInstance] setCategory:cat mode:mod options: optionsArg error:&error];
        
        if (error) {
            reject(@"setCategoryAndMode", @"Could not set category and mode.", error);
        } else {
            resolve(@[]);
        }
    } else {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession category and mode.",
                                   NSLocalizedFailureReasonErrorKey: @"The given category or mode is not supported on this device.",
                                   NSLocalizedRecoverySuggestionErrorKey: @"Try another category or mode."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setCategoryAndMode", @"Could not set category and mode.", error);
    }
}

RCT_EXPORT_METHOD(otherAudioPlaying:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL otherAudioPlaying = [AVAudioSession sharedInstance].otherAudioPlaying;
    resolve(@(otherAudioPlaying));
}

RCT_EXPORT_METHOD(secondaryAudioShouldBeSilencedHint:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL secondaryAudioShouldBeSilencedHint = [AVAudioSession sharedInstance].secondaryAudioShouldBeSilencedHint;
    resolve(@(secondaryAudioShouldBeSilencedHint));
}

RCT_EXPORT_METHOD(currentRoute:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAudioSessionRouteDescription *currentRoute = [AVAudioSession sharedInstance].currentRoute;
    
    NSMutableArray *inputs = [NSMutableArray array];
    
    for (int i = 0; i < [currentRoute.inputs count]; i++) {
        AVAudioSessionPortDescription *input = currentRoute.inputs[i];
        NSDictionary *portDict = [self convertAVAudioSessionPortDescriptionToDictionary: input];
        [inputs addObject: portDict];
    }
    
    NSMutableArray *outputs = [NSMutableArray array];
    
    for (int i = 0; i < [currentRoute.outputs count]; i++) {
        AVAudioSessionPortDescription *output = currentRoute.outputs[i];
        NSDictionary *portDict = [self convertAVAudioSessionPortDescriptionToDictionary: output];
        [outputs addObject: portDict];
    }
    
    NSDictionary *currentRouteDict = @{
                                       @"inputs": inputs,
                                       @"outputs": outputs
                                       };
    
    resolve(currentRouteDict);
}

RCT_EXPORT_METHOD(recordPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
    
    NSString *recordPermissionStr = @"";
    
    if(recordPermission == AVAudioSessionRecordPermissionGranted)
        recordPermissionStr = @"granted";
    else if(recordPermission == AVAudioSessionRecordPermissionDenied)
        recordPermissionStr = @"denied";
    else
        recordPermissionStr = @"undetermined";
    
    resolve(recordPermissionStr);
}

RCT_EXPORT_METHOD(inputAvailable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL inputAvailable = [AVAudioSession sharedInstance].inputAvailable;
    resolve(@(inputAvailable));
}

RCT_EXPORT_METHOD(availableInputs:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSArray *availableInputs = [AVAudioSession sharedInstance].availableInputs;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < [availableInputs count]; i++) {
        AVAudioSessionPortDescription *input = availableInputs[i];
        NSDictionary *portDict = [self convertAVAudioSessionPortDescriptionToDictionary: input];
        [array addObject: portDict];
    }
    
    resolve(array);
}

RCT_EXPORT_METHOD(preferredInput:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAudioSessionPortDescription *preferredInput = [AVAudioSession sharedInstance].preferredInput;
    
    if(preferredInput != nil) {
        resolve([self convertAVAudioSessionPortDescriptionToDictionary: preferredInput]);
    } else {
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(setPreferredInput:(NSString *)uid resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  
    NSError *error = nil;
    
    NSArray *availableInputs = [AVAudioSession sharedInstance].availableInputs;
    
    BOOL found = false;
    for(int i = 0; i < [availableInputs count]; i++) {
        
        AVAudioSessionPortDescription *input = availableInputs[i];
        if(input.UID == uid) {
            found = true;
            [[AVAudioSession sharedInstance] setPreferredInput:input error:&error];
            
            if(error) {
                reject(@"setPreferredInput", @"Could not set AVAudioSession preferred input.", error);
            } else {
                resolve(@"");
            }
        }
    }
    
    if(found == false) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession preferred input.",
                                   NSLocalizedFailureReasonErrorKey: @"The preferred input is not in the list of available inputs."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setPreferredInput", @"Could not set AVAudioSession preferred input.", error);
    }
}

RCT_EXPORT_METHOD(inputDataSources:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSArray *inputDataSources = [AVAudioSession sharedInstance].inputDataSources;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < [inputDataSources count]; i++) {
        AVAudioSessionDataSourceDescription *dataSource = inputDataSources[i];
        NSDictionary *dataSourceDict = [self convertAVAudioSessionDataSourceDescriptionToDictionary: dataSource];
        [array addObject: dataSourceDict];
    }
    
    resolve(array);
}

RCT_EXPORT_METHOD(inputDataSource:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAudioSessionDataSourceDescription *inputDataSource = [AVAudioSession sharedInstance].inputDataSource;
    
    if(inputDataSource != nil) {
        NSDictionary *inputDataSourceDict = [self convertAVAudioSessionDataSourceDescriptionToDictionary: inputDataSource];
        resolve(inputDataSourceDict);
    } else {
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(setInputDataSource:(NSNumber *)dataSourceId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    
    NSError *error = nil;
    
    NSArray *inputDataSources = [AVAudioSession sharedInstance].inputDataSources;
    
    BOOL found = false;
    for(int i = 0; i < [inputDataSources count]; i++) {
        
        AVAudioSessionDataSourceDescription *inputDataSource = inputDataSources[i];
        if(inputDataSource.dataSourceID == dataSourceId) {
            found = true;
            [[AVAudioSession sharedInstance] setInputDataSource:inputDataSource error:&error];
            
            if(error) {
                reject(@"setInputDataSource", @"Could not set AVAudioSession input dataSource.", error);
            } else {
                resolve(@"");
            }
        }
    }
    
    if(found == false) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession input dataSource.",
                                   NSLocalizedFailureReasonErrorKey: @"The input dataSource is not in the list of available input dataSources."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setInputDataSource", @"Could not set AVAudioSession input dataSource.", error);
    }
}

RCT_EXPORT_METHOD(outputDataSources:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSArray *outputDataSources = [AVAudioSession sharedInstance].outputDataSources;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < [outputDataSources count]; i++) {
        AVAudioSessionDataSourceDescription *dataSource = outputDataSources[i];
        NSDictionary *dataSourceDict = [self convertAVAudioSessionDataSourceDescriptionToDictionary: dataSource];
        [array addObject: dataSourceDict];
    }
    
    resolve(array);
}

RCT_EXPORT_METHOD(outputDataSource:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    AVAudioSessionDataSourceDescription *outputDataSource = [AVAudioSession sharedInstance].outputDataSource;
    
    if(outputDataSource != nil) {
        NSDictionary *outputDataSourceDict = [self convertAVAudioSessionDataSourceDescriptionToDictionary: outputDataSource];
        resolve(outputDataSourceDict);
    } else {
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(setOutputDataSource:(NSNumber *)dataSourceId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    
    NSError *error = nil;
    
    NSArray *outputDataSources = [AVAudioSession sharedInstance].outputDataSources;
    
    BOOL found = false;
    for(int i = 0; i < [outputDataSources count]; i++) {
        
        AVAudioSessionDataSourceDescription *outputDataSource = outputDataSources[i];
        if(outputDataSource.dataSourceID == dataSourceId) {
            found = true;
            [[AVAudioSession sharedInstance] setInputDataSource:outputDataSource error:&error];
            
            if(error) {
                reject(@"setOutputDataSource", @"Could not set AVAudioSession input dataSource.", error);
            } else {
                resolve(@"");
            }
        }
    }
    
    if(found == false) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not set AVAudioSession input dataSource.",
                                   NSLocalizedFailureReasonErrorKey: @"The input dataSource is not in the list of available output dataSources."
                                   };
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"setOutputDataSource", @"Could not set AVAudioSession output dataSource.", error);
    }
}

RCT_EXPORT_METHOD(overrideOutputAudioPort:(NSString *)override resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSNumber *overrideValue = [_portOverrides objectForKey:override];
    
    if(overrideValue != nil) {
        
        [[AVAudioSession sharedInstance] overrideOutputAudioPort: [overrideValue unsignedIntegerValue] error:&error];
        if(error) {
            reject(@"overrideOutputAudioPort", @"Could not override AVAudioSession output port.", error);
        } else {
            resolve(@"");
        }
    } else {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Could not override AVAudioSession output port.",
                                   NSLocalizedFailureReasonErrorKey: @"Invalid port override value."
                                   };
        
        NSError *error = [NSError errorWithDomain:@"RNAudioSession" code:-1 userInfo:userInfo];
        reject(@"overrideOutputAudioPort", @"Could not override AVAudioSession output port.", error);
    }
}


-(void) handleInterruption:(NSNotification*)notification{
    NSLog(@"[RNAudioSession] An interruption occurred");
    NSString* interruptTypeStr = @"";
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    //    NSString* interruptTypeAsStr = [NSString stringWithFormat: @"%ld",(long)reason];
    switch (reason) {
        case AVAudioSessionInterruptionTypeBegan:
            interruptTypeStr = @"Audo Session has been interrupted.";
            break;
        case AVAudioSessionInterruptionTypeEnded:
            interruptTypeStr = @"Audio Session interruption has ended.";
            break;
    }
    [self.bridge.eventDispatcher sendAppEventWithName:@"AudioSessionInterruption" body:@{@"typeStr": interruptTypeStr, @"type": [NSNumber numberWithInteger:reason]}];
}

-(void) handleRouteChange:(NSNotification*)notification{
    NSLog(@"[RNAudioSession] Audio route changed");
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count]?session.currentRoute.inputs:nil objectAtIndex:0];
    AVAudioSessionPortDescription *output = [[session.currentRoute.outputs count]?session.currentRoute.outputs:nil objectAtIndex:0];
    
    NSString *inputStr = input.portType ? input.portType : @"";
    NSString *outputStr = output.portType ? output.portType : @"";
    
    //  lastOutputStr = outputStr;
    
    NSLog(@"Change reason %@", seccReason);
    NSLog(@"input %@", inputStr);
    NSLog(@"output %@", outputStr);
    
    //  if (lastOutputStr != outputStr) {
    //    lastOutputStr = outputStr;
    //
    //    if ([outputStr isEqualToString:@"Speaker"]) {
    //      [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
    //                                       withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
    //                                             error:nil];
    //    } else {
    //      [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
    //                                       withOptions:AVAudioSessionCategoryOptionAllowBluetooth
    //                                             error:nil];
    //    }
    //  }
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"AudioSessionRouteChanged" body:@{@"input": inputStr, @"output": outputStr, @"reason": seccReason, @"category":[AVAudioSession sharedInstance].category, @"mode":[AVAudioSession sharedInstance].mode,@"options":[NSNumber numberWithInteger:[AVAudioSession sharedInstance].categoryOptions]}];
}

-(NSUInteger) convertOptionsToBitmask:(NSArray *) array  {
    
    NSUInteger bitmask = 0x0;
    
    for (int i = 0; i < [array count]; i++)
    {
        NSString *key = array[i];
        NSNumber *value = [_options objectForKey:key];
        if(value != nil) {
            bitmask = bitmask | [value unsignedIntegerValue];
        }
    }
    
    NSLog(@"Audio session options array to bitmask: %lu", bitmask);
    //NSLog(@"Test audio session options array to bitmask %lu", AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetoothA2DP);
    return bitmask;
}

-(NSArray *) convertOptionsBitmaskToArray:(NSUInteger) options  {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(id key in _options) {
        NSNumber *option = [_options objectForKey:key];
        NSUInteger optionInt = [option unsignedIntegerValue];
        
        if((optionInt & options) == optionInt) {
            [array addObject: key];
        }
    }
    return array;
}

-(NSDictionary *) convertAVAudioSessionPortDescriptionToDictionary:(AVAudioSessionPortDescription *) port {
    
    NSDictionary *portDict = @{
                               @"portName": port.portName,
                               @"portType": port.portType,
                               @"uid": port.UID
                               };
    return portDict;
}

-(NSDictionary *) convertAVAudioSessionDataSourceDescriptionToDictionary:(AVAudioSessionDataSourceDescription *) dataSource {
    
    NSDictionary *dataSourceDict = @{
                                     @"dataSourceID": dataSource.dataSourceID,
                                     @"dataSourceName": dataSource.dataSourceName,
                                     @"location": dataSource.location,
                                     @"orientation": dataSource.orientation
                                     };
    return dataSourceDict;
}

@end
