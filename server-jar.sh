#!/bin/bash
set -e
cd "$(dirname "$0")"
JAR_FILE='server.jar'
PID_FILE='server.pid'
LOG_FILE='server.log'

is_running(){
    [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null
}

case "$1" in 
    start) 
        if is_running; then 
            echo "Server is already running (PID: $(cat "$PID_FILE"))."
        elif [ ! -f "$JAR_FILE" ]; then
            echo "No $JAR_FILE found. Run: $0 build."
            exit 1
        else
            nohup java -jar "$JAR_FILE" > "$LOG_FILE" 2>&1 &
            echo $! > "$PID_FILE"
            sleep 2
            if is_running; then
                echo "Server started (PID: $(cat "$PID_FILE"))."
            else
                echo "Server failed to start. Log:"
                cat "$LOG_FILE"
                rm -f "$PID_FILE"
                exit 1
            fi 
        fi 
        ;;
    stop)
        if is_running; then
            kill "$(cat "$PID_FILE")"
            rm -f "$PID_FILE"
            echo "Stopped."
        else
            rm -f "$PID_FILE"
            echo "NOT running."
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    build)
        $0 stop
        javac SimpleHttpServer.java
        jar cfe "$JAR_FILE" SimpleHttpServer *.class
        echo "Build complete."
        $0 start
        ;;
    *)
        echo "Usage: ./server-jar.sh {start|stop|restart|build}"
        ;;
esac
        
