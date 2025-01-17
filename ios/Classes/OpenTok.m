// Autogenerated from Pigeon (v4.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "OpenTok.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ?: [NSNull null]),
        @"message": (error.message ?: [NSNull null]),
        @"details": (error.details ?: [NSNull null]),
        };
  }
  return @{
      @"result": (result ?: [NSNull null]),
      @"error": errorDict,
      };
}
static id GetNullableObject(NSDictionary* dict, id key) {
  id result = dict[key];
  return (result == [NSNull null]) ? nil : result;
}
static id GetNullableObjectAtIndex(NSArray* array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}


@interface FLTConnectionStateCallback ()
+ (FLTConnectionStateCallback *)fromMap:(NSDictionary *)dict;
+ (nullable FLTConnectionStateCallback *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTOpenTokConfig ()
+ (FLTOpenTokConfig *)fromMap:(NSDictionary *)dict;
+ (nullable FLTOpenTokConfig *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation FLTConnectionStateCallback
+ (instancetype)makeWithState:(FLTConnectionState)state
    errorDescription:(nullable NSString *)errorDescription {
  FLTConnectionStateCallback* pigeonResult = [[FLTConnectionStateCallback alloc] init];
  pigeonResult.state = state;
  pigeonResult.errorDescription = errorDescription;
  return pigeonResult;
}
+ (FLTConnectionStateCallback *)fromMap:(NSDictionary *)dict {
  FLTConnectionStateCallback *pigeonResult = [[FLTConnectionStateCallback alloc] init];
  pigeonResult.state = [GetNullableObject(dict, @"state") integerValue];
  pigeonResult.errorDescription = GetNullableObject(dict, @"errorDescription");
  return pigeonResult;
}
+ (nullable FLTConnectionStateCallback *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FLTConnectionStateCallback fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"state" : @(self.state),
    @"errorDescription" : (self.errorDescription ?: [NSNull null]),
  };
}
@end

@implementation FLTOpenTokConfig
+ (instancetype)makeWithApiKey:(NSString *)apiKey
    sessionId:(NSString *)sessionId
    token:(NSString *)token {
  FLTOpenTokConfig* pigeonResult = [[FLTOpenTokConfig alloc] init];
  pigeonResult.apiKey = apiKey;
  pigeonResult.sessionId = sessionId;
  pigeonResult.token = token;
  return pigeonResult;
}
+ (FLTOpenTokConfig *)fromMap:(NSDictionary *)dict {
  FLTOpenTokConfig *pigeonResult = [[FLTOpenTokConfig alloc] init];
  pigeonResult.apiKey = GetNullableObject(dict, @"apiKey");
  NSAssert(pigeonResult.apiKey != nil, @"");
  pigeonResult.sessionId = GetNullableObject(dict, @"sessionId");
  NSAssert(pigeonResult.sessionId != nil, @"");
  pigeonResult.token = GetNullableObject(dict, @"token");
  NSAssert(pigeonResult.token != nil, @"");
  return pigeonResult;
}
+ (nullable FLTOpenTokConfig *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FLTOpenTokConfig fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"apiKey" : (self.apiKey ?: [NSNull null]),
    @"sessionId" : (self.sessionId ?: [NSNull null]),
    @"token" : (self.token ?: [NSNull null]),
  };
}
@end

@interface FLTOpenTokHostApiCodecReader : FlutterStandardReader
@end
@implementation FLTOpenTokHostApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTOpenTokConfig fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTOpenTokHostApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTOpenTokHostApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTOpenTokConfig class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTOpenTokHostApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTOpenTokHostApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTOpenTokHostApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTOpenTokHostApiCodecReader alloc] initWithData:data];
}
@end


NSObject<FlutterMessageCodec> *FLTOpenTokHostApiGetCodec() {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    FLTOpenTokHostApiCodecReaderWriter *readerWriter = [[FLTOpenTokHostApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}

void FLTOpenTokHostApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTOpenTokHostApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.initSession"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(initSessionConfig:error:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(initSessionConfig:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTOpenTokConfig *arg_config = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api initSessionConfig:arg_config error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.endSession"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(endSessionWithError:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(endSessionWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api endSessionWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.toggleCamera"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(toggleCameraWithError:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(toggleCameraWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api toggleCameraWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.toggleAudio"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(toggleAudioEnabled:error:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(toggleAudioEnabled:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSNumber *arg_enabled = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api toggleAudioEnabled:arg_enabled error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.toggleVideo"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(toggleVideoEnabled:error:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(toggleVideoEnabled:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSNumber *arg_enabled = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api toggleVideoEnabled:arg_enabled error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.onPause"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(onPauseWithError:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(onPauseWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api onPauseWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.onResume"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(onResumeWithError:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(onResumeWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api onResumeWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.OpenTokHostApi.onStop"
        binaryMessenger:binaryMessenger
        codec:FLTOpenTokHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(onStopWithError:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(onStopWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api onStopWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
      FlutterBasicMessageChannel *channel =
        [[FlutterBasicMessageChannel alloc]
          initWithName:@"dev.flutter.pigeon.OpenTokHostApi.getConnectionId"
          binaryMessenger:binaryMessenger
          codec:FLTOpenTokHostApiGetCodec()];
      if (api) {
        NSCAssert([api respondsToSelector:@selector(getConnectionId:)], @"FLTOpenTokHostApi api (%@) doesn't respond to @selector(getConnectionId:)", api);
        [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
          FlutterError *error;
          NSString *connectionId = [api getConnectionId:&error];
          callback(wrapResult(connectionId, error));
        }];
      }
      else {
        [channel setMessageHandler:nil];
      }
    }
}
@interface FLTOpenTokPlatformApiCodecReader : FlutterStandardReader
@end
@implementation FLTOpenTokPlatformApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTConnectionStateCallback fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTOpenTokPlatformApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTOpenTokPlatformApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTConnectionStateCallback class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTOpenTokPlatformApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTOpenTokPlatformApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTOpenTokPlatformApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTOpenTokPlatformApiCodecReader alloc] initWithData:data];
}
@end


NSObject<FlutterMessageCodec> *FLTOpenTokPlatformApiGetCodec() {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    FLTOpenTokPlatformApiCodecReaderWriter *readerWriter = [[FLTOpenTokPlatformApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}

@interface FLTOpenTokPlatformApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation FLTOpenTokPlatformApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)onStateUpdateConnectionState:(FLTConnectionStateCallback *)arg_connectionState completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.OpenTokPlatformApi.onStateUpdate"
      binaryMessenger:self.binaryMessenger
      codec:FLTOpenTokPlatformApiGetCodec()      ];  [channel sendMessage:@[arg_connectionState ?: [NSNull null]] reply:^(id reply) {
    completion(nil);
  }];
}
@end
