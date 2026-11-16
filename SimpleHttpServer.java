import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class SimpleHttpServer {
    public static void main(String[] args) {
        try {
            // Create server instance on port 8000
            HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);

            // Send every path starting with "/" to MyHandler
            server.createContext("/", new MyHandler());

            // Use the default executor
            server.setExecutor(null);

            // Start the server
            server.start();
            System.out.println("Server is running on port 8000");
        } catch (IOException e) {
            System.out.println("Error starting server: " + e.getMessage());
        }
    }

    static class MyHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String response = "Hello, this is a simple HTTP server response!";
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
}
