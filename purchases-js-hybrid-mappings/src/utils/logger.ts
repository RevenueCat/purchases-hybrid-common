export class Logger {
  static warn(message: string): void {
    // eslint-disable-next-line no-console
    console.warn(message);
  }

  static error(message: string): void {
    // eslint-disable-next-line no-console
    console.error(message);
  }
}
