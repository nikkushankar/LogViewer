package io.funxion.logviewer;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.LogRecord;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;


@ServerEndpoint(value="/serverlog")
public class WebsocketAppender extends java.util.logging.StreamHandler{

    /* Queue for all open WebSocket sessions */
    static Queue<Session> queue = new ConcurrentLinkedQueue<Session>();
    
	@OnOpen
    public void openConnection(Session session) throws SecurityException, IOException {
        /* Register this connection in the queue */
        queue.add(session);                
    }
    
    @OnClose
    public void closedConnection(Session session) {
        /* Remove this connection from the queue */
        queue.remove(session);
    }
    
    @OnError
    public void error(Session session, Throwable t) {
        /* Remove this connection from the queue */
        queue.remove(session);
    }

	@Override
	public synchronized void publish(LogRecord record) {
		for (Session session : queue) {
			try {
				session.getBasicRemote().sendText(record.getMessage());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		super.publish(record);
	}
}
