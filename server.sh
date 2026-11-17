#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$DIR/server.pid"
LOGFILE="$DIR/server.log"
OUT="$DIR/out" 

is_running() {
  [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "$1" in
  start)
    if is_running; then
      echo "Already running (PID $(cat "$PIDFILE"))"
    else
      mkdir -p "$OUT"
      javac -d "$OUT" "$DIR/SimpleHttpServer.java" || { echo "Compile failed"; exit 1; }
      : > "$LOGFILE"
      nohup java -cp "$OUT" SimpleHttpServer >> "$LOGFILE" 2>&1 &
      echo $! > "$PIDFILE"
      sleep 2
      if is_running; then
        echo "Started (PID $(cat "$PIDFILE"))"
      else
        echo "Failed to start. Log:"
        cat "$LOGFILE"
        rm -f "$PIDFILE"
      fi
    fi
    ;;
  stop)
    if is_running; then
      kill "$(cat "$PIDFILE")"
      rm -f "$PIDFILE"
      echo "Stopped"
    else
      rm -f "$PIDFILE"
      echo "Not running"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
