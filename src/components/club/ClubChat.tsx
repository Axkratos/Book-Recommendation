import { useState, useRef, useEffect } from 'react';
import { Send } from 'lucide-react';
import { useBookClubs } from '../../context/BookClubContext';

interface ClubChatProps {
  clubId: string;
}

const ClubChat = ({ clubId }: ClubChatProps) => {
  const [message, setMessage] = useState('');
  const { messages, sendMessage } = useBookClubs();
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const clubMessages = messages[clubId] || [];

  useEffect(() => {
    scrollToBottom();
  }, [clubMessages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (message.trim()) {
      sendMessage(clubId, message);
      setMessage('');
    }
  };

  return (
    <div className="flex flex-col h-[600px] bg-white rounded-lg shadow-sm">
      <div className="flex-grow overflow-y-auto p-4 space-y-4">
        {clubMessages.map((msg) => (
          <div
            key={msg.id}
            className={`flex items-start space-x-3 ${
              msg.userId === '1' ? 'flex-row-reverse space-x-reverse' : ''
            }`}
          >
            <img
              src={msg.userAvatar}
              alt={msg.userName}
              className="w-8 h-8 rounded-full"
            />
            <div
              className={`max-w-[70%] rounded-lg p-3 ${
                msg.userId === '1'
                  ? 'bg-primary-100 text-primary-900'
                  : 'bg-gray-100'
              }`}
            >
              <p className="text-sm font-medium mb-1">{msg.userName}</p>
              <p className="text-sm">{msg.content}</p>
              <span className="text-xs text-gray-500 mt-1 block">
                {new Date(msg.timestamp).toLocaleTimeString()}
              </span>
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSubmit} className="p-4 border-t">
        <div className="flex space-x-2">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type your message..."
            className="flex-grow px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          />
          <button
            type="submit"
            className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <Send className="h-5 w-5" />
          </button>
        </div>
      </form>
    </div>
  );
};

export default ClubChat;