//
//  WGXBeacon.h
//  WGXBeacon
//
//  Created by zhangtan on 14-12-14.
//  Copyright (c) 2014年 zhangtan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UUID_1_WGXbeacon_Enum = 10 , //UUID 1
    Major_1_WGXbeacon_Enum,//Major 1
    Minor_1_WGXbeacon_Enum,//Minor 1
    
    UUID_2_WGXbeacon_Enum , //UUID 2
    Major_2_WGXbeacon_Enum,//Major 2
    Minor_2_WGXbeacon_Enum,//Minor 2
    
    MeasuredPower_WGXbeacon_Enum,//iBeacon 1米信号校准
    DeviceName_WGXbeacon_Enum,//设备名称
    
    OriBeaconPassword_WGXbeacon_Enum,//ibeacon原始密码
    CurBeaconPassword_WGXbeacon_Enum,//即将写入的密码
    
    SendFrequence_WGXbeacon_Enum,//发射频率
    
    SendTimeInter_WGXbeacon_Enum,//两个UUID发射时间间隔
    
    SignalUUIDSendTime_WGXbeacon_Enum, //单个UUID发射时间
    SendPower_WGXbeacon_Enum, //发射功率
    
    Password_WGXbeacon_Enum, //密码
    
    Resume_WGXbeacon_Enum, //恢复出厂设置
    
    End_WGXbeacon_Enum,//结束
}WGXBeaconTypeEnum;

@protocol WGXBeaconDelegate ;

@interface WGXBeacon : NSObject

@property (nonatomic , assign) id <WGXBeaconDelegate> delegate;//代理

@property (nonatomic , assign) float distanceForDisconnect;//连接信号强度,默认是-50

@property (nonatomic, assign) int setType;

//修改密码:
//nPassWord 新密码
//oldPassWord 旧密码
- (void)changePassWordWithNew:(NSString *)nPassWord oldPassWord:(NSString *)oldPassWord;

//恢复出厂设置
- (void)resumeOriStateWithOriPassWord:(NSString *)oriPassWord;


//开始写入数据，这里传入的格式是字典
//key为WGXBeaconTypeEnum字符
/*
 如
 NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"1234",[NSString stringWithFormat:@"%d",UUID_1_WGXbeacon_Enum],
                             nil];
 */
- (void)startWriteCharacteristicValueWithInfo:(NSDictionary *)infoDic;

@end

@protocol WGXBeaconDelegate <NSObject>

@optional
//修改成功回调
- (void)blueToothManagerConfigSuccess:(WGXBeacon *)currentView;

//等待超时
- (void)blueToothManagerBlankWait:(WGXBeacon *)currentView;

//写数据出现错误
- (void)blueToothManagerWriteError:(WGXBeacon *)currentView;
//密码错误
- (void)blueToothManagerPasswordError:(WGXBeacon *)currentView;

- (void)bluetoothIsConnectWith:(BOOL)isConnect;

- (void)readPowerSuccessWith:(int)powerValue;
- (void)blueToothManagerGetRSSI:(int)rssiValue;

@end
