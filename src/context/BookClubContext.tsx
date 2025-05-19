import { createContext, useContext, useState, ReactNode } from 'react';
import { BookClub, bookClubs as initialClubs } from '../data/mockData';

interface Message {
  id: string;
  clubId: string;
  userId: string;
  userName: string;
  userAvatar: string;
  content: string;
  timestamp: Date;
}

interface BookClubContextType {
  clubs: BookClub[];
  joinedClubs: string[];
  messages: Record<string, Message[]>;
  joinClub: (clubId: string) => void;
  leaveClub: (clubId: string) => void;
  sendMessage: (clubId: string, content: string) => void;
  isClubMember: (clubId: string) => boolean;
}

const BookClubContext = createContext<BookClubContextType | undefined>(undefined);

export const useBookClubs = () => {
  const context = useContext(BookClubContext);
  if (!context) {
    throw new Error('useBookClubs must be used within a BookClubProvider');
  }
  return context;
};

export const BookClubProvider = ({ children }: { children: ReactNode }) => {
  const [clubs] = useState<BookClub[]>(initialClubs);
  const [joinedClubs, setJoinedClubs] = useState<string[]>([]);
  const [messages, setMessages] = useState<Record<string, Message[]>>({});

  const joinClub = (clubId: string) => {
    if (!joinedClubs.includes(clubId)) {
      setJoinedClubs([...joinedClubs, clubId]);
    }
  };

  const leaveClub = (clubId: string) => {
    setJoinedClubs(joinedClubs.filter(id => id !== clubId));
  };

  const isClubMember = (clubId: string) => {
    return joinedClubs.includes(clubId);
  };

  const sendMessage = (clubId: string, content: string) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      clubId,
      userId: '1', // Mock user ID
      userName: 'Alice', // Mock user name
      userAvatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150',
      content,
      timestamp: new Date(),
    };

    setMessages(prev => ({
      ...prev,
      [clubId]: [...(prev[clubId] || []), newMessage],
    }));
  };

  return (
    <BookClubContext.Provider
      value={{
        clubs,
        joinedClubs,
        messages,
        joinClub,
        leaveClub,
        sendMessage,
        isClubMember,
      }}
    >
      {children}
    </BookClubContext.Provider>
  );
};