//
//  AudioRander.h
//  Pods
//
//  Created by Dotsocket on 2/2/22.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AudioRander : NSObject{
    
}
 @property(strong, nonatomic) AVAudioEngine *engine;
 @property(strong, nonatomic) AVAudioPlayerNode *playerNode;
 @property(nonatomic, strong) AVAudioMixerNode *mixer;
 @property(nonatomic, strong) AVAudioFile *file;
 @property(nonatomic, copy) NSString *resultPath;

- (void)clearTmpDirectory;
- (void)configureAudioEngine :(AVAudioEngine *)engine playerNode:(AVAudioPlayerNode *)playerNode fileUrl:(AVAudioFile *) fileUrl ;
- (NSString *)renderAudioAndWriteToFileExtension:(NSString *) extension callback:(void (^)(NSUInteger totalBytesWritten,NSUInteger totalBytesExpectedToWrite))completionBlock;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (NSString *)filePath:(NSString *) extension;
- (ExtAudioFileRef)createAndSetupExtAudioFileWithASBD:(AudioStreamBasicDescription const *)audioDescription
                                          andFilePath:(NSString *)path;
- (OSStatus)renderToBufferList:(AudioBufferList *)bufferList
                   writeToFile:(ExtAudioFileRef)audioFile
                  bufferLength:(NSUInteger)bufferLength
                     timeStamp:(AudioTimeStamp *)timeStamp  ;
- (void)clearBufferList:(AudioBufferList *)bufferList ;


@end
