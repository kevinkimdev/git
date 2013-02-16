library bot_io;

import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:logging/logging.dart' as logging;
import 'package:args/args.dart';
import 'package:bot/bot.dart';

part 'src/bot_io/ansi_color.dart';
part 'src/bot_io/completion.dart';
part 'src/bot_io/console.dart';
part 'src/bot_io/io_helpers.dart';
part 'src/bot_io/temp_dir.dart';
part 'src/bot_io/directory_populater.dart';

/*
 * TODO: Document this! Cool trick, but needs details.
 */
/**
 * When called, a listener is added to the root [Logger] and all output is
 * appended to a log file named "`new Options().script`.log".
 *
 * The format: [LogRecord.time] 'tab' [LogRecord.loggerName] 'tab' [LoggerRecord.message]
 */
void enableScriptLogListener() {
  if(_scriptLogListenerPath == null) {
    final options = new Options();

    final script = options.script;
    _scriptLogListenerPath = new Path(script).toNativePath().concat('.log');

    final logging.Logger rootLogger = logging.Logger.root;

    rootLogger.on.record.add(_doLog);

    final logging.Logger logger = logging.Logger.root;

    logger.info('Starting log for $script at $_scriptLogListenerPath');
  }
}

String _scriptLogListenerPath;

void _doLog(logging.LogRecord record) {

  final msg = '${record.time}\t${record.loggerName}\t${record.message}';

  final logFile = new File(_scriptLogListenerPath);

  logFile.writeAsStringSync('$msg\n', mode: FileMode.APPEND);
}
