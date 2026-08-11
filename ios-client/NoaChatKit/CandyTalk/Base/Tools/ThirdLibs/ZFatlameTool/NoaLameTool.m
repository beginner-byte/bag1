//
//  NoaLameTool.m
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

#import "NoaLameTool.h"
#import "lame.h"

@implementation NoaLameTool

//录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
+ (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                           callback:(void(^)(BOOL result))callback {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        @try {
            int read, write;
            
            // 打开源PCM文件
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
            if (pcm == NULL) {
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setObject:@"打开源PCM文件失败" forKey:@"recordVocieFailReason"];//失败原因
                [loganDict setObject:cafFilePath forKey:@"cafFilePath"];//mp3文件路径
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

                if (callback) {
                    callback(NO);
                }
                return;
            }
            
            // 跳过文件头
            fseek(pcm, 4*1024, SEEK_CUR);
            
            // 打开目标MP3文件
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSUTF8StringEncoding], "wb+");
            if (mp3 == NULL) {
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setObject:@"打开目标MP3文件失败" forKey:@"recordVocieFailReason"];//失败原因
                [loganDict setObject:mp3FilePath forKey:@"mp3FilePath"];//mp3文件路径
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

                fclose(pcm);
                if (callback) {
                    callback(NO);
                }
                return;
            }

            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];

            lame_t lame = lame_init();
            lame_set_num_channels(lame, 2);//默认为2双通道
            lame_set_in_samplerate(lame, 44100);//注意转换的时候，必须和采样的时候设置的采样率保持一致
            lame_set_VBR(lame, vbr_default);
            lame_set_brate(lame, 8);
            lame_set_quality(lame, 5); // 2=high 5 = medium 7=low 音质
            if (lame_init_params(lame) < 0) {
                NSLog(@"Failed to initialize LAME encoder parameters");
                lame_close(lame);
                fclose(pcm);
                fclose(mp3);
                if (callback) {
                    callback(NO);
                }
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setObject:@"lame 初始化参数失败" forKey:@"recordVocieFailReason"];//失败原因
                [loganDict setObject:mp3FilePath forKey:@"mp3FilePath"];//mp3文件路径
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

                return;
            }
            size_t read_size = 2 * sizeof(short int);
            do {
                read = (int)fread(pcm_buffer, read_size, PCM_SIZE, pcm);
                if (read == 0) {
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                } else {
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer, write, 1, mp3);
                }
            } while (read != 0);

            lame_mp3_tags_fid(lame, mp3);

            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            if (callback) {
                callback(YES);
            }
        }
        @catch (NSException *exception) {
            //NSLog(@"%@",[exception description]);
            //录音文件转mp3失败
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setObject:@"录音文件转mp3失败" forKey:@"recordVocieFail"];//失败原因
            [loganDict setObject:[exception description] forKey:@"recordVocieFailReason"];//失败原因
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

            //回调
            if (callback) {
                callback(NO);
            }
        }
        @finally {
            NSLog(@"-----\n  MP3生成成功: %@   -----  \n", mp3FilePath);
        }
    });
    
}

@end
