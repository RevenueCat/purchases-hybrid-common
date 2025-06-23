import { LogLevel } from '@revenuecat/purchases-js';
import { Logger } from '../utils/logger';

export function mapLogLevel(logLevel: string): LogLevel | null {
  const upperCaseLogLevel = logLevel.toUpperCase();
  switch (upperCaseLogLevel) {
    case 'VERBOSE':
      return LogLevel.Verbose;
    case 'DEBUG':
      return LogLevel.Debug;
    case 'INFO':
      return LogLevel.Info;
    case 'WARN':
      return LogLevel.Warn;
    case 'ERROR':
      return LogLevel.Error;
    case 'SILENT':
      return LogLevel.Silent;
    default:
      Logger.warn(`Invalid log level: ${logLevel}`);
      return null;
  }
}
