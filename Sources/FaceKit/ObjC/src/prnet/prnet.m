//
// prnet.m
//
// This file was automatically generated and should not be edited.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with automatic reference counting enabled (-fobjc-arc)
#endif

#import "prnet.h"

@implementation prnetInput

- (instancetype)initWithPlaceholder__0:(MLMultiArray *)Placeholder__0 {
    self = [super init];
    if (self) {
        _Placeholder__0 = Placeholder__0;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"Placeholder__0"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"Placeholder__0"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.Placeholder__0];
    }
    return nil;
}

@end

@implementation prnetOutput

- (instancetype)initWithResfcn256__Conv2d_transpose_16__Sigmoid__0:(MLMultiArray *)resfcn256__Conv2d_transpose_16__Sigmoid__0 {
    self = [super init];
    if (self) {
        _resfcn256__Conv2d_transpose_16__Sigmoid__0 = resfcn256__Conv2d_transpose_16__Sigmoid__0;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"resfcn256__Conv2d_transpose_16__Sigmoid__0"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"resfcn256__Conv2d_transpose_16__Sigmoid__0"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.resfcn256__Conv2d_transpose_16__Sigmoid__0];
    }
    return nil;
}

@end

@implementation prnet


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"prnet" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load prnet.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize prnet instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of prnet.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model {
    self = [super init];
    if (!self) { return nil; }
    _model = model;
    if (_model == nil) { return nil; }
    return self;
}


/**
    Initialize prnet instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize prnet instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize prnet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for prnet.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize prnet instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for prnet.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct prnet instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid prnet instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(prnet * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct prnet instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid prnet instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(prnet * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            prnet *typedModel = [[prnet alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable prnetOutput *)predictionFromFeatures:(prnetInput *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable prnetOutput *)predictionFromFeatures:(prnetInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [self.model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[prnetOutput alloc] initWithResfcn256__Conv2d_transpose_16__Sigmoid__0:(MLMultiArray *)[outFeatures featureValueForName:@"resfcn256__Conv2d_transpose_16__Sigmoid__0"].multiArrayValue];
}

- (nullable prnetOutput *)predictionFromPlaceholder__0:(MLMultiArray *)Placeholder__0 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    prnetInput *input_ = [[prnetInput alloc] initWithPlaceholder__0:Placeholder__0];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<prnetOutput *> *)predictionsFromInputs:(NSArray<prnetInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [self.model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<prnetOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        prnetOutput * result = [[prnetOutput alloc] initWithResfcn256__Conv2d_transpose_16__Sigmoid__0:(MLMultiArray *)[resultProvider featureValueForName:@"resfcn256__Conv2d_transpose_16__Sigmoid__0"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
