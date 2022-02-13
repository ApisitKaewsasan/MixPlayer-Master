//
//  AudioRander.m
//  audio_player
//
//  Created by Dotsocket on 2/2/22.
//
#import "AudioRander.h"

@implementation AudioRander : NSObject

- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

- (void)configureAudioEngine :(AVAudioEngine *)engine playerNode:(AVAudioPlayerNode *)playerNode fileUrl:(AVAudioFile *) fileUrl   {
    self.engine = engine;
    self.playerNode = playerNode;
    self.file = fileUrl;

}

- (NSString *)renderAudioAndWriteToFileExtension :(NSString *) extension callback:(void (^)(NSUInteger totalBytesWritten,NSUInteger totalBytesExpectedToWrite))completionBlock {
    AVAudioOutputNode *outputNode = self.engine.outputNode;
    AudioStreamBasicDescription const *audioDescription = [outputNode outputFormatForBus:0].streamDescription;
    NSString *path = [self filePath:extension];
    ExtAudioFileRef audioFile = [self createAndSetupExtAudioFileWithASBD:audioDescription andFilePath:path];
    if (!audioFile)
        return nil;
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.file.url];
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    NSUInteger lengthInFrames = (NSUInteger) (duration * audioDescription->mSampleRate);
    const NSUInteger kBufferLength = 3756;
    AudioBufferList *bufferList = AEAllocateAndInitAudioBufferList(*audioDescription, kBufferLength);
    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    OSStatus status = noErr;
    for (NSUInteger i = kBufferLength; i <= lengthInFrames; i += kBufferLength) {
        status = [self renderToBufferList:bufferList writeToFile:audioFile bufferLength:kBufferLength timeStamp:&timeStamp];
       // NSLog(@"cccza007 %d %d %d",i,lengthInFrames,i/lengthInFrames);
        completionBlock(i,lengthInFrames);
        if (status != noErr)
            break;
    }
    
    if (status == noErr && timeStamp.mSampleTime < lengthInFrames) {
        NSUInteger restBufferLength = (NSUInteger) (lengthInFrames - timeStamp.mSampleTime);
        AudioBufferList *restBufferList = AEAllocateAndInitAudioBufferList(*audioDescription, restBufferLength);
        status = [self renderToBufferList:restBufferList writeToFile:audioFile bufferLength:restBufferLength timeStamp:&timeStamp];
        AEFreeAudioBufferList(restBufferList);
    }
    SInt64 fileLengthInFrames;
    UInt32 size = sizeof(SInt64);
    ExtAudioFileGetProperty(audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthInFrames);
    AEFreeAudioBufferList(bufferList);
    ExtAudioFileDispose(audioFile);
    if (status != noErr)
      //  [self showAlertWithTitle:@"Error" message:@"See logs for details"];
    NSLog(@"See logs for details ");
    
    else {
        NSLog(@"Finished writing to file at path: %@", path);
      //  [self showAlertWithTitle:@"Success!" message:@"Now you can play a result file"];
    }
    return path;
}



- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}


- (NSString *)filePath:(NSString *) extension {
    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"mix_export_audio"];
    // New Folder is your folder name
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];


    NSString *fileName = [NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString],extension];
    NSString *path = [stringPath stringByAppendingPathComponent:fileName];
    return path;
}

- (ExtAudioFileRef)createAndSetupExtAudioFileWithASBD:(AudioStreamBasicDescription const *)audioDescription
                                          andFilePath:(NSString *)path {
    AudioStreamBasicDescription destinationFormat;
    memset(&destinationFormat, 0, sizeof(destinationFormat));
    destinationFormat.mChannelsPerFrame = audioDescription->mChannelsPerFrame;
    destinationFormat.mSampleRate = audioDescription->mSampleRate;
    destinationFormat.mFormatID = kAudioFormatMPEG4AAC;
    ExtAudioFileRef audioFile;
    OSStatus status = ExtAudioFileCreateWithURL(
            (__bridge CFURLRef) [NSURL fileURLWithPath:path],
            kAudioFileM4AType,
            &destinationFormat,
            NULL,
            kAudioFileFlags_EraseFile,
            &audioFile
    );
    if (status != noErr) {
        NSLog(@"Can not create ext audio file");
        return nil;
    }
    UInt32 codecManufacturer = kAppleSoftwareAudioCodecManufacturer;
    status = ExtAudioFileSetProperty(
            audioFile, kExtAudioFileProperty_CodecManufacturer, sizeof(UInt32), &codecManufacturer
    );
    status = ExtAudioFileSetProperty(
            audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), audioDescription
    );
    status = ExtAudioFileWriteAsync(audioFile, 0, NULL);
    if (status != noErr) {
        NSLog(@"Can not setup ext audio file");
        return nil;
    }
    return audioFile;
}
- (OSStatus)renderToBufferList:(AudioBufferList *)bufferList
                   writeToFile:(ExtAudioFileRef)audioFile
                  bufferLength:(NSUInteger)bufferLength
                     timeStamp:(AudioTimeStamp *)timeStamp {
    [self clearBufferList:bufferList];
    AudioUnit outputUnit = self.engine.outputNode.audioUnit;
    OSStatus status = AudioUnitRender(outputUnit, 0, timeStamp, 0, bufferLength, bufferList);
    if (status != noErr) {
        NSLog(@"Can not render audio unit");
        return status;
    }
    timeStamp->mSampleTime += bufferLength;
    status = ExtAudioFileWrite(audioFile, bufferLength, bufferList);
    if (status != noErr)
        NSLog(@"Can not write audio to file");
    return status;
}

- (void)clearBufferList:(AudioBufferList *)bufferList {
    for (int bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; bufferIndex++) {
        memset(bufferList->mBuffers[bufferIndex].mData, 0, bufferList->mBuffers[bufferIndex].mDataByteSize);
    }
}

AudioBufferList *AEAllocateAndInitAudioBufferList(AudioStreamBasicDescription audioFormat, int frameCount) {
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    AudioBufferList *audio = malloc(sizeof(AudioBufferList) + (numberOfBuffers - 1) * sizeof(AudioBuffer));
    if (!audio) {
        return NULL;
    }
    audio->mNumberBuffers = numberOfBuffers;
    for (int i = 0; i < numberOfBuffers; i++) {
        if (bytesPerBuffer > 0) {
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if (!audio->mBuffers[i].mData) {
                for (int j = 0; j < i; j++) free(audio->mBuffers[j].mData);
                free(audio);
                return NULL;
            }
        } else {
            audio->mBuffers[i].mData = NULL;
        }
        audio->mBuffers[i].mDataByteSize = bytesPerBuffer;
        audio->mBuffers[i].mNumberChannels = channelsPerBuffer;
    }
    return audio;
}

void AEFreeAudioBufferList(AudioBufferList *bufferList) {
    for (int i = 0; i < bufferList->mNumberBuffers; i++) {
        if (bufferList->mBuffers[i].mData) free(bufferList->mBuffers[i].mData);
       
    }
    free(bufferList);
}



@end
