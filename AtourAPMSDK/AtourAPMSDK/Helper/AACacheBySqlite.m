//
//  AACacheBySqlite.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import "AACacheBySqlite.h"
#import <sqlite3.h>
@implementation AACacheBySqlite {
    sqlite3 *_database;
    CFMutableDictionaryRef _dbStmtCache;
}

- (void)closeDatabase {
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    sqlite3_close(_database);
    sqlite3_shutdown();
    NSLog(@"%@ close database", self);
}

- (void)dealloc {
    [self closeDatabase];
}

/**
 根据传入的文件路径初始化
 @param filePath  传入的数据文件路径
 @return id 实例
 */
- (id)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (sqlite3_initialize() != SQLITE_OK) {
        NSLog(@"failed to initialize SQLite.");
        return nil;
    }
    if (sqlite3_open_v2([filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK && sqlite3_wal_checkpoint(_database, nil) == SQLITE_OK) {
        // 创建一个缓存表
        NSString *cpu_sql = @"create table if not exists cpu_table (id INTEGER PRIMARY KEY AUTOINCREMENT, value FLOAT, timestamp TIMESTAMP)";
        NSString *ram_sql = @"create table if not exists ram_table (id INTEGER PRIMARY KEY AUTOINCREMENT, value FLOAT, timestamp TIMESTAMP)";
        NSString *network_sql = @"create table if not exists network_table (id INTEGER PRIMARY KEY AUTOINCREMENT, value FLOAT, timestamp TIMESTAMP)";
        NSString *fps_sql = @"create table if not exists fps_table (id INTEGER PRIMARY KEY AUTOINCREMENT, value FLOAT, timestamp TIMESTAMP)";
        NSString *anr_sql = @"create table if not exists anr_table (id INTEGER PRIMARY KEY AUTOINCREMENT, value TEXT, timestamp TIMESTAMP)";
        char *errorMsg;
        if (sqlite3_exec(_database, [cpu_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            &&sqlite3_exec(_database, [ram_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            &&sqlite3_exec(_database, [network_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            &&sqlite3_exec(_database, [fps_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            &&sqlite3_exec(_database, [anr_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
        } else {
            NSLog(@"create apm cache failure %s", errorMsg);
            return nil;
        }
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = { 0 };
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        
    } else {
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        NSLog(@"failed to open SQLite db.");
        return nil;
    }
    return self;
}


- (sqlite3_stmt *)dbCacheStmt:(NSString *)sql {
    if (sql.length == 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_database));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

/**
 添加CPUUsage 数据
 @param cpuUsage app占用CPU 百分比
 @param timestamp 时间戳
 */
- (void)addCpuUsage:(float)cpuUsage timestamp:(NSString *)timestamp {
    NSString *query = @"INSERT INTO cpu_table(value, timestamp) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_double(insertStatement, 1, cpuUsage);
        sqlite3_bind_text(insertStatement, 2, timestamp.UTF8String, -1, SQLITE_TRANSIENT);
        
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"insert into cpu_table fail, rc is %d", rc);
        }
    } else {
        NSLog(@"insert into cpu_table error");
    }
}

/**
 添加RAMUsage 数据
 @param app_ram_usage  app占用的RAM
 @param timestamp 时间戳
 */
- (void)addAppRamUsage:(float)app_ram_usage timestamp:(NSString *)timestamp {
    NSString *query = @"INSERT INTO ram_table(value, timestamp) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_double(insertStatement, 1, app_ram_usage);
        sqlite3_bind_text(insertStatement, 2, timestamp.UTF8String, -1, SQLITE_TRANSIENT);
        
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"insert into ram_table fail, rc is %d", rc);
        }
    } else {
        NSLog(@"insert into ram_table error");
    }
}
/**
 添加流量数据
@param received app收到的流量
@param timestamp 时间戳
*/
- (void)addNetworkFlow:(unsigned int)received timestamp:(NSString *)timestamp {
    NSString *query = @"INSERT INTO network_table(value, timestamp) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_double(insertStatement, 1, received);
        sqlite3_bind_text(insertStatement, 2, timestamp.UTF8String, -1, SQLITE_TRANSIENT);
        
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"insert into network_table fail, rc is %d", rc);
        }
    } else {
        NSLog(@"insert into network_table error");
    }
}
                        
/**
 添加FPS 数据
@param fps 刷新率
@param timestamp 时间戳
 */
- (void)addFPS:(float)fps timestamp:(NSString *)timestamp {
    NSString *query = @"INSERT INTO fps_table(value, timestamp) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_double(insertStatement, 1, fps);
        sqlite3_bind_text(insertStatement, 2, timestamp.UTF8String, -1, SQLITE_TRANSIENT);
        
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"insert into fps_table fail, rc is %d", rc);
        }
    } else {
        NSLog(@"insert into fps_table error");
    }
}

/**
 添加ANR 数据
@param callStack 堆栈数据
@param timestamp 时间戳
 */
- (void)addANR:(NSString *)callStack timestamp:(NSString *)timestamp {
    NSString *query = @"INSERT INTO anr_table(value, timestamp) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_text(insertStatement, 1, callStack.UTF8String, -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(insertStatement, 2, timestamp.UTF8String, -1, SQLITE_TRANSIENT);
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"insert into anr_table fail, rc is %d", rc);
        }
    } else {
        NSLog(@"insert into anr_table error");
    }
}
@end
