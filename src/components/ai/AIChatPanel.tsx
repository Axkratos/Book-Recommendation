import { useState, useRef, useEffect } from 'react';
import { SendHorizontal } from 'lucide-react';
import { AIMessage, aiConversation as initialMessages } from '../../data/mockData';

interface AIChatPanelProps {
  bookId?: string;
}

const AIChatPanel = ({ bookId }: AIChatPanelProps) => {
  const [messages, setMessages] = useState<AIMessage[]>(initialMessages);
  const [newMessage, setNewMessage] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    scrollToBottom();
  }, [messages]);
  
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };
  
  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim()) return;
    
    // Add user message
    const userMessage: AIMessage = {
      id: String(Date.now()),
      sender: 'user',
      message: newMessage,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };
    
    setMessages(prev => [...prev, userMessage]);
    setNewMessage('');
    
    // Simulate AI response after a delay
    setTimeout(() => {
      const aiResponse: AIMessage = {
        id: String(Date.now() + 1),
        sender: 'ai',
        message: getAIResponse(newMessage, bookId),
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      };
      
      setMessages(prev => [...prev, aiResponse]);
    }, 1000);
  };
  
  const getAIResponse = (message: string, bookId?: string): string => {
    // Simple mock AI responses based on user input
    const lowerMsg = message.toLowerCase();
    
    if (lowerMsg.includes('hello') || lowerMsg.includes('hi')) {
      return "Hello! I'm your AI reading companion. How can I enhance your reading experience today?";
    } else if (lowerMsg.includes('character') || lowerMsg.includes('protagonist')) {
      return bookId === '1'
        ? "Essun is a complex protagonist who is dealing with tremendous grief while navigating a world ending cataclysm. Her journey is both physical and emotional as she searches for her daughter."
        : "The protagonist of this book is on a challenging journey that tests their beliefs and resolve. Would you like me to analyze their character arc without spoilers?";
    } else if (lowerMsg.includes('summary') || lowerMsg.includes('plot')) {
      return "This story explores themes of resilience in the face of catastrophe, examining how societies break and rebuild. The narrative moves between different timelines, gradually revealing how past events connect to present circumstances.";
    } else if (lowerMsg.includes('recommend') || lowerMsg.includes('suggestion')) {
      return "Based on this book, you might also enjoy 'The Broken Earth Trilogy' by N.K. Jemisin, 'The Memory Police' by Yoko Ogawa, or 'Station Eleven' by Emily St. John Mandel.";
    } else if (lowerMsg.includes('theme') || lowerMsg.includes('symbolism')) {
      return "The key themes in this work include power imbalances, ecological disaster, and found family. The author uses recurring symbols like stone and ash to represent permanence and transformation.";
    } else {
      return "That's an interesting question about the book. The author has crafted a narrative that invites readers to explore complex questions about society and human nature. Would you like me to elaborate on any particular aspect?";
    }
  };
  
  return (
    <div className="flex flex-col h-full border border-gray-200 rounded-lg bg-white shadow-sm">
      <div className="bg-gray-50 border-b border-gray-200 p-3">
        <h3 className="font-medium">AI Reading Companion</h3>
        <p className="text-xs text-gray-500">Ask questions about characters, themes, or get recommendations</p>
      </div>
      
      <div className="flex-grow overflow-y-auto p-4 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[75%] rounded-lg p-3 ${
                msg.sender === 'user'
                  ? 'bg-primary-100 text-gray-800'
                  : 'bg-white border border-gray-200 text-gray-800'
              }`}
            >
              <p className="text-sm">{msg.message}</p>
              <span className="text-xs text-gray-500 mt-1 block text-right">
                {msg.timestamp}
              </span>
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      
      <form onSubmit={handleSendMessage} className="border-t border-gray-200 p-3">
        <div className="flex items-center">
          <input
            type="text"
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            className="flex-grow border border-gray-300 rounded-l-md px-3 py-2 focus:ring-2 focus:ring-primary-300 focus:border-primary-500 focus:outline-none"
            placeholder="Ask your AI Companion..."
          />
          <button
            type="submit"
            className="bg-primary-600 text-white rounded-r-md p-2 hover:bg-primary-700 transition-colors"
          >
            <SendHorizontal className="h-5 w-5" />
          </button>
        </div>
      </form>
    </div>
  );
};

export default AIChatPanel;