part of hop;

typedef void Printer(Object value);

class RootTaskContext {
  final Printer _printer;
  final bool _enableColor;
  final bool _prefixEnabled;
  final Level _minLogLevel;

  RootTaskContext(Printer printer, {bool colorEnabled:true,
    bool prefixEnabled: true,
    Level minLogLevel: Level.ALL}) :
    _printer = printer,
    _enableColor = colorEnabled,
    _prefixEnabled = prefixEnabled,
    _minLogLevel = minLogLevel {
      requireArgumentNotNull(printer, 'printer');
      requireArgumentNotNull(colorEnabled, 'colorEnabled');
      requireArgumentNotNull(prefixEnabled, 'prefixEnabled');
      requireArgumentNotNull(minLogLevel, 'minLogLevel');
    }

  TaskContext getSubContext(String name, ArgResults arguments) =>
    new _SubTaskContext(this, name, arguments);

  void log(String message, [AnsiColor color = null]) {
    if(!_enableColor) {
      color = null;
    }

    if(color != null) {
      message = color.wrap(message);
    }

    _printer(message);
  }

  void _subTaskLog(_SubTaskContext subTask, Level logLevel, String message) {
    assert(subTask._parent == this);
    _logCore([subTask._name], logLevel, message);
  }

  void _logCore(List<String> titleSections, Level logLevel, String message) {
    requireArgumentNotNull(message, 'message');
    assert(!titleSections.isEmpty);
    assert(titleSections.every((s) => s != null && !s.isEmpty));

    if(logLevel >= _minLogLevel) {
      if(_prefixEnabled) {
        final color = _getColor(logLevel);

        var indent = '';
        var title = titleSections.join(' - ').concat(': ');

        while(indent.length < title.length) {
          indent =  indent.concat(' ');
        }

        if(color != null) {
          title = color.wrap(title);
        }

        final lines = Util.splitLines(message);
        var first = true;
        for(final l in lines) {
          if(first) {
            first = false;
            _printer(title.concat(l));
          } else {
            _printer(indent.concat(l));
          }
        }
      } else {
        _printer(message);
      }
    }
  }

  AnsiColor _getColor(Level logLevel) {
    if(_enableColor) {
      return getLogColor(logLevel);
    } else {
      return null;
    }
  }

  static AnsiColor getLogColor(Level logLevel) {
    requireArgumentNotNull(logLevel, 'logLevel');
    if(logLevel.value > Level.WARNING.value) {
      return AnsiColor.RED;
    } else if(logLevel.value > Level.INFO.value) {
      return AnsiColor.LIGHT_RED;
    } else if(logLevel.value >= Level.INFO.value) {
      return AnsiColor.BLUE;
    } else {
      return AnsiColor.GRAY;
    }
  }
}

class _SubTaskContext extends TaskContext {
  final String _name;
  final RootTaskContext _parent;
  final ArgResults arguments;

  bool _isDisposed = false;

  _SubTaskContext(this._parent, this._name, this.arguments);

  bool get isDisposed => _isDisposed;

  void log(Level logLevel, String message) {
    _assertNotDisposed();
    _parent._subTaskLog(this, logLevel, message);
  }

  TaskLogger getSubLogger(String name) {
    _assertNotDisposed();
    return new _SubLogger(name, this);
  }

  void dispose() {
    _assertNotDisposed();
    _isDisposed = true;
  }

  void _subLoggerLog(_SubLogger logger, Level logLevel, String message) {
    _assertNotDisposed();
    _parent._logCore([_name, logger._name], logLevel, message);
  }

  void _assertNotDisposed() {
    if(_isDisposed) {
      throw 'already disposed';
    }
  }
}

class _SubLogger extends TaskLogger {
  final String _name;
  final _SubTaskContext _parent;

  _SubLogger(this._name, this._parent);

  void log(Level logLevel, String message) {
    _parent._subLoggerLog(this, logLevel, message);
  }
}
